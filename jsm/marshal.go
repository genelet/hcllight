package jsm

import (
	"fmt"

	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"
	"gopkg.in/yaml.v3"
)

func NewSchemaFromBody(body *light.Body) (*Schema, error) {
	if body == nil {
		return nil, nil
	}
	if (body.Blocks != nil && len(body.Blocks) > 0) || body.Attributes == nil || len(body.Attributes) >= 2 {
		full, err := bodyToSchemaFull(body)
		return &Schema{SchemaFull: full, isFull: true}, err
	}

	s := &Schema{}
	var err error
	s.Reference, s.Common, s.SchemaNumber, s.SchemaString, s.SchemaArray, s.SchemaObject, s.SchemaMap, err = bodyToShorts(body)
	if err != nil {
		return nil, err
	}
	if s.Common != nil && s.Common.Type != nil {
		return s, nil
	}

	full, err := bodyToSchemaFull(body)
	return &Schema{SchemaFull: full, isFull: true}, err
}

func (self *Schema) ToBody() (*light.Body, error) {
	if self.isFull {
		return schemaFullToBody(self.SchemaFull)
	}

	return shortsToBody(
		self.Reference,
		self.Common,
		self.SchemaNumber,
		self.SchemaString,
		self.SchemaArray,
		self.SchemaObject,
		self.SchemaMap,
	)
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
	default:
	}
	x := light.TupleConsExprToStringArray(expr)
	return &jsonschema.StringOrStringArray{
		StringArray: &x,
	}
}

// try to use mapToBody first
func mapSchemaToObjectConsExpr(s map[string]*Schema) (*light.ObjectConsExpr, error) {
	if s == nil {
		return nil, nil
	}
	var items []*light.ObjectConsItem
	for k, v := range s {
		ex, err := schemaToExpression(v)
		if err != nil {
			return nil, err
		}
		items = append(items, &light.ObjectConsItem{
			KeyExpr:   light.StringToLiteralValueExpr(k),
			ValueExpr: ex,
		})
	}
	return &light.ObjectConsExpr{
		Items: items,
	}, nil
}

func objectConsExprToMapSchema(o *light.ObjectConsExpr) (map[string]*Schema, error) {
	if o == nil {
		return nil, nil
	}
	m := make(map[string]*Schema)
	for _, item := range o.Items {
		k := light.KeyValueExprToString(item.KeyExpr)
		v, err := expressionToSchema(item.ValueExpr)
		if err != nil {
			return nil, err
		}
		m[*k] = v
	}
	return m, nil
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

// should use it in schemaMap
func schemaOrBooleanToExpression(items *SchemaOrBoolean) (*light.Expression, error) {
	if items.Schema != nil {
		return schemaToExpression(items.Schema)
	} else {
		return light.BooleanToLiteralValueExpr(*items.Boolean), nil
	}
}

// should use it in schemaMap
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
		case *light.Expression_Texpr:
			enums = append(enums, jsonschema.SchemaEnumValue{String: light.TextValueExprToString(expr)})
		case *light.Expression_Lvexpr:
			enums = append(enums, jsonschema.SchemaEnumValue{Bool: light.LiteralValueExprToBoolean(expr)})
		default:
		}
	}
	return enums, nil
}

func mapSchemaToBody(s map[string]*Schema) (*light.Body, error) {
	if s == nil {
		return nil, nil
	}

	var body *light.Body
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	for k, v := range s {
		if v.isFull {
			bdy, err := schemaFullToBody(v.SchemaFull)
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type: k,
				Bdy:  bdy,
			})
		} else {
			expr, err := schemaToExpression(v)
			if err != nil {
				return nil, err
			}
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: expr,
			}
		}
	}

	if len(attrs) > 0 {
		body = &light.Body{
			Attributes: attrs,
		}
	}
	if len(blocks) > 0 {
		if body == nil {
			body = &light.Body{}
		}
		body.Blocks = blocks
	}
	return body, nil
}

func bodyToMapSchema(b *light.Body) (map[string]*Schema, error) {
	if b == nil {
		return nil, nil
	}
	m := make(map[string]*Schema)
	for k, v := range b.Attributes {
		s, err := expressionToSchema(v.Expr)
		if err != nil {
			return nil, err
		}
		m[k] = s
	}
	for _, block := range b.Blocks {
		s, err := NewSchemaFromBody(block.Bdy)
		if err != nil {
			return nil, err
		}
		m[block.Type] = s
	}

	return m, nil
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
		s, err := bodyToSchemaFull(block.Bdy)
		if err != nil {
			return nil, err
		}
		m[block.Type] = &SchemaOrStringArray{
			Schema: &Schema{
				isFull:     true,
				SchemaFull: s,
			},
		}
	}
	return m, nil
}

