package light

import (
	"fmt"

	"github.com/genelet/hcllight/generated"
	"github.com/genelet/hcllight/internal/ast"
)

func xtraverseAttrTo(attr *generated.TraverseAttr) (*ast.TraverseAttr, error) {
	if attr == nil {
		return nil, nil
	}

	return &ast.TraverseAttr{
		Name:     attr.Name,
		SrcRange: xrangeTo(attr),
	}, nil
}

func traverseAttrTo(attr *ast.TraverseAttr) (*generated.TraverseAttr, error) {
	if attr == nil {
		return nil, nil
	}

	return &generated.TraverseAttr{
		Name: attr.Name,
	}, nil
}

func xtraverseIndexTo(index *generated.TraverseIndex) (*ast.TraverseIndex, error) {
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

func traverseIndexTo(index *ast.TraverseIndex) (*generated.TraverseIndex, error) {
	if index == nil {
		return nil, nil
	}

	key, err := ctyValueTo(index.Key)
	if err != nil {
		return nil, err
	}

	return &generated.TraverseIndex{
		Key: key,
	}, nil
}

func xtraverseRootTo(root *generated.TraverseRoot) (*ast.TraverseRoot, error) {
	if root == nil {
		return nil, nil
	}

	return &ast.TraverseRoot{
		Name:     root.Name,
		SrcRange: xrangeTo(root),
	}, nil
}

func traverseRootTo(root *ast.TraverseRoot) (*generated.TraverseRoot, error) {
	if root == nil {
		return nil, nil
	}

	return &generated.TraverseRoot{
		Name: root.Name,
	}, nil
}

func xtraverseTo(trv *generated.Traverser) (*ast.Traverser, error) {
	if trv == nil {
		return nil, nil
	}

	switch t := trv.TraverserClause.(type) {
	case *generated.Traverser_TAttr:
		attr, err := xtraverseAttrTo(t.TAttr)
		if err != nil {
			return nil, err
		}
		return &ast.Traverser{
			TraverserClause: &ast.Traverser_TAttr{TAttr: attr},
		}, err
	case *generated.Traverser_TIndex:
		index, err := xtraverseIndexTo(t.TIndex)
		if err != nil {
			return nil, err
		}
		return &ast.Traverser{
			TraverserClause: &ast.Traverser_TIndex{TIndex: index},
		}, err
	case *generated.Traverser_TRoot:
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

func traverseTo(trv *ast.Traverser) (*generated.Traverser, error) {
	if trv == nil {
		return nil, nil
	}

	switch t := trv.TraverserClause.(type) {
	case *ast.Traverser_TAttr:
		attr, err := traverseAttrTo(t.TAttr)
		if err != nil {
			return nil, err
		}
		return &generated.Traverser{
			TraverserClause: &generated.Traverser_TAttr{TAttr: attr},
		}, err
	case *ast.Traverser_TIndex:
		index, err := traverseIndexTo(t.TIndex)
		if err != nil {
			return nil, err
		}
		return &generated.Traverser{
			TraverserClause: &generated.Traverser_TIndex{TIndex: index},
		}, err
	case *ast.Traverser_TRoot:
		root, err := traverseRootTo(t.TRoot)
		if err != nil {
			return nil, err
		}
		return &generated.Traverser{
			TraverserClause: &generated.Traverser_TRoot{TRoot: root},
		}, nil
	default:
	}
	return nil, fmt.Errorf("unknown traverser type: %T", trv)
}
