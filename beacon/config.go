// Copyright (c) Greetingland LLC

package beacon

import (
	"fmt"
	"net/url"
	"strings"

	"github.com/genelet/hcllight/light"
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

func NewGnoConfig(c *Config, doc *openapiv3.Document) (*GnoConfig, error) {
	gc := &GnoConfig{}

	gp, err := NewGnoProvider(&c.Provider, doc)
	if err != nil {
		return nil, fmt.Errorf("error building provider: %w", err)
	}
	gc.GnoProvider = *gp

	var grs map[string]*GnoResource
	for name, resource := range c.Resources {
		gr, err := NewGnoResource(resource, doc)
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
		gds, err := NewGnoDataSource(dataSource, doc)
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

func (self *GnoConfig) BuildHCL() (*light.Body, error) {
	var blocks []*light.Block

	provider, err := self.GnoProvider.blockProvider(self)
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
		blks, err := resource.blockResource(name, self)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}

	for name, data_source := range self.GnoDataSources {
		blks, err := data_source.blockDataSource(name, self)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}

	return &light.Body{
		Blocks: blocks,
	}, nil
}

func (self *GnoConfig) blockSchemas() (*light.Block, error) {
	var attributes map[string]*light.Attribute
	var blocks []*light.Block
	for name, schema := range self.Schemas {
		expr, err := self.exprSchemaOrReference(schema)
		if err != nil {
			return nil, err
		}

		if attributes == nil {
			attributes = make(map[string]*light.Attribute)
		}
		attributes[name] = &light.Attribute{
			Name: name,
			Expr: expr,
		}

	}

	return &light.Block{
		Type:   "variables",
		Labels: []string{"schemas"},
		Bdy: &light.Body{
			Attributes: attributes,
			Blocks:     blocks,
		},
	}, nil
}

func (self *GnoConfig) blockParameters() (*light.Block, error) {
	//	var attributes map[string]*light.Attribute
	var blocks []*light.Block
	for name, parameter := range self.Parameters {
		str, expr, err := self.nameExprParameterOrReference(parameter)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: name,
			Bdy: &light.Body{
				Attributes: map[string]*light.Attribute{
					name: {
						Name: str,
						Expr: expr,
					},
				},
			},
		})
	}

	return &light.Block{
		Type:   "variables",
		Labels: []string{"parameters"},
		Bdy: &light.Body{
			Blocks: blocks,
		},
	}, nil
}

func (self *GnoConfig) blockRequestBodies() (*light.Block, error) {
	var attributes map[string]*light.Attribute
	var blocks []*light.Block
	for name, requestBody := range self.RequestBodies {
		expr, err := self.exprRequestBodyOrReference(requestBody)
		if err != nil {
			return nil, err
		}
		if attributes == nil {
			attributes = make(map[string]*light.Attribute)
		}
		attributes[name] = &light.Attribute{
			Name: name,
			Expr: expr,
		}
	}

	return &light.Block{
		Type:   "variables",
		Labels: []string{"request_bodies"},
		Bdy: &light.Body{
			Attributes: attributes,
			Blocks:     blocks,
		},
	}, nil
}

func (self *GnoConfig) expandSchemaOrReference(v *openapiv3.SchemaOrReference) (*openapiv3.Schema, error) {
	var schema *openapiv3.Schema
	if x := v.GetReference(); x != nil {
		key := getLastName(x.GetXRef())
		if self.Schemas[key] == nil {
			return nil, fmt.Errorf("schema %s not found", key)
		}
		schema = self.Schemas[key].GetSchema()
	} else {
		schema = v.GetSchema()
	}
	if schema == nil {
		return nil, fmt.Errorf("schema not found")
	}
	return schema, nil
}

func (self *GnoConfig) expandParameterOrReference(v *openapiv3.ParameterOrReference) (*openapiv3.Parameter, error) {
	var parameter *openapiv3.Parameter
	if x := v.GetReference(); x != nil {
		key := getLastName(x.GetXRef())
		if self.Parameters[key] == nil {
			return nil, fmt.Errorf("parameter %s not found", key)
		}
		parameter = self.Parameters[key].GetParameter()
	} else {
		parameter = v.GetParameter()
	}
	if parameter == nil {
		return nil, fmt.Errorf("parameter not found")
	}
	return parameter, nil
}

func (self *GnoConfig) expandRequestBodyOrReference(v *openapiv3.RequestBodyOrReference) (*openapiv3.RequestBody, error) {
	var requestBody *openapiv3.RequestBody
	if x := v.GetReference(); x != nil {
		key := getLastName(x.GetXRef())
		if self.RequestBodies[key] == nil {
			return nil, fmt.Errorf("request body %s not found", key)
		}
		requestBody = self.RequestBodies[key].GetRequestBody()
	} else {
		requestBody = v.GetRequestBody()
	}
	if requestBody == nil {
		return nil, fmt.Errorf("request body not found")
	}
	return requestBody, nil
}

func getLastName(name string) string {
	items := strings.Split(name, "/")
	return items[len(items)-1]
}

