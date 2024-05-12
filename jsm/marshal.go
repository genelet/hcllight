package jsm

import (
	"fmt"

	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"
	"gopkg.in/yaml.v3"
)

func referenceToExpression(ref string) (*light.Expression, error) {
	if ref[:2] != "#/" {
		return nil, fmt.Errorf("invalid reference: %s", ref)
	}
	return stringToTraversal(ref[2:]), nil
}

func expressionToReference(expr *light.Expression) (string, error) {
	x := traversalToString(expr)
	if x == nil {
		return "", fmt.Errorf("invalid expression: %#v", expr)
	}
	return "#/" + *x, nil
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
				def, err := exprToLiteralString(expr.Args[0])
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
func schemaNumberToFcexpr(self *SchemaNumber, expr *light.FunctionCallExpr) (*light.FunctionCallExpr, error) {
	if self == nil {
		return expr, nil
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

	return expr, nil
}

func fcexprToSchemaNumber(common *Common, fcexpr *light.FunctionCallExpr) (*Schema, error) {
	s := &Schema{
		Common:       common,
		SchemaNumber: &SchemaNumber{},
	}
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
				s.SchemaNumber.Minimum = &jsonschema.SchemaNumber{
					Float: &min,
				}
			case "maximum":
				max, err := exprToFloat64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.SchemaNumber.Maximum = &jsonschema.SchemaNumber{
					Float: &max,
				}
			case "exclusiveMinimum":
				excl, err := exprToBoolean(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.SchemaNumber.ExclusiveMinimum = &excl
			case "exclusiveMaximum":
				excl, err := exprToBoolean(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.SchemaNumber.ExclusiveMaximum = &excl
			case "multipleOf":
				mul, err := exprToFloat64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.SchemaNumber.MultipleOf = &jsonschema.SchemaNumber{
					Float: &mul,
				}
			default:
			}
		default:
		}
	}
	return s, nil
}

func schemaStringToFcexpr(self *SchemaString, expr *light.FunctionCallExpr) (*light.FunctionCallExpr, error) {
	if self == nil {
		return expr, nil
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
	return expr, nil
}

func fcexprToSchemaString(common *Common, fcexpr *light.FunctionCallExpr) (*Schema, error) {
	s := &Schema{
		Common:       common,
		SchemaString: &SchemaString{},
	}
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
				s.SchemaString.MaxLength = &max
			case "minLength":
				min, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.SchemaString.MinLength = &min
			case "pattern":
				pattern, err := exprToTextString(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.SchemaString.Pattern = &pattern
			default:
			}
		default:
		}
	}
	return s, nil
}

func schemaArrayToFcexpr(self *SchemaArray, expr *light.FunctionCallExpr) (*light.FunctionCallExpr, error) {
	if self == nil {
		return expr, nil
	}
	if self.Items != nil && (self.Items.Schema != nil || len(self.Items.SchemaArray) > 0) {
		ex, err := schemaOrSchemaArrayToExpression(self.Items)
		if err != nil {
			return nil, err
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
	return expr, nil
}

func fcexprToSchemaArray(common *Common, fcexpr *light.FunctionCallExpr) (*Schema, error) {
	s := &Schema{
		Common:      common,
		SchemaArray: &SchemaArray{},
	}

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
				s.SchemaArray.MaxItems = &max
			case "minItems":
				min, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.SchemaArray.MinItems = &min
			case "uniqueItems":
				unique, err := exprToBoolean(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.SchemaArray.UniqueItems = &unique
			default:
			}
		default:
			if found {
				return nil, fmt.Errorf("got two or more items in fcexpr")
			}
			found = true
			items, err := expressionToSchemaOrSchemaArray(arg)
			if err != nil {
				return nil, err
			}
			s.SchemaArray.Items = items
		}
	}
	return s, nil
}

func schemaObjectToFcexpr(self *SchemaObject, expr *light.FunctionCallExpr) (*light.FunctionCallExpr, error) {
	if self == nil {
		return expr, nil
	}
	if self.Properties != nil {
		ex, err := mapSchemaToObjectConsExpr(self.Properties)
		if err != nil {
			return nil, err
		}
		expr.Args = append([]*light.Expression{&light.Expression{
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
	return expr, nil
}

func fcexprToSchemaObject(common *Common, fcexpr *light.FunctionCallExpr) (*Schema, error) {
	s := &Schema{
		Common:       common,
		SchemaObject: &SchemaObject{},
	}
	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Ocexpr:
			expr := arg.GetOcexpr()
			properties, err := objectConsExprToMapSchema(expr)
			if err != nil {
				return nil, err
			}
			s.SchemaObject.Properties = properties
		case *light.Expression_Fcexpr:
			expr := arg.GetFcexpr()
			switch expr.Name {
			case "maxProperties":
				max, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.SchemaObject.MaxProperties = &max
			case "minProperties":
				min, err := exprToInt64(expr.Args[0])
				if err != nil {
					return nil, err
				}
				s.SchemaObject.MinProperties = &min
			case "required":
				s.SchemaObject.Required = tupleConsExprToStringArray(expr.Args[0])
			default:
			}
		default:
		}
	}
	return s, nil
}

func schemaMapToFcexpr(self *SchemaMap, expr *light.FunctionCallExpr) (*light.FunctionCallExpr, error) {
	if self == nil {
		return expr, nil
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
			return nil, err
		}
		expr.Args = append([]*light.Expression{ex}, expr.Args...)
	}
	return expr, nil
}

func fcexprToSchemaMap(common *Common, fcexpr *light.FunctionCallExpr) (*Schema, error) {
	s := &Schema{
		Common:    common,
		SchemaMap: &SchemaMap{},
	}
	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Lvexpr:
			b, err := exprToBoolean(arg)
			if err != nil {
				return nil, err
			}
			s.SchemaMap.AdditionalProperties = &SchemaOrBoolean{
				Boolean: &b,
			}
		default:
			s, err := expressionToSchema(arg)
			if err != nil {
				return nil, err
			}
			s.SchemaMap.AdditionalProperties = &SchemaOrBoolean{
				Schema: s,
			}
		}
	}
	return s, nil
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
		return schemaMapToFcexpr(self.SchemaMap, expr)
	case "object":
		return schemaObjectToFcexpr(self.SchemaObject, expr)
	case "array":
		return schemaArrayToFcexpr(self.SchemaArray, expr)
	case "string":
		return schemaStringToFcexpr(self.SchemaString, expr)
	case "number", "integer":
		return schemaNumberToFcexpr(self.SchemaNumber, expr)
	default:
	}

	// this is boolean
	return expr, nil
}

func fcexprToSchema(fcexpr *light.FunctionCallExpr) (*Schema, error) {
	if fcexpr == nil {
		return nil, nil
	}

	common, err := fcexprToCommon(fcexpr)
	if err != nil {
		return nil, err
	}

	switch fcexpr.Name {
	case "number", "integer":
		return fcexprToSchemaNumber(common, fcexpr)
	case "string":
		return fcexprToSchemaString(common, fcexpr)
	case "array":
		return fcexprToSchemaArray(common, fcexpr)
	case "object":
		return fcexprToSchemaObject(common, fcexpr)
	case "map":
		return fcexprToSchemaMap(common, fcexpr)
	default:
	}

	// boolean
	return &Schema{
		Common: common,
	}, nil
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
