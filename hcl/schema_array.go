package hcl

import (
	"github.com/genelet/hcllight/light"
)

func arrayToTupleConsExpr(items []*SchemaOrReference) (*light.TupleConsExpr, error) {
	if items == nil {
		return nil, nil
	}
	var exprs []*light.Expression
	for _, item := range items {
		expr, err := item.toExpression()
		if err != nil {
			return nil, err
		}
		exprs = append(exprs, expr)
	}
	return &light.TupleConsExpr{
		Exprs: exprs,
	}, nil
}

func tupleConsExprToArray(t *light.TupleConsExpr) ([]*SchemaOrReference, error) {
	if t == nil {
		return nil, nil
	}
	exprs := t.Exprs
	if len(exprs) == 0 {
		return nil, nil
	}

	var items []*SchemaOrReference
	for _, expr := range exprs {
		s, err := expressionToSchemaOrReference(expr)
		if err != nil {
			return nil, err
		}
		items = append(items, s)
	}
	return items, nil
}

func itemsToAttributes(items []*SchemaOrReference, name string, attrs map[string]*light.Attribute) error {
	if len(items) == 0 {
		return nil
	}

	expr, err := arrayToTupleConsExpr(items)
	if err != nil {
		return err
	}
	attrs[name] = &light.Attribute{
		Name: name,
		Expr: &light.Expression{
			ExpressionClause: &light.Expression_Tcexpr{
				Tcexpr: expr,
			},
		},
	}
	return nil
}

func attributesToItems(attrs map[string]*light.Attribute, name string) ([]*SchemaOrReference, error) {
	if attrs == nil {
		return nil, nil
	}
	if v, ok := attrs[name]; ok {
		return tupleConsExprToArray(v.Expr.GetTcexpr())
	}
	return nil, nil
}

func oneOfToAttributes(self *SchemaOneOf, attrs map[string]*light.Attribute) error {
	if self == nil {
		return nil
	}
	return itemsToAttributes(self.Items, "oneOf", attrs)
}

func attributesToOneOf(attrs map[string]*light.Attribute) (*SchemaOneOf, error) {
	if items, err := attributesToItems(attrs, "oneOf"); err != nil {
		return nil, err
	} else if items != nil {
		return &SchemaOneOf{
			Items: items,
		}, nil
	}
	return nil, nil
}

func allOfToAttributes(self *SchemaAllOf, attrs map[string]*light.Attribute) error {
	if self == nil {
		return nil
	}
	return itemsToAttributes(self.Items, "allOf", attrs)
}

func attributesToAllOf(attrs map[string]*light.Attribute) (*SchemaAllOf, error) {
	if items, err := attributesToItems(attrs, "allOf"); err != nil {
		return nil, err
	} else if items != nil {
		return &SchemaAllOf{
			Items: items,
		}, nil
	}
	return nil, nil
}

func anyOfToAttributes(self *SchemaAnyOf, attrs map[string]*light.Attribute) error {
	if self == nil {
		return nil
	}
	return itemsToAttributes(self.Items, "anyOf", attrs)
}

func attributesToAnyOf(attrs map[string]*light.Attribute) (*SchemaAnyOf, error) {
	if items, err := attributesToItems(attrs, "anyOf"); err != nil {
		return nil, err
	} else if items != nil {
		return &SchemaAnyOf{
			Items: items,
		}, nil
	}
	return nil, nil
}

func arrayToAttributes(self *SchemaArray, attrs map[string]*light.Attribute) error {
	if self == nil || attrs == nil {
		return nil
	}

	if self.MinItems != 0 {
		attrs["minItems"] = &light.Attribute{
			Name: "minItems",
			Expr: light.Int64ToLiteralValueExpr(self.MinItems),
		}
	}
	if self.MaxItems != 0 {
		attrs["maxItems"] = &light.Attribute{
			Name: "maxItems",
			Expr: light.Int64ToLiteralValueExpr(self.MaxItems),
		}
	}
	if self.UniqueItems {
		attrs["uniqueItems"] = &light.Attribute{
			Name: "uniqueItems",
			Expr: light.BooleanToLiteralValueExpr(self.UniqueItems),
		}
	}

	return itemsToAttributes(self.Items, "items", attrs)
}

func attributesToArray(attrs map[string]*light.Attribute) (*SchemaArray, error) {
	if attrs == nil {
		return nil, nil
	}

	var found bool
	var err error
	array := &SchemaArray{}
	if v, ok := attrs["minItems"]; ok {
		array.MinItems = *light.LiteralValueExprToInt64(v.Expr)
		found = true
	}
	if v, ok := attrs["maxItems"]; ok {
		array.MaxItems = *light.LiteralValueExprToInt64(v.Expr)
		found = true
	}
	if v, ok := attrs["uniqueItems"]; ok {
		array.UniqueItems = *light.LiteralValueExprToBoolean(v.Expr)
		found = true
	}

	if array.Items, err = attributesToItems(attrs, "items"); err != nil {
		return nil, err
	} else if array.Items != nil {
		found = true
	}

	if found {
		return array, nil
	}
	return nil, nil
}

func schemaArrayToFcexpr(self *SchemaArray, expr *light.FunctionCallExpr) error {
	if self == nil {
		return nil
	}

	if self.MaxItems != 0 {
		expr.Args = append(expr.Args, in64ToLiteralFcexpr("maxItems", self.MaxItems))
	}
	if self.MinItems != 0 {
		expr.Args = append(expr.Args, in64ToLiteralFcexpr("minItems", self.MinItems))
	}
	if self.UniqueItems {
		expr.Args = append(expr.Args, booleanToLiteralFcexpr("uniqueItems", self.UniqueItems))
	}
	if self.Items != nil && len(self.Items) > 0 {
		e, err := arrayToTupleConsExpr(self.Items)
		if err != nil {
			return err
		}
		ex := &light.Expression{
			ExpressionClause: &light.Expression_Tcexpr{
				Tcexpr: e,
			},
		}
		expr.Args = append(expr.Args, ex)
	}
	return nil
}

func fcexprToSchemaArray(fcexpr *light.FunctionCallExpr) (*SchemaArray, error) {
	if fcexpr == nil {
		return nil, nil
	}

	s := &SchemaArray{}
	var found bool
	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "maxItems":
				s.MaxItems = *light.LiteralValueExprToInt64(expr.Args[0])
				found = true
			case "minItems":
				s.MinItems = *light.LiteralValueExprToInt64(expr.Args[0])
				found = true
			case "uniqueItems":
				s.UniqueItems = *light.LiteralValueExprToBoolean(expr.Args[0])
				found = true
			default:
			}
		case *light.Expression_Tcexpr:
			items, err := tupleConsExprToArray(arg.GetTcexpr())
			if err != nil {
				return nil, err
			}
			s.Items = items
			found = true
		default:
		}
	}

	if !found {
		return nil, nil
	}
	return s, nil
}
