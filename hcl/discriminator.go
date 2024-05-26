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
				Expr: light.StringToTextValueExpr(v),
			}
		}
	}
	if self.Mapping != nil {
		attrs["mapping"] = &light.Attribute{
			Name: "mapping",
			Expr: light.StringMapToObjConsExpr(self.Mapping),
		}
	}
	if self.SpecificationExtension != nil {
		body.Blocks = make([]*light.Block, 0)
		if err := addSpecification(self.SpecificationExtension, &body.Blocks); err != nil {
			return nil, err
		}
	}

	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	return body, nil
}

func discriminatorFromHCL(body *light.Body) (*Discriminator, error) {
	if body == nil {
		return nil, nil
	}
	discriminator := &Discriminator{}
	var found bool
	for k, v := range body.Attributes {
		switch k {
		case "propertyName":
			discriminator.PropertyName = *light.TextValueExprToString(v.Expr)
			found = true
		case "mapping":
			discriminator.Mapping = light.ObjConsExprToStringMap(v.Expr)
			found = true
		default:
		}
	}
	var err error
	discriminator.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	}
	if discriminator.SpecificationExtension != nil {
		found = true
	}

	if !found {
		return nil, nil
	}
	return discriminator, nil
}
