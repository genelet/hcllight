package hcl

import (
	"github.com/genelet/hcllight/light"
)

func pathItemMapToBlocks(paths map[string]*PathItem) ([]*light.Block, error) {
	blocks := make([]*light.Block, 0)
	for k, v := range paths {
		switch v.Oneof.(type) {
		case *PathItemOrReference_PathItem:
			t := v.GetPathItem()
			body, err := t.toHCL()
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type: k,
				Bdy:  body,
			})
		case *PathItemOrReference_Reference:
			t := v.GetReference()
			blocks = append(blocks, &light.Block{
				Type: k,
				Bdy:  stringToLiteralValueExpr(t.XRef),
			})
		default:
		}
	}
	return blocks, nil
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

func (self *Operation) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"deprecated": self.Deprecated,
	}
	mapStrings := map[string]string{
		"summary":     self.Summary,
		"description": self.Description,
		"operationId": self.OperationId,
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
				Expr: stringToLiteralValueExpr(v),
			}
		}
	}
	if self.Tags != nil {
		expr := stringsToTupleConsExpr(self.Tags)
		attrs["tags"] = &light.Attribute{
			Name: "tags",
			Expr: expr,
		}
	}
	if self.Parameters != nil {
		hash := arrayParameterToHash(self.Parameters)
		blks, err := parameterOrReferenceMapToBlocks(hash)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.RequestBody != nil {
		bdy, err := self.RequestBody.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "requestBody",
			Bdy:  bdy,
		})
	}
	if self.Responses != nil {
		blks, err := responseOrReferenceMapToBlocks(self.Responses)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Callbacks != nil {
		blk, err := toBlock(self.Callbacks, "callbacks")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk)
	}
	if self.Security != nil {
		blk, err := toBlock(self.Security, "security")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk)
	}
	if self.Servers != nil {
		blk, err := toBlock(self.Servers, "servers")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk)
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}
