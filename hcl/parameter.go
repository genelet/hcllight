package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *ParameterOrReference) getAble() ableHCL {
	return self.GetParameter()
}

func (self *Parameter) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"required":        self.Required,
		"deprecated":      self.Deprecated,
		"allowEmptyValue": self.AllowEmptyValue,
		"explode":         self.Explode,
		"allowReserved":   self.AllowReserved,
	}
	mapStrings := map[string]string{
		"name":        self.Name,
		"in":          self.In,
		"description": self.Description,
		"style":       self.Style,
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
	if self.Example != nil {
		expr, err := self.Example.toExpression()
		if err != nil {
			return nil, err
		}
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: expr,
		}
	}
	if self.Examples != nil {
		blk, err := exampleOrReferenceMapToBlocks(self.Examples, "examples")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk...)
	}
	if err := addSpecification(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
	}

	if self.Schema != nil {
		expr, err := self.Schema.toExpression()
		if err != nil {
			return nil, err
		}
		attrs["schema"] = &light.Attribute{
			Name: "schema",
			Expr: expr,
		}
	}
	if self.Content != nil {
		blks, err := mediaTypeMapToBlocks(self.Content)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func parameterFromHCL(body *light.Body) (*Parameter, error) {
	if body == nil {
		return nil, nil
	}

	parameter := new(Parameter)
	var err error
	var found bool
	for k, v := range body.Attributes {
		switch k {
		case "required":
			parameter.Required = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "deprecated":
			parameter.Deprecated = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "allowEmptyValue":
			parameter.AllowEmptyValue = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "explode":
			parameter.Explode = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "allowReserved":
			parameter.AllowReserved = *light.LiteralValueExprToBoolean(v.Expr)
			found = true
		case "name":
			parameter.Name = *light.TextValueExprToString(v.Expr)
			found = true
		case "in":
			parameter.In = *light.TextValueExprToString(v.Expr)
			found = true
		case "description":
			parameter.Description = *light.TextValueExprToString(v.Expr)
			found = true
		case "style":
			parameter.Style = *light.TextValueExprToString(v.Expr)
			found = true
		case "example":
			parameter.Example, err = anyFromHCL(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		case "schema":
			parameter.Schema, err = expressionToSchemaOrReference(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		default:
		}
	}

	parameter.Examples, err = blocksToExampleOrReferenceMap(body.Blocks, "examples")
	if err != nil {
		return nil, err
	}
	if parameter.Examples == nil {
		found = true
	}
	parameter.Content, err = blocksToMediaTypeMap(body.Blocks)
	if err != nil {
		return nil, err
	}
	if parameter.Content == nil {
		found = true
	}
	for _, block := range body.Blocks {
		if block.Type == "specification" {
			parameter.SpecificationExtension, err = bodyToAnyMap(block.Bdy)
			if err != nil {
				return nil, err
			}
			found = true
		}
	}

	if !found {
		return nil, nil
	}
	return parameter, nil
}

func parameterOrReferenceArrayToBody(array []*ParameterOrReference) (*light.Body, error) {
	if array == nil {
		return nil, nil
	}

	blocks := make([]*light.Block, 0)
	var exprs []*light.Expression
	for _, v := range array {
		switch v.Oneof.(type) {
		case *ParameterOrReference_Parameter:
			t := v.GetParameter()
			name := t.Name
			t.Name = ""
			body, err := t.toHCL()
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type:   "parameters",
				Labels: []string{name},
				Bdy:    body,
			})
		case *ParameterOrReference_Reference:
			reference := v.GetReference()
			expr, err := reference.toExpression()
			if err != nil {
				return nil, err
			}
			exprs = append(exprs, expr)
		default:
		}
	}

	if len(blocks) == 0 && exprs == nil {
		return nil, nil
	}
	body := new(light.Body)
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	if exprs != nil {
		body.Attributes = map[string]*light.Attribute{
			"parameters": {
				Name: "parameters",
				Expr: &light.Expression{
					ExpressionClause: &light.Expression_Tcexpr{
						Tcexpr: &light.TupleConsExpr{
							Exprs: exprs,
						},
					},
				},
			},
		}
	}
	return body, nil
}

func bodyToParameterOrReferenceArray(body *light.Body, name string) ([]*ParameterOrReference, error) {
	if body == nil {
		return nil, nil
	}

	var array []*ParameterOrReference
	for k, v := range body.Attributes {
		if k != name {
			continue
		}
		if v.Expr.GetTcexpr() != nil {
			for _, expr := range v.Expr.GetTcexpr().Exprs {
				reference, err := expressionToReference(expr)
				if err != nil {
					return nil, err
				}
				if reference != nil {
					array = append(array, &ParameterOrReference{
						Oneof: &ParameterOrReference_Reference{
							Reference: reference,
						},
					})
				}
			}
		}
	}
	for _, block := range body.Blocks {
		if block.Type != name {
			continue
		}
		parameter, err := parameterFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		if parameter != nil {
			parameter.Name = block.Labels[0]
			array = append(array, &ParameterOrReference{
				Oneof: &ParameterOrReference_Parameter{
					Parameter: parameter,
				},
			})
		}
	}

	return array, nil
}

func parameterOrReferenceMapToBlocks(parameters map[string]*ParameterOrReference, names ...string) ([]*light.Block, error) {
	if parameters == nil {
		return nil, nil
	}

	hash := make(map[string]orHCL)
	for k, v := range parameters {
		hash[k] = v
	}
	return orMapToBlocks(hash, names...)
}

func blocksToParameterOrReferenceMap(blocks []*light.Block, names ...string) (map[string]*ParameterOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, func(reference *Reference) orHCL {
		return &ParameterOrReference{
			Oneof: &ParameterOrReference_Reference{
				Reference: reference,
			},
		}
	}, func(body *light.Body) (orHCL, error) {
		parameter, err := parameterFromHCL(body)
		if err != nil {
			return nil, err
		}
		if parameter != nil {
			return &ParameterOrReference{
				Oneof: &ParameterOrReference_Parameter{
					Parameter: parameter,
				},
			}, nil
		}
		return nil, nil
	}, names...)
	if err != nil {
		return nil, err
	}

	if orMap == nil {
		return nil, nil
	}

	hash := make(map[string]*ParameterOrReference)
	for k, v := range orMap {
		hash[k] = v.(*ParameterOrReference)
	}

	return hash, nil
}
