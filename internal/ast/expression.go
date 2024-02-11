package ast

import (
	"fmt"

	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclsyntax"
)

func xanonSymbolExprTo(sym *hclsyntax.AnonSymbolExpr) (*AnonSymbolExpr, error) {
	if sym == nil {
		return nil, nil
	}

	return &AnonSymbolExpr{
		SrcRange: xrangeTo(sym.SrcRange),
	}, nil
}

func anonSymbolExprTo(sym *AnonSymbolExpr) (*hclsyntax.AnonSymbolExpr, error) {
	if sym == nil {
		return nil, nil
	}

	return &hclsyntax.AnonSymbolExpr{
		SrcRange: rangeTo(sym.SrcRange),
	}, nil
}

func xbinaryOpExprTo(expr *hclsyntax.BinaryOpExpr) (*BinaryOpExpr, error) {
	if expr == nil {
		return nil, nil
	}

	lhs, err := xexpressionTo(expr.LHS)
	if err != nil {
		return nil, err
	}
	rhs, err := xexpressionTo(expr.RHS)
	if err != nil {
		return nil, err
	}

	op := xoperationTo(expr.Op)

	return &BinaryOpExpr{
		Op:       op,
		LHS:      lhs,
		RHS:      rhs,
		SrcRange: xrangeTo(expr.SrcRange),
	}, nil
}

func binaryOpExprTo(expr *BinaryOpExpr) (*hclsyntax.BinaryOpExpr, error) {
	if expr == nil {
		return nil, nil
	}

	lhs, err := expressionTo(expr.LHS)
	if err != nil {
		return nil, err
	}
	rhs, err := expressionTo(expr.RHS)
	if err != nil {
		return nil, err
	}

	op := operationTo(expr.Op)

	return &hclsyntax.BinaryOpExpr{
		Op:       op,
		LHS:      lhs,
		RHS:      rhs,
		SrcRange: rangeTo(expr.SrcRange),
	}, nil
}

func xconditionalExprTo(expr *hclsyntax.ConditionalExpr) (*ConditionalExpr, error) {
	if expr == nil {
		return nil, nil
	}

	condition, err := xexpressionTo(expr.Condition)
	if err != nil {
		return nil, err
	}
	trueResult, err := xexpressionTo(expr.TrueResult)
	if err != nil {
		return nil, err
	}
	falseResult, err := xexpressionTo(expr.FalseResult)
	if err != nil {
		return nil, err
	}

	return &ConditionalExpr{
		Condition:   condition,
		TrueResult:  trueResult,
		FalseResult: falseResult,
		SrcRange:    xrangeTo(expr.SrcRange),
	}, nil
}

func conditionalExprTo(expr *ConditionalExpr) (*hclsyntax.ConditionalExpr, error) {
	if expr == nil {
		return nil, nil
	}

	condition, err := expressionTo(expr.Condition)
	if err != nil {
		return nil, err
	}
	trueResult, err := expressionTo(expr.TrueResult)
	if err != nil {
		return nil, err
	}
	falseResult, err := expressionTo(expr.FalseResult)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.ConditionalExpr{
		Condition:   condition,
		TrueResult:  trueResult,
		FalseResult: falseResult,
		SrcRange:    rangeTo(expr.SrcRange),
	}, nil
}

func xforExprTo(expr *hclsyntax.ForExpr) (*ForExpr, error) {
	if expr == nil {
		return nil, nil
	}

	keyExpr, err := xexpressionTo(expr.KeyExpr)
	if err != nil {
		return nil, err
	}
	valExpr, err := xexpressionTo(expr.ValExpr)
	if err != nil {
		return nil, err
	}
	collExpr, err := xexpressionTo(expr.CollExpr)
	if err != nil {
		return nil, err
	}
	condExpr, err := xexpressionTo(expr.CondExpr)
	if err != nil {
		return nil, err
	}

	return &ForExpr{
		KeyVar:     expr.KeyVar,
		ValVar:     expr.ValVar,
		KeyExpr:    keyExpr,
		ValExpr:    valExpr,
		CollExpr:   collExpr,
		CondExpr:   condExpr,
		Grp:        expr.Group,
		SrcRange:   xrangeTo(expr.SrcRange),
		OpenRange:  xrangeTo(expr.OpenRange),
		CloseRange: xrangeTo(expr.CloseRange),
	}, nil
}

