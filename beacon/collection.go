// Copyright (c) Greetingland LLC
// MIT License

package beacon

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"

	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"

	"github.com/genelet/determined/convert"
)

// Collection represents a generator Collection.
type Collection struct {
	myURL           *url.URL
	Path            string
	Query           url.Values
	Method          string
	parameters      []*hcl.Parameter
	request         *hcl.SchemaObject
	requestRequired bool
	RequestData     []byte
	response        *hcl.SchemaObject
	ResponseData    []byte
}

func (self *Collection) SetMyURL(u *url.URL) {
	self.myURL = u
}

func (self *Collection) GetMyURL() *url.URL {
	return self.myURL
}

func (self *Collection) checkBody(body *light.Body) error {
	if body == nil {
		return nil
	}

	_, path, query, _, _ := parametersToParametersMap(self.parameters)
	schemaMap := self.request

	attributes := make(map[string]*light.Attribute)
	var blocks []*light.Block
	args_path := make(map[string]interface{})
	args_query := make(map[string]interface{})
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
		body = &light.Body{
			Blocks: blocks,
		}
		if len(attributes) > 0 {
			body.Attributes = attributes
		}

		bs, err := body.Evaluate()
		if err != nil {
			return err
		}
		self.RequestData, err = convert.HCLToJSON(bs)
		if err != nil {
			return err
		}
	}
	if self.RequestData == nil && self.requestRequired {
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
			switch v.(type) {
			case []interface{}:
				for _, item := range v.([]interface{}) {
					self.Query.Add(k, fmt.Sprintf("%v", item))
				}
			default:
				self.Query.Add(k, fmt.Sprintf("%v", v))
			}
		}
	}

	return nil
}

// DoRequest sends a http request according to the Collection.
func (self *Collection) DoRequest(ctx context.Context, client *http.Client, headers ...map[string][]string) error {
	if self.myURL == nil {
		return fmt.Errorf("request url not found")
	}
	urlstr := self.myURL.String()

	var msg *bytes.Buffer
	if grep([]string{"POST", "UPDATE", "PATCH"}, self.Method) && self.RequestData != nil {
		msg = bytes.NewBuffer(self.RequestData)
	}

	req, err := http.NewRequestWithContext(ctx, self.Method, urlstr, msg)
	if err != nil {
		return err
	}
	if headers != nil {
		req.Header = headers[0]
	}

	res, err := client.Do(req)
	if err != nil {
		return err
	}
	body, err := io.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		return err
	}
	if res.StatusCode < 200 || res.StatusCode >= 300 {
		return fmt.Errorf("%d: %s", res.StatusCode, body)
	}
	self.ResponseData = body

	return nil
}
