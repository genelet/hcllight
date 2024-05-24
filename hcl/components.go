package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Components) toHCL() (*light.Body, error) {
	body := new(light.Body)
	blocks := make([]*light.Block, 0)
	if self.Schemas != nil {
		blks, err := schemaOrReferenceMapToBlocks(self.Schemas, "schemas")
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

func componentsFromHCL(body *light.Body) (*Components, error) {
	if body == nil {
		return nil, nil
	}

	schemaOrReferenceMap, err := blocksToSchemaOrReferenceMap(body.Blocks, "schemas")
	if err != nil {
		return nil, err
	}
	responseOrReferenceMap, err := blocksToResponseOrReferenceMap(body.Blocks, "responses")
	if err != nil {
		return nil, err
	}
	parameters, err := blocksToParameterOrReferenceMap(body.Blocks, "parameters")
	if err != nil {
		return nil, err
	}
	examples, err := blocksToExampleOrReferenceMap(body.Blocks, "examples")
	if err != nil {
		return nil, err
	}
	requestBodies, err := blocksToRequestBodyOrReferenceMap(body.Blocks, "requestBodies")
	if err != nil {
		return nil, err
	}
	headers, err := blocksToHeaderOrReferenceMap(body.Blocks, "headers")
	if err != nil {
		return nil, err
	}
	securitySchemes, err := blocksToSecuritySchemeOrReferenceMap(body.Blocks, "securitySchemes")
	if err != nil {
		return nil, err
	}
	links, err := blocksToLinkOrReferenceMap(body.Blocks, "links")
	if err != nil {
		return nil, err
	}
	callbacks, err := blocksToCallbackOrReferenceMap(body.Blocks, "callbacks")
	if err != nil {
		return nil, err
	}
	var specificationExtension map[string]*Any
	for _, block := range body.Blocks {
		if block.Type == "specification" {
			specificationExtension, err = bodyToAnyMap(block.Bdy)
			if err != nil {
				return nil, err
			}
		}
	}

	if schemaOrReferenceMap == nil && responseOrReferenceMap == nil && parameters == nil &&
		examples == nil && requestBodies == nil && headers == nil && securitySchemes == nil &&
		links == nil && callbacks == nil && specificationExtension == nil {
		return nil, nil
	}

	return &Components{
		Schemas:                schemaOrReferenceMap,
		Responses:              responseOrReferenceMap,
		Parameters:             parameters,
		Examples:               examples,
		RequestBodies:          requestBodies,
		Headers:                headers,
		SecuritySchemes:        securitySchemes,
		Links:                  links,
		Callbacks:              callbacks,
		SpecificationExtension: specificationExtension,
	}, nil
}
