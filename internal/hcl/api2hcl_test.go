package hcl

import (
	"os"
	"testing"

	"github.com/genelet/determined/dethcl"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func TestApi2Hcl(t *testing.T) {
	data, err := os.ReadFile("openapi.json")
	doc, err := openapiv3.ParseDocument(data)
	if err != nil {
		t.Fatal(err)
	}

	api := DocumentToHcl(doc)

	bs, err := dethcl.Marshal(api)
	if err != nil {
		t.Fatal(err)
	}
	if len(string(bs)) != 32582 {
		t.Errorf("%d=>%s", len(string(bs)), bs)
	}
}
