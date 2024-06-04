// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//

package beacon

import (
	"fmt"
	"strings"

	"github.com/genelet/determined/dethcl"
	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
	"gopkg.in/yaml.v3"
)

// Config represents a generator config.
type Config struct {
	*Provider   `yaml:"provider" hcl:"provider,block"`
	Resources   map[string]*Resource   `yaml:"resources" hcl:"resources,block"`
	DataSources map[string]*DataSource `yaml:"data_sources" hcl:"data_sources,block"`
	doc         *hcl.Document
}

type Provider struct {
	Name           string `yaml:"name" hcl:"name"`
	SchemaRef      string `yaml:"schema_ref" hcl:"schema_ref,optional"`
	*SchemaOptions `yaml:"schema" hcl:"schema,block"`
	doc            *hcl.Document
}

type Resource struct {
	Create         *OpenApiSpecLocation `yaml:"create" hcl:"create,block"`
	Read           *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	Update         *OpenApiSpecLocation `yaml:"update" hcl:"update,block"`
	Delete         *OpenApiSpecLocation `yaml:"delete" hcl:"delete,block"`
	*SchemaOptions `yaml:"schema" hcl:"schema,block"`
	doc            *hcl.Document
}

type DataSource struct {
	Read           *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	*SchemaOptions `yaml:"schema" hcl:"schema,block"`
	doc            *hcl.Document
}

// OpenApiSpecLocation defines a location in an OpenAPI spec for an API operation.
type OpenApiSpecLocation struct {
	Path   string `yaml:"path" hcl:"path"`
	Method string `yaml:"method" hcl:"method"`
	doc    *hcl.Document
}

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

// ParseConfig takes in a byte array, unmarshals into a Config struct.
// By default the byte array is assumed to be HCL, but if data_type is "yml" or "yaml", it will be unmarshaled as YAML.
func ParseConfig(bytes []byte, data_type ...string) (*Config, error) {
	var result Config
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
	return &result, nil
}

func (self *SchemaOptions) ToBody() (*light.Body, error) {
	bs, err := dethcl.Marshal(self)
	if err != nil {
		return nil, err
	}
	return light.Parse(bs)
}

func (self *Config) SetDocument(doc *hcl.Document) {
	self.doc = doc
	for _, resource := range self.Resources {
		resource.SetDocument(doc)
	}
	for _, dataSource := range self.DataSources {
		dataSource.SetDocument(doc)
	}
	if self.Provider != nil {
		self.Provider.SetDocument(doc)
	}
}

func (self *Config) GetDocument() *hcl.Document {
	return self.doc
}

func (self *Resource) SetDocument(doc *hcl.Document) {
	self.doc = doc
}

func (self *Resource) GetDocument() *hcl.Document {
	return self.doc
}

func (self *DataSource) SetDocument(doc *hcl.Document) {
	self.doc = doc
}

func (self *DataSource) GetDocument() *hcl.Document {
	return self.doc
}

func (self *Provider) SetDocument(doc *hcl.Document) {
	self.doc = doc
}

func (self *Provider) GetDocument() *hcl.Document {
	return self.doc
}

func (self *OpenApiSpecLocation) SetDocument(doc *hcl.Document) {
	self.doc = doc
}

func (self *OpenApiSpecLocation) GetDocument() *hcl.Document {
	return self.doc
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

	return hash[strings.ToLower(self.Method)]
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
	var first *hcl.SchemaOrReference
	for k, v := range content {
		s, err := doc.ResolveSchemaOrReference(v.Schema)
		if err != nil {
			return nil, err
		}
		if first == nil {
			first = s
		}
		if k == "application/json" {
			return objectToMap(s), nil
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

func (self *Resource) toBody() (*light.Body, error) {
	var blocks []*light.Block
	if self.Create != nil {
		self.Create.SetDocument(self.doc)
		schemaMap, err := self.Create.getCreateSchema()
		if err != nil {
			return nil, err
		}
		schemaMap = ignoreSchemaOrReferenceMap(schemaMap, self.SchemaOptions)
		bdy, err := hcl.SchemaOrReferenceMapToBody(schemaMap)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "create",
			Bdy:  bdy,
		})
	}

	if self.Read != nil {
		self.Read.SetDocument(self.doc)
		schemaMap, err := self.Read.getReadSchema()
		if err != nil {
			return nil, err
		}
		schemaMap = ignoreSchemaOrReferenceMap(schemaMap, self.SchemaOptions)
		bdy, err := hcl.SchemaOrReferenceMapToBody(schemaMap)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "read",
			Bdy:  bdy,
		})
	}

	if self.SchemaOptions != nil {
		bdy, err := self.SchemaOptions.ToBody()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "schema",
			Bdy:  bdy,
		})
	}

	if len(blocks) == 0 {
		return nil, nil
	}

	return &light.Body{
		Blocks: blocks,
	}, nil
}

func (self *DataSource) toBody() (*light.Body, error) {
	var blocks []*light.Block
	if self.Read != nil {
		self.Read.SetDocument(self.doc)
		schemaMap, err := self.Read.getReadSchema()
		if err != nil {
			return nil, err
		}
		schemaMap = ignoreSchemaOrReferenceMap(schemaMap, self.SchemaOptions)
		bdy, err := hcl.SchemaOrReferenceMapToBody(schemaMap)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "read",
			Bdy:  bdy,
		})
	}
	if self.SchemaOptions != nil {
		bdy, err := self.SchemaOptions.ToBody()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "schema",
			Bdy:  bdy,
		})
	}

	if len(blocks) == 0 {
		return nil, nil
	}

	return &light.Body{
		Blocks: blocks,
	}, nil
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

func findGeneralReference(body *light.Body, names []string) *light.Body {
	if body == nil || len(names) == 0 {
		return body
	}

	name := names[0]
	names = names[1:]

	for _, block := range body.Blocks {
		if block.Type == name {
			return findGeneralReference(block.Bdy, names)
		}
	}

	return nil
}

func (self *Provider) toBody() (*light.Body, error) {
	var blocks []*light.Block
	if self.SchemaOptions != nil {
		bdy, err := self.SchemaOptions.ToBody()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "schema",
			Bdy:  bdy,
		})
	}

	var body *light.Body
	if self.SchemaRef != "" {
		arr := strings.Split(self.SchemaRef, "#/")
		names := strings.Split(arr[1], "/")
		body, err := self.doc.ToBody()
		if err != nil {
			return nil, err
		}
		body = findGeneralReference(body, names)
	} else {
		body = &light.Body{
			Attributes: map[string]*light.Attribute{
				"name": {
					Name: "name",
					Expr: light.StringToTextValueExpr(self.Name),
				},
			},
			Blocks: blocks,
		}
	}
	return ignoreBody(body, self.SchemaOptions), nil
}

func (self *Config) toBody() (*light.Body, error) {
	var blocks []*light.Block
	if self.Provider != nil {
		bdy, err := self.Provider.toBody()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "provider",
			Bdy:  bdy,
		})
	}
	for k, v := range self.Resources {
		bdy, err := v.toBody()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "resource",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	for k, v := range self.DataSources {
		bdy, err := v.toBody()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "data",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}

	return &light.Body{
		Blocks: blocks,
	}, nil
}

func (self *Config) MarshalHCL() ([]byte, error) {
	bdy, err := self.toBody()
	if err != nil {
		return nil, err
	}
	return bdy.Hcl()
}
