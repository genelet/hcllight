package hcl

import (
	"github.com/genelet/hcllight/light"
	//pp "github.com/k0kubun/pp/v3"
)

func (self *PathItem) toHCL() (*light.Body, error) {
	hash := self.ToOperationMap()
	blocks := make([]*light.Block, 0)
	for k, v := range hash {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "pathItem",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}

	return &light.Body{
		Blocks: blocks,
	}, nil
}

/*
	func pathItemFromHCL(body *light.Body) (*PathItem, error) {
		if body == nil {
			return nil, nil
		}
		for _, block := range body.Blocks {
			if block.Type == "pathItem" {
				hash := make(map[string]*Operation)
				for _, b := range block.Bdy.Blocks {
					operation, err := operationFromHCL(b.Bdy)
					if err != nil {
						return nil, err
					}
					hash[b.Labels[0]] = operation
				}
				return pathItemFromOperationMap(hash), nil
			}
		}
		return nil, nil
	}
*/

// ToOperationMap returns a map of operations with the key as the HTTP method.
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

	if len(self.Servers) > 0 || self.Summary != "" || self.Description != "" || len(self.Parameters) > 0 || len(self.SpecificationExtension) > 0 {
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

// PathItemFromOperationMap returns a PathItem from a map of operations with the key as the HTTP method.
func PathItemFromOperationMap(hash map[string]*Operation) *PathItem {
	if hash == nil {
		return nil
	}

	p := &PathItem{}
	for k, v := range hash {
		switch k {
		case "get":
			p.Get = v
		case "put":
			p.Put = v
		case "post":
			p.Post = v
		case "delete":
			p.Delete = v
		case "options":
			p.Options = v
		case "head":
			p.Head = v
		case "patch":
			p.Patch = v
		case "trace":
			p.Trace = v
		case "common":
			p.Summary = v.Summary
			p.Description = v.Description
			p.Servers = v.Servers
			p.Parameters = v.Parameters
			p.SpecificationExtension = v.SpecificationExtension
		}
	}

	return p
}

func pathItemOrReferenceMapToBlocks(paths map[string]*PathItemOrReference) ([]*light.Block, error) {
	if len(paths) == 0 {
		return nil, nil
	}

	blocks := make([]*light.Block, 0)

	for k, v := range paths {
		switch v.Oneof.(type) {
		case *PathItemOrReference_Reference:
			reference := v.GetReference().XRef
			blocks = append(blocks, &light.Block{
				Type:   k,
				Labels: []string{reference},
			})
		default:
			item := v.GetItem()
			hash := item.ToOperationMap()
			for k2, v2 := range hash {
				bdy, err := v2.toHCL()
				if err != nil {
					return nil, err
				}
				blocks = append(blocks, &light.Block{
					Type:   k,
					Labels: []string{k2},
					Bdy:    bdy,
				})
			}
		}
	}

	return blocks, nil
}

func blocksToPathItemOrReferenceMap(blocks []*light.Block) (map[string]*PathItemOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	hash1 := make(map[string]*PathItemOrReference)
	hash2 := make(map[string]map[string]*Operation)
	for _, block := range blocks {
		k := block.Type
		if block.Labels == nil {
			return nil, ErrInvalidType(1001, block.String())
		}
		method := block.Labels[0]
		switch method {
		case "get", "put", "post", "delete", "options", "head", "patch", "trace", "common":
			if _, ok := hash2[k]; !ok {
				hash2[k] = make(map[string]*Operation)
			}
			operation, err := operationFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			hash2[k][method] = operation
		default:
			hash1[k] = &PathItemOrReference{
				Oneof: &PathItemOrReference_Reference{
					Reference: &Reference{
						XRef: method,
					},
				},
			}
		}
	}

	for k, v := range hash2 {
		hash1[k] = &PathItemOrReference{
			Oneof: &PathItemOrReference_Item{
				Item: PathItemFromOperationMap(v),
			},
		}
	}

	return hash1, nil
}
