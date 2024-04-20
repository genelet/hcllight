package gno

import (
	"os"
	"testing"

	"github.com/genelet/determined/convert"
)

func TestBuild(t *testing.T) {
	bs, err := os.ReadFile("config.json")
	if err != nil {
		panic(err)
	}
	g, err := NewGno(bs)
	if err != nil {
		panic(err)
	}
	err = g.Build()
	if err != nil {
		panic(err)
	}

	bs, err = g.YAMLValue("comment")
	if err != nil {
		panic(err)
	}
	bs, err = convert.YAMLToHCL(bs)
	if err != nil {
		panic(err)
	}
	err = os.WriteFile("convert.hcl", bs, 0644)
	if err != nil {
		panic(err)
	}
}

func TestCodeGen(t *testing.T) {
	bs, err := os.ReadFile("pets.json")
	if err != nil {
		panic(err)
	}
	g, err := NewGno(bs)
	if err != nil {
		panic(err)
	}

	bs, err = os.ReadFile("pets_generator.yaml")
	if err != nil {
		panic(err)
	}
	_, err = g.DocumentNode(bs)
	if err != nil {
		panic(err)
	}
}
