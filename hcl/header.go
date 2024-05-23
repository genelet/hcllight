package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *HeaderOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *HeaderOrReference_Header:
		return self.GetHeader().toHCL()
	case *HeaderOrReference_Reference:
		return self.GetReference().toHCL()
	default:
	}
	return nil, nil
}

func headerOrReferenceFromHCL(body *light.Body) (*HeaderOrReference, error) {
	if body == nil {
		return nil, nil
	}

	reference, err := referenceFromHCL(body)
	if err != nil {
		return nil, err
	}
	if reference != nil {
		return &HeaderOrReference{
			Oneof: &HeaderOrReference_Reference{
				Reference: reference,
			},
		}, nil
	}

	header, err := headerFromHCL(body)
	if err != nil {
		return nil, err
	}
	if header == nil {
		return nil, nil
	}
	return &HeaderOrReference{
		Oneof: &HeaderOrReference_Header{
			Header: header,
		},
	}, nil
}

func (self *Header) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"required":        self.Required,
		"deprecated":      self.Deprecated,
		"allowEmptyValue": self.AllowEmptyValue,
		"explode":         self.Explode,
		"allowReserved":   self.AllowReserved,
	}
	mapStrings := map[string]string{
		"description": self.Description,
		"style":       self.Style,
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
		expr, err := self.Example.toExpression()
		if err != nil {
			return nil, err
		}
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: expr,
		}
	}
	if self.Examples != nil {
		blk, err := exampleOrReferenceMapToBlocks(self.Examples)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk...)
	}
	if err := addSpecificationBlock(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
	}
	if self.Schema != nil {
		expr, err := self.Schema.toExpression()
		if err != nil {
			return nil, err
		}
		attrs["schema"] = &light.Attribute{
			Name: "schema",
			Expr: expr,
		}
	}
	if self.Content != nil {
		blks, err := mediaTypeMapToBlocks(self.Content)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func headerFromHCL(body *light.Body) (*Header, error) {
	if body == nil {
		return nil, nil
	}

	self := new(Header)
	var found bool
	var err error
	for k, v := range body.Attributes {
		switch k {
		case "required":
			self.Required = *literalValueExprToBoolean(v.Expr)
			found = true
		case "deprecated":
			self.Deprecated = *literalValueExprToBoolean(v.Expr)
			found = true
		case "allowEmptyValue":
			self.AllowEmptyValue = *literalValueExprToBoolean(v.Expr)
			found = true
		case "explode":
			self.Explode = *literalValueExprToBoolean(v.Expr)
			found = true
		case "allowReserved":
			self.AllowReserved = *literalValueExprToBoolean(v.Expr)
			found = true
		case "description":
			self.Description = *literalValueExprToString(v.Expr)
			found = true
		case "style":
			self.Style = *literalValueExprToString(v.Expr)
			found = true
		case "example":
			self.Example, err = anyFromHCL(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		case "schema":
			self.Schema, err = ExpressionToSchemaOrReference(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		default:
		}
	}
	for _, block := range body.Blocks {
		switch block.Type {
		case "examples":
			self.Examples, err = blocksToExampleOrReferenceMap(block.Bdy.Blocks)
			if err != nil {
				return nil, err
			}
			found = true
		case "content":
			self.Content, err = blocksToMediaTypeMap(block.Bdy.Blocks)
			if err != nil {
				return nil, err
			}
			found = true
		case "specification":
			self.SpecificationExtension, err = bodyToAnyMap(block.Bdy)
			if err != nil {
				return nil, err
			}
			found = true
		default:
		}
	}
	if found {
		return self, nil
	}
	return nil, nil
}

func headerOrReferenceMapToBlocks(headers map[string]*HeaderOrReference) ([]*light.Block, error) {
	if headers == nil {
		return nil, nil
	}

	hash := make(map[string]OrHCL)
	for k, v := range headers {
		hash[k] = v
	}
	return orMapToBlocks(hash, "headers")
}

func blocksToHeaderOrReferenceMap(blocks []*light.Block) (map[string]*HeaderOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, "headers", func(reference *Reference) OrHCL {
		return &HeaderOrReference{
			Oneof: &HeaderOrReference_Reference{
				Reference: reference,
			},
		}
	}, func(body *light.Body) (OrHCL, error) {
		header, err := headerFromHCL(body)
		if err != nil {
			return nil, err
		}
		if header != nil {
			return &HeaderOrReference{
				Oneof: &HeaderOrReference_Header{
					Header: header,
				},
			}, nil
		}
		return nil, nil
	})
	if err != nil {
		return nil, err
	}

	if orMap == nil {
		return nil, nil
	}

	hash := make(map[string]*HeaderOrReference)
	for k, v := range orMap {
		hash[k] = v.(*HeaderOrReference)
	}

	return hash, nil
}
