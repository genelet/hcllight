package light

import (
	"fmt"

	"github.com/genelet/hcllight/internal/ast"
)

func xanonSymbolExprTo(sym *AnonSymbolExpr) (*ast.AnonSymbolExpr, error) {
	if sym == nil {
		return nil, nil
	}

	return &ast.AnonSymbolExpr{
		SrcRange: xrangeTo(sym),
	}, nil
}

func anonSymbolExprTo(sym *ast.AnonSymbolExpr) (*AnonSymbolExpr, error) {
	if sym == nil {
		return nil, nil
	}

	return &AnonSymbolExpr{}, nil
}

func xbinaryOpExprTo(expr *BinaryOpExpr) (*ast.BinaryOpExpr, error) {
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

	return &ast.BinaryOpExpr{
		Op:       op,
		LHS:      lhs,
		RHS:      rhs,
		SrcRange: xrangeTo(expr),
	}, nil
}

func binaryOpExprTo(expr *ast.BinaryOpExpr) (*BinaryOpExpr, error) {
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

	return &BinaryOpExpr{
		Op:  op,
		LHS: lhs,
		RHS: rhs,
	}, nil
}

func xconditionalExprTo(expr *ConditionalExpr) (*ast.ConditionalExpr, error) {
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

	return &ast.ConditionalExpr{
		Condition:   condition,
		TrueResult:  trueResult,
		FalseResult: falseResult,
		SrcRange:    xrangeTo(expr),
	}, nil
}

func conditionalExprTo(expr *ast.ConditionalExpr) (*ConditionalExpr, error) {
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

	return &ConditionalExpr{
		Condition:   condition,
		TrueResult:  trueResult,
		FalseResult: falseResult,
	}, nil
}

func xforExprTo(expr *ForExpr) (*ast.ForExpr, error) {
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

	return &ast.ForExpr{
		KeyVar:     expr.KeyVar,
		ValVar:     expr.ValVar,
		KeyExpr:    keyExpr,
		ValExpr:    valExpr,
		CollExpr:   collExpr,
		CondExpr:   condExpr,
		Grp:        expr.Grp,
		SrcRange:   xrangeTo(expr),
		OpenRange:  xrangeTo(expr),
		CloseRange: xrangeTo(expr),
	}, nil
}

func forExprTo(expr *ast.ForExpr) (*ForExpr, error) {
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

	return &ForExpr{
		KeyVar:   expr.KeyVar,
		ValVar:   expr.ValVar,
		KeyExpr:  keyExpr,
		ValExpr:  valExpr,
		CollExpr: collExpr,
		CondExpr: condExpr,
		Grp:      expr.Grp,
	}, nil
}

func xfunctionCallExprTo(expr *FunctionCallExpr) (*ast.FunctionCallExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var args []*ast.Expression
	for _, arg := range expr.Args {
		a, err := xexpressionTo(arg)
		if err != nil {
			return nil, err
		}
		args = append(args, a)
	}

	return &ast.FunctionCallExpr{
		Name:            expr.Name,
		Args:            args,
		ExpandFinal:     expr.ExpandFinal,
		NameRange:       xrangeTo(expr),
		OpenParenRange:  xrangeTo(expr),
		CloseParenRange: xrangeTo(expr),
	}, nil
}

func functionCallExprTo(expr *ast.FunctionCallExpr) (*FunctionCallExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var args []*Expression
	for _, arg := range expr.Args {
		a, err := expressionTo(arg)
		if err != nil {
			return nil, err
		}
		args = append(args, a)
	}

	return &FunctionCallExpr{
		Name:        expr.Name,
		Args:        args,
		ExpandFinal: expr.ExpandFinal,
	}, nil
}

func xindexExprTo(expr *IndexExpr) (*ast.IndexExpr, error) {
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

	return &ast.IndexExpr{
		Collection:   collExpr,
		Key:          keyExpr,
		SrcRange:     xrangeTo(expr),
		OpenRange:    xrangeTo(expr),
		BracketRange: xrangeTo(expr),
	}, nil
}

