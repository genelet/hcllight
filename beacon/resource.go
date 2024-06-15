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
func (self *Resource) toBody() (*light.Body, *light.Body, error) {
	if self.Create == nil && self.Read == nil {
		return nil, nil, nil
	}

	var schemaMap *hcl.SchemaObject
	if self.Create != nil {
		self.Create.doc = self.doc
		rm, _, err := self.Create.getRequestSchemaMapAndRequired()
		if err != nil {
			return nil, nil, err
		}
		rpm, _, err := self.Create.getResponseSchemaMap()
		if err != nil {
			return nil, nil, err
		}
		schemaMap = addSchemaMap(rm, rpm)
	}
	if self.Read != nil {
		self.Read.doc = self.doc
		rpm, _, err := self.Read.getResponseSchemaMap()
		if err != nil {
			return nil, nil, err
		}
		pm, err := self.Read.getParametersMap()
		if err != nil {
			return nil, nil, err
		}
		schemaMap = addSchemaMap(schemaMap, addSchemaMap(rpm, pm))
	}

	required, optional := ignoreSchemaOrReferenceMap(schemaMap, self.SchemaOptions)
	body1, err := hcl.SchemaOrReferenceMapToBody(required)
	if err != nil {
		return nil, nil, err
	}
	body2, err := hcl.SchemaOrReferenceMapToBody(optional)
	return body1, body2, err
}
