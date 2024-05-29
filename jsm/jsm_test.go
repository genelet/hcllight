package jsm

import (
	"bufio"
	"os"
	"testing"

	"github.com/google/gnostic/jsonschema"
)

func TestConversion(t *testing.T) {
	s, err := jsonschema.NewSchemaFromFile("schema_v30.json")
	if err != nil {
		t.Fatalf("Error parsing schema: %v", err)
	}
	schema := NewSchemaFromJSM(s)
	bs, err := schema.MarshalHCL()
	if err != nil {
		t.Fatalf("Error converting expression to HCL: %v", err)
	}
	err = os.WriteFile("tmp/schema_v30.hcl", bs, 0644)
	if err != nil {
		t.Fatalf("Error writing HCL: %v", err)
	}

	bs1, err := os.ReadFile("tmp/schema_v30.hcl")
	if err != nil {
		t.Fatalf("Error reading HCL: %v", err)
	}
	schema1, err := ParseSchema(bs1)
	if err != nil {
		t.Fatalf("error %v", err)
	}
	s1 := schema1.ToJSM()
	err = os.WriteFile("tmp/schema_v30_2.json", []byte(s1.JSONString()), 0644)
	if err != nil {
		t.Fatalf("%v", err)
	}

	smap := make(map[string]*jsonschema.Schema)
	for _, item := range *s.Definitions {
		smap[item.Name] = item.Value
	}
	for _, item := range *s1.Definitions {
		v1 := item.Value
		v := smap[item.Name]

		file := "tmp/" + item.Name + ".json"
		os.WriteFile(file, []byte(v.JSONString()), 0644)
		file1 := "tmp/" + item.Name + "1.json"
		os.WriteFile(file1, []byte(v1.JSONString()), 0644)
		f, _ := os.Open(file)
		defer f.Close()
		fileScanner := bufio.NewScanner(f)
		lineCount := 0
		for fileScanner.Scan() {
			lineCount++
		}
		f1, _ := os.Open(file1)
		fileScanner1 := bufio.NewScanner(f1)
		lineCount1 := 0
		for fileScanner1.Scan() {
			lineCount1++
		}
		if lineCount != lineCount1 {
			t.Errorf("FOUND! %s not equal to original schema", item.Name)
		}
	}
}
