package light

import (
	"testing"

	"github.com/google/go-cmp/cmp"
	"google.golang.org/protobuf/testing/protocmp"
)

func TestParseDocumentHcl(t *testing.T) {
	bodyr, err := parseFile("openapi.hcl")
	if err != nil {
		t.Fatal(err)
	}
	backr, err := hclBack(bodyr)
	if err != nil {
		t.Fatal(err)
	}

	var r DiffReporter
	opt := protocmp.Transform()
	if cmp.Equal(bodyr, backr, opt, cmp.Reporter(&r)) == false {
		t.Errorf("%s", r.String())
	}
}
