package beacon

import (
	"os"
	"testing"

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

	gc, err := NewGnoConfig(config, doc)
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
	bs, err = body.Hcl()
	if err != nil {
		t.Fatal(err)
	}
	t.Errorf("%s", bs)
}
