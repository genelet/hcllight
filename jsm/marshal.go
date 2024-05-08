package jsm

import (
	"fmt"

	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"
)

// try to use mapToBody first
func mapToObjectConsExpr(s map[string]*Schema) (*light.ObjectConsExpr, error) {
	if s == nil {
		return nil, nil
	}
	var items []*light.ObjectConsItem
	for k, v := range s {
		ex, err := v.toExpression()
		if err != nil {
			return nil, err
		}
		items = append(items, &light.ObjectConsItem{
			KeyExpr:   stringToLiteralValueExpr(k),
			ValueExpr: ex,
		})
	}
	return &light.ObjectConsExpr{
		Items: items,
	}, nil
}

func mapToBody(s map[string]*Schema) (*light.Body, error) {
	if s == nil {
		return nil, nil
	}

	var body *light.Body
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	for k, v := range s {
		if v.isFull {
			bdy, err := v.SchemaFull.toBody()
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type: k,
				Bdy:  bdy,
			})
		} else {
			expr, err := v.toExpression()
			if err != nil {
				return nil, err
			}
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: expr,
			}
		}
	}

	if len(attrs) > 0 {
		body = &light.Body{
			Attributes: attrs,
		}
	}
	if len(blocks) > 0 {
		if body == nil {
			body = &light.Body{}
		}
		body.Blocks = blocks
	}
	return body, nil
}

func mapSchemaOrStringArrayToMap(s map[string]*SchemaOrStringArray) (*light.Body, error) {
	if s == nil {
		return nil, nil
	}

	bdy := &light.Body{}
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	for k, v := range s {
		if v.Schema != nil {
			if v.Schema.isFull {
				bdy, err := v.Schema.SchemaFull.toBody()
				if err != nil {
					return nil, err
				}
				blocks = append(blocks, &light.Block{
					Type: k,
					Bdy:  bdy,
				})
			} else {
				expr, err := v.Schema.toExpression()
				if err != nil {
					return nil, err
				}
				attrs[k] = &light.Attribute{
					Name: k,
					Expr: expr,
				}
			}
		} else {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringsToTupleConsExpr(v.StringArray),
			}
		}
	}
	if len(attrs) > 0 {
		bdy.Attributes = attrs
	}
	if len(blocks) > 0 {
		bdy.Blocks = blocks
	}
	return bdy, nil
}

func sliceToTupleConsExpr(allof []*Schema) (*light.TupleConsExpr, error) {
	if allof == nil {
		return nil, nil
	}
	var exprs []*light.Expression
	for _, v := range allof {
		ex, err := v.toExpression()
		if err != nil {
			return nil, err
		}
		exprs = append(exprs, ex)
	}
	return &light.TupleConsExpr{
		Exprs: exprs,
	}, nil
}

func itemsToExpression(items *SchemaOrSchemaArray) (*light.Expression, error) {
	if items.Schema != nil {
		return items.Schema.toExpression()
	} else {
		expr, err := sliceToTupleConsExpr(items.SchemaArray)
		if err != nil {
			return nil, err
		}
		return &light.Expression{
			ExpressionClause: &light.Expression_Tcexpr{
				Tcexpr: expr,
			},
		}, nil
	}
}

func enumToTupleConsExpr(enumeration []jsonschema.SchemaEnumValue) (*light.TupleConsExpr, error) {
	if enumeration == nil || len(enumeration) == 0 {
		return nil, nil
	}

	var enums []*light.Expression
	for _, e := range enumeration {
		if e.String != nil {
			enums = append(enums, stringToTextValueExpr(*e.String))
		} else {
			enums = append(enums, booleanToLiteralValueExpr(*e.Bool))
		}
	}

	return &light.TupleConsExpr{
		Exprs: enums,
	}, nil
}

func (self *Common) toBoolFcexpr() (*light.FunctionCallExpr, error) {
	if self.Type == nil && *self.Type.String != "boolean" {
		return nil, fmt.Errorf("invalid type: %#v", self.Type)
	}
	fnc := &light.FunctionCallExpr{
		Name: "bool",
	}
	if self.Default != nil {
		d, err := yamlToBool(self.Default)
		if err != nil {
			return nil, err
		}
		fnc.Args = append(fnc.Args, booleanToLiteralValueExpr(d))
	}
	return fnc, nil
}

