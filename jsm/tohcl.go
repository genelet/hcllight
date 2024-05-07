package jsm

import (
	"github.com/google/gnostic/jsonschema"
)

func ToHcl(s *jsonschema.Schema) *Schema {
	if s == nil {
		return nil
	}

	if check(s) {
		return schemaFull2Hcl(s)
	}

	if s.Ref != nil {
		return &Schema{
			Reference: &Reference{
				Ref: s.Ref,
			},
		}
	}

	common := common2Hcl(s)

	switch *s.Type.String {
	case "boolean":
		return &Schema{
			Common: common,
		}
	case "number":
		return &Schema{
			Common: common,
			SchemaNumber: &SchemaNumber{
				MultipleOf:       s.MultipleOf,
				Maximum:          s.Maximum,
				ExclusiveMaximum: s.ExclusiveMaximum,
				Minimum:          s.Minimum,
				ExclusiveMinimum: s.ExclusiveMinimum,
			},
		}
	case "integer":
		return &Schema{
			Common: common,
			SchemaInteger: &SchemaInteger{
				MultipleOf:       s.MultipleOf.Integer,
				Maximum:          s.Maximum.Integer,
				ExclusiveMaximum: s.ExclusiveMaximum,
				Minimum:          s.Minimum.Integer,
				ExclusiveMinimum: s.ExclusiveMinimum,
			},
		}
	case "string":
		return &Schema{
			Common: common,
			SchemaString: &SchemaString{
				MaxLength: s.MaxLength,
				MinLength: s.MinLength,
				Pattern:   s.Pattern,
			},
		}
	case "array":
		var items *SchemaOrSchemaArray
		if s.Items.Schema != nil {
			items = &SchemaOrSchemaArray{
				Schema: ToHcl(s.Items.Schema),
			}
		} else {
			for _, v := range *s.Items.SchemaArray {
				items.SchemaArray = append(items.SchemaArray, ToHcl(v))
			}
		}
		return &Schema{
			SchemaArray: &SchemaArray{
				Items:       items,
				MaxItems:    s.MaxItems,
				MinItems:    s.MinItems,
				UniqueItems: s.UniqueItems,
			},
		}
	case "object":
		if s.Properties == nil && s.AdditionalProperties != nil {
			return &Schema{
				SchemaMap: &SchemaMap{
					AdditionalProperties: &SchemaOrBoolean{
						Schema:  ToHcl(s.AdditionalProperties.Schema),
						Boolean: s.AdditionalProperties.Boolean,
					},
				},
			}
		} else if s.Properties == nil {
			return nil
		}

		object := &SchemaObject{
			MaxProperties: s.MaxProperties,
			MinProperties: s.MinProperties,
			Properties:    namedSchemaArrayToMap(s.Properties),
		}
		if s.Required != nil {
			object.Required = *s.Required
		}
		return &Schema{
			SchemaObject: object,
		}
	default:
	}

	return schemaFull2Hcl(s)
}

func namedSchemaArrayToMap(s *[]*jsonschema.NamedSchema) map[string]*Schema {
	if s == nil {
		return nil
	}
	m := make(map[string]*Schema)
	for _, v := range *s {
		m[v.Name] = ToHcl(v.Value)
	}
	return m
}

func namedSchemaOrStringArrayArrayToMap(s *[]*jsonschema.NamedSchemaOrStringArray) map[string]*SchemaOrStringArray {
	if s == nil {
		return nil
	}
	m := make(map[string]*SchemaOrStringArray)
	for _, v := range *s {
		if v.Value.Schema != nil {
			m[v.Name] = &SchemaOrStringArray{
				Schema: ToHcl(v.Value.Schema),
			}
		} else {
			var arr []string
			for _, v := range *v.Value.StringArray {
				arr = append(arr, v)
			}
			m[v.Name] = &SchemaOrStringArray{
				StringArray: arr,
			}
		}
	}
	return m
}

func referenceToHcl(s *jsonschema.Schema) *Reference {
	if s == nil || !isReference(s) {
		return nil
	}
	return &Reference{
		Ref: s.Ref,
	}
}
func common2Hcl(s *jsonschema.Schema) *Common {
	if s == nil || !isCommon(s) {
		return nil
	}
	common := &Common{
		Type:    s.Type,
		Format:  s.Format,
		Default: s.Default,
	}
	if s.Enumeration != nil {
		common.Enumeration = *s.Enumeration
	}
	return common
}

