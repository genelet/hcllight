package gno

import (
	"fmt"
	"net/url"
	"os"
	"strings"

	"github.com/genelet/hcllight/generated"
	"github.com/genelet/hcllight/light"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
	"gopkg.in/yaml.v3"
	//"github.com/k0kubun/pp/v3"
)

type Gno struct {
	doc     *openapiv3.Document
	address *url.URL
	ref     map[string]*generated.Body
	extra   map[string]*generated.Body
}

// NewGno creates a new Gno object from a byte slice of an OpenAPI 3.0 document.
func NewGno(bs []byte) (*Gno, error) {
	doc, err := openapiv3.ParseDocument(bs)
	if err != nil {
		return nil, err
	}
	u := "/"
	if doc.Servers != nil && doc.Servers[0].Url != "" {
		u = doc.Servers[0].Url
	}
	address, err := url.Parse(u)
	if err != nil {
		return nil, err
	}
	return &Gno{
		doc:     doc,
		address: address,
		ref:     make(map[string]*generated.Body),
	}, nil
}

func (self *Gno) YAMLValue(comment string) ([]byte, error) {
	return self.doc.YAMLValue(comment)
}

func reportNode(node *yaml.Node, f func(*yaml.Node) string) string {
	switch node.Kind {
	case yaml.ScalarNode:
		return f(node)
	case yaml.SequenceNode:
		var arr []string
		for _, n := range node.Content {
			arr = append(arr, reportNode(n, f))
		}
		return `[` + strings.Join(arr, ", ") + `]`
	case yaml.MappingNode:
		var arr []string
		for i := 0; i < len(node.Content); i += 2 {
			key := f(node.Content[i])
			value := reportNode(node.Content[i+1], f)
			arr = append(arr, key+" = "+value)
		}
		return `{` + strings.Join(arr, ", ") + `}`
	case yaml.AliasNode:
		return f(node)
	case yaml.DocumentNode:
		return reportNode(node.Content[0], f)
	default:
	}
	return ""
}

func loopNode(node *yaml.Node, f func(*yaml.Node) error) error {
	switch node.Kind {
	case yaml.ScalarNode:
		return f(node)
	case yaml.SequenceNode:
		for _, n := range node.Content {
			err := loopNode(n, f)
			if err != nil {
				return err
			}
		}
	case yaml.MappingNode:
		for i := 0; i < len(node.Content); i += 2 {
			err := f(node.Content[i])
			if err != nil {
				return err
			}
			err = loopNode(node.Content[i+1], f)
			if err != nil {
				return err
			}
		}
	case yaml.AliasNode:
		return f(node)
	case yaml.DocumentNode:
		return loopNode(node.Content[0], f)
	default:
	}
	return nil
}

