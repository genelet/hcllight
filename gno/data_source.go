// Copyright (c) Greetingland LLC
// MIT License
package gno

import (
	"github.com/genelet/hcllight/generated"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

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

func (self *DataSource) NewGnoDataSource(doc *openapiv3.Document) (*GnoDataSource, error) {
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
