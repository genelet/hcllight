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
	if err := addSpecificationBlock(self.SpecificationExtension, &body.Blocks); err != nil {
		return nil, err
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}

	return body, nil
}

func serverVariableFromHCL(body *light.Body) (*ServerVariable, error) {
	if body == nil {
		return nil, nil
	}

	self := &ServerVariable{}
	var found bool
	var err error
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
			self.SpecificationExtension, err = bodyToAnyMap(block.Bdy)
			if err != nil {
				return nil, err
			}
			found = true
		}
	}

	if found {
		return self, nil
	}
	return nil, nil
}

func serverVariableMapToBlocks(serverVariables map[string]*ServerVariable) ([]*light.Block, error) {
	if serverVariables == nil {
		return nil, nil
	}
	hash := make(map[string]ableHCL)
	for k, v := range serverVariables {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "serverVariable")
}

func blocksToServerVariableMap(blocks []*light.Block) (map[string]*ServerVariable, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*ServerVariable)
	for _, block := range blocks {
		able, err := serverVariableFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}
