package hcl

import (
	"os"
	"testing"
)

func TestHclOpen(t *testing.T) {
	data, err := os.ReadFile("openapi.json")
	api, err := ParseDocument(data, "json")

	bs, err := api.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	err = os.WriteFile("openapi.hcl", bs, 0644)
	if err != nil {
		t.Fatal(err)
	}
}

func TestHclTwitter(t *testing.T) {
	data, err := os.ReadFile("twitter.json")
	api, err := ParseDocument(data, "json")

	bs, err := api.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	err = os.WriteFile("twitter.hcl", bs, 0644)
	if err != nil {
		t.Fatal(err)
	}
}

func TestParseOpen(t *testing.T) {
	data, err := os.ReadFile("openapi.hcl")
	if err != nil {
		t.Fatal(err)
	}
	api, err := ParseDocument(data)
	if err != nil {
		t.Fatal(err)
	}
	bs, err := api.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	err = os.WriteFile("openapi2.hcl", bs, 0644)
	if err != nil {
		t.Fatal(err)
	}
}

func TestParseTwitter(t *testing.T) {
	data, err := os.ReadFile("twitter.hcl")
	if err != nil {
		t.Fatal(err)
	}
	api, err := ParseDocument(data)
	if err != nil {
		t.Fatal(err)
	}
	bs, err := api.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	err = os.WriteFile("twitter2.hcl", bs, 0644)
	if err != nil {
		t.Fatal(err)
	}
}
