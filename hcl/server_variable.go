package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *ServerVariable) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	mapStrings := map[string]string{
		"default":     self.Default,
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
	if self.Enum != nil {
		expr := stringArrayToTupleConsEpr(self.Enum)
		attrs["enum"] = &light.Attribute{
			Name: "enum",
			Expr: expr,
		}
	}
	addSpecificationBlock(self.SpecificationExtension, &body.Blocks)
	if len(attrs) > 0 {
		body.Attributes = attrs
	}

	return body, nil
}

func serverVariableFromBody(body *light.Body) (*ServerVariable, error) {
	if body == nil {
		return nil, nil
	}

	self := &ServerVariable{}
	var found bool
	if attr, ok := body.Attributes["default"]; ok {
		self.Default = *literalValueExprToString(attr.Expr)
		found = true
	}
	if attr, ok := body.Attributes["description"]; ok {
		self.Description = *literalValueExprToString(attr.Expr)
		found = true
	}
	if attr, ok := body.Attributes["enum"]; ok {
		self.Enum = tupleConsExprToStringArray(attr.Expr)
		found = true
	}
	for _, block := range body.Blocks {
		if block.Type == "SpecificationExtension" {
			self.SpecificationExtension = bodyToAnyMap(block.Bdy)
			found = true
		}
	}

	if found {
		return self, nil
	}
	return nil, nil
}
