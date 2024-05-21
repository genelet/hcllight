package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *ParameterOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *ParameterOrReference_Parameter:
		return self.GetParameter().toHCL()
	case *ParameterOrReference_Reference:
		return self.GetReference().toHCL()
	default:
	}
	return nil, nil
}

func parameterOrReferenceFromHCL(body *light.Body) (*ParameterOrReference, error) {
	if body == nil {
		return nil, nil
	}

	reference, err := referenceFromHCL(body)
	if err != nil {
		return nil, err
	}
	if reference != nil {
		return &ParameterOrReference{
			Oneof: &ParameterOrReference_Reference{
				Reference: reference,
			},
		}, nil
	}

	parameter, err := parameterFromHCL(body)
	if err != nil {
		return nil, err
	}
	if parameter == nil {
		return nil, nil
	}
	return &ParameterOrReference{
		Oneof: &ParameterOrReference_Parameter{
			Parameter: parameter,
		},
	}, nil
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
				Expr: booleanToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Example != nil {
		expr := self.Example.toExpression()
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: expr,
		}
	}
	if self.Examples != nil {
		blk, err := exampleOrReferenceMapToBlocks(self.Examples)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk...)
	}
	addSpecificationBlock(self.SpecificationExtension, &blocks)

	if self.Schema != nil {
		expr, err := SchemaOrReferenceToExpression(self.Schema)
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
			parameter.Required = *literalValueExprToBoolean(v.Expr)
			found = true
		case "deprecated":
			parameter.Deprecated = *literalValueExprToBoolean(v.Expr)
			found = true
		case "allowEmptyValue":
			parameter.AllowEmptyValue = *literalValueExprToBoolean(v.Expr)
			found = true
		case "explode":
			parameter.Explode = *literalValueExprToBoolean(v.Expr)
			found = true
		case "allowReserved":
			parameter.AllowReserved = *literalValueExprToBoolean(v.Expr)
			found = true
		case "name":
			parameter.Name = *textValueExprToString(v.Expr)
			found = true
		case "in":
			parameter.In = *textValueExprToString(v.Expr)
			found = true
		case "description":
			parameter.Description = *textValueExprToString(v.Expr)
			found = true
		case "style":
			parameter.Style = *textValueExprToString(v.Expr)
			found = true
		case "example":
			parameter.Example = anyFromHCL(v.Expr)
			found = true
		case "schema":
			parameter.Schema, err = ExpressionToSchemaOrReference(v.Expr)
			if err != nil {
				return nil, err
			}
			found = true
		default:
		}
		for _, block := range body.Blocks {
			switch block.Type {
			case "examples":
				parameter.Examples, err = blocksToExampleOrReferenceMap(block.Bdy.Blocks)
				if err != nil {
					return nil, err
				}
				found = true
			case "content":
				parameter.Content, err = blocksToMediaTypeMap(block.Bdy.Blocks)
				if err != nil {
					return nil, err
				}
				found = true
			case "specification":
				parameter.SpecificationExtension = bodyToAnyMap(block.Bdy)
			}
		}
	}
	if !found {
		return nil, nil
	}
	return parameter, nil
}

/*
	func parametersToTupleConsExpr(parameters []*ParameterOrReference) (*light.Expression, error) {
		if parameters == nil || len(parameters) == 0 {
			return nil, nil
		}

		var arr []AbleHCL
		for _, v := range parameters {
			arr = append(arr, v)
		}
		return ableToTupleConsExpr(arr)
	}

	func expressionToParameters(expr *light.Expression) ([]*ParameterOrReference, error) {
		if expr == nil {
			return nil, nil
		}

		ables, err := tupleConsExprToAble(expr, func(expr *light.ObjectConsExpr) (AbleHCL, error) {
			return parameterOrReferenceFromHCL(expr.ToBody())
		})
		if err != nil {
			return nil, err
		}
		var parameters []*ParameterOrReference
		for _, able := range ables {
			parameters = append(parameters, able.(*ParameterOrReference))
		}
		return parameters, nil
	}
*/
func arrayParameterToHash(array []*ParameterOrReference) map[string]*ParameterOrReference {
	hash := make(map[string]*ParameterOrReference)
	for _, v := range array {
		switch v.Oneof.(type) {
		case *ParameterOrReference_Parameter:
			t := v.GetParameter()
			name := t.Name
			t.Name = ""
			hash[name] = v
		case *ParameterOrReference_Reference:
			t := v.GetReference()
			hash[t.XRef] = v
		default:
		}
	}
	return hash
}

func hashParameterToArray(hash map[string]*ParameterOrReference) []*ParameterOrReference {
	if hash == nil {
		return nil
	}

	var array []*ParameterOrReference
	for k, v := range hash {
		switch v.Oneof.(type) {
		case *ParameterOrReference_Parameter:
			v.GetParameter().Name = k
		case *ParameterOrReference_Reference:
			v.GetReference().XRef = k
		default:
		}
		array = append(array, v)
	}
	return array
}

func parameterOrReferenceMapToBlocks(parameters map[string]*ParameterOrReference) ([]*light.Block, error) {
	if parameters == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range parameters {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "parameters")
}

func blocksToParameterOrReferenceMap(blocks []*light.Block) (map[string]*ParameterOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*ParameterOrReference)
	for _, block := range blocks {
		able, err := parameterOrReferenceFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Labels[0]] = able
	}
	return hash, nil
}
