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

/*
	func stringArrayToFcxpr(key string, values []string) *light.Expression {
		var args []*light.Expression
		for _, value := range values {
			args = append(args, light.StringToTextValueExpr(value))
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
			value := *light.TextValueExprToString(arg)
			values = append(values, value)
		}
		return name, values
	}

	func textFcexprToString(expr *light.Expression) (string, string) {
		name, args := fcexprToShort(expr)
		if name == "" || args == nil {
			return "", ""
		}

		return name, *light.TextValueExprToString(args[0])
	}

	func literalFcexprToFloat64(expr *light.Expression) (string, float64) {
		name, args := fcexprToShort(expr)
		if name == "" || args == nil {
			return "", 0
		}
		return name, *light.LiteralValueExprToFloat64(args[0])
	}

	func literalFcexprToInt64(expr *light.Expression) (string, int64) {
		name, args := fcexprToShort(expr)
		if name == "" || args == nil {
			return "", 0
		}
		return name, *light.LiteralValueExprToInt64(args[0])
	}

func literalFcexprToBoolean(expr *light.Expression) (string, bool) {
	name, args := fcexprToShort(expr)
	if name == "" || args == nil {
		return "", false
	}
	return name, *light.LiteralValueExprToBoolean(args[0])
}
*/

/*
func yamlToBool(y *yaml.Node) (bool, error) {
	if y == nil {
		return false, nil
	}
	var x bool
	err := y.Decode(&x)
	return x, err
}

func boolToYaml(b bool) *yaml.Node {
	return &yaml.Node{
		Kind:  yaml.ScalarNode,
		Tag:   "!!bool",
		Value: strings.ToLower(strconv.FormatBool(b)),
	}
}

func yamlToFloat64(y *yaml.Node) (float64, error) {
	if y == nil {
		return 0.0, nil
	}
	var x float64
	err := y.Decode(&x)
	return x, err
}

func float64ToYaml(f float64) *yaml.Node {
	return &yaml.Node{
		Kind:  yaml.ScalarNode,
		Tag:   "!!float",
		Value: strconv.FormatFloat(f, 'g', -1, 64),
	}
}

func yamlToInt64(y *yaml.Node) (int64, error) {
	if y == nil {
		return 0, nil
	}
	var x int64
	err := y.Decode(&x)
	return x, err
}

func int64ToYaml(i int64) *yaml.Node {
	return &yaml.Node{
		Kind:  yaml.ScalarNode,
		Tag:   "!!int",
		Value: strconv.FormatInt(i, 10),
	}
}

func yamlToString(y *yaml.Node) (string, error) {
	if y == nil {
		return "", nil
	}
	var x string
	err := y.Decode(&x)
	return x, err
}

func stringToYaml(s string) *yaml.Node {
	return &yaml.Node{
		Kind:  yaml.ScalarNode,
		Tag:   "!!str",
		Value: s,
	}
}
*/
