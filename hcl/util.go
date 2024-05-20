package hcl

import (
	"fmt"
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

func anyMapToBody(content map[string]*Any) *light.Body {
	if content == nil {
		return nil
	}
	body := &light.Body{
		Attributes: make(map[string]*light.Attribute),
	}
	for k, v := range content {
		body.Attributes[k] = &light.Attribute{
			Name: k,
			Expr: v.toExpression(),
		}
	}
	return body
}

func bodyToAnyMap(body *light.Body) (map[string]*Any, error) {
	if body == nil {
		return nil, nil
	}
	hash := make(map[string]*Any)
	for k, v := range body.Attributes {
		hash[k] = anyFromHCL(v.Expr)
	}
	return hash, nil
}

type AbleHCL interface {
	toHCL() (*light.Body, error)
}

func ableToTupleConsExpr(tags []AbleHCL) (*light.Expression, error) {
	tcexpr := &light.TupleConsExpr{}
	for _, tag := range tags {
		body, err := tag.toHCL()
		if err != nil {
			return nil, err
		}
		tcexpr.Exprs = append(tcexpr.Exprs, &light.Expression{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: body.ToObjectConsExpr(),
			},
		})
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Tcexpr{
			Tcexpr: tcexpr,
		},
	}, nil
}

func tupleConsExprToAble(expr *light.Expression, fromHCL func(*light.ObjectConsExpr) (AbleHCL, error)) ([]AbleHCL, error) {
	if expr == nil {
		return nil, nil
	}
	if expr.GetTcexpr() == nil {
		return nil, nil
	}
	exprs := expr.GetTcexpr().Exprs
	if len(exprs) == 0 {
		return nil, nil
	}

	var tags []AbleHCL
	for _, expr := range exprs {
		tag, err := fromHCL(expr.GetOcexpr())
		if err != nil {
			return nil, err
		}
		tags = append(tags, tag)
	}
	return tags, nil
}

func tagsToTupleConsExpr(tags []*Tag) (*light.Expression, error) {
	if tags == nil || len(tags) == 0 {
		return nil, nil
	}
	var arr []AbleHCL
	for _, tag := range tags {
		arr = append(arr, tag)
	}
	return ableToTupleConsExpr(arr)
}

var ErrInvalidType = func() error {
	return fmt.Errorf("%s", "invalid type")
}

func expressionToTags(expr *light.Expression) ([]*Tag, error) {
	if expr == nil {
		return nil, nil
	}
	ables, err := tupleConsExprToAble(expr, tagFromHCL)
	if err != nil {
		return nil, err
	}
	var tags []*Tag
	for _, able := range ables {
		tag, ok := able.(*Tag)
		if !ok {
			return nil, ErrInvalidType()
		}
		tags = append(tags, tag)
	}
	return tags, nil
}

func serversToTupleConsExpr(servers []*Server) (*light.Expression, error) {
	if servers == nil || len(servers) == 0 {
		return nil, nil
	}
	var arr []AbleHCL
	for _, server := range servers {
		arr = append(arr, server)
	}
	return ableToTupleConsExpr(arr)
}

func expressionToServers(expr *light.Expression) ([]*Server, error) {
	if expr == nil {
		return nil, nil
	}
	ables, err := tupleConsExprToAble(expr, serverFromHCL)
	if err != nil {
		return nil, err
	}
	var servers []*Server
	for _, able := range ables {
		server, ok := able.(*Server)
		if !ok {
			return nil, ErrInvalidType()
		}
		servers = append(servers, server)
	}
	return servers, nil
}

func securityRequirementToTupleConsExpr(security []*SecurityRequirement) (*light.Expression, error) {
	if security == nil || len(security) == 0 {
		return nil, nil
	}
	var arr []AbleHCL
	for _, item := range security {
		arr = append(arr, item)
	}
	return ableToTupleConsExpr(arr)
}

func expressionToSecurityRequirement(expr *light.Expression) ([]*SecurityRequirement, error) {
	if expr == nil {
		return nil, nil
	}
	ables, err := tupleConsExprToAble(expr, securityRequirementFromHCL)
	if err != nil {
		return nil, err
	}
	var security []*SecurityRequirement
	for _, able := range ables {
		item, ok := able.(*SecurityRequirement)
		if !ok {
			return nil, ErrInvalidType()
		}
		security = append(security, item)
	}
	return security, nil
}

