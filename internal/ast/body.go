package ast

import (
	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclsyntax"
)

func xposTo(pos hcl.Pos) *Pos {
	return &Pos{
		Line:   int64(pos.Line),
		Column: int64(pos.Column),
	}
}

func posTo(pos *Pos) hcl.Pos {
	return hcl.Pos{
		Line:   int(pos.Line),
		Column: int(pos.Column),
	}
}

func xrangeTo(rng hcl.Range) *Range {
	return &Range{
		Filename: rng.Filename,
		Start:    xposTo(rng.Start),
		End:      xposTo(rng.End),
	}
}

func rangeTo(rng *Range) hcl.Range {
	return hcl.Range{
		Filename: rng.Filename,
		Start:    posTo(rng.Start),
		End:      posTo(rng.End),
	}
}

func XblockTo(blk *hclsyntax.Block) (*Block, error) {
	if blk == nil {
		return nil, nil
	}

	body, err := XbodyTo(blk.Body)
	if err != nil {
		return nil, err
	}

	return &Block{
		Type:            blk.Type,
		Labels:          blk.Labels,
		Bdy:             body,
		TypeRange:       xrangeTo(blk.TypeRange),
		OpenBraceRange:  xrangeTo(blk.OpenBraceRange),
		CloseBraceRange: xrangeTo(blk.CloseBraceRange),
	}, nil
}

func BlockTo(blk *Block) (*hclsyntax.Block, error) {
	if blk == nil {
		return nil, nil
	}

	body, err := BodyTo(blk.Bdy)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.Block{
		Type:            blk.Type,
		Labels:          blk.Labels,
		Body:            body,
		TypeRange:       rangeTo(blk.TypeRange),
		OpenBraceRange:  rangeTo(blk.OpenBraceRange),
		CloseBraceRange: rangeTo(blk.CloseBraceRange),
	}, nil
}

func XbodyTo(bdy *hclsyntax.Body) (*Body, error) {
	if bdy == nil {
		return nil, nil
	}

	b := &Body{
		SrcRange: xrangeTo(bdy.SrcRange),
		EndRange: xrangeTo(bdy.EndRange),
	}

	for key, attribute := range bdy.Attributes {
		if b.Attributes == nil {
			b.Attributes = make(map[string]*Attribute)
		}

		attr, err := XattributeTo(attribute)
		if err != nil {
			return nil, err
		}
		b.Attributes[key] = attr
	}

	for _, block := range bdy.Blocks {
		blk, err := XblockTo(block)
		if err != nil {
			return nil, err
		}
		b.Blocks = append(b.Blocks, blk)
	}

	return b, nil
}

func BodyTo(bdy *Body) (*hclsyntax.Body, error) {
	if bdy == nil {
		return nil, nil
	}

	b := &hclsyntax.Body{
		SrcRange: rangeTo(bdy.SrcRange),
		EndRange: rangeTo(bdy.EndRange),
	}

	for key, attribute := range bdy.Attributes {
		if b.Attributes == nil {
			b.Attributes = make(map[string]*hclsyntax.Attribute)
		}

		attr, err := AttributeTo(attribute)
		if err != nil {
			return nil, err
		}
		b.Attributes[key] = attr
	}

	for _, block := range bdy.Blocks {
		blk, err := BlockTo(block)
		if err != nil {
			return nil, err
		}
		b.Blocks = append(b.Blocks, blk)
	}

	return b, nil
}

func XattributeTo(attr *hclsyntax.Attribute) (*Attribute, error) {
	if attr == nil {
		return nil, nil
	}

	expr, err := xexpressionTo(attr.Expr)
	if err != nil {
		return nil, err
	}

	return &Attribute{
		Name:        attr.Name,
		Expr:        expr,
		SrcRange:    xrangeTo(attr.SrcRange),
		NameRange:   xrangeTo(attr.NameRange),
		EqualsRange: xrangeTo(attr.EqualsRange),
	}, nil
}

func AttributeTo(attr *Attribute) (*hclsyntax.Attribute, error) {
	if attr == nil {
		return nil, nil
	}

	expr, err := expressionTo(attr.Expr)
	if err != nil {
		return nil, err
	}

	return &hclsyntax.Attribute{
		Name:        attr.Name,
		Expr:        expr,
		SrcRange:    rangeTo(attr.SrcRange),
		NameRange:   rangeTo(attr.NameRange),
		EqualsRange: rangeTo(attr.EqualsRange),
	}, nil
}