func refToScopeTraversalExpr(ref string) (*light.ScopeTraversalExpr, error) {
	u, err := url.Parse(ref)
	if err != nil {
		return nil, err
	}

	root := &light.Traverser{
		TraverserClause: &light.Traverser_TRoot{
			TRoot: &light.TraverseRoot{Name: "var"},
		},
	}
	traversal := []*light.Traverser{root}

	if u.Host == "" && u.Path == "" && u.Fragment != "" {
		for _, item := range strings.SplitN(u.Fragment, "/", -1) {
			if item == "" || strings.ToLower(item) == "components" {
				continue
			}
			traversal = append(traversal, &light.Traverser{
				TraverserClause: &light.Traverser_TAttr{
					TAttr: &light.TraverseAttr{Name: item},
				},
			})
		}
	}
	return &light.ScopeTraversalExpr{
		Traversal: traversal,
	}, nil
}

func light.StringToLiteralValueExpr(s string) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_StringValue{
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

func bodyExpr(expr *light.Expression) (*light.Body, error) {
	ocexpr := expr.GetOcexpr()
	if ocexpr == nil {
		return nil, fmt.Errorf("expression is not ocexpr")
	}

	attributes := make(map[string]*light.Attribute)
	for _, item := range ocexpr.Items {
		k := item.KeyExpr.GetLvexpr().Val.GetStringValue()
		attributes[k] = &light.Attribute{
			Name: k,
			Expr: item.ValueExpr,
		}
	}
	return &light.Body{
		Attributes: attributes,
	}, nil
}

func (self *GnoConfig) exprSchemaOrReference(v *openapiv3.SchemaOrReference) (*light.Expression, error) {
	schema, err := self.expandSchemaOrReference(v)
	if err != nil {
		return nil, err
	}
	return self.exprSchema(schema)
}

func (self *GnoConfig) exprSchema(v *openapiv3.Schema) (*light.Expression, error) {
	switch v.Type {
	case "string", "number", "integer", "boolean":
		fcexpr := &light.FunctionCallExpr{Name: v.Type}
		if v.Format != "" {
			fcexpr.Args = append(fcexpr.Args, stringToTextValueExpr(v.Format))
		}
		return &light.Expression{
			ExpressionClause: &light.Expression_Fcexpr{
				Fcexpr: fcexpr,
			},
		}, nil
	case "array":
		tcexpr := &light.TupleConsExpr{}
		for _, item := range v.Items.SchemaOrReference {
			expr, err := self.exprSchemaOrReference(item)
			if err != nil {
				return nil, err
			}
			tcexpr.Exprs = append(tcexpr.Exprs, expr)
		}
		return &light.Expression{
			ExpressionClause: &light.Expression_Tcexpr{
				Tcexpr: tcexpr,
			},
		}, nil
	default:
	}

	if v.Properties != nil {
		ocexpr := &light.ObjectConsExpr{}
		var items []*light.ObjectConsItem
		for _, item := range v.Properties.AdditionalProperties {
			expr, err := self.exprSchemaOrReference(item.Value)
			if err != nil {
				return nil, err
			}
			items = append(items, &light.ObjectConsItem{
				KeyExpr:   light.StringToLiteralValueExpr(item.Name),
				ValueExpr: expr,
			})
		}
		ocexpr.Items = items
		return &light.Expression{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: ocexpr,
			},
		}, nil
	}

	if v.AdditionalProperties != nil {
		if x := v.AdditionalProperties.GetSchemaOrReference(); x != nil {
			return self.exprSchemaOrReference(x)
		}
	}

	return nil, nil
}

func (self *GnoConfig) nameExprParameterOrReference(v *openapiv3.ParameterOrReference) (string, *light.Expression, error) {
	parameter, err := self.expandParameterOrReference(v)
	if err != nil {
		return "", nil, err
	}
	expr, err := self.exprParameter(parameter)
	return parameter.Name, expr, err
}

// parameter always return body, different bodies could be added
func (self *GnoConfig) exprParameter(p *openapiv3.Parameter) (*light.Expression, error) {
	if p.GetSchema() != nil {
		return self.exprSchemaOrReference(p.GetSchema())
	}

	// p.Content != nil
	schemaOrReference := schemaMediaTypes(p.Content)
	return self.exprSchemaOrReference(schemaOrReference)
}

func (self *GnoConfig) bodyArrayParameterOrReference(v []*openapiv3.ParameterOrReference) (*light.Body, error) {
	attributes := make(map[string]*light.Attribute)
	for _, item := range v {
		name, expr, err := self.nameExprParameterOrReference(item)
		if err != nil {
			return nil, err
		}
		attributes[name] = &light.Attribute{
			Name: name,
			Expr: expr,
		}
	}

	return &light.Body{
		Attributes: attributes,
	}, nil
}

// return request body as ocexpr
func (self *GnoConfig) exprRequestBodyOrReference(v *openapiv3.RequestBodyOrReference) (*light.Expression, error) {
	rb, err := self.expandRequestBodyOrReference(v)
	if err != nil {
		return nil, err
	}
	return self.exprRequestBody(rb)
}

func (self *GnoConfig) exprRequestBody(v *openapiv3.RequestBody) (*light.Expression, error) {
	schemaOrReference := schemaMediaTypes(v.Content)
	return self.exprSchemaOrReference(schemaOrReference)
}

// return request body as body
func (self *GnoConfig) bodyRequestBodyOrReference(v *openapiv3.RequestBodyOrReference) (*light.Body, error) {
	expr, err := self.exprRequestBodyOrReference(v)
	if err != nil {
		return nil, err
	}

	return bodyExpr(expr)
}
