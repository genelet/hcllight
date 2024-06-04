// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//

package beacon

import (
	"github.com/genelet/determined/dethcl"
	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
)

// SchemaOptions contains options for modifying the output of the generator.
type SchemaOptions struct {
	// Ignores are a slice of strings, representing an attribute location to ignore during mapping (dot-separated for nested attributes).
	Ignores          []string `yaml:"ignores" hcl:"ignores,optional"`
	AttributeOptions `yaml:"attributes" hcl:"attributes,block"`
}

// AttributeOptions is used to modify the output of specific attributes.
type AttributeOptions struct {
	// Aliases are a map, with the key being a parameter name in an OpenAPI operation and the value being the new name (alias).
	Aliases map[string]string `yaml:"aliases" hcl:"aliases,optional"`
	// Overrides are a map, with the key being an attribute location (dot-separated for nested attributes) and the value being overrides to apply to the attribute.
	Overrides map[string]*Override `yaml:"overrides" hcl:"overrides,block"`
}

type Override struct {
	// Description overrides the description that was mapped/merged from the OpenAPI specification.
	Description string `yaml:"description" hcl:"description,optional"`
}

func (self *SchemaOptions) ToBody() (*light.Body, error) {
	bs, err := dethcl.Marshal(self)
	if err != nil {
		return nil, err
	}
	return light.Parse(bs)
}

func ignoreBody(body *light.Body, so *SchemaOptions) *light.Body {
	if body == nil || so == nil {
		return body
	}

	ignores := so.Ignores
	aliases := so.Aliases
	//overrides := so.Overrides

	var blocks []*light.Block
	for _, block := range body.Blocks {
		if grep(ignores, block.Type) {
			continue
		}
		if aliases != nil {
			if u, ok := aliases[block.Type]; ok {
				block.Type = u
			}
		}
		blocks = append(blocks, block)
	}
	var attributes map[string]*light.Attribute
	if body.Attributes != nil {
		attributes = make(map[string]*light.Attribute)
		for k, v := range body.Attributes {
			if grep(ignores, k) {
				continue
			}
			if aliases != nil {
				if u, ok := aliases[k]; ok {
					k = u
				}
			}
			attributes[k] = v
		}
	}

	bdy := &light.Body{
		Blocks: blocks,
	}
	if len(attributes) > 0 {
		bdy.Attributes = attributes
	}
	return bdy
}

func ignoreSchemaOrReferenceMap(schemaMap map[string]*hcl.SchemaOrReference, so *SchemaOptions) map[string]*hcl.SchemaOrReference {
	if schemaMap == nil || so == nil {
		return schemaMap
	}

	ignores := so.Ignores
	aliases := so.Aliases
	//overrides := so.Overrides

	hash := make(map[string]*hcl.SchemaOrReference)
	for k, v := range schemaMap {
		if grep(ignores, k) {
			continue
		}
		if aliases != nil {
			if u, ok := aliases[k]; ok {
				k = u
			}
		}
		hash[k] = v
	}
	if len(hash) == 0 {
		return nil
	}
	return hash
}

func grep(names []string, name string) bool {
	for _, n := range names {
		if n == name {
			return true
		}
	}
	return false
}
