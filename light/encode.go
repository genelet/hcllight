package light

import (
	"fmt"
	"math/rand"
	"strings"

	"github.com/genelet/hcllight/generated"
	"github.com/genelet/hcllight/internal/ast"

	"github.com/genelet/determined/utils"
	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclsyntax"
)

// Parse parses HCL data into Body proto.
func Parse(dat []byte) (*generated.Body, error) {
	f := fmt.Sprintf("%d.hcl", rand.Int())
	file, diags := hclsyntax.ParseConfig(dat, f, hcl.Pos{Line: 1, Column: 1})
	if diags.HasErrors() {
		return nil, fmt.Errorf("%s", diags.Error())
	}

	bdy, err := ast.XbodyTo(file.Body.(*hclsyntax.Body))
	if err != nil {
		return nil, err
	}
	return bodyTo(bdy)
}

func evaluateBodyNode(self *generated.Body, ref map[string]interface{}, node *utils.Tree, level int) (string, error) {
	var arr []string

	leading := strings.Repeat("  ", level+1)
	lessLeading := strings.Repeat("  ", level)

	for name, attr := range self.Attributes {
		astAttr, err := xattributeTo(attr)
		if err != nil {
			return "", err
		}
		syntaxAttr, err := ast.AttributeTo(astAttr)
		if err != nil {
			return "", err
		}
		cv, err := utils.ExpressionToCty(ref, node, syntaxAttr.Expr)
		if err != nil {
			return "", err
		}
		v, err := utils.CtyToNative(cv)
		if err != nil {
			return "", err
		}

		syntaxAttr.Expr = utils.CtyToExpression(cv, syntaxAttr.Range())
		node.AddItem(name, cv)

		bs, err := utils.Encoding(v, level+1)
		if err != nil {
			return "", err
		}
		if bs == nil {
			continue
		}
		arr = append(arr, fmt.Sprintf(`%s = %s`, name, bs))
	}

	for _, block := range self.Blocks {
		name := block.Type
		for _, label := range block.Labels {
			name += fmt.Sprintf(` "%s"`, label)
		}
		bs, err := evaluateBodyNode(block.Bdy, ref, node.AddNode(name), level+1)
		if err != nil {
			return "", err
		}
		if bs == "" {
			continue
		}
		arr = append(arr, fmt.Sprintf(`%s %s`, name, bs))
	}
	if arr == nil {
		if level == 0 {
			return "", nil
		} else {
			return "{}", nil
		}
	}
	if level == 0 {
		return fmt.Sprintf("\n%s\n%s", leading+strings.Join(arr, "\n"+leading), lessLeading), nil
	}
	return fmt.Sprintf("{\n%s\n%s}", leading+strings.Join(arr, "\n"+leading), lessLeading), nil
}

// Evaluate converts Body proto to HCL with expressions evaluated.
func Evaluate(body *generated.Body, ref ...map[string]interface{}) ([]byte, error) {
	var r map[string]interface{}
	if ref != nil {
		r = ref[0]
	} else {
		r = make(map[string]interface{})
	}
	node, r := utils.DefaultTreeFunctions(r)
	str, err := evaluateBodyNode(body, r, node, 0)
	if err != nil {
		return nil, err
	}
	return []byte(str), nil
}
