// Copyright (c) Greetingland LLC

package config

import (
	"github.com/genelet/hcllight/generated"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

type GnoConfig struct {
	GnoProvider    `hcl:"provider,block"`
	Schemas        map[string]*openapiv3.SchemaOrReference      `hcl:"schemas,block"`
	Parameters     map[string]*openapiv3.ParameterOrReference   `hcl:"parameters,block"`
	RequestBodies  map[string]*openapiv3.RequestBodyOrReference `hcl:"request_bodies,block"`
	GnoResources   map[string]*GnoResource                      `hcl:"resources,block"`
	GnoDataSources map[string]*GnoDataSource                    `hcl:"data_sources,block"`
}

func (self *GnoConfig) BuildHCL() (*generated.Body, error) {
	var blocks []*generated.Block

	provider, err := self.buildProvider()
	if err != nil {
		return nil, err
	}
	blocks = append(blocks, provider)

	schemas, err := self.blockSchemas()
	if err != nil {
		return nil, err
	}
	blocks = append(blocks, schemas)

	parameters, err := self.blockParameters()
	if err != nil {
		return nil, err
	}
	blocks = append(blocks, parameters)

	reqs, err := self.blockRequestBodies()
	if err != nil {
		return nil, err
	}
	blocks = append(blocks, reqs)

	resources, err := self.blockResources()
	if err != nil {
		return nil, err
	}
	blocks = append(blocks, resources)

	dataSources, err := self.blockDataSources()
	if err != nil {
		return nil, err
	}
	blocks = append(blocks, dataSources)

	return &generated.Body{
		Blocks: blocks,
	}, nil
}

func (self *GnoConfig) exprReference(v *openapiv3.Reference) (*generated.Expression, error) {
	traversal, err := refToScopeTraversalExpr(v.GetXRef())
	if err != nil {
		return nil, err
	}
	return &generated.Expression{
		ExpressionClause: &generated.Expression_Stexpr{
			Stexpr: traversal,
		},
	}, nil
}

func (self *GnoConfig) exprBodySchemaOrReference(v *openapiv3.SchemaOrReference) (*generated.Expression, *generated.Body, error) {
	if x := v.GetReference(); x != nil {
		expr, err := self.exprReference(x)
		return expr, nil, err
	}
	return self.exprBodySchema(v.GetSchema())
}

func (self *GnoConfig) exprBodySchema(v *openapiv3.Schema) (*generated.Expression, *generated.Body, error) {
	fcexpr := &generated.FunctionCallExpr{Name: v.Type}
	var bdy *generated.Body
	var blocks []*generated.Block

	switch v.Type {
	case "string", "number", "integer", "boolean":
		if v.Format != "" {
			fcexpr.Args = append(fcexpr.Args, stringToLiteralValueExpr(v.Format))
		}
	case "array":
		for _, item := range v.Items.SchemaOrReference {
			expr, _, err := self.exprBodySchemaOrReference(item)
			if err != nil {
				return nil, nil, err
			}
			fcexpr.Args = append(fcexpr.Args, expr)
		}
	default:
		if v.Properties != nil {
			var items []*generated.ObjectConsItem
			attrs := make(map[string]*generated.Attribute)
			for _, item := range v.Properties.AdditionalProperties {
				expr, body, err := self.exprBodySchemaOrReference(item.Value)
				if err != nil {
					return nil, nil, err
				}
				items = append(items, &generated.ObjectConsItem{
					KeyExpr:   stringToLiteralValueExpr(item.Name),
					ValueExpr: expr,
				})
				attrs[item.Name] = &generated.Attribute{
					Name: item.Name,
					Expr: expr,
				}
				if body != nil {
					blocks = append(blocks, &generated.Block{
						Type: item.Name,
						Bdy:  body,
					})
				}
			}

			fcexpr.Args = append(fcexpr.Args, &generated.Expression{
				ExpressionClause: &generated.Expression_Ocexpr{
					Ocexpr: &generated.ObjectConsExpr{
						Items: items,
					},
				},
			})

			bdy = &generated.Body{
				Attributes: attrs,
				Blocks:     blocks,
			}
		} else if v.AdditionalProperties != nil {
			if x := v.AdditionalProperties.GetSchemaOrReference(); x != nil {
				expr, _, err := self.exprBodySchemaOrReference(x)
				if err != nil {
					return nil, nil, err
				}
				fcexpr.Args = append(fcexpr.Args, expr)
			}
		}
	}

	return &generated.Expression{
		ExpressionClause: &generated.Expression_Fcexpr{
			Fcexpr: fcexpr,
		},
	}, bdy, nil
}

// parameter always return body, different bodies could be added
func (self *GnoConfig) exprBodyParameter(p *openapiv3.Parameter) (*generated.Expression, *generated.Body, error) {
	if p.GetSchema() != nil {
		return self.exprBodySchemaOrReference(p.GetSchema())
	}

	// p.Content != nil
	schemaOrReference := schemaMediaTypes(p.Content)
	return self.exprBodySchemaOrReference(schemaOrReference)
}

func (self *GnoConfig) nameExprBodyParameterOrReference(v *openapiv3.ParameterOrReference) (string, *generated.Expression, *generated.Body, error) {
	if x := v.GetReference(); x != nil {
		expr, err := self.exprReference(x)
		return "", expr, nil, err
	}

	expr, body, err := self.exprBodyParameter(v.GetParameter())
	return v.GetParameter().Name, expr, body, err
}

func (self *GnoConfig) exprBodyArrayParameterOrReference(v []*openapiv3.ParameterOrReference) (*generated.Expression, *generated.Body, error) {
	fcexpr := &generated.FunctionCallExpr{Name: "array"}
	var items []*generated.ObjectConsItem
	var blocks []*generated.Block
	var attrs map[string]*generated.Attribute

	for _, item := range v {
		name, expr, body, err := self.nameExprBodyParameterOrReference(item)
		if err != nil {
			return nil, nil, err
		}
		if name == "" {
			name = "XREF"
			attr := &generated.Attribute{
				Name: name,
				Expr: expr,
			}
			if attrs == nil {
				attrs = make(map[string]*generated.Attribute)
			}
			attrs[name] = attr
		} else {
			if body == nil {
				if attrs == nil {
					attrs = make(map[string]*generated.Attribute)
				}
				attrs[name] = &generated.Attribute{
					Name: name,
					Expr: expr,
				}
			} else {
				if blocks == nil {
					blocks = make([]*generated.Block, 0, len(v))
				}
				blocks = append(blocks, &generated.Block{
					Type: name,
					Bdy:  body,
				})
			}
		}
		items = append(items, &generated.ObjectConsItem{
			KeyExpr:   stringToLiteralValueExpr(name),
			ValueExpr: expr,
		})
	}
	fcexpr.Args = append(fcexpr.Args, &generated.Expression{
		ExpressionClause: &generated.Expression_Ocexpr{
			Ocexpr: &generated.ObjectConsExpr{
				Items: items,
			},
		},
	})

	return &generated.Expression{
			ExpressionClause: &generated.Expression_Fcexpr{
				Fcexpr: fcexpr,
			},
		}, &generated.Body{
			Attributes: attrs,
			Blocks:     blocks,
		}, nil
}

func (self *GnoConfig) exprBodyRequestBodyOrReference(v *openapiv3.RequestBodyOrReference) (*generated.Expression, *generated.Body, error) {
	if x := v.GetReference(); x != nil {
		expr, err := self.exprReference(x)
		return expr, nil, err
	}
	return self.exprBodyRequestBody(v.GetRequestBody())
}

func (self *GnoConfig) exprBodyRequestBody(v *openapiv3.RequestBody) (*generated.Expression, *generated.Body, error) {
	schemaOrReference := schemaMediaTypes(v.Content)
	return self.exprBodySchemaOrReference(schemaOrReference)
}

func (self *GnoConfig) exprOperation(v *openapiv3.Operation) (*generated.Expression, *generated.Body, error) {
	if v.Parameters != nil {
		return self.exprBodyArrayParameterOrReference(v.Parameters)
	}

	return self.exprBodyRequestBodyOrReference(v.RequestBody)
}
