package hcl

import (
	"fmt"

	"github.com/genelet/determined/dethcl"
	"github.com/genelet/hcllight/light"
)

func stringToLiteralValueExpr(s string) *light.Expression {
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

func int64ToLiteralValueExpr(i int64) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_NumberValue{
						NumberValue: float64(i),
					},
				},
			},
		},
	}
}

func doubleToLiteralValueExpr(f float64) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_NumberValue{
						NumberValue: f,
					},
				},
			},
		},
	}
}

func booleanToLiteralValueExpr(b bool) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_BoolValue{
						BoolValue: b,
					},
				},
			},
		},
	}
}

func stringsToTupleConsExpr(items []string) *light.Expression {
	tcexpr := &light.TupleConsExpr{}
	for _, item := range items {
		tcexpr.Exprs = append(tcexpr.Exprs, stringToLiteralValueExpr(item))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Tcexpr{
			Tcexpr: tcexpr,
		},
	}
}

func itemsToTupleConsExpr(items []*SchemaOrReference) *light.Expression {
	tcexpr := &light.TupleConsExpr{}
	for _, item := range items {
		expr := exprSchemaOrReference(item)
		tcexpr.Exprs = append(tcexpr.Exprs, expr)
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Tcexpr{
			Tcexpr: tcexpr,
		},
	}
}

func hashToObjectConsExpr(hash map[string]*SchemaOrReference) *light.Expression {
	ocexpr := &light.ObjectConsExpr{}
	var items []*light.ObjectConsItem
	for name, item := range hash {
		expr := exprSchemaOrReference(item)
		items = append(items, &light.ObjectConsItem{
			KeyExpr:   stringToLiteralValueExpr(name),
			ValueExpr: expr,
		})
	}
	ocexpr.Items = items
	return &light.Expression{
		ExpressionClause: &light.Expression_Ocexpr{
			Ocexpr: ocexpr,
		},
	}
}

func (self *SchemaOrReference) MarshalHCL() ([]byte, error) {
	expr := exprSchemaOrReference(self)
	if expr == nil {
		return nil, nil
	}
	str, err := expr.HclExpression()
	return []byte(str), err
}

func exprSchemaOrReference(s *SchemaOrReference) *light.Expression {
	if s == nil {
		return nil
	}

	var name string
	var args []*light.Expression

	switch s.Oneof.(type) {
	case *SchemaOrReference_Reference:
		t := s.GetReference()
		name = "reference"
		args = []*light.Expression{stringToLiteralValueExpr(t.XRef)}
		if t.Summary != "" {
			args = append(args, stringToLiteralValueExpr(t.Summary))
		}
		if t.Description != "" {
			args = append(args, stringToLiteralValueExpr(t.Description))
		}
	case *SchemaOrReference_Array:
		t := s.GetArray()
		name = t.Type
		items := itemsToTupleConsExpr(t.Items)
		args = []*light.Expression{items}
		if name != "array" {
			break
		}
		if t.MinItems != 0 || t.MaxItems != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MinItems))
			args = append(args, int64ToLiteralValueExpr(t.MaxItems))
		}
		if t.UniqueItems {
			args = append(args, booleanToLiteralValueExpr(t.UniqueItems))
		}
	case *SchemaOrReference_Map:
		t := s.GetMap()
		name = "map"
		ap := t.AdditionalProperties
		if ap != nil {
			switch ap.Oneof.(type) {
			case *AdditionalPropertiesItem_SchemaOrReference:
				x := ap.GetSchemaOrReference()
				args = append(args, exprSchemaOrReference(x))
			case *AdditionalPropertiesItem_Boolean:
				x := ap.GetBoolean()
				if x {
					args = append(args, booleanToLiteralValueExpr(x))
				}

			default:
				panic("no a datatype")
			}
		}
	case *SchemaOrReference_Object:
		t := s.GetObject()
		name = t.Type
		properties := hashToObjectConsExpr(t.Properties)
		args = []*light.Expression{properties}
		if t.MinProperties != 0 || t.MaxProperties != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MinProperties))
			args = append(args, int64ToLiteralValueExpr(t.MaxProperties))
		}
		if t.Required != nil {
			required := stringsToTupleConsExpr(t.Required)
			args = append(args, required)
		}
	case *SchemaOrReference_String_:
		t := s.GetString_()
		name = t.Type
		args = append(args, stringToLiteralValueExpr(t.Format))
		if t.MinLength != 0 || t.MaxLength != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MinLength))
			args = append(args, int64ToLiteralValueExpr(t.MaxLength))
		}
		if t.Pattern != "" {
			args = append(args, stringToLiteralValueExpr(t.Pattern))
		}
	case *SchemaOrReference_Number:
		t := s.GetNumber()
		name = t.Type
		args = append(args, stringToLiteralValueExpr(t.Format))
		if t.Minimum != 0 || t.Maximum != 0 || t.ExclusiveMinimum || t.ExclusiveMaximum {
			args = append(args, doubleToLiteralValueExpr(t.Minimum))
			args = append(args, doubleToLiteralValueExpr(t.Maximum))
			args = append(args, booleanToLiteralValueExpr(t.ExclusiveMinimum))
			args = append(args, booleanToLiteralValueExpr(t.ExclusiveMaximum))
		}
		if t.MultipleOf != 0 {
			args = append(args, doubleToLiteralValueExpr(t.MultipleOf))
		}
	case *SchemaOrReference_Integer:
		t := s.GetInteger()
		name = t.Type
		args = append(args, stringToLiteralValueExpr(t.Format))
		if t.Minimum != 0 || t.Maximum != 0 || t.ExclusiveMinimum || t.ExclusiveMaximum {
			args = append(args, int64ToLiteralValueExpr(t.Minimum))
			args = append(args, int64ToLiteralValueExpr(t.Maximum))
			args = append(args, booleanToLiteralValueExpr(t.ExclusiveMinimum))
			args = append(args, booleanToLiteralValueExpr(t.ExclusiveMaximum))
		}
		if t.MultipleOf != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MultipleOf))
		}
	case *SchemaOrReference_Boolean:
		t := s.GetBoolean()
		name = t.Type
		if t.Default {
			args = append(args, booleanToLiteralValueExpr(t.Default))
		}
	case *SchemaOrReference_Schema:
		expr, err := exprSchema(s.GetSchema())
		if err != nil {
			panic(err)
		}
		fmt.Printf("%#v\n", expr)
		return expr
	default:
	}

	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: name,
				Args: args,
			},
		},
	}
}

