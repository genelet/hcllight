package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *PathItemOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *PathItemOrReference_Item:
		return self.GetItem().toHCL()
	case *PathItemOrReference_Reference:
		return self.GetReference().toHCL()
	default:
	}
	return nil, nil
}

func pathItemOrReferenceFromHCL(body *light.Body) (*PathItemOrReference, error) {
	if body == nil {
		return nil, nil
	}

	reference, err := referenceFromHCL(body)
	if err != nil {
		return nil, err
	}
	if reference != nil {
		return &PathItemOrReference{
			Oneof: &PathItemOrReference_Reference{
				Reference: reference,
			},
		}, nil
	}

	item, err := pathItemFromHCL(body)
	if err != nil {
		return nil, err
	}
	if item == nil {
		return nil, nil
	}
	return &PathItemOrReference{
		Oneof: &PathItemOrReference_Item{
			Item: item,
		},
	}, nil
}

func (self *PathItem) toHCL() (*light.Body, error) {
	hash := self.toOperationMap()
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

func (self *PathItem) toOperationMap() map[string]*Operation {
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

func pathItemFromOperationMap(hash map[string]*Operation) *PathItem {
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
	blocks := make([]*light.Block, 0)
	for k, v := range paths {
		if x := v.GetReference(); x != nil {
			blocks = append(blocks, &light.Block{
				Type:   "paths",
				Labels: []string{k, x.XRef},
				Bdy:    &light.Body{},
			},
			)
			continue
		}

		item := v.GetItem()
		hash := item.toOperationMap()
		for k2, v2 := range hash {
			bdy, err := v2.toHCL()
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type:   "paths",
				Labels: []string{k, k2},
				Bdy:    bdy,
			})
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
		if block.Type == "paths" {
			if len(block.Labels) == 2 {
				hash1[block.Labels[0]] = &PathItemOrReference{
					Oneof: &PathItemOrReference_Reference{
						Reference: &Reference{
							XRef: block.Labels[1],
						},
					},
				}
			} else {
				if len(block.Labels) < 2 {
					return nil, ErrInvalidType()
				}
				if _, ok := hash2[block.Labels[0]]; !ok {
					hash2[block.Labels[0]] = make(map[string]*Operation)
				}
				operation, err := operationFromHCL(block.Bdy)
				if err != nil {
					return nil, err
				}
				hash2[block.Labels[0]][block.Labels[1]] = operation
			}
		}
	}

	for k, v := range hash2 {
		item := new(PathItem)
		if common, ok := v["common"]; ok {
			item = &PathItem{
				Summary:                common.Summary,
				Description:            common.Description,
				Servers:                common.Servers,
				Parameters:             common.Parameters,
				SpecificationExtension: common.SpecificationExtension,
			}
		}

		if operation, ok := v["get"]; ok {
			item.Get = operation
		}
		if operation, ok := v["put"]; ok {
			item.Put = operation
		}
		if operation, ok := v["post"]; ok {
			item.Post = operation
		}
		if operation, ok := v["delete"]; ok {
			item.Delete = operation
		}
		if operation, ok := v["options"]; ok {
			item.Options = operation
		}
		if operation, ok := v["head"]; ok {
			item.Head = operation
		}
		if operation, ok := v["patch"]; ok {
			item.Patch = operation
		}
		if operation, ok := v["trace"]; ok {
			item.Trace = operation
		}
		hash1[k] = &PathItemOrReference{
			Oneof: &PathItemOrReference_Item{
				Item: item,
			},
		}
	}

	return hash1, nil
}

/*
func pathItemOrReferenceMapToBlocks(path map[string]*PathItemOrReference) ([]*light.Block, error) {
	if path == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range path {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "path")
}

func blocksToPathItemOrReferenceMap(blocks []*light.Block) (map[string]*PathItemOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*PathItemOrReference)
	for _, block := range blocks {
		able, err := pathItemOrReferenceFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Type] = able
	}

	return hash, nil
}
*/
/*
func tupleConsExprToAble(expr *light.Expression, fromHCL func(*light.ObjectConsExpr) (AbleHCL, error)) ([]AbleHCL, error) {
	if expr == nil {
		return nil, nil
	}
	if expr.GetTcexpr() == nil {
		return nil, nil
	}
	exprs := expr.GetTcexpr().Exprs
	if len(exprs) == 0 {
		return nil, nil
	}

	var items []AbleHCL
	for _, expr := range exprs {
		item, err := fromHCL(expr.GetOcexpr())
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, nil
}

func ableMapToBlocks(hash map[string]AbleHCL, label string) ([]*light.Block, error) {
	if hash == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range hash {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   label,
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}
*/
