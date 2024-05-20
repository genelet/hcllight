package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *SecuritySchemeOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *SecuritySchemeOrReference_SecurityScheme:
		return self.GetSecurityScheme().toHCL()
	case *SecuritySchemeOrReference_Reference:
		body := self.GetReference().toBody()
		return body, nil
	default:
	}
	return nil, nil
}

func (self *SecurityScheme) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"type":             self.Type,
		"description":      self.Description,
		"name":             self.Name,
		"in":               self.In,
		"scheme":           self.Scheme,
		"bearerFormat":     self.BearerFormat,
		"openIdConnectUrl": self.OpenIdConnectUrl,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if self.Flows != nil {
		blk, err := self.Flows.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "flows",
			Bdy:  blk,
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

