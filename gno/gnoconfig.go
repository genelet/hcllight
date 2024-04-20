// Copyright (c) Greetingland LLC

package gno

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

	for name, resource := range self.GnoResources {
		blks, err := resource.ToBlocks(name)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}

	for name, data_source := range self.GnoDataSources {
		blks, err := data_source.ToBlocks(name)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}

	return &generated.Body{
		Blocks: blocks,
	}, nil
}

func exprReference(v *openapiv3.Reference) (*generated.Expression, error) {
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

func exprSchemaOrReference(v *openapiv3.SchemaOrReference) (*generated.Expression, error) {
	if x := v.GetReference(); x != nil {
		return exprReference(x)
	}
	return exprSchema(v.GetSchema())
}

func exprSchema(v *openapiv3.Schema) (*generated.Expression, error) {
	switch v.Type {
	case "string", "number", "integer", "boolean":
		fcexpr := &generated.FunctionCallExpr{Name: v.Type}
		if v.Format != "" {
			fcexpr.Args = append(fcexpr.Args, stringToLiteralValueExpr(v.Format))
		}
		return &generated.Expression{
			ExpressionClause: &generated.Expression_Fcexpr{
				Fcexpr: fcexpr,
			},
		}, nil
	case "array":
		tcexpr := &generated.TupleConsExpr{}
		for _, item := range v.Items.SchemaOrReference {
			expr, err := exprSchemaOrReference(item)
			if err != nil {
				return nil, err
			}
			tcexpr.Exprs = append(tcexpr.Exprs, expr)
		}
		return &generated.Expression{
			ExpressionClause: &generated.Expression_Tcexpr{
				Tcexpr: tcexpr,
			},
		}, nil
	default:
	}

	if v.Properties != nil {
		ocexpr := &generated.ObjectConsExpr{}
		var items []*generated.ObjectConsItem
		for _, item := range v.Properties.AdditionalProperties {
			expr, err := exprSchemaOrReference(item.Value)
			if err != nil {
				return nil, err
			}
			items = append(items, &generated.ObjectConsItem{
				KeyExpr:   stringToLiteralValueExpr(item.Name),
				ValueExpr: expr,
			})
		}
		ocexpr.Items = items
		return &generated.Expression{
			ExpressionClause: &generated.Expression_Ocexpr{
				Ocexpr: ocexpr,
			},
		}, nil
	}

	if v.AdditionalProperties != nil {
		if x := v.AdditionalProperties.GetSchemaOrReference(); x != nil {
			return exprSchemaOrReference(x)
		}
	}

	return nil, nil
}

// parameter always return body, different bodies could be added
func exprParameter(p *openapiv3.Parameter) (*generated.Expression, error) {
	if p.GetSchema() != nil {
		return exprSchemaOrReference(p.GetSchema())
	}

	// p.Content != nil
	schemaOrReference := schemaMediaTypes(p.Content)
	return exprSchemaOrReference(schemaOrReference)
}

func nameExprParameterOrReference(v *openapiv3.ParameterOrReference) (string, *generated.Expression, error) {
	if x := v.GetReference(); x != nil {
		expr, err := exprReference(x)
		return "", expr, err
	}

	expr, err := exprParameter(v.GetParameter())
	return v.GetParameter().Name, expr, err
}

func exprRequestBodyOrReference(v *openapiv3.RequestBodyOrReference) (*generated.Expression, error) {
	if x := v.GetReference(); x != nil {
		return exprReference(x)
	}
	return exprRequestBody(v.GetRequestBody())
}

func exprRequestBody(v *openapiv3.RequestBody) (*generated.Expression, error) {
	schemaOrReference := schemaMediaTypes(v.Content)
	return exprSchemaOrReference(schemaOrReference)
}
