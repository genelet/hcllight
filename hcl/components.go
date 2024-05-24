package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Components) toHCL() (*light.Body, error) {
	body := new(light.Body)
	blocks := make([]*light.Block, 0)
	if self.Schemas != nil {
		blks, err := mapSchemaOrReferenceToBlocks(self.Schemas, "schemas")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Responses != nil {
		blks, err := responseOrReferenceMapToBlocks(self.Responses, "responses")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Parameters != nil {
		blks, err := parameterOrReferenceMapToBlocks(self.Parameters, "parameters")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Examples != nil {
		blks, err := exampleOrReferenceMapToBlocks(self.Examples, "examples")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.RequestBodies != nil {
		blks, err := requestBodyOrReferenceMapToBlocks(self.RequestBodies, "requestBodies")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Headers != nil {
		blks, err := headerOrReferenceMapToBlocks(self.Headers, "headers")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.SecuritySchemes != nil {
		blks, err := securitySchemeOrReferenceMapToBlocks(self.SecuritySchemes, "securitySchemes")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Links != nil {
		blks, err := linkOrReferenceMapToBlocks(self.Links, "links")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Callbacks != nil {
		blks, err := callbackOrReferenceMapToBlocks(self.Callbacks, "callbacks")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if err := addSpecificationBlock(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
	}

	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

/*
func componentsFromHCL(body *light.Body) (*Components, error) {
	if body == nil {
		return nil, nil
	}

	var found bool
	var blocks_schemas []*light.Block
	var blocks_responses []*light.Block
	var blocks_parameters []*light.Block
	var blocks_examples []*light.Block
	var blocks_requestBodies []*light.Block
	var blocks_headers []*light.Block
	var blocks_securitySchemes []*light.Block
	var blocks_links []*light.Block
	var blocks_callbacks []*light.Block
	var blocks_specificationExtension []*light.Block

	var attrs_schema map[string]*light.Attribute

	for _, block := range body.Blocks {
		if block.Type != "components" {
			continue
		}
		found = true
		if block.Labels == nil || len(block.Labels) == 0 {
			return nil, ErrInvalidType("components")
		}

		switch block.Labels[0] {
		case "schemas":
			if len(block.Labels) == 1 {
				attrs_schema = block.Bdy.Attributes
				continue
			}
			blocks_schemas = append(blocks_schemas, &light.Block{
				Type: block.Labels[1],
				Bdy:  block.Bdy,
			})
		case "responses":
			if len(block.Labels) == 1 {
				blocks_responses = append(blocks_responses, block)
				continue
			}
		case "parameters":
			parameters, err := parameterOrReferenceMapFromBlocks(v.Blocks)
			if err != nil {
				return nil, err
			}
			components.Parameters = parameters
		case "examples":
			examples, err := exampleOrReferenceMapFromBlocks(v.Blocks)
			if err != nil {
				return nil, err
			}
			components.Examples = examples
		case "requestBodies":
			requestBodies, err := requestBodyOrReferenceMapFromBlocks(v.Blocks)
			if err != nil {
				return nil, err
			}
			components.RequestBodies = requestBodies
		case "headers":
			headers, err := headerOrReferenceMapFromBlocks(v.Blocks)
			if err != nil {
				return nil, err
			}
			components.Headers = headers
		case "securitySchemes":
			securitySchemes, err := securitySchemeOrReferenceMapFromBlocks(v.Blocks)
			if err != nil {
				return nil, err
			}
			components.SecuritySchemes = securitySchemes
		case "links":
			links, err := linkOrReferenceMapFromBlocks(v.Blocks)
			if err != nil {
				return nil, err
			}
			components.Links = links
		case "callbacks":
			callbacks := make(map[string]*Callback)
			for _, block := range v.Blocks {
				callback, err := callbackFromHCL(block.Bdy)
				if err != nil {
					return nil, err
				}
				callbacks[block.Labels[0]] = callback
			}
			components.Callbacks = callbacks
		default:
			if err := addSpecificationAttribute(k, v, &components.SpecificationExtension); err != nil {
				return nil, err
			}
		}
	}

	return components, nil
}
*/
