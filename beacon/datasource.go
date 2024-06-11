// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//

package beacon

import (
	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
)

type DataSource struct {
	Read           *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	*SchemaOptions `yaml:"schema" hcl:"schema,block"`
	doc            *hcl.Document
}

func (self *DataSource) SetDocument(doc *hcl.Document) {
	self.doc = doc
}

func (self *DataSource) GetDocument() *hcl.Document {
	return self.doc
}

func (self *DataSource) GetRequestSchemaMap() (map[string]*hcl.SchemaOrReference, error) {
	self.Read.SetDocument(self.doc)
	rpm, err := self.Read.getParameters()
	if err != nil {
		return nil, err
	}
	if rpm == nil {
		return nil, nil
	}
	outputs := make(map[string]*hcl.SchemaOrReference)
	for _, parameter := range rpm {
		if parameter.Schema != nil {
			outputs[parameter.Name] = parameter.Schema
		}
	}
	if len(outputs) == 0 {
		return nil, nil
	}
	return outputs, nil
}

func (self *DataSource) GetResponseSchemaMap() (map[string]*hcl.SchemaOrReference, error) {
	self.Read.SetDocument(self.doc)
	rrp, err := self.Read.getResponseBody()
	if err != nil {
		return nil, err
	}
	if rrp == nil {
		return nil, nil
	}
	return schemaMapFromContent(self.doc, rrp.GetContent())
}

func (self *DataSource) getSchema() (map[string]*hcl.SchemaOrReference, error) {
	outputs, err := self.GetRequestSchemaMap()
	if err != nil {
		return nil, err
	}
	hash, err := self.GetResponseSchemaMap()
	if err != nil {
		return nil, err
	}
	if outputs == nil {
		outputs = make(map[string]*hcl.SchemaOrReference)
	}
	for k, v := range hash {
		if _, ok := outputs[k]; !ok {
			outputs[k] = v
		}
	}
	if len(outputs) == 0 {
		return nil, nil
	}
	return outputs, nil
}

/*
ToBody will return a light Body object that represents the data source schema.

The generator uses the read operation to map to the provider code specification. Multiple schemas will have the OAS types mapped to Provider Attributes and then be merged together; with the final result being the Data Source schema. The schemas that will be merged together (in priority order):

1. read operation: parameters
The generator will merge all query and path parameters to the root of the schema.
The generator will consider as parameters the ones in the Path Item Object and the ones in the Operation Object, merged based on the rules in the specification
2. read operation: response body in responses
The response body is the only schema required for data sources. If not found, the generator will skip the data source without mapping.
Will attempt to use 200 or 201 response body. If not found, will grab the first available 2xx response code with a schema (lexicographic order)
Will attempt to use application/json content-type first. If not found, will grab the first available content-type with a schema (alphabetical order)
*/
func (self *DataSource) ToBody() (*light.Body, error) {
	if self.Read == nil {
		return nil, nil
	}

	schemaMap, err := self.getSchema()
	if err != nil {
		return nil, err
	}
	schemaMap = ignoreSchemaOrReferenceMap(schemaMap, self.SchemaOptions)
	return hcl.SchemaOrReferenceMapToBody(schemaMap)
}
