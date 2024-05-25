package hcl

import (
	"fmt"

	"github.com/genelet/hcllight/light"
)

var ErrInvalidType = func(code int, e any) error {
	return fmt.Errorf("code %d: invalid type %v", code, e)
}

type ableHCL interface {
	toHCL() (*light.Body, error)
}

func ableToTupleConsExpr(items []ableHCL) (*light.Expression, error) {
	if items == nil || len(items) == 0 {
		return nil, nil
	}

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

func tupleConsExprToAble(expr *light.Expression, fromHCL func(*light.ObjectConsExpr) (ableHCL, error)) ([]ableHCL, error) {
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

	var items []ableHCL
	for _, expr := range exprs {
		item, err := fromHCL(expr.GetOcexpr())
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}
	return items, nil
}

func ableMapToBlocks(hash map[string]ableHCL, label string) ([]*light.Block, error) {
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

func blocksToAbleMap(blocks []*light.Block, fromHCL func(*light.Body) (ableHCL, error)) (map[string]ableHCL, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]ableHCL)
	for _, block := range blocks {
		able, err := fromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}

func bodyToBlocks(body *light.Body, name ...string) []*light.Block {
	if body == nil {
		return nil
	}

	if name == nil {
		return body.Blocks
	}

	typ := name[0]
	labels := name[1:]

	var blocks []*light.Block
	if body.Attributes != nil && len(body.Attributes) > 0 {
		blocks = append(blocks, &light.Block{
			Type:   typ,
			Labels: labels,
			Bdy: &light.Body{
				Attributes: body.Attributes,
			},
		})
	}
	for _, block := range body.Blocks {
		blocks = append(blocks, &light.Block{
			Type:   typ,
			Labels: append(labels, block.Type),
			Bdy:    block.Bdy,
		})
	}
	return blocks
}

func labelsMatch(labels []string, name ...string) bool {
	if labels == nil && name == nil {
		return true
	}

	if labels == nil || name == nil {
		return false
	}

	if len(labels) != len(name) {
		return false
	}
	for i, l := range labels {
		if l != name[i] {
			return false
		}
	}

	return true
}

func blocksToBody(blocks []*light.Block, name ...string) *light.Body {
	if blocks == nil {
		return nil
	}

	if name == nil {
		return &light.Body{
			Blocks: blocks,
		}
	}

	typ := name[0]
	labels := name[1:]

	var attrs map[string]*light.Attribute
	var blks []*light.Block

	for _, block := range blocks {
		if block.Type != typ {
			continue
		}
		if labelsMatch(block.Labels, labels...) {
			attrs = block.Bdy.Attributes
			continue
		}
		blks = append(blks, &light.Block{
			Type: block.Labels[len(block.Labels)-1],
			Bdy:  block.Bdy,
		})
	}
	if attrs == nil && blks == nil {
		return nil
	}

	return &light.Body{
		Attributes: attrs,
		Blocks:     blks,
	}
}

type orHCL interface {
	GetReference() *Reference
	getAble() ableHCL
}

func orMapToBody(hash map[string]orHCL) (*light.Body, error) {
	if hash == nil {
		return nil, nil
	}
	var blocks []*light.Block
	attrs := make(map[string]*light.Attribute)
	for k, v := range hash {
		if x := v.GetReference(); x != nil {
			if x.Summary == "" && x.Description == "" {
				expr, err := xrefToTraversal(x.XRef)
				if err != nil {
					return nil, err
				}
				attrs[k] = &light.Attribute{
					Name: k,
					Expr: expr,
				}
				continue
			} else {
				body, err := x.toHCL()
				if err != nil {
					return nil, err
				}
				blocks = append(blocks, &light.Block{
					Type: k,
					Bdy:  body,
				})
				continue
			}
		}

		bdy, err := v.getAble().toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: k,
			Bdy:  bdy,
		})
	}
	if len(attrs) == 0 && blocks == nil {
		return nil, nil
	}

	return &light.Body{
		Attributes: attrs,
		Blocks:     blocks,
	}, nil
}

func orMapToBlocks(hash map[string]orHCL, labels ...string) ([]*light.Block, error) {
	body, err := orMapToBody(hash)
	if err != nil || body == nil {
		return nil, err
	}

	return bodyToBlocks(body, labels...), nil
}

func bodyToOrMap(body *light.Body, fromReference func(*Reference) orHCL, fromHCL func(*light.Body) (orHCL, error)) (map[string]orHCL, error) {
	if body == nil {
		return nil, nil
	}

	hash := make(map[string]orHCL)
	if body.Attributes != nil {
		for k, v := range body.Attributes {
			str, err := traversalToXref(v.Expr)
			if err != nil {

			}
			hash[k] = fromReference(&Reference{XRef: str})
		}
	}
	for _, block := range body.Blocks {
		k := block.Type
		reference, err := referenceFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		if reference != nil {
			hash[k] = fromReference(reference)
			continue
		}
		able, err := fromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[k] = able
	}

	if len(hash) == 0 {
		return nil, nil
	}
	return hash, nil
}

func blocksToOrMap(blocks []*light.Block, fromReference func(*Reference) orHCL, fromHCL func(*light.Body) (orHCL, error), labels ...string) (map[string]orHCL, error) {
	body := blocksToBody(blocks, labels...)
	if body == nil {
		return nil, nil
	}

	return bodyToOrMap(body, fromReference, fromHCL)
}
