package hcl

import (
	"fmt"

	"github.com/genelet/hcllight/light"
)

func (self *SchemaObject) ToBody() (*light.Body, error) {
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	err := objectToAttributesBlocks(self, attrs, &blocks)
	if err != nil {
		return nil, err
	}

	body := &light.Body{}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func (self *SchemaObject) MarshalHCL() ([]byte, error) {
	body, err := self.ToBody()
	if err != nil {
		return nil, err
	}

	return body.MarshalHCL()
}

func (self *SchemaObject) UnmarshalHCL(bs []byte, labels ...string) error {
	if bs == nil {
		return nil
	}

	body, err := light.ParseBody(bs)
	if err != nil {
		return err
	}
	if body == nil {
		return fmt.Errorf("failsed ParseBody: body is nil")
	}

	attrs := body.Attributes
	blocks := body.Blocks

	object, err := attributesBlocksToObject(attrs, blocks)
	if err != nil {
		return err
	}
	if object == nil {
		return fmt.Errorf("failed attributesBlocksToObject: object is nil")
	}

	self.MaxProperties = object.MaxProperties
	self.MinProperties = object.MinProperties
	self.Required = object.Required
	self.Properties = object.Properties

	return nil
}

func objectToAttributesBlocks(self *SchemaObject, attrs map[string]*light.Attribute, blocks *[]*light.Block) error {
	if self == nil {
		return nil
	}

	if self.MinProperties != 0 {
		attrs["minProperties"] = &light.Attribute{
			Name: "minProperties",
			Expr: light.Int64ToLiteralValueExpr(self.MinProperties),
		}
	}
	if self.MaxProperties != 0 {
		attrs["maxProperties"] = &light.Attribute{
			Name: "maxProperties",
			Expr: light.Int64ToLiteralValueExpr(self.MaxProperties),
		}
	}
	if self.Required != nil {
		expr := light.StringArrayToTupleConsEpr(self.Required)
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

func Body2SchemaObject(body *light.Body) (*SchemaObject, error) {
	return attributesBlocksToObject(body.Attributes, body.Blocks)
}

func attributesBlocksToObject(attrs map[string]*light.Attribute, blocks []*light.Block) (*SchemaObject, error) {
	object := &SchemaObject{}

	var err error
	var found bool

	if v, ok := attrs["minProperties"]; ok {
		object.MinProperties = *light.LiteralValueExprToInt64(v.Expr)
		found = true
	}
	if v, ok := attrs["maxProperties"]; ok {
		object.MaxProperties = *light.LiteralValueExprToInt64(v.Expr)
		found = true
	}
	if v, ok := attrs["required"]; ok {
		object.Required = light.TupleConsExprToStringArray(v.Expr)
		found = true
	}

	for _, block := range blocks {
		if block.Type == "properties" {
			object.Properties, err = BodyToSchemaOrReferenceMap(block.Bdy)
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
		tcexpr := light.StringArrayToTupleConsEpr(self.Required)
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
				s.MaxProperties = *light.LiteralValueExprToInt64(expr.Args[0])
				found = true
			case "minProperties":
				s.MinProperties = *light.LiteralValueExprToInt64(expr.Args[0])
				found = true
			case "required":
				s.Required = light.TupleConsExprToStringArray(&light.Expression{
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
