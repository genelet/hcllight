package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *HeaderOrReference) getAble() ableHCL {
	return self.GetHeader()
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
				Expr: light.BooleanToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: light.StringToTextValueExpr(v, true),
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
		blk, err := exampleOrReferenceMapToBlocks(self.Examples, "examples")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk...)
	}
	if err := addSpecification(self.SpecificationExtension, &blocks); err != nil {
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
			self.Required = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "deprecated":
			self.Deprecated = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "allowEmptyValue":
			self.AllowEmptyValue = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "explode":
			self.Explode = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "allowReserved":
			self.AllowReserved = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "description":
			self.Description = *light.TextValueExprToString(v.Expr)
			found = true
		case "style":
			self.Style = *light.TextValueExprToString(v.Expr)
			found = true
		case "example":
			self.Example, err = anyFromHCL(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		case "schema":
			self.Schema, err = expressionToSchemaOrReference(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		default:
		}
	}

	self.Examples, err = blocksToExampleOrReferenceMap(body.Blocks, "examples")
	if err != nil {
		return nil, err
	}
	if self.Examples != nil {
		found = true
	}
	self.Content, err = blocksToMediaTypeMap(body.Blocks)
	if err != nil {
		return nil, err
	}
	if self.Content != nil {
		found = true
	}
	self.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	} else if self.SpecificationExtension != nil {
		found = true
	}

	if !found {
		return nil, nil
	}
	return self, nil
}

func headerOrReferenceMapToBlocks(headers map[string]*HeaderOrReference, names ...string) ([]*light.Block, error) {
	if headers == nil {
		return nil, nil
	}

	hash := make(map[string]orHCL)
	for k, v := range headers {
		hash[k] = v
	}
	return orMapToBlocks(hash, names...)
}

func blocksToHeaderOrReferenceMap(blocks []*light.Block, names ...string) (map[string]*HeaderOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, func(reference *Reference) orHCL {
		return &HeaderOrReference{
			Oneof: &HeaderOrReference_Reference{
				Reference: reference,
			},
		}
	}, func(body *light.Body) (orHCL, error) {
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
	}, names...)
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