func indexExprTo(expr *ast.IndexExpr) (*IndexExpr, error) {
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

	return &IndexExpr{
		Collection: collExpr,
		Key:        keyExpr,
	}, nil
}

func xliteralValueExprTo(expr *LiteralValueExpr) (*ast.LiteralValueExpr, error) {
	if expr == nil {
		return nil, nil
	}

	val, err := xctyValueTo(expr.Val)
	if err != nil {
		return nil, err
	}
	return &ast.LiteralValueExpr{
		Val:      val,
		SrcRange: xrangeTo(expr),
	}, nil
}

func literalValueExprTo(expr *ast.LiteralValueExpr) (*LiteralValueExpr, error) {
	if expr == nil {
		return nil, nil
	}

	val, err := ctyValueTo(expr.Val)
	if err != nil {
		return nil, err
	}
	return &LiteralValueExpr{
		Val: val,
	}, nil
}

func xobjectConsItemTo(item *ObjectConsItem) (*ast.ObjectConsItem, error) {
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

	return &ast.ObjectConsItem{
		KeyExpr:   keyExpr,
		ValueExpr: valueExpr,
	}, nil
}

func objectConsItemTo(item *ast.ObjectConsItem) (*ObjectConsItem, error) {
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

	return &ObjectConsItem{
		KeyExpr:   keyExpr,
		ValueExpr: valueExpr,
	}, nil
}

func xobjectConsExprTo(expr *ObjectConsExpr) (*ast.ObjectConsExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var items []*ast.ObjectConsItem
	for _, item := range expr.Items {
		i, err := xobjectConsItemTo(item)
		if err != nil {
			return nil, err
		}
		items = append(items, i)
	}

	return &ast.ObjectConsExpr{
		Items:     items,
		OpenRange: xrangeTo(expr),
		SrcRange:  xrangeTo(expr),
	}, nil
}

func objectConsExprTo(expr *ast.ObjectConsExpr) (*ObjectConsExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var items []*ObjectConsItem
	for _, item := range expr.Items {
		i, err := objectConsItemTo(item)
		if err != nil {
			return nil, err
		}
		items = append(items, i)
	}

	return &ObjectConsExpr{
		Items: items,
	}, nil
}

func xobjectConsKeyExprTo(expr *ObjectConsKeyExpr) (*ast.ObjectConsKeyExpr, error) {
	if expr == nil {
		return nil, nil
	}

	wrapped, err := xexpressionTo(expr.Wrapped)
	if err != nil {
		return nil, err
	}

	return &ast.ObjectConsKeyExpr{
		Wrapped:         wrapped,
		ForceNonLiteral: expr.ForceNonLiteral,
	}, nil
}

func objectConsKeyExprTo(expr *ast.ObjectConsKeyExpr) (*ObjectConsKeyExpr, error) {
	if expr == nil {
		return nil, nil
	}

	wrapped, err := expressionTo(expr.Wrapped)
	if err != nil {
		return nil, err
	}

	return &ObjectConsKeyExpr{
		Wrapped:         wrapped,
		ForceNonLiteral: expr.ForceNonLiteral,
	}, nil
}

func xparenthesizedExprTo(expr *ParenthesesExpr) (*ast.ParenthesesExpr, error) {
	if expr == nil {
		return nil, nil
	}

	expression, err := xexpressionTo(expr.Expr)
	if err != nil {
		return nil, err
	}

	return &ast.ParenthesesExpr{
		Expr:     expression,
		SrcRange: xrangeTo(expr),
	}, nil
}

func parenthesesExprTo(expr *ast.ParenthesesExpr) (*ParenthesesExpr, error) {
	if expr == nil {
		return nil, nil
	}

	expression, err := expressionTo(expr.Expr)
	if err != nil {
		return nil, err
	}

	return &ParenthesesExpr{
		Expr: expression,
	}, nil
}

func xrelativeTraversalExprTo(expr *RelativeTraversalExpr) (*ast.RelativeTraversalExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var traversal []*ast.Traverser
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

	return &ast.RelativeTraversalExpr{
		Source:    source,
		Traversal: traversal,
		SrcRange:  xrangeTo(expr),
	}, nil
}

