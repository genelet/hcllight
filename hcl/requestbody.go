package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *RequestBodyOrReference) getAble() ableHCL {
	return self.GetRequestBody()
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
			Expr: light.StringToTextValueExpr(self.Description),
		}
	}
	if self.Required {
		attrs["required"] = &light.Attribute{
			Name: "required",
			Expr: light.BooleanToLiteralValueExpr(self.Required),
		}
	}
	if err := addSpecification(self.SpecificationExtension, &blocks); err != nil {
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
			requestBody.Description = *light.TextValueExprToString(v.Expr)
			found = true
		case "required":
			requestBody.Required = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		default:
		}
	}
	requestBody.Content, err = blocksToMediaTypeMap(body.Blocks)
	if err != nil {
		return nil, err
	}
	if requestBody.Content == nil {
		found = true
	}

	requestBody.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	} else if requestBody.SpecificationExtension == nil {
		found = true
	}

	if !found {
		return nil, nil
	}
	return requestBody, nil
}

func requestBodyOrReferenceMapToBlocks(requestBodys map[string]*RequestBodyOrReference, names ...string) ([]*light.Block, error) {
	if requestBodys == nil {
		return nil, nil
	}

	hash := make(map[string]orHCL)
	for k, v := range requestBodys {
		hash[k] = v
	}
	return orMapToBlocks(hash, names...)
}

func blocksToRequestBodyOrReferenceMap(blocks []*light.Block, names ...string) (map[string]*RequestBodyOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, func(reference *Reference) orHCL {
		return &RequestBodyOrReference{
			Oneof: &RequestBodyOrReference_Reference{
				Reference: reference,
			},
		}
	}, func(body *light.Body) (orHCL, error) {
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
	}, names...)
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
