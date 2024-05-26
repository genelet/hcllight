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

func externalDocsFromHCL(body *light.Body) (*ExternalDocs, error) {
	if body == nil {
		return nil, nil
	}
	externalDocs := &ExternalDocs{}
	var found bool
	for k, v := range body.Attributes {
		switch k {
		case "url":
			externalDocs.Url = *textValueExprToString(v.Expr)
			found = true
		case "description":
			externalDocs.Description = *textValueExprToString(v.Expr)
			found = true
		}
	}

	if found {
		return externalDocs, nil
	}
	return nil, nil
}
