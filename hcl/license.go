package hcl

import (
	"github.com/genelet/hcllight/light"
)


func (self *License) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	mapStrings := map[string]string{
		"name": self.Name,
		"url":  self.Url,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}

	return body, nil
}

