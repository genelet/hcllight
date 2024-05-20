package hcl

import (
	"github.com/genelet/hcllight/light"
)


func (self *MediaType) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
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

	if self.Schema != nil {
		attrs["schema"] = &light.Attribute{
			Name: "schema",
			Expr: self.Schema.toExpression(),
		}
	}
	if self.Encoding != nil {
		blks, err := encodingMapToBlocks(self.Encoding)
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

