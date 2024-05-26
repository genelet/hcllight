package hcl

import (
	"strings"

	"github.com/genelet/hcllight/light"
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

func textValueExprToString(t *light.Expression) *string {
	if t == nil {
		return nil
	}
	if t.GetTexpr() == nil {
		return nil
	}
	parts := t.GetTexpr().Parts
	if len(parts) == 0 {
		return nil
	}
	if parts[0].GetLvexpr() == nil {
		return nil
	}
	return literalValueExprToString(parts[0])
}

func stringToLiteralValueExpr(s string) *light.Expression {
	s = strings.TrimSpace(s)
	s = strings.Trim(s, "\"")                // people sometimes double quote strings in JSON
	//s = strings.ReplaceAll(s, "\n", "\\\\n") // newlines are not accepted in HCL
	s = strings.ReplaceAll(s, "\n", "\\n") // newlines are not accepted in HCL
	s = strings.ReplaceAll(s, `\/`, `/`)     // people sometimes escape slashes in JSON

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

func literalValueExprToString(l *light.Expression) *string {
	if l == nil {
		return nil
	}
	if l.GetLvexpr() == nil {
		return nil
	}
	if l.GetLvexpr().GetVal() == nil {
		return nil
	}
	x := l.GetLvexpr().GetVal().GetStringValue()
	return &x
}

func keyValueExprToString(l *light.Expression) *string {
	if l == nil {
		return nil
	}

	switch l.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		return literalValueExprToString(l)
	case *light.Expression_Texpr:
		return textValueExprToString(l)
	case *light.Expression_Ockexpr:
		k := l.GetOckexpr()
		if k.ForceNonLiteral {
		} else {
			switch k.Wrapped.ExpressionClause.(type) {
			case *light.Expression_Texpr:
				return textValueExprToString(k.Wrapped)
			case *light.Expression_Stexpr:
				return traversalToString(k.Wrapped)
			default:
			}
		}
	default:
	}
	return nil
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

func literalValueExprToInt64(l *light.Expression) *int64 {
	if l == nil {
		return nil
	}
	if l.GetLvexpr() == nil {
		return nil
	}
	if l.GetLvexpr().GetVal() == nil {
		return nil
	}
	x := int64(l.GetLvexpr().GetVal().GetNumberValue())
	return &x
}

func float64ToLiteralValueExpr(f float64) *light.Expression {
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

func literalValueExprToFloat64(l *light.Expression) *float64 {
	if l == nil {
		return nil
	}

	switch l.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		if l.GetLvexpr() == nil {
			return nil
		}
		if l.GetLvexpr().GetVal() == nil {
			return nil
		}
		x := l.GetLvexpr().GetVal().GetNumberValue()
		return &x
	case *light.Expression_Uoexpr:
		u := l.GetUoexpr()
		if u.Op.Sign == light.TokenType_Minus {
			y := *literalValueExprToFloat64(u.Val)
			y *= -1
			return &y
		}
		return literalValueExprToFloat64(u.Val)
	default:
	}

	return nil
}

func booleanToLiteralValueExpr(b bool) *light.Expression {
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

func literalValueExprToBoolean(l *light.Expression) *bool {
	if l == nil {
		return nil
	}
	if l.GetLvexpr() == nil {
		return nil
	}
	if l.GetLvexpr().GetVal() == nil {
		return nil
	}
	x := l.GetLvexpr().GetVal().GetBoolValue()
	return &x
}

func stringMapToObjConsExpr(items map[string]string) *light.Expression {
	var args []*light.ObjectConsItem
	for k, v := range items {
		args = append(args, &light.ObjectConsItem{
			KeyExpr:   stringToTextValueExpr(k),
			ValueExpr: stringToTextValueExpr(v),
		})
	}

	return &light.Expression{
		ExpressionClause: &light.Expression_Ocexpr{
			Ocexpr: &light.ObjectConsExpr{
				Items: args,
			},
		},
	}
}

func objConsExprToStringMap(expr *light.Expression) map[string]string {
	if expr == nil {
		return nil
	}

	o := expr.GetOcexpr()
	if o == nil {
		return nil
	}

	items := make(map[string]string)
	for _, item := range o.Items {
		k := *keyValueExprToString(item.KeyExpr)
		v := *textValueExprToString(item.ValueExpr)
		items[k] = v
	}
	return items
}

func stringArrayToTupleConsEpr(items []string) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Tcexpr{
			Tcexpr: &light.TupleConsExpr{
				Exprs: stringArrayToTextValueArray(items),
			},
		},
	}
}

func tupleConsExprToStringArray(expr *light.Expression) []string {
	if expr == nil {
		return nil
	}

	t := expr.GetTcexpr()
	if t == nil {
		return nil
	}
	if len(t.Exprs) == 1 {
		x := t.Exprs[0]
		switch x.ExpressionClause.(type) {
		case *light.Expression_Tcexpr:
			return tupleConsExprToStringArray(x)
		default:
		}
	}

	return textValueArrayToStringArray(t.Exprs)
}

func stringArrayToTextValueArray(items []string) []*light.Expression {
	var exprs []*light.Expression
	for _, item := range items {
		exprs = append(exprs, stringToTextValueExpr(item))
	}
	return exprs
}

func textValueArrayToStringArray(args []*light.Expression) []string {
	if args == nil {
		return nil
	}
	var items []string
	for _, expr := range args {
		switch expr.ExpressionClause.(type) {
		case *light.Expression_Texpr:
			items = append(items, *textValueExprToString(expr))
		case *light.Expression_Lvexpr:
			items = append(items, *literalValueExprToString(expr))
		case *light.Expression_Stexpr:
			items = append(items, *traversalToString(expr))
		default:
		}
	}
	return items
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

func traversalToString(t *light.Expression) *string {
	if t == nil {
		return nil
	}
	if t.GetStexpr() == nil {
		return nil
	}
	traversal := t.GetStexpr().Traversal
	if len(traversal) == 0 {
		return nil
	}
	var parts []string
	for _, part := range traversal {
		switch part.GetTraverserClause().(type) {
		case *light.Traverser_TRoot:
			parts = append(parts, part.GetTRoot().Name)
		case *light.Traverser_TAttr:
			parts = append(parts, part.GetTAttr().Name)
		}
	}
	x := strings.Join(parts, "/")
	return &x
}

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
/*
func referenceToExpression(ref string) (*light.Expression, error) {
	arr := strings.Split(ref, "#/")
	if len(arr) != 2 {
		return nil, fmt.Errorf("invalid reference: %s", ref)
	}
	return stringToTraversal(arr[1]), nil
}

func expressionToReference(expr *light.Expression) (string, error) {
	// in case there is only one level of reference which is parsed as lvexpr
	if x := expr.GetLvexpr(); x != nil {
		return "#/" + x.Val.GetStringValue(), nil
	} else if x := traversalToString(expr); x != nil {
		return "#/" + *x, nil
	}
	return "", fmt.Errorf("1 invalid expression: %#v", expr)
}
*/
