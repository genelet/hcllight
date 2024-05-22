package hcl

import (
	"fmt"

	"github.com/genelet/hcllight/light"
)

var ErrInvalidType = func() error {
	return fmt.Errorf("%s", "invalid type")
}

type AbleHCL interface {
	toHCL() (*light.Body, error)
}

func ableToTupleConsExpr(items []AbleHCL) (*light.Expression, error) {
	tcexpr := &light.TupleConsExpr{}
	for _, item := range items {
		body, err := item.toHCL()
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

	var items []AbleHCL
	for _, expr := range exprs {
		item, err := fromHCL(expr.GetOcexpr())
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, nil
}

func ableMapToBlocks(hash map[string]AbleHCL, label string) ([]*light.Block, error) {
	if hash == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range hash {
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

/*
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
*/
/*
type OrHCL interface {
	toExpression() (*light.Expression, error)
}

func orMapToBody(hash map[string]OrHCL, label string) (*light.Body, error) {
	if hash == nil {
		return nil, nil
	}

	blocks := make([]*light.Block, 0)
	attrs := make(map[string]*light.Attribute)
	for k, v := range hash {
		expr, err := v.toExpression()
		if err != nil {
			return nil, err
		}
		switch expr.ExpressionClause.(type) {
		case *light.Expression_Stexpr:
			attrs[k] = &light.Attribute{
				Name:  k,
				Value: expr,
		blocks = append(blocks, &light.Block{
			Type:   label,
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}
*/
