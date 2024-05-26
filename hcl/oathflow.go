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
	if err := addSpecification(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
	}

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
	var found bool
	var err error
	for _, blk := range body.Blocks {
		if blk.Type == "implicit" {
			flow, err := flowFromHCL(blk.Bdy)
			if err != nil {
				return nil, err
			}
			flows.Implicit = flow
			found = true
		} else if blk.Type == "password" {
			flow, err := flowFromHCL(blk.Bdy)
			if err != nil {
				return nil, err
			}
			flows.Password = flow
			found = true
		} else if blk.Type == "clientCredentials" {
			flow, err := flowFromHCL(blk.Bdy)
			if err != nil {
				return nil, err
			}
			flows.ClientCredentials = flow
			found = true
		} else if blk.Type == "authorizationCode" {
			flow, err := flowFromHCL(blk.Bdy)
			if err != nil {
				return nil, err
			}
			flows.AuthorizationCode = flow
			found = true
		} else if blk.Type == "specificationExtension" {
			flows.SpecificationExtension, err = bodyToAnyMap(blk.Bdy)
			if err != nil {
				return nil, err
			}
			found = true
		}
	}

	if !found {
		return nil, nil
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
		attrs["scopes"] = &light.Attribute{
			Name: "scopes",
			Expr: stringMapToObjConsExpr(self.Scopes),
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

func flowFromHCL(body *light.Body) (*OauthFlow, error) {
	if body == nil {
		return nil, nil
	}

	flow := &OauthFlow{}
	var found bool
	var err error
	for k, v := range body.Attributes {
		switch k {
		case "authorizationURL":
			flow.AuthorizationUrl = *textValueExprToString(v.Expr)
			found = true
		case "tokenURL":
			flow.TokenUrl = *textValueExprToString(v.Expr)
			found = true
		case "refreshURL":
			flow.RefreshUrl = *textValueExprToString(v.Expr)
			found = true
		case "scopes":
			flow.Scopes = objConsExprToStringMap(v.Expr)
			found = true
		default:
		}
	}

	flow.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	}
	if flow.SpecificationExtension != nil {
		found = true
	}

	if !found {
		return nil, nil
	}
	return flow, nil
}
