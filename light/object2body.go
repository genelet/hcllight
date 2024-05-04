package light

func stringToLiteralValueExpr(s string) *Expression {
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
		key := item.KeyExpr.GetLvexpr().GetVal().GetStringValue()
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
