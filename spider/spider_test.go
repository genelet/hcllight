package spider

import (
	"testing"
)

func TestSpider(t *testing.T) {
	spd, err := NewSpiderFromFiles("petstore.json", "generator.yml", "tf_data.hcl")
	if err != nil {
		t.Fatal(err)
	}

	/*
		key: [pet resource], value: {"category":{"id":1,"name":"Animal"},"id":123,"name":"doggie","photoUrls":["http://localhost/1","http://localhost/2"],"status":"available","tags":[{"id":12,"name":"cat"},{"id":12,"name":"cat"}]}
		url: /api/v3, path: /pet, method: POST
		key: [order data], value: {"orderId":2}
		url: /api/v3, path: /store/order/2, method: GET
	*/
	for k, v := range spd.Collections {
		if k[0] == "pet" && k[1] == "resource" {
			if v.myURL.String() != "/api/v3" || v.Path != "/pet" || v.Method != "POST" {
				t.Errorf("key: %v, value: %s\n", k, v.RequestBodyData)
				t.Errorf("url: %v, path: %s, method: %s\n", v.myURL.String(), v.Path, v.Method)
			}
		}
		if k[0] == "order" && k[1] == "data" {
			if v.myURL.String() != "/api/v3" || v.Path != "/store/order/2" || v.Method != "GET" {
				t.Errorf("key: %v, value: %s\n", k, v.RequestBodyData)
				t.Errorf("url: %v, path: %s, method: %s\n", v.myURL.String(), v.Path, v.Method)
			}
		}
	}
}
