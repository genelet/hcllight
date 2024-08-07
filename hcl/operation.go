package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Operation) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"deprecated": self.Deprecated,
	}
	mapStrings := map[string]string{
		"summary":     self.Summary,
		"description": self.Description,
		"operationId": self.OperationId,
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
				Expr: light.StringToTextValueExpr(v, true),
			}
		}
	}
	if self.Tags != nil {
		expr := light.StringArrayToTupleConsEpr(self.Tags)
		attrs["tags"] = &light.Attribute{
			Name: "tags",
			Expr: expr,
		}
	}
	if self.Parameters != nil {
		body, err := parameterOrReferenceArrayToBody(self.Parameters)
		if err != nil {
			return nil, err
		}
		for k, v := range body.Attributes {
			attrs[k] = v
		}
		blocks = append(blocks, body.Blocks...)
	}
	if self.RequestBody != nil {
		bdy, err := self.RequestBody.getAble().toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "requestBody",
			Bdy:  bdy,
		})
	}
	if self.Responses != nil {
		blks, err := responseOrReferenceMapToBlocks(self.Responses, "responses")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Callbacks != nil {
		blks, err := callbackOrReferenceMapToBlocks(self.Callbacks, "callbacks")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Security != nil {
		expr, err := securityRequirementToTupleConsExpr(self.Security)
		if err != nil {
			return nil, err
		}
		attrs["security"] = &light.Attribute{
			Name: "security",
			Expr: expr,
		}
	}
	if self.Servers != nil {
		expr, err := serversToTupleConsExpr(self.Servers)
		if err != nil {
			return nil, err
		}
		attrs["servers"] = &light.Attribute{
			Name: "servers",
			Expr: expr,
		}
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

func operationFromHCL(body *light.Body) (*Operation, error) {
	if body == nil {
		return nil, nil
	}

	self := &Operation{}
	var err error
	var found bool
	for k, v := range body.Attributes {
		switch k {
		case "deprecated":
			self.Deprecated = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "summary":
			self.Summary = *light.TextValueExprToString(v.Expr)
			found = true
		case "description":
			self.Description = *light.TextValueExprToString(v.Expr)
			found = true
		case "operationId":
			self.OperationId = *light.TextValueExprToString(v.Expr)
			found = true
		case "tags":
			self.Tags = light.TupleConsExprToStringArray(v.Expr)
			found = true
		case "security":
			self.Security, err = expressionToSecurityRequirement(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		case "servers":
			self.Servers, err = expressionToServers(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		default:
		}
	}

	for _, block := range body.Blocks {
		switch block.Type {
		case "requestBody":
			self.RequestBody, err = requestBodyOrReferenceFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			found = true
		default:
		}
	}
	parameters, err := bodyToParameterOrReferenceArray(body, "parameters")
	if err != nil {
		return nil, err
	}
	if parameters != nil {
		self.Parameters = parameters
		found = true
	}

	responses, err := blocksToResponseOrReferenceMap(body.Blocks, "responses")
	if err != nil {
		return nil, err
	}
	if responses != nil {
		self.Responses = responses
		found = true
	}

	callbacks, err := blocksToCallbackOrReferenceMap(body.Blocks, "callbacks")
	if err != nil {
		return nil, err
	}
	if callbacks != nil {
		self.Callbacks = callbacks
		found = true
	}
	self.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	} else if self.SpecificationExtension != nil {
		found = true
	}

	if !found {
		return nil, nil
	}
	return self, nil
}

/*
func operationMapToBlocks(op map[string]*Operation) ([]*light.Block, error) {
	if op == nil {
		return nil, nil
	}
	hash := make(map[string]ableHCL)
	for k, v := range op {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "op")
}

func blocksToOperationMap(blocks []*light.Block) (map[string]*Operation, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*Operation)
	for _, block := range blocks {
		if block.Type != "op" {
			continue
		}
		able, err := operationFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}

	return hash, nil
}
*/
