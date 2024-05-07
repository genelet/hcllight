package jsm

import (
	"fmt"

	"github.com/genelet/hcllight/light"
)

func (self *Common) toAttributes(attrs map[string]*light.Attribute) error {
	if self.Type != nil {
		if self.Type.String != nil {
			attrs["type"] = &light.Attribute{
				Name: "type",
				Expr: stringToTextValueExpr(*self.Type.String),
			}
		} else {
			attrs["type"] = &light.Attribute{
				Name: "type",
				Expr: stringsToTupleConsExpr(*self.Type.StringArray),
			}
		}
	}
	if self.Format != nil {
		attrs["format"] = &light.Attribute{
			Name: "format",
			Expr: stringToTextValueExpr(*self.Format),
		}
	}
	if self.Default != nil {
		attrs["default"] = &light.Attribute{
			Name: "default",
			Expr: stringToLiteralValueExpr(self.Default.Value),
		}
	}
	if self.Enumeration != nil {
		expr, err := enumToTupleConsExpr(self.Enumeration)
		if err != nil {
			return err
		}
		attrs["enum"] = &light.Attribute{
			Name: "enum",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: expr,
				},
			},
		}
	}
	return nil
}

func (self *SchemaNumber) toAttributes(attrs map[string]*light.Attribute) error {
	if self.Minimum != nil {
		attrs["minimum"] = &light.Attribute{
			Name: "minimum",
			Expr: doubleToLiteralValueExpr(*self.Minimum.Float),
		}
	}
	if self.Maximum != nil {
		attrs["maximum"] = &light.Attribute{
			Name: "maximum",
			Expr: doubleToLiteralValueExpr(*self.Maximum.Float),
		}
	}
	if self.ExclusiveMinimum != nil {
		attrs["exclusiveMinimum"] = &light.Attribute{
			Name: "exclusiveMinimum",
			Expr: booleanToLiteralValueExpr(*self.ExclusiveMinimum),
		}
	}
	if self.ExclusiveMaximum != nil {
		attrs["exclusiveMaximum"] = &light.Attribute{
			Name: "exclusiveMaximum",
			Expr: booleanToLiteralValueExpr(*self.ExclusiveMaximum),
		}
	}
	if self.MultipleOf != nil {
		attrs["multipleOf"] = &light.Attribute{
			Name: "multipleOf",
			Expr: doubleToLiteralValueExpr(*self.MultipleOf.Float),
		}
	}
	return nil
}

func (self *SchemaInteger) toAttributes(attrs map[string]*light.Attribute) error {
	if self.Minimum != nil {
		attrs["minimum"] = &light.Attribute{
			Name: "minimum",
			Expr: int64ToLiteralValueExpr(*self.Minimum),
		}
	}
	if self.Maximum != nil {
		attrs["maximum"] = &light.Attribute{
			Name: "maximum",
			Expr: int64ToLiteralValueExpr(*self.Maximum),
		}
	}
	if self.ExclusiveMinimum != nil {
		attrs["exclusiveMinimum"] = &light.Attribute{
			Name: "exclusiveMinimum",
			Expr: booleanToLiteralValueExpr(*self.ExclusiveMinimum),
		}
	}
	if self.ExclusiveMaximum != nil {
		attrs["exclusiveMaximum"] = &light.Attribute{
			Name: "exclusiveMaximum",
			Expr: booleanToLiteralValueExpr(*self.ExclusiveMaximum),
		}
	}
	if self.MultipleOf != nil {
		attrs["multipleOf"] = &light.Attribute{
			Name: "multipleOf",
			Expr: int64ToLiteralValueExpr(*self.MultipleOf),
		}
	}
	return nil
}

func (self *SchemaString) toAttributes(attrs map[string]*light.Attribute) error {
	if self.MaxLength != nil {
		attrs["maxLength"] = &light.Attribute{
			Name: "maxLength",
			Expr: int64ToLiteralValueExpr(*self.MaxLength),
		}
	}
	if self.MinLength != nil {
		attrs["minLength"] = &light.Attribute{
			Name: "minLength",
			Expr: int64ToLiteralValueExpr(*self.MinLength),
		}
	}
	if self.Pattern != nil {
		attrs["pattern"] = &light.Attribute{
			Name: "pattern",
			Expr: stringToTextValueExpr(*self.Pattern),
		}
	}
	return nil
}

