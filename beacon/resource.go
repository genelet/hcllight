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

func (self *Resource) toBody() (*light.Body, error) {
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
