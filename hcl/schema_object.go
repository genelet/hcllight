package hcl

import (
	"github.com/genelet/hcllight/light"
)

func objectToAttributesBlocks(self *SchemaObject, attrs map[string]*light.Attribute, blocks *[]*light.Block) error {
	if self == nil {
		return nil
	}

	if self.MinProperties != 0 {
		attrs["minProperties"] = &light.Attribute{
			Name: "minProperties",
			Expr: int64ToLiteralValueExpr(self.MinProperties),
		}
	}
	if self.MaxProperties != 0 {
		attrs["maxProperties"] = &light.Attribute{
			Name: "maxProperties",
			Expr: int64ToLiteralValueExpr(self.MaxProperties),
		}
	}
	if self.Required != nil {
		expr := stringArrayToTupleConsEpr(self.Required)
		attrs["required"] = &light.Attribute{
			Name: "required",
			Expr: expr,
		}
	}
	if self.Properties != nil {
		bdy, err := mapSchemaOrReferenceToBody(self.Properties)
		if err != nil {
			return err
		}
		*blocks = append(*blocks, &light.Block{
			Type: "properties",
			Bdy:  bdy,
		})
	}
	return nil
}

func attributesBlocksToObject(attrs map[string]*light.Attribute, blocks []*light.Block) (*SchemaObject, error) {
	object := &SchemaObject{}

	var err error
	var found bool

	if v, ok := attrs["minProperties"]; ok {
		object.MinProperties = *literalValueExprToInt64(v.Expr)
		found = true
	}
	if v, ok := attrs["maxProperties"]; ok {
		object.MaxProperties = *literalValueExprToInt64(v.Expr)
		found = true
	}
	if v, ok := attrs["required"]; ok {
		object.Required = tupleConsExprToStringArray(v.Expr)
		found = true
	}

	for _, block := range blocks {
		if block.Type == "properties" {
			object.Properties, err = bodyToMapSchemaOrReference(block.Bdy)
			if err != nil {
				return nil, err
			}
			found = true
		}
	}

	if found {
		return object, nil
	}
	return nil, nil
}

func schemaObjectToFcexpr(self *SchemaObject, expr *light.FunctionCallExpr) error {
	if self == nil {
		return nil
	}

	if self.Properties != nil {
		ex, err := mapSchemaOrReferenceToObjectConsExpr(self.Properties)
		if err != nil {
			return err
		}
		expr.Args = append([]*light.Expression{{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: ex,
			}}}, expr.Args...)
	}

	if self.MaxProperties != 0 {
		expr.Args = append(expr.Args, int64ToLiteralExpr("maxProperties", self.MaxProperties))
	}
	if self.MinProperties != 0 {
		expr.Args = append(expr.Args, int64ToLiteralExpr("minProperties", self.MinProperties))
	}
	if self.Required != nil {
		expr.Args = append(expr.Args, stringArrayToTupleConsEpr(self.Required))
	}
	return nil
}

func fcexprToSchemaObject(fcexpr *light.FunctionCallExpr) (*SchemaObject, error) {
	s := &SchemaObject{}
	found := false

	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Ocexpr:
			expr := arg.GetOcexpr()
			properties, err := objectConsExprToMapSchemaOrReference(expr)
			if err != nil {
				return nil, err
			}
			s.Properties = properties
			found = true
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "maxProperties":
				max, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MaxProperties = max
				found = true
			case "minProperties":
				min, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MinProperties = min
				found = true
			case "required":
				s.Required = tupleConsExprToStringArray(expr.Args[0])
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
