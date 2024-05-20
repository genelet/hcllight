package hcl

import (
	"github.com/genelet/hcllight/light"
)

func schemaOrBooleanToExpression(item *AdditionalPropertiesItem) (*light.Expression, error) {
	if x := item.GetSchemaOrReference(); x != nil {
		return SchemaOrReferenceToExpression(x)
	} else {
		return booleanToLiteralValueExpr(item.GetBoolean()), nil
	}
}

func expressionToSchemaOrBoolean(expr *light.Expression) (*AdditionalPropertiesItem, error) {
	if expr.GetLvexpr() != nil {
		return &AdditionalPropertiesItem{
			Oneof: &AdditionalPropertiesItem_Boolean{
				Boolean: *literalValueExprToBoolean(expr),
			},
		}, nil
	} else {
		s, err := ExpressionToSchemaOrReference(expr)
		if err != nil {
			return nil, err
		}
		return &AdditionalPropertiesItem{
			Oneof: &AdditionalPropertiesItem_SchemaOrReference{
				SchemaOrReference: s,
			},
		}, nil
	}
}

func mapToAttributes(self *SchemaMap, attrs map[string]*light.Attribute) error {
	if self == nil || attrs == nil {
		return nil
	}

	if self.AdditionalProperties != nil {
		expr, err := schemaOrBooleanToExpression(self.AdditionalProperties)
		if err != nil {
			return err
		}
		attrs["additionalProperties"] = &light.Attribute{
			Name: "additionalProperties",
			Expr: expr,
		}
	}

	return nil
}

func attributesToMap(attrs map[string]*light.Attribute) (*SchemaMap, error) {
	if attrs == nil {
		return nil, nil
	}

	var found bool
	var err error
	m := &SchemaMap{}
	if v, ok := attrs["additionalProperties"]; ok {
		m.AdditionalProperties, err = expressionToSchemaOrBoolean(v.Expr)
		found = true
	}

	if found {
		return m, err
	}
	return nil, err
}

func schemaMapToFcexpr(self *SchemaMap, expr *light.FunctionCallExpr) error {
	if self == nil {
		return nil
	}
	if self.AdditionalProperties != nil {
		ex, err := schemaOrBooleanToExpression(self.AdditionalProperties)
		if err != nil {
			return err
		}
		expr.Args = append([]*light.Expression{ex}, expr.Args...)
	}
	return nil
}

func fcexprToSchemaMap(fcexpr *light.FunctionCallExpr) (*SchemaMap, error) {
	s := &SchemaMap{}
	var found bool
	var err error
	for _, arg := range fcexpr.Args {
		s.AdditionalProperties, err = expressionToSchemaOrBoolean(arg)
		found = true
	}

	if found {
		return s, err
	}
	return nil, err
}
