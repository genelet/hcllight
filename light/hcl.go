package light

import (
	"fmt"
	"strings"

	"github.com/genelet/determined/dethcl"
	"github.com/genelet/determined/utils"
	"github.com/genelet/hcllight/generated"
	"github.com/genelet/hcllight/internal/ast"

	"github.com/hashicorp/hcl/v2/hclsyntax"
)

func hclExpression(self *generated.Expression, x ...interface{}) (string, error) {
	if self == nil {
		return "", nil
	}

	var parent *generated.Expression
	var level int
	if x != nil {
		switch t := x[0].(type) {
		case *generated.Expression:
			parent = t
		case int:
			level = t
		default:
		}
		if len(x) > 1 {
			level = x[1].(int)
		}
	}

	switch self.ExpressionClause.(type) {
	/*
		case *generated.Expression_Asexpr:
			v, err := xanonSymbolExprTo(e.Asexpr)
			return &ast.Expression{
				ExpressionClause: &ast.Expression_Asexpr{
					Asexpr: v,
				},
			}, err
	*/
	case *generated.Expression_Boexpr:
		v := self.GetBoexpr()
		lft, err := hclExpression(v.GetLHS())
		if err != nil {
			return "", err
		}
		rgt, err := hclExpression(v.GetRHS())
		if err != nil {
			return "", err
		}
		operation := v.GetOp()
		sign, err := hclOperation(operation)
		if err != nil {
			return "", err
		}
		return fmt.Sprintf("%s %s %s", lft, sign, rgt), nil
	case *generated.Expression_Cexpr:
		v := self.GetCexpr()
		condition, err := hclExpression(v.GetCondition())
		if err != nil {
			return "", err
		}
		trueResult, err := hclExpression(v.GetTrueResult())
		if err != nil {
			return "", err
		}
		falseResult, err := hclExpression(v.GetFalseResult())
		if err != nil {
			return "", err
		}
		return fmt.Sprintf("%s ? %s : %s", condition, trueResult, falseResult), nil
	case *generated.Expression_Fexpr:
		v := self.GetFexpr()

		var key, collExpression, conditionalExpression, keyExpression, valExpression string
		var err error

		if v.KeyVar != "" {
			key = v.KeyVar + ", "
		}

		collExpression, err = hclExpression(v.CollExpr, self)
		if err == nil {
			collExpression = strings.TrimSpace(strings.ReplaceAll(collExpression, "\n", ""))
			valExpression, err = hclExpression(v.ValExpr)
			if err == nil && v.CondExpr != nil {
				conditionalExpression, err = hclExpression(v.CondExpr)
			}
			if err == nil && v.KeyExpr != nil {
				keyExpression, err = hclExpression(v.KeyExpr)
			}
		}
		if err != nil {
			return "", err
		}

		switch t := v.CollExpr.ExpressionClause.(type) {
		case *generated.Expression_Ocexpr: // object = {for k, v in map: k => upper(v)}
			str := `for ` + key + v.ValVar + ` in ` + collExpression + `: ` + keyExpression + ` => ` + valExpression
			if conditionalExpression != "" {
				str += ` if ` + conditionalExpression
			}
			return str, nil
		case *generated.Expression_Stexpr: // object = {for k, v in map: k => upper(v)}
			str := `for ` + key + v.ValVar + ` in ` + collExpression + `: ` + keyExpression + ` => ` + valExpression
			if conditionalExpression != "" {
				str += ` if ` + conditionalExpression
			}
			return str, nil
		default:
			return "", fmt.Errorf("unknown collection type: %T", t)
		}
	case *generated.Expression_Fcexpr:
		expr := self.GetFcexpr()
		name := expr.GetName()
		args := expr.GetArgs()
		var arr []string
		for _, arg := range args {
			str, err := hclExpression(arg)
			if err != nil {
				return "", err
			}
			arr = append(arr, str)
		}
		return name + "(" + strings.Join(arr, ", ") + ")", nil
	case *generated.Expression_Iexpr:
		v := self.GetIexpr()
		s_collection, err := hclExpression(v.GetCollection())
		if err != nil {
			return "", err
		}
		s_key, err := hclExpression(v.GetKey())
		if err != nil {
			return "", err
		}
		return s_collection + "[" + s_key + "]", nil
	case *generated.Expression_Lvexpr:
		expr := self.GetLvexpr()
		return hclCty(expr.GetVal())
	case *generated.Expression_Ocexpr:
		nextLeading := strings.Repeat("  ", level+2)
		leading := strings.Repeat("  ", level+1)
		expr := self.GetOcexpr()
		var arr []string
		for _, item := range expr.GetItems() {
			key, err := hclExpression(item.GetKeyExpr())
			if err != nil {
				return "", err
			}
			val, err := hclExpression(item.GetValueExpr(), level+1)
			if err != nil {
				return "", err
			}
			if parent != nil && parent.ExpressionClause.(*generated.Expression_Fexpr) != nil {
				arr = append(arr, key+`:`+val)
			} else {
				arr = append(arr, nextLeading+key+" = "+val)
			}
		}
		return fmt.Sprintf("{\n%s\n%s}", strings.Join(arr, ",\n"), leading), nil
		//return "{" + strings.Join(arr, ", ") + "}", nil
	case *generated.Expression_Ockexpr:
		expr := self.GetOckexpr()
		return hclExpression(expr.GetWrapped())
		/*
			case *generated.Expression_Pexpr:
				v, err := xparenthesizedExprTo(e.Pexpr)
				return &ast.Expression{
					ExpressionClause: &ast.Expression_Pexpr{
						Pexpr: v,
					},
				}, err
			case *generated.Expression_Rtexpr:
				v, err := xrelativeTraversalExprTo(e.Rtexpr)
				return &ast.Expression{
					ExpressionClause: &ast.Expression_Rtexpr{
						Rtexpr: v,
					},
				}, err
		*/
	case *generated.Expression_Stexpr:
		v := self.GetStexpr()
		rootOnly := true
		var arr []string
		for _, trv := range v.GetTraversal() {
			switch t := trv.TraverserClause.(type) {
			case *generated.Traverser_TRoot:
				arr = append(arr, t.TRoot.GetName())
			case *generated.Traverser_TAttr:
				arr = append(arr, t.TAttr.GetName())
				rootOnly = false
			case *generated.Traverser_TIndex:
				str, err := hclCty(t.TIndex.GetKey())
				if err != nil {
					return "", err
				}
				arr = append(arr, str)
				rootOnly = false
			default:
				return "", fmt.Errorf("unknown traverser type: %T", trv)
			}
		}
		if rootOnly && parent != nil {
			if _, ok := parent.ExpressionClause.(*generated.Expression_Texpr); ok {
				return `${` + arr[0] + `}`, nil
			}

		}
		return strings.Join(arr, "."), nil
		/*
			case *generated.Expression_Sexpr:
				v, err := xsplatExprTo(e.Sexpr)
				return &ast.Expression{
					ExpressionClause: &ast.Expression_Sexpr{
						Sexpr: v,
					},
				}, err
		*/
	case *generated.Expression_Texpr:
		v := self.GetTexpr()
		var arr []string

		for _, part := range v.GetParts() {
			str, err := hclExpression(part, self)
			if err != nil {
				return "", err
			}
			arr = append(arr, str)
		}
		return `"` + strings.Join(arr, ``) + `"`, nil
		/*
			case *generated.Expression_Tjexpr:
				v, err := xtemplateJoinExprTo(e.Tjexpr)
				return &ast.Expression{
					ExpressionClause: &ast.Expression_Tjexpr{
						Tjexpr: v,
					},
				}, err
			case *generated.Expression_Twexpr:
				v, err := xtemplateWrapExprTo(e.Twexpr)
				return &ast.Expression{
					ExpressionClause: &ast.Expression_Twexpr{
						Twexpr: v,
					},
				}, err
		*/
	case *generated.Expression_Tcexpr:
		v := self.GetTcexpr()
		var arr []string
		for _, item := range v.GetExprs() {
			// for tuple or array, each item stays at the current level
			str, err := hclExpression(item, level)
			if err != nil {
				return "", err
			}
			arr = append(arr, str)
		}
		return `[` + strings.Join(arr, ", ") + `]`, nil

	case *generated.Expression_Uoexpr:
		v := self.GetUoexpr()
		str, err := hclExpression(v.Val)
		if err != nil {
			return "", err
		}
		sign, err := hclOperation(v.Op)
		if err != nil {
			return "", err
		}
		return sign + str, nil
	default:
	}

	return "", fmt.Errorf("TOBE: expression type %T", self.ExpressionClause)
}

