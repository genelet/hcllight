// Copyright (c) Greetingland LLC
// MIT License
package gno

import (
	"github.com/genelet/hcllight/generated"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

type GnoProvider struct {
	Name        string                       `hcl:"name"`
	SchemaProxy *openapiv3.SchemaOrReference `hcl:"schema_proxy,block"`
	SchemaOptions
}

func (self *Provider) NewGnoProvider(doc *openapiv3.Document) (*GnoProvider, error) {
	gp := &GnoProvider{
		Name:          self.Name,
		SchemaOptions: self.SchemaOptions,
	}

	if doc != nil && doc.Components != nil && doc.Components.Schemas != nil {
		for _, item := range doc.Components.Schemas.AdditionalProperties {
			if item.Name == self.SchemaRef {
				gp.SchemaProxy = item.Value
				return gp, nil
			}
		}
	}

	return gp, nil
}

func (self *GnoProvider) buildProvider() (*generated.Block, error) {
	block := &generated.Block{
		Type:   "provider",
		Labels: []string{self.Name},
		Bdy:    new(generated.Body),
	}

	if self.SchemaProxy != nil {
		expr, err := exprSchemaOrReference(self.SchemaProxy)
		if err != nil {
			return nil, err
		}

		block.Bdy = &generated.Body{
			Attributes: map[string]*generated.Attribute{
				"schema_proxy": {
					Expr: expr,
				},
			},
		}

	}

	return block, nil
}
