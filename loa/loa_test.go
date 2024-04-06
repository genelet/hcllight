package loa

import (
	"os"
	"testing"
)

func TestBuild(t *testing.T) {
	bs, err := os.ReadFile("config.json")
	if err != nil {
		panic(err)
	}
	l, err := NewLoa(bs)
	if err != nil {
		panic(err)
	}
	err = l.Build()
	if err != nil {
		panic(err)
	}
}
