// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//

package beacon

import (
	"fmt"
	"os"
	"path/filepath"
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
	Cleanups    map[string]*Cleanup    `yaml:"cleanups" hcl:"cleanups,block"`
	doc         *hcl.Document
}

// ParseConfigFromFiles takes in two file paths, one for the OpenAPI spec and one for the generator config.
// It returns a Config struct or an error if one occurs.
func ParseConfigFromFiles(openapi, generator string) (*Config, error) {
	ext_openapi := filepath.Ext(openapi)
	if ext_openapi[0] == '.' {
		ext_openapi = ext_openapi[1:]
	}
	bs, err := os.ReadFile(openapi)
	if err != nil {
		return nil, err
	}
	doc_openapi, err := hcl.ParseDocument(bs, ext_openapi)
	if err != nil {
		return nil, err
	}

	ext_generator := filepath.Ext(generator)
	if ext_generator[0] == '.' {
		ext_generator = ext_generator[1:]
	}
	bs, err = os.ReadFile(generator)
	if err != nil {
		return nil, err
	}
	config_generator, err := ParseConfig(bs, ext_generator)
	if err != nil {
		return nil, err
	}
	config_generator.SetDocument(doc_openapi)
	return config_generator, nil
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

// SetDocument sets the document for the Config and its children.
func (self *Config) SetDocument(doc *hcl.Document) {
	self.doc = doc
	for _, resource := range self.Resources {
		resource.doc = doc
	}
	for _, dataSource := range self.DataSources {
		dataSource.doc = doc
	}
	for _, cleanup := range self.Cleanups {
		cleanup.doc = doc
	}
	if self.Provider != nil {
		self.Provider.doc = doc
	}
}

// GetDocument returns the document for the Config.
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
	if self.Resources != nil {
		for k, v := range self.Resources {
			required, bdy, err := v.toBody()
			if err != nil {
				return nil, err
			}
			if required != nil {
				blocks = append(blocks, &light.Block{
					Type:   "resource",
					Labels: []string{k, "required"},
					Bdy:    required,
				})
			}
			if bdy != nil {
				blocks = append(blocks, &light.Block{
					Type:   "resource",
					Labels: []string{k},
					Bdy:    bdy,
				})
			}
		}
	}
	if self.DataSources != nil {
		for k, v := range self.DataSources {
			required, bdy, err := v.toBody()
			if err != nil {
				return nil, err
			}
			if required != nil {
				blocks = append(blocks, &light.Block{
					Type:   "data",
					Labels: []string{k, "required"},
					Bdy:    required,
				})
			}
			if bdy != nil {
				blocks = append(blocks, &light.Block{
					Type:   "data",
					Labels: []string{k},
					Bdy:    bdy,
				})
			}
		}
	}
	if self.Cleanups != nil {
		for k, v := range self.Cleanups {
			required, bdy, err := v.toBody()
			if err != nil {
				return nil, err
			}
			if required != nil {
				blocks = append(blocks, &light.Block{
					Type:   "cleanup",
					Labels: []string{k, "required"},
					Bdy:    required,
				})
			}
			if bdy != nil {
				blocks = append(blocks, &light.Block{
					Type:   "cleanup",
					Labels: []string{k},
					Bdy:    bdy,
				})
			}
		}
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
