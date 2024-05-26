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
				Expr: light.StringToTextValueExpr(v),
			}
		}
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}

	return body, nil
}

func licenseFromHCL(body *light.Body) (*License, error) {
	if body == nil {
		return nil, nil
	}

	self := &License{}
	var found bool
	if attr, ok := body.Attributes["name"]; ok {
		if attr.Expr != nil {
			self.Name = *light.TextValueExprToString(attr.Expr)
			found = true
		}
	}
	if attr, ok := body.Attributes["url"]; ok {
		if attr.Expr != nil {
			self.Url = *light.TextValueExprToString(attr.Expr)
		}
	}

	if !found {
		return nil, nil
	}

	return self, nil
}
