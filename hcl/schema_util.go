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

/*
	func stringArrayToFcxpr(key string, values []string) *light.Expression {
		var args []*light.Expression
		for _, value := range values {
			args = append(args, stringToTextValueExpr(value))
		}
		return &light.Expression{
			ExpressionClause: &light.Expression_Fcexpr{
				Fcexpr: &light.FunctionCallExpr{
					Name: key,
					Args: args,
				},
			},
		}
	}

	func fcexprToStringArray(expr *light.Expression) (string, []string) {
		name, args := fcexprToShort(expr)
		if name == "" || args == nil {
			return "", nil
		}
		var values []string
		for _, arg := range args {
			value := *textValueExprToString(arg)
			values = append(values, value)
		}
		return name, values
	}
*/
func stringToTextFcexpr(key, value string) *light.Expression {
	return shortToFcexpr(key, stringToTextValueExpr(value))
}

/*
	func textFcexprToString(expr *light.Expression) (string, string) {
		name, args := fcexprToShort(expr)
		if name == "" || args == nil {
			return "", ""
		}

		return name, *textValueExprToString(args[0])
	}
*/
func float64ToLiteralFcexpr(key string, f float64) *light.Expression {
	return shortToFcexpr(key, float64ToLiteralValueExpr(f))
}

/*
	func literalFcexprToFloat64(expr *light.Expression) (string, float64) {
		name, args := fcexprToShort(expr)
		if name == "" || args == nil {
			return "", 0
		}
		return name, *literalValueExprToFloat64(args[0])
	}
*/
func in64ToLiteralFcexpr(key string, i int64) *light.Expression {
	return shortToFcexpr(key, int64ToLiteralValueExpr(i))
}

/*
	func literalFcexprToInt64(expr *light.Expression) (string, int64) {
		name, args := fcexprToShort(expr)
		if name == "" || args == nil {
			return "", 0
		}
		return name, *literalValueExprToInt64(args[0])
	}
*/
func booleanToLiteralFcexpr(key string, b bool) *light.Expression {
	return shortToFcexpr(key, booleanToLiteralValueExpr(b))
}

/*
func literalFcexprToBoolean(expr *light.Expression) (string, bool) {
	name, args := fcexprToShort(expr)
	if name == "" || args == nil {
		return "", false
	}
	return name, *literalValueExprToBoolean(args[0])
}
*/
