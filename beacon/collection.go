// Copyright (c) Greetingland LLC
// MIT License

package beacon

import (
	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
)

type Collection struct {
	ReadRequest        *hcl.SchemaObject `yaml:"read_request" hcl:"read_request,block"`
	ReadRequestData    *light.Body
	ReadResponse       *hcl.SchemaObject `yaml:"read_response" hcl:"read_response,block"`
	ReadResponseData   *light.Body
	WriteRequest       *hcl.SchemaObject `yaml:"write_request" hcl:"write_request,block"`
	WriteRequestData   *light.Body
	WriteResponse      *hcl.SchemaObject `yaml:"write_response" hcl:"write_response,block"`
	WriteResponseData  *light.Body
	DeleteRequest      *hcl.SchemaObject `yaml:"delete_request" hcl:"delete_request,block"`
	DeleteRequestData  *light.Body
	DeleteResponse     *hcl.SchemaObject `yaml:"delete_response" hcl:"delete_response,block"`
	DeleteResponseData *light.Body
}
