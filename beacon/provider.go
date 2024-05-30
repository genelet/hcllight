// Copyright (c) Greetingland LLC
// MIT License
package beacon

import (
	"github.com/genelet/hcllight/light"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

type GnoProvider struct {
	Name        string                       `hcl:"name"`
	SchemaProxy *openapiv3.SchemaOrReference `hcl:"schema_proxy,block"`
	SchemaOptions
}

func NewGnoProvider(p *Provider, doc *openapiv3.Document) (*GnoProvider, error) {
	gp := &GnoProvider{
		Name:          p.Name,
		SchemaOptions: p.SchemaOptions,
	}

	if doc != nil && doc.Components != nil && doc.Components.Schemas != nil {
		for _, item := range doc.Components.Schemas.AdditionalProperties {
			if item.Name == p.SchemaRef {
				gp.SchemaProxy = item.Value
				return gp, nil
			}
		}
	}

	return gp, nil
}

func (self *GnoProvider) blockProvider(c *GnoConfig) (*light.Block, error) {
	block := &light.Block{
		Type:   "provider",
		Labels: []string{self.Name},
		Bdy:    new(light.Body),
	}

	if self.SchemaProxy != nil {
		expr, err := c.exprSchemaOrReference(self.SchemaProxy)
		if err != nil {
			return nil, err
		}

		block.Bdy = &light.Body{
			Attributes: map[string]*light.Attribute{
				"schema_proxy": {
					Expr: expr,
				},
			},
		}

	}

	return block, nil
}
