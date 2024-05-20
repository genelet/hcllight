package hcl

import (
	"github.com/genelet/hcllight/light"
)

// reference
func (self *Reference) toBody() (*light.Body, error) {
	if self == nil {
		return nil, nil
	}

	body := &light.Body{
		Attributes: map[string]*light.Attribute{
			"XRef": {
				Name: "XRef",
				Expr: stringToTextValueExpr(self.XRef),
			},
		},
	}
	if self.Summary != "" {
		body.Attributes["summary"] = &light.Attribute{
			Name: "summary",
			Expr: stringToTextValueExpr(self.Summary),
		}
	}
	if self.Description != "" {
		body.Attributes["description"] = &light.Attribute{
			Name: "description",
			Expr: stringToTextValueExpr(self.Description),
		}
	}
	return body, nil
}

func referenceToExpression(self *Reference) *light.Expression {
	if self == nil {
		return nil
	}

	if self.Summary == "" && self.Description == "" && (self.XRef)[:2] == "#/" {
		return stringToTraversal((self.XRef)[:2])
	}

	args := []*light.Expression{
		stringToLiteralValueExpr(self.XRef),
	}
	if self.Summary != "" {
		args = append(args, stringToTextValueExpr(self.Summary))
	}
	if self.Description != "" {
		args = append(args, stringToTextValueExpr(self.Description))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: "reference",
				Args: args,
			},
		},
	}
}
