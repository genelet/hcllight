package jsm

import (
	"fmt"
	"strings"

	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"

	"gopkg.in/yaml.v3"
)

// MarshalHCL converts a Schema to HCL representation.
func (self *Schema) MarshalHCL() ([]byte, error) {
	body, err := self.toBody()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

// UnmarshalHCL converts HCL representation to a Schema.
func (self *Schema) UnmarshalHCL(data []byte) error {
	var err error
	self, err = ParseSchema(data)
	return err
}

// ParseSchema parses a Schema from HCL, JSON, or YAML.
// The data parameter is the input data.
// The extension parameter is the file extension, which can be "json", "jsn", "yaml", or "yml".
// If the extension parameter is not provided, it is default to "hcl".
func ParseSchema(data []byte, extension ...string) (*Schema, error) {
	var typ string
	if extension != nil {
		typ = strings.ToLower(extension[0])
	}
	if typ == "json" || typ == "jsn" || typ == "yaml" || typ == "yml" {
		var doc yaml.Node
		err := yaml.Unmarshal(data, &doc)
		if err != nil {
			return nil, err
		}
		return NewSchemaFromJSM(jsonschema.NewSchemaFromObject(&doc)), nil
	}

	body, err := light.Parse(data)
	if err != nil {
		return nil, err
	}

	return schemaFromBody(body)
}

func schemaFromBody(body *light.Body) (*Schema, error) {
	ref, common, schemaNumber, schemaString, schemaArray, schemaObject, schemaMap, err := bodyToShorts(body)
	if err != nil {
		return nil, err
	}
	if ref != nil {
		return &Schema{
			Reference: ref,
		}, nil
	}

	full, err := bodyToSchemaFull(body, common, schemaNumber, schemaString, schemaArray, schemaObject, schemaMap)
	if err != nil {
		return nil, err
	}
	if full != nil {
		return &Schema{
			SchemaFull: full,
			isFull:     true,
		}, nil
	}

	if common != nil || schemaNumber != nil || schemaString != nil || schemaArray != nil || schemaObject != nil || schemaMap != nil {
		return &Schema{
			Common:       common,
			SchemaNumber: schemaNumber,
			SchemaString: schemaString,
			SchemaArray:  schemaArray,
			SchemaObject: schemaObject,
			SchemaMap:    schemaMap,
		}, nil
	}
	return nil, nil
}

func (self *Schema) toBody() (*light.Body, error) {
	var b *light.Body
	var err error
	if self.isFull {
		b, err = schemaFullToBody(self.SchemaFull)
		if err != nil {
			panic(err)
		}
		return b, nil
	}

	b, err = shortsToBody(
		self.Reference,
		self.Common,
		self.SchemaNumber,
		self.SchemaString,
		self.SchemaArray,
		self.SchemaObject,
		self.SchemaMap,
	)
	if err != nil {
		panic(err)
	}
	return b, nil
}

func stringOrStringArrayToExpression(t *jsonschema.StringOrStringArray) *light.Expression {
	if t == nil {
		return nil
	}
	if t.String != nil {
		return light.StringToTextValueExpr(*t.String)
	}
	return light.StringArrayToTupleConsEpr(*t.StringArray)
}

func expressionToStringOrStringArray(expr *light.Expression) *jsonschema.StringOrStringArray {
	if expr == nil {
		return nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Texpr:
		return &jsonschema.StringOrStringArray{
			String: light.TextValueExprToString(expr),
		}
	case *light.Expression_Tcexpr:
		arr := light.TupleConsExprToStringArray(expr)
		return &jsonschema.StringOrStringArray{
			StringArray: &arr,
		}
	}
	return nil
}

func sliceToTupleConsExpr(allof []*Schema) (*light.TupleConsExpr, error) {
	if allof == nil {
		return nil, nil
	}

	var exprs []*light.Expression
	for _, v := range allof {
		ex, err := schemaToExpression(v)
		if err != nil {
			return nil, err
		}
		exprs = append(exprs, ex)
	}
	return &light.TupleConsExpr{
		Exprs: exprs,
	}, nil
}

func tupleConsExprToSlice(t *light.TupleConsExpr) ([]*Schema, error) {
	if t == nil {
		return nil, nil
	}
	exprs := t.Exprs
	if len(exprs) == 0 {
		return nil, nil
	}
	var items []*Schema
	for _, expr := range exprs {
		s, err := expressionToSchema(expr)
		if err != nil {
			return nil, err
		}
		items = append(items, s)
	}

	return items, nil
}

func schemaOrSchemaArrayToExpression(items *SchemaOrSchemaArray) (*light.Expression, error) {
	if items.Schema != nil {
		return schemaToExpression(items.Schema)
	} else {
		expr, err := sliceToTupleConsExpr(items.SchemaArray)
		if err != nil {
			return nil, err
		}
		return &light.Expression{
			ExpressionClause: &light.Expression_Tcexpr{
				Tcexpr: expr,
			},
		}, nil
	}
}

func expressionToSchemaOrSchemaArray(expr *light.Expression) (*SchemaOrSchemaArray, error) {
	if expr.GetTcexpr() != nil {
		items, err := tupleConsExprToSlice(expr.GetTcexpr())
		if err != nil {
			return nil, err
		}
		return &SchemaOrSchemaArray{
			SchemaArray: items,
		}, nil
	} else {
		s, err := expressionToSchema(expr)
		if err != nil {
			return nil, err
		}
		return &SchemaOrSchemaArray{
			Schema: s,
		}, nil
	}
}

func schemaOrBooleanToExpression(items *SchemaOrBoolean) (*light.Expression, error) {
	if items.Schema != nil {
		return schemaToExpression(items.Schema)
	} else {
		return light.BooleanToLiteralValueExpr(*items.Boolean), nil
	}
}

func expressionToSchemaOrBoolean(expr *light.Expression) (*SchemaOrBoolean, error) {
	if expr.GetLvexpr() != nil {
		return &SchemaOrBoolean{
			Boolean: light.LiteralValueExprToBoolean(expr),
		}, nil
	} else {
		s, err := expressionToSchema(expr)
		if err != nil {
			return nil, err
		}
		return &SchemaOrBoolean{
			Schema: s,
		}, nil
	}
}

func enumToTupleConsExpr(enumeration []jsonschema.SchemaEnumValue) (*light.TupleConsExpr, error) {
	if len(enumeration) == 0 {
		return nil, nil
	}

	var enums []*light.Expression
	for _, e := range enumeration {
		if e.String != nil {
			enums = append(enums, light.StringToTextValueExpr(*e.String))
		} else {
			enums = append(enums, light.BooleanToLiteralValueExpr(*e.Bool))
		}
	}

	if len(enums) == 0 {
		return nil, nil
	}

	return &light.TupleConsExpr{
		Exprs: enums,
	}, nil
}

func tupleConsExprToEnum(t *light.TupleConsExpr) ([]jsonschema.SchemaEnumValue, error) {
	if t == nil {
		return nil, nil
	}
	exprs := t.Exprs
	if len(exprs) == 0 {
		return nil, nil
	}
	var enums []jsonschema.SchemaEnumValue
	for _, expr := range exprs {
		switch expr.ExpressionClause.(type) {
		case *light.Expression_Lvexpr:
			ptr := light.LiteralValueExprToString(expr)
			if ptr != nil {
				enums = append(enums, jsonschema.SchemaEnumValue{String: ptr})
			} else {
				enums = append(enums, jsonschema.SchemaEnumValue{Bool: light.LiteralValueExprToBoolean(expr)})
			}
		case *light.Expression_Texpr:
			ptr := light.TextValueExprToString(expr)
			if ptr != nil {
				enums = append(enums, jsonschema.SchemaEnumValue{String: ptr})
			} else {
				return nil, fmt.Errorf("invalid enum value: %#v", expr)
			}
		default:
			return nil, fmt.Errorf("invalid enum value not l nor t: %#v", expr)
		}
	}
	return enums, nil
}

func mapSchemaToOcexpr(s map[string]*Schema) (*light.ObjectConsExpr, error) {
	if s == nil {
		return nil, nil
	}

	var items []*light.ObjectConsItem
	for k, v := range s {
		expr, err := schemaToExpression(v)
		if err != nil {
			return nil, err
		}
		items = append(items, &light.ObjectConsItem{
			KeyExpr:   light.StringToKeyExpr(k),
			ValueExpr: expr,
		})
	}
	return &light.ObjectConsExpr{
		Items: items,
	}, nil
}

func ocexprToMapSchema(b *light.ObjectConsExpr) (map[string]*Schema, error) {
	if b == nil {
		return nil, nil
	}

	m := make(map[string]*Schema)
	for _, item := range b.Items {
		k := *light.KeyValueExprToString(item.KeyExpr)
		s, err := expressionToSchema(item.ValueExpr)
		if err != nil {
			return nil, err
		}
		m[k] = s
	}
	return m, nil
}

func mapSchemaToBlocks(s map[string]*Schema) ([]*light.Block, error) {
	if s == nil {
		return nil, nil
	}

	var blocks []*light.Block
	for k, v := range s {
		bdy, err := v.toBody()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: k,
			Bdy:  bdy,
		})
	}
	return blocks, nil
}

