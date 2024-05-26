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
			Expr: light.Float64ToLiteralValueExpr(self.Minimum),
		}
	}
	if self.Maximum != 0 {
		attrs["maximum"] = &light.Attribute{
			Name: "maximum",
			Expr: light.Float64ToLiteralValueExpr(self.Maximum),
		}
	}
	if self.ExclusiveMinimum {
		attrs["exclusiveMinimum"] = &light.Attribute{
			Name: "exclusiveMinimum",
			Expr: light.BooleanToLiteralValueExpr(self.ExclusiveMinimum),
		}
	}
	if self.ExclusiveMaximum {
		attrs["exclusiveMaximum"] = &light.Attribute{
			Name: "exclusiveMaximum",
			Expr: light.BooleanToLiteralValueExpr(self.ExclusiveMaximum),
		}
	}
	if self.MultipleOf != 0 {
		attrs["multipleOf"] = &light.Attribute{
			Name: "multipleOf",
			Expr: light.Float64ToLiteralValueExpr(self.MultipleOf),
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
		number.Minimum = *light.LiteralValueExprToFloat64(v.Expr)
		found = true
	}
	if v, ok := attrs["maximum"]; ok {
		number.Maximum = *light.LiteralValueExprToFloat64(v.Expr)
		found = true
	}
	if v, ok := attrs["exclusiveMinimum"]; ok {
		number.ExclusiveMinimum = *light.LiteralValueExprToBoolean(v.Expr)
		found = true
	}
	if v, ok := attrs["exclusiveMaximum"]; ok {
		number.ExclusiveMaximum = *light.LiteralValueExprToBoolean(v.Expr)
		found = true
	}
	if v, ok := attrs["multipleOf"]; ok {
		number.MultipleOf = *light.LiteralValueExprToFloat64(v.Expr)
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
				s.Minimum = *light.LiteralValueExprToFloat64(expr.Args[0])
				found = true
			case "maximum":
				s.Maximum = *light.LiteralValueExprToFloat64(expr.Args[0])
				found = true
			case "exclusiveMinimum":
				s.ExclusiveMinimum = *light.LiteralValueExprToBoolean(expr.Args[0])
				found = true
			case "exclusiveMaximum":
				s.ExclusiveMaximum = *light.LiteralValueExprToBoolean(expr.Args[0])
				found = true
			case "multipleOf":
				s.MultipleOf = *light.LiteralValueExprToFloat64(expr.Args[0])
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
