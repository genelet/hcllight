package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *RequestBodyOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *RequestBodyOrReference_RequestBody:
		return self.GetRequestBody().toHCL()
	case *RequestBodyOrReference_Reference:
		return self.GetReference().toHCL()
	default:
	}
	return nil, nil
}

func requestBodyOrReferenceFromHCL(body *light.Body) (*RequestBodyOrReference, error) {
	if body == nil {
		return nil, nil
	}

	reference, err := referenceFromHCL(body)
	if err != nil {
		return nil, err
	}
	if reference != nil {
		return &RequestBodyOrReference{
			Oneof: &RequestBodyOrReference_Reference{
				Reference: reference,
			},
		}, nil
	}

	requestBody, err := requestBodyFromHCL(body)
	if err != nil {
		return nil, err
	}
	if requestBody == nil {
		return nil, nil
	}
	return &RequestBodyOrReference{
		Oneof: &RequestBodyOrReference_RequestBody{
			RequestBody: requestBody,
		},
	}, nil
}

func (self *RequestBody) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Description != "" {
		attrs["description"] = &light.Attribute{
			Name: "description",
			Expr: stringToTextValueExpr(self.Description),
		}
	}
	if self.Required {
		attrs["required"] = &light.Attribute{
			Name: "required",
			Expr: booleanToLiteralValueExpr(self.Required),
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

	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}

	return body, nil
}

func requestBodyFromHCL(body *light.Body) (*RequestBody, error) {
	if body == nil {
		return nil, nil
	}

	requestBody := new(RequestBody)
	var found bool
	var err error
	for k, v := range body.Attributes {
		switch k {
		case "description":
			requestBody.Description = *textValueExprToString(v.Expr)
		case "required":
			requestBody.Required = *literalValueExprToBoolean(v.Expr)
		default:
		}
	}
	for _, block := range body.Blocks {
		switch block.Labels[0] {
		case "content":
			content, err := blocksToMediaTypeMap(block.Bdy.Blocks)
			if err != nil {
				return nil, err
			}
			requestBody.Content = content
		case "specification":
			requestBody.SpecificationExtension, err = bodyToAnyMap(block.Bdy)
			if err != nil {
				return nil, err
			}
		default:
		}
	}

	if !found {
		return nil, nil
	}
	return requestBody, nil
}

func requestBodyOrReferenceMapToBlocks(requestBodys map[string]*RequestBodyOrReference) ([]*light.Block, error) {
	if requestBodys == nil {
		return nil, nil
	}

	hash := make(map[string]OrHCL)
	for k, v := range requestBodys {
		hash[k] = v
	}
	return orMapToBlocks(hash, "requestBodys")
}

func blocksToRequestBodyOrReferenceMap(blocks []*light.Block) (map[string]*RequestBodyOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, "requestBodys", func(reference *Reference) OrHCL {
		return &RequestBodyOrReference{
			Oneof: &RequestBodyOrReference_Reference{
				Reference: reference,
			},
		}
	}, func(body *light.Body) (OrHCL, error) {
		requestBody, err := requestBodyFromHCL(body)
		if err != nil {
			return nil, err
		}
		if requestBody != nil {
			return &RequestBodyOrReference{
				Oneof: &RequestBodyOrReference_RequestBody{
					RequestBody: requestBody,
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

	hash := make(map[string]*RequestBodyOrReference)
	for k, v := range orMap {
		hash[k] = v.(*RequestBodyOrReference)
	}

	return hash, nil
}