func blocksToMapSchema(blocks []*light.Block, name string) (map[string]*Schema, error) {
	if blocks == nil {
		return nil, nil
	}

	m := make(map[string]*Schema)
	for _, block := range blocks {
		if block.Type != name {
			continue
		}
		s, err := schemaFromBody(block.Bdy)
		if err != nil {
			return nil, err
		}
		m[block.Labels[0]] = s
	}
	if len(m) == 0 {
		return nil, nil
	}
	return m, nil
}

func getOcexprFromBlocks(blocks []*light.Block, name string) *light.ObjectConsExpr {
	for _, block := range blocks {
		if block.Type != name {
			continue
		}
		return block.Bdy.ToObjectConsExpr()
	}
	return nil
}

func mapSchemaOrStringArrayToBody(s map[string]*SchemaOrStringArray) (*light.Body, error) {
	if s == nil {
		return nil, nil
	}

	bdy := &light.Body{}
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	for k, v := range s {
		if v.Schema != nil {
			if v.Schema.isFull {
				bdy, err := schemaFullToBody(v.Schema.SchemaFull)
				if err != nil {
					return nil, err
				}
				blocks = append(blocks, &light.Block{
					Type: k,
					Bdy:  bdy,
				})
			} else {
				expr, err := schemaToExpression(v.Schema)
				if err != nil {
					return nil, err
				}
				attrs[k] = &light.Attribute{
					Name: k,
					Expr: expr,
				}
			}
		} else {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: light.StringArrayToTupleConsEpr(v.StringArray),
			}
		}
	}
	if len(attrs) > 0 {
		bdy.Attributes = attrs
	}
	if len(blocks) > 0 {
		bdy.Blocks = blocks
	}
	return bdy, nil
}

