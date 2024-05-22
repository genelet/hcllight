package hcl

import (
	"fmt"
	"strings"

	"github.com/genelet/hcllight/light"
)

// reference
func (self *Reference) toHCL() (*light.Body, error) {
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

func referenceFromHCL(body *light.Body) (*Reference, error) {
	if body == nil {
		return nil, nil
	}

	self := &Reference{}
	var found bool
	if attr, ok := body.Attributes["XRef"]; ok {
		if attr.Expr != nil {
			self.XRef = *textValueExprToString(attr.Expr)
			found = true
		}
	}
	if attr, ok := body.Attributes["summary"]; ok {
		if attr.Expr != nil {
			self.Summary = *textValueExprToString(attr.Expr)
		}
	}
	if attr, ok := body.Attributes["description"]; ok {
		if attr.Expr != nil {
			self.Description = *textValueExprToString(attr.Expr)
		}
	}

	if !found {
		return nil, nil
	}
	return self, nil
}

func (self *Reference) toExpression() (*light.Expression, error) {
	if self.Summary == "" && self.Description == "" {
		arr := strings.Split(self.XRef, "#/")
		if len(arr) != 2 {
			return nil, fmt.Errorf("invalid reference: %s", self.XRef)
		}
		return stringToTraversal(arr[1]), nil
	}

	args := []*light.Expression{
		stringToTextValueExpr(self.XRef),
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
	}, nil
}

func expressionToReference(expr *light.Expression) (*Reference, error) {
	if expr == nil {
		return nil, nil
	}

	reference := &Reference{}
	var found bool
	if x := expr.GetFcexpr(); x != nil {
		if x.Name == "reference" {
			if len(x.Args) < 1 {
				return nil, fmt.Errorf("invalid reference expression: %#v", expr)
			}
			arg := x.Args[0]
			reference.XRef = *textValueExprToString(arg)
			if len(x.Args) > 1 {
				arg = x.Args[1]
				reference.Summary = *textValueExprToString(arg)
			}
			if len(x.Args) > 2 {
				arg = x.Args[2]
				reference.Description = *textValueExprToString(arg)
			}
			found = true
		}
	} else if x := expr.GetLvexpr(); x != nil {
		reference.XRef = "#/" + *traversalToString(expr)
		found = true
	}

	if !found {
		return nil, nil
	}
	return reference, nil
}
