package openhcl

import (
	"github.com/genelet/hcllight/generated"
	"github.com/genelet/hcllight/internal/hcl"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
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

func itemsToTupleConsExpr(items []SchemaOrReference) *generated.Expression {
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

func hashToObjectConsExpr(hash map[string]SchemaOrReference) *generated.Expression {
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

/*
func (self *SchemaOrReference) MarshalHCL() ([]byte, error) {
	s := self.X
	if s == nil {
		return nil, nil
	}
	switch s.(type) {
	case *hcl.Schema:
		return dethcl.Marshal(s)
	default:
	}
	expr := exprSchemaOrReference(self)
	return dethcl.Marshal(expr)
}
*/

func exprSchemaOrReference(s SchemaOrReference) *generated.Expression {
	if s == nil {
		return nil
	}

	var name string
	var args []*generated.Expression

	switch t := s.(type) {
	case *hcl.Reference:
		name = "reference"
		args = []*generated.Expression{stringToLiteralValueExpr(t.XRef)}
		if t.Summary != "" {
			args = append(args, stringToLiteralValueExpr(t.Summary))
		}
		if t.Description != "" {
			args = append(args, stringToLiteralValueExpr(t.Description))
		}
	case *hcl.Schema:
		return nil
	case *OASArray:
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
	case *OASMap:
		name = "map"
		ap := t.AdditionalProperties
		if ap != nil {
			switch x := ap.(type) {
			case SchemaOrReference:
				args = append(args, exprSchemaOrReference(x))
			case bool:
				if x {
					args = append(args, booleanToLiteralValueExpr(x))
				}
			default:
				panic("no a datatype")
			}
		}
	case *OASObject:
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
	case *hcl.OASString:
		name = t.Type
		args = append(args, stringToLiteralValueExpr(t.Format))
		if t.MinLength != 0 || t.MaxLength != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MinLength))
			args = append(args, int64ToLiteralValueExpr(t.MaxLength))
		}
		if t.Pattern != "" {
			args = append(args, stringToLiteralValueExpr(t.Pattern))
		}
	case *hcl.OASNumber:
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
	case *hcl.OASInteger:
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
	case *hcl.OASBoolean:
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

func exprSchema(v *openapiv3.Schema) *generated.Expression {
	switch v.Type {
	case "string", "number", "integer", "boolean":
		fcexpr := &generated.FunctionCallExpr{Name: v.Type}
		if v.Format != "" {
			fcexpr.Args = append(fcexpr.Args, stringToLiteralValueExpr(v.Format))
		}
		return &generated.Expression{
			ExpressionClause: &generated.Expression_Fcexpr{
				Fcexpr: fcexpr,
			},
		}
	case "array":
		tcexpr := &generated.TupleConsExpr{}
		for _, item := range v.Items.SchemaOrReference {
			expr := exprSchemaOrReference(item)
			tcexpr.Exprs = append(tcexpr.Exprs, expr)
		}
		return &generated.Expression{
			ExpressionClause: &generated.Expression_Tcexpr{
				Tcexpr: tcexpr,
			},
		}
	default:
	}

	if v.Properties != nil {
		ocexpr := &generated.ObjectConsExpr{}
		var items []*generated.ObjectConsItem
		for _, item := range v.Properties.AdditionalProperties {
			expr := exprSchemaOrReference(item.Value)
			items = append(items, &generated.ObjectConsItem{
				KeyExpr:   stringToLiteralValueExpr(item.Name),
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

	if v.AdditionalProperties != nil {
		if x := v.AdditionalProperties.GetSchemaOrReference(); x != nil {
			return exprSchemaOrReference(x)
		}
	}

	return nil
}
