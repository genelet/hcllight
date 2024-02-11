package light

import (
	"fmt"

	"github.com/genelet/hcllight/generated"
	"github.com/genelet/hcllight/internal/ast"
)

func xparameterTo(parameter *generated.CtyParameter) *ast.CtyParameter {
	return &ast.CtyParameter{
		Name:             parameter.Name,
		Description:      parameter.Description,
		Typ:              xctyTypeTo(parameter.Typ),
		AllowNull:        parameter.AllowNull,
		AllowDynamicType: parameter.AllowDynamicType,
		AllowMarked:      parameter.AllowMarked,
	}
}

func parameterTo(parameter *ast.CtyParameter) *generated.CtyParameter {
	return &generated.CtyParameter{
		Name:             parameter.Name,
		Description:      parameter.Description,
		Typ:              ctyTypeTo(parameter.Typ),
		AllowNull:        parameter.AllowNull,
		AllowDynamicType: parameter.AllowDynamicType,
		AllowMarked:      parameter.AllowMarked,
	}
}

func xfunctionTo(fn *generated.CtyFunction) *ast.CtyFunction {
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

func functionTo(fn *ast.CtyFunction) *generated.CtyFunction {
	var params []*generated.CtyParameter
	for _, v := range fn.Parameters {
		params = append(params, parameterTo(v))
	}

	output := &generated.CtyFunction{
		Description: fn.Description,
		Parameters:  params,
	}
	if vp := fn.VarParam; vp != nil {
		output.VarParam = parameterTo(vp)
	}

	return output
}

func xoperationTo(op *generated.Operation) *ast.Operation {
	if op == nil {
		return nil
	}

	if op.Sign != generated.TokenType_TokenUnknown {
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

func operationTo(op *ast.Operation) *generated.Operation {
	if op == nil {
		return nil
	}

	if op.Sign != ast.TokenType(generated.TokenType_TokenUnknown) {
		return &generated.Operation{
			Sign: generated.TokenType(op.Sign),
		}
	}

	return &generated.Operation{
		Typ:  ctyTypeTo(op.Typ),
		Impl: functionTo(op.Impl),
		Sign: generated.TokenType_TokenUnknown,
	}
}

func xctyValueTo(val *generated.CtyValue) (*ast.CtyValue, error) {
	if val == nil {
		return nil, nil
	}

	switch t := val.CtyValueClause.(type) {
	case *generated.CtyValue_StringValue:
		return &ast.CtyValue{
			CtyValueClause: &ast.CtyValue_StringValue{StringValue: t.StringValue},
		}, nil
	case *generated.CtyValue_NumberValue:
		return &ast.CtyValue{
			CtyValueClause: &ast.CtyValue_NumberValue{NumberValue: t.NumberValue},
		}, nil
	case *generated.CtyValue_BoolValue:
		return &ast.CtyValue{
			CtyValueClause: &ast.CtyValue_BoolValue{BoolValue: t.BoolValue},
		}, nil
	case *generated.CtyValue_ListValue:
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
	case *generated.CtyValue_MapValue:
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

func ctyValueTo(val *ast.CtyValue) (*generated.CtyValue, error) {
	if val == nil {
		return nil, nil
	}

	switch t := val.CtyValueClause.(type) {
	case *ast.CtyValue_StringValue:
		return &generated.CtyValue{
			CtyValueClause: &generated.CtyValue_StringValue{StringValue: t.StringValue},
		}, nil
	case *ast.CtyValue_NumberValue:
		return &generated.CtyValue{
			CtyValueClause: &generated.CtyValue_NumberValue{NumberValue: t.NumberValue},
		}, nil
	case *ast.CtyValue_BoolValue:
		return &generated.CtyValue{
			CtyValueClause: &generated.CtyValue_BoolValue{BoolValue: t.BoolValue},
		}, nil
	case *ast.CtyValue_ListValue:
		var output []*generated.CtyValue
		for _, v := range t.ListValue.Values {
			u, err := ctyValueTo(v)
			if err != nil {
				return nil, err
			}
			output = append(output, u)
		}
		return &generated.CtyValue{
			CtyValueClause: &generated.CtyValue_ListValue{ListValue: &generated.CtyList{Values: output}},
		}, nil
	case *ast.CtyValue_MapValue:
		output := make(map[string]*generated.CtyValue)
		for k, v := range t.MapValue.Values {
			u, err := ctyValueTo(v)
			if err != nil {
				return nil, err
			}
			output[k] = u
		}
		return &generated.CtyValue{
			CtyValueClause: &generated.CtyValue_MapValue{MapValue: &generated.CtyMap{Values: output}},
		}, nil
	default:
	}
	return nil, fmt.Errorf("primitive value %#v not implementned", val)
}

func xctyTypeTo(typ generated.CtyType) ast.CtyType {
	switch typ {
	case generated.CtyType_Bool:
		return ast.CtyType_Bool
	case generated.CtyType_Number:
		return ast.CtyType_Number
	case generated.CtyType_String:
		return ast.CtyType_String
	case generated.CtyType_List:
		return ast.CtyType_List
	case generated.CtyType_Map:
		return ast.CtyType_Map
	default:
	}
	return ast.CtyType_CtyUnknown
}

func ctyTypeTo(typ ast.CtyType) generated.CtyType {
	switch typ {
	case ast.CtyType_Bool:
		return generated.CtyType_Bool
	case ast.CtyType_Number:
		return generated.CtyType_Number
	case ast.CtyType_String:
		return generated.CtyType_String
	case ast.CtyType_List:
		return generated.CtyType_List
	case ast.CtyType_Map:
		return generated.CtyType_Map
	default:
	}
	return generated.CtyType_Unknown
}
