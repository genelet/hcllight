package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *SecuritySchemeOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *SecuritySchemeOrReference_SecurityScheme:
		return self.GetSecurityScheme().toHCL()
	case *SecuritySchemeOrReference_Reference:
		return self.GetReference().toHCL()
	default:
	}
	return nil, nil
}

func securitySchemeOrReferenceFromHCL(body *light.Body) (*SecuritySchemeOrReference, error) {
	if body == nil {
		return nil, nil
	}

	reference, err := referenceFromHCL(body)
	if err != nil {
		return nil, err
	}
	if reference != nil {
		return &SecuritySchemeOrReference{
			Oneof: &SecuritySchemeOrReference_Reference{
				Reference: reference,
			},
		}, nil
	}

	securityScheme, err := securitySchemeFromHCL(body)
	if err != nil {
		return nil, err
	}
	if securityScheme == nil {
		return nil, nil
	}
	return &SecuritySchemeOrReference{
		Oneof: &SecuritySchemeOrReference_SecurityScheme{
			SecurityScheme: securityScheme,
		},
	}, nil
}

func (self *SecurityScheme) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"type":             self.Type,
		"description":      self.Description,
		"name":             self.Name,
		"in":               self.In,
		"scheme":           self.Scheme,
		"bearerFormat":     self.BearerFormat,
		"openIdConnectUrl": self.OpenIdConnectUrl,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if err := addSpecificationBlock(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
	}

	if self.Flows != nil {
		blk, err := self.Flows.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "flows",
			Bdy:  blk,
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

func securitySchemeFromHCL(body *light.Body) (*SecurityScheme, error) {
	if body == nil {
		return nil, nil
	}

	self := &SecurityScheme{}
	var found bool
	var err error
	for k, v := range body.Attributes {
		if k == "type" {
			self.Type = *textValueExprToString(v.Expr)
			found = true
		} else if k == "description" {
			self.Description = *textValueExprToString(v.Expr)
			found = true
		} else if k == "name" {
			self.Name = *textValueExprToString(v.Expr)
			found = true
		} else if k == "in" {
			self.In = *textValueExprToString(v.Expr)
			found = true
		} else if k == "scheme" {
			self.Scheme = *textValueExprToString(v.Expr)
			found = true
		} else if k == "bearerFormat" {
			self.BearerFormat = *textValueExprToString(v.Expr)
			found = true
		} else if k == "openIdConnectUrl" {
			self.OpenIdConnectUrl = *textValueExprToString(v.Expr)
			found = true
		}
	}
	for _, block := range body.Blocks {
		switch block.Type {
		case "SpecificationExtension":
			self.SpecificationExtension, err = bodyToAnyMap(block.Bdy)
			if err != nil {
				return nil, err
			}
			found = true
		case "flows":
			blk, err := flowsFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			self.Flows = blk
			found = true
		}
	}

	if found {
		return self, nil
	}
	return nil, nil
}

func securitySchemeOrReferenceMapToBlocks(securitySchemes map[string]*SecuritySchemeOrReference) ([]*light.Block, error) {
	if securitySchemes == nil {
		return nil, nil
	}
	hash := make(map[string]ableHCL)
	for k, v := range securitySchemes {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "securityScheme")
}

func blocksToSecuritySchemeOrReferenceMap(blocks []*light.Block) (map[string]*SecuritySchemeOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*SecuritySchemeOrReference)
	for _, block := range blocks {
		able, err := securitySchemeOrReferenceFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}
