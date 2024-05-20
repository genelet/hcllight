package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *ResponseOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *ResponseOrReference_Response:
		return self.GetResponse().toHCL()
	case *ResponseOrReference_Reference:
		body := self.GetReference().toBody()
		return body, nil
	default:
	}
	return nil, nil
}

func (self *Response) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Description != "" {
		body.Attributes = map[string]*light.Attribute{
			"description": {
				Name: "description",
				Expr: stringToTextValueExpr(self.Description),
			},
		}
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}

	if self.Content != nil {
		blks, err := mediaTypeMapToBlocks(self.Content)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Headers != nil {
		blks, err := headerOrReferenceMapToBlocks(self.Headers)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Links != nil {
		blks, err := linkOrReferenceMapToBlocks(self.Links)
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

