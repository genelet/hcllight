package loa

import (
	"context"
	"fmt"
	"net/url"
	"os"
	"strings"

	"github.com/genelet/hcllight/generated"
	"github.com/genelet/hcllight/light"

	"github.com/pb33f/libopenapi"
	highbase "github.com/pb33f/libopenapi/datamodel/high/base"
	v3 "github.com/pb33f/libopenapi/datamodel/high/v3"
	"github.com/pb33f/libopenapi/orderedmap"
)

type Loa struct {
	doc     *libopenapi.DocumentModel[v3.Document]
	model   v3.Document
	address *url.URL
	ref     map[string]*generated.Body
	extra   map[string]*generated.Body
}

// NewLoa creates a new Loa object from a byte slice of an OpenAPI 3.0 document.
func NewLoa(bs []byte) (*Loa, error) {
	model3, err := libopenapi.NewDocument(bs)
	if err != nil {
		return nil, err
	}
	doc, errs := model3.BuildV3Model()
	if len(errs) > 0 {
		return nil, fmt.Errorf("failed to build V3 model: %v", errs)
	}

	model := doc.Model

	u := "/"
	if model.Servers != nil && model.Servers[0].URL != "" {
		u = model.Servers[0].URL
	}
	address, err := url.Parse(u)
	if err != nil {
		return nil, err
	}
	return &Loa{
		doc:     doc,
		model:   model,
		address: address,
		ref:     make(map[string]*generated.Body),
	}, nil
}

func stringToCtyValue(val string) *generated.CtyValue {
	return &generated.CtyValue{
		CtyValueClause: &generated.CtyValue_StringValue{StringValue: val},
	}
}

func stringToExpression(val string) *generated.Expression {
	return &generated.Expression{
		ExpressionClause: &generated.Expression_Lvexpr{
			Lvexpr: &generated.LiteralValueExpr{Val: stringToCtyValue(val)},
		},
	}
}

func (self *Loa) schemaToBody(key string, schema *highbase.Schema) (*generated.Body, *highbase.Schema, error) {
	switch schema.SchemaTypeRef {
	case "string", "number", "integer", "boolean":
		return nil, schema, nil
	case "array":
		bdy, s, err := self.schemaRefToBody(key, schema.Items.A)
		if err != nil {
			return nil, nil, err
		}
		if bdy == nil {
			schema.SchemaTypeRef = "list(" + s.SchemaTypeRef + ")"
			return nil, schema, nil
		}
		if self.extra == nil {
			self.extra = make(map[string]*generated.Body)
		}
		self.extra[key] = bdy
		schema.SchemaTypeRef = "list(" + key + ")"
		return nil, schema, nil
	default:
	}

	if schema.Properties.IsZero() {
		typ := "{}"
		if schema.AdditionalProperties != nil {
			if schema.AdditionalProperties.IsA() {
				_, s, err := self.schemaRefToBody(key, schema.AdditionalProperties.A)
				if err != nil {
					return nil, nil, err
				}
				if s == nil {
					typ = key
				} else {
					typ = s.SchemaTypeRef
				}
			} else if schema.AdditionalProperties.IsB() {
				typ = "any"
			}
		}
		schema.SchemaTypeRef = "object(string," + typ + ")"
		return nil, schema, nil
	}

	var body = &generated.Body{}
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	c := orderedmap.Iterate(ctx, schema.Properties)

	for pair := range c {
		k := pair.Key()
		v := pair.Value()
		bdy, s, err := self.schemaRefToBody(k, v)
		if err != nil {
			return nil, s, err
		}
		if bdy == nil {
			if body.Attributes == nil {
				body.Attributes = make(map[string]*generated.Attribute)
			}
			body.Attributes[k] = &generated.Attribute{
				Name: k,
				Expr: stringToExpression(s.SchemaTypeRef),
			}
		} else {
			block := &generated.Block{
				Type: k,
				Bdy:  bdy,
			}
			body.Blocks = append(body.Blocks, block)
		}
	}

	return body, nil, nil
}

func (self *Loa) schemaRefToBody(key string, v *highbase.SchemaProxy) (*generated.Body, *highbase.Schema, error) {
	if ref := v.GetReference(); ref != "" {
		rel, err := getStructName(ref)
		return nil, &highbase.Schema{SchemaTypeRef: rel}, err
	}
	schema, err := v.BuildSchema()
	if err != nil {
		return nil, nil, err
	}
	return self.schemaToBody(key, schema)
}

