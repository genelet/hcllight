package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/genelet/determined/convert"
	"github.com/genelet/hcllight/hcl"
)

var from string
var to string

func init() {
	flag.StringVar(&from, "from", "yaml", "json|yaml|hcl")
	flag.StringVar(&to, "to", "hcl", "json|yaml/hcl")
	flag.Parse()
}

func usage() {
	fmt.Fprintf(os.Stderr, "usage: %s [options] <filename>\n", os.Args[0])
	flag.PrintDefaults()
	os.Exit(0)
}

func main() {

	if from == to {
		fmt.Fprintf(os.Stderr, "error: from and to format are the same\n")
		os.Exit(-1)
	}

	filename := flag.Arg(0)
	if filename == "" {
		usage()
	}

	raw, err := os.ReadFile(filename)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(-1)
	}

	doc, err := hcl.ParseDocument(raw, from)
	if err != nil {
		fmt.Fprintf(os.Stderr, "parsing error: %v\n", err)
		os.Exit(-1)
	}

	if to == "hcl" {
		bs, err := doc.MarshalHCL()
		if err != nil {
			fmt.Fprintf(os.Stderr, "marshal rror: %v\n", err)
			os.Exit(-1)
		}
		fmt.Printf("%s", bs)
		os.Exit(0)
	}

	apidoc := doc.ToAPI()
	bs, err := apidoc.YAMLValue("converted")
	if err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(-1)
	}
	if to == "json" {
		bs, err = convert.YAMLToJSON(bs)
		if err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(-1)
		}
	}
	fmt.Printf("%s", bs)
	os.Exit(0)
}
