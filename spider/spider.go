// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//

package spider

import (
	"net/http"
	"net/url"
	"os"

	"github.com/genelet/hcllight/hcl"
	"github.com/genelet/hcllight/light"
	"github.com/genelet/kinet/micro"
)

// Spider represents a generator Spider.
type Spider struct {
	Provider *Provider              `hcl:"provider,block"`
	Data     map[string]*Collection `hcl:"data,block"`
	Resource map[string]*Collection `hcl:"resource,block"`
	Cleanup  map[string]*Collection `hcl:"cleanup,block"`
	doc      *hcl.Document
}

// NewSpiderFromFiles takes in three file paths, one for the OpenAPI spec, one for the generator config, and one for the input.
// It returns a Spider struct or an error if one occurs.
func NewSpiderFromFiles(openapi, generator, input string) (*Spider, error) {
	config, err := ParseConfigFromFiles(openapi, generator)
	if err != nil {
		return nil, err
	}
	bs, err := os.ReadFile(input)
	if err != nil {
		return nil, err
	}
	return NewSpider(config, bs)
}

// NewSpider takes in a Config struct and a byte array, unmarshals into a Spider struct.
func NewSpider(bc *Config, bs []byte) (*Spider, error) {
	spd, err := newSpiderFromBeacon(bc)
	if err != nil {
		return nil, err
	}
	doc, err := light.Parse(bs)
	if err != nil {
		return nil, err
	}

	for _, block := range doc.Blocks {
		if block.Type == "resource" {
			key := block.Labels[0]
			collection, ok := spd.Resource[key]
			if !ok {
				continue
			}
			err := collection.validateRequest(block.Bdy)
			if err != nil {
				return nil, err
			}
			spd.Resource[key] = collection
		}
		if block.Type == "data" {
			key := block.Labels[0]
			collection, ok := spd.Data[key]
			if !ok {
				continue
			}
			err := collection.validateRequest(block.Bdy)
			if err != nil {
				return nil, err
			}
			spd.Data[key] = collection
		}
		if block.Type == "cleanup" {
			key := block.Labels[0]
			collection, ok := spd.Cleanup[key]
			if !ok {
				continue
			}
			err := collection.validateRequest(block.Bdy)
			if err != nil {
				return nil, err
			}
			spd.Cleanup[key] = collection
		}
	}
	return spd, nil
}

func newSpiderFromBeacon(bc *Config) (*Spider, error) {
	myURL, err := bc.doc.GetDefaultServer()
	if err != nil {
		return nil, err
	}

	spd := &Spider{Provider: bc.Provider, doc: bc.GetDocument()}
	var data, resource, cleanup map[string]*Collection
	if bc.Resources != nil {
		resource = make(map[string]*Collection)
		for k, v := range bc.Resources {
			create := v.Create
			if create == nil {
				continue
			}
			create.doc = bc.doc
			resource[k], err = create.toCollection()
			if err != nil {
				return nil, err
			}
			resource[k].myURL = myURL
		}
	}
	if bc.DataSources != nil {
		data = make(map[string]*Collection)
		for k, v := range bc.DataSources {
			read := v.Read
			if read == nil {
				continue
			}
			read.doc = bc.doc
			data[k], err = read.toCollection()
			if err != nil {
				return nil, err
			}
			data[k].myURL = myURL
		}
	}
	if bc.Cleanups != nil {
		cleanup = make(map[string]*Collection)
		for k, v := range bc.Cleanups {
			delett := v.Delete
			if delett == nil {
				continue
			}
			delett.doc = bc.doc
			cleanup[k], err = delett.toCollection()
			if err != nil {
				return nil, err
			}
			cleanup[k].myURL = myURL
		}
	}

	spd.Data = data
	spd.Resource = resource
	spd.Cleanup = cleanup

	return spd, nil
}

func (self *Spider) GetDocument() *hcl.Document {
	return self.doc
}

