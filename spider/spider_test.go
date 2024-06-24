package spider

import (
	"context"
	"net/url"
	"os"
	"testing"

	"github.com/genelet/determined/dethcl"
	"github.com/genelet/kinet/micro"
)

func TestSpiderPlain(t *testing.T) {
	spd, err := NewSpiderFromFiles("petstore.json", "petgenerator.yml", "pettf_data.hcl")
	if err != nil {
		t.Fatal(err)
	}

	/*
		key: [pet resource], value: {"category":{"id":1,"name":"Animal"},"id":123,"name":"doggie","photoUrls":["http://localhost/1","http://localhost/2"],"status":"available","tags":[{"id":12,"name":"cat"},{"id":12,"name":"cat"}]}
		url: /api/v3, path: /pet, method: POST
		key: [order data], value: {"orderId":2}
		url: /api/v3, path: /store/order/2, method: GET
	*/
	for k, v := range spd.Resource {
		if k == "pet" {
			if v.myURL.String() != "/api/v3" || v.Path != "/pet" || v.Method != "POST" {
				t.Errorf("key: %v, value: %s\n", k, v.RequestBodyData)
				t.Errorf("url: %v, path: %s, method: %s\n", v.myURL.String(), v.Path, v.Method)
			}
		}
		for k, v := range spd.Data {
			if k == "order" {
				if v.myURL.String() != "/api/v3" || v.Path != "/store/order/2" || v.Method != "GET" {
					t.Errorf("key: %v, value: %s\n", k, v.RequestBodyData)
					t.Errorf("url: %v, path: %s, method: %s\n", v.myURL.String(), v.Path, v.Method)
				}
			}
		}
	}

	bs, err := dethcl.Marshal(spd)
	if err != nil {
		t.Fatal(err)
	}

	spd1 := new(Spider)
	err = dethcl.Unmarshal(bs, spd1)
	if err != nil {
		t.Fatal(err)
	}
	t.Errorf("%#v", spd1.Resource["pet"].RequestBodyData)
	for k, v := range spd1.Resource {
		if k == "pet" {
			if v.Path != "/pet" || v.Method != "POST" {
				t.Errorf("key: %v, value: %s\n", k, v.RequestBodyData)
				t.Errorf("url: %v, path: %s, method: %s\n", v.myURL.String(), v.Path, v.Method)
			}
		}
		for k, v := range spd.Data {
			if k == "order" {
				if v.Path != "/store/order/2" || v.Method != "GET" {
					t.Errorf("key: %v, value: %s\n", k, v.RequestBodyData)
					t.Errorf("url: %v, path: %s, method: %s\n", v.myURL.String(), v.Path, v.Method)
				}
			}
		}
	}

	bs1, err := dethcl.Marshal(spd1)
	if err != nil {
		t.Fatal(err)
	}

	if string(bs) != string(bs1) {
		t.Errorf("not equal: %s, %s", string(bs), string(bs1))
	}
}

func TestSpiderService(t *testing.T) {
	spd, err := NewSpiderFromFiles("petstore.json", "petgenerator.yml", "pettf_data.hcl")
	if err != nil {
		t.Fatal(err)
	}

	// Test the service
	u, err := url.Parse("file:///testdata/spider.hcl")
	if err != nil {
		t.Fatal(err)
	}
	svc, err := spd.NewFileService(u)
	if err != nil {
		t.Fatal(err)
	}
	svc.SetLogger(micro.DevelopLogger(os.Stdout))

	ctx := context.Background()
	err = svc.Read(ctx)
	if err != nil {
		t.Fatal(err)
	}

	bs, err := svc.Write(ctx)
	if err != nil {
		t.Fatal(err)
	}
	t.Errorf("%s", bs)
}

func TestBeaconConfig(t *testing.T) {
	spd, err := NewSpiderFromFiles("kinet_1v3.json", "generator.yml", "tf_data.hcl")
	if err != nil {
		t.Fatal(err)
	}

	u, err := url.Parse("file:///testdata/ping.hcl")
	if err != nil {
		t.Fatal(err)
	}

	ps, err := spd.NewFileService(u)
	if err != nil {
		t.Fatal(err)
	}
	ps.SetLogger(micro.DevelopLogger(os.Stdout))

	ctx := context.Background()
	err = ps.Read(ctx)
	if err != nil {
		t.Fatal(err)
	}

	spider := ps.GetObject().(*Spider)
	auth := spider.Resource["onboard"].Response.BodyData["auth"]
	t.Errorf("%#v", auth.(map[string]interface{})["client_token"])
	/*
		bs, err := ps.Write(ctx)
		if err != nil {
			t.Fatal(err)
		}
		t.Errorf("%s", bs)
	*/
}
