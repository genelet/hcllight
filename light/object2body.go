package light

import "strings"

func stringToTextValueExpr(s string) *Expression {
	if s == "" {
		return nil
	}

	return &Expression{
		ExpressionClause: &Expression_Texpr{
			Texpr: &TemplateExpr{
				Parts: []*Expression{stringToLiteralValueExpr(s)},
			},
		},
	}
}

func textValueExprToString(t *Expression) *string {
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
	return literalValueExprToString(parts[0])
}

func stringToLiteralValueExpr(s string) *Expression {
	s = strings.TrimSpace(s)
	s = strings.Trim(s, "\"")                // people sometimes double quote strings in JSON
	s = strings.ReplaceAll(s, "\n", "\\\\n") // newlines are not accepted in HCL
	s = strings.ReplaceAll(s, `\/`, `/`)     // people sometimes escape slashes in JSON

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

func literalValueExprToString(l *Expression) *string {
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

func keyValueExprToString(l *Expression) *string {
	if l == nil {
		return nil
	}

	switch l.ExpressionClause.(type) {
	case *Expression_Lvexpr:
		return literalValueExprToString(l)
	case *Expression_Texpr:
		return textValueExprToString(l)
	case *Expression_Ockexpr:
		k := l.GetOckexpr()
		if k.ForceNonLiteral {
		} else {
			switch k.Wrapped.ExpressionClause.(type) {
			case *Expression_Texpr:
				return textValueExprToString(k.Wrapped)
			case *Expression_Stexpr:
				return traversalToString(k.Wrapped)
			default:
			}
		}
	default:
	}
	return nil
}

func int64ToLiteralValueExpr(i int64) *Expression {
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

func literalValueExprToInt64(l *Expression) *int64 {
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

func float64ToLiteralValueExpr(f float64) *Expression {
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

func literalValueExprToFloat64(l *Expression) *float64 {
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
			y := *literalValueExprToFloat64(u.Val)
			y *= -1
			return &y
		}
		return literalValueExprToFloat64(u.Val)
	default:
	}

	return nil
}

func booleanToLiteralValueExpr(b bool) *Expression {
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

func literalValueExprToBoolean(l *Expression) *bool {
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

func stringMapToObjConsExpr(items map[string]string) *Expression {
	var args []*ObjectConsItem
	for k, v := range items {
		args = append(args, &ObjectConsItem{
			KeyExpr:   stringToTextValueExpr(k),
			ValueExpr: stringToTextValueExpr(v),
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

func objConsExprToStringMap(expr *Expression) map[string]string {
	if expr == nil {
		return nil
	}

	o := expr.GetOcexpr()
	if o == nil {
		return nil
	}

	items := make(map[string]string)
	for _, item := range o.Items {
		k := *keyValueExprToString(item.KeyExpr)
		v := *textValueExprToString(item.ValueExpr)
		items[k] = v
	}
	return items
}

func stringArrayToTupleConsEpr(items []string) *Expression {
	return &Expression{
		ExpressionClause: &Expression_Tcexpr{
			Tcexpr: &TupleConsExpr{
				Exprs: stringArrayToTextValueArray(items),
			},
		},
	}
}

func tupleConsExprToStringArray(expr *Expression) []string {
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
			return tupleConsExprToStringArray(x)
		default:
		}
	}

	return textValueArrayToStringArray(t.Exprs)
}

func stringArrayToTextValueArray(items []string) []*Expression {
	var exprs []*Expression
	for _, item := range items {
		exprs = append(exprs, stringToTextValueExpr(item))
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
			items = append(items, *textValueExprToString(expr))
		case *Expression_Lvexpr:
			items = append(items, *literalValueExprToString(expr))
		case *Expression_Stexpr:
			items = append(items, *traversalToString(expr))
		default:
		}
	}
	return items
}

func stringToTraversal(str string) *Expression {
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

func traversalToString(t *Expression) *string {
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

func (self *Body) ToObjectConsExpr() *ObjectConsExpr {
	ocExpr := &ObjectConsExpr{}
	for name, attr := range self.Attributes {
		ocExpr.Items = append(ocExpr.Items, &ObjectConsItem{
			KeyExpr:   stringToLiteralValueExpr(name),
			ValueExpr: attr.Expr,
		})
	}
	for _, block := range self.Blocks {
		ocExpr.Items = append(ocExpr.Items, &ObjectConsItem{
			KeyExpr: stringToLiteralValueExpr(block.Type),
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
		key := *keyValueExprToString(item.KeyExpr)
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
