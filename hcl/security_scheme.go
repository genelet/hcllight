package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *SecuritySchemeOrReference) getAble() ableHCL {
	return self.GetSecurityScheme()
}

func (self *SecurityScheme) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *SecurityScheme) UnmarshalHCL(bs []byte, labels ...string) error {
	body, err := light.ParseBody(bs)
	if err != nil {
		return err
	}
	securityScheme, err := securitySchemeFromHCL(body)
	if err != nil {
		return err
	}

	if securityScheme != nil {
		self.BearerFormat = securityScheme.BearerFormat
		self.Description = securityScheme.Description
		self.Flows = securityScheme.Flows
		self.In = securityScheme.In
		self.Name = securityScheme.Name
		self.OpenIdConnectUrl = securityScheme.OpenIdConnectUrl
		self.Scheme = securityScheme.Scheme
		self.SpecificationExtension = securityScheme.SpecificationExtension
		self.Type = securityScheme.Type
	}
	return nil
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
				Expr: light.StringToTextValueExpr(v),
			}
		}
	}
	if err := addSpecification(self.SpecificationExtension, &blocks); err != nil {
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
			self.Type = *light.TextValueExprToString(v.Expr)
			found = true
		} else if k == "description" {
			self.Description = *light.TextValueExprToString(v.Expr)
			found = true
		} else if k == "name" {
			self.Name = *light.TextValueExprToString(v.Expr)
			found = true
		} else if k == "in" {
			self.In = *light.TextValueExprToString(v.Expr)
			found = true
		} else if k == "scheme" {
			self.Scheme = *light.TextValueExprToString(v.Expr)
			found = true
		} else if k == "bearerFormat" {
			self.BearerFormat = *light.TextValueExprToString(v.Expr)
			found = true
		} else if k == "openIdConnectUrl" {
			self.OpenIdConnectUrl = *light.TextValueExprToString(v.Expr)
			found = true
		}
	}
	for _, block := range body.Blocks {
		switch block.Type {
		case "flows":
			blk, err := flowsFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			self.Flows = blk
			found = true
		}
	}
	self.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	} else if self.SpecificationExtension != nil {
		found = true
	}

	if found {
		return self, nil
	}
	return nil, nil
}

func securitySchemeOrReferenceMapToBlocks(securitySchemes map[string]*SecuritySchemeOrReference, names ...string) ([]*light.Block, error) {
	if securitySchemes == nil {
		return nil, nil
	}

	hash := make(map[string]orHCL)
	for k, v := range securitySchemes {
		hash[k] = v
	}
	return orMapToBlocks(hash, names...)
}

func blocksToSecuritySchemeOrReferenceMap(blocks []*light.Block, names ...string) (map[string]*SecuritySchemeOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, func(reference *Reference) orHCL {
		return &SecuritySchemeOrReference{
			Oneof: &SecuritySchemeOrReference_Reference{
				Reference: reference,
			},
		}
	}, func(body *light.Body) (orHCL, error) {
		securityScheme, err := securitySchemeFromHCL(body)
		if err != nil {
			return nil, err
		}
		if securityScheme != nil {
			return &SecuritySchemeOrReference{
				Oneof: &SecuritySchemeOrReference_SecurityScheme{
					SecurityScheme: securityScheme,
				},
			}, nil
		}
		return nil, nil
	}, names...)
	if err != nil {
		return nil, err
	}

	if orMap == nil {
		return nil, nil
	}

	hash := make(map[string]*SecuritySchemeOrReference)
	for k, v := range orMap {
		hash[k] = v.(*SecuritySchemeOrReference)
	}

	return hash, nil
}
