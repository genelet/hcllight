package jsm

import (
	"github.com/genelet/hcllight/light"
)

func (self *Common) toAttributes(attrs map[string]*light.Attribute) error {
	if self.Type != nil {
		if self.Type.String != nil {
			attrs["type"] = &light.Attribute{
				Name: "type",
				Expr: stringToTextValueExpr(*self.Type.String),
			}
		} else {
			attrs["type"] = &light.Attribute{
				Name: "type",
				Expr: stringsToTupleConsExpr(*self.Type.StringArray),
			}
		}
	}
	if self.Format != nil {
		attrs["format"] = &light.Attribute{
			Name: "format",
			Expr: stringToTextValueExpr(*self.Format),
		}
	}
	if self.Default != nil {
		attrs["default"] = &light.Attribute{
			Name: "default",
			Expr: stringToLiteralValueExpr(self.Default.Value),
		}
	}
	if self.Enumeration != nil {
		expr, err := enumToTupleConsExpr(self.Enumeration)
		if err != nil {
			return err
		}
		attrs["enum"] = &light.Attribute{
			Name: "enum",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: expr,
				},
			},
		}
	}
	return nil
}

func (self *SchemaNumber) toAttributes(attrs map[string]*light.Attribute) error {
	if self.Minimum != nil {
		attrs["minimum"] = &light.Attribute{
			Name: "minimum",
			Expr: doubleToLiteralValueExpr(*self.Minimum.Float),
		}
	}
	if self.Maximum != nil {
		attrs["maximum"] = &light.Attribute{
			Name: "maximum",
			Expr: doubleToLiteralValueExpr(*self.Maximum.Float),
		}
	}
	if self.ExclusiveMinimum != nil {
		attrs["exclusiveMinimum"] = &light.Attribute{
			Name: "exclusiveMinimum",
			Expr: booleanToLiteralValueExpr(*self.ExclusiveMinimum),
		}
	}
	if self.ExclusiveMaximum != nil {
		attrs["exclusiveMaximum"] = &light.Attribute{
			Name: "exclusiveMaximum",
			Expr: booleanToLiteralValueExpr(*self.ExclusiveMaximum),
		}
	}
	if self.MultipleOf != nil {
		attrs["multipleOf"] = &light.Attribute{
			Name: "multipleOf",
			Expr: doubleToLiteralValueExpr(*self.MultipleOf.Float),
		}
	}
	return nil
}

func (self *SchemaString) toAttributes(attrs map[string]*light.Attribute) error {
	if self.MaxLength != nil {
		attrs["maxLength"] = &light.Attribute{
			Name: "maxLength",
			Expr: int64ToLiteralValueExpr(*self.MaxLength),
		}
	}
	if self.MinLength != nil {
		attrs["minLength"] = &light.Attribute{
			Name: "minLength",
			Expr: int64ToLiteralValueExpr(*self.MinLength),
		}
	}
	if self.Pattern != nil {
		attrs["pattern"] = &light.Attribute{
			Name: "pattern",
			Expr: stringToTextValueExpr(*self.Pattern),
		}
	}
	return nil
}

func (self *SchemaArray) toAttributes(attrs map[string]*light.Attribute) error {
	if self.MaxItems != nil {
		attrs["maxItems"] = &light.Attribute{
			Name: "maxItems",
			Expr: int64ToLiteralValueExpr(*self.MaxItems),
		}
	}
	if self.MinItems != nil {
		attrs["minItems"] = &light.Attribute{
			Name: "minItems",
			Expr: int64ToLiteralValueExpr(*self.MinItems),
		}
	}
	if self.UniqueItems != nil {
		attrs["uniqueItems"] = &light.Attribute{
			Name: "uniqueItems",
			Expr: booleanToLiteralValueExpr(*self.UniqueItems),
		}
	}
	if self.Items != nil {
		expr, err := itemsToExpression(self.Items)
		if err != nil {
			return err
		}
		attrs["items"] = &light.Attribute{
			Name: "items",
			Expr: expr,
		}
	}
	return nil
}

