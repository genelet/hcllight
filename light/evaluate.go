package light

import (
	"fmt"
	"strings"

	"github.com/genelet/hcllight/internal/ast"

	"github.com/genelet/determined/dethcl"
	"github.com/genelet/determined/utils"
)

// Evaluate converts Body proto to HCL with expressions evaluated.
func (body *Body) Evaluate(ref ...map[string]interface{}) ([]byte, error) {
	var r map[string]interface{}
	if ref != nil {
		r = ref[0]
	} else {
		r = make(map[string]interface{})
	}
	node, r := utils.DefaultTreeFunctions(r)
	str, err := body.evaluateBodyNode(r, node, 0)
	if err != nil {
		return nil, err
	}
	return []byte(str), nil
}

func (body *Body) MarshalHCL() ([]byte, error) {
	return body.Evaluate()
}

// ToNative converts Attribute to a native Go type assuming there is no evaluation needed.
func (self *Attribute) ToNative() (interface{}, error) {
	astAttr, err := xattributeTo(self)
	if err != nil {
		return nil, err
	}
	syntaxAttr, err := ast.AttributeTo(astAttr)
	if err != nil {
		return nil, err
	}
	cv, err := utils.ExpressionToCty(nil, nil, syntaxAttr.Expr)
	if err != nil {
		return nil, err
	}
	return utils.CtyToNative(cv)
}

func (self *Body) evaluateBodyNode(ref map[string]interface{}, node *utils.Tree, level int) (string, error) {
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

		bs, err := dethcl.MarshalLevel(v, level+1)
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
		bs, err := block.Bdy.evaluateBodyNode(ref, node.AddNode(name), level+1)
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