func bodyToMapSchemaOrStringArray(b *light.Body) (map[string]*SchemaOrStringArray, error) {
	if b == nil {
		return nil, nil
	}
	m := make(map[string]*SchemaOrStringArray)
	for k, v := range b.Attributes {
		if v.Expr.GetTcexpr() != nil {
			m[k] = &SchemaOrStringArray{
				StringArray: light.TupleConsExprToStringArray(v.Expr),
			}
		} else {
			s, err := expressionToSchema(v.Expr)
			if err != nil {
				return nil, err
			}
			m[k] = &SchemaOrStringArray{
				Schema: s,
			}
		}
	}
	for _, block := range b.Blocks {
		s, err := schemaFromBody(block.Bdy)
		if err != nil {
			return nil, err
		}
		m[block.Type] = &SchemaOrStringArray{
			Schema: s,
		}
	}
	return m, nil
}

func commonToFcexpr(self *Common) (*light.FunctionCallExpr, error) {
	if self == nil {
		return nil, nil
	}

	typ := *self.Type.String
	fnc := &light.FunctionCallExpr{
		Name: typ,
	}
	if self.Format != nil {
		fnc.Args = append(fnc.Args, stringToTextExpr("format", *self.Format))
	}
	if self.Default != nil {
		switch typ {
		case "boolean", "number", "integer", "array", "object", "map":
			fnc.Args = append(fnc.Args, stringToLiteralExpr("default", self.Default.Value))
		default:
			fnc.Args = append(fnc.Args, stringToTextExpr("default", self.Default.Value))
		}
	}
	if self.Enumeration != nil {
		expr, err := enumToTupleConsExpr(self.Enumeration)
		if err != nil {
			return nil, err
		} else if expr != nil {
			fnc.Args = append(fnc.Args, &light.Expression{
				ExpressionClause: &light.Expression_Fcexpr{
					Fcexpr: &light.FunctionCallExpr{
						Name: "enum",
						Args: expr.Exprs,
					},
				},
			})
		}
	}
	return fnc, nil
}

