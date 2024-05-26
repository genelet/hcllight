package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Schema) toHCL() (*light.Body, error) {
	if self == nil {
		return nil, nil
	}

	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"nullable":   self.Nullable,
		"readOnly":   self.ReadOnly,
		"writeOnly":  self.WriteOnly,
		"deprecated": self.Deprecated,
	}
	mapStrings := map[string]string{
		"title": self.Title,
	}

	for k, v := range mapBools {
		if v {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: light.BooleanToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: light.StringToTextValueExpr(v),
			}
		}
	}

	if self.Discriminator != nil {
		bdy, err := self.Discriminator.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "discriminator",
			Bdy:  bdy,
		})
	}
	if self.ExternalDocs != nil {
		bdy, err := self.ExternalDocs.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "externalDocs",
			Bdy:  bdy,
		})
	}
	if self.Xml != nil {
		bdy, err := self.Xml.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "xml",
			Bdy:  bdy,
		})
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
	if err := addSpecification(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
	}

	var err error
	if err = commonToAttributes(self.Common, attrs); err == nil {
		if err = numberToAttributes(self.Number, attrs); err == nil {
			if err = stringToAttributes(self.String_, attrs); err == nil {
				if err = arrayToAttributes(self.Array, attrs); err == nil {
					if err = objectToAttributesBlocks(self.Object, attrs, &blocks); err == nil {
						if err = mapToAttributes(self.Map, attrs); err == nil {
							if err = oneOfToAttributes(self.OneOf, attrs); err == nil {
								if err = allOfToAttributes(self.AllOf, attrs); err == nil {
									err = anyOfToAttributes(self.AnyOf, attrs)
								}
							}
						}
					}
				}
			}
		}
	}

	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, err
}

func schemaFullFromHCL(body *light.Body) (*Schema, error) {
	if body == nil {
		return nil, nil
	}

	oneOf, err := attributesToOneOf(body.Attributes)
	if err != nil {
		return nil, err
	}
	allOf, err := attributesToAllOf(body.Attributes)
	if err != nil {
		return nil, err
	}
	anyOf, err := attributesToAnyOf(body.Attributes)
	if err != nil {
		return nil, err
	}
	common, err := attributesToCommon(body.Attributes)
	if err != nil {
		return nil, err
	}
	number, err := attributesToNumber(body.Attributes)
	if err != nil {
		return nil, err
	}
	str, err := attributesToString(body.Attributes)
	if err != nil {
		return nil, err
	}
	arr, err := attributesToArray(body.Attributes)
	if err != nil {
		return nil, err
	}
	obj, err := attributesBlocksToObject(body.Attributes, body.Blocks)
	if err != nil {
		return nil, err
	}
	m, err := attributesToMap(body.Attributes)
	if err != nil {
		return nil, err
	}

	s := &Schema{
		Common:  common,
		Number:  number,
		String_: str,
		Array:   arr,
		Object:  obj,
		Map:     m,
		OneOf:   oneOf,
		AllOf:   allOf,
		AnyOf:   anyOf,
	}

	for _, block := range body.Blocks {
		switch block.Type {
		case "discriminator":
			s.Discriminator, err = discriminatorFromHCL(block.Bdy)
		case "externalDocs":
			s.ExternalDocs, err = externalDocsFromHCL(block.Bdy)
		case "xml":
			s.Xml, err = xmlFromHCL(block.Bdy)
		case "specificationExtension":
			s.SpecificationExtension, err = bodyToAnyMap(block.Bdy)
		default:
		}
		if err != nil {
			return nil, err
		}
	}

	for k, v := range body.Attributes {
		switch k {
		case "not":
			s.Not, err = expressionToSchemaOrReference(v.Expr)
			if err != nil {
				return nil, err
			}
		case "nullable":
			s.Nullable = *light.LiteralValueExprToBoolean(v.Expr)
		case "readOnly":
			s.ReadOnly = *light.LiteralValueExprToBoolean(v.Expr)
		case "writeOnly":
			s.WriteOnly = *light.LiteralValueExprToBoolean(v.Expr)
		case "deprecated":
			s.Deprecated = *light.LiteralValueExprToBoolean(v.Expr)
		case "title":
			s.Title = *light.TextValueExprToString(v.Expr)
		default:
		}
	}

	return s, nil
}
