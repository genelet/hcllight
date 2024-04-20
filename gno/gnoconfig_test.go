package gno

import (
	"os"
	"testing"

	"github.com/genelet/hcllight/light"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func TestGnoConfigGenerator(t *testing.T) {
	bs, err := os.ReadFile("generator_config.yml")
	if err != nil {
		t.Fatal(err)
	}

	config, err := ParseConfig(bs)
	if err != nil {
		t.Fatal(err)
	}

	data, err := os.ReadFile("openapi.json")
	doc, err := openapiv3.ParseDocument(data)
	if err != nil {
		t.Fatal(err)
	}

	gc, err := config.NewGnoConfig(doc)
	if err != nil {
		t.Fatal(err)
	}

	//t.Errorf("%#v", gc.GnoProvider)
	//t.Errorf("%#v", gc.GnoResources)
	//t.Errorf("%#v", gc.GnoDataSources)

	body, err := gc.BuildHCL()
	if err != nil {
		t.Fatal(err)
	}
	bs, err = light.Hcl(body)
	if err != nil {
		t.Fatal(err)
	}
	t.Errorf("%s", bs)
}
