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

	if self.Content != nil {
		blks, err := mediaTypeMapToBlocks(self.Content)
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
	if self.Links != nil {
		blks, err := linkOrReferenceMapToBlocks(self.Links, "links")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if err := addSpecification(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
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

	response.Content, err = blocksToMediaTypeMap(body.Blocks)
	if err != nil {
		return nil, err
	}
	if response.Content == nil {
		found = true
	}
	response.Headers, err = blocksToHeaderOrReferenceMap(body.Blocks, "headers")
	if err != nil {
		return nil, err
	}
	if response.Headers == nil {
		found = true
	}
	response.Links, err = blocksToLinkOrReferenceMap(body.Blocks, "links")
	if err != nil {
		return nil, err
	}
	if response.Links == nil {
		found = true
	}
	response.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	} else if response.SpecificationExtension == nil {
		found = true
	}

	if !found {
		return nil, nil
	}
	return response, nil
}

func responseOrReferenceMapToBlocks(responses map[string]*ResponseOrReference, names ...string) ([]*light.Block, error) {
	if responses == nil {
		return nil, nil
	}

	hash := make(map[string]orHCL)
	for k, v := range responses {
		hash[k] = v
	}
	return orMapToBlocks(hash, names...)
}

func blocksToResponseOrReferenceMap(blocks []*light.Block, names ...string) (map[string]*ResponseOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, func(reference *Reference) orHCL {
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
	}, names...)
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
