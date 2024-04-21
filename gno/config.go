// Copyright (c) Greetingland LLC

package gno

import (
	"fmt"
	"net/url"
	"strings"

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

	provider, err := self.GnoProvider.buildProvider()
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

func (self *GnoConfig) blockSchemas() (*generated.Block, error) {
	var attributes map[string]*generated.Attribute
	var blocks []*generated.Block
	for name, schema := range self.Schemas {
		expr, err := exprSchemaOrReference(schema)
		if err != nil {
			return nil, err
		}

		if attributes == nil {
			attributes = make(map[string]*generated.Attribute)
		}
		attributes[name] = &generated.Attribute{
			Name: name,
			Expr: expr,
		}

	}

	return &generated.Block{
		Type:   "variables",
		Labels: []string{"schemas"},
		Bdy: &generated.Body{
			Attributes: attributes,
			Blocks:     blocks,
		},
	}, nil
}

func (self *GnoConfig) blockParameters() (*generated.Block, error) {
	//	var attributes map[string]*generated.Attribute
	var blocks []*generated.Block
	for name, parameter := range self.Parameters {
		str, expr, err := nameExprParameterOrReference(parameter)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &generated.Block{
			Type: name,
			Bdy: &generated.Body{
				Attributes: map[string]*generated.Attribute{
					name: {
						Name: str,
						Expr: expr,
					},
				},
			},
		})
	}

	return &generated.Block{
		Type:   "variables",
		Labels: []string{"parameters"},
		Bdy: &generated.Body{
			Blocks: blocks,
		},
	}, nil
}

func (self *GnoConfig) blockRequestBodies() (*generated.Block, error) {
	var attributes map[string]*generated.Attribute
	var blocks []*generated.Block
	for name, requestBody := range self.RequestBodies {
		expr, err := exprRequestBodyOrReference(requestBody)
		if err != nil {
			return nil, err
		}
		if attributes == nil {
			attributes = make(map[string]*generated.Attribute)
		}
		attributes[name] = &generated.Attribute{
			Name: name,
			Expr: expr,
		}
	}

	return &generated.Block{
		Type:   "variables",
		Labels: []string{"request_bodies"},
		Bdy: &generated.Body{
			Attributes: attributes,
			Blocks:     blocks,
		},
	}, nil
}

func exprSchemaOrReference(v *openapiv3.SchemaOrReference) (*generated.Expression, error) {
	if x := v.GetReference(); x != nil {
		return exprReference(x)
	}
	return exprSchema(v.GetSchema())
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

func nameExprParameterOrReference(v *openapiv3.ParameterOrReference) (string, *generated.Expression, error) {
	if x := v.GetReference(); x != nil {
		expr, err := exprReference(x)
		return "", expr, err
	}

	expr, err := exprParameter(v.GetParameter())
	return v.GetParameter().Name, expr, err
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

func (c *Config) NewGnoConfig(doc *openapiv3.Document) (*GnoConfig, error) {
	gc := &GnoConfig{}

	gp, err := c.Provider.NewGnoProvider(doc)
	if err != nil {
		return nil, fmt.Errorf("error building provider: %w", err)
	}
	gc.GnoProvider = *gp

	var grs map[string]*GnoResource
	for name, resource := range c.Resources {
		gr, err := resource.NewGnoResource(doc)
		if err != nil {
			return nil, fmt.Errorf("error building resource '%s': %w", name, err)
		}
		if grs == nil {
			grs = make(map[string]*GnoResource)
		}
		grs[name] = gr
	}
	if grs != nil {
		gc.GnoResources = grs

	}

	var gdss map[string]*GnoDataSource
	for name, dataSource := range c.DataSources {
		gds, err := dataSource.NewGnoDataSource(doc)
		if err != nil {
			return nil, fmt.Errorf("error building data source '%s': %w", name, err)
		}
		if gdss == nil {
			gdss = make(map[string]*GnoDataSource)
		}
		gdss[name] = gds
	}
	if gdss != nil {
		gc.GnoDataSources = gdss
	}

	if doc != nil && doc.Components != nil && doc.Components.Schemas != nil {
		named := make(map[string]*openapiv3.SchemaOrReference)
		for _, item := range doc.Components.Schemas.AdditionalProperties {
			named[item.Name] = item.Value
		}
		gc.Schemas = named
	}

	if doc != nil && doc.Components != nil && doc.Components.Parameters != nil {
		named := make(map[string]*openapiv3.ParameterOrReference)
		for _, item := range doc.Components.Parameters.AdditionalProperties {
			named[item.Name] = item.Value
		}
		gc.Parameters = named
	}

	if doc != nil && doc.Components != nil && doc.Components.RequestBodies != nil {
		named := make(map[string]*openapiv3.RequestBodyOrReference)
		for _, item := range doc.Components.RequestBodies.AdditionalProperties {
			named[item.Name] = item.Value
		}
		gc.RequestBodies = named
	}

	return gc, nil
}

func refToScopeTraversalExpr(ref string) (*generated.ScopeTraversalExpr, error) {
	u, err := url.Parse(ref)
	if err != nil {
		return nil, err
	}

	root := &generated.Traverser{
		TraverserClause: &generated.Traverser_TRoot{
			TRoot: &generated.TraverseRoot{Name: "var"},
		},
	}
	traversal := []*generated.Traverser{root}

	if u.Host == "" && u.Path == "" && u.Fragment != "" {
		for _, item := range strings.SplitN(u.Fragment, "/", -1) {
			if item == "" || strings.ToLower(item) == "components" {
				continue
			}
			traversal = append(traversal, &generated.Traverser{
				TraverserClause: &generated.Traverser_TAttr{
					TAttr: &generated.TraverseAttr{Name: item},
				},
			})
		}
	}
	return &generated.ScopeTraversalExpr{
		Traversal: traversal,
	}, nil
}

func stringToLiteralValueExpr(s string) *generated.Expression {
	return &generated.Expression{
		ExpressionClause: &generated.Expression_Lvexpr{
			Lvexpr: &generated.LiteralValueExpr{
				Val: &generated.CtyValue{
					CtyValueClause: &generated.CtyValue_StringValue{
						StringValue: s,
					},
				},
			},
		},
	}
}

func schemaMediaTypes(m *openapiv3.MediaTypes) *openapiv3.SchemaOrReference {
	for _, item := range m.AdditionalProperties {
		if strings.ToLower(item.Name) == "application/json" {
			return item.Value.GetSchema()
		}
	}

	for _, item := range m.AdditionalProperties {
		if strings.ToLower(item.Name) == "application/x-www-form-urlencoded" {
			return item.Value.GetSchema()
		}
	}

	return m.AdditionalProperties[0].Value.GetSchema()
}
