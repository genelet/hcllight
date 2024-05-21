package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *OauthFlows) toHCL() (*light.Body, error) {
	body := new(light.Body)
	blocks := make([]*light.Block, 0)
	if self.Implicit != nil {
		blk, err := self.Implicit.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "implicit",
			Bdy:  blk,
		})
	}
	if self.Password != nil {
		blk, err := self.Password.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "password",
			Bdy:  blk,
		})
	}
	if self.ClientCredentials != nil {
		blk, err := self.ClientCredentials.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "clientCredentials",
			Bdy:  blk,
		})
	}
	if self.AuthorizationCode != nil {
		blk, err := self.AuthorizationCode.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "authorizationCode",
			Bdy:  blk,
		})
	}
	addSpecificationBlock(self.SpecificationExtension, &blocks)

	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func flowsFromHCL(body *light.Body) (*OauthFlows, error) {
	if body == nil {
		return nil, nil
	}

	flows := &OauthFlows{}
	for _, blk := range body.Blocks {
		if blk.Type == "implicit" {
			flow, err := flowFromHCL(blk.Bdy)
			if err != nil {
				return nil, err
			}
			flows.Implicit = flow
		} else if blk.Type == "password" {
			flow, err := flowFromHCL(blk.Bdy)
			if err != nil {
				return nil, err
			}
			flows.Password = flow
		} else if blk.Type == "clientCredentials" {
			flow, err := flowFromHCL(blk.Bdy)
			if err != nil {
				return nil, err
			}
			flows.ClientCredentials = flow
		} else if blk.Type == "authorizationCode" {
			flow, err := flowFromHCL(blk.Bdy)
			if err != nil {
				return nil, err
			}
			flows.AuthorizationCode = flow
		} else if blk.Type == "specificationExtension" {
			flows.SpecificationExtension = bodyToAnyMap(blk.Bdy)
		}
	}

	return flows, nil
}

func (self *OauthFlow) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"authorizationUrl": self.AuthorizationUrl,
		"tokenUrl":         self.TokenUrl,
		"refreshUrl":       self.RefreshUrl,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Scopes != nil {
		bdy := &light.Body{
			Attributes: map[string]*light.Attribute{},
		}
		for k, v := range self.Scopes {
			bdy.Attributes[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
		blocks = append(blocks, &light.Block{
			Type: "scopes",
			Bdy:  bdy,
		})
	}
	addSpecificationBlock(self.SpecificationExtension, &blocks)
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func flowFromHCL(body *light.Body) (*OauthFlow, error) {
	if body == nil {
		return nil, nil
	}

	flow := &OauthFlow{}
	var found bool
	for k, v := range body.Attributes {
		if k == "authorizationURL" {
			flow.AuthorizationUrl = *textValueExprToString(v.Expr)
			found = true
		} else if k == "tokenURL" {
			flow.TokenUrl = *textValueExprToString(v.Expr)
			found = true
		} else if k == "refreshURL" {
			flow.RefreshUrl = *textValueExprToString(v.Expr)
			found = true
		}
	}
	for _, blk := range body.Blocks {
		if blk.Type == "scopes" {
			flow.Scopes = make(map[string]string)
			for k, v := range blk.Bdy.Attributes {
				flow.Scopes[k] = *textValueExprToString(v.Expr)
			}
			found = true
		} else if blk.Type == "specificationExtension" {
			flow.SpecificationExtension = bodyToAnyMap(blk.Bdy)
			found = true
		}
	}

	if found {
		return flow, nil
	}
	return nil, nil
}
