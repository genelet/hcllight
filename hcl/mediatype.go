package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *MediaType) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Example != nil {
		expr, err := self.Example.toExpression()
		if err != nil {
			return nil, err
		}
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: expr,
		}
	}
	if self.Examples != nil {
		blk, err := exampleOrReferenceMapToBlocks(self.Examples, "examples")
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
	var err error
	for k, v := range body.Attributes {
		switch k {
		case "example":
			mediaType.Example, err = anyFromHCL(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		case "schema":
			schema, err := expressionToSchemaOrReference(v.Expr)
			if err != nil {
				return nil, err
			}
			mediaType.Schema = schema
			found = true
		default:
		}
	}

	examples, err := blocksToExampleOrReferenceMap(body.Blocks, "examples")
	if err != nil {
		return nil, err
	}
	if examples != nil {
		mediaType.Examples = examples
		found = true
	}

	encoding, err := blocksToEncodingMap(body.Blocks)
	if err != nil {
		return nil, err
	}
	if encoding != nil {
		mediaType.Encoding = encoding
		found = true
	}
	mediaType.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	}
	if mediaType.SpecificationExtension != nil {
		found = true
	}

	if !found {
		return nil, nil
	}
	return mediaType, nil
}

func mediaTypeMapToBlocks(content map[string]*MediaType) ([]*light.Block, error) {
	if content == nil {
		return nil, nil
	}
	hash := make(map[string]ableHCL)
	for k, v := range content {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "content")
}

func blocksToMediaTypeMap(blocks []*light.Block) (map[string]*MediaType, error) {
	if blocks == nil {
		return nil, nil
	}
	var hash map[string]*MediaType
	for _, block := range blocks {
		if block.Type != "content" {
			continue
		}
		if hash == nil {
			hash = make(map[string]*MediaType)
		}
		able, err := mediaTypeFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}
