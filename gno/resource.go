// Copyright (c) Greetingland LLC
// MIT License
package gno

import (
	"github.com/genelet/hcllight/generated"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

type GnoResource struct {
	GnoDataSource
	CreateOp *openapiv3.Operation `hcl:"create_op,block"`
	UpdateOp *openapiv3.Operation `hcl:"update_op,block"`
	DeleteOp *openapiv3.Operation `hcl:"delete_op,block"`
}

func (self *Resource) NewGnoResource(doc *openapiv3.Document) (*GnoResource, error) {
	ds := &DataSource{
		Read:          self.Read,
		SchemaOptions: self.SchemaOptions,
	}
	gds, err := ds.NewGnoDataSource(doc)
	if err != nil {
		return nil, err
	}

	gr := &GnoResource{
		GnoDataSource: *gds,
	}

	for _, item := range doc.GetPaths().Path {
		if self.Create != nil && item.Name == self.Create.Path {
			gr.CreateOp = getOperationByMethod(item.Value, self.Create.Method)
		}
		if self.Update != nil && item.Name == self.Update.Path {
			gr.UpdateOp = getOperationByMethod(item.Value, self.Update.Method)
		}
		if self.Delete != nil && item.Name == self.Delete.Path {
			gr.DeleteOp = getOperationByMethod(item.Value, self.Delete.Method)
		}
	}

	return gr, nil
}

func (self *GnoResource) ToBlocks(name string) ([]*generated.Block, error) {
	var blocks []*generated.Block
	var err error
	if self.ReadOp != nil {
		blocks, err = blksArrayParameters(blocks, "resource", name, "read_op", self.ReadOp.Parameters, self.SchemaOptions)
	}
	if err == nil && self.CreateOp != nil {
		blocks, err = blksArrayParameters(blocks, "resource", name, "create_op", self.CreateOp.Parameters, self.SchemaOptions)
	}
	if err == nil && self.UpdateOp != nil {
		blocks, err = blksArrayParameters(blocks, "resource", name, "update_op", self.UpdateOp.Parameters, self.SchemaOptions)
	}
	if err == nil && self.DeleteOp != nil {
		blocks, err = blksArrayParameters(blocks, "resource", name, "delete_op", self.DeleteOp.Parameters, self.SchemaOptions)
	}
	if err == nil && self.CommonParameters != nil {
		blocks, err = blksArrayParameters(blocks, "resource", name, "common_parameters", self.CommonParameters, self.SchemaOptions)
	}

	return blocks, err
}
