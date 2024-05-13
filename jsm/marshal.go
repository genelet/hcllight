package jsm

import (
	"fmt"

	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"
	"gopkg.in/yaml.v3"
)

func (s *Schema) ToBody() (*light.Body, error) {
	if s.isFull {
		return schemaFullToBody(s.SchemaFull)
	}

	return shortsToBody(
		s.Reference,
		s.Common,
		s.SchemaNumber,
		s.SchemaString,
		s.SchemaArray,
		s.SchemaObject,
		s.SchemaMap,
	)
}

func NewSchemaFromBody(body *light.Body) (*Schema, error) {
	if body == nil {
		return nil, nil
	}
	if (body.Blocks != nil && len(body.Blocks) > 0) ||
		body.Attributes == nil ||
		(body.Attributes != nil && len(body.Attributes) != 1) {
		full, err := bodyToSchemaFull(body)
		return &Schema{SchemaFull: full, isFull: true}, err
	}

	s := &Schema{}
	var err error
	s.Reference, s.Common, s.SchemaNumber, s.SchemaString, s.SchemaArray, s.SchemaObject, s.SchemaMap, err = bodyToShorts(body)
	return s, err
}

func referenceToExpression(ref string) (*light.Expression, error) {
	if ref[:2] != "#/" {
		return nil, fmt.Errorf("invalid reference: %s", ref)
	}
	return stringToTraversal(ref[2:]), nil
}

func expressionToReference(expr *light.Expression) (string, error) {
	// in case there is only one level of reference which is parsed as lvexpr
	if x := expr.GetLvexpr(); x != nil {
		return "#/" + x.Val.GetStringValue(), nil
	} else if x := traversalToString(expr); x != nil {
		return "#/" + *x, nil
	}
	return "", fmt.Errorf("invalid expression: %#v", expr)
}

func shortToExpr(key string, expr *light.Expression) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: key,
				Args: []*light.Expression{expr},
			},
		},
	}
}

func stringToTextExpr(key, value string) *light.Expression {
	return shortToExpr(key, stringToTextValueExpr(value))
}

func exprToTextString(expr *light.Expression) (string, error) {
	if expr == nil {
		return "", nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Texpr:
		return expr.GetTexpr().Parts[0].GetLvexpr().GetVal().GetStringValue(), nil
	default:
	}
	return "", fmt.Errorf("invalid expression: %#v", expr)
}

func stringToLiteralExpr(key, value string) *light.Expression {
	return shortToExpr(key, stringToLiteralValueExpr(value))
}

func exprToLiteralString(expr *light.Expression) (string, error) {
	if expr == nil {
		return "", nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		return expr.GetLvexpr().Val.GetStringValue(), nil
	default:
	}
	return "", fmt.Errorf("invalid expression: %#v", expr)
}

func float64ToLiteralExpr(key string, f float64) *light.Expression {
	return shortToExpr(key, float64ToLiteralValueExpr(f))
}

func exprToFloat64(expr *light.Expression) (float64, error) {
	if expr == nil {
		return 0, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		return expr.GetLvexpr().Val.GetNumberValue(), nil
	default:
	}
	return 0, fmt.Errorf("invalid expression: %#v", expr)
}

func int64ToLiteralExpr(key string, i int64) *light.Expression {
	return shortToExpr(key, int64ToLiteralValueExpr(i))
}

func exprToInt64(expr *light.Expression) (int64, error) {
	if expr == nil {
		return 0, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		return int64(expr.GetLvexpr().Val.GetNumberValue()), nil
	default:
	}
	return 0, fmt.Errorf("invalid expression: %#v", expr)
}

func booleanToLiteralExpr(key string, b bool) *light.Expression {
	return shortToExpr(key, booleanToLiteralValueExpr(b))
}

func exprToBoolean(expr *light.Expression) (bool, error) {
	if expr == nil {
		return false, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		return expr.GetLvexpr().Val.GetBoolValue(), nil
	default:
	}
	return false, fmt.Errorf("invalid expression: %#v", expr)
}

func commonToFcexpr(self *Common) (*light.FunctionCallExpr, error) {
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

	found := false

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
				found = true
			case "default":
				def, err := exprToLiteralString(expr.Args[0])
				if err != nil {
					return nil, err
				}
				common.Default = &yaml.Node{
					Kind:  yaml.ScalarNode,
					Value: def,
				}
				found = true
			case "enum":
				enum, err := tupleConsExprToEnum(&light.TupleConsExpr{
					Exprs: expr.Args,
				})
				if err != nil {
					return nil, err
				}
				common.Enumeration = enum
				found = true
			default:
			}
		default:
		}
	}

	if found {
		return common, nil
	}
	return nil, nil
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
					Args: stringArrayToTupleConsEpr(self.Required).GetTcexpr().Exprs,
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
				s.Required = tupleConsExprToStringArray(expr.Args[0])
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
			ex = booleanToLiteralValueExpr(*self.AdditionalProperties.Boolean)
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
	expr, err := commonToFcexpr(self.Common)
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
		s, err := bodyToSchemaFull(body)
		if err != nil {
			return nil, err
		}
		return &Schema{
			isFull:     true,
			SchemaFull: s,
		}, nil
	default:
	}

	return nil, nil
}
