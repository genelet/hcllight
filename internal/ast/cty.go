package ast

import (
	"fmt"

	"github.com/hashicorp/hcl/v2/hclsyntax"
	"github.com/zclconf/go-cty/cty"
	"github.com/zclconf/go-cty/cty/function"

	"github.com/zclconf/go-cty/cty/gocty"
)

func xparameterTo(parameter function.Parameter) *CtyParameter {
	return &CtyParameter{
		Name:             parameter.Name,
		Description:      parameter.Description,
		Typ:              xctyTypeTo(parameter.Type),
		AllowNull:        parameter.AllowNull,
		AllowDynamicType: parameter.AllowDynamicType,
		AllowMarked:      parameter.AllowMarked,
	}
}

func parameterTo(parameter *CtyParameter) function.Parameter {
	return function.Parameter{
		Name:             parameter.Name,
		Description:      parameter.Description,
		Type:             ctyTypeTo(parameter.Typ),
		AllowNull:        parameter.AllowNull,
		AllowDynamicType: parameter.AllowDynamicType,
		AllowMarked:      parameter.AllowMarked,
	}
}

func xfunctionTo(fn function.Function) *CtyFunction {
	description := fn.Description()
	var params []*CtyParameter
	for _, v := range fn.Params() {
		params = append(params, xparameterTo(v))
	}

	output := &CtyFunction{
		Description: description,
		Parameters:  params,
	}
	if vp := fn.VarParam(); vp != nil { // pointer
		output.VarParam = xparameterTo(*vp)
	}

	return output
}

func functionTo(fn *CtyFunction) function.Function {
	var params []function.Parameter
	for _, v := range fn.Parameters {
		params = append(params, parameterTo(v))
	}

	spec := &function.Spec{
		Description: fn.Description,
		Params:      params,
	}
	if fn.VarParam != nil {
		vp := parameterTo(fn.VarParam)
		spec.VarParam = &vp
	}
	return function.New(spec)
}

func xoperationTo(op *hclsyntax.Operation) *Operation {
	if op == nil {
		return nil
	}

	output := &Operation{
		Sign: TokenType_TokenUnknown,
	}

	switch op {
	case hclsyntax.OpLogicalOr:
		output.Sign = TokenType_Or
	case hclsyntax.OpLogicalAnd:
		output.Sign = TokenType_And
	case hclsyntax.OpEqual:
		output.Sign = TokenType_EqualOp
	case hclsyntax.OpNotEqual:
		output.Sign = TokenType_NotEqual
	case hclsyntax.OpGreaterThan:
		output.Sign = TokenType_GreaterThan
	case hclsyntax.OpGreaterThanOrEqual:
		output.Sign = TokenType_GreaterThanEq
	case hclsyntax.OpLessThan:
		output.Sign = TokenType_LessThan
	case hclsyntax.OpLessThanOrEqual:
		output.Sign = TokenType_LessThanEq
	case hclsyntax.OpAdd:
		output.Sign = TokenType_Plus
	case hclsyntax.OpSubtract:
		output.Sign = TokenType_Minus
	case hclsyntax.OpMultiply:
		output.Sign = TokenType_Star
	case hclsyntax.OpDivide:
		output.Sign = TokenType_Slash
	case hclsyntax.OpModulo:
		output.Sign = TokenType_Percent
	case hclsyntax.OpNegate:
	default:
		output.Typ = xctyTypeTo(op.Type)
		output.Impl = xfunctionTo(op.Impl)
	}

	return output
}

func operationTo(op *Operation) *hclsyntax.Operation {
	if op == nil {
		return nil
	}

	switch op.Sign {
	case TokenType_Or:
		return hclsyntax.OpLogicalOr
	case TokenType_And:
		return hclsyntax.OpLogicalAnd
	case TokenType_EqualOp:
		return hclsyntax.OpEqual
	case TokenType_NotEqual:
		return hclsyntax.OpNotEqual
	case TokenType_GreaterThan:
		return hclsyntax.OpGreaterThan
	case TokenType_GreaterThanEq:
		return hclsyntax.OpGreaterThanOrEqual
	case TokenType_LessThan:
		return hclsyntax.OpLessThan
	case TokenType_LessThanEq:
		return hclsyntax.OpLessThanOrEqual
	case TokenType_Plus:
		return hclsyntax.OpAdd
	case TokenType_Minus:
		return hclsyntax.OpSubtract
	case TokenType_Star:
		return hclsyntax.OpMultiply
	case TokenType_Slash:
		return hclsyntax.OpDivide
	case TokenType_Percent:
		return hclsyntax.OpModulo
	default:
	}

	return &hclsyntax.Operation{
		Type: ctyTypeTo(op.Typ),
		Impl: functionTo(op.Impl),
	}
}