func forExprTo(expr *ForExpr) (*hclsyntax.ForExpr, error) {
	if expr == nil {
		return nil, nil
	}

	keyExpr, err := expressionTo(expr.KeyExpr)
	if err != nil {
		return nil, err
	}
	valExpr, err := expressionTo(expr.ValExpr)
	if err != nil {
		return nil, err
	}
	collExpr, err := expressionTo(expr.CollExpr)
	if err != nil {
		return nil, err
	}
	condExpr, err := expressionTo(expr.CondExpr)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.ForExpr{
		KeyVar:     expr.KeyVar,
		ValVar:     expr.ValVar,
		KeyExpr:    keyExpr,
		ValExpr:    valExpr,
		CollExpr:   collExpr,
		CondExpr:   condExpr,
		Group:      expr.Grp,
		SrcRange:   rangeTo(expr.SrcRange),
		OpenRange:  rangeTo(expr.OpenRange),
		CloseRange: rangeTo(expr.CloseRange),
	}, nil
}

func xfunctionCallExprTo(expr *hclsyntax.FunctionCallExpr) (*FunctionCallExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var args []*Expression
	for _, arg := range expr.Args {
		a, err := xexpressionTo(arg)
		if err != nil {
			return nil, err
		}
		args = append(args, a)
	}

	return &FunctionCallExpr{
		Name:            expr.Name,
		Args:            args,
		ExpandFinal:     expr.ExpandFinal,
		NameRange:       xrangeTo(expr.NameRange),
		OpenParenRange:  xrangeTo(expr.OpenParenRange),
		CloseParenRange: xrangeTo(expr.CloseParenRange),
	}, nil
}

func functionCallExprTo(expr *FunctionCallExpr) (*hclsyntax.FunctionCallExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var args []hclsyntax.Expression
	for _, arg := range expr.Args {
		a, err := expressionTo(arg)
		if err != nil {
			return nil, err
		}
		args = append(args, a)
	}

	return &hclsyntax.FunctionCallExpr{
		Name:            expr.Name,
		Args:            args,
		ExpandFinal:     expr.ExpandFinal,
		NameRange:       rangeTo(expr.NameRange),
		OpenParenRange:  rangeTo(expr.OpenParenRange),
		CloseParenRange: rangeTo(expr.CloseParenRange),
	}, nil
}

func xindexExprTo(expr *hclsyntax.IndexExpr) (*IndexExpr, error) {
	if expr == nil {
		return nil, nil
	}

	collExpr, err := xexpressionTo(expr.Collection)
	if err != nil {
		return nil, err
	}
	keyExpr, err := xexpressionTo(expr.Key)
	if err != nil {
		return nil, err
	}

	return &IndexExpr{
		Collection:   collExpr,
		Key:          keyExpr,
		SrcRange:     xrangeTo(expr.SrcRange),
		OpenRange:    xrangeTo(expr.OpenRange),
		BracketRange: xrangeTo(expr.BracketRange),
	}, nil
}

func indexExprTo(expr *IndexExpr) (*hclsyntax.IndexExpr, error) {
	if expr == nil {
		return nil, nil
	}

	collExpr, err := expressionTo(expr.Collection)
	if err != nil {
		return nil, err
	}
	keyExpr, err := expressionTo(expr.Key)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.IndexExpr{
		Collection:   collExpr,
		Key:          keyExpr,
		SrcRange:     rangeTo(expr.SrcRange),
		OpenRange:    rangeTo(expr.OpenRange),
		BracketRange: rangeTo(expr.BracketRange),
	}, nil
}

func xliteralValueExprTo(expr *hclsyntax.LiteralValueExpr) (*LiteralValueExpr, error) {
	if expr == nil {
		return nil, nil
	}

	val, err := xctyValueTo(expr.Val)
	if err != nil {
		return nil, err
	}
	return &LiteralValueExpr{
		Val:      val,
		SrcRange: xrangeTo(expr.SrcRange),
	}, nil
}

