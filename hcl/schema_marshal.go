package hcl

import (
	"github.com/genelet/hcllight/light"
)

func SchemaOrReferenceToExpression(self *SchemaOrReference) (*light.Expression, error) {
	if self == nil {
		return nil, nil
	}

	switch self.Oneof.(type) {
	case *SchemaOrReference_Reference:
		return referenceToExpression(self.GetReference()), nil
	case *SchemaOrReference_Schema:
		bdy, err := schemaFullToBody(self.GetSchema())
		if err != nil {
			return nil, err
		}
		return &light.Expression{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: bdy.ToObjectConsExpr(),
			},
		}, nil
	default:
	}

	expr := &light.FunctionCallExpr{}
	if x := self.GetBoolean(); x != nil {
		expr.Name = "boolean"
		expr.Args = append(expr.Args, booleanToLiteralValueExpr(x.Boolean))
	}
	switch self.Oneof.(type) {
	case *SchemaOrReference_Array:
		return schemaArrayToFcexpr(self.GetArray().Array)
	case *SchemaOrReference_Map:
		return schemaMapToFcexpr(self.GetMap().Map)
	case *SchemaOrReference_Object:
		return schemaObjectToFcexpr(self.GetObject().Object)
	case *SchemaOrReference_String_:
		return schemaStringToFcexpr(self.GetString_().String_)
	case *SchemaOrReference_Number:
		return schemaNumberToFcexpr(self.GetNumber().Number)
	default:
	}
	return nil, nil
}

func ExpressionToSchemaOrReference(self *light.Expression) (*SchemaOrReference, error) {
	if self == nil {
		return nil, nil
	}

	switch self.ExpressionClause.(type) {
	case *light.Expression_Fcexpr:
		expr := self.GetFcexpr()
		switch expr.Name {
		case "reference":
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_Reference{
					Reference: expressionToReference(expr),
				},
			}, nil
		case "array":
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_Array{
					Array: fcexprToArray(expr),
				},
			}, nil
		case "map":
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_Map{
					Map: fcexprToMap(expr),
				},
			}, nil
		case "object":
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_Object{
					Object: fcexprToObject(expr),
				},
			}, nil
		case "string":
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_String_{
					String_: fcexprToString(expr),
				},
			}, nil
		case "number":
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_Number{
					Number: fcexprToNumber(expr),
				},
			}, nil
		default:
		}
	}
	return nil, nil

}

func schemaOrReferenceToFcexpr(self *SchemaOrReference) (*light.FunctionCallExpr, error) {
	if self == nil {
		return nil
	}

	if x := self.GetReference(); x != nil {
		return referenceToExpression(x), nil
	}

	switch self.Oneof.(type) {
	case *SchemaOrReference_Reference:
		expr.Args = append(expr.Args, referenceToExpression(self.GetReference()))
	case *SchemaOrReference_Schema:
		bdy, err := schemaFullToBody(self.GetSchema())
		if err != nil {
			return err
		}
		return bdy.ToFunctionCallExpr(expr), nil
	case *SchemaOrReference_Array:
		return schemaArrayToFcexpr(self.GetArray().Array, expr)
	case *SchemaOrReference_Map:
		return schemaMapToFcexpr(self.GetMap().Map, expr)
	case *SchemaOrReference_Object:
		return schemaObjectToFcexpr(self.GetObject().Object, expr)
	case *SchemaOrReference_String_:
		return schemaStringToFcexpr(self.GetString_().String_, expr)
	case *SchemaOrReference_Number:
		return schemaNumberToFcexpr(self.GetNumber().Number, expr)
	default:
	}
	return nil
}

func fcexprToSchemaOrReference(fcexpr *light.FunctionCallExpr) (*SchemaOrReference, error) {
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

	return &SchemaOrReference{
		OASSchemaBoolean: common,
		SchemaNumber:     schemaNumber,
		SchemaString:     schemaString,
		SchemaArray:      schemaArray,
		SchemaObject:     schemaObject,
		SchemaMap:        schemaMap,
	}, err
}

func SchemaOrReferenceToBody(s *SchemaOrReference) (*light.Body, error) {
	if s == nil {
		return nil, nil
	}
	switch s.Oneof.(type) {
	case *SchemaOrReference_Reference:
		t := s.GetReference()
		return t.toBody(), nil
	case *SchemaOrReference_Schema:
		return s.GetSchema().toHCL()
	default: // we ignore all other types, meaning we have to assign type Schema when parsing Components.Schemas
	}
	return nil, nil
}