func (self *SchemaObject) toAttributesBlocks(attrs map[string]*light.Attribute, blocks *[]*light.Block) error {
	if self.MaxProperties != nil {
		attrs["maxProperties"] = &light.Attribute{
			Name: "maxProperties",
			Expr: int64ToLiteralValueExpr(*self.MaxProperties),
		}
	}
	if self.MinProperties != nil {
		attrs["minProperties"] = &light.Attribute{
			Name: "minProperties",
			Expr: int64ToLiteralValueExpr(*self.MinProperties),
		}
	}
	if self.Required != nil {
		attrs["required"] = &light.Attribute{
			Name: "required",
			Expr: stringsToTupleConsExpr(self.Required),
		}
	}
	if self.Properties != nil {
		bdy, err := mapToBody(self.Properties)
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

func (self *SchemaMap) toAttributes(attrs map[string]*light.Attribute) error {
	if self.AdditionalProperties.Schema != nil {
		expr, err := self.AdditionalProperties.Schema.toExpression()
		if err != nil {
			return err
		}
		attrs["additionalProperties"] = &light.Attribute{
			Name: "additionalProperties",
			Expr: expr,
		}
	} else {
		attrs["additionalProperties"] = &light.Attribute{
			Name: "additionalProperties",
			Expr: booleanToLiteralValueExpr(*self.AdditionalProperties.Boolean),
		}
	}

	return nil
}

func (self *SchemaFull) toBody() (*light.Body, error) {
	body := &light.Body{}
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)

	if self.Ref != nil {
		if ex, err := referenceToExpression(*self.Ref); err != nil {
			attrs["$ref"] = &light.Attribute{
				Name: "$ref",
				Expr: ex,
			}
		}
	}
	if self.Common != nil {
		if err := self.Common.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.SchemaNumber != nil {
		if err := self.SchemaNumber.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.SchemaString != nil {
		if err := self.SchemaString.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.SchemaArray != nil {
		if err := self.SchemaArray.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.SchemaObject != nil {
		if err := self.SchemaObject.toAttributesBlocks(attrs, &blocks); err != nil {
			return nil, err
		}
	}
	if self.SchemaMap != nil {
		if err := self.SchemaMap.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.AdditionalItems != nil {
		if self.AdditionalItems.Schema != nil {
			ex, err := self.AdditionalItems.Schema.toExpression()
			if err != nil {
				return nil, err
			}
			attrs["additionalItems"] = &light.Attribute{
				Name: "additionalItems",
				Expr: ex,
			}
		} else {
			attrs["additionalItems"] = &light.Attribute{
				Name: "additionalItems",
				Expr: booleanToLiteralValueExpr(*self.AdditionalItems.Boolean),
			}
		}
	}
	if self.PatternProperties != nil {
		bdy, err := mapToBody(self.PatternProperties)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "patternProperties",
			Bdy:  bdy,
		})
	}
	if self.Definitions != nil {
		bdy, err := mapToBody(self.Definitions)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "definitions",
			Bdy:  bdy,
		})
	}
	if self.Dependencies != nil {
		bdy, err := mapSchemaOrStringArrayToMap(self.Dependencies)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "dependencies",
			Bdy:  bdy,
		})
	}
	if self.AllOf != nil {
		expr, err := sliceToTupleConsExpr(self.AllOf)
		if err != nil {
			return nil, err
		}
		attrs["allOf"] = &light.Attribute{
			Name: "allOf",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: expr,
				},
			},
		}
	}
	if self.OneOf != nil {
		expr, err := sliceToTupleConsExpr(self.OneOf)
		if err != nil {
			return nil, err
		}
		attrs["oneOf"] = &light.Attribute{
			Name: "oneOf",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: expr,
				},
			},
		}
	}
	if self.AnyOf != nil {
		expr, err := sliceToTupleConsExpr(self.AnyOf)
		if err != nil {
			return nil, err
		}
		attrs["anyOf"] = &light.Attribute{
			Name: "anyOf",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: expr,
				},
			},
		}
	}
	if self.Not != nil {
		expr, err := self.Not.toExpression()
		if err != nil {
			return nil, err
		}
		attrs["not"] = &light.Attribute{
			Name: "not",
			Expr: expr,
		}
	}
	if self.Title != nil {
		attrs["title"] = &light.Attribute{
			Name: "title",
			Expr: stringToTextValueExpr(*self.Title),
		}
	}
	if self.Description != nil {
		attrs["description"] = &light.Attribute{
			Name: "description",
			Expr: stringToTextValueExpr(*self.Description),
		}
	}
	if self.Format != nil {
		attrs["format"] = &light.Attribute{
			Name: "format",
			Expr: stringToTextValueExpr(*self.Format),
		}
	}
	if self.Default != nil {
		attrs["default"] = &light.Attribute{
			Name: "default",
			Expr: stringToLiteralValueExpr(self.Default.Value),
		}
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}
