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
		"title":       self.Title,
		"description": self.Description,
	}

	for k, v := range mapBools {
		if v {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: booleanToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}

	if self.Example != nil {
		expr := self.Example.toExpression()
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: expr,
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
	addSpecificationBlock(self.SpecificationExtension, &blocks)

	var err error
	if err = commonToAttributes(self.Common, attrs); err == nil {
		if err = numberToAttributes(self.Number, attrs); err == nil {
			if err = stringToAttributes(self.String_, attrs); err == nil {
				if err = arrayToAttributes(self.Array, attrs); err == nil {
					if err = objectToAttributesBlocks(self.Object, attrs, &blocks); err == nil {
						err = mapToAttributes(self.Map, attrs)
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
	}

	for _, block := range body.Blocks {
		switch block.Type {
		case "discriminator":
			s.Discriminator, err = discriminatorFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
		case "externalDocs":
			s.ExternalDocs, err = externalDocsFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
		case "xml":
			s.Xml, err = xmlFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
		case "specificationExtension":
			s.SpecificationExtension = bodyToAnyMap(block.Bdy)
		default:
		}
	}

	for k, v := range body.Attributes {
		switch k {
		case "not":
			s.Not, err = ExpressionToSchemaOrReference(v.Expr)
			if err != nil {
				return nil, err
			}
		case "example":
			s.Example = anyFromHCL(v.Expr)
		case "nullable":
			s.Nullable = *literalValueExprToBoolean(v.Expr)
		case "readOnly":
			s.ReadOnly = *literalValueExprToBoolean(v.Expr)
		case "writeOnly":
			s.WriteOnly = *literalValueExprToBoolean(v.Expr)
		case "deprecated":
			s.Deprecated = *literalValueExprToBoolean(v.Expr)
		case "title":
			s.Title = *textValueExprToString(v.Expr)
		case "description":
			s.Description = *textValueExprToString(v.Expr)
		default:
		}
	}

	return s, nil
}
