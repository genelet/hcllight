// Copyright (c) Greetingland LLC
// MIT License
package gno

import (
	"errors"
	"fmt"

	"github.com/genelet/hcllight/generated"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

// DataSource generator config section.
type DataSource struct {
	/* private start
	    *
	   The generator uses the read operation to map to the provider code specification. Multiple schemas will have the OAS types mapped to Provider Attributes and then be merged together; with the final result being the Data Source schema. The schemas that will be merged together (in priority order):

	   1. read operation: parameters
	    - The generator will merge all query and path parameters to the root of the schema.
	    - The generator will consider as parameters the ones in the Path Item Object and the ones in the Operation Object, merged based on the rules in the specification
	   2. read operation: response body in responses
	    - The response body is the only schema required for data sources. If not found, the generator will skip the data source without mapping.
	    - Will attempt to use 200 or 201 response body. If not found, will grab the first available 2xx response code with a schema (lexicographic order)
	    - Will attempt to use application/json content-type first. If not found, will grab the first available content-type with a schema (alphabetical order)

	    * private end
	*/
	Read           *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	*SchemaOptions `yaml:"schema" hcl:"schema,block"`
}

func (d *DataSource) Validate() error {
	if d == nil {
		return errors.New("data source is nil")
	}

	var result error

	if d.Read == nil {
		result = errors.Join(result, errors.New("must have a read object"))
	}

	err := d.Read.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid read: %w", err))
	}

	err = d.SchemaOptions.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid schema: %w", err))
	}

	return result
}

type GnoDataSource struct {
	ReadOp           *openapiv3.Operation              `hcl:"read_op,block"`
	CommonParameters []*openapiv3.ParameterOrReference `hcl:"common_parameters,block"`
	*SchemaOptions   `hcl:"schema,block"`
}

func getOperationByMethod(pathItem *openapiv3.PathItem, method string) *openapiv3.Operation {
	switch method {
	case "read", "READ", "get", "GET":
		return pathItem.Get
	case "create", "CREATE", "post", "POST":
		return pathItem.Post
	case "update", "UPDATE", "put", "PUT":
		return pathItem.Put
	case "delete", "DELETE":
		return pathItem.Delete
	default:
	}

	return pathItem.Get
}

func (self *DataSource) BuildGnoDataSource(doc *openapiv3.Document) (*GnoDataSource, error) {
	gds := &GnoDataSource{
		SchemaOptions: self.SchemaOptions,
	}

	for _, item := range doc.GetPaths().Path {
		if item.Name == self.Read.Path {
			pathItem := item.Value
			gds.CommonParameters = pathItem.Parameters
			gds.ReadOp = getOperationByMethod(pathItem, self.Read.Method)
		}
	}

	return gds, nil
}

func (self *GnoDataSource) ToBlocks(name string) ([]*generated.Block, error) {
	var blocks []*generated.Block
	var err error

	if self.ReadOp != nil {
		blocks, err = blksArrayParameters(blocks, "data_source", name, "read_op", self.ReadOp.Parameters, self.SchemaOptions)
	}
	if err == nil && self.CommonParameters != nil {
		blocks, err = blksArrayParameters(blocks, "data_source", name, "common_parameters", self.CommonParameters, self.SchemaOptions)
	}
	if err != nil {
		return nil, err
	}

	return blocks, nil
}

func bodyArrayParameterOrReference(v []*openapiv3.ParameterOrReference, so *SchemaOptions) (*generated.Body, error) {
	attributes := make(map[string]*generated.Attribute)
TOP:
	for _, item := range v {
		name, expr, err := nameExprParameterOrReference(item)
		if err != nil {
			return nil, err
		}
		if name == "" {
			name = "XREF"
		}
		if so != nil {
			for _, ignore := range so.Ignores {
				if ignore == name {
					continue TOP
				}
			}
			for k, v := range so.Aliases {
				if k == name {
					name = v
				}
			}
			/*
				for k, v := range so.Overrides {
					if k == name {
						if v.Description != "" {
							expr.Expression = v.Description
						}
					}
				}
			*/
		}

		attributes[name] = &generated.Attribute{
			Name: name,
			Expr: expr,
		}
	}

	return &generated.Body{
		Attributes: attributes,
	}, nil
}

func blksArrayParameters(blocks []*generated.Block, name1, name2, name3 string, params []*openapiv3.ParameterOrReference, so *SchemaOptions) ([]*generated.Block, error) {
	body, err := bodyArrayParameterOrReference(params, so)
	if err != nil {
		return nil, err
	}
	blocks = append(blocks, &generated.Block{
		Type:   name1,
		Labels: []string{name2, name3},
		Bdy:    body,
	})
	return blocks, nil
}
