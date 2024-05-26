package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Contact) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	mapStrings := map[string]string{
		"name":  self.Name,
		"url":   self.Url,
		"email": self.Email,
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

func contactFromHCL(body *light.Body) (*Contact, error) {
	if body == nil {
		return nil, nil
	}

	self := &Contact{}
	var found bool
	if attr, ok := body.Attributes["name"]; ok {
		if attr.Expr != nil {
			self.Name = *textValueExprToString(attr.Expr)
			found = true
		}
	}
	if attr, ok := body.Attributes["url"]; ok {
		if attr.Expr != nil {
			self.Url = *textValueExprToString(attr.Expr)
			found = true
		}
	}
	if attr, ok := body.Attributes["email"]; ok {
		if attr.Expr != nil {
			self.Email = *textValueExprToString(attr.Expr)
			found = true
		}

	}

	if !found {
		return nil, nil
	}

	return self, nil
}
