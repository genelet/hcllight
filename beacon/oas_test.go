package beacon

import (
	"os"
	"testing"

	"github.com/genelet/hcllight/hcl"
)

func getbc(t *testing.T) *Config {
	bs, err := os.ReadFile("generator_config.yml")
	if err != nil {
		t.Fatal(err)
	}
	bc, err := ParseConfig(bs, "yaml")
	if err != nil {
		t.Fatal(err)
	}

	data, err := os.ReadFile("petstore.json")
	if err != nil {
		t.Fatal(err)
	}
	doc, err := hcl.ParseDocument([]byte(data), "json")
	if err != nil {
		t.Fatal(err)
	}

	bc.SetDocument(doc)
	return bc
}

func TestOas(t *testing.T) {
	bc := getbc(t)

	bs, err := os.ReadFile("tf_data.hcl")
	if err != nil {
		t.Fatal(err)
	}
	oas, err := NewOas(bc, bs)
	if err != nil {
		t.Fatal(err)
	}

	/*
		key: [pet resource], value: {"category":{"id":1,"name":"Animal"},"id":123,"name":"doggie","photoUrls":["http://localhost/1","http://localhost/2"],"status":"available","tags":[{"id":12,"name":"cat"},{"id":12,"name":"cat"}]}
		url: /api/v3, path: /pet, method: POST
		key: [order data], value: {"orderId":2}
		url: /api/v3, path: /store/order/2, method: GET
	*/
	for k, v := range oas.Collections {
		if k[0] == "pet" && k[1] == "resource" {
			if v.myURL.String() != "/api/v3" || v.Path != "/pet" || v.Method != "POST" {
				t.Errorf("key: %v, value: %s\n", k, v.RequestData)
				t.Errorf("url: %v, path: %s, method: %s\n", v.myURL.String(), v.Path, v.Method)
			}
		}
		if k[0] == "order" && k[1] == "data" {
			if v.myURL.String() != "/api/v3" || v.Path != "/store/order/2" || v.Method != "GET" {
				t.Errorf("key: %v, value: %s\n", k, v.RequestData)
				t.Errorf("url: %v, path: %s, method: %s\n", v.myURL.String(), v.Path, v.Method)
			}
		}
	}
}
