package hcl

import (
	"github.com/genelet/hcllight/light"
)

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
		tcexpr.Exprs = append(tcexpr.Exprs, stringToLiteralValueExpr(item))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Tcexpr{
			Tcexpr: tcexpr,
		},
	}
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