func xctyValueTo(val cty.Value) (*CtyValue, error) {
	ty := val.Type()
	switch ty {
	case cty.String:
		var v string
		err := gocty.FromCtyValue(val, &v)
		if err != nil {
			return nil, err
		}
		return &CtyValue{
			CtyValueClause: &CtyValue_StringValue{StringValue: v},
		}, nil
	case cty.Number:
		var v float64
		err := gocty.FromCtyValue(val, &v)
		if err != nil {
			return nil, err
		}
		return &CtyValue{
			CtyValueClause: &CtyValue_NumberValue{NumberValue: v},
		}, nil

	case cty.Bool:
		var v bool
		err := gocty.FromCtyValue(val, &v)
		if err != nil {
			return nil, err
		}
		return &CtyValue{
			CtyValueClause: &CtyValue_BoolValue{BoolValue: v},
		}, nil
	default:
	}

	switch {
	case ty.IsListType(), ty.IsTupleType(), ty.IsSetType():
		var output []*CtyValue
		for _, v := range val.AsValueSlice() {
			u, err := xctyValueTo(v)
			if err != nil {
				return nil, err
			}
			output = append(output, u)
		}
		return &CtyValue{
			CtyValueClause: &CtyValue_ListValue{ListValue: &CtyList{Values: output}},
		}, nil
	case ty.IsMapType(), ty.IsObjectType():
		output := map[string]*CtyValue{}
		for k, v := range val.AsValueMap() {
			u, err := xctyValueTo(v)
			if err != nil {
				return nil, err
			}
			output[k] = u
		}
		return &CtyValue{
			CtyValueClause: &CtyValue_MapValue{MapValue: &CtyMap{Values: output}},
		}, nil
	default:
	}
	return nil, fmt.Errorf("cty value %#v not implementned", val)
}

func CtyValueTo(val *CtyValue) (cty.Value, error) {
	if val == nil {
		return cty.NilVal, nil
	}

	switch t := val.CtyValueClause.(type) {
	case *CtyValue_StringValue:
		return cty.StringVal(t.StringValue), nil
	case *CtyValue_NumberValue:
		return cty.NumberFloatVal(t.NumberValue), nil
	case *CtyValue_BoolValue:
		return cty.BoolVal(t.BoolValue), nil
	case *CtyValue_ListValue:
		var output []cty.Value
		for _, v := range t.ListValue.Values {
			u, err := CtyValueTo(v)
			if err != nil {
				return cty.NilVal, err
			}
			output = append(output, u)
		}
		return cty.ListVal(output), nil
	case *CtyValue_MapValue:
		output := make(map[string]cty.Value)
		for k, v := range t.MapValue.Values {
			u, err := CtyValueTo(v)
			if err != nil {
				return cty.NilVal, err
			}
			output[k] = u
		}
		return cty.MapVal(output), nil
	default:
	}
	return cty.NilVal, fmt.Errorf("primitive value %#v not implementned", val)
}

func xctyTypeTo(typ cty.Type) CtyType {
	switch typ {
	case cty.Bool:
		return CtyType_Bool
	case cty.Number:
		return CtyType_Number
	case cty.String:
		return CtyType_String
	case cty.List(cty.Bool), cty.List(cty.Number), cty.List(cty.String), cty.List(cty.DynamicPseudoType), cty.Set(cty.Bool), cty.Set(cty.Number), cty.Set(cty.String), cty.Set(cty.DynamicPseudoType):
		return CtyType_List
	case cty.Map(cty.Bool), cty.Map(cty.Number), cty.Map(cty.String), cty.Map(cty.DynamicPseudoType):
		return CtyType_Map
	default:
	}
	return CtyType_CtyUnknown
}

func ctyTypeTo(typ CtyType) cty.Type {
	switch typ {
	case CtyType_Bool:
		return cty.Bool
	case CtyType_Number:
		return cty.Number
	case CtyType_String:
		return cty.String
	case CtyType_List:
		return cty.List(cty.DynamicPseudoType)
	case CtyType_Map:
		return cty.Map(cty.DynamicPseudoType)
	default:
	}
	return cty.NilType
}
