package light

import (
	"fmt"

	"github.com/genelet/hcllight/internal/ast"
)

func xtraverseAttrTo(attr *TraverseAttr) (*ast.TraverseAttr, error) {
	if attr == nil {
		return nil, nil
	}

	return &ast.TraverseAttr{
		Name:     attr.Name,
		SrcRange: xrangeTo(attr),
	}, nil
}

func traverseAttrTo(attr *ast.TraverseAttr) (*TraverseAttr, error) {
	if attr == nil {
		return nil, nil
	}

	return &TraverseAttr{
		Name: attr.Name,
	}, nil
}

func xtraverseIndexTo(index *TraverseIndex) (*ast.TraverseIndex, error) {
	if index == nil {
		return nil, nil
	}

	key, err := xctyValueTo(index.Key)
	if err != nil {
		return nil, err
	}
	return &ast.TraverseIndex{
		Key:      key,
		SrcRange: xrangeTo(index),
	}, nil
}

func traverseIndexTo(index *ast.TraverseIndex) (*TraverseIndex, error) {
	if index == nil {
		return nil, nil
	}

	key, err := ctyValueTo(index.Key)
	if err != nil {
		return nil, err
	}

	return &TraverseIndex{
		Key: key,
	}, nil
}

func xtraverseRootTo(root *TraverseRoot) (*ast.TraverseRoot, error) {
	if root == nil {
		return nil, nil
	}

	return &ast.TraverseRoot{
		Name:     root.Name,
		SrcRange: xrangeTo(root),
	}, nil
}

func traverseRootTo(root *ast.TraverseRoot) (*TraverseRoot, error) {
	if root == nil {
		return nil, nil
	}

	return &TraverseRoot{
		Name: root.Name,
	}, nil
}

func xtraverseTo(trv *Traverser) (*ast.Traverser, error) {
	if trv == nil {
		return nil, nil
	}

	switch t := trv.TraverserClause.(type) {
	case *Traverser_TAttr:
		attr, err := xtraverseAttrTo(t.TAttr)
		if err != nil {
			return nil, err
		}
		return &ast.Traverser{
			TraverserClause: &ast.Traverser_TAttr{TAttr: attr},
		}, err
	case *Traverser_TIndex:
		index, err := xtraverseIndexTo(t.TIndex)
		if err != nil {
			return nil, err
		}
		return &ast.Traverser{
			TraverserClause: &ast.Traverser_TIndex{TIndex: index},
		}, err
	case *Traverser_TRoot:
		root, err := xtraverseRootTo(t.TRoot)
		if err != nil {
			return nil, err
		}
		return &ast.Traverser{
			TraverserClause: &ast.Traverser_TRoot{TRoot: root},
		}, err
	default:
	}

	return nil, fmt.Errorf("unknown traverser type: %T", trv)
}

func traverseTo(trv *ast.Traverser) (*Traverser, error) {
	if trv == nil {
		return nil, nil
	}

	switch t := trv.TraverserClause.(type) {
	case *ast.Traverser_TAttr:
		attr, err := traverseAttrTo(t.TAttr)
		if err != nil {
			return nil, err
		}
		return &Traverser{
			TraverserClause: &Traverser_TAttr{TAttr: attr},
		}, err
	case *ast.Traverser_TIndex:
		index, err := traverseIndexTo(t.TIndex)
		if err != nil {
			return nil, err
		}
		return &Traverser{
			TraverserClause: &Traverser_TIndex{TIndex: index},
		}, err
	case *ast.Traverser_TRoot:
		root, err := traverseRootTo(t.TRoot)
		if err != nil {
			return nil, err
		}
		return &Traverser{
			TraverserClause: &Traverser_TRoot{TRoot: root},
		}, nil
	default:
	}
	return nil, fmt.Errorf("unknown traverser type: %T", trv)
}
