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

	"github.com/genelet/determined/convert"
	"github.com/genelet/determined/dethcl"
	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
	"github.com/genelet/kinet/micro"
)

type Response struct {
	BodyData    map[string]interface{} `hcl:"body_data,block"`
	HeadersData map[string][]string    `hcl:"headers_data,optional"`
}

func (self *Response) GetLocation(caller *url.URL, _ string, _ string, _ interface{}) (micro.Resolver, *url.URL, error) {
	return new(Response), caller, nil
}

var _ micro.Resolver = (*Response)(nil)

type ResponseService struct {
	micro.Soliton
	client                        *http.Client
	headers                       map[string][]string
	method                        string
	requestBodyData               *light.Body
	requestHeadersData            map[string][]string
	responseBody, responseHeaders *hcl.SchemaObject
	location                      *OpenApiSpecLocation
}

var _ micro.Microservice = (*ResponseService)(nil)

func NewResponseService(object micro.Resolver, myURL *url.URL, rest ...interface{}) *ResponseService {
	var spec *micro.Struct
	var client *http.Client
	if rest != nil && len(rest) == 2 {
		spec = rest[0].(*micro.Struct)
		client = rest[1].(*http.Client)
	} else if rest != nil && len(rest) == 1 {
		client = rest[0].(*http.Client)
	}
	if client == nil {
		client = http.DefaultClient
	}

	soliton := micro.NewSoliton(object, myURL, spec)
	myc := &ResponseService{Soliton: *soliton, client: client}
	myc.Microservice = myc
	return myc
}

func (self *ResponseService) SetResponseBody(schema *hcl.SchemaObject) {
	self.responseBody = schema
}

func (self *ResponseService) GetResponseBody() *hcl.SchemaObject {
	return self.responseBody
}

func (self *ResponseService) SetResponseHeaders(schema *hcl.SchemaObject) {
	self.responseHeaders = schema
}

func (self *ResponseService) GetResponseHeaders() *hcl.SchemaObject {
	return self.responseHeaders
}

func (self *ResponseService) SetLocation(location *OpenApiSpecLocation) {
	self.location = location
}

func (self *ResponseService) GetLocation() *OpenApiSpecLocation {
	return self.location
}

func (self *ResponseService) SetMethod(method string) {
	self.method = method
}

func (self *ResponseService) GetMethod() string {
	return self.method
}

func (self *ResponseService) SetRequestBodyData(body *light.Body) {
	self.requestBodyData = body
}

func (self *ResponseService) GetRequestBodyData() *light.Body {
	return self.requestBodyData
}

func (self *ResponseService) SetRequestHeadersData(headers map[string][]string) {
	self.requestHeadersData = headers
}

func (self *ResponseService) GetRequestHeadersData() map[string][]string {
	return self.requestHeadersData
}

func (self *ResponseService) SetHeaders(headers map[string][]string) {
	self.headers = headers
}

func (self *ResponseService) GetHeaders() map[string][]string {
	return self.headers
}

func (self *ResponseService) SetClient(client *http.Client) {
	self.client = client
}

func (self *ResponseService) GetClient() *http.Client {
	return self.client
}

// Read data with data
func (self *ResponseService) ReadData(ctx context.Context, args ...interface{}) ([]byte, error) {
	return self.doRequest(ctx, "read")
}

// Write data with resource
func (self *ResponseService) WriteData(ctx context.Context, bs []byte, args ...interface{}) ([]byte, error) {
	//return self.doRequest(ctx, "write")
	return bs, nil
}

// Delete data with cleanup
func (self *ResponseService) DeleteData(ctx context.Context, args ...interface{}) ([]byte, error) {
	//return self.doRequest(ctx, "delete")
	return nil, nil
}

func (self *ResponseService) doRequest(ctx context.Context, current string) ([]byte, error) {
	msg := new(bytes.Buffer)
	if grep([]string{"POST", "UPDATE", "PATCH"}, self.method) && self.requestBodyData != nil {
		bs, err := self.bodyToMsg(self.requestBodyData)
		if err != nil {
			return nil, err
		}
		if bs != nil {
			msg = bytes.NewBuffer(bs)
		}
	}

	req, err := http.NewRequestWithContext(ctx, self.method, self.GetMyURL().String(), msg)
	if err != nil {
		return nil, err
	}
	headers := self.GetHeaders()
	if headers == nil {
		req.Header = self.requestHeadersData
	} else {
		req.Header = mergeHeaders(self.requestHeadersData, headers)
	}
	if req == nil {
		return nil, fmt.Errorf("req is nil")
	}
	client := self.GetClient()
	if client == nil {
		return nil, fmt.Errorf("client is nil")
	}

	res, err := client.Do(req)
	if err != nil {
		return nil, err
	}

	body, err := io.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		return nil, err
	}

	location := self.GetLocation()
	if location != nil && location.ResponseStatusCode != nil && (*location.ResponseStatusCode == res.StatusCode || *location.ResponseStatusCode == -1) {
		switch current {
		case "write", "delete":
			return nil, nil
		}
		err = self.validateResponse(body, res.Header)
	} else if res.StatusCode < 200 || res.StatusCode >= 300 {
		return nil, fmt.Errorf("%d: %s", res.StatusCode, body)
	} else {
		switch current {
		case "write", "delete":
			return nil, nil
		}
		err = self.validateResponse(body, res.Header)
	}
	if err != nil {
		return nil, err
	}

	bs, err := dethcl.Marshal(self.GetObject())
	if err != nil {
		return nil, err
	}

	return bs, nil
}

