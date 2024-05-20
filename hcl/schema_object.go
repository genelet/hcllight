package hcl

import (
	"github.com/genelet/hcllight/light"
)

// use mapSchemaOrReferenceToBody instead
func mapSchemaOrReferenceToObjectConsExpr(m map[string]*SchemaOrReference) (*light.ObjectConsExpr, error) {
	if m == nil {
		return nil, nil
	}
	var exprs []*light.ObjectConsItem
	for k, v := range m {
		expr, err := SchemaOrReferenceToExpression(v)
		if err != nil {
			return nil, err
		}
		exprs = append(exprs, &light.ObjectConsItem{
			KeyExpr:   stringToLiteralValueExpr(k),
			ValueExpr: expr,
		})
	}
	return &light.ObjectConsExpr{
		Items: exprs,
	}, nil
}

func objectConsExprToMapSchemaOrReference(o *light.ObjectConsExpr) (map[string]*SchemaOrReference, error) {
	if o == nil {
		return nil, nil
	}
	m := make(map[string]*SchemaOrReference)
	for _, item := range o.Items {
		key := *literalValueExprToString(item.KeyExpr)
		value, err := ExpressionToSchemaOrReference(item.ValueExpr)
		if err != nil {
			return nil, err
		}
		m[key] = value
	}
	return m, nil
}

func mapSchemaOrReferenceToBody(m map[string]*SchemaOrReference) (*light.Body, error) {
	if m == nil {
		return nil, nil
	}

	var body *light.Body
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)

	for k, v := range m {
		switch v.Oneof.(type) {
		case *SchemaOrReference_Schema:
			bdy, err := v.GetSchema().toHCL()
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type: k,
				Bdy:  bdy,
			})
		default:
			expr, err := SchemaOrReferenceToExpression(v)
			if err != nil {
				return nil, err
			}
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: expr,
			}
		}
	}

	if len(attrs) > 0 || len(blocks) > 0 {
		body = &light.Body{}
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func bodyToMapSchemaOrReference(b *light.Body) (map[string]*SchemaOrReference, error) {
	if b == nil {
		return nil, nil
	}

	m := make(map[string]*SchemaOrReference)
	for k, v := range b.Attributes {
		value, err := ExpressionToSchemaOrReference(v.Expr)
		if err != nil {
			return nil, err
		}
		m[k] = value
	}

	for _, block := range b.Blocks {
		s, err := schemaFullFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		m[block.Type] = &SchemaOrReference{
			Oneof: &SchemaOrReference_Schema{
				Schema: s,
			},
		}
	}
	return m, nil
}

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
