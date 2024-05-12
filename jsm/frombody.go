package jsm

import (
	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"
)

func getType(body *light.Body) *jsonschema.StringOrStringArray {
	if body == nil {
		return nil
	}
	if attr, ok := body.Attributes["type"]; ok {
		switch attr.Expr.ExpressionClause.(type) {
		case *light.Expression_Tcexpr:
			x := tupleConsExprToStringArray(attr.Expr)
			return &jsonschema.StringOrStringArray{
				StringArray: &x,
			}
		case *light.Expression_Lvexpr:
			x := textValueExprToString(attr.Expr)
			return &jsonschema.StringOrStringArray{
				String: x,
			}
		default:
		}
	}
	return nil
}

func BodyToSchema(body *light.Body) (*Schema, error) {
	for name, attr := range body.Attributes {
	}
	schemaFull, err := bodyToSchemaFull(body)
	if err != nil {
		return nil, err
	}

	if schemaFull == nil {
		return nil, nil
	}

	common := schemaFull.Common
	if common == nil {
		return &Schema{
			SchemaFull: schemaFull,
			isFull:     true,
		}, nil
	}

	typ := common.Type

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

	if schemaFull.Reference != nil && common == nil && schemaFull.SchemaNumber == nil && schemaFull.SchemaString == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaObject == nil && schemaFull.SchemaMap == nil {
		return &Schema{
			Reference: schemaFull.Reference,
		}, nil
	}

	schema := &Schema{
		Common: common,
	}

	if schemaFull.SchemaNumber == nil && schemaFull.SchemaString == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaObject == nil && schemaFull.SchemaMap == nil {
		return schema, nil
	}

	if schemaFull.SchemaNumber != nil && schemaFull.SchemaString == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaObject == nil && schemaFull.SchemaMap == nil {
		schema.SchemaNumber = schemaFull.SchemaNumber
		return schema, nil
	} else if schemaFull.SchemaString != nil && schemaFull.SchemaNumber == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaObject == nil && schemaFull.SchemaMap == nil {
		schema.SchemaString = schemaFull.SchemaString
		return schema, nil
	} else if schemaFull.SchemaArray != nil && schemaFull.SchemaNumber == nil && schemaFull.SchemaString == nil && schemaFull.SchemaObject == nil && schemaFull.SchemaMap == nil {
		schema.SchemaArray = schemaFull.SchemaArray
		return schema, nil
	} else if schemaFull.SchemaObject != nil && schemaFull.SchemaNumber == nil && schemaFull.SchemaString == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaMap == nil {
		schema.SchemaObject = schemaFull.SchemaObject
		return schema, nil
	} else if schemaFull.SchemaMap != nil && schemaFull.SchemaNumber == nil && schemaFull.SchemaString == nil && schemaFull.SchemaArray == nil && schemaFull.SchemaObject == nil {
		schema.SchemaMap = schemaFull.SchemaMap
		return schema, nil
	}

	return &Schema{
		SchemaFull: schemaFull,
		isFull:     true,
	}, nil
}

func bodyToSchemaFull(body *light.Body) (*SchemaFull, error) {
	if body == nil {
		return nil, nil
	}

	schemaFull := &SchemaFull{}
	typ := getType(body)

	var reference *Reference
	var common *Common
	var schemaNumber *jsonschema.SchemaNumber
	var schemaString *SchemaString
	var schemaArray *SchemaArray
	var SchemaObject *SchemaObject
	var schemaMap *SchemaMap

	for name, attr := range body.Attributes {
		var err error
		switch name {
		case "ref":
			ref, err := attributeToString(attr)
			if err != nil {
				return nil, err
			}
			reference = &Reference{
				Ref: ref,
			}
			return nil, nil
		case "schema":
			schemaFull.Schema, err = attributeToString(attr)
		case "id":
			schemaFull.ID, err = attributeToString(attr)
		case "format":
			schemaFull.Format, err = attributeToString(attr)
		default:
		}
	}
	common := getCommon(body)

}
