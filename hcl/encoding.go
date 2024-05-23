package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Encoding) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"explode":       self.Explode,
		"allowReserved": self.AllowReserved,
	}
	mapStrings := map[string]string{
		"contentType": self.ContentType,
		"style":       self.Style,
	}
	for k, v := range mapBools {
		if v {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: booleanToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if err := addSpecificationBlock(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
	}

	if self.Headers != nil {
		blks, err := headerOrReferenceMapToBlocks(self.Headers)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func encodingFromHCL(body *light.Body) (*Encoding, error) {
	if body == nil {
		return nil, nil
	}

	self := &Encoding{}
	var err error
	var found bool
	for k, v := range body.Attributes {
		switch k {
		case "contentType":
			self.ContentType = *textValueExprToString(v.Expr)
			found = true
		case "style":
			self.Style = *textValueExprToString(v.Expr)
			found = true
		case "explode":
			self.Explode = *literalValueExprToBoolean(v.Expr)
			found = true
		case "allowReserved":
			self.AllowReserved = *literalValueExprToBoolean(v.Expr)
			found = true
		}
	}
	for _, block := range body.Blocks {
		switch block.Labels[0] {
		case "header":
			self.Headers, err = blocksToHeaderOrReferenceMap(block.Bdy.Blocks)
			if err != nil {
				return nil, err
			}
			found = true
		case "specification":
			self.SpecificationExtension, err = bodyToAnyMap(block.Bdy)
			found = true
		}
	}

	if found {
		return self, nil
	}
	return nil, nil
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
