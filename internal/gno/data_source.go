// Copyright (c) Greetingland LLC
// MIT License
package gno

import (
	"github.com/genelet/hcllight/light"
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

func NewGnoDataSource(ds *DataSource, doc *openapiv3.Document) (*GnoDataSource, error) {
	gds := &GnoDataSource{
		SchemaOptions: ds.SchemaOptions,
	}

	for _, item := range doc.GetPaths().Path {
		if item.Name == ds.Read.Path {
			pathItem := item.Value
			gds.CommonParameters = pathItem.Parameters
			gds.ReadOp = getOperationByMethod(pathItem, ds.Read.Method)
		}
	}

	return gds, nil
}

func (self *GnoDataSource) blockDataSource(name string, c *GnoConfig) ([]*light.Block, error) {
	var blocks []*light.Block

	if self.ReadOp != nil {
		body, err := c.bodyOperation(self.ReadOp, self.SchemaOptions)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "data_source",
			Labels: []string{name, "read_op"},
			Bdy:    body,
		})
	}
	if self.CommonParameters != nil {
		body, err := c.bodyArrayParameterOrReference(self.CommonParameters)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "data_source",
			Labels: []string{name, "common_parameters"},
			Bdy:    body,
		})
	}

	return blocks, nil
}

func (self *GnoConfig) bodyOperation(op *openapiv3.Operation, so *SchemaOptions) (*light.Body, error) {
	if op == nil {
		return nil, nil
	}

	var body *light.Body
	var err error
	if op.Parameters == nil {
		body, err = self.bodyRequestBodyOrReference(op.RequestBody)
	} else {
		body, err = self.bodyArrayParameterOrReference(op.Parameters)
	}
	if err != nil {
		return nil, err
	}
	if so != nil {
		for key, attr := range body.Attributes {
			for _, ignore := range so.Ignores {
				if ignore == key {
					delete(body.Attributes, key)
				}
			}
			for k, v := range so.Aliases {
				if k == key {
					delete(body.Attributes, key)
					body.Attributes[v] = attr
				}
			}
		}
	}
	return body, nil
}
