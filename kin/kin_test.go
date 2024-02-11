package kin

import (
	"os"
	"testing"
)

func TestBuild(t *testing.T) {
	bs, err := os.ReadFile("config.json")
	if err != nil {
		panic(err)
	}
	kn, err := NewKin(bs)
	if err != nil {
		panic(err)
	}
	err = kn.Build()
	if err != nil {
		panic(err)
	}
}
