package hcl

import (
	"github.com/genelet/hcllight/light"
)


func (self *Tag) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	mapStrings := map[string]string{
		//"name":        self.Name,
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
	if self.ExternalDocs != nil {
		blk, err := self.ExternalDocs.toHCL()
		if err != nil {
			return nil, err
		}
		body.Blocks = append(body.Blocks, &light.Block{
			Type: "externalDocs",
			Bdy:  blk,
		})
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	return body, nil
}
