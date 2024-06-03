// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//
// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

package beacon

import (
	"fmt"
	"regexp"
	"strings"

	"github.com/genelet/determined/dethcl"
	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
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
	doc    *hcl.Document
	how    string
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
	var result *Config
	var typ string
	var err error
	if data_type != nil {
		typ = strings.ToLower(data_type[0])
	}
	if typ == "yml" || typ == "yaml" {
		err = yaml.Unmarshal(bytes, &result)
	} else {
		err = dethcl.Unmarshal(bytes, &result)
	}
	if err != nil {
		return nil, err
	}
	if len(result.DataSources) == 0 && len(result.Resources) == 0 {
		return nil, fmt.Errorf("at least one object is required in 'resources' or 'data_sources'")
	}
	return result, nil
}

func (self *OpenApiSpecLocation) SetDocument(doc *hcl.Document) {
	self.doc = doc
}

func (self *OpenApiSpecLocation) GetDocument() *hcl.Document {
	return self.doc
}

func (self *OpenApiSpecLocation) SetHow(how string) {
	self.how = how
}

func (self *OpenApiSpecLocation) GetHow() string {
	return self.how
}

func (self *OpenApiSpecLocation) GetPath() *hcl.PathItem {
	hash := self.doc.GetPaths()
	if len(hash) == 0 {
		return nil
	}
	pathOrReference, ok := hash[self.Path]
	if !ok {
		return nil
	}
	switch pathOrReference.Oneof.(type) {
	case *hcl.PathItemOrReference_Item:
		return pathOrReference.GetItem()
	case *hcl.PathItemOrReference_Reference:
	default:
	}
	return nil
}

func (self *OpenApiSpecLocation) GetOperation(common ...bool) *hcl.Operation {
	path := self.GetPath()
	if path == nil {
		return nil
	}
	hash := path.ToOperationMap()

	if len(common) > 0 && common[0] {
		return hash["common"]
	}

	for k, v := range hash {
		if k == self.Method {
			return v
		}
	}
	return nil
}

func (self *OpenApiSpecLocation) getRequestBody() (*hcl.RequestBody, error) {
	operation := self.GetOperation()
	if operation == nil {
		return nil, nil
	}

	var rb *hcl.RequestBody
	var err error
	switch operation.RequestBody.Oneof.(type) {
	case *hcl.RequestBodyOrReference_Reference:
		reference := operation.RequestBody.GetReference()
		rb, err = self.doc.ResolveRequestBodyOrReference(reference)
		if err != nil {
			return nil, err
		}
	default:
		rb = operation.RequestBody.GetRequestBody()
	}
	return rb, nil
}

func (self *OpenApiSpecLocation) getResponseBody() (*hcl.Response, error) {
	operation := self.GetOperation()
	if operation == nil {
		return nil, nil
	}

	var rb, first *hcl.Response
	var err error
	for k, v := range operation.Responses {
		switch v.Oneof.(type) {
		case *hcl.ResponseOrReference_Reference:
			reference := v.GetReference()
			rb, err = self.doc.ResolveReponseOrReference(reference)
			if err != nil {
				return nil, err
			}
		default:
			rb = v.GetResponse()
		}
		if first == nil {
			first = rb
		}
		if k == "200" || k == "201" {
			return rb, nil
		}
	}

	return first, nil
}

func parametersFromOperation(doc *hcl.Document, operation *hcl.Operation) ([]*hcl.Parameter, error) {
	var parameters []*hcl.Parameter
	for _, v := range operation.Parameters {
		var parameter *hcl.Parameter
		var err error
		switch v.Oneof.(type) {
		case *hcl.ParameterOrReference_Reference:
			reference := v.GetReference()
			parameter, err = doc.ResolveParameterOrReference(reference)
		default:
			parameter = v.GetParameter()
		}
		if err != nil {
			return nil, err
		}
		if parameter.In == "query" || parameter.In == "path" {
			parameters = append(parameters, parameter)
		}
	}
	return parameters, nil
}

