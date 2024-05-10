package light

import (
	"fmt"
	"math/rand"
	"strings"

	"github.com/genelet/determined/utils"
	"github.com/genelet/hcllight/internal/ast"
	"github.com/zclconf/go-cty/cty"

	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclsyntax"
)

// Parse parses HCL data into Body proto.
func Parse(dat []byte) (*Body, error) {
	if dat == nil {
		return nil, nil
	}

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

// HCL converts Body proto to HCL without evaluation of expressions.
func (self *Body) Hcl() ([]byte, error) {
	str, err := self.hclBodyNode(0)
	if err != nil {
		return nil, err
	}
	return []byte(str), nil
}

func (self *Body) hclBodyNode(level int) (string, error) {
	var arr []string

	nextLeading := strings.Repeat("  ", level+2)
	leading := strings.Repeat("  ", level+1)
	lessLeading := strings.Repeat("  ", level)

	for name, attr := range self.Attributes {
		str, err := attr.Expr.HclExpression(level)
		if err != nil {
			return "", err
		}
		//if str == "" {
		//	continue
		//}
		switch attr.Expr.ExpressionClause.(type) {
		case *Expression_Fexpr:
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
		bs, err := block.Bdy.hclBodyNode(level + 1)
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

func (self *Expression) HclExpression(x ...interface{}) (string, error) {
	if self == nil {
		return "", nil
	}

	var parent *Expression
	var level int
	if x != nil {
		switch t := x[0].(type) {
		case *Expression:
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
		case *Expression_Asexpr:
			v, err := xanonSymbolExprTo(e.Asexpr)
			return &ast.Expression{
				ExpressionClause: &ast.Expression_Asexpr{
					Asexpr: v,
				},
			}, err
	*/
	case *Expression_Boexpr:
		v := self.GetBoexpr()
		lft, err := v.GetLHS().HclExpression()
		if err != nil {
			return "", err
		}
		rgt, err := v.GetRHS().HclExpression()
		if err != nil {
			return "", err
		}
		operation := v.GetOp()
		sign, err := hclOperation(operation)
		if err != nil {
			return "", err
		}
		return fmt.Sprintf("%s %s %s", lft, sign, rgt), nil
	case *Expression_Cexpr:
		v := self.GetCexpr()
		condition, err := v.GetCondition().HclExpression()
		if err != nil {
			return "", err
		}
		trueResult, err := v.GetTrueResult().HclExpression()
		if err != nil {
			return "", err
		}
		falseResult, err := v.GetFalseResult().HclExpression()
		if err != nil {
			return "", err
		}
		return fmt.Sprintf("%s ? %s : %s", condition, trueResult, falseResult), nil
	case *Expression_Fexpr:
		v := self.GetFexpr()

		var key, collExpression, conditionalExpression, keyExpression, valExpression string
		var err error

		if v.KeyVar != "" {
			key = v.KeyVar + ", "
		}

		collExpression, err = v.CollExpr.HclExpression(self)
		if err == nil {
			collExpression = strings.TrimSpace(strings.ReplaceAll(collExpression, "\n", ""))
			valExpression, err = v.ValExpr.HclExpression()
			if err == nil && v.CondExpr != nil {
				conditionalExpression, err = v.CondExpr.HclExpression()
			}
			if err == nil && v.KeyExpr != nil {
				keyExpression, err = v.KeyExpr.HclExpression()
			}
		}
		if err != nil {
			return "", err
		}

		switch t := v.CollExpr.ExpressionClause.(type) {
		case *Expression_Ocexpr: // object = {for k, v in map: k => upper(v)}
			str := `for ` + key + v.ValVar + ` in ` + collExpression + `: ` + keyExpression + ` => ` + valExpression
			if conditionalExpression != "" {
				str += ` if ` + conditionalExpression
			}
			return str, nil
		case *Expression_Stexpr: // object = {for k, v in map: k => upper(v)}
			str := `for ` + key + v.ValVar + ` in ` + collExpression + `: ` + keyExpression + ` => ` + valExpression
			if conditionalExpression != "" {
				str += ` if ` + conditionalExpression
			}
			return str, nil
		default:
			return "", fmt.Errorf("unknown collection type: %T", t)
		}
	case *Expression_Fcexpr:
		expr := self.GetFcexpr()
		name := expr.GetName()
		args := expr.GetArgs()
		var arr []string
		for _, arg := range args {
			str, err := arg.HclExpression(level)
			if err != nil {
				return "", err
			}
			arr = append(arr, str)
		}
		return name + "(" + strings.Join(arr, ", ") + ")", nil
	case *Expression_Iexpr:
		v := self.GetIexpr()
		s_collection, err := v.GetCollection().HclExpression()
		if err != nil {
			return "", err
		}
		s_key, err := v.GetKey().HclExpression()
		if err != nil {
			return "", err
		}
		return s_collection + "[" + s_key + "]", nil
	case *Expression_Lvexpr:
		expr := self.GetLvexpr()
		return hclCty(expr.GetVal())
	case *Expression_Ocexpr:
		nextLeading := strings.Repeat("  ", level+2)
		leading := strings.Repeat("  ", level+1)
		expr := self.GetOcexpr()
		var arr []string
		for _, item := range expr.GetItems() {
			key, err := item.GetKeyExpr().HclExpression()
			if err != nil {
				return "", err
			}
			val, err := item.GetValueExpr().HclExpression(level + 1)
			if err != nil {
				return "", err
			}
			if parent != nil && parent.ExpressionClause.(*Expression_Fexpr) != nil {
				arr = append(arr, key+`:`+val)
			} else {
				arr = append(arr, nextLeading+key+" = "+val)
			}
		}
		if arr == nil {
			return "{}", nil
		}
		return fmt.Sprintf("{\n%s\n%s}", strings.Join(arr, ",\n"), leading), nil
	case *Expression_Ockexpr:
		expr := self.GetOckexpr()
		return expr.GetWrapped().HclExpression()
		/*
			case *Expression_Pexpr:
				v, err := xparenthesizedExprTo(e.Pexpr)
				return &ast.Expression{
					ExpressionClause: &ast.Expression_Pexpr{
						Pexpr: v,
					},
				}, err
			case *Expression_Rtexpr:
				v, err := xrelativeTraversalExprTo(e.Rtexpr)
				return &ast.Expression{
					ExpressionClause: &ast.Expression_Rtexpr{
						Rtexpr: v,
					},
				}, err
		*/
	case *Expression_Stexpr:
		v := self.GetStexpr()
		rootOnly := true
		var arr []string
		for _, trv := range v.GetTraversal() {
			switch t := trv.TraverserClause.(type) {
			case *Traverser_TRoot:
				arr = append(arr, t.TRoot.GetName())
			case *Traverser_TAttr:
				arr = append(arr, t.TAttr.GetName())
				rootOnly = false
			case *Traverser_TIndex:
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
			if _, ok := parent.ExpressionClause.(*Expression_Texpr); ok {
				return `${` + arr[0] + `}`, nil
			}

		}
		return strings.Join(arr, "."), nil
		/*
			case *Expression_Sexpr:
				v, err := xsplatExprTo(e.Sexpr)
				return &ast.Expression{
					ExpressionClause: &ast.Expression_Sexpr{
						Sexpr: v,
					},
				}, err
		*/
	case *Expression_Texpr:
		v := self.GetTexpr()
		var arr []string

		for _, part := range v.GetParts() {
			str, err := part.HclExpression(self)
			if err != nil {
				return "", err
			}
			arr = append(arr, str)
		}
		return `"` + strings.Join(arr, ``) + `"`, nil
		/*
			case *Expression_Tjexpr:
				v, err := xtemplateJoinExprTo(e.Tjexpr)
				return &ast.Expression{
					ExpressionClause: &ast.Expression_Tjexpr{
						Tjexpr: v,
					},
				}, err
			case *Expression_Twexpr:
				v, err := xtemplateWrapExprTo(e.Twexpr)
				return &ast.Expression{
					ExpressionClause: &ast.Expression_Twexpr{
						Twexpr: v,
					},
				}, err
		*/
	case *Expression_Tcexpr:
		v := self.GetTcexpr()
		var arr []string
		for _, item := range v.GetExprs() {
			// for tuple or array, each item stays at the current level
			str, err := item.HclExpression(level)
			if err != nil {
				return "", err
			}
			arr = append(arr, str)
		}
		return `[` + strings.Join(arr, ", ") + `]`, nil

	case *Expression_Uoexpr:
		v := self.GetUoexpr()
		str, err := v.Val.HclExpression()
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

func hclCty(self *CtyValue) (string, error) {
	switch t := self.CtyValueClause.(type) {
	case *CtyValue_StringValue:
		return t.StringValue, nil
	case *CtyValue_BoolValue:
		return fmt.Sprintf("%t", t.BoolValue), nil
	case *CtyValue_NumberValue:
		val := cty.NumberFloatVal(t.NumberValue)
		v, err := utils.CtyToNative(val)
		if err != nil {
			return "", err
		}
		switch v.(type) {
		case int, int64, int32, int16, int8, uint, uint64, uint32, uint16, uint8:
			return fmt.Sprintf("%d", v), nil
		default:
		}
		return fmt.Sprintf("%f", v), nil
	case *CtyValue_ListValue:
		var output []string
		for _, v := range t.ListValue.Values {
			u, err := hclCty(v)
			if err != nil {
				return "", err
			}
			output = append(output, u)
		}
		return "[" + strings.Join(output, " ,") + "]", nil
	case *CtyValue_MapValue:
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

func hclOperation(self *Operation) (string, error) {
	if self == nil {
		return "", nil
	}

	switch self.Sign {
	case TokenType_Or:
		return string(hclsyntax.TokenOr), nil
	case TokenType_And:
		return string(hclsyntax.TokenAnd), nil
	case TokenType_EqualOp: // hclsyntax.TokenEqual is not acceptable
		return string(hclsyntax.TokenEqual) + string(hclsyntax.TokenEqual), nil
	case TokenType_NotEqual:
		return string(hclsyntax.TokenNotEqual), nil
	case TokenType_GreaterThan:
		return string(hclsyntax.TokenGreaterThan), nil
	case TokenType_GreaterThanEq:
		return string(hclsyntax.TokenGreaterThanEq), nil
	case TokenType_LessThan:
		return string(hclsyntax.TokenLessThan), nil
	case TokenType_LessThanEq:
		return string(hclsyntax.TokenLessThanEq), nil
	case TokenType_Plus:
		return string(hclsyntax.TokenPlus), nil
	case TokenType_Minus:
		return string(hclsyntax.TokenMinus), nil
	case TokenType_Star:
		return string(hclsyntax.TokenStar), nil
	case TokenType_Slash:
		return string(hclsyntax.TokenSlash), nil
	case TokenType_Percent:
		return string(hclsyntax.TokenPercent), nil
	case TokenType_TokenUnknown:
		if self.Impl != nil && self.Impl.Description == "Applies the logical NOT operation to the given boolean value." {
			return string(hclsyntax.TokenBang), nil
		}
	default:
	}

	return "", fmt.Errorf("unknown operation type %T", self)
}
