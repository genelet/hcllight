// Copyright (c) Greetingland LLC

package gno

import (
	"errors"
	"fmt"
	"net/url"
	"strings"

	"github.com/genelet/determined/dethcl"
	"github.com/genelet/hcllight/generated"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
	"gopkg.in/yaml.v3"
)

// Config represents a YAML generator config.
type Config struct {
	Provider    `yaml:"provider" hcl:"provider,block"`
	Resources   map[string]*Resource   `yaml:"resources" hcl:"resources,block"`
	DataSources map[string]*DataSource `yaml:"data_sources" hcl:"data_sources,block"`
}

// ParseConfig takes in a byte array, unmarshals into a Config struct, and validates the result
// By default the byte array is assumed to be YAML, but if data_type is "hcl" or "tf", it will be unmarshaled as HCL
func ParseConfig(bytes []byte, data_type ...string) (*Config, error) {
	var result Config
	var typ string
	var err error
	if data_type != nil {
		typ = strings.ToLower(data_type[0])
	}
	if typ == "hcl" || typ == "tf" {
		err = dethcl.Unmarshal(bytes, &result)
	} else {
		err = yaml.Unmarshal(bytes, &result)
	}
	if err != nil {
		return nil, fmt.Errorf("error unmarshaling config: %w", err)
	}
	if err = result.Validate(); err != nil {
		return nil, fmt.Errorf("config validation error(s): %w", err)
	}

	return &result, nil
}

func (self *Config) Validate() error {
	if self == nil {
		return errors.New("config is nil")
	}

	var result error

	if (self.DataSources == nil || len(self.DataSources) == 0) && (self.Resources == nil || len(self.Resources) == 0) {
		result = errors.Join(result, fmt.Errorf("\t%s", "at least one object is required in either 'resources' or 'data_sources'"))
	}

	// Validate Provider
	err := self.Provider.Validate()
	if err != nil {
		result = errors.Join(result, fmt.Errorf("\tprovider %w", err))
	}

	// Validate all Resources
	for name, resource := range self.Resources {
		err := resource.Validate()
		if err != nil {
			result = errors.Join(result, fmt.Errorf("\tresource '%s' %w", name, err))
		}
	}

	// Validate all Data Sources
	for name, dataSource := range self.DataSources {
		err := dataSource.Validate()
		if err != nil {
			result = errors.Join(result, fmt.Errorf("\tdata_source '%s' %w", name, err))
		}
	}

	return result
}

func (c *Config) NewGnoConfig(doc *openapiv3.Document) (*GnoConfig, error) {
	gc := &GnoConfig{}

	gp, err := c.Provider.BuildGnoProvider(doc)
	if err != nil {
		return nil, fmt.Errorf("error building provider: %w", err)
	}
	gc.GnoProvider = *gp

	var grs map[string]*GnoResource
	for name, resource := range c.Resources {
		gr, err := resource.BuildGnoResource(doc)
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
		gds, err := dataSource.BuildGnoDataSource(doc)
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

func sumBodies(bodies ...*generated.Body) *generated.Body {
	var result *generated.Body
	for _, body := range bodies {
		if body == nil {
			continue
		}
		if result == nil {
			result = &generated.Body{}
		}
		if body.Attributes != nil {
			if result.Attributes == nil {
				result.Attributes = make(map[string]*generated.Attribute)
			}
			for name, attr := range body.Attributes {
				result.Attributes[name] = attr
			}
		}
		if body.Blocks != nil {
			if result.Blocks == nil {
				result.Blocks = make([]*generated.Block, 0, len(body.Blocks))
			}
			result.Blocks = append(result.Blocks, body.Blocks...)
		}
	}
	return result
}

func simpleBody(name string, expr *generated.Expression) *generated.Body {
	return &generated.Body{
		Attributes: map[string]*generated.Attribute{
			name: {
				Name: name,
				Expr: expr,
			},
		},
	}
}

func appendBlock(blocks []*generated.Block, name string, body *generated.Body) []*generated.Block {
	return append(blocks, &generated.Block{
		Type: name,
		Bdy:  body,
	})
}