func (self *OpenApiSpecLocation) getParameters() ([]*hcl.Parameter, error) {
	operation := self.GetOperation()
	if operation == nil {
		return nil, nil
	}

	parameters, err := parametersFromOperation(self.doc, operation)
	if err != nil {
		return nil, err
	}

	operation = self.GetOperation(true)
	if operation == nil {
		return parameters, nil
	}
	additionals, err := parametersFromOperation(self.doc, operation)
	if err != nil {
		return nil, err
	}
	parameters = append(parameters, additionals...)
	return parameters, nil
}

func objectToMap(schema *hcl.SchemaOrReference) map[string]*hcl.SchemaOrReference {
	if schema == nil {
		return nil
	}
	var object *hcl.SchemaObject
	switch schema.Oneof.(type) {
	case *hcl.SchemaOrReference_Schema:
		object = schema.GetSchema().Object
	case *hcl.SchemaOrReference_Object:
		object = schema.GetObject().Object
	default:
	}
	if object == nil {
		return nil
	}
	return object.Properties
}

func schemaMapFromContent(doc *hcl.Document, content map[string]*hcl.MediaType) (map[string]*hcl.SchemaOrReference, error) {
	var schema, first *hcl.SchemaOrReference
	var err error
	for k, v := range content {
		s := v.Schema
		switch s.Oneof.(type) {
		case *hcl.SchemaOrReference_Reference:
			reference := s.GetReference()
			schema, err = doc.ResolveSchemaOrReference(reference)
			if err != nil {
				return nil, err
			}
		default:
			schema = s
		}
		if first == nil {
			first = schema
		}
		if k == "application/json" {
			return objectToMap(schema), nil
		}
	}
	return objectToMap(first), nil
}

func (self *OpenApiSpecLocation) getCreateSchema() (map[string]*hcl.SchemaOrReference, error) {
	var content map[string]*hcl.MediaType
	rb, err := self.getRequestBody()
	if err != nil {
		return nil, err
	}
	if rb != nil {
		content = rb.GetContent()
	} else {
		rp, err := self.getResponseBody()
		if err != nil {
			return nil, err
		}
		if rp != nil {
			content = rp.GetContent()
		}
	}
	if len(content) == 0 {
		return nil, nil
	}
	return schemaMapFromContent(self.doc, content)
}

func (self *OpenApiSpecLocation) getReadSchema() (map[string]*hcl.SchemaOrReference, error) {
	var content map[string]*hcl.MediaType
	rp, err := self.getResponseBody()
	if err != nil {
		return nil, err
	}
	if rp != nil {
		content = rp.GetContent()
		if len(content) > 0 {
			return schemaMapFromContent(self.doc, content)
		}
	}

	parameters, err := self.getParameters()
	if err != nil {
		return nil, err
	}
	if len(parameters) == 0 {
		return nil, nil
	}

	properties := make(map[string]*hcl.SchemaOrReference)
	for _, parameter := range parameters {
		if parameter.Schema != nil {
			properties[parameter.Name] = parameter.Schema
		}
	}
	return properties, nil
}

func (self *OpenApiSpecLocation) MarshalHCL() ([]byte, error) {
	var schema map[string]*hcl.SchemaOrReference
	var err error
	switch self.how {
	case "create":
		schema, err = self.getCreateSchema()
	case "read":
		schema, err = self.getReadSchema()
	default:
	}
	if err != nil {
		return nil, err
	}
	if schema == nil {
		return nil, nil
	}
	body, err := hcl.SchemaOrReferenceMapToBody(schema)
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Resource) MarshalHCL() ([]byte, error) {
	var body *light.Body
	var err error
	if self.Create != nil {
		self.Create.SetHow("create")
		bs1, err = self.Create.MarshalHCL()
	} else if self.Read != nil {
		self.Read.SetHow("read")
		bs2, err = self.Read.MarshalHCL()
	} else {
		return nil, fmt.Errorf("either 'create' or 'read' must be defined")
	}
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}
