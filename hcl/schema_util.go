package hcl

import (
	"fmt"

	"github.com/genelet/hcllight/light"
)

func shortToExpr(key string, expr *light.Expression) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: key,
				Args: []*light.Expression{expr},
			},
		},
	}
}

func stringToTextExpr(key, value string) *light.Expression {
	return shortToExpr(key, stringToTextValueExpr(value))
}

func textExprToString(expr *light.Expression) (string, error) {
	if expr == nil {
		return "", nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Texpr:
		return expr.GetTexpr().Parts[0].GetLvexpr().GetVal().GetStringValue(), nil
	case *light.Expression_Lvexpr:
		return expr.GetLvexpr().Val.GetStringValue(), nil
	default:
	}
	return "", ErrInvalidType(expr)
}

func float64ToLiteralExpr(key string, f float64) *light.Expression {
	return shortToExpr(key, float64ToLiteralValueExpr(f))
}

func literalExprToFloat64(expr *light.Expression) (float64, error) {
	if expr == nil {
		return 0, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		return expr.GetLvexpr().Val.GetNumberValue(), nil
	default:
	}
	return 0, fmt.Errorf("4 invalid expression: %#v", expr)
}

func int64ToLiteralExpr(key string, i int64) *light.Expression {
	return shortToExpr(key, int64ToLiteralValueExpr(i))
}

func literalExprToInt64(expr *light.Expression) (int64, error) {
	if expr == nil {
		return 0, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		return int64(expr.GetLvexpr().Val.GetNumberValue()), nil
	default:
	}
	return 0, fmt.Errorf("5 invalid expression: %#v", expr)
}

func booleanToLiteralExpr(key string, b bool) *light.Expression {
	return shortToExpr(key, booleanToLiteralValueExpr(b))
}

func literalExprToBoolean(expr *light.Expression) (bool, error) {
	if expr == nil {
		return false, nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		return expr.GetLvexpr().Val.GetBoolValue(), nil
	default:
	}
	return false, fmt.Errorf("6 invalid expression: %#v", expr)
}
