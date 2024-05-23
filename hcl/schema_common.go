package hcl

import (
	"github.com/genelet/hcllight/light"
)

func defaultTypeToExpression(d *DefaultType) *light.Expression {
	if d == nil {
		return nil
	}
	switch d.Oneof.(type) {
	case *DefaultType_Boolean:
		t := d.GetBoolean()
		return booleanToLiteralValueExpr(t)
	case *DefaultType_Number:
		t := d.GetNumber()
		return float64ToLiteralValueExpr(t)
	case *DefaultType_String_:
		t := d.GetString_()
		return stringToTextValueExpr(t)
	default:
	}
	return nil
}

func defaultTypeToFcexpr(d *DefaultType) *light.Expression {
	if d == nil {
		return nil
	}
	args := []*light.Expression{defaultTypeToExpression(d)}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: "default",
				Args: args,
			},
		},
	}
}

func fcexprToDefaultType(expr *light.Expression) *DefaultType {
	if expr == nil {
		return nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Fcexpr:
		return expressionToDefaultType(expr.GetFcexpr().Args[0])
	default:
	}
	return nil
}

func expressionToDefaultType(e *light.Expression) *DefaultType {
	if e == nil {
		return nil
	}
	switch e.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		t := e.GetLvexpr().GetVal()
		switch t.CtyValueClause.(type) {
		case *light.CtyValue_BoolValue:
			return &DefaultType{
				Oneof: &DefaultType_Boolean{
					Boolean: t.GetBoolValue(),
				},
			}
		case *light.CtyValue_NumberValue:
			return &DefaultType{
				Oneof: &DefaultType_Number{
					Number: t.GetNumberValue(),
				},
			}
		case *light.CtyValue_StringValue:
			return &DefaultType{
				Oneof: &DefaultType_String_{
					String_: t.GetStringValue(),
				},
			}
		default:
		}
	default:
	}
	return nil
}

func enumToTupleConsExpr(enumeration []*Any, typ ...string) (*light.TupleConsExpr, error) {
	if len(enumeration) == 0 {
		return nil, nil
	}

	var enums []*light.Expression
	for _, e := range enumeration {
		expr, err := e.toExpression(typ...)
		if err != nil {
			return nil, err
		}
		enums = append(enums, expr)
	}

	if len(enums) == 0 {
		return nil, nil
	}

	return &light.TupleConsExpr{
		Exprs: enums,
	}, nil
}

func tupleConsExprToEnum(t *light.TupleConsExpr) ([]*Any, error) {
	if t == nil {
		return nil, nil
	}

	var enums []*Any
	for _, e := range t.Exprs {
		item, err := anyFromHCL(e)
		if err != nil {
			return nil, err
		}
		enums = append(enums, item)
	}

	if len(enums) == 0 {
		return nil, nil
	}

	return enums, nil
}

func commonToAttributes(self *SchemaCommon, attrs map[string]*light.Attribute) error {
	if self == nil || attrs == nil {
		return nil
	}

	if self.Type != "" {
		attrs["type"] = &light.Attribute{
			Name: "type",
			Expr: stringToTextValueExpr(self.Type),
		}
	}
	if self.Format != "" {
		attrs["format"] = &light.Attribute{
			Name: "format",
			Expr: stringToTextValueExpr(self.Format),
		}
	}
	if self.Description != "" {
		attrs["description"] = &light.Attribute{
			Name: "description",
			Expr: stringToTextValueExpr(self.Description),
		}
	}
	if self.Default != nil {
		attrs["default"] = &light.Attribute{
			Name: "default",
			Expr: stringToLiteralValueExpr(self.Default.String()),
		}
	}
	if self.Example != nil {
		expr, err := self.Example.toExpression(self.Type)
		if err != nil {
			return err
		}
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: expr,
		}
	}
	if self.Enum != nil {
		expr, err := enumToTupleConsExpr(self.Enum, self.Type)
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

func attributesToCommon(attrs map[string]*light.Attribute) (*SchemaCommon, error) {
	if attrs == nil {
		return nil, nil
	}

	var found bool
	var err error
	common := &SchemaCommon{}
	if v, ok := attrs["type"]; ok {
		common.Type = *textValueExprToString(v.Expr)
		found = true
	}
	if v, ok := attrs["format"]; ok {
		common.Format = *textValueExprToString(v.Expr)
		found = true
	}
	if v, ok := attrs["description"]; ok {
		common.Description = *textValueExprToString(v.Expr)
		found = true
	}
	if v, ok := attrs["default"]; ok {
		common.Default = expressionToDefaultType(v.Expr)
		found = true
	}
	if v, ok := attrs["example"]; ok {
		common.Example, err = anyFromHCL(v.Expr)
		if err != nil {
			return nil, err
		}
		found = true
	}
	if v, ok := attrs["enum"]; ok {
		enums, err := tupleConsExprToEnum(v.Expr.GetTcexpr())
		if err != nil {
			return nil, err
		}
		common.Enum = enums
		found = true
	}

	if found {
		return common, nil
	}
	return nil, nil
}

func commonToFcexpr(self *SchemaCommon) (*light.FunctionCallExpr, error) {
	typ := self.Type
	fnc := &light.FunctionCallExpr{
		Name: typ,
	}
	if self.Format != "" {
		fnc.Args = append(fnc.Args, stringToTextFcexpr("format", self.Format))
	}
	if self.Description != "" {
		fnc.Args = append(fnc.Args, stringToTextFcexpr("description", self.Description))
	}
	if self.Default != nil {
		fnc.Args = append(fnc.Args, defaultTypeToFcexpr(self.Default))
	}
	if self.Example != nil {
		expr, err := self.Example.toFcexpr(self.Type)
		if err != nil {
			return nil, err
		}
		fnc.Args = append(fnc.Args, expr)
	}
	if self.Enum != nil {
		expr, err := enumToTupleConsExpr(self.Enum, self.Type)
		if err != nil {
			return nil, err
		} else if expr != nil {
			fnc.Args = append(fnc.Args, &light.Expression{
				ExpressionClause: &light.Expression_Fcexpr{
					Fcexpr: &light.FunctionCallExpr{
						Name: "enum",
						Args: expr.Exprs,
					},
				},
			})
		}
	}
	return fnc, nil
}

func fcexprToCommon(fcexpr *light.FunctionCallExpr) (*SchemaCommon, error) {
	if fcexpr == nil {
		return nil, nil
	}

	common := &SchemaCommon{
		Type: fcexpr.Name,
	}

	found := false
	var err error
	for _, arg := range fcexpr.Args {
		switch arg.ExpressionClause.(type) {
		case *light.Expression_Fcexpr:
			name, items := fcexprToShort(arg)
			switch name {
			case "format":
				common.Format = *literalValueExprToString(items[0])
				found = true
			case "description":
				common.Description = *literalValueExprToString(items[0])
				found = true
			case "default":
				common.Default = expressionToDefaultType(items[0])
				found = true
			case "example":
				common.Example, err = anyFromHCL(items[0])
				if err != nil {
					return nil, err
				}
				found = true
			case "enum":
				enum, err := tupleConsExprToEnum(&light.TupleConsExpr{
					Exprs: items,
				})
				if err != nil {
					return nil, err
				}
				common.Enum = enum
				found = true
			default:
			}
		default:
		}
	}

	if found {
		return common, nil
	}
	return nil, nil
}