func relativeTraversalExprTo(expr *ast.RelativeTraversalExpr) (*RelativeTraversalExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var traversal []*Traverser
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

	return &RelativeTraversalExpr{
		Source:    source,
		Traversal: traversal,
	}, nil
}

func xscopeTraversalExprTo(expr *ScopeTraversalExpr) (*ast.ScopeTraversalExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var traversal []*ast.Traverser
	for _, trv := range expr.Traversal {
		t, err := xtraverseTo(trv)
		if err != nil {
			return nil, err
		}
		traversal = append(traversal, t)
	}

	return &ast.ScopeTraversalExpr{
		Traversal: traversal,
		SrcRange:  xrangeTo(expr),
	}, nil
}

func scopeTraversalExprTo(expr *ast.ScopeTraversalExpr) (*ScopeTraversalExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var traversal []*Traverser
	for _, trv := range expr.Traversal {
		t, err := traverseTo(trv)
		if err != nil {
			return nil, err
		}
		traversal = append(traversal, t)
	}

	return &ScopeTraversalExpr{
		Traversal: traversal,
	}, nil
}

func xsplatExprTo(expr *SplatExpr) (*ast.SplatExpr, error) {
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

	return &ast.SplatExpr{
		Source:      source,
		Each:        each,
		Item:        item,
		SrcRange:    xrangeTo(expr),
		MarkerRange: xrangeTo(expr),
	}, nil
}

func splatExprTo(expr *ast.SplatExpr) (*SplatExpr, error) {
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

	return &SplatExpr{
		Source: source,
		Each:   each,
		Item:   item,
	}, nil
}

func xtemplateExprTo(expr *TemplateExpr) (*ast.TemplateExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var parts []*ast.Expression
	for _, part := range expr.Parts {
		p, err := xexpressionTo(part)
		if err != nil {
			return nil, err
		}
		parts = append(parts, p)
	}

	return &ast.TemplateExpr{
		Parts:    parts,
		SrcRange: xrangeTo(expr),
	}, nil
}

func templateExprTo(expr *ast.TemplateExpr) (*TemplateExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var parts []*Expression
	for _, part := range expr.Parts {
		p, err := expressionTo(part)
		if err != nil {
			return nil, err
		}
		parts = append(parts, p)
	}

	return &TemplateExpr{
		Parts: parts,
	}, nil
}

func xtemplateJoinExprTo(expr *TemplateJoinExpr) (*ast.TemplateJoinExpr, error) {
	if expr == nil {
		return nil, nil
	}

	t, err := xexpressionTo(expr.Tuple)
	return &ast.TemplateJoinExpr{
		Tuple: t,
	}, err
}

func templateJoinExprTo(expr *ast.TemplateJoinExpr) (*TemplateJoinExpr, error) {
	if expr == nil {
		return nil, nil
	}

	t, err := expressionTo(expr.Tuple)
	return &TemplateJoinExpr{
		Tuple: t,
	}, err
}

func xtemplateWrapExprTo(expr *TemplateWrapExpr) (*ast.TemplateWrapExpr, error) {
	if expr == nil {
		return nil, nil
	}

	wrapped, err := xexpressionTo(expr.Wrapped)
	return &ast.TemplateWrapExpr{
		Wrapped:  wrapped,
		SrcRange: xrangeTo(expr),
	}, err
}

func templateWrapExprTo(expr *ast.TemplateWrapExpr) (*TemplateWrapExpr, error) {
	if expr == nil {
		return nil, nil
	}

	wrapped, err := expressionTo(expr.Wrapped)
	return &TemplateWrapExpr{
		Wrapped: wrapped,
	}, err
}

func xtupleConsExprTo(expr *TupleConsExpr) (*ast.TupleConsExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var expressions []*ast.Expression
	for _, e := range expr.Exprs {
		ex, err := xexpressionTo(e)
		if err != nil {
			return nil, err
		}
		expressions = append(expressions, ex)
	}

	return &ast.TupleConsExpr{
		Exprs:     expressions,
		OpenRange: xrangeTo(expr),
		SrcRange:  xrangeTo(expr),
	}, nil
}

