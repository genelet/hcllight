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
		// true to indicate that we are in the object Equal Sign context
		bdy, err := schemaOrReferenceMapToBody(self.Properties, true)
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
			object.Properties, err = bodyToSchemaOrReferenceMap(block.Bdy)
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

	if self.MaxProperties != 0 {
		expr.Args = append(expr.Args, in64ToLiteralFcexpr("maxProperties", self.MaxProperties))
	}
	if self.MinProperties != 0 {
		expr.Args = append(expr.Args, in64ToLiteralFcexpr("minProperties", self.MinProperties))
	}
	if self.Required != nil {
		tcexpr := stringArrayToTupleConsEpr(self.Required)
		expr.Args = append(expr.Args, shortToFcexpr("required", tcexpr))
	}
	if self.Properties != nil {
		ex, err := mapSchemaOrReferenceToObjectConsExpr(self.Properties)
		if err != nil {
			return err
		}
		expr.Args = append(expr.Args, &light.Expression{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: ex,
			},
		})
	}
	return nil
}

func fcexprToSchemaObject(fcexpr *light.FunctionCallExpr) (*SchemaObject, error) {
	if fcexpr == nil {
		return nil, nil
	}

	s := &SchemaObject{}
	found := false

	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "maxProperties":
				s.MaxProperties = *literalValueExprToInt64(expr.Args[0])
				found = true
			case "minProperties":
				s.MinProperties = *literalValueExprToInt64(expr.Args[0])
				found = true
			case "required":
				s.Required = tupleConsExprToStringArray(&light.Expression{
					ExpressionClause: &light.Expression_Tcexpr{
						Tcexpr: &light.TupleConsExpr{
							Exprs: expr.Args,
						},
					},
				})
				found = true
			default:
			}
		case *light.Expression_Ocexpr:
			expr := arg.GetOcexpr()
			properties, err := objectConsExprToMapSchemaOrReference(expr)
			if err != nil {
				return nil, err
			}
			s.Properties = properties
			found = true
		default:
		}
	}

	if !found {
		return nil, nil
	}
	return s, nil
}
