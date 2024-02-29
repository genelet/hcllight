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
	kn, err := NewGno(bs)
	if err != nil {
		panic(err)
	}
	err = kn.Build()
	if err != nil {
		panic(err)
	}

	bs, err = kn.YAMLValue("comment")
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
	kn, err := NewGno(bs)
	if err != nil {
		panic(err)
	}

	bs, err = os.ReadFile("tf.yaml")
	if err != nil {
		panic(err)
	}
	_, err = kn.DocumentNode(bs)
	if err != nil {
		panic(err)
	}
}
