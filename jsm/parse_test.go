package jsm

import (
	"os"
	"testing"

	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"
	//"github.com/k0kubun/pp/v3"
)

func TestParseSchemaJSON(t *testing.T) {
	s, err := jsonschema.NewSchemaFromFile("openapi-3.1_gnostic.json")
	if err != nil {
		t.Fatalf("Error parsing schema: %v", err)
	}
	schema := NewSchemaFromJSM(s)
	//t.Errorf("Schema: %s", s.String())
	body, err := schema.ToBody()
	if err != nil {
		t.Fatalf("Error converting schema to expression: %v", err)
	}
	data, err := body.Hcl()
	if err != nil {
		t.Fatalf("Error converting expression to HCL: %v", err)
	}
	err = os.WriteFile("y.hcl", data, 0644)
	if err != nil {
		t.Fatalf("Error writing HCL: %v", err)
	}
}

func TestParseSchemaYAML(t *testing.T) {
	s, err := jsonschema.NewSchemaFromFile("schema_v30.yaml")
	if err != nil {
		t.Fatalf("Error parsing schema: %v", err)
	}
	schema := NewSchemaFromJSM(s)
	//t.Errorf("Schema: %s", s.String())
	body, err := schema.ToBody()
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
}

func TestParseHCL(t *testing.T) {
	bs, err := os.ReadFile("schema_v30.hcl")
	if err != nil {
		t.Fatalf("Error reading HCL: %v", err)
	}

	body, err := light.ParseBody(bs)
	if err != nil {
		t.Fatalf("Error parsing HCL: %v", err)
	}
	schema, err := NewSchemaFromBody(body)
	if err != nil {
		t.Fatalf("error %v", err)
	}

	x, err := schema.ToBody()
	if err != nil {
		t.Fatalf("error %v", err)
	}
	data, err := x.Hcl()
	if err != nil {
		t.Fatalf("error %v", err)
	}

	err = os.WriteFile("back_v30.hcl", data, 0644)
	if err != nil {
		t.Fatalf("Error writing HCL: %v", err)
	}

	s := schema.ToJSM().String()
	t.Errorf("Schema: %s", s)
}
