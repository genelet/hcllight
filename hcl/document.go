package hcl

import (
	"fmt"
	"net/url"
	"strings"

	"github.com/genelet/hcllight/light"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func (self *Document) resolveItems(items []*SchemaOrReference) ([]*SchemaOrReference, error) {
	var arr []*SchemaOrReference
	for _, item := range items {
		sor, err := self.ResolveSchemaOrReference(item)
		if err != nil {
			return nil, err
		}
		arr = append(arr, sor)
	}
	return arr, nil
}

func (self *Document) resolveReference(reference *Reference) (*SchemaOrReference, error) {
	if reference == nil {
		return nil, fmt.Errorf("reference is nil")
	}
	addresses, err := reference.toAddressArray()
	if err != nil {
		return nil, err
	}

	if len(addresses) < 3 {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	if strings.ToLower(addresses[0]) != "components" {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	if strings.ToLower(addresses[1]) != "schemas" {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	r2 := self.Components.Schemas[addresses[2]]
	if r2 == nil {
		return nil, fmt.Errorf("reference not found: %s", reference.XRef)
	}
	switch r2.Oneof.(type) {
	case *SchemaOrReference_Reference:
		return self.resolveReference(r2.GetReference())
	default:
	}
	return r2, nil
}

func (self *Document) ResolveSchemaOrReference(sor *SchemaOrReference) (*SchemaOrReference, error) {
	if sor == nil {
		return nil, nil
	}

	switch sor.Oneof.(type) {
	case *SchemaOrReference_Reference:
		reference := sor.GetReference()
		sor1, err := self.resolveReference(reference)
		if err != nil {
			return nil, err
		}
		return self.ResolveSchemaOrReference(sor1)
	case *SchemaOrReference_AllOf:
		arr, err := self.resolveItems(sor.GetAllOf().GetItems())
		if err != nil {
			return nil, err
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_AllOf{
				AllOf: &SchemaAllOf{
					Items: arr,
				},
			},
		}, nil
	case *SchemaOrReference_AnyOf:
		arr, err := self.resolveItems(sor.GetAnyOf().GetItems())
		if err != nil {
			return nil, err
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_AnyOf{
				AnyOf: &SchemaAnyOf{
					Items: arr,
				},
			},
		}, nil
	case *SchemaOrReference_OneOf:
		arr, err := self.resolveItems(sor.GetOneOf().GetItems())
		if err != nil {
			return nil, err
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_OneOf{
				OneOf: &SchemaOneOf{
					Items: arr,
				},
			},
		}, nil
	case *SchemaOrReference_Array:
		sa := sor.GetArray()
		arr, err := self.resolveItems(sa.GetArray().Items)
		if err != nil {
			return nil, err
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Array{
				Array: &OASArray{
					Array: &SchemaArray{
						Items:    arr,
						MaxItems: sa.GetArray().MaxItems,
						MinItems: sa.GetArray().MinItems,
					},
					Common: sa.Common,
				},
			},
		}, nil
	case *SchemaOrReference_Object:
		so := sor.GetObject()
		properties := make(map[string]*SchemaOrReference)
		for key, value := range so.GetObject().Properties {
			sor1, err := self.ResolveSchemaOrReference(value)
			if err != nil {
				return nil, err
			}
			properties[key] = sor1
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Object{
				Object: &OASObject{
					Object: &SchemaObject{
						Properties:    properties,
						MaxProperties: so.GetObject().MaxProperties,
						MinProperties: so.GetObject().MinProperties,
					},
					Common: so.Common,
				},
			},
		}, nil
	case *SchemaOrReference_Schema:
		s := sor.GetSchema()
		if allof := s.GetAllOf(); allof != nil {
			arr, err := self.resolveItems(allof.GetItems())
			if err != nil {
				return nil, err
			}
			s.AllOf = &SchemaAllOf{
				Items: arr,
			}
		}
		if anyof := s.GetAnyOf(); anyof != nil {
			arr, err := self.resolveItems(anyof.GetItems())
			if err != nil {
				return nil, err
			}
			s.AnyOf = &SchemaAnyOf{
				Items: arr,
			}
		}
		if oneof := s.GetOneOf(); oneof != nil {
			arr, err := self.resolveItems(oneof.GetItems())
			if err != nil {
				return nil, err
			}
			s.OneOf = &SchemaOneOf{
				Items: arr,
			}
		}
		if array := s.GetArray(); array != nil {
			arr, err := self.resolveItems(array.Items)
			if err != nil {
				return nil, err
			}
			s.Array = &SchemaArray{
				Items:    arr,
				MaxItems: array.MaxItems,
				MinItems: array.MinItems,
			}
		}
		if object := s.GetObject(); object != nil {
			properties := make(map[string]*SchemaOrReference)
			for key, value := range object.Properties {
				sor1, err := self.ResolveSchemaOrReference(value)
				if err != nil {
					return nil, err
				}
				properties[key] = sor1
			}
			s.Object = &SchemaObject{
				Properties:    properties,
				MaxProperties: object.MaxProperties,
				MinProperties: object.MinProperties,
			}
		}
		if not := s.GetNot(); not != nil {
			x, err := self.ResolveSchemaOrReference(not)
			if err != nil {
				return nil, err
			}
			s.Not = x
		}
		if xml := s.GetXml(); xml != nil {
			s.Xml = nil
		}
		return refreshFullSchema(s), nil
	default:
	}
	return sor, nil
}

func (self *Document) ResolveRequestBodyOrReference(reference *Reference) (*RequestBody, error) {
	if reference == nil {
		return nil, fmt.Errorf("reference is nil")
	}
	addresses, err := reference.toAddressArray()
	if err != nil {
		return nil, err
	}
	if len(addresses) <= 3 {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	if strings.ToLower(addresses[0]) != "components" {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	if strings.ToLower(addresses[1]) != "requestbodies" {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	r2 := self.Components.RequestBodies[addresses[2]]
	if r2 == nil {
		return nil, fmt.Errorf("reference not found: %s", reference.XRef)
	}
	switch r2.Oneof.(type) {
	case *RequestBodyOrReference_RequestBody:
		return r2.GetRequestBody(), nil
	case *RequestBodyOrReference_Reference:
		return self.ResolveRequestBodyOrReference(r2.GetReference())
	default:
	}
	return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
}

func (self *Document) ResolveReponseOrReference(reference *Reference) (*Response, error) {
	if reference == nil {
		return nil, fmt.Errorf("reference is nil")
	}
	addresses, err := reference.toAddressArray()
	if err != nil {
		return nil, err
	}
	if len(addresses) <= 3 {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	if strings.ToLower(addresses[0]) != "components" {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	if strings.ToLower(addresses[1]) != "responses" {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	r2 := self.Components.Responses[addresses[2]]
	if r2 == nil {
		return nil, fmt.Errorf("reference not found: %s", reference.XRef)
	}
	switch r2.Oneof.(type) {
	case *ResponseOrReference_Response:
		return r2.GetResponse(), nil
	case *ResponseOrReference_Reference:
		return self.ResolveReponseOrReference(r2.GetReference())
	default:
	}
	return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
}

func (self *Document) ResolveParameterOrReference(reference *Reference) (*Parameter, error) {
	if reference == nil {
		return nil, fmt.Errorf("reference is nil")
	}
	addresses, err := reference.toAddressArray()
	if err != nil {
		return nil, err
	}
	if len(addresses) <= 3 {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	if strings.ToLower(addresses[0]) != "components" {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	if strings.ToLower(addresses[1]) != "parameters" {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	r2 := self.Components.Parameters[addresses[2]]
	if r2 == nil {
		return nil, fmt.Errorf("reference not found: %s", reference.XRef)
	}
	switch r2.Oneof.(type) {
	case *ParameterOrReference_Parameter:
		return r2.GetParameter(), nil
	case *ParameterOrReference_Reference:
		return self.ResolveParameterOrReference(r2.GetReference())
	default:
	}
	return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
}

func (self *Document) ResolveExampleOrReference(reference *Reference) (*Example, error) {
	if reference == nil {
		return nil, fmt.Errorf("reference is nil")
	}
	addresses, err := reference.toAddressArray()
	if err != nil {
		return nil, err
	}
	if len(addresses) <= 3 {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	if strings.ToLower(addresses[0]) != "components" {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	if strings.ToLower(addresses[1]) != "examples" {
		return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
	}
	r2 := self.Components.Examples[addresses[2]]
	if r2 == nil {
		return nil, fmt.Errorf("reference not found: %s", reference.XRef)
	}
	switch r2.Oneof.(type) {
	case *ExampleOrReference_Example:
		return r2.GetExample(), nil
	case *ExampleOrReference_Reference:
		return self.ResolveExampleOrReference(r2.GetReference())
	default:
	}
	return nil, fmt.Errorf("invalid reference: %s", reference.XRef)
}

// ToBody converts a Document to a HCL Body.
func (self *Document) ToBody() (*light.Body, error) {
	return self.toHCL()
}

// MarshalHCL converts a Document to HCL representation.
func (self *Document) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

// UnmarshalHCL converts HCL representation to a Document.
func (self *Document) UnmarshalHCL(data []byte) error {
	var err error
	self, err = ParseDocument(data)
	return err
}

// ParseDocument parses a Document from HCL, JSON, or YAML.
// The data parameter is the input data.
// The extension parameter is the file extension, which can be "json", "jsn", "yaml", or "yml".
// If the extension parameter is not provided, it is default to "hcl".
func ParseDocument(data []byte, extension ...string) (*Document, error) {
	var typ string
	if extension != nil {
		typ = strings.ToLower(extension[0])
	}
	if typ == "json" || typ == "jsn" || typ == "yaml" || typ == "yml" {
		doc, err := openapiv3.ParseDocument(data)
		if err != nil {
			return nil, err
		}
		return DocumentFromApi(doc), nil
	}

	body, err := light.Parse(data)
	if err != nil {
		return nil, err
	}

	return documentFromHCL(body)
}

func (self *Document) GetDefaultServer() (*url.URL, error) {
	var first string
	if self.Servers != nil || len(self.Servers) != 0 {
		for _, server := range self.Servers {
			first = server.GetUrl()
			u, err := url.Parse(first)
			if err != nil {
				return nil, err
			}
			if u.Host != "" {
				return url.Parse(first)
			}
		}
	}
	return url.Parse(first)
}

func (self *Document) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Openapi != "" {
		attrs["openapi"] = &light.Attribute{
			Name: "openapi",
			Expr: light.StringToTextValueExpr(self.Openapi),
		}
	}
	if self.Info != nil {
		bdy, err := self.Info.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "info",
			Bdy:  bdy,
		})
	}
	if self.Servers != nil && len(self.Servers) > 0 {
		expr, err := serversToTupleConsExpr(self.Servers)
		if err != nil {
			return nil, err
		}
		attrs["servers"] = &light.Attribute{
			Name: "servers",
			Expr: expr,
		}
	}
	if self.Tags != nil && len(self.Tags) > 0 {
		expr, err := tagsToTupleConsExpr(self.Tags)
		if err != nil {
			return nil, err
		}
		attrs["tags"] = &light.Attribute{
			Name: "tags",
			Expr: expr,
		}
	}
	if self.ExternalDocs != nil {
		bdy, err := self.ExternalDocs.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "externalDocs",
			Bdy:  bdy,
		})
	}
	if self.Paths != nil {
		blks, err := pathItemOrReferenceMapToBlocks(self.Paths)
		if err != nil {
			return nil, err
		}
		for _, block := range blks {
			blocks = append(blocks, &light.Block{
				Type: "paths",
				Labels: []string{
					block.Type,
					block.Labels[0],
				},
				Bdy: block.Bdy,
			})
		}
	}
	if self.Components != nil {
		bdy, err := self.Components.toHCL()
		if err != nil {
			return nil, err
		}
		for _, block := range bdy.Blocks {
			labels := []string{block.Type}
			labels = append(labels, block.Labels...)
			blocks = append(blocks, &light.Block{
				Type:   "components",
				Labels: labels,
				Bdy:    block.Bdy,
			})
		}
	}
	if self.Security != nil {
		expr, err := securityRequirementToTupleConsExpr(self.Security)
		if err != nil {
			return nil, err
		}
		attrs["security"] = &light.Attribute{
			Name: "security",
			Expr: expr,
		}
	}
	if err := addSpecification(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func documentFromHCL(body *light.Body) (*Document, error) {
	if body == nil {
		return nil, nil
	}

	doc := new(Document)
	var blks_paths, blks_comments []*light.Block
	for key, attr := range body.Attributes {
		switch key {
		case "openapi":
			doc.Openapi = *light.TextValueExprToString(attr.Expr)
		case "servers":
			servers, err := expressionToServers(attr.Expr)
			if err != nil {
				return nil, err
			}
			if servers == nil || servers[0] == nil {
				panic(servers)
			}
			doc.Servers = servers
		case "tags":
			tags, err := expressionToTags(attr.Expr)
			if err != nil {
				return nil, err
			}
			doc.Tags = tags
		case "security":
			security, err := expressionToSecurityRequirement(attr.Expr)
			if err != nil {
				return nil, err
			}
			doc.Security = security
		}
	}
	for _, block := range body.Blocks {
		switch block.Type {
		case "info":
			info, err := infoFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			doc.Info = info
		case "externalDocs":
			externalDocs, err := externalDocsFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			doc.ExternalDocs = externalDocs
		case "paths":
			blks_paths = append(blks_paths, &light.Block{
				Type:   block.Labels[0],
				Labels: block.Labels[1:],
				Bdy:    block.Bdy,
			})
		case "components":
			blks_comments = append(blks_comments, &light.Block{
				Type:   block.Labels[0],
				Labels: block.Labels[1:],
				Bdy:    block.Bdy,
			})
		default:
		}
	}

	if blks_paths != nil {
		paths, err := blocksToPathItemOrReferenceMap(blks_paths)
		if err != nil {
			return nil, err
		}
		doc.Paths = paths
	}
	if blks_comments != nil {
		components, err := componentsFromHCL(&light.Body{Blocks: blks_comments})
		if err != nil {
			return nil, err
		}
		doc.Components = components
	}
	var err error
	doc.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	}

	return doc, nil
}