func literalValueExprTo(expr *LiteralValueExpr) (*hclsyntax.LiteralValueExpr, error) {
	if expr == nil {
		return nil, nil
	}

	val, err := CtyValueTo(expr.Val)
	if err != nil {
		return nil, err
	}
	return &hclsyntax.LiteralValueExpr{
		Val:      val,
		SrcRange: rangeTo(expr.SrcRange),
	}, nil
}

func xobjectConsItemTo(item *hclsyntax.ObjectConsItem) (*ObjectConsItem, error) {
	if item == nil {
		return nil, nil
	}

	keyExpr, err := xexpressionTo(item.KeyExpr)
	if err != nil {
		return nil, err
	}
	valueExpr, err := xexpressionTo(item.ValueExpr)
	if err != nil {
		return nil, err
	}

	return &ObjectConsItem{
		KeyExpr:   keyExpr,
		ValueExpr: valueExpr,
	}, nil
}

func objectConsItemTo(item *ObjectConsItem) (*hclsyntax.ObjectConsItem, error) {
	if item == nil {
		return nil, nil
	}

	keyExpr, err := expressionTo(item.KeyExpr)
	if err != nil {
		return nil, err
	}
	valueExpr, err := expressionTo(item.ValueExpr)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.ObjectConsItem{
		KeyExpr:   keyExpr,
		ValueExpr: valueExpr,
	}, nil
}

func xobjectConsExprTo(expr *hclsyntax.ObjectConsExpr) (*ObjectConsExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var items []*ObjectConsItem
	for _, item := range expr.Items {
		i, err := xobjectConsItemTo(&item)
		if err != nil {
			return nil, err
		}
		items = append(items, i)
	}

	return &ObjectConsExpr{
		Items:     items,
		OpenRange: xrangeTo(expr.OpenRange),
		SrcRange:  xrangeTo(expr.SrcRange),
	}, nil
}

func objectConsExprTo(expr *ObjectConsExpr) (*hclsyntax.ObjectConsExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var items []hclsyntax.ObjectConsItem
	for _, item := range expr.Items {
		i, err := objectConsItemTo(item)
		if err != nil {
			return nil, err
		}
		items = append(items, *i)
	}

	return &hclsyntax.ObjectConsExpr{
		Items:     items,
		OpenRange: rangeTo(expr.OpenRange),
		SrcRange:  rangeTo(expr.SrcRange),
	}, nil
}

func xobjectConsKeyExprTo(expr *hclsyntax.ObjectConsKeyExpr) (*ObjectConsKeyExpr, error) {
	if expr == nil {
		return nil, nil
	}

	wrapped, err := xexpressionTo(expr.Wrapped)
	if err != nil {
		return nil, err
	}

	return &ObjectConsKeyExpr{
		Wrapped:         wrapped,
		ForceNonLiteral: expr.ForceNonLiteral,
	}, nil
}

func objectConsKeyExprTo(expr *ObjectConsKeyExpr) (*hclsyntax.ObjectConsKeyExpr, error) {
	if expr == nil {
		return nil, nil
	}

	wrapped, err := expressionTo(expr.Wrapped)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.ObjectConsKeyExpr{
		Wrapped:         wrapped,
		ForceNonLiteral: expr.ForceNonLiteral,
	}, nil
}

func xparenthesizedExprTo(expr *hclsyntax.ParenthesesExpr) (*ParenthesesExpr, error) {
	if expr == nil {
		return nil, nil
	}

	expression, err := xexpressionTo(expr.Expression)
	if err != nil {
		return nil, err
	}

	return &ParenthesesExpr{
		Expr:     expression,
		SrcRange: xrangeTo(expr.SrcRange),
	}, nil
}

func parenthesesExprTo(expr *ParenthesesExpr) (*hclsyntax.ParenthesesExpr, error) {
	if expr == nil {
		return nil, nil
	}

	expression, err := expressionTo(expr.Expr)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.ParenthesesExpr{
		Expression: expression,
		SrcRange:   rangeTo(expr.SrcRange),
	}, nil
}

func xrelativeTraversalExprTo(expr *hclsyntax.RelativeTraversalExpr) (*RelativeTraversalExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var traversal []*Traverser
	for _, trv := range expr.Traversal {
		t, err := xtraverseTo(trv)
		if err != nil {
			return nil, err
		}
		traversal = append(traversal, t)
	}

	source, err := xexpressionTo(expr.Source)
	if err != nil {
		return nil, err
	}

	return &RelativeTraversalExpr{
		Source:    source,
		Traversal: traversal,
		SrcRange:  xrangeTo(expr.SrcRange),
	}, nil
}

