# HCL Light

[hclsyntax](https://pkg.go.dev/github.com/hashicorp/hcl/v2/hclsyntax) is the AST parsing package for HCL (HashiCorp Configuration Language).
This *hcllight* package removes position and location tags in *hclsyntax*.

 - This allows for dynamic addition and deletion of attributes, variables, expressions and blocks, after which the tree can be output back to HCL data.
 - This can be done with or without the evaluation of logic expressions in HCL.
 - The package is defined by Protobuf, enabling precise tracking of changes in the tree state.

To install,

```bash
go install github.com/genelet/hcllight
```

To use the *hcllight* package,

[![GoDoc](https://godoc.org/github.com/genelet/hcllight?status.svg)](https://godoc.org/github.com/genelet/hcllight)

## Application 

As a demo application of *hcllight*, package *kin*, included, builds Terraform scripts from OpenAPI 3.0 documents.



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

This program parses the HCL data into the document node, *generated.Body*, and outputs it in HCL format, both with and without evaluation.

```go
package main

import (
	"fmt"
	"math/rand"
	"os"

	"github.com/genelet/hcllight/generated"
	"github.com/genelet/hcllight/light"

	"github.com/zclconf/go-cty/cty"
	"github.com/zclconf/go-cty/cty/function"
)

func main() {
	body, err := parseFile("random.hcl")
	if err != nil {
		panic(err)
	}
	hcl, err := light.Hcl(body)
	if err != nil {
		panic(err)
	}

	ref := getRef()
	eval, err := light.Evaluate(body, ref)
	if err != nil {
		panic(err)
	}

	fmt.Printf("hcl: %s\n", hcl)
	fmt.Printf("evaluated: %s\n", eval)
}

func parseFile(filename string) (*generated.Body, error) {
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
