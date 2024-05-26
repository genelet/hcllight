package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Tag) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	mapStrings := map[string]string{
		"name":        self.Name,
		"description": self.Description,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.ExternalDocs != nil {
		blk, err := self.ExternalDocs.toHCL()
		if err != nil {
			return nil, err
		}
		body.Blocks = append(body.Blocks, &light.Block{
			Type: "externalDocs",
			Bdy:  blk,
		})
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	return body, nil
}

func tagFromHCL(body *light.Body) (*Tag, error) {
	if body == nil {
		return nil, nil
	}

	self := &Tag{}
	var found bool
	if attr, ok := body.Attributes["description"]; ok {
		self.Description = *textValueExprToString(attr.Expr)
		found = true
	}
	if attr, ok := body.Attributes["name"]; ok {
		self.Name = *textValueExprToString(attr.Expr)
		found = true
	}
	for _, block := range body.Blocks {
		switch block.Type {
		case "externalDocs":
			blk, err := externalDocsFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			self.ExternalDocs = blk
			found = true
		}
	}
	if !found {
		return nil, nil
	}
	return self, nil
}

func tagsToTupleConsExpr(tags []*Tag) (*light.Expression, error) {
	if tags == nil || len(tags) == 0 {
		return nil, nil
	}
	var arr []ableHCL
	for _, tag := range tags {
		arr = append(arr, tag)
	}
	return ableToTupleConsExpr(arr)
}

func expressionToTags(expr *light.Expression) ([]*Tag, error) {
	if expr == nil {
		return nil, nil
	}

	ables, err := tupleConsExprToAble(expr, func(expr *light.ObjectConsExpr) (ableHCL, error) {
		return tagFromHCL(expr.ToBody())
	})
	if err != nil {
		return nil, err
	}
	var tags []*Tag
	for _, able := range ables {
		tag, ok := able.(*Tag)
		if !ok {
			return nil, ErrInvalidType(1004, able)
		}
		tags = append(tags, tag)
	}
	return tags, nil
}
