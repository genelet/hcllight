package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Components) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Schemas != nil {
		/*
			blks, err := schemaOrReferenceMapToBlocks(self.Schemas)
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, blks...)
		*/
		bdy, err := mapSchemaOrReferenceToBody(self.Schemas)
		if err != nil {
			return nil, err
		}
		for k, v := range bdy.Attributes {
			attrs[k] = v
		}
		blocks = append(blocks, bdy.Blocks...)
	}
	if self.Responses != nil {
		blks, err := responseOrReferenceMapToBlocks(self.Responses)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Parameters != nil {
		blks, err := parameterOrReferenceMapToBlocks(self.Parameters)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Examples != nil {
		blks, err := exampleOrReferenceMapToBlocks(self.Examples)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.RequestBodies != nil {
		blks, err := requestBodyOrReferenceMapToBlocks(self.RequestBodies)
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
	if self.SecuritySchemes != nil {
		blks, err := securitySchemeOrReferenceMapToBlocks(self.SecuritySchemes)
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
	if self.Callbacks != nil && len(self.Callbacks) > 0 {
		for k, v := range self.Callbacks {
			bdy, err := v.toHCL()
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type:   "callbacks",
				Labels: []string{k},
				Bdy:    bdy,
			})
		}
	}
	addSpecificationBlock(self.SpecificationExtension, &blocks)
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}