func commonToFcexpr(self *Common) (*light.FunctionCallExpr, error) {
	if self == nil {
		return nil, nil
	}

	if self.Type == nil || self.Type.String == nil {
		return nil, fmt.Errorf("invalid type for common: %#v", self)
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
				common.Format = light.TextValueExprToString(expr.Args[0])
			case "default":
				v := light.LiteralValueExprToInterface(expr.Args[0])
				common.Default = &yaml.Node{
					Kind:  yaml.ScalarNode,
					Value: fmt.Sprintf("%v", v),
				}
			case "enum":
				for _, arg := range expr.Args {
					switch arg.ExpressionClause.(type) {
					case *light.Expression_Texpr:
						common.Enumeration = append(common.Enumeration, jsonschema.SchemaEnumValue{
							String: light.TextValueExprToString(arg),
						})
					case *light.Expression_Lvexpr:
						common.Enumeration = append(common.Enumeration, jsonschema.SchemaEnumValue{
							Bool: light.LiteralValueExprToBoolean(arg),
						})
					default:
						// ignore for Common
					}
				}
			default:
				// ignore for Common
			}
		default:
			// ignore for Common
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
			case "enum", "format", "default":
				// ignore
			default:
				return nil, fmt.Errorf("invalid name in number function: %s", expr.Name)
			}
		default:
			return nil, fmt.Errorf("invalid expression in number: %#v", arg)
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
			case "enum", "format", "default":
				// ignore
			default:
				return nil, fmt.Errorf("invalid name in string function: %s", expr.Name)
			}
		default:
			return nil, fmt.Errorf("invalid expression in string: %#v", arg)
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
			case "enum", "format", "default":
				// ignore
			default:
				items, err := expressionToSchemaOrSchemaArray(arg)
				if err != nil {
					return nil, err
				}
				s.Items = items
				found = true
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
		ex, err := mapSchemaToObjectConsExpr(self.Properties)
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
					Args: []*light.Expression{light.StringArrayToTupleConsEpr(self.Required)},
				},
			},
		})
	}
	return nil
}

func fcexprToSchemaObject(fcexpr *light.FunctionCallExpr) (*SchemaObject, error) {
	s := &SchemaObject{}
	found := false

	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Ocexpr:
			expr := arg.GetOcexpr()
			properties, err := objectConsExprToMapSchema(expr)
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
				s.Required = light.TupleConsExprToStringArray(expr.Args[0])
				found = true
			case "enum", "format", "default":
				// ignore
			default:
				return nil, fmt.Errorf("invalid name in object function: %s", expr.Name)
			}
		default:
			return nil, fmt.Errorf("invalid expression in object: %#v", arg)
		}
	}
	if found {
		return s, nil
	}
	return nil, nil
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
			continue
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "enum", "format", "default":
				// ignore
				continue
			default:
			}
		default:
		}

		schema, err := expressionToSchema(arg)
		if err != nil {
			return nil, err
		}
		s.AdditionalProperties = &SchemaOrBoolean{
			Schema: schema,
		}
		found = true
	}

	if !found {
		return nil, nil
	}

	return s, nil
}

func schemaToFcexpr(self *Schema) (*light.FunctionCallExpr, error) {
	comm, err := commonToFcexpr(self.Common)
	if err != nil {
		return nil, err
	}
	if comm == nil {
		return nil, nil
	}

	switch comm.Name {
	case "map":
		err = schemaMapToFcexpr(self.SchemaMap, comm)
	case "object":
		err = schemaObjectToFcexpr(self.SchemaObject, comm)
	case "array":
		err = schemaArrayToFcexpr(self.SchemaArray, comm)
	case "string":
		err = schemaStringToFcexpr(self.SchemaString, comm)
	case "number", "integer":
		err = schemaNumberToFcexpr(self.SchemaNumber, comm)
	case "boolean":
		// this is boolean
	default:
		return nil, fmt.Errorf("invalid type: %s", comm.Name)
	}

	return comm, err
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
	case "boolean":
	default:
		return nil, fmt.Errorf("invalid type: %s", fcexpr.Name)
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
		body := expr.GetOcexpr().ToBody()
		return NewSchemaFromBody(body)
	default:
	}

	return nil, fmt.Errorf("not supported expression: %#v", expr)
}
