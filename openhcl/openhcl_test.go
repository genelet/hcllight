package openhcl

import (
	"os"
	"testing"

	"github.com/genelet/determined/dethcl"
	"github.com/genelet/hcllight/internal/hcl"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
	//"github.com/k0kubun/pp/v3"
)

func TestOpenHcl(t *testing.T) {
	data, err := os.ReadFile("openapi.json")
	doc, err := openapiv3.ParseDocument(data)
	if err != nil {
		t.Fatal(err)
	}

	inter := hcl.DocumentToHcl(doc)
	api := NewDocument(inter)
	//pp.Println(api)
	bs, err := dethcl.Marshal(api)
	if err != nil {
		t.Fatal(err)
	}

	t.Errorf("%d=>%s", len(string(bs)), bs)

}
