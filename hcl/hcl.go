package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func isCommon(s *openapiv3.Schema) bool {
	return s.Type != "" || s.Format != "" || s.Default != nil || s.Enum != nil || s.Example != nil || s.Description != "" || s.ReadOnly || s.WriteOnly || s.Nullable || s.Deprecated
}
func isNumber(s *openapiv3.Schema) bool {
	return s.MultipleOf != 0 || s.Maximum != 0 || s.ExclusiveMaximum || s.Minimum != 0 || s.ExclusiveMinimum
}

func isString(s *openapiv3.Schema) bool {
	return s.MaxLength != 0 || s.MinLength != 0 || s.Pattern != ""
}

func isArray(s *openapiv3.Schema) bool {
	return s.Items != nil || s.MaxItems != 0 || s.MinItems != 0 || s.UniqueItems
}
func isObject(s *openapiv3.Schema) bool {
	return s.MaxProperties != 0 || s.MinProperties != 0 || (s.Properties != nil && len(s.Properties.AdditionalProperties) > 0) || (s.Required != nil && len(s.Required) > 0)
}

func isMap(s *openapiv3.Schema) bool {
	return s.AdditionalProperties != nil
}

func isAllOf(s *openapiv3.Schema) bool {
	return s.AllOf != nil
}

func isOneOf(s *openapiv3.Schema) bool {
	return s.OneOf != nil
}

func isAnyOf(s *openapiv3.Schema) bool {
	return s.AnyOf != nil
}

func isRest(s *openapiv3.Schema) bool {
	return s.Discriminator != nil || s.Xml != nil || s.ExternalDocs != nil || s.Title != "" || s.Not != nil || (s.SpecificationExtension != nil && len(s.SpecificationExtension) > 0)
}

func isFull(s *openapiv3.Schema) bool {
	if isRest(s) {
		return true
	}

	if !isCommon(s) {
		return isString(s) || isNumber(s) || isArray(s) || isObject(s) || isMap(s) || (isAllOf(s) && isOneOf(s)) || (isAllOf(s) && isAnyOf(s)) || (isOneOf(s) && isAnyOf(s))
	}

	switch s.Type {
	case "boolean":
		return isString(s) || isNumber(s) || isArray(s) || isObject(s) || isMap(s) || isAllOf(s) || isOneOf(s) || isAnyOf(s)
	case "number", "integer":
		return isString(s) || isArray(s) || isObject(s) || isMap(s) || isAllOf(s) || isOneOf(s) || isAnyOf(s)
	case "string":
		return isNumber(s) || isArray(s) || isObject(s) || isMap(s) || isAllOf(s) || isOneOf(s) || isAnyOf(s)
	case "array":
		return isString(s) || isNumber(s) || isObject(s) || isMap(s) || isAllOf(s) || isOneOf(s) || isAnyOf(s)
	case "object":
		if s.AdditionalProperties != nil {
			return isString(s) || isNumber(s) || isArray(s) || isObject(s) || isAllOf(s) || isOneOf(s) || isAnyOf(s)
		} else {
			return isString(s) || isNumber(s) || isArray(s) || isMap(s) || isAllOf(s) || isOneOf(s) || isAnyOf(s)
		}
	default:
	}

	return true
}
