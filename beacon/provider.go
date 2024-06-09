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
	"github.com/genelet/hcllight/light"
)

type Provider struct {
	Name           string `yaml:"name" hcl:"name"`
	SchemaRef      string `yaml:"schema_ref" hcl:"schema_ref,optional"`
	*SchemaOptions `yaml:"schema" hcl:"schema,block"`
	doc            *hcl.Document
}

func (self *Provider) SetDocument(doc *hcl.Document) {
	self.doc = doc
}

func (self *Provider) GetDocument() *hcl.Document {
	return self.doc
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
