package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *ExampleOrReference) getAble() ableHCL {
	return self.GetExample()
}

func (self *Example) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"summary":       self.Summary,
		"description":   self.Description,
		"externalValue": self.ExternalValue,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: light.StringToTextValueExpr(v),
			}
		}
	}
	if self.Value != nil {
		expr, err := self.Value.toExpression()
		if err != nil {
			return nil, err
		}
		attrs["value"] = &light.Attribute{
			Name: "value",
			Expr: expr,
		}
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

func exampleFromHCL(body *light.Body) (*Example, error) {
	if body == nil {
		return nil, nil
	}
	example := &Example{}
	var found bool
	var err error
	for k, v := range body.Attributes {
		switch k {
		case "summary":
			example.Summary = *light.TextValueExprToString(v.Expr)
			found = true
		case "description":
			example.Description = *light.TextValueExprToString(v.Expr)
			found = true
		case "externalValue":
			example.ExternalValue = *light.TextValueExprToString(v.Expr)
			found = true
		case "value":
			example.Value, err = anyFromHCL(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		}
	}
	example.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	} else if example.SpecificationExtension != nil {
		found = true
	}

	if found {
		return example, nil
	}
	return nil, nil
}

func exampleOrReferenceMapToBlocks(examples map[string]*ExampleOrReference, names ...string) ([]*light.Block, error) {
	if examples == nil {
		return nil, nil
	}

	hash := make(map[string]orHCL)
	for k, v := range examples {
		hash[k] = v
	}
	return orMapToBlocks(hash, names...)
}

func blocksToExampleOrReferenceMap(blocks []*light.Block, names ...string) (map[string]*ExampleOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, func(reference *Reference) orHCL {
		return &ExampleOrReference{
			Oneof: &ExampleOrReference_Reference{
				Reference: reference,
			},
		}
	}, func(body *light.Body) (orHCL, error) {
		example, err := exampleFromHCL(body)
		if err != nil {
			return nil, err
		}
		if example != nil {
			return &ExampleOrReference{
				Oneof: &ExampleOrReference_Example{
					Example: example,
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

	hash := make(map[string]*ExampleOrReference)
	for k, v := range orMap {
		hash[k] = v.(*ExampleOrReference)
	}

	return hash, nil
}
