package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *HeaderOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *HeaderOrReference_Header:
		return self.GetHeader().toHCL()
	case *HeaderOrReference_Reference:
		return self.GetReference().toBody(), nil
	default:
	}
	return nil, nil
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
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: self.Example.toExpression(),
		}
	}
	if self.Examples != nil {
		blk, err := exampleOrReferenceMapToBlocks(self.Examples)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk...)
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if self.Schema != nil {
		attrs["schema"] = &light.Attribute{
			Name: "schema",
			Expr: self.Schema.toExpression(),
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

