# HCL Light


This *hcllight* package removes position and location tags in [hclsyntax](https://pkg.go.dev/github.com/hashicorp/hcl/v2/hclsyntax) , the official AST parsing package for HCL (HashiCorp Configuration Language).

 - It allows for dynamic manipulation of attributes, variables, expressions and blocks, after which the tree can be output back to HCL data.
 - The output can be made with or without the evaluation of logic expressions in HCL.

Two applications are packed together: 

 - [jsm](./jsm), to parse JSON Schema document, draft-04, in HCL
 - [hcl](./hcl), to parse OpenAPI description, version 3.0 and 3.1, in HCL

We obtain OpenAPI and JSON Schema files that are of 50% in size of the corresponding JSON files.

[Here](https://medium.com/@peterbi_91340/json-schema-in-the-hcl-data-format-e8a6613112bc) is a Medium article on JSON Schema.

To install,

```bash
go install github.com/genelet/hcllight
```

See the reference to use *hcllight*, *JSON Schema* and *OpenAPI* packages,

[![GoDoc](https://godoc.org/github.com/genelet/hcllight?status.svg)](https://godoc.org/github.com/genelet/hcllight)


## Example

Here is a HCL sample:

```bash
TEST_FOLDER = "__test__"
EXECUTION_ID = random(6)
version = 2
say = {
    for k, v in {hello: "world"}: k => v if k == "hello"
}

job check "this is a temporal job" {
  python "run.py" {}
}

job e2e "running integration tests" {

  python "app-e2e.py" {
    root_dir = var.TEST_FOLDER
    python_version = version + 6
  }

  slack {
    channel  = "slack-my-channel"
    message = "Job execution ${EXECUTION_ID} completed successfully"
  }
}
```

This program parses the HCL data into the document node, *Body*, and outputs it in HCL format, with and without evaluation.

```go
package main

import (
	"fmt"
	"math/rand"
	"os"

	"github.com/genelet/hcllight/light"

	"github.com/zclconf/go-cty/cty"
	"github.com/zclconf/go-cty/cty/function"
)

func main() {
	body, err := parseFile("random.hcl")
	if err != nil {
		panic(err)
	}
	hcl, err := body.MarshalHCL()
	if err != nil {
		panic(err)
	}

	ref := getRef()
	eval, err := body.Evaluate(ref)
	if err != nil {
		panic(err)
	}

	fmt.Printf("hcl: %s\n", hcl)
	fmt.Printf("evaluated: %s\n", eval)
}

func parseFile(filename string) (*light.Body, error) {
	dat, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}
	return light.Parse(dat)
}

func getRef() map[string]interface{} {
	return map[string]interface{}{
		"functions": map[string]function.Function{
			"random": function.New(&function.Spec{
				VarParam: nil,
				Params: []function.Parameter{
					{Type: cty.Number},
				},
				Type: func(args []cty.Value) (cty.Type, error) {
					return cty.String, nil
				},
				Impl: func(args []cty.Value, retType cty.Type) (cty.Value, error) {
					var letterRunes = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
					n, _ := args[0].AsBigFloat().Int64()
					b := make([]rune, n)
					for i := range b {
						b[i] = letterRunes[rand.Intn(len(letterRunes))]
					}
					return cty.StringVal(string(b)), nil
				},
			}),
		},
	}
}
```

The result is
```bash
hcl: 
  TEST_FOLDER = "__test__"
  EXECUTION_ID = random(6)
  version = 2
  say = {
    for k, v in {hello:"world"}: k => v if k == "hello"
  }
  job "check" "this is a temporal job" {
    python "run.py" {}
  }
  job "e2e" "running integration tests" {
    python "app-e2e.py" {
      root_dir = var.TEST_FOLDER
      python_version = version + 6
    }
    slack {
      message = "Job execution ${EXECUTION_ID} completed successfully"
      channel = "slack-my-channel"
    }
  }

evaluated: 
  say = {
    hello = "world"
  }
  TEST_FOLDER = "__test__"
  EXECUTION_ID = "nOVqNf"
  version = 2
  job "check" "this is a temporal job" {
    python "run.py" {}
  }
  job "e2e" "running integration tests" {
    python "app-e2e.py" {
      root_dir = "__test__"
      python_version = 8
    }
    slack {
      message = "Job execution nOVqNf completed successfully"
      channel = "slack-my-channel"
    }
  }
```
