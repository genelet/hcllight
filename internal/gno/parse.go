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
	"strings"

	"github.com/genelet/determined/dethcl"
	"gopkg.in/yaml.v3"
)

// This regex matches attribute locations, dot-separated, as represented as {attribute_name}.{nested_attribute_name}
//   - category = MATCH
//   - category.id = MATCH
//   - category.tags.name = MATCH
//   - category. = NO MATCH
//   - .category = NO MATCH
var attributeLocationRegex = regexp.MustCompile(`^[\w]+(?:\.[\w]+)*$`)

// Config represents a YAML generator config.
type Config struct {
	Provider    `yaml:"provider" hcl:"provider,block"`
	Resources   map[string]*Resource   `yaml:"resources" hcl:"resources,block"`
	DataSources map[string]*DataSource `yaml:"data_sources" hcl:"data_sources,block"`
}

// Provider generator config section.
type Provider struct {
	Name          string `yaml:"name" hcl:"name"`
	SchemaRef     string `yaml:"schema_ref" hcl:"schema_ref,optional"`
	SchemaOptions `yaml:"schema" hcl:"schema,block"`
}

// Resource generator config section.
type Resource struct {
	Create         *OpenApiSpecLocation `yaml:"create" hcl:"create,block"`
	Read           *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	Update         *OpenApiSpecLocation `yaml:"update" hcl:"update,block"`
	Delete         *OpenApiSpecLocation `yaml:"delete" hcl:"delete,block"`
	*SchemaOptions `yaml:"schema" hcl:"schema,block"`
}

// DataSource generator config section.
type DataSource struct {
	/* private start
	    *
	   The generator uses the read operation to map to the provider code specification. Multiple schemas will have the OAS types mapped to Provider Attributes and then be merged together; with the final result being the Data Source schema. The schemas that will be merged together (in priority order):

	   1. read operation: parameters
	    - The generator will merge all query and path parameters to the root of the schema.
	    - The generator will consider as parameters the ones in the Path Item Object and the ones in the Operation Object, merged based on the rules in the specification
	   2. read operation: response body in responses
	    - The response body is the only schema required for data sources. If not found, the generator will skip the data source without mapping.
	    - Will attempt to use 200 or 201 response body. If not found, will grab the first available 2xx response code with a schema (lexicographic order)
	    - Will attempt to use application/json content-type first. If not found, will grab the first available content-type with a schema (alphabetical order)

	    * private end
	*/
	Read           *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	*SchemaOptions `yaml:"schema" hcl:"schema,block"`
}

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

// ParseConfig takes in a byte array, unmarshals into a Config struct, and validates the result
// By default the byte array is assumed to be YAML, but if data_type is "hcl" or "tf", it will be unmarshaled as HCL
func ParseConfig(bytes []byte, data_type ...string) (*Config, error) {
	var result Config
	var typ string
	var err error
	if data_type != nil {
		typ = strings.ToLower(data_type[0])
	}
	if typ == "hcl" || typ == "tf" {
		err = dethcl.Unmarshal(bytes, &result)
	} else {
		err = yaml.Unmarshal(bytes, &result)
	}
	if err != nil {
		return nil, fmt.Errorf("error unmarshaling config: %w", err)
	}
	if err = result.Validate(); err != nil {
		return nil, fmt.Errorf("config validation error(s): %w", err)
	}

	return &result, nil
}

func (self *Config) Validate() error {
	if self == nil {
		return errors.New("config is nil")
	}

	var result error

	if (self.DataSources == nil || len(self.DataSources) == 0) && (self.Resources == nil || len(self.Resources) == 0) {
		result = errors.Join(result, fmt.Errorf("\t%s", "at least one object is required in either 'resources' or 'data_sources'"))
	}

	// Validate Provider
	err := self.Provider.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("\tprovider %w", err))
	}

	// Validate all Resources
	for name, resource := range self.Resources {
		err := resource.Validate()
		if err != nil {
			result = errors.Join(result, fmt.Errorf("\tresource '%s' %w", name, err))
		}
	}

	// Validate all Data Sources
	for name, dataSource := range self.DataSources {
		err := dataSource.Validate()
		if err != nil {
			result = errors.Join(result, fmt.Errorf("\tdata_source '%s' %w", name, err))
		}
	}

	return result
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

func (r *Resource) Validate() error {
	if r == nil {
		return errors.New("resource is nil")
	}

	var result error

	if r.Create == nil {
		result = errors.Join(result, errors.New("must have a create object"))
	}
	if r.Read == nil {
		result = errors.Join(result, errors.New("must have a read object"))
	}

	err := r.Create.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid create: %w", err))
	}

	err = r.Read.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid read: %w", err))
	}

	err = r.Update.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid update: %w", err))
	}

	err = r.Delete.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid delete: %w", err))
	}

	err = r.SchemaOptions.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid schema: %w", err))
	}

	return result
}

func (d *DataSource) Validate() error {
	if d == nil {
		return errors.New("data source is nil")
	}

	var result error

	if d.Read == nil {
		result = errors.Join(result, errors.New("must have a read object"))
	}

	err := d.Read.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid read: %w", err))
	}

	err = d.SchemaOptions.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid schema: %w", err))
	}

	return result
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
