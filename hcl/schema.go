package hcl

import (
	"github.com/genelet/hcllight/light"
)

/*
	func (s *SchemaOrReference) toHCL() (*light.Body, error) {
		switch s.Oneof.(type) {
		case *SchemaOrReference_Schema:
			return s.GetSchema().toHCL()
		case *SchemaOrReference_Reference:
			return s.GetReference().toHCL()
		default: // we ignore all other types, meaning we have to assign type Schema when parsing Components.Schemas
		}

		return nil, nil
	}
*/
func (self *SchemaOrReference) toExpression() (*light.Expression, error) {
	if self == nil {
		return nil, nil
	}

	switch self.Oneof.(type) {
	case *SchemaOrReference_Schema:
		bdy, err := self.GetSchema().toHCL()
		if err != nil {
			return nil, err
		}
		return &light.Expression{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: bdy.ToObjectConsExpr(),
			},
		}, nil
	case *SchemaOrReference_Reference:
		return self.GetReference().toExpression()
	default:
	}

	var expr *light.FunctionCallExpr
	var err error
	if x := self.GetBoolean(); x != nil {
		expr, err = commonToFcexpr(x.GetCommon())
	} else if x := self.GetNumber(); x != nil {
		if expr, err = commonToFcexpr(x.GetCommon()); err == nil {
			err = schemaNumberToFcexpr(x.GetNumber(), expr)
		}
	} else if x := self.GetString_(); x != nil {
		if expr, err = commonToFcexpr(x.GetCommon()); err == nil {
			err = schemaStringToFcexpr(x.GetString_(), expr)
		}
	} else if x := self.GetArray(); x != nil {
		if expr, err = commonToFcexpr(x.GetCommon()); err == nil {
			err = schemaArrayToFcexpr(x.GetArray(), expr)
		}
	} else if x := self.GetObject(); x != nil {
		if expr, err = commonToFcexpr(x.GetCommon()); err == nil {
			err = schemaObjectToFcexpr(x.GetObject(), expr)
		}
	} else if x := self.GetMap(); x != nil {
		if expr, err = commonToFcexpr(x.GetCommon()); err == nil {
			err = schemaMapToFcexpr(x.GetMap(), expr)
		}
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: expr,
		},
	}, err
}

func ExpressionToSchemaOrReference(self *light.Expression) (*SchemaOrReference, error) {
	if self == nil {
		return nil, nil
	}

	switch self.ExpressionClause.(type) {
	case *light.Expression_Ocexpr:
		bdy := self.GetOcexpr().ToBody()
		s, err := schemaFullFromHCL(bdy)
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Schema{
				Schema: s,
			},
		}, err
	default:
	}

	ref, err := expressionToReference(self)
	if err != nil {
		return nil, err
	}
	if ref != nil {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Reference{
				Reference: ref,
			},
		}, nil
	}

	expr := self.GetFcexpr()
	common, err := fcexprToCommon(expr)
	if err != nil {
		return nil, err
	}
	number, err := fcexprToSchemaNumber(expr)
	if err != nil {
		return nil, err
	}
	string_, err := fcexprToSchemaString(expr)
	if err != nil {
		return nil, err
	}
	array, err := fcexprToSchemaArray(expr)
	if err != nil {
		return nil, err
	}
	object, err := fcexprToSchemaObject(expr)
	if err != nil {
		return nil, err
	}
	m, err := fcexprToSchemaMap(expr)
	if err != nil {
		return nil, err
	}

	if number != nil {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Number{
				Number: &OASNumber{
					Common: common,
					Number: number,
				},
			},
		}, nil
	} else if string_ != nil {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_String_{
				String_: &OASString{
					Common:  common,
					String_: string_,
				},
			},
		}, nil
	} else if array != nil {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Array{
				Array: &OASArray{
					Common: common,
					Array:  array,
				},
			},
		}, nil
	} else if object != nil {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Object{
				Object: &OASObject{
					Common: common,
					Object: object,
				},
			},
		}, nil
	} else if m != nil {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Map{
				Map: &OASMap{
					Common: common,
					Map:    m,
				},
			},
		}, nil
	}

	return &SchemaOrReference{
		Oneof: &SchemaOrReference_Boolean{
			Boolean: &OASBoolean{
				Common: common,
			},
		},
	}, nil
}

// use mapSchemaOrReferenceToBody instead
func mapSchemaOrReferenceToObjectConsExpr(m map[string]*SchemaOrReference) (*light.ObjectConsExpr, error) {
	if m == nil {
		return nil, nil
	}
	var exprs []*light.ObjectConsItem
	for k, v := range m {
		expr, err := v.toExpression()
		if err != nil {
			return nil, err
		}
		exprs = append(exprs, &light.ObjectConsItem{
			KeyExpr:   stringToLiteralValueExpr(k),
			ValueExpr: expr,
		})
	}
	return &light.ObjectConsExpr{
		Items: exprs,
	}, nil
}

func objectConsExprToMapSchemaOrReference(o *light.ObjectConsExpr) (map[string]*SchemaOrReference, error) {
	if o == nil {
		return nil, nil
	}
	m := make(map[string]*SchemaOrReference)
	for _, item := range o.Items {
		key := *literalValueExprToString(item.KeyExpr)
		value, err := ExpressionToSchemaOrReference(item.ValueExpr)
		if err != nil {
			return nil, err
		}
		m[key] = value
	}
	return m, nil
}

func mapSchemaOrReferenceToBody(m map[string]*SchemaOrReference) (*light.Body, error) {
	if m == nil {
		return nil, nil
	}

	var body *light.Body
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)

	for k, v := range m {
		switch v.Oneof.(type) {
		case *SchemaOrReference_Schema:
			bdy, err := v.GetSchema().toHCL()
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type: k,
				Bdy:  bdy,
			})
		default:
			expr, err := v.toExpression()
			if err != nil {
				return nil, err
			}
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: expr,
			}
		}
	}

	if len(attrs) > 0 || len(blocks) > 0 {
		body = &light.Body{}
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func bodyToMapSchemaOrReference(b *light.Body) (map[string]*SchemaOrReference, error) {
	if b == nil {
		return nil, nil
	}

	m := make(map[string]*SchemaOrReference)
	for k, v := range b.Attributes {
		value, err := ExpressionToSchemaOrReference(v.Expr)
		if err != nil {
			return nil, err
		}
		m[k] = value
	}

	for _, block := range b.Blocks {
		s, err := schemaFullFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		m[block.Type] = &SchemaOrReference{
			Oneof: &SchemaOrReference_Schema{
				Schema: s,
			},
		}
	}
	return m, nil
}
