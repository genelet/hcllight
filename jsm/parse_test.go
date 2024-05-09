package jsm

import (
	"os"
	"testing"

	"github.com/google/gnostic/jsonschema"
	//"github.com/k0kubun/pp/v3"
)

func TestParseSchema(t *testing.T) {
	s, err := jsonschema.NewSchemaFromFile("schema_v30.yaml")
	if err != nil {
		t.Fatalf("Error parsing schema: %v", err)
	}
	hcl := ToHcl(s)
	//t.Errorf("Schema: %s", s.String())
	body, err := hcl.toBody()
	if err != nil {
		t.Fatalf("Error converting schema to expression: %v", err)
	}
	data, err := body.Hcl()
	if err != nil {
		t.Fatalf("Error converting expression to HCL: %v", err)
	}
	err = os.WriteFile("schema_v30.hcl", data, 0644)
	if err != nil {
		t.Fatalf("Error writing HCL: %v", err)
	}
	t.Errorf("1")
}
