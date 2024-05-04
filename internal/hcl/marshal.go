package hcl

import (
	"github.com/genelet/hcllight/generated"
)

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

func int64ToLiteralValueExpr(i int64) *generated.Expression {
	return &generated.Expression{
		ExpressionClause: &generated.Expression_Lvexpr{
			Lvexpr: &generated.LiteralValueExpr{
				Val: &generated.CtyValue{
					CtyValueClause: &generated.CtyValue_NumberValue{
						NumberValue: float64(i),
					},
				},
			},
		},
	}
}

func doubleToLiteralValueExpr(f float64) *generated.Expression {
	return &generated.Expression{
		ExpressionClause: &generated.Expression_Lvexpr{
			Lvexpr: &generated.LiteralValueExpr{
				Val: &generated.CtyValue{
					CtyValueClause: &generated.CtyValue_NumberValue{
						NumberValue: f,
					},
				},
			},
		},
	}
}

func booleanToLiteralValueExpr(b bool) *generated.Expression {
	return &generated.Expression{
		ExpressionClause: &generated.Expression_Lvexpr{
			Lvexpr: &generated.LiteralValueExpr{
				Val: &generated.CtyValue{
					CtyValueClause: &generated.CtyValue_BoolValue{
						BoolValue: b,
					},
				},
			},
		},
	}
}

func stringsToTupleConsExpr(items []string) *generated.Expression {
	tcexpr := &generated.TupleConsExpr{}
	for _, item := range items {
		tcexpr.Exprs = append(tcexpr.Exprs, stringToLiteralValueExpr(item))
	}
	return &generated.Expression{
		ExpressionClause: &generated.Expression_Tcexpr{
			Tcexpr: tcexpr,
		},
	}
}

func itemsToTupleConsExpr(items []*SchemaOrReference) *generated.Expression {
	tcexpr := &generated.TupleConsExpr{}
	for _, item := range items {
		expr := exprSchemaOrReference(item)
		tcexpr.Exprs = append(tcexpr.Exprs, expr)
	}
	return &generated.Expression{
		ExpressionClause: &generated.Expression_Tcexpr{
			Tcexpr: tcexpr,
		},
	}
}

func hashToObjectConsExpr(hash map[string]*SchemaOrReference) *generated.Expression {
	ocexpr := &generated.ObjectConsExpr{}
	var items []*generated.ObjectConsItem
	for name, item := range hash {
		expr := exprSchemaOrReference(item)
		items = append(items, &generated.ObjectConsItem{
			KeyExpr:   stringToLiteralValueExpr(name),
			ValueExpr: expr,
		})
	}
	ocexpr.Items = items
	return &generated.Expression{
		ExpressionClause: &generated.Expression_Ocexpr{
			Ocexpr: ocexpr,
		},
	}
}

func exprSchemaOrReference(s *SchemaOrReference) *generated.Expression {
	if s == nil {
		return nil
	}

	var name string
	var args []*generated.Expression

	switch s.Oneof.(type) {
	case *SchemaOrReference_Reference:
		t := s.GetReference()
		name = "reference"
		args = []*generated.Expression{stringToLiteralValueExpr(t.XRef)}
		if t.Summary != "" {
			args = append(args, stringToLiteralValueExpr(t.Summary))
		}
		if t.Description != "" {
			args = append(args, stringToLiteralValueExpr(t.Description))
		}
	case *SchemaOrReference_Schema:
		t := s.GetSchema()
		return exprSchema(t)
	case *SchemaOrReference_Array:
		t := s.GetArray()
		name = t.Type
		items := itemsToTupleConsExpr(t.Items)
		args = []*generated.Expression{items}
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
		args = []*generated.Expression{properties}
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
	default:
	}

	return &generated.Expression{
		ExpressionClause: &generated.Expression_Fcexpr{
			Fcexpr: &generated.FunctionCallExpr{
				Name: name,
				Args: args,
			},
		},
	}
}

func exprSchema(schema *Schema) *generated.Expression {
	if schema == nil {
		return nil
	}
	s := &Schema{
		Nullable: schema.Nullable,
	}
	return s
}
