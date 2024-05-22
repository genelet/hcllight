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

func infoFromHCL(body *light.Body) (*Info, error) {
	if body == nil {
		return nil, nil
	}

	info := new(Info)
	var found bool
	for k, v := range body.Attributes {
		switch k {
		case "title":
			info.Title = *textValueExprToString(v.Expr)
			found = true
		case "description":
			info.Description = *textValueExprToString(v.Expr)
			found = true
		case "termsOfService":
			info.TermsOfService = *textValueExprToString(v.Expr)
			found = true
		case "version":
			info.Version = *textValueExprToString(v.Expr)
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
		case "specification":
			info.SpecificationExtension = bodyToAnyMap(block.Bdy)
			found = true
		default:
		}
	}

	if !found {
		return nil, nil
	}
	return info, nil
}
