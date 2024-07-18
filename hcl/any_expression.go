package hcl

import (
	"fmt"
	"strings"

	"github.com/genelet/hcllight/light"
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
		return light.StringToLiteralValueExpr(fmt.Sprintf("%v", self.Value)), nil
	}
	if typ == nil {
		return light.StringToTextValueExpr(strings.TrimSpace(self.Yaml), true), nil
	}

	var err error
	switch typ[0] {
	case "string":
		var str string
		err = yaml.Unmarshal([]byte(self.Yaml), &str)
		if err == nil {
			return light.StringToTextValueExpr(str, true), nil
		}
	case "integer":
		var i int
		err = yaml.Unmarshal([]byte(self.Yaml), &i)
		if err == nil {
			return light.Int64ToLiteralValueExpr(int64(i)), nil
		}
	case "number":
		var f float64
		err = yaml.Unmarshal([]byte(self.Yaml), &f)
		if err == nil {
			return light.Float64ToLiteralValueExpr(f), nil
		}
	case "boolean":
		var b bool
		err = yaml.Unmarshal([]byte(self.Yaml), &b)
		if err == nil {
			return light.BooleanToLiteralValueExpr(b), nil
		}
	case "object", "map":
		obj := make(map[string]interface{})
		err = yaml.Unmarshal([]byte(self.Yaml), &obj)
		if err == nil {
			var items []*light.ObjectConsItem
			for k, v := range obj {
				var keyExpr *light.Expression
				if !strings.Contains(k, ".") && ((k[0] >= 'a' && k[0] <= 'z') || (k[0] >= 'A' && k[0] <= 'Z')) {
					keyExpr = light.StringToLiteralValueExpr(k)
				} else {
					keyExpr = light.StringToTextValueExpr(k)
				}
				items = append(items, &light.ObjectConsItem{
					KeyExpr:   keyExpr,
					ValueExpr: light.StringToTextValueExpr(fmt.Sprintf("%v", v)),
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
		err = yaml.Unmarshal([]byte(self.Yaml), &arr)
		if err == nil {
			var exprs []*light.Expression
			for _, v := range arr {
				exprs = append(exprs, light.StringToTextValueExpr(fmt.Sprintf("%v", v)))
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
		return light.StringToTextValueExpr(self.Yaml), nil
	}
	return nil, err
}

func anyFromHCL(expr *light.Expression) (*Any, error) {
	if expr == nil {
		return nil, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Texpr:
		return &Any{
			Yaml: *light.TextValueExprToString(expr),
		}, nil
	case *light.Expression_Lvexpr:
		return &Any{
			Yaml: fmt.Sprintf("%v", light.LiteralValueExprToInterface(expr)),
		}, nil
	case *light.Expression_Ocexpr:
		obj := light.ObjConsExprToStringMap(expr)
		yml, err := yaml.Marshal(obj)
		return &Any{
			Yaml: string(yml),
		}, err
	case *light.Expression_Tcexpr:
		arr := light.TupleConsExprToStringArray(expr)
		yml, err := yaml.Marshal(arr)
		return &Any{
			Yaml: string(yml),
		}, err
	default:
	}
	return nil, nil
}

func addSpecification(se map[string]*Any, blocks *[]*light.Block) error {
	if len(se) == 0 {
		return nil
	}
	bdy, err := anyMapToBody(se)
	if err != nil {
		return err
	}
	if bdy == nil {
		return nil
	}
	*blocks = append(*blocks, &light.Block{
		Type: "specificationExtension",
		Bdy:  bdy,
	})
	return nil
}

func getSpecification(body *light.Body) (map[string]*Any, error) {
	if body == nil {
		return nil, nil
	}
	for _, block := range body.Blocks {
		if block.Type == "specificationExtension" {
			return bodyToAnyMap(block.Bdy)
		}
	}
	return nil, nil
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
