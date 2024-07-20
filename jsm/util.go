package jsm

import (
	"fmt"
	"strings"

	"github.com/genelet/hcllight/light"
)

func referenceToExpression(ref string) (*light.Expression, error) {
	arr := strings.Split(ref, "#/")
	if len(arr) != 2 {
		return nil, fmt.Errorf("invalid reference: %s", ref)
	}
	return light.StringToTraversal(arr[1]), nil
}

func expressionToReference(expr *light.Expression) (string, error) {
	// in case there is only one level of reference which is parsed as lvexpr
	if x := expr.GetLvexpr(); x != nil {
		return "#/" + x.Val.GetStringValue(), nil
	} else if x := light.TraversalToString(expr); x != nil {
		return "#/" + *x, nil
	}
	return "", fmt.Errorf("1 invalid expression: %#v", expr)
}

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
	return shortToExpr(key, light.StringToTextValueExpr(value))
}

func exprToTextString(expr *light.Expression) (string, error) {
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
	return "", fmt.Errorf("2 invalid expression: %#v", expr)
}

func stringToLiteralExpr(key, value string) *light.Expression {
	return shortToExpr(key, light.StringToLiteralValueExpr(value))
}

func float64ToLiteralExpr(key string, f float64) *light.Expression {
	return shortToExpr(key, light.Float64ToLiteralValueExpr(f))
}

func exprToFloat64(expr *light.Expression) (float64, error) {
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
	return shortToExpr(key, light.Int64ToLiteralValueExpr(i))
}

func exprToInt64(expr *light.Expression) (int64, error) {
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
	return shortToExpr(key, light.BooleanToLiteralValueExpr(b))
}

func exprToBoolean(expr *light.Expression) (bool, error) {
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
