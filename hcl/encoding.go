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
				Expr: light.BooleanToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: light.StringToTextValueExpr(v),
			}
		}
	}

	if self.Headers != nil {
		blks, err := headerOrReferenceMapToBlocks(self.Headers, "headers")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if err := addSpecification(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
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
			self.ContentType = *light.TextValueExprToString(v.Expr)
			found = true
		case "style":
			self.Style = *light.TextValueExprToString(v.Expr)
			found = true
		case "explode":
			self.Explode = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "allowReserved":
			self.AllowReserved = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		}
	}

	self.Headers, err = blocksToHeaderOrReferenceMap(body.Blocks, "headers")
	if err != nil {
		return nil, err
	}
	if self.Headers != nil {
		found = true
	}

	self.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	}
	if self.SpecificationExtension != nil {
		found = true
	}

	if !found {
		return nil, nil
	}
	return self, nil
}

func encodingMapToBlocks(encodings map[string]*Encoding) ([]*light.Block, error) {
	if encodings == nil {
		return nil, nil
	}
	hash := make(map[string]ableHCL)
	for k, v := range encodings {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "encoding")
}

func blocksToEncodingMap(blocks []*light.Block) (map[string]*Encoding, error) {
	if blocks == nil {
		return nil, nil
	}
	var hash map[string]*Encoding
	for _, block := range blocks {
		if block.Type != "encoding" {
			continue
		}
		if hash == nil {
			hash = make(map[string]*Encoding)
		}
		able, err := encodingFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}