func (self *SchemaArray) toAttributes(attrs map[string]*light.Attribute) error {
	if self.MaxItems != nil {
		attrs["maxItems"] = &light.Attribute{
			Name: "maxItems",
			Expr: int64ToLiteralValueExpr(*self.MaxItems),
		}
	}
	if self.MinItems != nil {
		attrs["minItems"] = &light.Attribute{
			Name: "minItems",
			Expr: int64ToLiteralValueExpr(*self.MinItems),
		}
	}
	if self.UniqueItems != nil {
		attrs["uniqueItems"] = &light.Attribute{
			Name: "uniqueItems",
			Expr: booleanToLiteralValueExpr(*self.UniqueItems),
		}
	}
	if self.Items != nil {
		expr, err := itemsToExpression(self.Items)
		if err != nil {
			return err
		}
		attrs["items"] = &light.Attribute{
			Name: "items",
			Expr: expr,
		}
	}
	return nil
}

func (self *SchemaObject) toAttributes(attrs map[string]*light.Attribute) error {
	if self.MaxProperties != nil {
		attrs["maxProperties"] = &light.Attribute{
			Name: "maxProperties",
			Expr: int64ToLiteralValueExpr(*self.MaxProperties),
		}
	}
	if self.MinProperties != nil {
		attrs["minProperties"] = &light.Attribute{
			Name: "minProperties",
			Expr: int64ToLiteralValueExpr(*self.MinProperties),
		}
	}
	if self.Required != nil {
		attrs["required"] = &light.Attribute{
			Name: "required",
			Expr: stringsToTupleConsExpr(self.Required),
		}
	}
	if self.Properties != nil {
		hash, err := mapToObjectConsExpr(self.Properties)
		if err != nil {
			return err
		}
		attrs["properties"] = &light.Attribute{
			Name: "properties",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Ocexpr{
					Ocexpr: hash,
				},
			},
		}
	}
	return nil
}

func (self *SchemaMap) toAttributes(attrs map[string]*light.Attribute) error {
	if self.AdditionalProperties != nil {
		if self.AdditionalProperties.Schema != nil {
			ex, err := self.AdditionalProperties.Schema.toExpression()
			if err != nil {
				return err
			}
			attrs["additionalProperties"] = &light.Attribute{
				Name: "additionalProperties",
				Expr: ex,
			}
		} else {
			attrs["additionalProperties"] = &light.Attribute{
				Name: "additionalProperties",
				Expr: booleanToLiteralValueExpr(*self.AdditionalProperties.Boolean),
			}
		}
	}
	return nil
}

func (self *Reference) toExpression() (*light.Expression, error) {
	if self == nil {
		return nil, nil
	}
	if *self.Ref != "#/" {
		return nil, fmt.Errorf("invalid reference: %s", *self.Ref)
	}
	return stringToTraversal((*self.Ref)[:2]), nil
}

func (self *Schema) toBoolExpression() (*light.Expression, error) {
	if self.Common == nil {
		return nil, nil
	}

	expr, err := self.Common.toBoolFcexpr()
	if err != nil {
		return nil, err
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: expr,
		},
	}, nil
}

// because of order in function, we can't loop attribute map
func (self *SchemaNumber) toNumberExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
	if self.Minimum != nil {
		expr.Args = append(expr.Args, doubleToLiteralValueExpr(*self.Minimum.Float))
	}
	if self.Maximum != nil {
		expr.Args = append(expr.Args, doubleToLiteralValueExpr(*self.Maximum.Float))
	}
	if self.ExclusiveMinimum != nil {
		expr.Args = append(expr.Args, booleanToLiteralValueExpr(*self.ExclusiveMinimum))
	}
	if self.ExclusiveMaximum != nil {
		expr.Args = append(expr.Args, booleanToLiteralValueExpr(*self.ExclusiveMaximum))
	}
	if self.MultipleOf != nil {
		expr.Args = append(expr.Args, doubleToLiteralValueExpr(*self.MultipleOf.Float))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: expr,
		},
	}, nil
}

