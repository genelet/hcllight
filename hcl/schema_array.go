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
		expr, err := SchemaOrReferenceToExpression(item)
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
		s, err := ExpressionToSchemaOrReference(expr)
		if err != nil {
			return nil, err
		}
		items = append(items, s)
	}
	return items, nil
}

func arrayToAttributes(self *SchemaArray, attrs map[string]*light.Attribute) error {
	if self == nil || attrs == nil {
		return nil
	}

	if self.MinItems != 0 {
		attrs["minItems"] = &light.Attribute{
			Name: "minItems",
			Expr: int64ToLiteralValueExpr(self.MinItems),
		}
	}
	if self.MaxItems != 0 {
		attrs["maxItems"] = &light.Attribute{
			Name: "maxItems",
			Expr: int64ToLiteralValueExpr(self.MaxItems),
		}
	}
	if self.UniqueItems {
		attrs["uniqueItems"] = &light.Attribute{
			Name: "uniqueItems",
			Expr: booleanToLiteralValueExpr(self.UniqueItems),
		}
	}
	if self.Items != nil {
		expr, err := arrayToTupleConsExpr(self.Items)
		if err != nil {
			return err
		}
		attrs["items"] = &light.Attribute{
			Name: "items",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: expr,
				},
			},
		}
	}
	return nil
}

func attributesToArray(attrs map[string]*light.Attribute) (*SchemaArray, error) {
	if attrs == nil {
		return nil, nil
	}

	var found bool
	array := &SchemaArray{}
	if v, ok := attrs["minItems"]; ok {
		array.MinItems = *literalValueExprToInt64(v.Expr)
		found = true
	}
	if v, ok := attrs["maxItems"]; ok {
		array.MaxItems = *literalValueExprToInt64(v.Expr)
		found = true
	}
	if v, ok := attrs["uniqueItems"]; ok {
		array.UniqueItems = *literalValueExprToBoolean(v.Expr)
		found = true
	}
	if v, ok := attrs["items"]; ok {
		items, err := tupleConsExprToArray(v.Expr.GetTcexpr())
		if err != nil {
			return nil, err
		}
		array.Items = items
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
		expr.Args = append([]*light.Expression{ex}, expr.Args...)
	}

	if self.MaxItems != 0 {
		expr.Args = append(expr.Args, int64ToLiteralExpr("maxItems", self.MaxItems))
	}
	if self.MinItems != 0 {
		expr.Args = append(expr.Args, int64ToLiteralExpr("minItems", self.MinItems))
	}
	if self.UniqueItems {
		expr.Args = append(expr.Args, booleanToLiteralExpr("uniqueItems", self.UniqueItems))
	}
	return nil
}

func fcexprToSchemaArray(fcexpr *light.FunctionCallExpr) (*SchemaArray, error) {
	s := &SchemaArray{}
	var found bool

	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "maxItems":
				max, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MaxItems = max
				found = true
			case "minItems":
				min, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MinItems = min
				found = true
			case "uniqueItems":
				unique, err := exprToBoolean(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.UniqueItems = unique
				found = true
			default:
			}
		default:
			items, err := tupleConsExprToArray(arg.GetTcexpr())
			if err != nil {
				return nil, err
			}
			s.Items = items
			found = true
		}
	}
	if found {
		return s, nil
	}
	return nil, nil
}
