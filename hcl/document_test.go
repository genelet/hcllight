package hcl

import (
	"os"
	"testing"

	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func TestApi2Hcl(t *testing.T) {
	data, err := os.ReadFile("twitter.json")
	doc, err := openapiv3.ParseDocument(data)
	if err != nil {
		t.Fatal(err)
	}

	api := DocumentFromApi(doc)

	bs, err := api.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	err = os.WriteFile("twitter.hcl", bs, 0644)
	if err != nil {
		t.Fatal(err)
	}
	//t.Errorf("%d=>%s", len(string(bs)), bs)
}