func tupleConsExprTo(expr *ast.TupleConsExpr) (*TupleConsExpr, error) {
	if expr == nil {
		return nil, nil
	}

	var expressions []*Expression
	for _, e := range expr.Exprs {
		ex, err := expressionTo(e)
		if err != nil {
			return nil, err
		}
		expressions = append(expressions, ex)
	}

	return &TupleConsExpr{
		Exprs: expressions,
	}, nil
}

func xunaryOpExprTo(expr *UnaryOpExpr) (*ast.UnaryOpExpr, error) {
	if expr == nil {
		return nil, nil
	}

	operand := xoperationTo(expr.Op)

	val, err := xexpressionTo(expr.Val)
	return &ast.UnaryOpExpr{
		Op:          operand,
		Val:         val,
		SrcRange:    xrangeTo(expr),
		SymbolRange: xrangeTo(expr),
	}, err
}

func unaryOpExprTo(expr *ast.UnaryOpExpr) (*UnaryOpExpr, error) {
	if expr == nil {
		return nil, nil
	}

	operand := operationTo(expr.Op)

	val, err := expressionTo(expr.Val)
	return &UnaryOpExpr{
		Op:  operand,
		Val: val,
	}, err
}

func xexpressionTo(expr *Expression) (*ast.Expression, error) {
	if expr == nil {
		return nil, nil
	}

	switch e := expr.ExpressionClause.(type) {
	case *Expression_Asexpr:
		v, err := xanonSymbolExprTo(e.Asexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Asexpr{
				Asexpr: v,
			},
		}, err
	case *Expression_Boexpr:
		v, err := xbinaryOpExprTo(e.Boexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Boexpr{
				Boexpr: v,
			},
		}, err
	case *Expression_Cexpr:
		v, err := xconditionalExprTo(e.Cexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Cexpr{
				Cexpr: v,
			},
		}, err
	case *Expression_Fexpr:
		v, err := xforExprTo(e.Fexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Fexpr{
				Fexpr: v,
			},
		}, err
	case *Expression_Fcexpr:
		v, err := xfunctionCallExprTo(e.Fcexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Fcexpr{
				Fcexpr: v,
			},
		}, err
	case *Expression_Iexpr:
		v, err := xindexExprTo(e.Iexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Iexpr{
				Iexpr: v,
			},
		}, err
	case *Expression_Lvexpr:
		v, err := xliteralValueExprTo(e.Lvexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Lvexpr{
				Lvexpr: v,
			},
		}, err
	case *Expression_Ocexpr:
		v, err := xobjectConsExprTo(e.Ocexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Ocexpr{
				Ocexpr: v,
			},
		}, err
	case *Expression_Ockexpr:
		v, err := xobjectConsKeyExprTo(e.Ockexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Ockexpr{
				Ockexpr: v,
			},
		}, err
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
	case *Expression_Stexpr:
		v, err := xscopeTraversalExprTo(e.Stexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Stexpr{
				Stexpr: v,
			},
		}, err
	case *Expression_Sexpr:
		v, err := xsplatExprTo(e.Sexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Sexpr{
				Sexpr: v,
			},
		}, err
	case *Expression_Texpr:
		v, err := xtemplateExprTo(e.Texpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Texpr{
				Texpr: v,
			},
		}, err
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
	case *Expression_Tcexpr:
		v, err := xtupleConsExprTo(e.Tcexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Tcexpr{
				Tcexpr: v,
			},
		}, err
	case *Expression_Uoexpr:
		v, err := xunaryOpExprTo(e.Uoexpr)
		return &ast.Expression{
			ExpressionClause: &ast.Expression_Uoexpr{
				Uoexpr: v,
			},
		}, err
	default:
	}
	return nil, fmt.Errorf("unknown expression type %T", expr)
}

