// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//

package beacon

import (
	"strings"

	"github.com/genelet/hcllight/hcl"
)

// OpenApiSpecLocation defines a location in an OpenAPI spec for an API operation.
type OpenApiSpecLocation struct {
	Path   string `yaml:"path" hcl:"path"`
	Method string `yaml:"method" hcl:"method"`
	doc    *hcl.Document
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
