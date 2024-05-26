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
				Expr: light.StringToTextValueExpr(v),
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
	if err := addSpecification(self.SpecificationExtension, &body.Blocks); err != nil {
		return nil, err
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}

	return body, nil
}

func infoFromHCL(body *light.Body) (*Info, error) {
	if body == nil {
		return nil, nil
	}

	info := new(Info)
	var found bool
	var err error
	for k, v := range body.Attributes {
		switch k {
		case "title":
			info.Title = *light.TextValueExprToString(v.Expr)
			found = true
		case "description":
			info.Description = *light.TextValueExprToString(v.Expr)
			found = true
		case "termsOfService":
			info.TermsOfService = *light.TextValueExprToString(v.Expr)
			found = true
		case "version":
			info.Version = *light.TextValueExprToString(v.Expr)
			found = true
		}
	}
	for _, block := range body.Blocks {
		switch block.Type {
		case "contact":
			contact, err := contactFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			info.Contact = contact
			found = true
		case "license":
			license, err := licenseFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			info.License = license
			found = true
		default:
		}
	}
	info.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	} else if info.SpecificationExtension != nil {
		found = true
	}

	if !found {
		return nil, nil
	}
	return info, nil
}
