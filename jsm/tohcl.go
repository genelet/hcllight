package jsm

import (
	"github.com/google/gnostic/jsonschema"
)

func ToHcl(s *jsonschema.Schema) *Schema {
	if s == nil {
		return nil
	}

	if isFull(s) {
		return schemaFullToHcl(s)
	}

	if s.Ref != nil {
		return &Schema{
			Reference: referenceToHcl(s),
		}
	}

	common := commonToHcl(s)

	switch *s.Type.String {
	case "boolean":
		return &Schema{
			Common: common,
		}
	case "number", "integer":
		return &Schema{
			Common:       common,
			SchemaNumber: numberToHcl(s),
		}
	case "string":
		return &Schema{
			Common:       common,
			SchemaString: stringToHcl(s),
		}
	case "array":
		return &Schema{
			Common:      common,
			SchemaArray: arrayToHcl(s),
		}
	case "object":
		if isMap(s) && !isObject(s) {
			typ := "map"
			common.Type.String = &typ
			return &Schema{
				Common:    common,
				SchemaMap: mapToHcl(s),
			}
		}

		return &Schema{
			Common:       common,
			SchemaObject: objectToHcl(s),
		}
	default:
	}

	return schemaFullToHcl(s)
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

func sliceToHcl(allof *[]*jsonschema.Schema) []*Schema {
	if allof == nil {
		return nil
	}
	var arr []*Schema
	for _, v := range *allof {
		arr = append(arr, ToHcl(v))
	}
	return arr
}

func referenceToHcl(s *jsonschema.Schema) *Reference {
	if s == nil || !isReference(s) {
		return nil
	}
	return &Reference{
		Ref: s.Ref,
	}
}

func commonToHcl(s *jsonschema.Schema) *Common {
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

	items := new(SchemaOrSchemaArray)
	if s.Items != nil {
		if s.Items.Schema != nil {
			items.Schema = ToHcl(s.Items.Schema)
		} else {
			items.SchemaArray = sliceToHcl(s.Items.SchemaArray)
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

func schemaFullToHcl(s *jsonschema.Schema) *Schema {
	full := &SchemaFull{
		Schema:            s.Schema,
		ID:                s.ID,
		ReadOnly:          s.ReadOnly,
		WriteOnly:         s.WriteOnly,
		PatternProperties: namedSchemaArrayToMap(s.PatternProperties),
		Dependencies:      namedSchemaOrStringArrayArrayToMap(s.Dependencies),

		Reference:    referenceToHcl(s),
		Common:       commonToHcl(s),
		SchemaNumber: numberToHcl(s),
		SchemaString: stringToHcl(s),
		SchemaArray:  arrayToHcl(s),
		SchemaMap:    mapToHcl(s),
		SchemaObject: objectToHcl(s),

		AllOf:       sliceToHcl(s.AllOf),
		AnyOf:       sliceToHcl(s.AnyOf),
		OneOf:       sliceToHcl(s.OneOf),
		Not:         ToHcl(s.Not),
		Definitions: namedSchemaArrayToMap(s.Definitions),

		Title:       s.Title,
		Description: s.Description,
	}
	if s.AdditionalItems != nil {
		if s.AdditionalItems.Schema != nil {
			full.AdditionalItems = &SchemaOrBoolean{
				Schema: ToHcl(s.AdditionalItems.Schema),
			}
		} else {
			full.AdditionalItems = &SchemaOrBoolean{
				Boolean: s.AdditionalItems.Boolean,
			}
		}
	}
	return &Schema{
		SchemaFull: full,
		isFull:     true,
	}
}