func expressionTo(expr *ast.Expression) (*Expression, error) {
	if expr == nil {
		return nil, nil
	}

	switch e := expr.ExpressionClause.(type) {
	case *ast.Expression_Asexpr:
		v, err := anonSymbolExprTo(e.Asexpr)
		return &Expression{
			ExpressionClause: &Expression_Asexpr{
				Asexpr: v,
			},
		}, err
	case *ast.Expression_Boexpr:
		v, err := binaryOpExprTo(e.Boexpr)
		return &Expression{
			ExpressionClause: &Expression_Boexpr{
				Boexpr: v,
			},
		}, err
	case *ast.Expression_Cexpr:
		v, err := conditionalExprTo(e.Cexpr)
		return &Expression{
			ExpressionClause: &Expression_Cexpr{
				Cexpr: v,
			},
		}, err
	case *ast.Expression_Fexpr:
		v, err := forExprTo(e.Fexpr)
		return &Expression{
			ExpressionClause: &Expression_Fexpr{
				Fexpr: v,
			},
		}, err
	case *ast.Expression_Fcexpr:
		v, err := functionCallExprTo(e.Fcexpr)
		return &Expression{
			ExpressionClause: &Expression_Fcexpr{
				Fcexpr: v,
			},
		}, err
	case *ast.Expression_Iexpr:
		v, err := indexExprTo(e.Iexpr)
		return &Expression{
			ExpressionClause: &Expression_Iexpr{
				Iexpr: v,
			},
		}, err
	case *ast.Expression_Lvexpr:
		v, err := literalValueExprTo(e.Lvexpr)
		return &Expression{
			ExpressionClause: &Expression_Lvexpr{
				Lvexpr: v,
			},
		}, err
	case *ast.Expression_Ocexpr:
		v, err := objectConsExprTo(e.Ocexpr)
		return &Expression{
			ExpressionClause: &Expression_Ocexpr{
				Ocexpr: v,
			},
		}, err
	case *ast.Expression_Ockexpr:
		v, err := objectConsKeyExprTo(e.Ockexpr)
		return &Expression{
			ExpressionClause: &Expression_Ockexpr{
				Ockexpr: v,
			},
		}, err
	case *ast.Expression_Pexpr:
		v, err := parenthesesExprTo(e.Pexpr)
		return &Expression{
			ExpressionClause: &Expression_Pexpr{
				Pexpr: v,
			},
		}, err
	case *ast.Expression_Rtexpr:
		v, err := relativeTraversalExprTo(e.Rtexpr)
		return &Expression{
			ExpressionClause: &Expression_Rtexpr{
				Rtexpr: v,
			},
		}, err
	case *ast.Expression_Stexpr:
		v, err := scopeTraversalExprTo(e.Stexpr)
		return &Expression{
			ExpressionClause: &Expression_Stexpr{
				Stexpr: v,
			},
		}, err
	case *ast.Expression_Sexpr:
		v, err := splatExprTo(e.Sexpr)
		return &Expression{
			ExpressionClause: &Expression_Sexpr{
				Sexpr: v,
			},
		}, err
	case *ast.Expression_Texpr:
		v, err := templateExprTo(e.Texpr)
		return &Expression{
			ExpressionClause: &Expression_Texpr{
				Texpr: v,
			},
		}, err
	case *ast.Expression_Tjexpr:
		v, err := templateJoinExprTo(e.Tjexpr)
		return &Expression{
			ExpressionClause: &Expression_Tjexpr{
				Tjexpr: v,
			},
		}, err
	case *ast.Expression_Twexpr:
		v, err := templateWrapExprTo(e.Twexpr)
		return &Expression{
			ExpressionClause: &Expression_Twexpr{
				Twexpr: v,
			},
		}, err
	case *ast.Expression_Tcexpr:
		v, err := tupleConsExprTo(e.Tcexpr)
		return &Expression{
			ExpressionClause: &Expression_Tcexpr{
				Tcexpr: v,
			},
		}, err
	case *ast.Expression_Uoexpr:
		v, err := unaryOpExprTo(e.Uoexpr)
		return &Expression{
			ExpressionClause: &Expression_Uoexpr{
				Uoexpr: v,
			},
		}, err
	default:
	}
	return nil, fmt.Errorf("unknown expression type %T", expr)
}
