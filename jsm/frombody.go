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
