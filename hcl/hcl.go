package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func isCommon(s *openapiv3.Schema) bool {
	return s.Type != "" || s.Format != "" || s.Default != nil || s.Enum != nil
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

func isRest(s *openapiv3.Schema) bool {
	return s.Nullable || s.Discriminator != nil || s.ReadOnly || s.WriteOnly || s.Xml != nil || s.ExternalDocs != nil || s.Example != nil || s.Deprecated || s.Title != "" || s.Description != "" || s.AllOf != nil || s.OneOf != nil || s.AnyOf != nil || s.Not != nil || (s.SpecificationExtension != nil && len(s.SpecificationExtension) > 0)
}

func isFull(s *openapiv3.Schema) bool {
	if isRest(s) || !isCommon(s) {
		return true
	}

	switch s.Type {
	case "boolean":
		return isString(s) || isNumber(s) || isArray(s) || isObject(s) || isMap(s)
	case "number", "integer":
		return isString(s) || isArray(s) || isObject(s) || isMap(s)
	case "string":
		return isNumber(s) || isArray(s) || isObject(s) || isMap(s)
	case "array":
		return isString(s) || isNumber(s) || isObject(s) || isMap(s)
	case "object":
		if s.AdditionalProperties != nil {
			return isString(s) || isNumber(s) || isArray(s) || isObject(s)
		} else {
			return isString(s) || isNumber(s) || isArray(s) || isMap(s)
		}
	default:
	}
	return true
}
