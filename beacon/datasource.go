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

func (self *DataSource) getSchema() (map[string]*hcl.SchemaOrReference, error) {
	outputs := make(map[string]*hcl.SchemaOrReference)

	if self.Read == nil {
		return nil, nil
	}
	self.Read.SetDocument(self.doc)
	rpm, err := self.Read.getParameters()
	if err != nil {
		return nil, err
	}
	rrp, err := self.Read.getResponseBody()
	if err != nil {
		return nil, err
	}
	if rpm != nil {
		for _, parameter := range rpm {
			if parameter.Schema != nil {
				outputs[parameter.Name] = parameter.Schema
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
	if len(outputs) == 0 {
		return nil, nil
	}
	return outputs, nil
}

func (self *DataSource) toBody() (*light.Body, error) {
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
