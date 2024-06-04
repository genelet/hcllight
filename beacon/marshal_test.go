package beacon

import (
	"os"
	"testing"

	"github.com/genelet/hcllight/hcl"
)

func TestConfigGenerator(t *testing.T) {
	bs, err := os.ReadFile("generator_config.yml")
	if err != nil {
		t.Fatal(err)
	}

	config, err := ParseConfig(bs, "yaml")
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

	config.SetDocument(doc)

	bs, err = config.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	t.Errorf("%s", bs)
}
