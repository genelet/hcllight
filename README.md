# HCL Light

[hclsyntax](https://pkg.go.dev/github.com/hashicorp/hcl/v2/hclsyntax) is the offical HCL (HashiCorp Configuration Language) parsing package. 
This *hcllight* package removes position and location tags from the hclsyntax parsing tree.

 - You can dynamically add and delete tags, then output the tree back to
HCL data, with logic expressions being evaluated or kepted in the original format.
 - The package is defined by protobuf, which let you accurately measure the state of changes in the parsing tree.

To install,

```bash
go install github.com/genelet/hcllight
```

To use the package,

[![GoDoc](https://godoc.org/github.com/genelet/hcllight?status.svg)](https://godoc.org/github.com/genelet/hcllight)
