// Copyright (c) Greetingland LLC
// MIT License

package spider

import (
	"fmt"
	"net/url"
	"strings"

	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
	"github.com/genelet/kinet/micro"
)

// Collection represents a generator Collection.
type Collection struct {
	location           *OpenApiSpecLocation
	myURL              *url.URL
	Path               string     `hcl:"path,optional"`
	Query              url.Values `hcl:"query,optional"`
	Method             string     `hcl:"method,optional"`
	parameters         []*hcl.Parameter
	request            *hcl.SchemaObject
	requestRequired    bool
	RequestBodyData    *light.Body         `hcl:"request_body,block"`
	RequestHeadersData map[string][]string `hcl:"request_headers,optional"`
	responseBody       *hcl.SchemaObject
	responseHeaders    *hcl.SchemaObject
	*Response          `hcl:"response,block"`
}

func (self *Collection) GetLocation(caller *url.URL, _ string, _ string, _ interface{}) (micro.Resolver, *url.URL, error) {
	u := &(*caller)
	path := caller.Path
	if self.Path != "" {
		if strings.HasPrefix(self.Path, "/") {
			if strings.HasSuffix(path, "/") {
				path += self.Path[1:]
			} else {
				path += self.Path
			}
		} else if strings.HasSuffix(path, "/") {
			path += self.Path
		} else {
			path += "/" + self.Path
		}
	}
	u.Path = path
	return new(Response), u, nil
}

var _ micro.Resolver = (*Collection)(nil)

func (self *Collection) SetMyURL(u *url.URL) {
	self.myURL = u
}

func (self *Collection) GetMyURL() *url.URL {
	return self.myURL
}

func (self *Collection) validateRequest(body *light.Body) error {
	if body == nil {
		return nil
	}

	_, path, query, headers, cookies := parametersToParametersMap(self.parameters)
	schemaMap := self.request

	attributes := make(map[string]*light.Attribute)
	var blocks []*light.Block
	args_path := make(map[string]interface{})
	args_query := make(map[string]interface{})
	args_headers := make(map[string][]string)
	var allkeys []string

	if body.Attributes != nil {
		for k, attr := range body.Attributes {
			if path != nil && path[k] != nil {
				v, err := attr.ToNative()
				if err != nil {
					return err
				}
				args_path[k] = v
				allkeys = append(allkeys, k)
			} else if query != nil && query[k] != nil {
				v, err := attr.ToNative()
				if err != nil {
					return err
				}
				args_query[k] = v
				allkeys = append(allkeys, k)
			} else if headers != nil && headers[k] != nil {
				v, err := attr.ToNative()
				if err != nil {
					return err
				}
				switch t := v.(type) {
				case []interface{}:
					for _, item := range t {
						args_headers[k] = append(args_headers[k], fmt.Sprintf("%v", item))
					}
				case []string:
					args_headers[k] = t
				default:
					args_headers[k] = []string{fmt.Sprintf("%v", v)}
				}
				allkeys = append(allkeys, k)
			} else if cookies != nil && cookies[k] != nil {
				v, err := attr.ToNative()
				if err != nil {
					return err
				}
				args_headers["Cookie"] = append(args_headers["Cookie"], fmt.Sprintf("%s=%v", k, v))
				allkeys = append(allkeys, k)
			} else if schemaMap != nil && schemaMap.Properties[k] != nil {
				attributes[k] = attr
				allkeys = append(allkeys, k)
			}
		}
	}
	for _, b := range body.Blocks {
		k := b.Type
		if schemaMap != nil && schemaMap.Properties[k] != nil {
			blocks = append(blocks, b)
			allkeys = append(allkeys, k)
		}
	}

	var missings []string
	if schemaMap != nil {
		for _, key := range schemaMap.Required {
			if !grep(allkeys, key) {
				missings = append(missings, key)
			}
		}
	}
	if len(path) > 0 {
		for k, parameter := range path {
			if parameter.Required && !grep(allkeys, k) {
				missings = append(missings, k)
			}
		}
	}
	if len(query) > 0 {
		for k, parameter := range query {
			if parameter.Required && !grep(allkeys, k) {
				missings = append(missings, k)
			}
		}
	}
	if len(missings) > 0 {
		return fmt.Errorf("missing required fields: %v", missings)
	}

	if len(blocks) > 0 || len(attributes) > 0 {
		self.RequestBodyData = &light.Body{
			Blocks: blocks,
		}
		if len(attributes) > 0 {
			self.RequestBodyData.Attributes = attributes
		}
	}
	if self.RequestBodyData == nil && self.requestRequired {
		return fmt.Errorf("missing required body: %v", schemaMap.Required)
	}

	if len(args_path) > 0 {
		arr := strings.Split(self.Path, "/")
		for i, item := range arr {
			if strings.HasPrefix(item, "{") && strings.HasSuffix(item, "}") {
				name := item[1 : len(item)-1]
				if _, ok := args_path[name]; !ok {
					return fmt.Errorf("missing required field in path: %v", name)
				}
				arr[i] = fmt.Sprintf("%v", args_path[name])
			}
		}
		self.Path = strings.Join(arr, "/")
	}

	if len(args_query) > 0 {
		self.Query = url.Values{}
		for k, v := range args_query {
			switch t := v.(type) {
			case []interface{}:
				for _, item := range t {
					self.Query.Add(k, fmt.Sprintf("%v", item))
				}
			case []string:
				for _, item := range t {
					self.Query.Add(k, item)
				}
			default:
				self.Query.Add(k, fmt.Sprintf("%v", v))
			}
		}
	}

	if len(args_headers) > 0 {
		self.RequestHeadersData = args_headers
	}

	return nil
}

func mergeHeaders(h1, h2 map[string][]string) map[string][]string {
	if h1 == nil {
		return h2
	}
	if h2 == nil {
		return h1
	}
	for k, v := range h2 {
		if arr, ok := h1[k]; ok {
			h1[k] = append(arr, v...)
		} else {
			h1[k] = v
		}
	}
	return h1
}