func hclCty(self *generated.CtyValue) (string, error) {
	switch t := self.CtyValueClause.(type) {
	case *generated.CtyValue_StringValue:
		return t.StringValue, nil
	case *generated.CtyValue_NumberValue, *generated.CtyValue_BoolValue:
		xcty, err := xctyValueTo(self)
		if err != nil {
			return "", err
		}
		val, err := ast.CtyValueTo(xcty)
		if err != nil {
			return "", err
		}
		v, err := utils.CtyToNative(val)
		if err != nil {
			return "", err
		}
		bs, err := dethcl.MarshalLevel(v, 0)
		if err != nil {
			return "", err
		}
		return string(bs), nil
	//case *generated.CtyValue_BoolValue:
	//	return t.BoolValue, nil
	case *generated.CtyValue_ListValue:
		var output []string
		for _, v := range t.ListValue.Values {
			u, err := hclCty(v)
			if err != nil {
				return "", err
			}
			output = append(output, u)
		}
		return "[" + strings.Join(output, " ,") + "]", nil
	case *generated.CtyValue_MapValue:
		var output []string
		for k, v := range t.MapValue.Values {
			u, err := hclCty(v)
			if err != nil {
				return "", err
			}
			output = append(output, fmt.Sprintf("%s = %s", k, u))
		}
		return "{" + strings.Join(output, " ,") + "}", nil
	default:
	}
	return "", fmt.Errorf("primitive value %#v not implementned", self)
}

