package light

import (
"log"
	"fmt"
	"strings"

	"github.com/genelet/hcllight/internal/ast"

	"github.com/genelet/determined/dethcl"
	"github.com/genelet/determined/utils"
)

// Evaluate converts Body proto to HCL with expressions evaluated.
func (body *Body) Evaluate(rest ...interface{}) ([]byte, error) {
	var ref map[string]interface{}
	var node *utils.Tree
	if len(rest) > 0 {
		ref = rest[0].(map[string]interface{})
		if len(rest) == 2 {
			node = rest[1].(*utils.Tree)
		}
	}
	if node == nil {
		node, ref = utils.DefaultTreeFunctions(ref)	
	}
	str, err := body.evaluateBodyNode(ref, node, 0)
	if err != nil {
		return nil, err
	}
	return []byte(str), nil
}

func (body *Body) MarshalHCL() ([]byte, error) {
	return body.Evaluate()
}

// ToNative converts Attribute to a native Go type assuming there is no evaluation needed.
func (self *Attribute) ToNative(ref map[string]interface{}, node *utils.Tree, k ...string) (interface{}, error) {
	astAttr, err := xattributeTo(self)
	if err != nil {
		return nil, err
	}
	syntaxAttr, err := ast.AttributeTo(astAttr)
	if err != nil {
		return nil, err
	}
	cv, err := utils.ExpressionToCty(ref, node, syntaxAttr.Expr)
	if err != nil {
		return nil, err
	}
	//syntaxAttr.Expr = utils.CtyToExpression(cv, syntaxAttr.Range())
	if k != nil {
log.Printf("0000 %s => %#v", k[0], cv)
		node.AddItem(k[0], cv)
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
		astAttr, err = ast.XattributeTo(syntaxAttr)
		if err != nil {
			return "", err
		}
		self.Attributes[name], err = attributeTo(astAttr)
		if err != nil {
			return "", err
		}
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
