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
	Create        *OpenApiSpecLocation `yaml:"create" hcl:"create,block"`
	Read          *OpenApiSpecLocation `yaml:"read" hcl:"read,block"`
	Update        *OpenApiSpecLocation `yaml:"update" hcl:"update,block"`
	Delete        *OpenApiSpecLocation `yaml:"delete" hcl:"delete,block"`
	SchemaOptions `yaml:"schema" hcl:"schema,block"`
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

func (self *GnoConfig) blksArrayParameters(blks []*generated.Block, name string, params []*openapiv3.ParameterOrReference) ([]*generated.Block, error) {
	var bdy *generated.Body
	var err error
	_, bdy, err = self.exprBodyArrayParameterOrReference(params)
	if err != nil {
		return nil, err
	}
	return appendBlock(blks, name, bdy), nil
}

func (self *GnoConfig) blockResources() (*generated.Block, error) {
	var attributes map[string]*generated.Attribute
	var blocks []*generated.Block
	for name, resource := range self.GnoResources {
		var blks []*generated.Block
		var err error
		if resource.ReadOp != nil {
			blks, err = self.blksArrayParameters(blks, "read_op", resource.ReadOp.Parameters)
		}
		if err != nil {
			return nil, err
		}
		if resource.CreateOp != nil {
			blks, err = self.blksArrayParameters(blks, "create_op", resource.CreateOp.Parameters)
		}
		if err != nil {
			return nil, err
		}
		if resource.UpdateOp != nil {
			blks, err = self.blksArrayParameters(blks, "update_op", resource.UpdateOp.Parameters)
		}
		if err != nil {
			return nil, err
		}
		if resource.DeleteOp != nil {
			blks, err = self.blksArrayParameters(blks, "delete_op", resource.DeleteOp.Parameters)
		}
		if err != nil {
			return nil, err
		}
		if resource.CommonParameters != nil {
			blks, err = self.blksArrayParameters(blks, "common_parameters", resource.CommonParameters)
		}
		if err != nil {
			return nil, err
		}
		body := &generated.Body{
			Blocks: blks,
		}
		blocks = appendBlock(blocks, name, body)
	}

	return &generated.Block{
		Type: "resource",
		Bdy: &generated.Body{
			Attributes: attributes,
			Blocks:     blocks,
		},
	}, nil
}
