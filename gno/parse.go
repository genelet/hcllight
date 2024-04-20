// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//
// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

package gno

import (
	"errors"
	"fmt"
	"regexp"
)

// This regex matches attribute locations, dot-separated, as represented as {attribute_name}.{nested_attribute_name}
//   - category = MATCH
//   - category.id = MATCH
//   - category.tags.name = MATCH
//   - category. = NO MATCH
//   - .category = NO MATCH
var attributeLocationRegex = regexp.MustCompile(`^[\w]+(?:\.[\w]+)*$`)

// OpenApiSpecLocation defines a location in an OpenAPI spec for an API operation.
type OpenApiSpecLocation struct {
	// Matches the path key for a path item (refer to [OAS Paths Object]).
	//
	// [OAS Paths Object]: https://spec.openapis.org/oas/v3.1.0#paths-object
	Path string `yaml:"path" hcl:"path"`
	// Matches the operation method in a path item: GET, POST, etc (refer to [OAS Path Item Object]).
	//
	// [OAS Path Item Object]: https://spec.openapis.org/oas/v3.1.0#pathItemObject
	Method string `yaml:"method" hcl:"method"`
}

// SchemaOptions generator config section. This section contains options for modifying the output of the generator.
type SchemaOptions struct {
	// Ignores are a slice of strings, representing an attribute location to ignore during mapping (dot-separated for nested attributes).
	Ignores          []string `yaml:"ignores" hcl:"ignores,optional"`
	AttributeOptions `yaml:"attributes" hcl:"attributes,block"`
}

// AttributeOptions generator config section. This section is used to modify the output of specific attributes.
type AttributeOptions struct {
	// Aliases are a map, with the key being a parameter name in an OpenAPI operation and the value being the new name (alias).
	Aliases map[string]string `yaml:"aliases" hcl:"aliases,optional"`
	// Overrides are a map, with the key being an attribute location (dot-separated for nested attributes) and the value being overrides to apply to the attribute.
	Overrides map[string]*Override `yaml:"overrides" hcl:"overrides,block"`
}

// Override generator config section.
type Override struct {
	// Description overrides the description that was mapped/merged from the OpenAPI specification.
	Description string `yaml:"description" hcl:"description,optional"`
}

func (o *OpenApiSpecLocation) Validate() error {
	if o == nil {
		return nil
	}

	var result error

	if o.Path == "" {
		result = errors.Join(result, errors.New("'path' property is required"))
	}

	if o.Method == "" {
		result = errors.Join(result, errors.New("'method' property is required"))
	}

	return result
}

func (s *SchemaOptions) Validate() error {
	if s == nil {
		return nil
	}

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
	if s == nil {
		return nil
	}

	var result error

	for path := range s.Overrides {
		if !attributeLocationRegex.MatchString(path) {
			result = errors.Join(result, fmt.Errorf("invalid key for override: %q - must be dot-separated string", path))
		}
	}

	return result
}
