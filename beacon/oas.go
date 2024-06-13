// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//

package beacon

import (
	"net/url"

	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
)

// Oas represents a generator Oas.
type Oas struct {
	Provider    *Provider
	Collections map[[2]string]*Collection
	doc         *hcl.Document
}

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
	myURL := new(url.URL)
	if bc.doc != nil {
		str, err := bc.doc.GetDefaultServer()
		if err != nil {
			return nil, err
		}
		if str != "" {
			myURL, err = url.Parse(str)
			if err != nil {
				return nil, err
			}
		}
	}

	Oas := &Oas{Provider: bc.Provider, doc: bc.GetDocument()}
	result := make(map[[2]string]*Collection)
	if bc.Resources != nil {
		for k, v := range bc.Resources {
			rmap, err := v.GetRequestSchemaMap()
			if err != nil {
				return nil, err
			}
			pmap, err := v.GetResponseSchemaMap()
			if err != nil {
				return nil, err
			}
			key := [2]string{k, "resource"}
			result[key] = &Collection{
				myURL:    myURL,
				Path:     v.Create.Path,
				Method:   v.Create.Method,
				Request:  rmap,
				Response: pmap,
			}
		}
	}
	if bc.DataSources != nil {
		for k, v := range bc.DataSources {
			rmap, err := v.GetRequestSchemaMap()
			if err != nil {
				return nil, err
			}
			pmap, err := v.GetResponseSchemaMap()
			if err != nil {
				return nil, err
			}
			key := [2]string{k, "data"}
			result[key] = &Collection{
				myURL:    myURL,
				Path:     v.Read.Path,
				Method:   v.Read.Method,
				Request:  rmap,
				Response: pmap,
			}
		}
	}
	if bc.Cleanups != nil {
		for k, v := range bc.Cleanups {
			rmap, err := v.GetRequestSchemaMap()
			if err != nil {
				return nil, err
			}
			pmap, err := v.GetResponseSchemaMap()
			if err != nil {
				return nil, err
			}
			key := [2]string{k, "cleanup"}
			result[key] = &Collection{
				myURL:    myURL,
				Path:     v.Delete.Path,
				Method:   v.Delete.Method,
				Request:  rmap,
				Response: pmap,
			}
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
