// Copyright (c) Greetingland LLC
// MIT License
package gno

import (
	"errors"
	"fmt"

	"github.com/genelet/hcllight/generated"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

// Resource generator config section.
type Resource struct {
	Create         *OpenApiSpecLocation `yaml:"create" hcl:"create,block"`
	Read           *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	Update         *OpenApiSpecLocation `yaml:"update" hcl:"update,block"`
	Delete         *OpenApiSpecLocation `yaml:"delete" hcl:"delete,block"`
	*SchemaOptions `yaml:"schema" hcl:"schema,block"`
}

func (r *Resource) Validate() error {
	if r == nil {
		return errors.New("resource is nil")
	}

	var result error

	if r.Create == nil {
		result = errors.Join(result, errors.New("must have a create object"))
	}
	if r.Read == nil {
		result = errors.Join(result, errors.New("must have a read object"))
	}

	err := r.Create.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid create: %w", err))
	}

	err = r.Read.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid read: %w", err))
	}

	err = r.Update.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid update: %w", err))
	}

	err = r.Delete.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid delete: %w", err))
	}

	err = r.SchemaOptions.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("invalid schema: %w", err))
	}

	return result
}

type GnoResource struct {
	GnoDataSource
	CreateOp *openapiv3.Operation `hcl:"create_op,block"`
	UpdateOp *openapiv3.Operation `hcl:"update_op,block"`
	DeleteOp *openapiv3.Operation `hcl:"delete_op,block"`
}

func (self *Resource) BuildGnoResource(doc *openapiv3.Document) (*GnoResource, error) {
	ds := &DataSource{
		Read:          self.Read,
		SchemaOptions: self.SchemaOptions,
	}
	gds, err := ds.BuildGnoDataSource(doc)
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
