// Copyright (c) Greetingland LLC
// MIT License

package beacon

import (
	"github.com/genelet/hcllight/hcl"
)

type Collection struct {
	ReadRequest        *hcl.SchemaObject
	ReadRequestData    []byte
	ReadResponse       *hcl.SchemaObject
	ReadResponseData   []byte
	WriteRequest       *hcl.SchemaObject
	WriteRequestData   []byte
	WriteResponse      *hcl.SchemaObject
	WriteResponseData  []byte
	DeleteRequest      *hcl.SchemaObject
	DeleteRequestData  []byte
	DeleteResponse     *hcl.SchemaObject
	DeleteResponseData []byte
}
