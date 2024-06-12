// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//

package beacon

import (
	"fmt"

	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
)

// Oas represents a generator Oas.
type Oas struct {
	Provider    *Provider
	Collections map[string]*Collection
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
		switch block.Type {
		case "data":
			key := block.Labels[0]
			collection, ok := collections[key]
			if !ok {
				continue
			}
			collectionData, err := checkBody(collection.ReadRequest, block.Bdy)
			if err != nil {
				return nil, err
			}
			if _, ok := collections[key]; ok {
				collections[key].ReadRequestData = collectionData
			}
		case "resource":
			key := block.Labels[0]
			collection, ok := collections[key]
			if !ok {
				continue
			}
			collectionData, err := checkBody(collection.WriteRequest, block.Bdy)
			if err != nil {
				return nil, err
			}
			if _, ok := collections[key]; ok {
				collections[key].WriteRequestData = collectionData
			}
		case "cleanup":
			key := block.Labels[0]
			collection, ok := collections[key]
			if !ok {
				continue
			}
			collectionData, err := checkBody(collection.DeleteRequest, block.Bdy)
			if err != nil {
				return nil, err
			}
			if _, ok := collections[key]; ok {
				collections[key].DeleteRequestData = collectionData
			}
		default:
		}
	}
	return oas, nil
}

func (bc *Config) newOasFromBeacon() (*Oas, error) {
	Oas := &Oas{Provider: bc.Provider, doc: bc.GetDocument()}
	result := make(map[string]*Collection)
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
			result[k] = &Collection{
				WriteRequest:  rmap,
				WriteResponse: pmap,
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
			if _, ok := result[k]; ok {
				result[k].ReadRequest = rmap
				result[k].ReadResponse = pmap
			} else {
				result[k] = &Collection{
					ReadRequest:  rmap,
					ReadResponse: pmap,
				}
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
			if _, ok := result[k]; ok {
				result[k].DeleteRequest = rmap
				result[k].DeleteResponse = pmap
			} else {
				result[k] = &Collection{
					DeleteRequest:  rmap,
					DeleteResponse: pmap,
				}
			}
		}
	}
	if len(result) > 0 {
		Oas.Collections = result
	}
	return Oas, nil
}

func checkBody(schemaMap *hcl.SchemaObject, body *light.Body) (*light.Body, error) {
	if body == nil {
		return nil, nil
	}

	attributes := make(map[string]*light.Attribute)
	var blocks []*light.Block
	var allkeys []string
	if body.Attributes != nil {
		for k, attr := range body.Attributes {
			if _, ok := schemaMap.Properties[k]; ok {
				attributes[k] = attr
				allkeys = append(allkeys, k)
			}
		}
	}
	for _, b := range body.Blocks {
		if _, ok := schemaMap.Properties[b.Type]; ok {
			blocks = append(blocks, b)
			allkeys = append(allkeys, b.Type)
		}
	}

	var missings []string
	for _, key := range schemaMap.Required {
		if !grep(allkeys, key) {
			missings = append(missings, key)
		}
	}
	if len(missings) > 0 {
		return nil, fmt.Errorf("missing required fields: %v", missings)
	}
	body = &light.Body{
		Blocks: blocks,
	}
	if len(attributes) > 0 {
		body.Attributes = attributes
	}

	return body, nil
}
