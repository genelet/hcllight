// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

package gno

import (
	"errors"
	"fmt"
	"regexp"
	"strings"

	"github.com/genelet/determined/dethcl"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
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
	Provider    Provider              `yaml:"provider" hcl:"provider,block"`
	Resources   map[string]Resource   `yaml:"resources" hcl:"resources,block"`
	DataSources map[string]DataSource `yaml:"data_sources" hcl:"data_sources,block"`
	document    *openapiv3.Document
}

// Provider generator config section.
type Provider struct {
	Name      string `yaml:"name" hcl:"name"`
	SchemaRef string `yaml:"schema_ref" hcl:"schema_ref,optional"`

	// TODO: At some point, this should probably be refactored to work with the SchemaOptions struct
	// Ignores are a slice of strings, representing an attribute location to ignore during mapping (dot-separated for nested attributes).
	Ignores []string `yaml:"ignores" hcl:"ignores,optional"`
}

// Resource generator config section.
type Resource struct {
	Create        *OpenApiSpecLocation `yaml:"create" hcl:"create,block"`
	Read          *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	Update        *OpenApiSpecLocation `yaml:"update" hcl:"update,block"`
	Delete        *OpenApiSpecLocation `yaml:"delete" hcl:"delete,block"`
	SchemaOptions SchemaOptions        `yaml:"schema" hcl:"schema,block"`
}

// DataSource generator config section.
type DataSource struct {
	Read          *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	SchemaOptions SchemaOptions        `yaml:"schema" hcl:"schema,block"`
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
	Method string               `yaml:"method" hcl:"method"`
	Detail *openapiv3.Operation `yaml:"detail" hcl:"detail,block"`
}

// ParseConfig takes in a byte array, unmarshals into a Config struct, and validates the result.
// By default the byte array is assumed to be HCL, but if data_type is "yaml" or "yml", it will be unmarshaled as YAML.
func ParseConfig(bytes []byte, data_type ...string) (*Config, error) {
	var result Config
	var has_result bool
	if data_type != nil {
		t := strings.ToLower(data_type[0])
		if t == "yaml" || t == "yml" {
			err := yaml.Unmarshal(bytes, &result)
			if err != nil {
				return nil, fmt.Errorf("error unmarshaling config: %w", err)
			}
			has_result = true
		}
	}
	if !has_result {
		err := dethcl.Unmarshal(bytes, &result)
		if err != nil {
			return nil, fmt.Errorf("error unmarshaling config: %w", err)
		}
	}

	if err := result.Validate(); err != nil {
		return nil, fmt.Errorf("config validation error(s):\n%w", err)
	}

	return &result, nil
}

func (c Config) Validate() error {
	var result error

	if len(c.DataSources) == 0 && len(c.Resources) == 0 {
		result = errors.Join(result, errors.New("\tat least one object is required in either 'resources' or 'data_sources'"))
	}

	// Validate Provider
	err := c.Provider.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("\tprovider %w", err))
	}

	// Validate all Resources
	for name, resource := range c.Resources {
		err := resource.Validate()
		if err != nil {
			result = errors.Join(result, fmt.Errorf("\tresource '%s' %w", name, err))
		}
	}

	// Validate all Data Sources
	for name, dataSource := range c.DataSources {
		err := dataSource.Validate()
		if err != nil {
			result = errors.Join(result, fmt.Errorf("\tdata_source '%s' %w", name, err))
		}
	}

	return result
}

func (p Provider) Validate() error {
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

func (r Resource) Validate() error {
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

func (d DataSource) Validate() error {
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
	var result error
	if o == nil {
		return nil
	}

	if o.Path == "" {
		result = errors.Join(result, errors.New("'path' property is required"))
	}

	if o.Method == "" {
		result = errors.Join(result, errors.New("'method' property is required"))
	}

	return result
}

func (self *Config) ParseDocument(data []byte) error {
	doc, err := openapiv3.ParseDocument(data)
	if err != nil {
		return err
	}
	self.document = doc

	paths := doc.Paths
	if paths == nil || len(paths.Path) == 0 {
		return fmt.Errorf("no paths found in OpenAPI document")
	}
	for _, namedPathItem := range paths.Path {
		name := namedPathItem.Name
		pathItem := namedPathItem.Value
		self.addToResources(name, pathItem)
		self.addToDataSources(name, pathItem)
	}
	return nil
}

func (self *Config) addToResources(name string, pathItem *openapiv3.PathItem) {
	for k, v := range self.Resources {
		if v.Create != nil && v.Create.Path == name && pathItem.Post != nil {
			self.Resources[k].Create.Detail = v.SchemaOptions.filter(pathItem.Post)
		}
		if v.Read != nil && v.Read.Path == name && pathItem.Get != nil {
			self.Resources[k].Read.Detail = v.SchemaOptions.filter(pathItem.Get)
		}
		if v.Update != nil && v.Update.Path == name && pathItem.Put != nil {
			self.Resources[k].Update.Detail = v.SchemaOptions.filter(pathItem.Put)
		}
		if v.Delete != nil && v.Delete.Path == name && pathItem.Delete != nil {
			self.Resources[k].Delete.Detail = v.SchemaOptions.filter(pathItem.Delete)
		}
	}
}

func (self *Config) addToDataSources(name string, pathItem *openapiv3.PathItem) {
	for k, v := range self.DataSources {
		if v.Read != nil && v.Read.Path == name && pathItem.Get != nil {
			self.DataSources[k].Read.Detail = v.SchemaOptions.filter(pathItem.Get)
		}
	}
}
