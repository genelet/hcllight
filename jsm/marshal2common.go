package jsm

import (
	"fmt"

	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"
)

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
