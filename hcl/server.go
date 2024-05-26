package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *Server) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"url":         self.Url,
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
	if self.Variables != nil {
		blks, err := serverVariableMapToBlocks(self.Variables)
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

func serverFromHCL(body *light.Body) (*Server, error) {
	if body == nil {
		return nil, nil
	}

	self := &Server{}
	var found bool
	var err error
	if attr, ok := body.Attributes["url"]; ok {
		self.Url = *textValueExprToString(attr.Expr)
		found = true
	}
	if attr, ok := body.Attributes["description"]; ok {
		self.Description = *textValueExprToString(attr.Expr)
		found = true
	}

	variables, err := blocksToServerVariableMap(body.Blocks)
	if err != nil {
		return nil, err
	}
	if variables != nil {
		self.Variables = variables
		found = true
	}
	if self.SpecificationExtension, err = getSpecification(body); err != nil {
		return nil, err
	} else if self.SpecificationExtension != nil {
		found = true
	}

	if !found {
		return nil, nil
	}
	return self, nil
}

func serversToTupleConsExpr(servers []*Server) (*light.Expression, error) {
	if len(servers) == 0 {
		return nil, nil
	}

	var arr []ableHCL
	for _, server := range servers {
		arr = append(arr, server)
	}
	return ableToTupleConsExpr(arr)
}

func expressionToServers(expr *light.Expression) ([]*Server, error) {
	if expr == nil {
		return nil, nil
	}

	ables, err := tupleConsExprToAble(expr, func(e *light.ObjectConsExpr) (ableHCL, error) {
		return serverFromHCL(e.ToBody())
	})
	if err != nil {
		return nil, err
	}
	var servers []*Server
	for _, able := range ables {
		server, ok := able.(*Server)
		if !ok {
			return nil, ErrInvalidType(1003, able)
		}
		servers = append(servers, server)
	}
	return servers, nil
}