func (self *Gno) DocumentNode(data []byte) (*yaml.Node, error) {
	var ymlNode yaml.Node
	err := yaml.Unmarshal(data, &ymlNode)
	if err != nil {
		return nil, err
	}
	f1 := func(node *yaml.Node) error {
		//fmt.Printf("node: %#v\n", node)
		return nil
	}
	err = loopNode(&ymlNode, f1)
	//pp.Println(ymlNode)
	f11 := func(node *yaml.Node) string {
		return node.Value
	}
	str := reportNode(&ymlNode, f11)
	fmt.Printf("str: %s\n", str)
	rawInfo := self.doc.ToRawInfo()
	f2 := func(node *yaml.Node) error {
		//fmt.Printf("%v\n", node)
		return nil
	}
	err = loopNode(rawInfo, f2)
	return rawInfo, err
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

func (self *Gno) schemaToBody(key string, schema *openapiv3.Schema) (*generated.Body, *openapiv3.Schema, error) {
	switch schema.Type {
	case "string", "number", "integer", "boolean":
		return nil, schema, nil
	case "array":
		bdy, s, err := self.schemaRefToBody(key, schema.Items.SchemaOrReference[0])
		if err != nil {
			return nil, nil, err
		}
		if bdy == nil {
			schema.Type = "list(" + s.Type + ")"
			return nil, schema, nil
		}
		if self.extra == nil {
			self.extra = make(map[string]*generated.Body)
		}
		self.extra[key] = bdy
		schema.Type = "list(" + key + ")"
		return nil, schema, nil
	default:
	}

	if schema.Properties == nil && schema.AdditionalProperties != nil {
		typ := "{}"
		additionalPropertiesItem := schema.AdditionalProperties
		if x := additionalPropertiesItem.GetBoolean(); x != false {
			typ = "any"
		} else if x := additionalPropertiesItem.GetSchemaOrReference(); x != nil {
			_, s, err := self.schemaRefToBody(key, x)
			if err != nil {
				return nil, nil, err
			}
			if s == nil {
				typ = key
			} else {
				typ = s.Type
			}
		}
		schema.Type = "object(string," + typ + ")"
		return nil, schema, nil
	}

	var body = &generated.Body{}
	if x := schema.Properties; x != nil {
		for _, namedSchemaOrReference := range x.AdditionalProperties {
			k := namedSchemaOrReference.Name
			bdy, s, err := self.schemaRefToBody(k, namedSchemaOrReference.Value)
			if err != nil {
				return nil, s, err
			}
			if bdy == nil {
				if body.Attributes == nil {
					body.Attributes = make(map[string]*generated.Attribute)
				}
				body.Attributes[k] = &generated.Attribute{
					Name: k,
					Expr: stringToExpression(s.Type),
				}
			} else {
				block := &generated.Block{
					Type: k,
					Bdy:  bdy,
				}
				body.Blocks = append(body.Blocks, block)
			}
		}
	}

	return body, nil, nil
}

func (self *Gno) schemaRefToBody(key string, v *openapiv3.SchemaOrReference) (*generated.Body, *openapiv3.Schema, error) {
	if x := v.GetReference(); x != nil {
		rel, err := getStructName(x.GetXRef())
		return nil, &openapiv3.Schema{Type: rel}, err
	}
	return self.schemaToBody(key, v.GetSchema())
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
func (self *Gno) Build() error {
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

	if components.Schemas != nil {
		for _, named := range components.Schemas.AdditionalProperties {
			key := named.Name
			val := named.Value
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
	}

	if components.Parameters != nil {
		for _, named := range components.Parameters.AdditionalProperties {
			key := named.Name
			parameterOrReference := named.Value
			if x := parameterOrReference.GetReference(); x != nil {
				rel, err := getStructName(x.GetXRef())
				if err != nil {
					return err
				}
				fmt.Fprintf(f, "components parameter \"%s\" {\n  type = %s\n}\n\n", key, rel)
				continue
			} else if x := parameterOrReference.GetParameter(); x != nil {
				_, s, err := self.schemaRefToBody(key, x.Schema)
				if err != nil {
					return err
				}
				fmt.Fprintf(f, "variables \"%s\" {\n  type = %s\n", key, s.Type)
				if s.Description != "" {
					fmt.Fprintf(f, "  description = %s\n", s.Description)
				}
				fmt.Fprintf(f, "}\n\n")
			}
		}
	}

	for _, namedPathItem := range self.doc.Paths.Path {
		path := namedPathItem.Name
		item := namedPathItem.Value
		hash := map[string]*openapiv3.Operation{
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

func (self *Gno) getRR(op *openapiv3.Operation) ([]byte, []byte, error) {
	var bsRequest, bsResponse []byte
	var bdy *generated.Body
	var s *openapiv3.Schema
	var err error

	if x := op.RequestBody; x != nil {
		if x.GetReference() != nil {
			rel, err := getStructName(x.GetReference().GetXRef())
			if err != nil {
				return nil, nil, err
			}
			bsRequest = []byte(rel)
		} else if x.GetRequestBody(); x != nil {
			bdy, s, err = self.schemaRefToBody("", x.GetRequestBody().Content.AdditionalProperties[0].Value.Schema)
			if err == nil {
				if bdy == nil {
					bsRequest = []byte(s.Type)
				} else {
					bsRequest, err = light.Hcl(bdy)
				}
			}
		}
	}
	if op.Responses != nil && op.Responses.ResponseOrReference != nil && len(op.Responses.ResponseOrReference) > 0 {
		x := op.Responses.ResponseOrReference[0].Value
		if x.GetReference() != nil {
			rel, err := getStructName(x.GetReference().GetXRef())
			if err != nil {
				return nil, nil, err
			}
			bsResponse = []byte(rel)
		} else if x.GetResponse(); x != nil {
			bdy, s, err = self.schemaRefToBody("", x.GetResponse().Content.AdditionalProperties[0].Value.Schema)
			if err == nil {
				if bdy == nil {
					bsResponse = []byte(s.Type)
				} else {
					bsResponse, err = light.Hcl(bdy)
				}
			}
		}
	}

	return bsRequest, bsResponse, err
}