func relativeTraversalExprTo(expr *RelativeTraversalExpr) (*hclsyntax.RelativeTraversalExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var traversal []hcl.Traverser
	for _, trv := range expr.Traversal {
		t, err := traverseTo(trv)
		if err != nil {
			return nil, err
		}
		traversal = append(traversal, t)
	}

	source, err := expressionTo(expr.Source)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.RelativeTraversalExpr{
		Source:    source,
		Traversal: traversal,
		SrcRange:  rangeTo(expr.SrcRange),
	}, nil
}

func xscopeTraversalExprTo(expr *hclsyntax.ScopeTraversalExpr) (*ScopeTraversalExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var traversal []*Traverser
	for _, trv := range expr.Traversal {
		t, err := xtraverseTo(trv)
		if err != nil {
			return nil, err
		}
		traversal = append(traversal, t)
	}

	return &ScopeTraversalExpr{
		Traversal: traversal,
		SrcRange:  xrangeTo(expr.SrcRange),
	}, nil
}

func scopeTraversalExprTo(expr *ScopeTraversalExpr) (*hclsyntax.ScopeTraversalExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var traversal []hcl.Traverser
	for _, trv := range expr.Traversal {
		t, err := traverseTo(trv)
		if err != nil {
			return nil, err
		}
		traversal = append(traversal, t)
	}

	return &hclsyntax.ScopeTraversalExpr{
		Traversal: traversal,
		SrcRange:  rangeTo(expr.SrcRange),
	}, nil
}

func xsplatExprTo(expr *hclsyntax.SplatExpr) (*SplatExpr, error) {
	if expr == nil {
		return nil, nil
	}

	source, err := xexpressionTo(expr.Source)
	if err != nil {
		return nil, err
	}
	each, err := xexpressionTo(expr.Each)
	if err != nil {
		return nil, err
	}

	item, err := xanonSymbolExprTo(expr.Item)
	if err != nil {
		return nil, err
	}

	return &SplatExpr{
		Source:      source,
		Each:        each,
		Item:        item,
		SrcRange:    xrangeTo(expr.SrcRange),
		MarkerRange: xrangeTo(expr.MarkerRange),
	}, nil
}

func splatExprTo(expr *SplatExpr) (*hclsyntax.SplatExpr, error) {
	if expr == nil {
		return nil, nil
	}

	source, err := expressionTo(expr.Source)
	if err != nil {
		return nil, err
	}
	each, err := expressionTo(expr.Each)
	if err != nil {
		return nil, err
	}

	item, err := anonSymbolExprTo(expr.Item)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.SplatExpr{
		Source:      source,
		Each:        each,
		Item:        item,
		SrcRange:    rangeTo(expr.SrcRange),
		MarkerRange: rangeTo(expr.MarkerRange),
	}, nil
}

func xtemplateExprTo(expr *hclsyntax.TemplateExpr) (*TemplateExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var parts []*Expression
	for _, part := range expr.Parts {
		p, err := xexpressionTo(part)
		if err != nil {
			return nil, err
		}
		parts = append(parts, p)
	}

	return &TemplateExpr{
		Parts:    parts,
		SrcRange: xrangeTo(expr.SrcRange),
	}, nil
}

func templateExprTo(expr *TemplateExpr) (*hclsyntax.TemplateExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var parts []hclsyntax.Expression
	for _, part := range expr.Parts {
		p, err := expressionTo(part)
		if err != nil {
			return nil, err
		}
		parts = append(parts, p)
	}

	return &hclsyntax.TemplateExpr{
		Parts:    parts,
		SrcRange: rangeTo(expr.SrcRange),
	}, nil
}

func xtemplateJoinExprTo(expr *hclsyntax.TemplateJoinExpr) (*TemplateJoinExpr, error) {
	if expr == nil {
		return nil, nil
	}

	t, err := xexpressionTo(expr)
	return &TemplateJoinExpr{
		Tuple: t,
	}, err
}

