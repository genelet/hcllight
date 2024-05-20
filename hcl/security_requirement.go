package hcl

import (
	"github.com/genelet/hcllight/light"
)


func (self *SecurityRequirement) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	for k, v := range self.AdditionalProperties {
		attrs[k] = &light.Attribute{
			Name: k,
			Expr: stringArrayToTupleConsEpr(v.Value),
		}
	}
	body.Attributes = attrs
	return body, nil
}

