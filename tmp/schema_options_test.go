// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

package gno

// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

import (
	"os"
	"testing"
)

func TestGenerator(t *testing.T) {
	bs, err := os.ReadFile("pets_generator.yaml")
	if err != nil {
		t.Fatal(err)
	}
	config, err := ParseConfig(bs, "yaml")
	if err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile("pets.json")
	if err != nil {
		t.Fatal(err)
	}
	err = config.ParseDocument(data)
	if err != nil {
		t.Fatal(err)
	}
	for k, v := range config.Resources {
		if v.Create != nil {
			t.Errorf("create %s: %#v", k, v.Create.Detail)
		}
		if v.Read != nil {
			t.Errorf("read %s: %#v", k, v.Read.Detail)
		}
		if v.Update != nil {
			t.Errorf("update %s: %#v", k, v.Update)
		}
		if v.Delete != nil {
			t.Errorf("delete %s: %#v", k, v.Delete)
		}
	}
}
