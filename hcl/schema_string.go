package hcl

import (
	"github.com/genelet/hcllight/light"
)

func stringToAttributes(self *SchemaString, attrs map[string]*light.Attribute) error {
	if self == nil || attrs == nil {
		return nil
	}

	if self.MinLength != 0 {
		attrs["minLength"] = &light.Attribute{
			Name: "minLength",
			Expr: int64ToLiteralValueExpr(self.MinLength),
		}
	}
	if self.MaxLength != 0 {
		attrs["maxLength"] = &light.Attribute{
			Name: "maxLength",
			Expr: int64ToLiteralValueExpr(self.MaxLength),
		}
	}
	if self.Pattern != "" {
		attrs["pattern"] = &light.Attribute{
			Name: "pattern",
			Expr: stringToTextValueExpr(self.Pattern),
		}
	}
	return nil
}

func attributesToString(attrs map[string]*light.Attribute) (*SchemaString, error) {
	if attrs == nil {
		return nil, nil
	}

	var found bool
	str := &SchemaString{}
	if v, ok := attrs["minLength"]; ok {
		str.MinLength = *literalValueExprToInt64(v.Expr)
		found = true
	}
	if v, ok := attrs["maxLength"]; ok {
		str.MaxLength = *literalValueExprToInt64(v.Expr)
		found = true
	}
	if v, ok := attrs["pattern"]; ok {
		str.Pattern = *textValueExprToString(v.Expr)
		found = true
	}

	if found {
		return str, nil
	}
	return nil, nil
}

func schemaStringToFcexpr(self *SchemaString, expr *light.FunctionCallExpr) error {
	if self == nil {
		return nil
	}
	if self.MaxLength != 0 {
		expr.Args = append(expr.Args, int64ToLiteralExpr("maxLength", self.MaxLength))
	}
	if self.MinLength != 0 {
		expr.Args = append(expr.Args, int64ToLiteralExpr("minLength", self.MinLength))
	}
	if self.Pattern != "" {
		expr.Args = append(expr.Args, stringToTextExpr("pattern", self.Pattern))
	}
	return nil
}

func fcexprToSchemaString(fcexpr *light.FunctionCallExpr) (*SchemaString, error) {
	s := &SchemaString{}
	found := false
	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "maxLength":
				max, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MaxLength = max
				found = true
			case "minLength":
				min, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MinLength = min
				found = true
			case "pattern":
				pattern, err := exprToTextString(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.Pattern = pattern
				found = true
			default:
			}
		default:
		}
	}
	if found {
		return s, nil
	}
	return nil, nil
}