func exprSchema(schema *Schema) (*light.Expression, error) {
	if schema == nil {
		return nil, nil
	}
	newSchema := &Schema{
		Nullable:               schema.Nullable,
		Discriminator:          schema.Discriminator,
		ReadOnly:               schema.ReadOnly,
		WriteOnly:              schema.WriteOnly,
		Xml:                    schema.Xml,
		ExternalDocs:           schema.ExternalDocs,
		Example:                schema.Example,
		Deprecated:             schema.Deprecated,
		Title:                  schema.Title,
		MultipleOf:             schema.MultipleOf,
		Maximum:                schema.Maximum,
		ExclusiveMaximum:       schema.ExclusiveMaximum,
		Minimum:                schema.Minimum,
		ExclusiveMinimum:       schema.ExclusiveMinimum,
		MaxLength:              schema.MaxLength,
		MinLength:              schema.MinLength,
		Pattern:                schema.Pattern,
		MaxItems:               schema.MaxItems,
		MinItems:               schema.MinItems,
		UniqueItems:            schema.UniqueItems,
		MaxProperties:          schema.MaxProperties,
		MinProperties:          schema.MinProperties,
		Required:               schema.Required,
		Enum:                   schema.Enum,
		Type:                   schema.Type,
		Default:                schema.Default,
		Description:            schema.Description,
		Format:                 schema.Format,
		SpecificationExtension: schema.SpecificationExtension,
	}
	bs, err := dethcl.Marshal(newSchema)
	if err != nil {
		return nil, err
	}
	body, err := light.Parse(bs)
	if err != nil {
		return nil, err
	}
	if body.Attributes == nil {
		body.Attributes = make(map[string]*light.Attribute)
	}
	if schema.Not != nil {
		expr := exprSchemaOrReference(schema.Not)
		body.Attributes["not"] = &light.Attribute{
			Name: "not",
			Expr: expr,
		}
	}
	if schema.AllOf != nil {
		expr := itemsToTupleConsExpr(schema.AllOf)
		body.Attributes["allOf"] = &light.Attribute{
			Name: "allOf",
			Expr: expr,
		}
	}
	if schema.AnyOf != nil {
		expr := itemsToTupleConsExpr(schema.AnyOf)
		body.Attributes["anyOf"] = &light.Attribute{
			Name: "anyOf",
			Expr: expr,
		}
	}
	if schema.OneOf != nil {
		expr := itemsToTupleConsExpr(schema.OneOf)
		body.Attributes["oneOf"] = &light.Attribute{
			Name: "oneOf",
			Expr: expr,
		}
	}
	if schema.Items != nil {
		expr := itemsToTupleConsExpr(schema.Items)
		body.Attributes["items"] = &light.Attribute{
			Name: "items",
			Expr: expr,
		}
	}
	if schema.Properties != nil {
		expr := hashToObjectConsExpr(schema.Properties)
		body.Blocks = append(body.Blocks, &light.Block{
			Type: "properties",
			Bdy:  expr.GetOcexpr().ToBody(),
		})
	}
	if schema.AdditionalProperties != nil {
		switch schema.AdditionalProperties.Oneof.(type) {
		case *AdditionalPropertiesItem_SchemaOrReference:
			expr := exprSchemaOrReference(schema.AdditionalProperties.GetSchemaOrReference())
			body.Attributes["additionalProperties"] = &light.Attribute{
				Name: "additionalProperties",
				Expr: expr,
			}
		case *AdditionalPropertiesItem_Boolean:
			expr := booleanToLiteralValueExpr(schema.AdditionalProperties.GetBoolean())
			body.Attributes["additionalProperties"] = &light.Attribute{
				Name: "additionalProperties",
				Expr: expr,
			}
		default:
			return nil, fmt.Errorf("%s", "no a datatype")
		}
	}

	return &light.Expression{
		ExpressionClause: &light.Expression_Ocexpr{
			Ocexpr: body.ToObjectConsExpr(),
		},
	}, nil
}
