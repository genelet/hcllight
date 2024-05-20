package hcl

import (
	"github.com/genelet/hcllight/light"
)


func (self *Info) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	mapStrings := map[string]string{
		"title":          self.Title,
		"description":    self.Description,
		"termsOfService": self.TermsOfService,
		"version":        self.Version,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Contact != nil {
		bdy, err := self.Contact.toHCL()
		if err != nil {
			return nil, err
		}
		body.Blocks = append(body.Blocks, &light.Block{
			Type: "contact",
			Bdy:  bdy,
		})
	}
	if self.License != nil {
		bdy, err := self.License.toHCL()
		if err != nil {
			return nil, err
		}
		body.Blocks = append(body.Blocks, &light.Block{
			Type: "license",
			Bdy:  bdy,
		})
	}
	addSpecificationBlock(self.SpecificationExtension, &body.Blocks)
	if len(attrs) > 0 {
		body.Attributes = attrs
	}

	return body, nil
}

