package kin

import (
	"context"
	"fmt"
	"net/url"
	"os"
	"strings"

	"github.com/genelet/hcllight/light"

	"github.com/getkin/kin-openapi/openapi3"
)

type Kin struct {
	doc     *openapi3.T
	address *url.URL
	ref     map[string]*light.Body
	extra   map[string]*light.Body
}

// NewKin creates a new Kin object from a byte slice of an OpenAPI 3.0 document.
func NewKin(bs []byte) (*Kin, error) {
	doc, err := openapi3.NewLoader().LoadFromData(bs)
	if err != nil {
		return nil, err
	}
	err = doc.Validate(context.Background())
	if err != nil {
		return nil, err
	}
	u := "/"
	if doc.Servers != nil && doc.Servers[0].URL != "" {
		u = doc.Servers[0].URL
	}
	address, err := url.Parse(u)
	if err != nil {
		return nil, err
	}
	return &Kin{
		doc:     doc,
		address: address,
		ref:     make(map[string]*light.Body),
	}, nil
}

func stringToCtyValue(val string) *light.CtyValue {
	return &light.CtyValue{
		CtyValueClause: &light.CtyValue_StringValue{StringValue: val},
	}
}

func stringToExpression(val string) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{Val: stringToCtyValue(val)},
		},
	}
}

func (self *Kin) schemaToBody(key string, schema *openapi3.Schema) (*light.Body, *openapi3.Schema, error) {
	switch schema.Type {
	case "string", "number", "integer", "boolean":
		return nil, schema, nil
	case "array":
		bdy, s, err := self.schemaRefToBody(key, schema.Items)
		if err != nil {
			return nil, nil, err
		}
		if bdy == nil {
			schema.Type = "list(" + s.Type + ")"
			return nil, schema, nil
		}
		if self.extra == nil {
			self.extra = make(map[string]*light.Body)
		}
		self.extra[key] = bdy
		schema.Type = "list(" + key + ")"
		return nil, schema, nil
	default:
	}

	if schema.Properties == nil {
		typ := "{}"
		if schema.AdditionalProperties.Schema != nil {
			_, s, err := self.schemaRefToBody(key, schema.AdditionalProperties.Schema)
			if err != nil {
				return nil, nil, err
			}
			if s == nil {
				typ = key
			} else {
				typ = s.Type
			}
		} else if schema.AdditionalProperties.Has != nil {
			typ = "any"
		}
		schema.Type = "object(string," + typ + ")"
		return nil, schema, nil
	}

	var body = &light.Body{}
	for k, v := range schema.Properties {
		bdy, s, err := self.schemaRefToBody(k, v)
		if err != nil {
			return nil, s, err
		}
		if bdy == nil {
			if body.Attributes == nil {
				body.Attributes = make(map[string]*light.Attribute)
			}
			body.Attributes[k] = &light.Attribute{
				Name: k,
				Expr: stringToExpression(s.Type),
			}
		} else {
			block := &light.Block{
				Type: k,
				Bdy:  bdy,
			}
			body.Blocks = append(body.Blocks, block)
		}
	}

	return body, nil, nil
}

func (self *Kin) schemaRefToBody(key string, v *openapi3.SchemaRef) (*light.Body, *openapi3.Schema, error) {
	if v.Ref != "" {
		rel, err := getStructName(v.Ref)
		return nil, &openapi3.Schema{Type: rel}, err
	}
	return self.schemaToBody(key, v.Value)
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
func (self *Kin) Build() error {
	doc := self.doc
	components := doc.Components
	if components == nil {
		return nil
	}

	f, err := os.Create("openapi.hcl")
	if err != nil {
		return err
	}
	defer f.Close()

	for key, val := range components.Schemas {
		body, _, err := self.schemaRefToBody(key, val)
		if err != nil {
			return err
		}
		if body != nil {
			self.ref[key] = body
			hcl, err := body.Hcl()
			if err != nil {
				return err
			}
			fmt.Fprintf(f, "components schema \"%s\" {%s}\n\n", key, hcl)
		}
	}

	for key, val := range components.Parameters {
		_, s, err := self.schemaRefToBody(key, val.Value.Schema)
		if err != nil {
			return err
		}
		fmt.Fprintf(f, "variables \"%s\" {\n  type = %s\n", key, s.Type)
		if s.Description != "" {
			fmt.Fprintf(f, "  description = %s\n", s.Description)
		}
		if s.Default != "" {
			fmt.Fprintf(f, "  default = %v\n", s.Default)
		}
		fmt.Fprintf(f, "}\n\n")
	}

	for path, item := range self.doc.Paths.Map() {
		hash := map[string]*openapi3.Operation{
			"connect": item.Connect,
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

func (self *Kin) getRR(op *openapi3.Operation) ([]byte, []byte, error) {
	var bsRequest, bsResponse []byte
	var bdy *light.Body
	var s *openapi3.Schema
	var err error

	if op.RequestBody != nil {
		bdy, s, err = self.schemaRefToBody("", op.RequestBody.Value.Content["application/json"].Schema)
		if err == nil {
			if bdy == nil {
				bsRequest = []byte(s.Type)
			} else {
				bsRequest, err = bdy.Hcl()
			}
		}
	}
	if op.Responses != nil {
		bdy, s, err = self.schemaRefToBody("", op.Responses.Value("200").Value.Content["application/json"].Schema)
		if err == nil {
			if bdy == nil {
				bsResponse = []byte(s.Type)
			} else {
				bsResponse, err = bdy.Hcl()
			}
		}
	}

	return bsRequest, bsResponse, err
}
