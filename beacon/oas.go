// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//

package beacon

import (
	"os"

	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
)

// Oas represents a generator Oas.
type Oas struct {
	Provider    *Provider
	Collections map[[2]string]*Collection
	doc         *hcl.Document
}

// NewOasFromFiles takes in three file paths, one for the OpenAPI spec, one for the generator config, and one for the input.
// It returns a Oas struct or an error if one occurs.
func NewOasFromFiles(openapi, generator, input string) (*Oas, error) {
	config_generator, err := ParseConfigFromFiles(openapi, generator)
	if err != nil {
		return nil, err
	}
	bs, err := os.ReadFile(input)
	if err != nil {
		return nil, err
	}
	return NewOas(config_generator, bs)
}

// NewOas takes in a Config struct and a byte array, unmarshals into a Oas struct.
func NewOas(bc *Config, bs []byte) (*Oas, error) {
	oas, err := bc.newOasFromBeacon()
	if err != nil {
		return nil, err
	}
	doc, err := light.Parse(bs)
	if err != nil {
		return nil, err
	}

	collections := oas.Collections
	for _, block := range doc.Blocks {
		if grep([]string{"resource", "data", "cleanup"}, block.Type) {
			key := [2]string{block.Labels[0], block.Type}
			collection, ok := collections[key]
			if !ok {
				continue
			}
			err := collection.checkBody(block.Bdy)
			if err != nil {
				return nil, err
			}
			oas.Collections[key] = collection
		}
	}
	return oas, nil
}

func (bc *Config) newOasFromBeacon() (*Oas, error) {
	myURL, err := bc.doc.GetDefaultServer()
	if err != nil {
		return nil, err
	}

	Oas := &Oas{Provider: bc.Provider, doc: bc.GetDocument()}
	result := make(map[[2]string]*Collection)
	if bc.Resources != nil {
		for k, v := range bc.Resources {
			create := v.Create
			if create == nil {
				continue
			}
			create.doc = bc.doc
			key := [2]string{k, "resource"}
			result[key], err = create.toCollection()
			if err != nil {
				return nil, err
			}
			result[key].myURL = myURL
		}
	}
	if bc.DataSources != nil {
		for k, v := range bc.DataSources {
			read := v.Read
			if read == nil {
				continue
			}
			read.doc = bc.doc
			key := [2]string{k, "data"}
			result[key], err = read.toCollection()
			if err != nil {
				return nil, err
			}
			result[key].myURL = myURL
		}
	}
	if bc.Cleanups != nil {
		for k, v := range bc.Cleanups {
			delett := v.Delete
			if delett == nil {
				continue
			}
			delett.doc = bc.doc
			key := [2]string{k, "cleanup"}
			result[key], err = delett.toCollection()
			if err != nil {
				return nil, err
			}
			result[key].myURL = myURL
		}
	}

	if len(result) > 0 {
		Oas.Collections = result
	}
	return Oas, nil
}

func (self *Oas) GetDocument() *hcl.Document {
	return self.doc
}
