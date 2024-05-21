package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *ExampleOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *ExampleOrReference_Example:
		return self.GetExample().toHCL()
	case *ExampleOrReference_Reference:
		return self.GetReference().toHCL()
	default:
	}
	return nil, nil
}

func exampleOrReferenceFromHCL(body *light.Body) (*ExampleOrReference, error) {
	if body == nil {
		return nil, nil
	}

	reference, err := referenceFromHCL(body)
	if err != nil {
		return nil, err
	}
	if reference != nil {
		return &ExampleOrReference{
			Oneof: &ExampleOrReference_Reference{
				Reference: reference,
			},
		}, nil
	}

	example, err := exampleFromHCL(body)
	if err != nil {
		return nil, err
	}
	if example == nil {
		return nil, nil
	}
	return &ExampleOrReference{
		Oneof: &ExampleOrReference_Example{
			Example: example,
		},
	}, nil
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
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Value != nil {
		attrs["value"] = &light.Attribute{
			Name: "value",
			Expr: self.Value.toExpression(),
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

func exampleFromHCL(body *light.Body) (*Example, error) {
	if body == nil {
		return nil, nil
	}
	example := &Example{}
	var found bool
	for k, v := range body.Attributes {
		switch k {
		case "summary":
			example.Summary = *textValueExprToString(v.Expr)
			found = true
		case "description":
			example.Description = *textValueExprToString(v.Expr)
			found = true
		case "externalValue":
			example.ExternalValue = *textValueExprToString(v.Expr)
			found = true
		case "value":
			example.Value = anyFromHCL(v.Expr)
			found = true
		}
	}
	for _, block := range body.Blocks {
		switch block.Type {
		case "specification":
			example.SpecificationExtension = bodyToAnyMap(block.Bdy)
		}
	}
	if found {
		return example, nil
	}
	return nil, nil
}

func exampleOrReferenceMapToBlocks(examples map[string]*ExampleOrReference) ([]*light.Block, error) {
	if examples == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range examples {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "example")
}

func blocksToExampleOrReferenceMap(blocks []*light.Block) (map[string]*ExampleOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*ExampleOrReference)
	for _, block := range blocks {
		able, err := exampleOrReferenceFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}