func (self *ResponseService) bodyToMsg(body *light.Body) ([]byte, error) {
	if body == nil {
		return nil, nil
	}

	bodyToJson := func(bdy *light.Body) ([]byte, error) {
		bs, err := bdy.Evaluate()
		if err == nil {
			bs, err = convert.HCLToJSON(bs)
		}
		return bs, err
	}

	var bs []byte
	var err error
	location := self.GetLocation()
	if location.RequestMediaType != nil {
		switch *location.RequestMediaType {
		case "application/json":
			bs, err = bodyToJson(body)
		case "application/xml":
			bs, err = bodyToJson(body)
			var data map[string]interface{}
			err = json.Unmarshal(bs, &data)
			if err == nil {
				bs, err = xml.Marshal(data)
			}
		case "application/hcl":
			bs, err = body.Evaluate()
		case "application/x-www-form-urlencoded":
			data := url.Values{}
			var v interface{}
			for k, attr := range body.Attributes {
				v, err = attr.ToNative()
				if err == nil {
					switch t := v.(type) {
					case []interface{}:
						for _, item := range t {
							data.Add(k, fmt.Sprintf("%v", item))
						}
					case []string:
						for _, item := range t {
							data.Add(k, item)
						}
					default:
						data.Add(k, fmt.Sprintf("%v", v))
					}
				}
			}
		default:
		}
	} else {
		bs, err = bodyToJson(body)
	}
	return bs, err
}

func (self *ResponseService) validateResponse(body []byte, headers http.Header) error {
	err := self.validateResponseBody(body)
	if err != nil {
		return err
	}
	err = self.validateResponseHeaders(headers)
	return err
}

func (self *ResponseService) validateResponseHeaders(headers http.Header) error {
	responseHeaders := self.responseHeaders
	if responseHeaders == nil {
		return nil
	}
	updated := make(map[string][]string)
	var names []string
	for k, v := range headers {
		if responseHeaders.Properties[k] != nil {
			updated[k] = v
			names = append(names, k)
		}
	}
	var missings []string
	for _, key := range responseHeaders.Required {
		if !grep(names, key) {
			missings = append(missings, key)
		}
	}
	if len(missings) > 0 {
		return fmt.Errorf("missing required headers: %v", missings)
	}
	if len(updated) > 0 {
		object := self.GetObject().(*Response)
		object.HeadersData = updated
	}
	return nil
}

func (self *ResponseService) msgToMap(bs []byte) (map[string]interface{}, error) {
	var data map[string]interface{}
	var err error
	location := self.GetLocation()
	if location != nil && location.ResponseMediaType != nil {
		switch *location.ResponseMediaType {
		case "application/json":
			err = json.Unmarshal(bs, &data)
		case "application/xml":
			err = xml.Unmarshal(bs, &data)
		case "application/hcl":
			err = dethcl.Unmarshal(bs, &data)
		case "application/x-www-form-urlencoded":
			x, err1 := url.ParseQuery(string(bs))
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
				"plain": string(bs),
			}
		default:
		}
	} else {
		data = map[string]interface{}{
			"unknown": string(bs),
		}
	}

	return data, err
}

func (self *ResponseService) validateResponseBody(bs []byte) error {
	hash, err := self.msgToMap(bs)
	if err != nil {
		return err
	}

	rspn := self.GetObject().(*Response)
	responseBody := self.responseBody
	if responseBody == nil {
		rspn.BodyData = hash
		self.SetObject(rspn)
		return nil
	}

	updated := make(map[string]interface{})
	var names []string
	for k, v := range hash {
		if schema, ok := responseBody.Properties[k]; ok {
			err = validateInterfaceBySchemaOrReference(v, schema)
			if err != nil {
				return err
			}
			if v != nil {
				updated[k] = v
				names = append(names, k)
			}
		}
	}
	var missings []string
	for _, key := range responseBody.Required {
		if !grep(names, key) {
			missings = append(missings, key)
		}
	}
	if len(missings) > 0 {
		return fmt.Errorf("missing required fields in response: %v", missings)
	}
	if len(updated) > 0 {
		rspn.BodyData = updated
		self.SetObject(rspn)
	}

	return nil
}

func validateInterfaceBySchemaOrReference(_ interface{}, _ *hcl.SchemaOrReference) error {
	return nil
}