func fcexprToCommon(fcexpr *light.FunctionCallExpr) (*Common, error) {
	if fcexpr == nil {
		return nil, nil
	}

	common := &Common{
		Type: &jsonschema.StringOrStringArray{
			String: &fcexpr.Name,
		},
	}

	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "format":
				format, err := exprToTextString(expr.Args[0])
				if err != nil {
					return nil, err
				}
				common.Format = &format
			case "default":
				def, err := exprToTextString(expr.Args[0])
				if err != nil {
					return nil, err
				}
				common.Default = &yaml.Node{
					Kind:  yaml.ScalarNode,
					Value: def,
				}
			case "enum":
				enum, err := tupleConsExprToEnum(&light.TupleConsExpr{
					Exprs: expr.Args,
				})
				if err != nil {
					return nil, err
				}
				common.Enumeration = enum
			default:
			}
		default:
		}
	}

	return common, nil
}

// because of order in function, we can't loop attribute map
func schemaNumberToFcexpr(self *SchemaNumber, expr *light.FunctionCallExpr) error {
	if self == nil {
		return nil
	}
	if self.Minimum != nil {
		if self.Minimum.Float != nil {
			expr.Args = append(expr.Args, float64ToLiteralExpr("minimum", *self.Minimum.Float))
		} else {
			expr.Args = append(expr.Args, int64ToLiteralExpr("minimum", *self.Minimum.Integer))
		}
	}
	if self.Maximum != nil {
		if self.Maximum.Float != nil {
			expr.Args = append(expr.Args, float64ToLiteralExpr("maximum", *self.Maximum.Float))
		} else {
			expr.Args = append(expr.Args, int64ToLiteralExpr("maximum", *self.Maximum.Integer))
		}
	}
	if self.ExclusiveMinimum != nil {
		expr.Args = append(expr.Args, booleanToLiteralExpr("exclusiveMinimum", *self.ExclusiveMinimum))
	}
	if self.ExclusiveMaximum != nil {
		expr.Args = append(expr.Args, booleanToLiteralExpr("exclusiveMaximum", *self.ExclusiveMaximum))
	}
	if self.MultipleOf != nil {
		if self.MultipleOf.Float != nil {
			expr.Args = append(expr.Args, float64ToLiteralExpr("multipoleOf", *self.MultipleOf.Float))
		} else {
			expr.Args = append(expr.Args, int64ToLiteralExpr("multipleOf", *self.MultipleOf.Integer))
		}
	}

	return nil
}

func fcexprToSchemaNumber(fcexpr *light.FunctionCallExpr) (*SchemaNumber, error) {
	s := &SchemaNumber{}
	found := false

	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "minimum":
				min, err := exprToFloat64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.Minimum = &jsonschema.SchemaNumber{
					Float: &min,
				}
				found = true
			case "maximum":
				max, err := exprToFloat64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.Maximum = &jsonschema.SchemaNumber{
					Float: &max,
				}
				found = true
			case "exclusiveMinimum":
				excl, err := exprToBoolean(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.ExclusiveMinimum = &excl
				found = true
			case "exclusiveMaximum":
				excl, err := exprToBoolean(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.ExclusiveMaximum = &excl
				found = true
			case "multipleOf":
				mul, err := exprToFloat64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MultipleOf = &jsonschema.SchemaNumber{
					Float: &mul,
				}
				found = true
			default:
			}
		default:
		}
	}
	if found {
		return s, nil
	}
	return nil, nil
}

func schemaStringToFcexpr(self *SchemaString, expr *light.FunctionCallExpr) error {
	if self == nil {
		return nil
	}
	if self.MaxLength != nil {
		expr.Args = append(expr.Args, int64ToLiteralExpr("maxLength", *self.MaxLength))
	}
	if self.MinLength != nil {
		expr.Args = append(expr.Args, int64ToLiteralExpr("minLength", *self.MinLength))
	}
	if self.Pattern != nil {
		expr.Args = append(expr.Args, stringToTextExpr("pattern", *self.Pattern))
	}
	return nil
}

