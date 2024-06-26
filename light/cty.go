package light

import (
	"fmt"

	"github.com/genelet/hcllight/internal/ast"
)

func xparameterTo(parameter *CtyParameter) *ast.CtyParameter {
	return &ast.CtyParameter{
		Name:             parameter.Name,
		Description:      parameter.Description,
		Typ:              xctyTypeTo(parameter.Typ),
		AllowNull:        parameter.AllowNull,
		AllowDynamicType: parameter.AllowDynamicType,
		AllowMarked:      parameter.AllowMarked,
	}
}

func parameterTo(parameter *ast.CtyParameter) *CtyParameter {
	return &CtyParameter{
		Name:             parameter.Name,
		Description:      parameter.Description,
		Typ:              ctyTypeTo(parameter.Typ),
		AllowNull:        parameter.AllowNull,
		AllowDynamicType: parameter.AllowDynamicType,
		AllowMarked:      parameter.AllowMarked,
	}
}

func xfunctionTo(fn *CtyFunction) *ast.CtyFunction {
	var params []*ast.CtyParameter
	for _, v := range fn.Parameters {
		params = append(params, xparameterTo(v))
	}

	output := &ast.CtyFunction{
		Description: fn.Description,
		Parameters:  params,
	}
	if vp := fn.VarParam; vp != nil { // pointer
		output.VarParam = xparameterTo(vp)
	}

	return output
}

func functionTo(fn *ast.CtyFunction) *CtyFunction {
	if fn == nil {
		return nil
	}
	var params []*CtyParameter
	for _, v := range fn.Parameters {
		params = append(params, parameterTo(v))
	}

	output := &CtyFunction{
		Description: fn.Description,
		Parameters:  params,
	}
	if vp := fn.VarParam; vp != nil {
		output.VarParam = parameterTo(vp)
	}

	return output
}

func xoperationTo(op *Operation) *ast.Operation {
	if op == nil {
		return nil
	}

	if op.Sign != TokenType_TokenUnknown {
		return &ast.Operation{
			Sign: ast.TokenType(op.Sign),
		}
	}
	return &ast.Operation{
		Typ:  xctyTypeTo(op.Typ),
		Impl: xfunctionTo(op.Impl),
		Sign: ast.TokenType_TokenUnknown,
	}
}

func operationTo(op *ast.Operation) *Operation {
	if op == nil {
		return nil
	}

	if op.Sign != ast.TokenType(TokenType_TokenUnknown) {
		return &Operation{
			Sign: TokenType(op.Sign),
		}
	}

	return &Operation{
		Typ:  ctyTypeTo(op.Typ),
		Impl: functionTo(op.Impl),
		Sign: TokenType_TokenUnknown,
	}
}

func xctyValueTo(val *CtyValue) (*ast.CtyValue, error) {
	if val == nil {
		return nil, nil
	}

	switch t := val.CtyValueClause.(type) {
	case *CtyValue_StringValue:
		return &ast.CtyValue{
			CtyValueClause: &ast.CtyValue_StringValue{StringValue: t.StringValue},
		}, nil
	case *CtyValue_NumberValue:
		return &ast.CtyValue{
			CtyValueClause: &ast.CtyValue_NumberValue{NumberValue: t.NumberValue},
		}, nil
	case *CtyValue_BoolValue:
		return &ast.CtyValue{
			CtyValueClause: &ast.CtyValue_BoolValue{BoolValue: t.BoolValue},
		}, nil
	case *CtyValue_ListValue:
		var output []*ast.CtyValue
		for _, v := range t.ListValue.Values {
			u, err := xctyValueTo(v)
			if err != nil {
				return nil, err
			}
			output = append(output, u)
		}
		return &ast.CtyValue{
			CtyValueClause: &ast.CtyValue_ListValue{ListValue: &ast.CtyList{Values: output}},
		}, nil
	case *CtyValue_MapValue:
		output := make(map[string]*ast.CtyValue)
		for k, v := range t.MapValue.Values {
			u, err := xctyValueTo(v)
			if err != nil {
				return nil, err
			}
			output[k] = u
		}
		return &ast.CtyValue{
			CtyValueClause: &ast.CtyValue_MapValue{MapValue: &ast.CtyMap{Values: output}},
		}, nil
	default:
	}
	return nil, fmt.Errorf("primitive value %#v not implementned", val)
}

func ctyValueTo(val *ast.CtyValue) (*CtyValue, error) {
	if val == nil {
		return nil, nil
	}

	switch t := val.CtyValueClause.(type) {
	case *ast.CtyValue_StringValue:
		return &CtyValue{
			CtyValueClause: &CtyValue_StringValue{StringValue: t.StringValue},
		}, nil
	case *ast.CtyValue_NumberValue:
		return &CtyValue{
			CtyValueClause: &CtyValue_NumberValue{NumberValue: t.NumberValue},
		}, nil
	case *ast.CtyValue_BoolValue:
		return &CtyValue{
			CtyValueClause: &CtyValue_BoolValue{BoolValue: t.BoolValue},
		}, nil
	case *ast.CtyValue_ListValue:
		var output []*CtyValue
		for _, v := range t.ListValue.Values {
			u, err := ctyValueTo(v)
			if err != nil {
				return nil, err
			}
			output = append(output, u)
		}
		return &CtyValue{
			CtyValueClause: &CtyValue_ListValue{ListValue: &CtyList{Values: output}},
		}, nil
	case *ast.CtyValue_MapValue:
		output := make(map[string]*CtyValue)
		for k, v := range t.MapValue.Values {
			u, err := ctyValueTo(v)
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
	return nil, fmt.Errorf("primitive value %#v not implementned", val)
}

func xctyTypeTo(typ CtyType) ast.CtyType {
	switch typ {
	case CtyType_Bool:
		return ast.CtyType_Bool
	case CtyType_Number:
		return ast.CtyType_Number
	case CtyType_String:
		return ast.CtyType_String
	case CtyType_List:
		return ast.CtyType_List
	case CtyType_Map:
		return ast.CtyType_Map
	default:
	}
	return ast.CtyType_CtyUnknown
}

func ctyTypeTo(typ ast.CtyType) CtyType {
	switch typ {
	case ast.CtyType_Bool:
		return CtyType_Bool
	case ast.CtyType_Number:
		return CtyType_Number
	case ast.CtyType_String:
		return CtyType_String
	case ast.CtyType_List:
		return CtyType_List
	case ast.CtyType_Map:
		return CtyType_Map
	default:
	}
	return CtyType_Unknown
}
