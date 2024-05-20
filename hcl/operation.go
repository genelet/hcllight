package hcl

import (
	"github.com/genelet/hcllight/light"
)


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
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Tags != nil {
		expr := stringArrayToTupleConsEpr(self.Tags)
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
		blks, err := callbackOrReferenceMapToBlocks(self.Callbacks)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Security != nil {
		expr, err := securityRequirementToTupleConsExpr(self.Security)
		if err != nil {
			return nil, err
		}
		attrs["security"] = &light.Attribute{
			Name: "security",
			Expr: expr,
		}
	}
	if self.Servers != nil {
		expr, err := serversToTupleConsExpr(self.Servers)
		if err != nil {
			return nil, err
		}
		attrs["servers"] = &light.Attribute{
			Name: "servers",
			Expr: expr,
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

