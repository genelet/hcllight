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
