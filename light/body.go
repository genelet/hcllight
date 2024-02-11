package light

import (
	"fmt"

	"github.com/genelet/hcllight/generated"
	"github.com/genelet/hcllight/internal/ast"
)

func xposTo(end int64) *ast.Pos {
	return &ast.Pos{
		Line:   int64(1),
		Column: end,
	}
}

func xrangeTo(x ...interface{}) *ast.Range {
	end := int64(1)
	if x != nil {
		end += int64(len(fmt.Sprintf("%v", x[0])))
	}
	return &ast.Range{
		Filename: "",
		Start:    xposTo(1),
		End:      xposTo(end),
	}
}

func xblockTo(blk *generated.Block) (*ast.Block, error) {
	if blk == nil {
		return nil, nil
	}

	body, err := xbodyTo(blk.Bdy)
	if err != nil {
		return nil, err
	}

	return &ast.Block{
		Type:            blk.Type,
		Labels:          blk.Labels,
		Bdy:             body,
		TypeRange:       xrangeTo(blk),
		OpenBraceRange:  xrangeTo(blk),
		CloseBraceRange: xrangeTo(blk),
	}, nil
}

func blockTo(blk *ast.Block) (*generated.Block, error) {
	if blk == nil {
		return nil, nil
	}

	body, err := bodyTo(blk.Bdy)
	if err != nil {
		return nil, err
	}

	return &generated.Block{
		Type:   blk.Type,
		Labels: blk.Labels,
		Bdy:    body,
	}, nil
}

func xbodyTo(bdy *generated.Body) (*ast.Body, error) {
	if bdy == nil {
		return nil, nil
	}

	b := &ast.Body{
		SrcRange: xrangeTo(bdy),
		EndRange: xrangeTo(bdy),
	}

	for key, attribute := range bdy.Attributes {
		if b.Attributes == nil {
			b.Attributes = make(map[string]*ast.Attribute)
		}

		attr, err := xattributeTo(attribute)
		if err != nil {
			return nil, err
		}
		b.Attributes[key] = attr
	}

	for _, block := range bdy.Blocks {
		blk, err := xblockTo(block)
		if err != nil {
			return nil, err
		}
		b.Blocks = append(b.Blocks, blk)
	}

	return b, nil
}

func bodyTo(bdy *ast.Body) (*generated.Body, error) {
	if bdy == nil {
		return nil, nil
	}

	b := &generated.Body{}

	for key, attribute := range bdy.Attributes {
		if b.Attributes == nil {
			b.Attributes = make(map[string]*generated.Attribute)
		}

		attr, err := attributeTo(attribute)
		if err != nil {
			return nil, err
		}
		b.Attributes[key] = attr
	}

	for _, block := range bdy.Blocks {
		blk, err := blockTo(block)
		if err != nil {
			return nil, err
		}
		b.Blocks = append(b.Blocks, blk)
	}

	return b, nil
}

func xattributeTo(attr *generated.Attribute) (*ast.Attribute, error) {
	if attr == nil {
		return nil, nil
	}

	expr, err := xexpressionTo(attr.Expr)
	if err != nil {
		return nil, err
	}

	return &ast.Attribute{
		Name:        attr.Name,
		Expr:        expr,
		SrcRange:    xrangeTo(attr),
		NameRange:   xrangeTo(attr),
		EqualsRange: xrangeTo(attr),
	}, nil
}

func attributeTo(attr *ast.Attribute) (*generated.Attribute, error) {
	if attr == nil {
		return nil, nil
	}

	expr, err := expressionTo(attr.Expr)
	if err != nil {
		return nil, err
	}

	return &generated.Attribute{
		Name: attr.Name,
		Expr: expr,
	}, nil
}
