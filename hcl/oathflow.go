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
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
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
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

