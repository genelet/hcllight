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

func securityRequirementFromHCL(body *light.Body) (*SecurityRequirement, error) {
	if body == nil {
		return nil, nil
	}

	self := &SecurityRequirement{
		AdditionalProperties: make(map[string]*StringArray),
	}
	for k, v := range body.Attributes {
		self.AdditionalProperties[k] = &StringArray{
			Value: tupleConsExprToStringArray(v.Expr),
		}
	}
	return self, nil
}

func securityRequirementToTupleConsExpr(security []*SecurityRequirement) (*light.Expression, error) {
	if security == nil || len(security) == 0 {
		return nil, nil
	}
	var arr []AbleHCL
	for _, item := range security {
		arr = append(arr, item)
	}
	return ableToTupleConsExpr(arr)
}

func expressionToSecurityRequirement(expr *light.Expression) ([]*SecurityRequirement, error) {
	if expr == nil {
		return nil, nil
	}
	ables, err := tupleConsExprToAble(expr, func(expr *light.ObjectConsExpr) (AbleHCL, error) {
		return securityRequirementFromHCL(expr.ToBody())
	})
	if err != nil {
		return nil, err
	}
	var security []*SecurityRequirement
	for _, able := range ables {
		item, ok := able.(*SecurityRequirement)
		if !ok {
			return nil, ErrInvalidType()
		}
		security = append(security, item)
	}
	return security, nil
}
