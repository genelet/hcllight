package light

import (
	"regexp"
	"strings"
)

func StringToTextValueExpr(s string) *Expression {
	if s == "" {
		return nil
	}

	return &Expression{
		ExpressionClause: &Expression_Texpr{
			Texpr: &TemplateExpr{
				Parts: []*Expression{StringToLiteralValueExpr(s)},
			},
		},
	}
}

func TextValueExprToString(t *Expression) *string {
	if t == nil {
		return nil
	}
	if t.GetTexpr() == nil {
		return nil
	}
	parts := t.GetTexpr().Parts
	if len(parts) == 0 {
		return nil
	}
	if parts[0].GetLvexpr() == nil {
		return nil
	}
	return LiteralValueExprToString(parts[0])
}

func StringToLiteralValueExpr(s string) *Expression {
	s = strings.TrimSpace(s)
	s = strings.Trim(s, "\"")              // people sometimes double quote strings in JSON
	s = strings.ReplaceAll(s, "\n", "\\n") // newlines are not accepted in HCL
	s = strings.ReplaceAll(s, `\/`, `/`)   // people sometimes escape slashes in JSON
	s = strings.ReplaceAll(s, `\`, `\\`)   // people sometimes escape backslashes in JSON

	return &Expression{
		ExpressionClause: &Expression_Lvexpr{
			Lvexpr: &LiteralValueExpr{
				Val: &CtyValue{
					CtyValueClause: &CtyValue_StringValue{
						StringValue: s,
					},
				},
			},
		},
	}
}

func LiteralValueExprToString(l *Expression) *string {
	if l == nil {
		return nil
	}
	if l.GetLvexpr() == nil {
		return nil
	}
	if l.GetLvexpr().GetVal() == nil {
		return nil
	}
	x := l.GetLvexpr().GetVal().GetStringValue()
	return &x
}

func LiteralValueExprToInterface(l *Expression) interface{} {
	if l == nil {
		return nil
	}
	if l.GetLvexpr() == nil {
		return nil
	}
	val := l.GetLvexpr().GetVal()
	if val == nil {
		return nil
	}
	switch val.CtyValueClause.(type) {
	case *CtyValue_BoolValue:
		return val.GetBoolValue()
	case *CtyValue_NumberValue:
		return val.GetNumberValue()
	case *CtyValue_StringValue:
		return val.GetStringValue()
	default:
	}
	return nil
}

func KeyValueExprToString(l *Expression) *string {
	if l == nil {
		return nil
	}

	switch l.ExpressionClause.(type) {
	case *Expression_Lvexpr:
		return LiteralValueExprToString(l)
	case *Expression_Texpr:
		return TextValueExprToString(l)
	case *Expression_Ockexpr:
		k := l.GetOckexpr()
		if k.ForceNonLiteral {
		} else {
			switch k.Wrapped.ExpressionClause.(type) {
			case *Expression_Texpr:
				return TextValueExprToString(k.Wrapped)
			case *Expression_Stexpr:
				return TraversalToString(k.Wrapped)
			default:
			}
		}
	default:
	}
	return nil
}

func Int64ToLiteralValueExpr(i int64) *Expression {
	return &Expression{
		ExpressionClause: &Expression_Lvexpr{
			Lvexpr: &LiteralValueExpr{
				Val: &CtyValue{
					CtyValueClause: &CtyValue_NumberValue{
						NumberValue: float64(i),
					},
				},
			},
		},
	}
}

func LiteralValueExprToInt64(l *Expression) *int64 {
	if l == nil {
		return nil
	}
	if l.GetLvexpr() == nil {
		return nil
	}
	if l.GetLvexpr().GetVal() == nil {
		return nil
	}
	x := int64(l.GetLvexpr().GetVal().GetNumberValue())
	return &x
}

func Float64ToLiteralValueExpr(f float64) *Expression {
	return &Expression{
		ExpressionClause: &Expression_Lvexpr{
			Lvexpr: &LiteralValueExpr{
				Val: &CtyValue{
					CtyValueClause: &CtyValue_NumberValue{
						NumberValue: f,
					},
				},
			},
		},
	}
}

func LiteralValueExprToFloat64(l *Expression) *float64 {
	if l == nil {
		return nil
	}

	switch l.ExpressionClause.(type) {
	case *Expression_Lvexpr:
		if l.GetLvexpr() == nil {
			return nil
		}
		if l.GetLvexpr().GetVal() == nil {
			return nil
		}
		x := l.GetLvexpr().GetVal().GetNumberValue()
		return &x
	case *Expression_Uoexpr:
		u := l.GetUoexpr()
		if u.Op.Sign == TokenType_Minus {
			y := *LiteralValueExprToFloat64(u.Val)
			y *= -1
			return &y
		}
		return LiteralValueExprToFloat64(u.Val)
	default:
	}

	return nil
}

func BooleanToLiteralValueExpr(b bool) *Expression {
	return &Expression{
		ExpressionClause: &Expression_Lvexpr{
			Lvexpr: &LiteralValueExpr{
				Val: &CtyValue{
					CtyValueClause: &CtyValue_BoolValue{
						BoolValue: b,
					},
				},
			},
		},
	}
}

func LiteralValueExprToBoolean(l *Expression) *bool {
	if l == nil {
		return nil
	}
	if l.GetLvexpr() == nil {
		return nil
	}
	if l.GetLvexpr().GetVal() == nil {
		return nil
	}
	x := l.GetLvexpr().GetVal().GetBoolValue()
	return &x
}

func StringMapToObjConsExpr(items map[string]string) *Expression {
	var args []*ObjectConsItem
	for k, v := range items {
		args = append(args, &ObjectConsItem{
			KeyExpr:   StringToTextValueExpr(k),
			ValueExpr: StringToTextValueExpr(v),
		})
	}

	return &Expression{
		ExpressionClause: &Expression_Ocexpr{
			Ocexpr: &ObjectConsExpr{
				Items: args,
			},
		},
	}
}

func ObjConsExprToStringMap(expr *Expression) map[string]string {
	if expr == nil {
		return nil
	}

	o := expr.GetOcexpr()
	if o == nil {
		return nil
	}

	items := make(map[string]string)
	for _, item := range o.Items {
		k := *KeyValueExprToString(item.KeyExpr)
		v := *TextValueExprToString(item.ValueExpr)
		items[k] = v
	}
	return items
}

func StringArrayToTupleConsEpr(items []string) *Expression {
	return &Expression{
		ExpressionClause: &Expression_Tcexpr{
			Tcexpr: &TupleConsExpr{
				Exprs: stringArrayToTextValueArray(items),
			},
		},
	}
}

func TupleConsExprToStringArray(expr *Expression) []string {
	if expr == nil {
		return nil
	}

	t := expr.GetTcexpr()
	if t == nil {
		return nil
	}
	if len(t.Exprs) == 1 {
		x := t.Exprs[0]
		switch x.ExpressionClause.(type) {
		case *Expression_Tcexpr:
			return TupleConsExprToStringArray(x)
		default:
		}
	}

	return textValueArrayToStringArray(t.Exprs)
}

func stringArrayToTextValueArray(items []string) []*Expression {
	var exprs []*Expression
	for _, item := range items {
		exprs = append(exprs, StringToTextValueExpr(item))
	}
	return exprs
}

func textValueArrayToStringArray(args []*Expression) []string {
	if args == nil {
		return nil
	}
	var items []string
	for _, expr := range args {
		switch expr.ExpressionClause.(type) {
		case *Expression_Texpr:
			items = append(items, *TextValueExprToString(expr))
		case *Expression_Lvexpr:
			items = append(items, *LiteralValueExprToString(expr))
		case *Expression_Stexpr:
			items = append(items, *TraversalToString(expr))
		default:
		}
	}
	return items
}

func StringToTraversal(str string) *Expression {
	parts := strings.SplitN(str, "/", -1)
	args := []*Traverser{
		{TraverserClause: &Traverser_TRoot{
			TRoot: &TraverseRoot{Name: parts[0]},
		}},
	}
	if len(parts) > 1 {
		for _, part := range parts[1:] {
			args = append(args, &Traverser{
				TraverserClause: &Traverser_TAttr{
					TAttr: &TraverseAttr{Name: part},
				},
			})
		}
	}
	return &Expression{
		ExpressionClause: &Expression_Stexpr{
			Stexpr: &ScopeTraversalExpr{
				Traversal: args,
			},
		},
	}
}

func TraversalToString(t *Expression) *string {
	if t == nil {
		return nil
	}
	if t.GetStexpr() == nil {
		return nil
	}
	traversal := t.GetStexpr().Traversal
	if len(traversal) == 0 {
		return nil
	}
	var parts []string
	for _, part := range traversal {
		switch part.GetTraverserClause().(type) {
		case *Traverser_TRoot:
			parts = append(parts, part.GetTRoot().Name)
		case *Traverser_TAttr:
			parts = append(parts, part.GetTAttr().Name)
		}
	}
	x := strings.Join(parts, "/")
	return &x
}

func reliableKeyFromString(s string, quote ...bool) *Expression {
	if len(quote) > 0 && quote[0] {
		return StringToTextValueExpr(s)
	}
	if regexp.MustCompile(`^[a-zA-Z0-9_]*$`).MatchString(s) {
		return StringToLiteralValueExpr(s)
	}
	return StringToTextValueExpr(s)
}

func (self *Body) ToObjectConsExpr(quote ...bool) *ObjectConsExpr {
	ocExpr := &ObjectConsExpr{}
	for name, attr := range self.Attributes {
		ocExpr.Items = append(ocExpr.Items, &ObjectConsItem{
			KeyExpr:   reliableKeyFromString(name, quote...),
			ValueExpr: attr.Expr,
		})
	}
	for _, block := range self.Blocks {
		ocExpr.Items = append(ocExpr.Items, &ObjectConsItem{
			KeyExpr: reliableKeyFromString(block.Type, quote...),
			ValueExpr: &Expression{
				ExpressionClause: &Expression_Ocexpr{
					Ocexpr: block.Bdy.ToObjectConsExpr(),
				},
			},
		})
	}
	return ocExpr
}

func (self *ObjectConsExpr) ToBody() *Body {
	body := &Body{}
	for _, item := range self.Items {
		key := *KeyValueExprToString(item.KeyExpr)
		if x := item.ValueExpr.GetOcexpr(); x != nil {
			body.Blocks = append(body.Blocks, &Block{
				Type: key,
				Bdy:  x.ToBody(),
			})
		} else {
			if body.Attributes == nil {
				body.Attributes = make(map[string]*Attribute)
			}
			body.Attributes[key] = &Attribute{
				Name: key,
				Expr: item.ValueExpr,
			}
		}
	}
	return body
}
