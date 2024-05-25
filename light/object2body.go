package light

import "strings"

func stringToLiteralValueExpr(s string) *Expression {
	s = strings.ReplaceAll(s, "\n", "\\\\n")
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

func keyValueExprToString(l *Expression) *string {
	if l == nil {
		return nil
	}

	switch l.ExpressionClause.(type) {
	case *Expression_Lvexpr:
		str := l.GetLvexpr().GetVal().GetStringValue()
		return &str
	case *Expression_Ockexpr:
		k := l.GetOckexpr()
		if k.ForceNonLiteral {
		} else {
			switch k.Wrapped.ExpressionClause.(type) {
			case *Expression_Stexpr:
				return traversalToString(k.Wrapped)
			default:
			}
		}
	default:
	}
	return nil
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