func templateJoinExprTo(expr *TemplateJoinExpr) (*hclsyntax.TemplateJoinExpr, error) {
	if expr == nil {
		return nil, nil
	}

	t, err := expressionTo(expr.Tuple)
	return &hclsyntax.TemplateJoinExpr{
		Tuple: t,
	}, err
}

func xtemplateWrapExprTo(expr *hclsyntax.TemplateWrapExpr) (*TemplateWrapExpr, error) {
	if expr == nil {
		return nil, nil
	}

	wrapped, err := xexpressionTo(expr.Wrapped)
	if err != nil {
		return nil, err
	}

	return &TemplateWrapExpr{
		Wrapped:  wrapped,
		SrcRange: xrangeTo(expr.SrcRange),
	}, nil
}

func templateWrapExprTo(expr *TemplateWrapExpr) (*hclsyntax.TemplateWrapExpr, error) {
	if expr == nil {
		return nil, nil
	}

	wrapped, err := expressionTo(expr.Wrapped)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.TemplateWrapExpr{
		Wrapped:  wrapped,
		SrcRange: rangeTo(expr.SrcRange),
	}, nil
}

func xtupleConsExprTo(expr *hclsyntax.TupleConsExpr) (*TupleConsExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var expressions []*Expression
	for _, e := range expr.Exprs {
		ex, err := xexpressionTo(e)
		if err != nil {
			return nil, err
		}
		expressions = append(expressions, ex)
	}

	return &TupleConsExpr{
		Exprs:     expressions,
		OpenRange: xrangeTo(expr.OpenRange),
		SrcRange:  xrangeTo(expr.SrcRange),
	}, nil
}

func tupleConsExprTo(expr *TupleConsExpr) (*hclsyntax.TupleConsExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var expressions []hclsyntax.Expression
	for _, e := range expr.Exprs {
		ex, err := expressionTo(e)
		if err != nil {
			return nil, err
		}
		expressions = append(expressions, ex)
	}

	return &hclsyntax.TupleConsExpr{
		Exprs:     expressions,
		OpenRange: rangeTo(expr.OpenRange),
		SrcRange:  rangeTo(expr.SrcRange),
	}, nil
}

func xunaryOpExprTo(expr *hclsyntax.UnaryOpExpr) (*UnaryOpExpr, error) {
	if expr == nil {
		return nil, nil
	}

	operand := xoperationTo(expr.Op)

	val, err := xexpressionTo(expr.Val)
	if err != nil {
		return nil, err
	}

	return &UnaryOpExpr{
		Op:          operand,
		Val:         val,
		SrcRange:    xrangeTo(expr.SrcRange),
		SymbolRange: xrangeTo(expr.SymbolRange),
	}, nil
}

func unaryOpExprTo(expr *UnaryOpExpr) (*hclsyntax.UnaryOpExpr, error) {
	if expr == nil {
		return nil, nil
	}

	operand := operationTo(expr.Op)

	val, err := expressionTo(expr.Val)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.UnaryOpExpr{
		Op:          operand,
		Val:         val,
		SrcRange:    rangeTo(expr.SrcRange),
		SymbolRange: rangeTo(expr.SymbolRange),
	}, nil
}