func fcexprToSchemaString(fcexpr *light.FunctionCallExpr) (*SchemaString, error) {
	s := &SchemaString{}
	found := false
	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "maxLength":
				max, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MaxLength = &max
				found = true
			case "minLength":
				min, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MinLength = &min
				found = true
			case "pattern":
				pattern, err := exprToTextString(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.Pattern = &pattern
				found = true
			default:
			}
		default:
		}
	}
	if found {
		return s, nil
	}
	return nil, nil
}

func schemaArrayToFcexpr(self *SchemaArray, expr *light.FunctionCallExpr) error {
	if self == nil {
		return nil
	}
	if self.Items != nil && (self.Items.Schema != nil || len(self.Items.SchemaArray) > 0) {
		ex, err := schemaOrSchemaArrayToExpression(self.Items)
		if err != nil {
			return err
		}
		expr.Args = append([]*light.Expression{ex}, expr.Args...)
	}

	if self.MaxItems != nil {
		expr.Args = append(expr.Args, int64ToLiteralExpr("maxItems", *self.MaxItems))
	}
	if self.MinItems != nil {
		expr.Args = append(expr.Args, int64ToLiteralExpr("minItems", *self.MinItems))
	}
	if self.UniqueItems != nil {
		expr.Args = append(expr.Args, booleanToLiteralExpr("uniqueItems", *self.UniqueItems))
	}
	return nil
}

func fcexprToSchemaArray(fcexpr *light.FunctionCallExpr) (*SchemaArray, error) {
	s := &SchemaArray{}
	var found bool

	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "maxItems":
				max, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MaxItems = &max
				found = true
			case "minItems":
				min, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MinItems = &min
				found = true
			case "uniqueItems":
				unique, err := exprToBoolean(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.UniqueItems = &unique
				found = true
			default:
			}
		default:
			items, err := expressionToSchemaOrSchemaArray(arg)
			if err != nil {
				return nil, err
			}
			s.Items = items
			found = true
		}
	}
	if found {
		return s, nil
	}
	return nil, nil
}

func schemaObjectToFcexpr(self *SchemaObject, expr *light.FunctionCallExpr) error {
	if self == nil {
		return nil
	}

	if self.Properties != nil {
		ex, err := mapSchemaToOcexpr(self.Properties)
		if err != nil {
			return err
		}
		expr.Args = append([]*light.Expression{{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: ex,
			}}}, expr.Args...)
	}

	if self.MaxProperties != nil {
		expr.Args = append(expr.Args, int64ToLiteralExpr("maxProperties", *self.MaxProperties))
	}
	if self.MinProperties != nil {
		expr.Args = append(expr.Args, int64ToLiteralExpr("minProperties", *self.MinProperties))
	}
	if self.Required != nil {
		expr.Args = append(expr.Args, &light.Expression{
			ExpressionClause: &light.Expression_Fcexpr{
				Fcexpr: &light.FunctionCallExpr{
					Name: "required",
					Args: light.StringArrayToTupleConsEpr(self.Required).GetTcexpr().Exprs,
				},
			},
		})
	}
	return nil
}

func fcexprToSchemaObject(fcexpr *light.FunctionCallExpr) (*SchemaObject, error) {
	s := &SchemaObject{}

	var found bool
	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Ocexpr:
			expr := arg.GetOcexpr()
			properties, err := ocexprToMapSchema(expr)
			if err != nil {
				return nil, err
			}
			s.Properties = properties
			found = true
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "maxProperties":
				max, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MaxProperties = &max
				found = true
			case "minProperties":
				min, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.MinProperties = &min
				found = true
			case "required":
				s.Required = light.TupleConsExprToStringArray(&light.Expression{
					ExpressionClause: &light.Expression_Tcexpr{
						Tcexpr: &light.TupleConsExpr{
							Exprs: expr.Args,
						},
					},
				})
				found = true
			default:
			}
		default:
		}
	}
	if !found {
		return nil, nil
	}

	return s, nil
}

func schemaMapToFcexpr(self *SchemaMap, expr *light.FunctionCallExpr) error {
	if self == nil {
		return nil
	}
	if self.AdditionalProperties != nil {
		var ex *light.Expression
		var err error
		if self.AdditionalProperties.Schema != nil {
			ex, err = schemaToExpression(self.AdditionalProperties.Schema)
		} else {
			ex = light.BooleanToLiteralValueExpr(*self.AdditionalProperties.Boolean)
		}
		if err != nil {
			return err
		}
		expr.Args = append([]*light.Expression{ex}, expr.Args...)
	}
	return nil
}

