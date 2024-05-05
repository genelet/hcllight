// Copyright (c) Greetingland LLC
// MIT License
package gno

import (
	"github.com/genelet/hcllight/light"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

type GnoResource struct {
	GnoDataSource
	CreateOp *openapiv3.Operation `hcl:"create_op,block"`
	UpdateOp *openapiv3.Operation `hcl:"update_op,block"`
	DeleteOp *openapiv3.Operation `hcl:"delete_op,block"`
}

func NewGnoResource(r *Resource, doc *openapiv3.Document) (*GnoResource, error) {
	ds := &DataSource{
		Read:          r.Read,
		SchemaOptions: r.SchemaOptions,
	}
	gds, err := NewGnoDataSource(ds, doc)
	if err != nil {
		return nil, err
	}

	gr := &GnoResource{
		GnoDataSource: *gds,
	}

	for _, item := range doc.GetPaths().Path {
		if r.Create != nil && item.Name == r.Create.Path {
			gr.CreateOp = getOperationByMethod(item.Value, r.Create.Method)
		}
		if r.Update != nil && item.Name == r.Update.Path {
			gr.UpdateOp = getOperationByMethod(item.Value, r.Update.Method)
		}
		if r.Delete != nil && item.Name == r.Delete.Path {
			gr.DeleteOp = getOperationByMethod(item.Value, r.Delete.Method)
		}
	}

	return gr, nil
}

func (self *GnoResource) blockResource(name string, c *GnoConfig) ([]*light.Block, error) {
	var blocks []*light.Block

	if self.ReadOp != nil {
		body, err := c.bodyOperation(self.ReadOp, self.SchemaOptions)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "resource",
			Labels: []string{name, "read_op"},
			Bdy:    body,
		})

	}
	if self.CreateOp != nil {
		body, err := c.bodyOperation(self.CreateOp, self.SchemaOptions)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "resource",
			Labels: []string{name, "create_op"},
			Bdy:    body,
		})
	}
	if self.UpdateOp != nil {
		body, err := c.bodyOperation(self.UpdateOp, self.SchemaOptions)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "resource",
			Labels: []string{name, "update_op"},
			Bdy:    body,
		})
	}
	if self.DeleteOp != nil {
		body, err := c.bodyOperation(self.DeleteOp, self.SchemaOptions)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "resource",
			Labels: []string{name, "delete_op"},
			Bdy:    body,
		})
	}
	if self.CommonParameters != nil {
		body, err := c.bodyArrayParameterOrReference(self.CommonParameters)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "resource",
			Labels: []string{name, "common_parameters"},
			Bdy:    body,
		})
	}

	return blocks, nil
}
