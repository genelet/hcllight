package jsm

import (
	"strings"

	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"
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
	if l.GetLvexpr() == nil {
		return nil
	}
	if l.GetLvexpr().GetVal() == nil {
		return nil
	}
	x := l.GetLvexpr().GetVal().GetNumberValue()
	return &x
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

func stringArrayToTupleConsEpr(items []string) *light.Expression {
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

func tupleConsExprToStringArray(t *light.Expression) []string {
	if t == nil {
		return nil
	}
	if t.GetTcexpr() == nil {
		return nil
	}
	exprs := t.GetTcexpr().Exprs
	if len(exprs) == 0 {
		return nil
	}
	var items []string
	for _, expr := range exprs {
		items = append(items, *textValueExprToString(expr))
	}
	return items
}

func stringOrStringArrayToExpression(t *jsonschema.StringOrStringArray) *light.Expression {
	if t == nil {
		return nil
	}
	if t.String != nil {
		return stringToTextValueExpr(*t.String)
	}
	return stringArrayToTupleConsEpr(*t.StringArray)
}

func expressionToStringOrStringArray(expr *light.Expression) *jsonschema.StringOrStringArray {
	if expr == nil {
		return nil
	}
	if expr.GetLvexpr() != nil {
		x := expr.GetLvexpr().Val.GetStringValue()
		return &jsonschema.StringOrStringArray{
			String: &x,
		}
	}
	x := tupleConsExprToStringArray(expr)
	return &jsonschema.StringOrStringArray{
		StringArray: &x,
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
// try to use mapToBody first
func mapSchemaToObjectConsExpr(s map[string]*Schema) (*light.ObjectConsExpr, error) {
	if s == nil {
		return nil, nil
	}
	var items []*light.ObjectConsItem
	for k, v := range s {
		ex, err := schemaToExpression(v)
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

func objectConsExprToMapSchema(o *light.ObjectConsExpr) (map[string]*Schema, error) {
	if o == nil {
		return nil, nil
	}
	m := make(map[string]*Schema)
	for _, item := range o.Items {
		k := literalValueExprToString(item.KeyExpr)
		if k == nil {
			return nil, nil
		}
		v, err := expressionToSchema(item.ValueExpr)
		if err != nil {
			return nil, err
		}
		m[*k] = v
	}
	return m, nil
}

func sliceToTupleConsExpr(allof []*Schema) (*light.TupleConsExpr, error) {
	if allof == nil {
		return nil, nil
	}
	var exprs []*light.Expression
	for _, v := range allof {
		ex, err := schemaToExpression(v)
		if err != nil {
			return nil, err
		}
		exprs = append(exprs, ex)
	}
	return &light.TupleConsExpr{
		Exprs: exprs,
	}, nil
}

func tupleConsExprToSlice(t *light.TupleConsExpr) ([]*Schema, error) {
	if t == nil {
		return nil, nil
	}
	exprs := t.Exprs
	if len(exprs) == 0 {
		return nil, nil
	}
	var items []*Schema
	for _, expr := range exprs {
		s, err := expressionToSchema(expr)
		if err != nil {
			return nil, err
		}
		items = append(items, s)
	}
	return items, nil
}

func schemaOrSchemaArrayToExpression(items *SchemaOrSchemaArray) (*light.Expression, error) {
	if items.Schema != nil {
		return schemaToExpression(items.Schema)
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

func expressionToSchemaOrSchemaArray(expr *light.Expression) (*SchemaOrSchemaArray, error) {
	if expr.GetTcexpr() != nil {
		items, err := tupleConsExprToSlice(expr.GetTcexpr())
		if err != nil {
			return nil, err
		}
		return &SchemaOrSchemaArray{
			SchemaArray: items,
		}, nil
	} else {
		s, err := expressionToSchema(expr)
		if err != nil {
			return nil, err
		}
		return &SchemaOrSchemaArray{
			Schema: s,
		}, nil
	}
}

func schemaOrBooleanToExpression(items *SchemaOrBoolean) (*light.Expression, error) {
	if items.Schema != nil {
		return schemaToExpression(items.Schema)
	} else {
		return booleanToLiteralValueExpr(*items.Boolean), nil
	}
}

func expressionToSchemaOrBoolean(expr *light.Expression) (*SchemaOrBoolean, error) {
	if expr.GetLvexpr() != nil {
		return &SchemaOrBoolean{
			Boolean: literalValueExprToBoolean(expr),
		}, nil
	} else {
		s, err := expressionToSchema(expr)
		if err != nil {
			return nil, err
		}
		return &SchemaOrBoolean{
			Schema: s,
		}, nil
	}
}

func enumToTupleConsExpr(enumeration []jsonschema.SchemaEnumValue) (*light.TupleConsExpr, error) {
	if len(enumeration) == 0 {
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

	if len(enums) == 0 {
		return nil, nil
	}

	return &light.TupleConsExpr{
		Exprs: enums,
	}, nil
}

func tupleConsExprToEnum(t *light.TupleConsExpr) ([]jsonschema.SchemaEnumValue, error) {
	if t == nil {
		return nil, nil
	}
	exprs := t.Exprs
	if len(exprs) == 0 {
		return nil, nil
	}
	var enums []jsonschema.SchemaEnumValue
	for _, expr := range exprs {
		if expr.GetLvexpr() != nil {
			if expr.GetLvexpr().GetVal().GetStringValue() != "" {
				enums = append(enums, jsonschema.SchemaEnumValue{String: literalValueExprToString(expr)})
			} else {
				enums = append(enums, jsonschema.SchemaEnumValue{Bool: literalValueExprToBoolean(expr)})
			}
		}
	}
	return enums, nil
}

func mapSchemaToBody(s map[string]*Schema) (*light.Body, error) {
	if s == nil {
		return nil, nil
	}

	var body *light.Body
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	for k, v := range s {
		if v.isFull {
			bdy, err := schemaFullToBody(v.SchemaFull)
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type: k,
				Bdy:  bdy,
			})
		} else {
			expr, err := schemaToExpression(v)
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

func bodyToMapSchema(b *light.Body) (map[string]*Schema, error) {
	if b == nil {
		return nil, nil
	}
	m := make(map[string]*Schema)
	for k, v := range b.Attributes {
		s, err := expressionToSchema(v.Expr)
		if err != nil {
			return nil, err
		}
		m[k] = s
	}
	for _, block := range b.Blocks {
		s, err := bodyToSchemaFull(block.Bdy)
		if err != nil {
			return nil, err
		}
		m[block.Type] = &Schema{
			isFull:     true,
			SchemaFull: s,
		}
	}
	return m, nil
}

func mapSchemaOrStringArrayToBody(s map[string]*SchemaOrStringArray) (*light.Body, error) {
	if s == nil {
		return nil, nil
	}

	bdy := &light.Body{}
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	for k, v := range s {
		if v.Schema != nil {
			if v.Schema.isFull {
				bdy, err := schemaFullToBody(v.Schema.SchemaFull)
				if err != nil {
					return nil, err
				}
				blocks = append(blocks, &light.Block{
					Type: k,
					Bdy:  bdy,
				})
			} else {
				expr, err := schemaToExpression(v.Schema)
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
				Expr: stringArrayToTupleConsEpr(v.StringArray),
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

func bodyToMapSchemaOrStringArray(b *light.Body) (map[string]*SchemaOrStringArray, error) {
	if b == nil {
		return nil, nil
	}
	m := make(map[string]*SchemaOrStringArray)
	for k, v := range b.Attributes {
		if v.Expr.GetTcexpr() != nil {
			m[k] = &SchemaOrStringArray{
				StringArray: tupleConsExprToStringArray(v.Expr),
			}
		} else {
			s, err := expressionToSchema(v.Expr)
			if err != nil {
				return nil, err
			}
			m[k] = &SchemaOrStringArray{
				Schema: s,
			}
		}
	}
	for _, block := range b.Blocks {
		s, err := bodyToSchemaFull(block.Bdy)
		if err != nil {
			return nil, err
		}
		m[block.Type] = &SchemaOrStringArray{
			Schema: &Schema{
				isFull:     true,
				SchemaFull: s,
			},
		}
	}
	return m, nil
}