func (self *Spider) GetLocation(caller *url.URL, className, serviceName string, index interface{}) (micro.Resolver, *url.URL, error) {
	doc := self.GetDocument()
	if doc == nil {
		return new(Spider), caller, nil
	}
	u, err := doc.GetDefaultServer()
	if err != nil {
		return nil, nil, err
	}
	return new(Collection), u, nil
}

func serviceNameFromKey2(name, key string) string {
	return name + "Service" + key
}

func (self *Spider) makeSpec() (*micro.Struct, error) {
	resource := make(map[string][2]interface{})
	for k := range self.Resource {
		resource[k] = [2]interface{}{"Collection", map[string]interface{}{
			"Response": []string{"Response", serviceNameFromKey2("resource", k)},
		}}
	}
	data := make(map[string][2]interface{})
	for k := range self.Data {
		data[k] = [2]interface{}{"Collection", map[string]interface{}{
			"Response": []string{"Response", serviceNameFromKey2("data", k)},
		}}
	}
	Cleanup := make(map[string][2]interface{})
	for k := range self.Cleanup {
		Cleanup[k] = [2]interface{}{"Collection", map[string]interface{}{
			"Response": []string{"Response", serviceNameFromKey2("cleanup", k)},
		}}
	}
	return micro.NewStruct("Spider", map[string]interface{}{
		"Data":     data,
		"Resource": resource,
		"Cleanup":  Cleanup,
	})
}

func (self *Spider) getNative(rest ...interface{}) map[string]micro.Microservice {
	var client *http.Client
	var headers map[string][]string
	if rest != nil && len(rest) == 2 {
		client = rest[0].(*http.Client)
		headers = rest[1].(map[string][]string)
	} else if rest != nil && len(rest) == 1 {
		client = rest[0].(*http.Client)
	}
	if client == nil {
		client = http.DefaultClient
	}

	microservices := make(map[string]micro.Microservice)
	for k, v := range self.Resource {
		response := new(ResponseService)
		response.SetResponseBody(v.responseBody)
		response.SetResponseHeaders(v.responseHeaders)
		response.SetRequestBodyData(v.RequestBodyData)
		response.SetRequestHeadersData(v.RequestHeadersData)
		response.SetLocation(v.location)
		response.SetMethod(v.Method)
		response.SetClient(client)
		if headers != nil {
			response.headers = headers
		}
		microservices[serviceNameFromKey2("resource", k)] = response
	}
	for k, v := range self.Data {
		response := new(ResponseService)
		response.SetResponseBody(v.responseBody)
		response.SetResponseHeaders(v.responseHeaders)
		response.SetRequestBodyData(v.RequestBodyData)
		response.SetRequestHeadersData(v.RequestHeadersData)
		response.SetLocation(v.location)
		response.SetMethod(v.Method)
		response.SetClient(client)
		if headers != nil {
			response.headers = headers
		}
		microservices[serviceNameFromKey2("data", k)] = response
	}
	for k, v := range self.Cleanup {
		response := new(ResponseService)
		response.SetResponseBody(v.responseBody)
		response.SetResponseHeaders(v.responseHeaders)
		response.SetRequestBodyData(v.RequestBodyData)
		response.SetRequestHeadersData(v.RequestHeadersData)
		response.SetLocation(v.location)
		response.SetMethod(v.Method)
		response.SetClient(client)
		if headers != nil {
			response.headers = headers
		}
		microservices[serviceNameFromKey2("cleanup", k)] = response
	}

	return microservices
}

func (self *Spider) NewFileService(myURL *url.URL, rest ...interface{}) (*micro.Locked, error) {
	serviceRef := self.getNative(rest...)
	spec, err := self.makeSpec()
	if err != nil {
		return nil, err
	}
	fs := micro.NewFiledisk(self, myURL, spec)
	locked := micro.NewLocked(fs, serviceRef)
	locked.Conf = self
	locked.Force = true
	return locked, nil
}
