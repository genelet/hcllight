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
)

type Collection struct {
	myURL              *url.URL
	Path               string
	Query              url.Values
	Method             string
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

func (self *Collection) checkBody(how string, body *light.Body) error {
	if body == nil {
		return nil
	}

	var schemaMap *hcl.SchemaObject
	switch how {
	case "read":
		schemaMap = self.ReadRequest
	case "write":
		schemaMap = self.WriteRequest
	case "delete":
		schemaMap = self.DeleteRequest
	default:
		return fmt.Errorf("unknown case: %s", how)
	}

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

	switch how {
	case "read":
		self.ReadRequestData = bs
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
	case "write":
		self.WriteRequestData = bs
	case "delete":
		self.DeleteRequestData = bs
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

func (self *Collection) GetLocation(caller *url.URL, _ string, _ string, _ interface{}) (*url.URL, error) {
	myURL := self.myURL
	if caller != nil {
		myURL = caller
	}

	u, err := myURL.Parse(self.Path)
	if err != nil {
		return nil, err
	}
	if self.Query != nil {
		u.RawQuery = self.Query.Encode()
	}
	return u, nil
}

func (self *Collection) DoRequest(ctx context.Context, client *http.Client, method string) ([]byte, error) {
	urlstr := self.myURL.String()

	msg := new(bytes.Buffer)
	if bs != nil {
		msg = bytes.NewBuffer(bs)
	}
	req, err := http.NewRequestWithContext(ctx, method, urlstr, msg)
	if err != nil {
		return nil, err
	}
	if self.token != "" {
		req.Header.Set("Authorization", "Bearer "+self.token)
	}

	res, err := self.client.Do(req)
	if err != nil {
		return nil, err
	}
	body, err := io.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		return nil, err
	}
	if res.StatusCode != 200 {
		return nil, fmt.Errorf("%d: %s", res.StatusCode, body)
	}

	return body, nil
}

func (self *Collection) Read(ctx context.Context, client *http.Client) error {

}
