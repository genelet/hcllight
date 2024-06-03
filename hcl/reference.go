package hcl

import (
	"fmt"
	"strings"

	"github.com/genelet/hcllight/light"
)

func (self *Reference) toAddressArray() ([]string, error) {
	arr := strings.Split(self.XRef, "#/")
	if len(arr) != 2 {
		return nil, fmt.Errorf("invalid reference: %s", self.XRef)
	}
	return strings.Split(arr[1], "/"), nil
}

// reference
func (self *Reference) toHCL() (*light.Body, error) {
	body := &light.Body{
		Attributes: map[string]*light.Attribute{
			"XRef": {
				Name: "XRef",
				Expr: light.StringToTextValueExpr(self.XRef),
			},
		},
	}
	if self.Summary != "" {
		body.Attributes["summary"] = &light.Attribute{
			Name: "summary",
			Expr: light.StringToTextValueExpr(self.Summary),
		}
	}
	if self.Description != "" {
		body.Attributes["description"] = &light.Attribute{
			Name: "description",
			Expr: light.StringToTextValueExpr(self.Description),
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
			self.XRef = *light.TextValueExprToString(attr.Expr)
			found = true
		}
	}
	if attr, ok := body.Attributes["summary"]; ok {
		if attr.Expr != nil {
			self.Summary = *light.TextValueExprToString(attr.Expr)
		}
	}
	if attr, ok := body.Attributes["description"]; ok {
		if attr.Expr != nil {
			self.Description = *light.TextValueExprToString(attr.Expr)
		}
	}

	if !found {
		return nil, nil
	}
	return self, nil
}

func xrefToTraversal(xref string) (*light.Expression, error) {
	arr := strings.Split(xref, "#/")
	if len(arr) != 2 {
		return nil, fmt.Errorf("invalid reference: %s", xref)
	}
	return light.StringToTraversal(arr[1]), nil
}

func traversalToXref(expr *light.Expression) (string, error) {
	if expr == nil {
		return "", nil
	}
	return "#/" + *light.TraversalToString(expr), nil
}

func (self *Reference) toExpression() (*light.Expression, error) {
	if self.Summary == "" && self.Description == "" {
		return xrefToTraversal(self.XRef)
	}

	args := []*light.Expression{
		light.StringToTextValueExpr(self.XRef),
	}
	if self.Summary != "" {
		args = append(args, light.StringToTextValueExpr(self.Summary))
	}
	if self.Description != "" {
		args = append(args, light.StringToTextValueExpr(self.Description))
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
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Stexpr:
		str, err := traversalToXref(expr)
		if err != nil {
			return nil, err
		}
		reference.XRef = str
		return reference, nil
	case *light.Expression_Fcexpr:
		x := expr.GetFcexpr()
		if x.Name == "reference" {
			if len(x.Args) < 1 {
				return nil, fmt.Errorf("invalid reference expression: %#v", expr)
			}
			arg := x.Args[0]
			reference.XRef = *light.TextValueExprToString(arg)
			if len(x.Args) > 1 {
				arg = x.Args[1]
				reference.Summary = *light.TextValueExprToString(arg)
			}
			if len(x.Args) > 2 {
				arg = x.Args[2]
				reference.Description = *light.TextValueExprToString(arg)
			}
			return reference, nil
		}
	case *light.Expression_Ocexpr:
		x := expr.GetOcexpr()
		return referenceFromHCL(x.ToBody())
	default:
	}

	return nil, nil
}
