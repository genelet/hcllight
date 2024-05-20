package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *ExternalDocs) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"url":         self.Url,
		"description": self.Description,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
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

func bodyToExternalDocs(body *light.Body) *ExternalDocs {
	if body == nil {
		return nil
	}
	externalDocs := &ExternalDocs{}
	for k, v := range body.Attributes {
		switch k {
		case "url":
			externalDocs.Url = *textValueExprToString(v.Expr)
		case "description":
			externalDocs.Description = *textValueExprToString(v.Expr)
		}
	}
	return externalDocs
}
