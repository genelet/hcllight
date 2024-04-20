// Copyright (c) Greetingland LLC
// MIT License
package config

import (
	"errors"
	"fmt"

	"github.com/genelet/hcllight/generated"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

// Provider generator config section.
type Provider struct {
	Name          string `yaml:"name" hcl:"name"`
	SchemaRef     string `yaml:"schema_ref" hcl:"schema_ref,optional"`
	SchemaOptions `yaml:"schema" hcl:"schema,block"`
}

func (p *Provider) Validate() error {
	if p == nil {
		return errors.New("provider is nil")
	}

	var result error

	if p.Name == "" {
		result = errors.Join(result, errors.New("must have a 'name' property"))
	}

	for _, ignore := range p.Ignores {
		if !attributeLocationRegex.MatchString(ignore) {
			result = errors.Join(result, fmt.Errorf("invalid item for ignores: %q - must be dot-separated string", ignore))
		}
	}

	return result
}

type GnoProvider struct {
	Name        string                       `hcl:"name"`
	SchemaProxy *openapiv3.SchemaOrReference `hcl:"schema_proxy,block"`
	SchemaOptions
}

func (self *Provider) BuildGnoProvider(doc *openapiv3.Document) (*GnoProvider, error) {
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

func (self *Provider) GetIgnores() []string {
	return self.Ignores
}

func (self *GnoConfig) buildProvider() (*generated.Block, error) {
	p := self.GnoProvider
	block := &generated.Block{
		Type:   "provider",
		Labels: []string{p.Name},
		Bdy:    new(generated.Body),
	}

	if p.SchemaProxy != nil {
		expr, body, err := self.exprBodySchemaOrReference(p.SchemaProxy)
		if err != nil {
			return nil, err
		}
		if expr != nil {
			block.Bdy = &generated.Body{
				Attributes: map[string]*generated.Attribute{
					"schema_proxy": {
						Expr: expr,
					},
				},
			}
		} else {
			block.Labels = append(block.Labels, "schema_proxy")
			block.Bdy = body
		}
	}

	return block, nil
}

func (self *GnoConfig) blockSchemas() (*generated.Block, error) {
	var attributes map[string]*generated.Attribute
	var blocks []*generated.Block
	for name, schema := range self.Schemas {
		expr, body, err := self.exprBodySchemaOrReference(schema)
		if err != nil {
			return nil, err
		}
		if expr != nil {
			if attributes == nil {
				attributes = make(map[string]*generated.Attribute)
			}
			attributes[name] = &generated.Attribute{
				Name: name,
				Expr: expr,
			}
		} else {
			blocks = appendBlock(blocks, name, body)
		}
	}

	return &generated.Block{
		Type:   "variables",
		Labels: []string{"schemas"},
		Bdy: &generated.Body{
			Attributes: attributes,
			Blocks:     blocks,
		},
	}, nil
}

func (self *GnoConfig) blockParameters() (*generated.Block, error) {
	//	var attributes map[string]*generated.Attribute
	var blocks []*generated.Block
	for name, parameter := range self.Parameters {
		str, expr, body, err := self.nameExprBodyParameterOrReference(parameter)
		if err != nil {
			return nil, err
		}
		if expr != nil {
			body = simpleBody(str, expr)
		}
		blocks = appendBlock(blocks, name, body)
	}

	return &generated.Block{
		Type:   "variables",
		Labels: []string{"parameters"},
		Bdy: &generated.Body{
			Blocks: blocks,
		},
	}, nil
}

func (self *GnoConfig) blockRequestBodies() (*generated.Block, error) {
	var attributes map[string]*generated.Attribute
	var blocks []*generated.Block
	for name, requestBody := range self.RequestBodies {
		expr, body, err := self.exprBodyRequestBodyOrReference(requestBody)
		if err != nil {
			return nil, err
		}
		if expr != nil {
			if attributes == nil {
				attributes = make(map[string]*generated.Attribute)
			}
			attributes[name] = &generated.Attribute{
				Name: name,
				Expr: expr,
			}
		} else {
			blocks = appendBlock(blocks, name, body)
		}
	}

	return &generated.Block{
		Type:   "variables",
		Labels: []string{"request_bodies"},
		Bdy: &generated.Body{
			Attributes: attributes,
			Blocks:     blocks,
		},
	}, nil
}
