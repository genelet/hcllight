package kin

import (
	"context"
	"fmt"
	"log"
	"net/url"
	"os"
	"strings"

	"github.com/genelet/hcllight/generated"
	"github.com/genelet/hcllight/light"

	"github.com/getkin/kin-openapi/openapi3"
)

type Kin struct {
	doc     *openapi3.T
	address *url.URL
	ref     map[string]*generated.Body
	extra   map[string]*generated.Body
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

func (self *Kin) schemaToBody(key string, schema *openapi3.Schema) (*generated.Body, string, error) {
	switch schema.Type {
	case "string":
		return nil, "string", nil
	case "number":
		return nil, "number", nil
	case "integer":
		return nil, "integer", nil
	case "boolean":
		return nil, "boolean", nil
	case "array":
		bdy, str, err := self.schemaRefToBody(key, schema.Items)
		if err != nil {
			return nil, "", err
		}
		if str != "" {
			return nil, "list(" + str + ")", nil
		}
		if self.extra == nil {
			self.extra = make(map[string]*generated.Body)
		}
		self.extra[key] = bdy
		return nil, "list(" + key + ")", nil
	default:
	}

	if schema.Properties == nil {
		if schema.AdditionalProperties.Schema != nil {
			_, str, err := self.schemaRefToBody(key, schema.AdditionalProperties.Schema)
			if err != nil {
				return nil, "", err
			}
			if str != "" {
				return nil, "map(" + str + ")", err
			}
			return nil, "map(" + key + ")", nil
		} else if schema.AdditionalProperties.Has != nil {
			return nil, "map(any)", nil
		}
		return nil, "map(false)", nil
	}

	var body = &generated.Body{}
	for k, v := range schema.Properties {
		bdy, str, err := self.schemaRefToBody(k, v)
		if err != nil {
			return nil, "", err
		}
		if bdy == nil {
			if body.Attributes == nil {
				body.Attributes = make(map[string]*generated.Attribute)
			}
			body.Attributes[k] = &generated.Attribute{
				Name: k,
				Expr: stringToExpression(str),
			}
		} else {
			block := &generated.Block{
				Type: k,
				Bdy:  bdy,
			}
			body.Blocks = append(body.Blocks, block)
		}
	}

	return body, "", nil
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

func (self *Kin) schemaRefToBody(key string, v *openapi3.SchemaRef) (*generated.Body, string, error) {
	if v.Ref != "" {
		log.Printf("relative ref %s, ignore\n", v.Ref)
		rel, err := getStructName(v.Ref)
		if err != nil {
			return nil, "", err
		}
		bs, err := v.Value.MarshalJSON()
		if err != nil {
			return nil, "", err
		}
		log.Printf("value %s\n", bs)
		return nil, rel, nil
	}
	return self.schemaToBody(key, v.Value)
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
			hcl, err := light.Hcl(body)
			if err != nil {
				return err
			}
			fmt.Fprintf(f, "components schema \"%s\" {%s}\n\n", key, hcl)
		}
	}

	fmt.Fprintf(f, "var {\n")
	for key, val := range components.Parameters {
		_, str, err := self.schemaRefToBody(key, val.Value.Schema)
		if err != nil {
			return err
		}
		fmt.Fprintf(f, "  %s = %s\n", key, str)
	}
	fmt.Fprintf(f, "}\n\n")

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
			fmt.Fprintf(f, "  request = %s\n", twoSpace(req))
			fmt.Fprintf(f, "  response = %s\n", twoSpace(res))
			fmt.Fprintf(f, "}\n\n")
		}
	}

	return nil
}

func twoSpace(s []byte) string {
	lines := strings.Split(string(s), "\n")
	for i, line := range lines {
		lines[i] = "  " + line
	}
	return strings.Join(lines, "\n")
}

func (self *Kin) getRR(op *openapi3.Operation) ([]byte, []byte, error) {
	var bsRequest, bsResponse []byte
	var bdy *generated.Body
	var str string
	var err error

	if op.RequestBody != nil {
		bdy, str, err = self.schemaRefToBody("", op.RequestBody.Value.Content["application/json"].Schema)
		if err == nil {
			if bdy == nil {
				bsRequest = []byte(str)
			} else {
				bsRequest, err = light.Hcl(bdy)
			}
		}
	}
	if op.Responses != nil {
		bdy, str, err = self.schemaRefToBody("", op.Responses.Value("200").Value.Content["application/json"].Schema)
		if err == nil {
			if bdy == nil {
				bsResponse = []byte(str)
			} else {
				bsResponse, err = light.Hcl(bdy)
			}
		}
	}

	return bsRequest, bsResponse, err
}
