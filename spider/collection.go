// Copyright (c) Greetingland LLC
// MIT License

package spider

import (
	"bytes"
	"context"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"

	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"

	"github.com/genelet/determined/convert"
	"github.com/genelet/determined/dethcl"
)

// Collection represents a generator Collection.
type Collection struct {
	location            *OpenApiSpecLocation
	myURL               *url.URL
	Path                string
	Query               url.Values
	Method              string
	parameters          []*hcl.Parameter
	request             *hcl.SchemaObject
	requestRequired     bool
	RequestData         []byte
	RequestHeadersData  map[string][]string
	responseBody        *hcl.SchemaObject
	responseHeaders     *hcl.SchemaObject
	ResponseBodyData    map[string]interface{}
	ResponseHeadersData map[string][]string
}

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

	if headers == nil {
		req.Header = self.RequestHeadersData
	} else {
		req.Header = mergeHeaders(self.RequestHeadersData, headers[0])
	}

	res, err := client.Do(req)
	if err != nil {
		return err
	}

	err = self.validateResponseHeaders(res.Header)
	if err != nil {
		return err
	}

	body, err := io.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		return err
	}
	if self.location != nil && self.location.ResponseStatusCode != nil && (*self.location.ResponseStatusCode == res.StatusCode || *self.location.ResponseStatusCode == -1) {
		err = self.validateResponseBody(body)
	} else if res.StatusCode < 200 || res.StatusCode >= 300 {
		return fmt.Errorf("%d: %s", res.StatusCode, body)
	} else {
		err = self.validateResponseBody(body)
	}

	return err
}

func (self *Collection) validateResponseHeaders(headers http.Header) error {
	if self.responseHeaders == nil {
		return nil
	}
	updated := make(map[string][]string)
	var names []string
	for k, v := range headers {
		if self.responseHeaders.Properties[k] != nil {
			updated[k] = v
			names = append(names, k)
		}
	}
	var missings []string
	for _, key := range self.responseHeaders.Required {
		if !grep(names, key) {
			missings = append(missings, key)
		}
	}
	if len(missings) > 0 {
		return fmt.Errorf("missing required headers: %v", missings)
	}
	if len(updated) > 0 {
		self.ResponseHeadersData = updated
	}
	return nil
}

func (self *Collection) bodyToMap(body []byte) (map[string]interface{}, error) {
	var data map[string]interface{}
	var err error
	if self.location.ResponseMediaType == nil {
		switch *self.location.ResponseMediaType {
		case "application/json":
			err = json.Unmarshal(body, &data)
		case "application/xml":
			err = xml.Unmarshal(body, &data)
		case "application/hcl":
			err = dethcl.Unmarshal(body, &data)
		case "application/x-www-form-urlencoded":
			x, err1 := url.ParseQuery(string(body))
			if err1 != nil {
				err = err1
			} else {
				data = make(map[string]interface{})
				for k, v := range x {
					data[k] = v
				}
			}
		case "plain/text":
			data = map[string]interface{}{
				"plain": string(body),
			}
		default:
		}
	} else {
		data = map[string]interface{}{
			"unknown": string(body),
		}
	}
	return data, err
}

func (self *Collection) validateResponseBody(body []byte) error {
	data, err := self.bodyToMap(body)
	if err != nil {
		return err
	}
	if self.responseBody == nil {
		self.ResponseBodyData = data
		return nil
	}

	updated := make(map[string]interface{})
	var names []string
	for k, v := range data {
		if schema, ok := self.responseBody.Properties[k]; ok {
			err = validateInterfaceBySchemaOrReference(v, schema)
			if err != nil {
				return err
			}
			updated[k] = v
			names = append(names, k)
		}
	}
	var missings []string
	for _, key := range self.responseBody.Required {
		if !grep(names, key) {
			missings = append(missings, key)
		}
	}
	if len(missings) > 0 {
		return fmt.Errorf("missing required fields in response: %v", missings)
	}
	if len(updated) > 0 {
		self.ResponseBodyData = updated
	}
	return nil
}

func validateInterfaceBySchemaOrReference(_ interface{}, _ *hcl.SchemaOrReference) error {
	return nil
}