func xexpressionTo(expr hcl.Expression) (*Expression, error) {
	if expr == nil {
		return nil, nil
	}

	switch e := expr.(type) {
	case *hclsyntax.AnonSymbolExpr:
		v, err := xanonSymbolExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Asexpr{
				Asexpr: v,
			},
		}, err
	case *hclsyntax.BinaryOpExpr:
		v, err := xbinaryOpExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Boexpr{
				Boexpr: v,
			},
		}, err
	case *hclsyntax.ConditionalExpr:
		v, err := xconditionalExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Cexpr{
				Cexpr: v,
			},
		}, err
	case *hclsyntax.ForExpr:
		v, err := xforExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Fexpr{
				Fexpr: v,
			},
		}, err
	case *hclsyntax.FunctionCallExpr:
		v, err := xfunctionCallExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Fcexpr{
				Fcexpr: v,
			},
		}, err
	case *hclsyntax.IndexExpr:
		v, err := xindexExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Iexpr{
				Iexpr: v,
			},
		}, err
	case *hclsyntax.LiteralValueExpr:
		v, err := xliteralValueExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Lvexpr{
				Lvexpr: v,
			},
		}, err
	case *hclsyntax.ObjectConsExpr:
		v, err := xobjectConsExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Ocexpr{
				Ocexpr: v,
			},
		}, err
	case *hclsyntax.ObjectConsKeyExpr:
		v, err := xobjectConsKeyExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Ockexpr{
				Ockexpr: v,
			},
		}, err
	case *hclsyntax.ParenthesesExpr:
		v, err := xparenthesizedExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Pexpr{
				Pexpr: v,
			},
		}, err
	case *hclsyntax.RelativeTraversalExpr:
		v, err := xrelativeTraversalExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Rtexpr{
				Rtexpr: v,
			},
		}, err
	case *hclsyntax.ScopeTraversalExpr:
		v, err := xscopeTraversalExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Stexpr{
				Stexpr: v,
			},
		}, err
	case *hclsyntax.SplatExpr:
		v, err := xsplatExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Sexpr{
				Sexpr: v,
			},
		}, err
	case *hclsyntax.TemplateExpr:
		v, err := xtemplateExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Texpr{
				Texpr: v,
			},
		}, err
	case *hclsyntax.TemplateJoinExpr:
		v, err := xtemplateJoinExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Tjexpr{
				Tjexpr: v,
			},
		}, err
	case *hclsyntax.TemplateWrapExpr:
		v, err := xtemplateWrapExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Twexpr{
				Twexpr: v,
			},
		}, err
	case *hclsyntax.TupleConsExpr:
		v, err := xtupleConsExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Tcexpr{
				Tcexpr: v,
			},
		}, err
	case *hclsyntax.UnaryOpExpr:
		v, err := xunaryOpExprTo(e)
		return &Expression{
			ExpressionClause: &Expression_Uoexpr{
				Uoexpr: v,
			},
		}, err
	default:
	}

	return nil, fmt.Errorf("unknown expression type %T", expr)
}

func expressionTo(expr *Expression) (hclsyntax.Expression, error) {
	if expr == nil {
		return nil, nil
	}

	switch e := expr.ExpressionClause.(type) {
	case *Expression_Asexpr:
		v, err := anonSymbolExprTo(e.Asexpr)
		return v, err
	case *Expression_Boexpr:
		v, err := binaryOpExprTo(e.Boexpr)
		return v, err
	case *Expression_Cexpr:
		v, err := conditionalExprTo(e.Cexpr)
		return v, err
	case *Expression_Fexpr:
		v, err := forExprTo(e.Fexpr)
		return v, err
	case *Expression_Fcexpr:
		v, err := functionCallExprTo(e.Fcexpr)
		return v, err
	case *Expression_Iexpr:
		v, err := indexExprTo(e.Iexpr)
		return v, err
	case *Expression_Lvexpr:
		v, err := literalValueExprTo(e.Lvexpr)
		return v, err
	case *Expression_Ocexpr:
		v, err := objectConsExprTo(e.Ocexpr)
		return v, err
	case *Expression_Ockexpr:
		v, err := objectConsKeyExprTo(e.Ockexpr)
		return v, err
	case *Expression_Pexpr:
		v, err := parenthesesExprTo(e.Pexpr)
		return v, err
	case *Expression_Rtexpr:
		v, err := relativeTraversalExprTo(e.Rtexpr)
		return v, err
	case *Expression_Stexpr:
		v, err := scopeTraversalExprTo(e.Stexpr)
		return v, err
	case *Expression_Sexpr:
		v, err := splatExprTo(e.Sexpr)
		return v, err
	case *Expression_Texpr:
		v, err := templateExprTo(e.Texpr)
		return v, err
	case *Expression_Tjexpr:
		v, err := templateJoinExprTo(e.Tjexpr)
		return v, err
	case *Expression_Twexpr:
		v, err := templateWrapExprTo(e.Twexpr)
		return v, err
	case *Expression_Tcexpr:
		v, err := tupleConsExprTo(e.Tcexpr)
		return v, err
	case *Expression_Uoexpr:
		v, err := unaryOpExprTo(e.Uoexpr)
		return v, err
	default:
	}

	return nil, fmt.Errorf("unknown expression type %T", expr)
}
