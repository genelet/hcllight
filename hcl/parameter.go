package hcl

import (
	"github.com/genelet/hcllight/light"
)


func (self *ParameterOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *ParameterOrReference_Parameter:
		return self.GetParameter().toHCL()
	case *ParameterOrReference_Reference:
		return self.GetReference().toBody()
	default:
	}
	return nil, nil
}

func (self *Parameter) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"required":        self.Required,
		"deprecated":      self.Deprecated,
		"allowEmptyValue": self.AllowEmptyValue,
		"explode":         self.Explode,
		"allowReserved":   self.AllowReserved,
	}
	mapStrings := map[string]string{
		"name":        self.Name,
		"in":          self.In,
		"description": self.Description,
		"style":       self.Style,
	}
	for k, v := range mapBools {
		if v {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: booleanToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Example != nil {
		expr := self.Example.toExpression()
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: expr,
		}
	}
	if self.Examples != nil {
		blk, err := exampleOrReferenceMapToBlocks(self.Examples)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk...)
	}
	addSpecificationBlock(self.SpecificationExtension, &blocks)

	if self.Schema != nil {
		expr, err := SchemaOrReferenceToExpression(self.Schema)
		if err != nil {
			return nil, err
		}
		attrs["schema"] = &light.Attribute{
			Name: "schema",
			Expr: expr,
		}
	}
	if self.Content != nil {
		blks, err := mediaTypeMapToBlocks(self.Content)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}


func arrayParameterToHash(array []*ParameterOrReference) map[string]*ParameterOrReference {
	hash := make(map[string]*ParameterOrReference)
	for _, v := range array {
		switch v.Oneof.(type) {
		case *ParameterOrReference_Parameter:
			t := v.GetParameter()
			name := t.Name
			t.Name = ""
			hash[name] = v
		case *ParameterOrReference_Reference:
			t := v.GetReference()
			hash[t.XRef] = v
		default:
		}
	}
	return hash
}