func ableMapToBlocks(encodings map[string]AbleHCL, label string) ([]*light.Block, error) {
	if encodings == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range encodings {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   label,
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}

func blocksToAbleMap(blocks []*light.Block, fromHCL func(*light.Body) (AbleHCL, error)) (map[string]AbleHCL, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for _, block := range blocks {
		able, err := fromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func securitySchemeOrReferenceMapToBlocks(securitySchemes map[string]*SecuritySchemeOrReference) ([]*light.Block, error) {
	if securitySchemes == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range securitySchemes {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "securityScheme")
}

func blocksToSecuritySchemeOrReferenceMap(blocks []*light.Block) (map[string]*SecuritySchemeOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*SecuritySchemeOrReference)
	for _, block := range blocks {
		able, err := securitySchemeFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func encodingMapToBlocks(encodings map[string]*Encoding) ([]*light.Block, error) {
	if encodings == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range encodings {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "encoding")
}

func blocksToEncodingMap(blocks []*light.Block) (map[string]*Encoding, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*Encoding)
	for _, block := range blocks {
		able, err := encodingFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func exampleOrReferenceMapToBlocks(examples map[string]*ExampleOrReference) ([]*light.Block, error) {
	if examples == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range examples {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "example")
}

func blocksToExampleOrReferenceMap(blocks []*light.Block) (map[string]*ExampleOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*ExampleOrReference)
	for _, block := range blocks {
		able, err := exampleFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func headerOrReferenceMapToBlocks(headers map[string]*HeaderOrReference) ([]*light.Block, error) {
	if headers == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range headers {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "header")
}

func blocksToHeaderOrReferenceMap(blocks []*light.Block) (map[string]*HeaderOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*HeaderOrReference)
	for _, block := range blocks {
		able, err := headerFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func linkOrReferenceMapToBlocks(links map[string]*LinkOrReference) ([]*light.Block, error) {
	if links == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range links {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "link")
}

func blocksToLinkOrReferenceMap(blocks []*light.Block) (map[string]*LinkOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*LinkOrReference)
	for _, block := range blocks {
		able, err := linkFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func mediaTypeMapToBlocks(content map[string]*MediaType) ([]*light.Block, error) {
	if content == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range content {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "content")
}

func blocksToMediaTypeMap(blocks []*light.Block) (map[string]*MediaType, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*MediaType)
	for _, block := range blocks {
		able, err := mediaTypeFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func parameterOrReferenceMapToBlocks(parameters map[string]*ParameterOrReference) ([]*light.Block, error) {
	if parameters == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range parameters {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "parameter")
}

func blocksToParameterOrReferenceMap(blocks []*light.Block) (map[string]*ParameterOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*ParameterOrReference)
	for _, block := range blocks {
		able, err := parameterFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func requestBodyOrReferenceMapToBlocks(requestBodies map[string]*RequestBodyOrReference) ([]*light.Block, error) {
	if requestBodies == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range requestBodies {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "requestBody")
}

func blocksToRequestBodyOrReferenceMap(blocks []*light.Block) (map[string]*RequestBodyOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*RequestBodyOrReference)
	for _, block := range blocks {
		able, err := requestBodyFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func responseOrReferenceMapToBlocks(responses map[string]*ResponseOrReference) ([]*light.Block, error) {
	if responses == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range responses {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "response")
}

func blocksToResponseOrReferenceMap(blocks []*light.Block) (map[string]*ResponseOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*ResponseOrReference)
	for _, block := range blocks {
		able, err := responseFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func callbackOrReferenceMapToBlocks(callbacks map[string]*CallbackOrReference) ([]*light.Block, error) {
	if callbacks == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range callbacks {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "callback")
}

func blocksToCallbackOrReferenceMap(blocks []*light.Block) (map[string]*CallbackOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*CallbackOrReference)
	for _, block := range blocks {
		able, err := callbackFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func serverVariableMapToBlocks(serverVariables map[string]*ServerVariable) ([]*light.Block, error) {
	if serverVariables == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range serverVariables {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "serverVariable")
}

func blocksToServerVariableMap(blocks []*light.Block) (map[string]*ServerVariable, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*ServerVariable)
	for _, block := range blocks {
		able, err := serverVariableFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func schemaOrReferenceMapToBlocks(schemas map[string]*SchemaOrReference) ([]*light.Block, error) {
	if schemas == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range schemas {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "schema")
}

func blocksToSchemaOrReferenceMap(blocks []*light.Block) (map[string]*SchemaOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*SchemaOrReference)
	for _, block := range blocks {
		able, err := schemaOrReferenceFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}
