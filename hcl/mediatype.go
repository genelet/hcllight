package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *MediaType) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Example != nil {
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: self.Example.toExpression(),
		}
	}
	if self.Examples != nil {
		blk, err := exampleOrReferenceMapToBlocks(self.Examples)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk...)
	}

	if self.Schema != nil {
		expr, err := self.Schema.toExpression()
		if err != nil {
			return nil, err
		}
		attrs["schema"] = &light.Attribute{
			Name: "schema",
			Expr: expr,
		}
	}
	if self.Encoding != nil {
		blks, err := encodingMapToBlocks(self.Encoding)
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

func mediaTypeFromHCL(body *light.Body) (*MediaType, error) {
	if body == nil {
		return nil, nil
	}

	mediaType := new(MediaType)
	var found bool
	for k, v := range body.Attributes {
		switch k {
		case "example":
			mediaType.Example = anyFromHCL(v.Expr)
			found = true
		case "schema":
			schema, err := ExpressionToSchemaOrReference(v.Expr)
			if err != nil {
				return nil, err
			}
			mediaType.Schema = schema
			found = true
		default:
		}
	}
	for _, blk := range body.Blocks {
		switch blk.Type {
		case "examples":
			examples, err := blocksToExampleOrReferenceMap(blk.Bdy.Blocks)
			if err != nil {
				return nil, err
			}
			mediaType.Examples = examples
			found = true
		case "encoding":
			encoding, err := blocksToEncodingMap(blk.Bdy.Blocks)
			if err != nil {
				return nil, err
			}
			mediaType.Encoding = encoding
			found = true
		default:
		}
	}

	if found {
		return mediaType, nil
	}
	return nil, nil
}

func mediaTypeMapToBlocks(content map[string]*MediaType) ([]*light.Block, error) {
	if content == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range content {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "content")
}

func blocksToMediaTypeMap(blocks []*light.Block) (map[string]*MediaType, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*MediaType)
	for _, block := range blocks {
		able, err := mediaTypeFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}