func (self *SchemaInteger) toIntegerExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
	if self.Minimum != nil {
		expr.Args = append(expr.Args, int64ToLiteralValueExpr(*self.Minimum))
	}
	if self.Maximum != nil {
		expr.Args = append(expr.Args, int64ToLiteralValueExpr(*self.Maximum))
	}
	if self.ExclusiveMinimum != nil {
		expr.Args = append(expr.Args, booleanToLiteralValueExpr(*self.ExclusiveMinimum))
	}
	if self.ExclusiveMaximum != nil {
		expr.Args = append(expr.Args, booleanToLiteralValueExpr(*self.ExclusiveMaximum))
	}
	if self.MultipleOf != nil {
		expr.Args = append(expr.Args, int64ToLiteralValueExpr(*self.MultipleOf))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: expr,
		},
	}, nil
}

func (self *SchemaString) toStringExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
	if self.MaxLength != nil {
		expr.Args = append(expr.Args, int64ToLiteralValueExpr(*self.MaxLength))
	}
	if self.MinLength != nil {
		expr.Args = append(expr.Args, int64ToLiteralValueExpr(*self.MinLength))
	}
	if self.Pattern != nil {
		expr.Args = append(expr.Args, stringToTextValueExpr(*self.Pattern))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: expr,
		},
	}, nil
}

func (self *SchemaArray) toArrayExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
	if self.Items != nil {
		ex, err := itemsToExpression(self.Items)
		if err != nil {
			return nil, err
		}
		expr.Args = append(expr.Args, ex)
	}

	if self.MaxItems != nil {
		expr.Args = append(expr.Args, int64ToLiteralValueExpr(*self.MaxItems))
	}
	if self.MinItems != nil {
		expr.Args = append(expr.Args, int64ToLiteralValueExpr(*self.MinItems))
	}
	if self.UniqueItems != nil {
		expr.Args = append(expr.Args, booleanToLiteralValueExpr(*self.UniqueItems))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: expr,
		},
	}, nil
}

func (self *SchemaObject) toObjectExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
	if self.Properties != nil {
		ex, err := mapToObjectConsExpr(self.Properties)
		if err != nil {
			return nil, err
		}
		expr.Args = append(expr.Args, &light.Expression{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: ex,
			},
		})
	}

	if self.MaxProperties != nil {
		expr.Args = append(expr.Args, int64ToLiteralValueExpr(*self.MaxProperties))
	}
	if self.MinProperties != nil {
		expr.Args = append(expr.Args, int64ToLiteralValueExpr(*self.MinProperties))
	}
	if self.Required != nil {
		expr.Args = append(expr.Args, stringsToTupleConsExpr(self.Required))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: expr,
		},
	}, nil
}

func (self *SchemaMap) toMapExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
	if self.AdditionalProperties != nil {
		if self.AdditionalProperties.Schema != nil {
			ex, err := self.AdditionalProperties.Schema.toExpression()
			if err != nil {
				return nil, err
			}
			expr.Args = append(expr.Args, ex)
		} else {
			expr.Args = append(expr.Args, booleanToLiteralValueExpr(*self.AdditionalProperties.Boolean))
		}
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: expr,
		},
	}, nil
}

func (self *SchemaFull) toBody() (*light.Body, error) {
	body := &light.Body{}
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)

	if self.Common != nil {
		if err := self.Common.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.SchemaNumber != nil {
		if err := self.SchemaNumber.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.SchemaString != nil {
		if err := self.SchemaString.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.SchemaArray != nil {
		if err := self.SchemaArray.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.SchemaObject != nil {
		if err := self.SchemaObject.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.SchemaMap != nil {
		if err := self.SchemaMap.toAttributes(attrs); err != nil {
			return nil, err
		}
	}
	if self.Reference != nil {
		if ex, err := self.Reference.toExpression(); err != nil {
			return nil, err
		} else {
			attrs["$ref"] = ex
		}
	}

	return body, nil

}
