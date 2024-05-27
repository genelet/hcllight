package jsm

import (
	"os"
	"testing"
)

func TestParseSchemaJSON(t *testing.T) {
	s, err := os.ReadFile("openapi-3.1_gnostic.json")
	if err != nil {
		t.Fatalf("Error parsing schema: %v", err)
	}
	schema, err := ParseSchema(s, "json")
	if err != nil {
		t.Fatalf("Error parsing schema: %v", err)
	}

	data, err := schema.MarshalHCL()
	if err != nil {
		t.Fatalf("Error converting expression to HCL: %v", err)
	}
	err = os.WriteFile("openapi-3.1_gnostic.hcl", data, 0644)
	if err != nil {
		t.Fatalf("Error writing HCL: %v", err)
	}
}

func TestParseSchemaYAML(t *testing.T) {
	s, err := os.ReadFile("schema_v30.yaml")
	if err != nil {
		t.Fatalf("Error parsing schema: %v", err)
	}
	schema, err := ParseSchema(s, "yaml")
	if err != nil {
		t.Fatalf("Error parsing schema: %v", err)
	}

	data, err := schema.MarshalHCL()
	if err != nil {
		t.Fatalf("Error converting expression to HCL: %v", err)
	}
	err = os.WriteFile("schema_v30.hcl", data, 0644)
	if err != nil {
		t.Fatalf("Error writing HCL: %v", err)
	}
}

func TestParseHCL(t *testing.T) {
	bs, err := os.ReadFile("schema_v30.hcl")
	if err != nil {
		t.Fatalf("Error reading HCL: %v", err)
	}

	schema, err := ParseSchema(bs)
	if err != nil {
		t.Fatalf("error %v", err)
	}
	t.Errorf("schema %#v", schema)
	data, err := schema.MarshalHCL()
	if err != nil {
		t.Fatalf("%v", err)
	}
	err = os.WriteFile("schema_v30_2.hcl", data, 0644)
	if err != nil {
		t.Fatalf("%v", err)
	}
}
