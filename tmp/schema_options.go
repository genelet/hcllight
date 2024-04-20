// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

package gno

import (
	"errors"
	"fmt"

	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

// SchemaOptions generator config section. This section contains options for modifying the output of the generator.
type SchemaOptions struct {
	// Ignores are a slice of strings, representing an attribute location to ignore during mapping (dot-separated for nested attributes).
	Ignores          []string         `yaml:"ignores" hcl:"ignores,optional"`
	AttributeOptions AttributeOptions `yaml:"attributes" hcl:"attributes,block"`
}

// AttributeOptions generator config section. This section is used to modify the output of specific attributes.
type AttributeOptions struct {
	// Aliases are a map, with the key being a parameter name in an OpenAPI operation and the value being the new name (alias).
	Aliases map[string]string `yaml:"aliases" hcl:"aliases,optional"`
	// Overrides are a map, with the key being an attribute location (dot-separated for nested attributes) and the value being overrides to apply to the attribute.
	Overrides map[string]Override `yaml:"overrides" hcl:"overrides,block"`
}

// Override generator config section.
type Override struct {
	// Description overrides the description that was mapped/merged from the OpenAPI specification.
	Description string `yaml:"description" hcl:"description,optional"`
}

func (s *SchemaOptions) Validate() error {
	var result error

	err := s.AttributeOptions.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid attributes: %w", err))
	}

	for _, ignore := range s.Ignores {
		if !attributeLocationRegex.MatchString(ignore) {
			result = errors.Join(result, fmt.Errorf("invalid item for ignores: %q - must be dot-separated string", ignore))
		}
	}

	return result
}

func (s *AttributeOptions) Validate() error {
	var result error

	for path := range s.Overrides {
		if !attributeLocationRegex.MatchString(path) {
			result = errors.Join(result, fmt.Errorf("invalid key for override: %q - must be dot-separated string", path))
		}
	}

	return result
}

func ifIgnoreInParameterOrReference(ignore string, p *openapiv3.ParameterOrReference) bool {
	if x := p.GetParameter(); x != nil {
		return x.Name == ignore
	}
	if x := p.GetReference(); x != nil {
	}

	return false
}

func replaceName(orig, aliase string, p *openapiv3.ParameterOrReference) {
	if x := p.GetParameter(); x != nil {
		if x.Name == orig {
			x.Name = aliase
		}
		p.Oneof = &openapiv3.ParameterOrReference_Parameter{Parameter: x}
	}
}

func overrideAttribute(orig, override string, p *openapiv3.ParameterOrReference) {
	if x := p.GetParameter(); x != nil {
		if x.Name == orig {
			x.Description = override
		}
		p.Oneof = &openapiv3.ParameterOrReference_Parameter{Parameter: x}
	}
}

func (self SchemaOptions) filter(op *openapiv3.Operation) *openapiv3.Operation {
	var parameters []*openapiv3.ParameterOrReference
	for _, p := range op.Parameters {
		var found bool
		for _, param := range self.Ignores {
			if ifIgnoreInParameterOrReference(param, p) {
				found = true
				break
			}
		}
		if found {
			continue
		}
		for orig, aliase := range self.AttributeOptions.Aliases {
			replaceName(orig, aliase, p)
		}
		for orig, override := range self.AttributeOptions.Overrides {
			overrideAttribute(orig, override.Description, p)
		}
		parameters = append(parameters, p)
	}

	op.Parameters = parameters
	return op
}
