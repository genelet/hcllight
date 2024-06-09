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

type Resource struct {
	Create         *OpenApiSpecLocation `yaml:"create" hcl:"create,block"`
	Read           *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	Update         *OpenApiSpecLocation `yaml:"update" hcl:"update,block"`
	Delete         *OpenApiSpecLocation `yaml:"delete" hcl:"delete,block"`
	*SchemaOptions `yaml:"schema" hcl:"schema,block"`
	doc            *hcl.Document
}

func (self *Resource) SetDocument(doc *hcl.Document) {
	self.doc = doc
}

func (self *Resource) GetDocument() *hcl.Document {
	return self.doc
}

/*
ToBody will return a light.Body object that represents the schema of the resource.

In these OAS operations, the generator will search the create and read for schemas to map to the provider code specification. Multiple schemas will have the OAS types mapped to Provider Attributes and then be merged together; with the final result being the Resource schema. The schemas that will be merged together (in priority order):

1. create operation: requestBody
requestBody is the only schema required for resources. If not found, the generator will skip the resource without mapping.
Will attempt to use application/json content-type first. If not found, will grab the first available content-type with a schema (alphabetical order)
2. create operation: response body in responses
Will attempt to use 200 or 201 response body. If not found, will grab the first available 2xx response code with a schema (lexicographic order)
Will attempt to use application/json content-type first. If not found, will grab the first available content-type with a schema (alphabetical order)
3. read operation: response body in responses
Will attempt to use 200 or 201 response body. If not found, will grab the first available 2xx response code with a schema (lexicographic order)
Will attempt to use application/json content-type first. If not found, will grab the first available content-type with a schema (alphabetical order)
4. read operation: parameters
The generator will merge all query and path parameters to the root of the schema.
The generator will consider as parameters the ones in the OAS Path Item and the ones in the OAS Operation, merged based on the rules in the specification
*/
func (self *Resource) ToBody() (*light.Body, error) {
	schemaMap, err := self.getSchema()
	if err != nil {
		return nil, err
	}
	schemaMap = ignoreSchemaOrReferenceMap(schemaMap, self.SchemaOptions)
	return hcl.SchemaOrReferenceMapToBody(schemaMap)
}

func (self *Resource) getSchema() (map[string]*hcl.SchemaOrReference, error) {
	outputs := make(map[string]*hcl.SchemaOrReference)

	self.Create.SetDocument(self.doc)
	crb, err := self.Create.getRequestBody()
	if err != nil {
		return nil, err
	}
	crp, err := self.Create.getResponseBody()
	if err != nil {
		return nil, err
	}
	self.Read.SetDocument(self.doc)
	rrp, err := self.Read.getResponseBody()
	if err != nil {
		return nil, err
	}
	rpm, err := self.Read.getParameters()
	if err != nil {
		return nil, err
	}

	if crb != nil {
		hash, err := schemaMapFromContent(self.doc, crb.GetContent())
		if err != nil {
			return nil, err
		}
		for k, v := range hash {
			outputs[k] = v
		}
	}
	if crp != nil {
		hash, err := schemaMapFromContent(self.doc, crp.GetContent())
		if err != nil {
			return nil, err
		}
		for k, v := range hash {
			if _, ok := outputs[k]; !ok {
				outputs[k] = v
			}
		}
	}
	if rrp != nil {
		hash, err := schemaMapFromContent(self.doc, rrp.GetContent())
		if err != nil {
			return nil, err
		}
		for k, v := range hash {
			if _, ok := outputs[k]; !ok {
				outputs[k] = v
			}
		}
	}
	if rpm != nil {
		for _, parameter := range rpm {
			if parameter.Schema != nil {
				if _, ok := outputs[parameter.Name]; !ok {
					outputs[parameter.Name] = parameter.Schema
				}
			}
		}
	}

	return outputs, nil
}
