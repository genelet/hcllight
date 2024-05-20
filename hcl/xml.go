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
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	for k, v := range mapBools {
		if v {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: booleanToLiteralValueExpr(v),
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

func bodyToXML(body *light.Body) *Xml {
	if body == nil {
		return nil
	}
	xml := &Xml{}
	for k, v := range body.Attributes {
		switch k {
		case "name":
			xml.Name = *textValueExprToString(v.Expr)
		case "namespace":
			xml.Namespace = *textValueExprToString(v.Expr)
		case "prefix":
			xml.Prefix = *textValueExprToString(v.Expr)
		case "attribute":
			xml.Attribute = *literalValueExprToBoolean(v.Expr)
		case "wrapped":
			xml.Wrapped = *literalValueExprToBoolean(v.Expr)
		default:
		}
	}
	for _, v := range body.Blocks {
		if v.Type == "specificationExtension" {
			xml.SpecificationExtension = bodyToAnyMap(v.Bdy)
		}
	}
	return xml
}
