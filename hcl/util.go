package hcl

import (
	"github.com/genelet/hcllight/light"
)

func shortToFcexpr(key string, expr *light.Expression) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: key,
				Args: []*light.Expression{expr},
			},
		},
	}
}

func fcexprToShort(expr *light.Expression) (string, []*light.Expression) {
	if expr == nil {
		return "", nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Fcexpr:
		expr := expr.GetFcexpr()
		return expr.Name, expr.Args
	default:
	}
	return "", nil
}

func stringToTextFcexpr(key, value string) *light.Expression {
	return shortToFcexpr(key, light.StringToTextValueExpr(value))
}

func float64ToLiteralFcexpr(key string, f float64) *light.Expression {
	return shortToFcexpr(key, light.Float64ToLiteralValueExpr(f))
}

func in64ToLiteralFcexpr(key string, i int64) *light.Expression {
	return shortToFcexpr(key, light.Int64ToLiteralValueExpr(i))
}

func booleanToLiteralFcexpr(key string, b bool) *light.Expression {
	return shortToFcexpr(key, light.BooleanToLiteralValueExpr(b))
}
