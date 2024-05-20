package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *ExampleOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *ExampleOrReference_Example:
		return self.GetExample().toHCL()
	case *ExampleOrReference_Reference:
		body := self.GetReference().toBody()
		return body, nil
	default:
	}
	return nil, nil
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
	if self.SpecificationExtension != nil {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}
