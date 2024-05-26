package hcl

import (
	"github.com/genelet/hcllight/light"
)

func numberToAttributes(self *SchemaNumber, attrs map[string]*light.Attribute) error {
	if self == nil || attrs == nil {
		return nil
	}

	if self.Minimum != 0 {
		attrs["minimum"] = &light.Attribute{
			Name: "minimum",
			Expr: float64ToLiteralValueExpr(self.Minimum),
		}
	}
	if self.Maximum != 0 {
		attrs["maximum"] = &light.Attribute{
			Name: "maximum",
			Expr: float64ToLiteralValueExpr(self.Maximum),
		}
	}
	if self.ExclusiveMinimum {
		attrs["exclusiveMinimum"] = &light.Attribute{
			Name: "exclusiveMinimum",
			Expr: booleanToLiteralValueExpr(self.ExclusiveMinimum),
		}
	}
	if self.ExclusiveMaximum {
		attrs["exclusiveMaximum"] = &light.Attribute{
			Name: "exclusiveMaximum",
			Expr: booleanToLiteralValueExpr(self.ExclusiveMaximum),
		}
	}
	if self.MultipleOf != 0 {
		attrs["multipleOf"] = &light.Attribute{
			Name: "multipleOf",
			Expr: float64ToLiteralValueExpr(self.MultipleOf),
		}
	}
	return nil
}

func attributesToNumber(attrs map[string]*light.Attribute) (*SchemaNumber, error) {
	if attrs == nil {
		return nil, nil
	}

	var found bool
	number := &SchemaNumber{}
	if v, ok := attrs["minimum"]; ok {
		number.Minimum = *literalValueExprToFloat64(v.Expr)
		found = true
	}
	if v, ok := attrs["maximum"]; ok {
		number.Maximum = *literalValueExprToFloat64(v.Expr)
		found = true
	}
	if v, ok := attrs["exclusiveMinimum"]; ok {
		number.ExclusiveMinimum = *literalValueExprToBoolean(v.Expr)
		found = true
	}
	if v, ok := attrs["exclusiveMaximum"]; ok {
		number.ExclusiveMaximum = *literalValueExprToBoolean(v.Expr)
		found = true
	}
	if v, ok := attrs["multipleOf"]; ok {
		number.MultipleOf = *literalValueExprToFloat64(v.Expr)
		found = true
	}

	if found {
		return number, nil
	}
	return nil, nil
}

// because of order in function, we can't loop attribute map
func schemaNumberToFcexpr(self *SchemaNumber, expr *light.FunctionCallExpr) error {
	if self == nil {
		return nil
	}
	if self.Minimum != 0 {
		expr.Args = append(expr.Args, float64ToLiteralFcexpr("minimum", self.Minimum))
	}
	if self.Maximum != 0 {
		expr.Args = append(expr.Args, float64ToLiteralFcexpr("maximum", self.Maximum))
	}
	if self.ExclusiveMinimum {
		expr.Args = append(expr.Args, booleanToLiteralFcexpr("exclusiveMinimum", self.ExclusiveMinimum))
	}
	if self.ExclusiveMaximum {
		expr.Args = append(expr.Args, booleanToLiteralFcexpr("exclusiveMaximum", self.ExclusiveMaximum))
	}
	if self.MultipleOf != 0 {
		expr.Args = append(expr.Args, float64ToLiteralFcexpr("multipoleOf", self.MultipleOf))
	}

	return nil
}

func fcexprToSchemaNumber(fcexpr *light.FunctionCallExpr) (*SchemaNumber, error) {
	if fcexpr == nil {
		return nil, nil
	}

	s := &SchemaNumber{}
	found := false
	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "minimum":
				s.Minimum = *literalValueExprToFloat64(expr.Args[0])
				found = true
			case "maximum":
				s.Maximum = *literalValueExprToFloat64(expr.Args[0])
				found = true
			case "exclusiveMinimum":
				s.ExclusiveMinimum = *literalValueExprToBoolean(expr.Args[0])
				found = true
			case "exclusiveMaximum":
				s.ExclusiveMaximum = *literalValueExprToBoolean(expr.Args[0])
				found = true
			case "multipleOf":
				s.MultipleOf = *literalValueExprToFloat64(expr.Args[0])
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