func getStructName(ref string) (string, error) {
	u, err := url.Parse(ref)
	if err != nil {
		return "", err
	}
	if u.Host == "" && u.Path == "" && u.Fragment != "" {
		arr := strings.SplitN(u.Fragment, "/", -1)
		n := len(arr)
		for {
			if n <= 0 {
				break
			}
			if arr[0] == "" || strings.ToLower(arr[0]) == "components" || strings.ToLower(arr[0]) == "schemas" {
				arr = arr[1:]
				n--
			} else {
				return strings.Join(arr, "/"), nil
			}
		}
	}
	return "", nil
}

// Build generates a HCL file named openapi.hcl from the OpenAPI 3.0 document.
func (self *Loa) Build() error {
	model := self.model
	components := model.Components
	if components == nil {
		return nil
	}

	f, err := os.Create("openapi.hcl")
	if err != nil {
		return err
	}
	defer f.Close()

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	for pair := range orderedmap.Iterate(ctx, components.Schemas) {
		key := pair.Key()
		val := pair.Value()
		body, _, err := self.schemaRefToBody(key, val)
		if err != nil {
			return err
		}
		if body != nil {
			self.ref[key] = body
			hcl, err := light.Hcl(body)
			if err != nil {
				return err
			}
			fmt.Fprintf(f, "components schema \"%s\" {%s}\n\n", key, hcl)
		}
	}

	for pair := range orderedmap.Iterate(ctx, components.Parameters) {
		key := pair.Key()
		val := pair.Value()
		_, s, err := self.schemaRefToBody(key, val.Schema)
		if err != nil {
			return err
		}
		fmt.Fprintf(f, "variables \"%s\" {\n  type = %s\n", key, s.Type)
		if s.Description != "" {
			fmt.Fprintf(f, "  description = %s\n", s.Description)
		}
		if s.Default != nil {
			fmt.Fprintf(f, "  default = %v\n", s.Default)
		}
		fmt.Fprintf(f, "}\n\n")
	}

	for pair := range orderedmap.Iterate(ctx, self.model.Paths.PathItems) {
		path := pair.Key()
		item := pair.Value()
		hash := map[string]*v3.Operation{
			"delete":  item.Delete,
			"get":     item.Get,
			"head":    item.Head,
			"options": item.Options,
			"patch":   item.Patch,
			"post":    item.Post,
			"put":     item.Put,
			"trace":   item.Trace,
		}
		for k, v := range hash {
			if v == nil {
				continue
			}
			req, res, err := self.getRR(v)
			if err != nil {
				return err
			}
			fmt.Fprintf(f, "paths \"%s\" \"%s\" {\n", path, k)
			if req != nil {
				fmt.Fprintf(f, "  request = %s\n", twoSpace(req))
			}
			fmt.Fprintf(f, "  response = %s\n", twoSpace(res))
			fmt.Fprintf(f, "}\n\n")
		}
	}

	return nil
}

func twoSpace(s []byte) string {
	lines := strings.Split(string(s), "\n")
	for i, line := range lines {
		//lines[i] = "  " + line
		lines[i] = line
	}
	return strings.Join(lines, "\n")
}

func (self *Loa) getRR(op *v3.Operation) ([]byte, []byte, error) {
	var bsRequest, bsResponse []byte
	var bdy *generated.Body
	var s *highbase.Schema
	var err error

	if op.RequestBody != nil && !op.RequestBody.Content.IsZero() {
		jsn := op.RequestBody.Content.GetOrZero("application/json")
		if jsn == nil {
			return nil, nil, nil
		}
		bdy, s, err = self.schemaRefToBody("", jsn.Schema)
		if err == nil {
			if bdy == nil {
				bsRequest = []byte(s.SchemaTypeRef)
			} else {
				bsRequest, err = light.Hcl(bdy)
			}
		}
	}
	if op.Responses != nil && op.Responses.Default != nil && !op.Responses.Default.Content.IsZero() {
		jsn := op.Responses.Default.Content.GetOrZero("application/json")
		if jsn == nil {
			return nil, nil, nil
		}
		bdy, s, err = self.schemaRefToBody("", jsn.Schema)
		if err == nil {
			if bdy == nil {
				bsResponse = []byte(s.SchemaTypeRef)
			} else {
				bsResponse, err = light.Hcl(bdy)
			}
		}
	}

	return bsRequest, bsResponse, err
}
