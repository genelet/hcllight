package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *PathItemOrReference) toExpression() (*light.Expression, error) {
	switch self.Oneof.(type) {
	case *PathItemOrReference_Item:
		body, err := self.GetItem().toHCL()
		if err != nil {
			return nil, err
		}
		return &light.Expression{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: body.ToObjectConsExpr(),
			},
		}, nil
	case *PathItemOrReference_Reference:
		return self.GetReference().toExpression()
	default:
	}
	return nil, nil
}

func expressionToPathItemOrReference(expr *light.Expression) (*PathItemOrReference, error) {
	if expr == nil {
		return nil, nil
	}

	switch expr.ExpressionClause.(type) {
	case *light.Expression_Ocexpr:
		body := expr.GetOcexpr().ToBody()
		item, err := pathItemFromHCL(body)
		if err != nil {
			return nil, err
		}
		return &PathItemOrReference{
			Oneof: &PathItemOrReference_Item{
				Item: item,
			},
		}, nil
	default:
	}

	reference, err := expressionToReference(expr)
	return &PathItemOrReference{
		Oneof: &PathItemOrReference_Reference{
			Reference: reference,
		},
	}, err
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
	if paths == nil || len(paths) == 0 {
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
			hash := item.toOperationMap()
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
			return nil, ErrInvalidType(block)
		}
		method := block.Labels[0]
		switch method {
		case "get", "put", "post", "delete", "options", "head", "patch", "trace", "common":
			if _, ok := hash2[method]; !ok {
				hash2[method] = make(map[string]*Operation)
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
