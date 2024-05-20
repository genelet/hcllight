package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Discriminator) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	mapStrings := map[string]string{
		"propertyName": self.PropertyName,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Mapping != nil {
		bdy := &light.Body{
			Attributes: make(map[string]*light.Attribute),
		}
		for k, v := range self.Mapping {
			bdy.Attributes[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
		body.Blocks = append(body.Blocks, &light.Block{
			Type: "mapping",
			Bdy:  bdy,
		})
	}

	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	return body, nil
}

func bodyToDiscriminator(body *light.Body) *Discriminator {
	if body == nil {
		return nil
	}
	discriminator := &Discriminator{}
	for k, v := range body.Attributes {
		switch k {
		case "propertyName":
			discriminator.PropertyName = *textValueExprToString(v.Expr)
		}
	}
	for _, v := range body.Blocks {
		switch v.Type {
		case "mapping":
			discriminator.Mapping = make(map[string]string)
			for k, v := range v.Bdy.Attributes {
				discriminator.Mapping[k] = *textValueExprToString(v.Expr)
			}
		}
	}
	return discriminator
}
