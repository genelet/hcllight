package beacon

import (
	"os"
	"testing"
)

func TestConfigGenerator(t *testing.T) {
	config, err := ParseConfigFromFiles("petstore.json", "generator_config.yml")
	if err != nil {
		t.Fatal(err)
	}

	bs, err := config.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	err = os.WriteFile("tf_config.hcl", bs, 0644)
	if err != nil {
		t.Fatal(err)
	}
}
