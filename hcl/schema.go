package hcl

import (
	"github.com/genelet/hcllight/light"
	//"github.com/k0kubun/pp/v3"
)

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
	switch self.Oneof.(type) {
	case *SchemaOrReference_OneOf:
		x := self.GetOneOf()
		tcexpr, err := arrayToTupleConsExpr(x.Items)
		if err != nil {
			return nil, err
		}
		expr = &light.FunctionCallExpr{
			Name: "oneOf",
			Args: tcexpr.Exprs,
		}
	case *SchemaOrReference_AllOf:
		x := self.GetAllOf()
		tcexpr, err := arrayToTupleConsExpr(x.Items)
		if err != nil {
			return nil, err
		}
		expr = &light.FunctionCallExpr{
			Name: "allOf",
			Args: tcexpr.Exprs,
		}
	case *SchemaOrReference_AnyOf:
		x := self.GetAnyOf()
		tcexpr, err := arrayToTupleConsExpr(x.Items)
		if err != nil {
			return nil, err
		}
		expr = &light.FunctionCallExpr{
			Name: "anyOf",
			Args: tcexpr.Exprs,
		}
	case *SchemaOrReference_Boolean:
		x := self.GetBoolean()
		expr, err = commonToFcexpr(x.GetCommon())
	case *SchemaOrReference_Number:
		x := self.GetNumber()
		if expr, err = commonToFcexpr(x.GetCommon()); err == nil {
			err = schemaNumberToFcexpr(x.GetNumber(), expr)
		}
	case *SchemaOrReference_String_:
		x := self.GetString_()
		if expr, err = commonToFcexpr(x.GetCommon()); err == nil {
			err = schemaStringToFcexpr(x.GetString_(), expr)
		}
	case *SchemaOrReference_Array:
		x := self.GetArray()
		if expr, err = commonToFcexpr(x.GetCommon()); err == nil {
			err = schemaArrayToFcexpr(x.GetArray(), expr)
		}
	case *SchemaOrReference_Object:
		x := self.GetObject()
		if expr, err = commonToFcexpr(x.GetCommon()); err == nil {
			err = schemaObjectToFcexpr(x.GetObject(), expr)
		}
	case *SchemaOrReference_Map:
		x := self.GetMap()
		if expr, err = commonToFcexpr(x.GetCommon()); err == nil {
			err = schemaMapToFcexpr(x.GetMap(), expr)
		}
	default:
	}

	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: expr,
		},
	}, err
}

func expressionToSchemaOrReference(self *light.Expression) (*SchemaOrReference, error) {
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
	switch expr.Name {
	case "oneOf":
		items, err := tupleConsExprToArray(&light.TupleConsExpr{
			Exprs: expr.Args,
		})
		if err != nil {
			return nil, err
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_OneOf{
				OneOf: &SchemaOneOf{
					Items: items,
				},
			},
		}, nil
	case "allOf":
		arr, err := tupleConsExprToArray(&light.TupleConsExpr{
			Exprs: expr.Args,
		})
		if err != nil {
			return nil, err
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_AllOf{
				AllOf: &SchemaAllOf{
					Items: arr,
				},
			},
		}, nil
	case "anyOf":
		arr, err := tupleConsExprToArray(&light.TupleConsExpr{
			Exprs: expr.Args,
		})
		if err != nil {
			return nil, err
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_AnyOf{
				AnyOf: &SchemaAnyOf{
					Items: arr,
				},
			},
		}, nil
	default:
	}

	common, err := fcexprToCommon(expr)
	if err != nil {
		return nil, err
	}

	switch common.Type {
	case "boolean":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Boolean{
				Boolean: &OASBoolean{
					Common: common,
				},
			},
		}, nil
	case "number":
		number, err := fcexprToSchemaNumber(expr)
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Number{
				Number: &OASNumber{
					Common: common,
					Number: number,
				},
			},
		}, err
	case "string":
		string_, err := fcexprToSchemaString(expr)
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_String_{
				String_: &OASString{
					Common:  common,
					String_: string_,
				},
			},
		}, err
	case "array":
		array, err := fcexprToSchemaArray(expr)
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Array{
				Array: &OASArray{
					Common: common,
					Array:  array,
				},
			},
		}, err
	case "object":
		object, err := fcexprToSchemaObject(expr)
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Object{
				Object: &OASObject{
					Common: common,
					Object: object,
				},
			},
		}, err
	case "map":
		m, err := fcexprToSchemaMap(expr)
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Map{
				Map: &OASMap{
					Common: common,
					Map:    m,
				},
			},
		}, err
	default:
	}

	return nil, nil
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
		key := *keyValueExprToString(item.KeyExpr)
		value, err := expressionToSchemaOrReference(item.ValueExpr)
		if err != nil {
			return nil, err
		}
		m[key] = value
	}
	return m, nil
}

func schemaOrReferenceMapToBlocks(m map[string]*SchemaOrReference, names ...string) ([]*light.Block, error) {
	body, err := schemaOrReferenceMapToBody(m)
	if err != nil || body == nil {
		return nil, err
	}
	return bodyToBlocks(body, names...), nil
}

func schemaOrReferenceMapToBody(m map[string]*SchemaOrReference, force ...bool) (*light.Body, error) {
	if m == nil {
		return nil, nil
	}

	var body *light.Body
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)

	for k, v := range m {
		if v == nil {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: nil,
			}
			continue
		}
		switch v.Oneof.(type) {
		case *SchemaOrReference_Schema:
			bdy, err := v.GetSchema().toHCL()
			if err != nil {
				return nil, err
			}
			if force != nil && force[0] {
				attrs[k] = &light.Attribute{
					Name: k,
					Expr: &light.Expression{
						ExpressionClause: &light.Expression_Ocexpr{
							Ocexpr: bdy.ToObjectConsExpr(),
						},
					},
				}
			} else {
				blocks = append(blocks, &light.Block{
					Type: k,
					Bdy:  bdy,
				})
			}
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

func bodyToSchemaOrReferenceMap(b *light.Body) (map[string]*SchemaOrReference, error) {
	if b == nil {
		return nil, nil
	}

	m := make(map[string]*SchemaOrReference)
	for k, v := range b.Attributes {
		value, err := expressionToSchemaOrReference(v.Expr)
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

func blocksToSchemaOrReferenceMap(blocks []*light.Block, names ...string) (map[string]*SchemaOrReference, error) {
	body := blocksToBody(blocks, names...)
	if body == nil {
		return nil, nil
	}

	return bodyToSchemaOrReferenceMap(body)
}
