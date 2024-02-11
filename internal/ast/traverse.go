package ast

import (
	"fmt"

	"github.com/hashicorp/hcl/v2"
)

func xtraverseAttrTo(attr hcl.TraverseAttr) (*TraverseAttr, error) {
	return &TraverseAttr{
		Name:     attr.Name,
		SrcRange: xrangeTo(attr.SrcRange),
	}, nil
}

func traverseAttrTo(attr *TraverseAttr) (hcl.TraverseAttr, error) {
	return hcl.TraverseAttr{
		Name:     attr.Name,
		SrcRange: rangeTo(attr.SrcRange),
	}, nil
}

func xtraverseIndexTo(index hcl.TraverseIndex) (*TraverseIndex, error) {
	key, err := xctyValueTo(index.Key)
	if err != nil {
		return nil, err
	}

	return &TraverseIndex{
		Key:      key,
		SrcRange: xrangeTo(index.SrcRange),
	}, nil
}

func traverseIndexTo(index *TraverseIndex) (hcl.TraverseIndex, error) {
	key, err := CtyValueTo(index.Key)
	if err != nil {
		return hcl.TraverseIndex{}, err
	}

	return hcl.TraverseIndex{
		Key:      key,
		SrcRange: rangeTo(index.SrcRange),
	}, nil
}

func xtraverseRootTo(root hcl.TraverseRoot) (*TraverseRoot, error) {
	return &TraverseRoot{
		Name:     root.Name,
		SrcRange: xrangeTo(root.SrcRange),
	}, nil
}

func traverseRootTo(root *TraverseRoot) (hcl.TraverseRoot, error) {
	return hcl.TraverseRoot{
		Name:     root.Name,
		SrcRange: rangeTo(root.SrcRange),
	}, nil
}

func xtraverseTo(trv hcl.Traverser) (*Traverser, error) {
	if trv == nil {
		return nil, nil
	}

	switch t := trv.(type) {
	case hcl.TraverseAttr:
		attr, err := xtraverseAttrTo(t)
		return &Traverser{
			TraverserClause: &Traverser_TAttr{
				TAttr: attr,
			}}, err
	case hcl.TraverseIndex:
		index, err := xtraverseIndexTo(t)
		return &Traverser{
			TraverserClause: &Traverser_TIndex{
				TIndex: index,
			}}, err
	case hcl.TraverseRoot:
		root, err := xtraverseRootTo(t)
		return &Traverser{
			TraverserClause: &Traverser_TRoot{
				TRoot: root,
			}}, err
	default:
	}

	return nil, fmt.Errorf("unknown traverser type: %T", trv)
}

func traverseTo(trv *Traverser) (hcl.Traverser, error) {
	if trv == nil {
		return nil, nil
	}

	switch t := trv.TraverserClause.(type) {
	case *Traverser_TAttr:
		return traverseAttrTo(t.TAttr)
	case *Traverser_TIndex:
		index, err := traverseIndexTo(t.TIndex)
		return index, err
	case *Traverser_TRoot:
		return traverseRootTo(t.TRoot)
	default:
	}

	return nil, fmt.Errorf("unknown traverser type: %T", trv)
}
