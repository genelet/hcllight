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
	oas, err := ParseOas(bc, bs)
	if err != nil {
		t.Fatal(err)
	}
	for k, v := range oas.Collections {
		t.Errorf("key: %s, value: %s\n", k, v.ReadRequestData)
		t.Errorf("key: %s, value: %s\n", k, v.WriteRequestData)
	}
}
