package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *LinkOrReference) getAble() ableHCL {
	return self.GetLink()
}

func linkOrReferenceFromHCL(body *light.Body) (*LinkOrReference, error) {
	if body == nil {
		return nil, nil
	}

	reference, err := referenceFromHCL(body)
	if err != nil {
		return nil, err
	}
	if reference != nil {
		return &LinkOrReference{
			Oneof: &LinkOrReference_Reference{
				Reference: reference,
			},
		}, nil
	}

	link, err := linkFromHCL(body)
	if err != nil {
		return nil, err
	}
	if link == nil {
		return nil, nil
	}
	return &LinkOrReference{
		Oneof: &LinkOrReference_Link{
			Link: link,
		},
	}, nil
}

func (self *Link) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"operationRef": self.OperationRef,
		"operationId":  self.OperationId,
		"description":  self.Description,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Server != nil {
		bdy, err := self.Server.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "server",
			Bdy:  bdy,
		})
	}
	if err := addSpecificationBlock(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
	}

	if self.Parameters != nil {
		expr, err := self.Parameters.toExpression()
		if err != nil {
			return nil, err
		}
		attrs["parameters"] = &light.Attribute{
			Name: "parameters",
			Expr: expr,
		}
	}
	if self.RequestBody != nil {
		expr, err := self.RequestBody.toExpression()
		if err != nil {
			return nil, err
		}
		attrs["requestBody"] = &light.Attribute{
			Name: "requestBody",
			Expr: expr,
		}
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func linkFromHCL(body *light.Body) (*Link, error) {
	if body == nil {
		return nil, nil
	}

	link := new(Link)
	var found bool
	var err error
	for k, v := range body.Attributes {
		switch k {
		case "operationRef":
			link.OperationRef = *textValueExprToString(v.Expr)
			found = true
		case "operationId":
			link.OperationId = *textValueExprToString(v.Expr)
			found = true
		case "description":
			link.Description = *textValueExprToString(v.Expr)
			found = true
		case "parameters":
			link.Parameters, err = anyOrExpressionFromHCL(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		case "requestBody":
			link.RequestBody, err = anyOrExpressionFromHCL(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		default:
		}
	}
	for _, block := range body.Blocks {
		switch block.Type {
		case "server":
			server, err := serverFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			link.Server = server
		default:
			link.SpecificationExtension, err = bodyToAnyMap(body)
			if err != nil {
				return nil, err
			}
		}
	}

	if found {
		return link, nil
	}
	return nil, nil
}

func linkOrReferenceMapToBlocks(links map[string]*LinkOrReference) ([]*light.Block, error) {
	if links == nil {
		return nil, nil
	}

	hash := make(map[string]orHCL)
	for k, v := range links {
		hash[k] = v
	}
	return orMapToBlocks(hash, "links")
}

func blocksToLinkOrReferenceMap(blocks []*light.Block) (map[string]*LinkOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, "links", func(reference *Reference) orHCL {
		return &LinkOrReference{
			Oneof: &LinkOrReference_Reference{
				Reference: reference,
			},
		}
	}, func(body *light.Body) (orHCL, error) {
		link, err := linkFromHCL(body)
		if err != nil {
			return nil, err
		}
		if link != nil {
			return &LinkOrReference{
				Oneof: &LinkOrReference_Link{
					Link: link,
				},
			}, nil
		}
		return nil, nil
	})
	if err != nil {
		return nil, err
	}

	if orMap == nil {
		return nil, nil
	}

	hash := make(map[string]*LinkOrReference)
	for k, v := range orMap {
		hash[k] = v.(*LinkOrReference)
	}

	return hash, nil
}