func hclOperation(self *generated.Operation) (string, error) {
	if self == nil {
		return "", nil
	}

	switch self.Sign {
	case generated.TokenType_Or:
		return string(hclsyntax.TokenOr), nil
	case generated.TokenType_And:
		return string(hclsyntax.TokenAnd), nil
	case generated.TokenType_EqualOp: // hclsyntax.TokenEqual is not acceptable
		return string(hclsyntax.TokenEqual) + string(hclsyntax.TokenEqual), nil
	case generated.TokenType_NotEqual:
		return string(hclsyntax.TokenNotEqual), nil
	case generated.TokenType_GreaterThan:
		return string(hclsyntax.TokenGreaterThan), nil
	case generated.TokenType_GreaterThanEq:
		return string(hclsyntax.TokenGreaterThanEq), nil
	case generated.TokenType_LessThan:
		return string(hclsyntax.TokenLessThan), nil
	case generated.TokenType_LessThanEq:
		return string(hclsyntax.TokenLessThanEq), nil
	case generated.TokenType_Plus:
		return string(hclsyntax.TokenPlus), nil
	case generated.TokenType_Minus:
		return string(hclsyntax.TokenMinus), nil
	case generated.TokenType_Star:
		return string(hclsyntax.TokenStar), nil
	case generated.TokenType_Slash:
		return string(hclsyntax.TokenSlash), nil
	case generated.TokenType_Percent:
		return string(hclsyntax.TokenPercent), nil
	case generated.TokenType_TokenUnknown:
		if self.Impl != nil && self.Impl.Description == "Applies the logical NOT operation to the given boolean value." {
			return string(hclsyntax.TokenBang), nil
		}
	default:
	}

	return "", fmt.Errorf("unknown operation type %T", self)
}

func hclBodyNode(self *generated.Body, level int) (string, error) {
	var arr []string

	nextLeading := strings.Repeat("  ", level+2)
	leading := strings.Repeat("  ", level+1)
	lessLeading := strings.Repeat("  ", level)

	for name, attr := range self.Attributes {
		str, err := hclExpression(attr.Expr, level)
		if err != nil {
			return "", err
		}
		if str == "" {
			continue
		}
		switch attr.Expr.ExpressionClause.(type) {
		case *generated.Expression_Fexpr:
			str = fmt.Sprintf("{\n%s\n%s}", nextLeading+str, leading)
		default:
		}
		arr = append(arr, fmt.Sprintf(`%s = %s`, name, str))
	}

	for _, block := range self.Blocks {
		name := block.Type
		for _, label := range block.Labels {
			name += fmt.Sprintf(` "%s"`, label)
		}
		bs, err := hclBodyNode(block.Bdy, level+1)
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

// HCL converts Body proto to HCL without evaluation of expressions.
func Hcl(body *generated.Body) ([]byte, error) {
	str, err := hclBodyNode(body, 0)
	if err != nil {
		return nil, err
	}
	return []byte(str), nil
}