func stringToHcl(s *jsonschema.Schema) *SchemaString {
	if s == nil || !isString(s) {
		return nil
	}

	return &SchemaString{
		MaxLength: s.MaxLength,
		MinLength: s.MinLength,
		Pattern:   s.Pattern,
	}
}

func numberToHcl(s *jsonschema.Schema) *SchemaNumber {
	if s == nil || !isNumber(s) {
		return nil
	}

	return &SchemaNumber{
		MultipleOf:       s.MultipleOf,
		Maximum:          s.Maximum,
		ExclusiveMaximum: s.ExclusiveMaximum,
		Minimum:          s.Minimum,
		ExclusiveMinimum: s.ExclusiveMinimum,
	}
}

func arrayToHcl(s *jsonschema.Schema) *SchemaArray {
	if s == nil || !isArray(s) {
		return nil
	}

	var items *SchemaOrSchemaArray
	if s.Items.Schema != nil {
		items = &SchemaOrSchemaArray{
			Schema: ToHcl(s.Items.Schema),
		}
	} else {
		for _, v := range *s.Items.SchemaArray {
			items.SchemaArray = append(items.SchemaArray, ToHcl(v))
		}
	}

	return &SchemaArray{
		Items:       items,
		MaxItems:    s.MaxItems,
		MinItems:    s.MinItems,
		UniqueItems: s.UniqueItems,
	}
}

func mapToHcl(s *jsonschema.Schema) *SchemaMap {
	if s == nil || !isMap(s) {
		return nil
	}

	return &SchemaMap{
		AdditionalProperties: &SchemaOrBoolean{
			Schema:  ToHcl(s.AdditionalProperties.Schema),
			Boolean: s.AdditionalProperties.Boolean,
		},
	}
}

func objectToHcl(s *jsonschema.Schema) *SchemaObject {
	if s == nil || !isObject(s) {
		return nil
	}

	object := &SchemaObject{
		MaxProperties: s.MaxProperties,
		MinProperties: s.MinProperties,
		Properties:    namedSchemaArrayToMap(s.Properties),
	}
	if s.Required != nil {
		object.Required = *s.Required
	}
	return object
}

func schemaFull2Hcl(s *jsonschema.Schema) *Schema {
	var allOf []*Schema
	for _, v := range *s.AllOf {
		allOf = append(allOf, ToHcl(v))
	}
	var anyOf []*Schema
	for _, v := range *s.AnyOf {
		anyOf = append(anyOf, ToHcl(v))
	}
	var oneOf []*Schema
	for _, v := range *s.OneOf {
		oneOf = append(oneOf, ToHcl(v))
	}
	var definitions map[string]*Schema
	for _, v := range *s.Definitions {
		definitions[v.Name] = ToHcl(v.Value)
	}
	full := &SchemaFull{
		Schema:            s.Schema,
		ID:                s.ID,
		ReadOnly:          s.ReadOnly,
		WriteOnly:         s.WriteOnly,
		PatternProperties: namedSchemaArrayToMap(s.PatternProperties),
		Dependencies:      namedSchemaOrStringArrayArrayToMap(s.Dependencies),

		AllOf:       allOf,
		AnyOf:       anyOf,
		OneOf:       oneOf,
		Not:         ToHcl(s.Not),
		Definitions: definitions,

		Title:       s.Title,
		Description: s.Description,
	}
	if x := referenceToHcl(s); x != nil {
		full.Reference = *x
	}
	if x := stringToHcl(s); x != nil {
		full.SchemaString = *x
	}
	if x := numberToHcl(s); x != nil {
		full.SchemaNumber = *x
	}
	if x := arrayToHcl(s); x != nil {
		full.SchemaArray = *x
	}
	if s.AdditionalItems != nil {
		full.AdditionalItems = &SchemaOrBoolean{
			Schema:  ToHcl(s.AdditionalItems.Schema),
			Boolean: s.AdditionalItems.Boolean,
		}
	}
	if x := mapToHcl(s); x != nil {
		full.SchemaMap = *x
	}
	if x := objectToHcl(s); x != nil {
		full.SchemaObject = *x
	}

	return &Schema{
		SchemaFull: full,
	}
}
