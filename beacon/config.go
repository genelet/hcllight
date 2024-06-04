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
