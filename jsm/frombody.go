package jsm

import (
	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"
)

func attrToString(v *light.Expression) *string {
	if v == nil {
		return nil
	}
	return textValueExprToString(v.GetTcexpr().Exprs[0])
}

func attrToBool(v *light.Expression) *bool {
	if v == nil {
		return nil
	}
	return literalValueExprToBool(v.GetTcexpr().Exprs[0])
}

func attrToInt64(v *light.Expression) *int64 {
	if v == nil {
		return nil
	}
	return literalValueExprToInt64(v.GetTcexpr().Exprs[0])
}

func attrToFloat64(v *light.Expression) *float64 {
	if v == nil {
		return nil
	}
	return literalValueExprToFloat64(v.GetTcexpr().Exprs[0])
}

func attrToStringArray(v *light.Expression) []string {
	if v == nil {
		return nil
	}
	return tupleConsExprToStringArray(v)
}

func getType(body *light.Body) *jsonschema.StringOrStringArray {
	if body == nil {
		return nil
	}
	if attr, ok := body.Attributes["type"]; ok {
		switch attr.Expr.ExpressionClause.(type) {
		case *light.Expression_Tcexpr:
			return &jsonschema.StringOrStringArray{
				StringArray: &tupleConsExprToStringArray(attr.Expr),
			}
		case *light.Expression_Lvexpr:
			return &jsonschema.StringOrStringArray{
				String: &textValueExprToString(attr.Expr),
			}
		default:
		}
	}
	return nil
}

func bodyToSchema(body *light.Body) (*Schema, error) {
	schemaFull, err := bodyToSchemaFull(body)
	if err != nil {
		return nil, err
	}

	if schemaFull == nil {
		return nil, nil
	}

	typ := getType(body)

	if typ == nil ||
		typ.String == nil ||
		schemaFull.Schema != nil ||
		schemaFull.ID != nil ||
		schemaFull.ReadOnly != nil ||
		schemaFull.WriteOnly != nil ||
		schemaFull.AdditionalItems != nil ||
		schemaFull.PatternProperties != nil ||
		schemaFull.Dependencies != nil ||
		schemaFull.AllOf != nil ||
		schemaFull.AnyOf != nil ||
		schemaFull.OneOf != nil ||
		schemaFull.Not != nil ||
		schemaFull.Definitions != nil ||
		schemaFull.Title != nil ||
		schemaFull.Description != nil {
		return &Schema{
			SchemaFull: schemaFull,
			isFull:     true,
		}, nil
	}

	common := schemaFull.Common
	schema := &Schema{
		Common: common,
	}
	if schemaFull.SchemaNumber == nil && schemaFull.SchemaString == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaObject == nil && schemaFull.SchemaMap == nil {
		return schema, nil
	}

	if (schemaFull.Number != nil && schemaFull.SchemaString == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaObject == nil && schemaFull.SchemaMap == nil) ||
		(schemaFull.String != nil && schemaFull.SchemaNumber == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaObject == nil && schemaFull.SchemaMap == nil) ||
		(schemaFull.Array != nil && schemaFull.SchemaNumber == nil && schemaFull.SchemaString == nil && schemaFull.SchemaObject == nil && schemaFull.SchemaMap == nil) ||
		(schemaFull.Object != nil && schemaFull.SchemaNumber == nil && schemaFull.SchemaString == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaMap == nil) ||
		(schemaFull.Map != nil && schemaFull.SchemaNumber == nil && schemaFull.SchemaString == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaObject == nil) {
		switch *typ.String {
		case "interger":
			object := schemaFull.SchemaNumber
			if object == nil {
				return schema, nil
			}

			if object.MultipleOf != nil {
				schema.MultipleOf = object.MultipleOf.Integer
			}
			if object.Maximum != nil {
				schema.Maximum = object.Maximum.Integer
			}
			if object.Minimum != nil {
				schema.Minimum = object.Minimum.Integer
			}
			return schema, nil
		case "number":
			return &Schema{
				Common:       common,
				SchemaNumber: schemaFull.SchemaNumber,
			}, nil
		case "string":
			return &Schema{
				Common:       common,
				SchemaString: schemaFull.SchemaString,
			}, nil
		case "array":
			return &Schema{
				Common:      common,
				SchemaArray: schemaFull.SchemaArray,
			}, nil
		case "object":
			return &Schema{
				Common:       common,
				SchemaObject: schemaFull.SchemaObject,
			}, nil
		case "map":
			return &Schema{
				Common:    common,
				SchemaMap: schemaFull.SchemaMap,
			}, nil
		default:
		}
	}

	if typ != nil {
		switch {
		case typ.String != nil:
			common = &Common{
				Type: typ,
			}
		case typ.StringArray != nil:
			common = &Common{
				Type: typ,
			}
		default:
		}
	}

	for k, attr := range s.Attributes {
		v := attr.Expr
		switch k {
		case "schema":
			schema.Schema = attrToString(v)
		case "id":
			schema.ID = attrToString(v)
		case "pattern":
			schema.Pattern = attrToString(v)
		case "title":
			schema.Title = attrToString(v)
		case "description":
			schema.Description = attrToString(v)
		case "format":
			schema.Format = attrToString(v)
		case "readOnly":
			schema.ReadOnly = attrToBool(v)
		case "writeOnly":
			schema.WriteOnly = attrToBool(v)
		//case "exclusiveMaximum":
		//	schema.ExclusiveMaximum = attrToBool(v)
		//case "exclusiveMinimum":
		//		schema.ExclusiveMinimum = attrToBool(v)
		case "uniqueItems":
			schema.UniqueItems = attrToBool(v)
		case "maxLength":
			schema.MaxLength = attrToInt64(v)
		case "minLength":
			schema.MinLength = attrToInt64(v)
		case "maxItems":
			schema.MaxItems = attrToInt64(v)
		case "minItems":
			schema.MinItems = attrToInt64(v)
		case "maxProperties":
			schema.MaxProperties = attrToInt64(v)
		case "minProperties":
			schema.MinProperties = attrToInt64(v)
		case "multipleOf":
			schema.MultipleOf = attrToFloat64(v)
		case "maximum":
			schema.Maximum = attrToFloat64(v)
		case "minimum":
			schema.Minimum = attrToFloat64(v)
		case "required":
			schema.Required = attrToStringArray(v)
		case "enumeration":
			schema.Enumeration, _ = tupleConsExprToEnum(v)
		case "default":
			schema.Default = attrToInterface(v)
		case "additionalItems":
			schema.AdditionalItems = attrToInterface(v)
		case "additionalProperties":
			schema.AdditionalProperties = attrToInterface(v)
		case "oneOf":
			schema.OneOf = attrToInterface(v)
		case "anyOf":
			schema.AnyOf = attrToInterface(v)
		case "allOf":
			schema.AllOf = attrToInterface(v)
		case "not":
			schema.Not = attrToInterface(v)
		default:
		}
	}

	return schema, nil
}