func (self *Common) toNumberFcexpr() (*light.FunctionCallExpr, error) {
	if self.Type == nil && *self.Type.String != "number" {
		return nil, fmt.Errorf("invalid type: %#v", self.Type)
	}
	fnc := &light.FunctionCallExpr{
		Name: "number",
	}

	if self.Format != nil {
		fnc.Args = append(fnc.Args, stringToTextValueExpr(*self.Format))
	}

	if self.Default != nil {
		d, err := yamlToFloat64(self.Default)
		if err != nil {
			return nil, err
		}
		fnc.Args = append(fnc.Args, doubleToLiteralValueExpr(d))
	}

	return fnc, nil
}

func (self *Common) toIntegerFcexpr() (*light.FunctionCallExpr, error) {
	if self.Type == nil && *self.Type.String != "integer" {
		return nil, fmt.Errorf("invalid type: %#v", self.Type)
	}
	fnc := &light.FunctionCallExpr{
		Name: "integer",
	}

	if self.Format != nil {
		fnc.Args = append(fnc.Args, stringToTextValueExpr(*self.Format))
	}

	if self.Default != nil {
		d, err := yamlToInt64(self.Default)
		if err != nil {
			return nil, err
		}
		fnc.Args = append(fnc.Args, int64ToLiteralValueExpr(d))
	}

	return fnc, nil
}

func (self *Common) toStringFcexpr() (*light.FunctionCallExpr, error) {
	if self.Type == nil && *self.Type.String != "string" {
		return nil, fmt.Errorf("invalid type: %#v", self.Type)
	}
	fnc := &light.FunctionCallExpr{
		Name: "string",
	}

	if self.Format != nil {
		fnc.Args = append(fnc.Args, stringToTextValueExpr(*self.Format))
	}

	if self.Enumeration != nil {
		expr, err := enumToTupleConsExpr(self.Enumeration)
		if err != nil {
			return nil, err
		}
		fnc.Args = append(fnc.Args, &light.Expression{
			ExpressionClause: &light.Expression_Tcexpr{
				Tcexpr: expr,
			},
		})
	}

	if self.Default != nil {
		d, err := yamlToString(self.Default)
		if err != nil {
			return nil, err
		}
		fnc.Args = append(fnc.Args, stringToTextValueExpr(d))
	}

	return fnc, nil
}

func (self *Common) toArrayFcexpr() (*light.FunctionCallExpr, error) {
	if self.Type == nil && *self.Type.String != "array" {
		return nil, fmt.Errorf("invalid type: %#v", self.Type)
	}
	fnc := &light.FunctionCallExpr{
		Name: "array",
	}

	if self.Default != nil {
		fnc.Args = append(fnc.Args, stringToLiteralValueExpr(self.Default.Value))
	}

	return fnc, nil
}

func (self *Common) toObjectFcexpr() (*light.FunctionCallExpr, error) {
	if self.Type == nil && *self.Type.String != "object" {
		return nil, fmt.Errorf("invalid type: %#v", self.Type)
	}
	fnc := &light.FunctionCallExpr{
		Name: "object",
	}

	if self.Default != nil {
		fnc.Args = append(fnc.Args, stringToLiteralValueExpr(self.Default.Value))
	}

	return fnc, nil
}

func (self *Common) toMapFcexpr() (*light.FunctionCallExpr, error) {
	if self == nil {
		return nil, nil
	}
	if self.Type == nil && *self.Type.String != "map" {
		return nil, fmt.Errorf("invalid type: %#v", self.Type)
	}
	fnc := &light.FunctionCallExpr{
		Name: "map",
	}

	if self.Default != nil {
		fnc.Args = append(fnc.Args, stringToLiteralValueExpr(self.Default.Value))
	}

	return fnc, nil
}

func referenceToExpression(ref string) (*light.Expression, error) {
	if ref != "#/" {
		return nil, fmt.Errorf("invalid reference: %s", ref)
	}
	return stringToTraversal(ref[:2]), nil
}

// this is for bool only
func (self *Common) toExpression() (*light.Expression, error) {
	expr, err := self.toBoolFcexpr()
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
func (self *SchemaNumber) toExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
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

func (self *SchemaInteger) toExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
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

func (self *SchemaString) toExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
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

func (self *SchemaArray) toExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
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

func (self *SchemaObject) toExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
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

func (self *SchemaMap) toExpression(expr *light.FunctionCallExpr) (*light.Expression, error) {
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
