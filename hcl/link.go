package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *LinkOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *LinkOrReference_Link:
		return self.GetLink().toHCL()
	case *LinkOrReference_Reference:
		body := self.GetReference().toBody()
		return body, nil
	default:
	}
	return nil, nil
}

func (self *Link) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"operationRef": self.OperationRef,
		"operationId":  self.OperationId,
		"description":  self.Description,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Server != nil {
		bdy, err := self.Server.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "server",
			Bdy:  bdy,
		})
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}

	if self.Parameters != nil {
		attrs["parameters"] = &light.Attribute{
			Name: "parameters",
			Expr: self.Parameters.toExpression(),
		}
	}
	if self.RequestBody != nil {
		attrs["requestBody"] = &light.Attribute{
			Name: "requestBody",
			Expr: self.RequestBody.toExpression(),
		}
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

