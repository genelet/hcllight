package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Document) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Document) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Openapi != "" {
		attrs["openapi"] = &light.Attribute{
			Name: "openapi",
			Expr: stringToTextValueExpr(self.Openapi),
		}
	}
	if self.Info != nil {
		bdy, err := self.Info.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "info",
			Bdy:  bdy,
		})
	}
	if self.Servers != nil && len(self.Servers) > 0 {
		expr, err := serversToTupleConsExpr(self.Servers)
		if err != nil {
			return nil, err
		}
		attrs["servers"] = &light.Attribute{
			Name: "servers",
			Expr: expr,
		}
	}
	if self.Tags != nil && len(self.Tags) > 0 {
		hash := make(map[string]AbleHCL)
		for _, tag := range self.Tags {
			hash[tag.Name] = tag
		}
		blks, err := ableMapToBlocks(hash, "tags")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.ExternalDocs != nil {
		bdy, err := self.ExternalDocs.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "externalDocs",
			Bdy:  bdy,
		})
	}
	if self.Paths != nil {
		blks, err := pathItemOrReferenceMapToBlocks(self.Paths)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Components != nil {
		bdy, err := self.Components.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "components",
			Bdy:  bdy,
		})
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
	addSpecificationBlock(self.SpecificationExtension, &blocks)
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}
