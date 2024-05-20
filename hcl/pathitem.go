package hcl

import (
	"github.com/genelet/hcllight/light"
)


func (self *PathItem) ToOperationMap() map[string]*Operation {
	p := make(map[string]*Operation)
	if self.Get != nil {
		p["get"] = self.Get
	}
	if self.Put != nil {
		p["put"] = self.Put
	}
	if self.Post != nil {
		p["post"] = self.Post
	}
	if self.Delete != nil {
		p["delete"] = self.Delete
	}
	if self.Options != nil {
		p["options"] = self.Options
	}
	if self.Head != nil {
		p["head"] = self.Head
	}
	if self.Patch != nil {
		p["patch"] = self.Patch
	}
	if self.Trace != nil {
		p["trace"] = self.Trace
	}

	if (self.Servers != nil && len(self.Servers) > 0) || self.Summary != "" || self.Description != "" || (self.Parameters != nil && len(self.Parameters) > 0) || (self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0) {
		p["common"] = &Operation{
			Summary:                self.Summary,
			Description:            self.Description,
			Servers:                self.Servers,
			Parameters:             self.Parameters,
			SpecificationExtension: self.SpecificationExtension,
		}
	}

	return p
}

func pathItemMapToBlocks(paths map[string]*PathItem) ([]*light.Block, error) {
	blocks := make([]*light.Block, 0)
	for k, v := range paths {
		if v.XRef != "" {
			blocks = append(blocks, &light.Block{
				Type:   "pathItem",
				Labels: []string{k, v.XRef},
				Bdy: &light.Body{
					Attributes: map[string]*light.Attribute{
						"$ref": {
							Name: "$ref",
							Expr: stringToTextValueExpr(v.XRef),
						},
					},
				},
			})
			continue
		}
		hash := v.ToOperationMap()
		for k2, v2 := range hash {
			bdy, err := v2.toHCL()
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type:   "pathItem",
				Labels: []string{k, k2},
				Bdy:    bdy,
			})
		}
	}

	return blocks, nil
}

