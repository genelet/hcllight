package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *ResponseOrReference) getAble() ableHCL {
	return self.GetResponse()
}

func responseOrReferenceFromHCL(body *light.Body) (*ResponseOrReference, error) {
	if body == nil {
		return nil, nil
	}

	reference, err := referenceFromHCL(body)
	if err != nil {
		return nil, err
	}
	if reference != nil {
		return &ResponseOrReference{
			Oneof: &ResponseOrReference_Reference{
				Reference: reference,
			},
		}, nil
	}

	response, err := responseFromHCL(body)
	if err != nil {
		return nil, err
	}
	if response == nil {
		return nil, nil
	}
	return &ResponseOrReference{
		Oneof: &ResponseOrReference_Response{
			Response: response,
		},
	}, nil
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
	if err := addSpecificationBlock(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
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

func responseFromHCL(body *light.Body) (*Response, error) {
	if body == nil {
		return nil, nil
	}
	response := new(Response)
	var err error
	var found bool
	for k, v := range body.Attributes {
		switch k {
		case "description":
			response.Description = *textValueExprToString(v.Expr)
			found = true
		default:
		}
	}
	for _, block := range body.Blocks {
		switch block.Type {
		case "specification":
			response.SpecificationExtension, err = bodyToAnyMap(block.Bdy)
			if err != nil {
				return nil, err
			}
			found = true
		case "content":
			response.Content, err = blocksToMediaTypeMap(block.Bdy.Blocks)
			if err != nil {
				return nil, err
			}
			found = true
		case "header":
			response.Headers, err = blocksToHeaderOrReferenceMap(block.Bdy.Blocks)
			if err != nil {
				return nil, err
			}
			found = true
		case "link":
			response.Links, err = blocksToLinkOrReferenceMap(block.Bdy.Blocks)
			if err != nil {
				return nil, err
			}
		default:
		}
	}
	if !found {
		return nil, nil
	}
	return response, nil
}

func responseOrReferenceMapToBlocks(responses map[string]*ResponseOrReference) ([]*light.Block, error) {
	if responses == nil {
		return nil, nil
	}

	hash := make(map[string]orHCL)
	for k, v := range responses {
		hash[k] = v
	}
	return orMapToBlocks(hash, "responses")
}

func blocksToResponseOrReferenceMap(blocks []*light.Block) (map[string]*ResponseOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, "responses", func(reference *Reference) orHCL {
		return &ResponseOrReference{
			Oneof: &ResponseOrReference_Reference{
				Reference: reference,
			},
		}
	}, func(body *light.Body) (orHCL, error) {
		response, err := responseFromHCL(body)
		if err != nil {
			return nil, err
		}
		if response != nil {
			return &ResponseOrReference{
				Oneof: &ResponseOrReference_Response{
					Response: response,
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

	hash := make(map[string]*ResponseOrReference)
	for k, v := range orMap {
		hash[k] = v.(*ResponseOrReference)
	}

	return hash, nil
}
