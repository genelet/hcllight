package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Xml) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"name":      self.Name,
		"namespace": self.Namespace,
		"prefix":    self.Prefix,
	}
	mapBools := map[string]bool{
		"attribute": self.Attribute,
		"wrapped":   self.Wrapped,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: light.StringToTextValueExpr(v),
			}
		}
	}
	for k, v := range mapBools {
		if v {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: light.BooleanToLiteralValueExpr(v),
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

func xmlFromHCL(body *light.Body) (*Xml, error) {
	if body == nil {
		return nil, nil
	}
	xml := &Xml{}
	var found bool
	var err error
	for k, v := range body.Attributes {
		switch k {
		case "name":
			xml.Name = *light.TextValueExprToString(v.Expr)
			found = true
		case "namespace":
			xml.Namespace = *light.TextValueExprToString(v.Expr)
			found = true
		case "prefix":
			xml.Prefix = *light.TextValueExprToString(v.Expr)
			found = true
		case "attribute":
			xml.Attribute = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "wrapped":
			xml.Wrapped = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		default:
		}
	}
	for _, v := range body.Blocks {
		if v.Type == "specificationExtension" {
			xml.SpecificationExtension, err = bodyToAnyMap(v.Bdy)
			if err != nil {
				return nil, err
			}
			found = true
		}
	}

	if !found {
		return nil, nil
	}
	return xml, nil
}
