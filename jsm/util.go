package jsm

import (
	"log"
	"strings"

	"github.com/genelet/hcllight/light"
	"gopkg.in/yaml.v3"
)

func stringToTextValueExpr(s string) *light.Expression {
	if s == "" {
		return nil
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Texpr{
			Texpr: &light.TemplateExpr{
				Parts: []*light.Expression{stringToLiteralValueExpr(s)},
			},
		},
	}
}

func stringToLiteralValueExpr(s string) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_StringValue{
						StringValue: s,
					},
				},
			},
		},
	}
}

func int64ToLiteralValueExpr(i int64) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_NumberValue{
						NumberValue: float64(i),
					},
				},
			},
		},
	}
}

func doubleToLiteralValueExpr(f float64) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_NumberValue{
						NumberValue: f,
					},
				},
			},
		},
	}
}

func booleanToLiteralValueExpr(b bool) *light.Expression {
	log.Printf("1111 %v", b)
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_BoolValue{
						BoolValue: b,
					},
				},
			},
		},
	}
}

func stringsToTupleConsExpr(items []string) *light.Expression {
	tcexpr := &light.TupleConsExpr{}
	for _, item := range items {
		tcexpr.Exprs = append(tcexpr.Exprs, stringToTextValueExpr(item))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Tcexpr{
			Tcexpr: tcexpr,
		},
	}
}

func stringToTraversal(str string) *light.Expression {
	parts := strings.SplitN(str, "/", -1)
	args := []*light.Traverser{
		{TraverserClause: &light.Traverser_TRoot{
			TRoot: &light.TraverseRoot{Name: parts[0]},
		}},
	}
	if len(parts) > 1 {
		for _, part := range parts[1:] {
			args = append(args, &light.Traverser{
				TraverserClause: &light.Traverser_TAttr{
					TAttr: &light.TraverseAttr{Name: part},
				},
			})
		}
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Stexpr{
			Stexpr: &light.ScopeTraversalExpr{
				Traversal: args,
			},
		},
	}
}

func yamlToBool(y *yaml.Node) (bool, error) {
	if y == nil {
		return false, nil
	}
	var x bool
	err := y.Decode(&x)
	return x, err
}

func yamlToFloat64(y *yaml.Node) (float64, error) {
	if y == nil {
		return 0.0, nil
	}
	var x float64
	err := y.Decode(&x)
	return x, err
}

func yamlToInt64(y *yaml.Node) (int64, error) {
	if y == nil {
		return 0, nil
	}
	var x int64
	err := y.Decode(&x)
	return x, err
}

func yamlToString(y *yaml.Node) (string, error) {
	if y == nil {
		return "", nil
	}
	var x string
	err := y.Decode(&x)
	return x, err
}
