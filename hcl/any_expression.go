package hcl

import (
	"fmt"
	"log"
	"strings"

	"github.com/genelet/hcllight/light"
	"google.golang.org/protobuf/types/known/anypb"
	"gopkg.in/yaml.v2"
)

func (self *Any) toExpression(typ ...string) (*light.Expression, error) {
	if self == nil {
		return nil, nil
	}
	if self.Yaml == "" {
		return nil, nil
	}
	if self.Value != nil {
		return stringToLiteralValueExpr(fmt.Sprintf("%v", self.Value)), nil
	}
	if typ == nil {
		return stringToTextValueExpr(strings.TrimSpace(self.Yaml)), nil
	}

	var err error
	switch typ[0] {
	case "string":
		var str string
		err = yaml.Unmarshal([]byte(self.Yaml), &str)
		if err == nil {
			return stringToTextValueExpr(str), nil
		}
	case "integer":
		var i int
		err = yaml.Unmarshal([]byte(self.Yaml), &i)
		if err == nil {
			return int64ToLiteralValueExpr(int64(i)), nil
		}
	case "number":
		var f float64
		err = yaml.Unmarshal([]byte(self.Yaml), &f)
		if err == nil {
			return float64ToLiteralValueExpr(f), nil
		}
	case "boolean":
		var b bool
		err = yaml.Unmarshal([]byte(self.Yaml), &b)
		if err == nil {
			return booleanToLiteralValueExpr(b), nil
		}
	case "object", "map":
		obj := make(map[string]interface{})
		err = yaml.Unmarshal([]byte(self.Yaml), &obj)
		if err == nil {
			var items []*light.ObjectConsItem
			for k, v := range obj {
				items = append(items, &light.ObjectConsItem{
					KeyExpr:   stringToLiteralValueExpr(k),
					ValueExpr: stringToTextValueExpr(fmt.Sprintf("%v", v)),
				})
			}
			return &light.Expression{
				ExpressionClause: &light.Expression_Ocexpr{
					Ocexpr: &light.ObjectConsExpr{
						Items: items,
					},
				},
			}, nil
		}
	case "array":
		arr := make([]interface{}, 0)
		log.Printf("%s", self.Yaml)
		err = yaml.Unmarshal([]byte(self.Yaml), &arr)
		if err == nil {
			var exprs []*light.Expression
			for _, v := range arr {
				exprs = append(exprs, stringToTextValueExpr(fmt.Sprintf("%v", v)))
			}
			return &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: &light.TupleConsExpr{
						Exprs: exprs,
					},
				},
			}, nil
		}
	default:
	}

	if err != nil && strings.Contains(err.Error(), "cannot unmarshal !!str ") {
		return stringToTextValueExpr(self.Yaml), nil
	}
	return nil, err
}

func (self *Any) toFcexpr(typ ...string) (*light.Expression, error) {
	expr, err := self.toExpression(typ...)
	if err != nil {
		return nil, err
	}
	args := []*light.Expression{expr}

	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: "example",
				Args: args,
			},
		},
	}, nil
}

func fcexprToAny(expr *light.Expression) (*Any, error) {
	if expr == nil {
		return nil, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Fcexpr:
		return &Any{
			Value: &anypb.Any{
				Value: []byte(fmt.Sprintf("%v", expr.GetFcexpr().Args[0].GetLvexpr().Val)),
			},
		}, nil
	default:
	}
	return nil, nil
}

func anyFromHCL(expr *light.Expression) (*Any, error) {
	if expr == nil {
		return nil, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Texpr:
		return &Any{
			Yaml: expr.GetTexpr().Parts[0].GetLvexpr().GetVal().GetStringValue(),
		}, nil
	case *light.Expression_Lvexpr:
		return &Any{
			Yaml: fmt.Sprintf("%v", expr.GetLvexpr().Val),
		}, nil
	case *light.Expression_Ocexpr:
		return &Any{
			Yaml: fmt.Sprintf("%v", expr.GetOcexpr().ToBody()),
		}, nil
	case *light.Expression_Tcexpr:
		return &Any{
			Yaml: fmt.Sprintf("%v", expr.GetTcexpr().GetExprs()),
		}, nil
	case *light.Expression_Fcexpr:
		return fcexprToAny(expr)
	default:
	}
	return nil, nil
}

func addSpecificationBlock(se map[string]*Any, blocks *[]*light.Block) error {
	if se == nil || len(se) == 0 {
		return nil
	}
	bdy, err := anyMapToBody(se)
	if err != nil {
		return err
	}
	*blocks = append(*blocks, &light.Block{
		Type: "specificationExtension",
		Bdy:  bdy,
	})
	return nil
}

func anyMapToBody(content map[string]*Any) (*light.Body, error) {
	if content == nil {
		return nil, nil
	}
	body := &light.Body{
		Attributes: make(map[string]*light.Attribute),
	}
	for k, v := range content {
		expr, err := v.toExpression()
		if err != nil {
			return nil, err
		}
		body.Attributes[k] = &light.Attribute{
			Name: k,
			Expr: expr,
		}
	}
	return body, nil
}

func bodyToAnyMap(body *light.Body) (map[string]*Any, error) {
	if body == nil {
		return nil, nil
	}
	hash := make(map[string]*Any)
	var err error
	for k, v := range body.Attributes {
		hash[k], err = anyFromHCL(v.Expr)
		if err != nil {
			return nil, err
		}
	}
	return hash, nil
}

func (self *Expression) toExpression() (*light.Expression, error) {
	if self.AdditionalProperties == nil {
		return nil, nil
	}
	body, err := anyMapToBody(self.AdditionalProperties)
	if err != nil {
		return nil, err
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Ocexpr{
			Ocexpr: body.ToObjectConsExpr(),
		},
	}, nil
}

func expressionFromHCL(expr *light.Expression) (*Expression, error) {
	if expr == nil {
		return nil, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Ocexpr:
		anymap, err := bodyToAnyMap(expr.GetOcexpr().ToBody())
		if err != nil {
			return nil, err
		}
		return &Expression{
			AdditionalProperties: anymap,
		}, nil
	default:
	}
	return nil, nil
}

func (self *AnyOrExpression) toExpression() (*light.Expression, error) {
	switch self.Oneof.(type) {
	case *AnyOrExpression_Expression:
		t := self.GetExpression()
		return t.toExpression()
	case *AnyOrExpression_Any:
		t := self.GetAny()
		return t.toExpression()
	default:
	}
	return nil, nil
}

func anyOrExpressionFromHCL(expr *light.Expression) (*AnyOrExpression, error) {
	if expr == nil {
		return nil, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Ocexpr:
		e, err := expressionFromHCL(expr)
		if err != nil {
			return nil, err
		}
		return &AnyOrExpression{
			Oneof: &AnyOrExpression_Expression{
				Expression: e,
			},
		}, nil
	default:
	}

	any, err := anyFromHCL(expr)
	if err != nil {
		return nil, err
	}
	return &AnyOrExpression{
		Oneof: &AnyOrExpression_Any{
			Any: any,
		},
	}, nil
}
