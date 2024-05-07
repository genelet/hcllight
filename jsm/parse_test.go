package jsm

import (
	"testing"

	"github.com/k0kubun/pp/v3"
)

func TestParseSchema(t *testing.T) {
	s, err := ParseSchema("schema_v30.yaml")
	if err != nil {
		t.Fatalf("Error parsing schema: %v", err)
	}
	pp.Println(s)
	t.Errorf("Schema: %s", s.String())
}
