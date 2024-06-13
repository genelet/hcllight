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
	myURL        *url.URL
	Path         string
	Query        url.Values
	Method       string
	Request      *hcl.SchemaObject
	RequestData  []byte
	Response     *hcl.SchemaObject
	ResponseData []byte
}

func (self *Collection) GetMyURL() *url.URL {
	return self.myURL
}

func (self *Collection) checkBody(body *light.Body) error {
	if body == nil {
		return nil
	}

	schemaMap := self.Request

	attributes := make(map[string]*light.Attribute)
	var blocks []*light.Block
	var allkeys []string
	args := make(map[string]interface{})

	if body.Attributes != nil {
		for k, attr := range body.Attributes {
			if _, ok := schemaMap.Properties[k]; ok {
				attributes[k] = attr
				allkeys = append(allkeys, k)
				v, err := attr.ToNative()
				if err != nil {
					return err
				}
				args[k] = v
			}
		}
	}
	for _, b := range body.Blocks {
		if _, ok := schemaMap.Properties[b.Type]; ok {
			blocks = append(blocks, b)
			allkeys = append(allkeys, b.Type)
		}
	}

	var missings []string
	for _, key := range schemaMap.Required {
		if !grep(allkeys, key) {
			missings = append(missings, key)
		}
	}
	if len(missings) > 0 {
		return fmt.Errorf("missing required fields: %v", missings)
	}

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

	arr := strings.Split(self.Path, "/")
	for i, item := range arr {
		if strings.HasPrefix(item, "{") && strings.HasSuffix(item, "}") {
			name := item[1 : len(item)-1]
			if _, ok := args[name]; !ok {
				return fmt.Errorf("missing required field in path: %v", name)
			}
			arr[i] = fmt.Sprintf("%v", args[name])
		} else {
			delete(args, item)
		}
	}
	self.Path = strings.Join(arr, "/")

	switch self.Method {
	case "GET", "DELETE":
		if len(args) > 0 {
			self.Query = url.Values{}
			for k, v := range args {
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
	default:
	}
	return nil
}

// DoRequest sends a http request according to the Collection.
func (self *Collection) DoRequest(ctx context.Context, client *http.Client, headers ...map[string][]string) error {
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