func fcexprToSchemaMap(fcexpr *light.FunctionCallExpr) (*SchemaMap, error) {
	s := &SchemaMap{}
	found := false
	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Lvexpr:
			b, err := exprToBoolean(arg)
			if err != nil {
				return nil, err
			}
			s.AdditionalProperties = &SchemaOrBoolean{
				Boolean: &b,
			}
			found = true
		default:
			schema, err := expressionToSchema(arg)
			if err != nil {
				return nil, err
			}
			s.AdditionalProperties = &SchemaOrBoolean{
				Schema: schema,
			}
			found = true
		}
	}
	if found {
		return s, nil
	}
	return nil, nil
}

func schemaToFcexpr(self *Schema) (*light.FunctionCallExpr, error) {
	cobj := self.Common
	if cobj == nil || cobj.Type == nil || cobj.Type.String == nil {
		return nil, fmt.Errorf("invalid type for common: %#v", cobj)
	}

	expr, err := commonToFcexpr(cobj)
	if err != nil {
		return nil, err
	}
	if expr == nil {
		return nil, nil
	}

	switch expr.Name {
	case "map":
		err = schemaMapToFcexpr(self.SchemaMap, expr)
	case "object":
		err = schemaObjectToFcexpr(self.SchemaObject, expr)
	case "array":
		err = schemaArrayToFcexpr(self.SchemaArray, expr)
	case "string":
		err = schemaStringToFcexpr(self.SchemaString, expr)
	case "number", "integer":
		err = schemaNumberToFcexpr(self.SchemaNumber, expr)
	default:
	}

	// this is boolean
	return expr, err
}

func fcexprToSchema(fcexpr *light.FunctionCallExpr) (*Schema, error) {
	if fcexpr == nil {
		return nil, nil
	}

	common, err := fcexprToCommon(fcexpr)
	if err != nil {
		return nil, err
	}

	var schemaNumber *SchemaNumber
	var schemaString *SchemaString
	var schemaArray *SchemaArray
	var schemaObject *SchemaObject
	var schemaMap *SchemaMap

	switch fcexpr.Name {
	case "number", "integer":
		schemaNumber, err = fcexprToSchemaNumber(fcexpr)
	case "string":
		schemaString, err = fcexprToSchemaString(fcexpr)
	case "array":
		schemaArray, err = fcexprToSchemaArray(fcexpr)
	case "object":
		schemaObject, err = fcexprToSchemaObject(fcexpr)
	case "map":
		schemaMap, err = fcexprToSchemaMap(fcexpr)
	default:
	}

	return &Schema{
		Common:       common,
		SchemaNumber: schemaNumber,
		SchemaString: schemaString,
		SchemaArray:  schemaArray,
		SchemaObject: schemaObject,
		SchemaMap:    schemaMap,
	}, err
}

func schemaToExpression(self *Schema) (*light.Expression, error) {
	if self == nil {
		return nil, nil
	}

	if self.isFull {
		body, err := schemaFullToBody(self.SchemaFull)
		if err != nil {
			return nil, err
		}
		return &light.Expression{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: body.ToObjectConsExpr(),
			},
		}, nil
	}

	if self.Reference != nil {
		return referenceToExpression(*(self.Reference.Ref))
	}

	expr, err := schemaToFcexpr(self)
	if err != nil {
		return nil, err
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: expr,
		},
	}, nil
}

func expressionToSchema(expr *light.Expression) (*Schema, error) {
	if expr == nil {
		return nil, nil
	}

	switch expr.ExpressionClause.(type) {
	case *light.Expression_Stexpr:
		ref, err := expressionToReference(expr)
		if err != nil {
			return nil, err
		}
		return &Schema{
			Reference: &Reference{
				Ref: &ref,
			},
		}, nil
	case *light.Expression_Fcexpr:
		return fcexprToSchema(expr.GetFcexpr())
	case *light.Expression_Ocexpr:
		return schemaFromBody(expr.GetOcexpr().ToBody())
	default:
	}
	return nil, fmt.Errorf("invalid expression in expressionToSchema: %#v", expr)
}
