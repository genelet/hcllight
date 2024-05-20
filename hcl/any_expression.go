package hcl

import (
	"fmt"
	"strings"

	"github.com/genelet/hcllight/light"
	"google.golang.org/protobuf/types/known/anypb"
)

func (self *Any) toExpression(how ...bool) *light.Expression {
	if how != nil && len(how) > 0 {
		x := self.Yaml
		if x == "" && self.Value != nil {
			x = fmt.Sprintf("%v", self.Value.GetValue())
		}
		return stringToTextValueExpr(strings.TrimSpace(x))
	}

	var args []*light.Expression

	if self.Yaml != "" {
		args = append(args, stringToTextValueExpr(strings.TrimSpace(self.Yaml)))
	} else if self.Value != nil {
		args = append(args, stringToLiteralValueExpr(fmt.Sprintf("%v", self.Value)))
	}

	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: "any",
				Args: args,
			},
		},
	}
}

func anyFromHCL(expr *light.Expression) *Any {
	if expr == nil {
		return nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Texpr:
		return &Any{
			Yaml: expr.GetTexpr().Parts[0].GetLvexpr().GetVal().GetStringValue(),
		}
	case *light.Expression_Lvexpr:
		return &Any{
			Value: &anypb.Any{
				Value: []byte(fmt.Sprintf("%v", expr.GetLvexpr().Val)),
			},
		}
	default:
	}
	return nil
}

func addSpecificationBlock(se map[string]*Any, blocks *[]*light.Block) {
	if se == nil || len(se) == 0 {
		return
	}
	bdy := anyMapToBody(se)
	*blocks = append(*blocks, &light.Block{
		Type: "specificationExtension",
		Bdy:  bdy,
	})
}

func anyMapToBody(content map[string]*Any) *light.Body {
	if content == nil {
		return nil
	}
	body := &light.Body{
		Attributes: make(map[string]*light.Attribute),
	}
	for k, v := range content {
		body.Attributes[k] = &light.Attribute{
			Name: k,
			Expr: v.toExpression(),
		}
	}
	return body
}

func bodyToAnyMap(body *light.Body) map[string]*Any {
	if body == nil {
		return nil
	}
	hash := make(map[string]*Any)
	for k, v := range body.Attributes {
		hash[k] = anyFromHCL(v.Expr)
	}
	return hash
}

func (self *Expression) toExpression() *light.Expression {
	if self.AdditionalProperties == nil {
		return nil
	}
	body := anyMapToBody(self.AdditionalProperties)
	return &light.Expression{
		ExpressionClause: &light.Expression_Ocexpr{
			Ocexpr: body.ToObjectConsExpr(),
		},
	}
}

func expressionFromHCL(expr *light.Expression) *Expression {
	if expr == nil {
		return nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Ocexpr:
		return &Expression{
			AdditionalProperties: bodyToAnyMap(expr.GetOcexpr().ToBody()),
		}
	default:
	}
	return nil
}

func (self *AnyOrExpression) toExpression() *light.Expression {
	switch self.Oneof.(type) {
	case *AnyOrExpression_Expression:
		t := self.GetExpression()
		return t.toExpression()
	case *AnyOrExpression_Any:
		t := self.GetAny()
		return t.toExpression()
	default:
	}
	return nil
}

func anyOrExpressionFromHCL(expr *light.Expression) *AnyOrExpression {
	if expr == nil {
		return nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Ocexpr:
		return &AnyOrExpression{
			Oneof: &AnyOrExpression_Expression{
				Expression: expressionFromHCL(expr),
			},
		}
	default:
		return &AnyOrExpression{
			Oneof: &AnyOrExpression_Any{
				Any: anyFromHCL(expr),
			},
		}
	}
}
