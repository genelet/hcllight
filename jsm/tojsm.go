package jsm

import (
	"github.com/google/gnostic/jsonschema"
)

func ToJSM(s *Schema) *jsonschema.Schema {
	if s == nil {
		return nil
	}
	if s.isFull {
		return schemaFullToJSM(s)
	}

	if s.Reference != nil {
		return referenceToJSM(s.Reference)
	}

	schema := commonToJSM(s)

	if s.SchemaString != nil {
		return stringToJSM(schema, s.SchemaString)
	}
	if s.SchemaNumber != nil {
		return numberToJSM(schema, s.SchemaNumber)
	}
	if s.SchemaArray != nil {
		return arrayToJSM(schema, s.SchemaArray)
	}
	if s.SchemaObject != nil {
		return objectToJSM(schema, s.SchemaObject)
	}
	if s.SchemaMap != nil {
		return mapToJSM(schema, s.SchemaMap)
	}
	// boolean
	return schema
}

func mapToNamedSchemaArray(s map[string]*Schema) *[]*jsonschema.NamedSchema {
	if s == nil {
		return nil
	}
	var arr []*jsonschema.NamedSchema
	for k, v := range s {
		arr = append(arr, &jsonschema.NamedSchema{
			Name:  k,
			Value: ToJSM(v),
		})
	}
	return &arr
}

func mapToNamedSchemaOrStringArrayArray(s map[string]*SchemaOrStringArray) *[]*jsonschema.NamedSchemaOrStringArray {
	if s == nil {
		return nil
	}
	var arr []*jsonschema.NamedSchemaOrStringArray
	for k, v := range s {
		if v.Schema != nil {
			arr = append(arr, &jsonschema.NamedSchemaOrStringArray{
				Name: k,
				Value: &jsonschema.SchemaOrStringArray{
					Schema: ToJSM(v.Schema),
				},
			})
		} else {
			var sa []string
			for _, str := range v.StringArray {
				sa = append(sa, str)
			}
			arr = append(arr, &jsonschema.NamedSchemaOrStringArray{
				Name: k,
				Value: &jsonschema.SchemaOrStringArray{
					StringArray: &sa,
				},
			})
		}
	}
	return &arr
}

func sliceToJSM(allof []*Schema) *[]*jsonschema.Schema {
	if allof == nil {
		return nil
	}
	var arr []*jsonschema.Schema
	for _, v := range allof {
		arr = append(arr, ToJSM(v))
	}
	return &arr
}

func referenceToJSM(r *Reference) *jsonschema.Schema {
	if r == nil {
		return nil
	}
	return &jsonschema.Schema{
		Ref: r.Ref,
	}
}

func commonToJSM(c *Schema) *jsonschema.Schema {
	jsm := &jsonschema.Schema{}
	jsm.Type = c.Type
	jsm.Format = c.Format
	jsm.Default = c.Default
	if c.Enumeration != nil {
		jsm.Enumeration = &c.Enumeration
	}
	return jsm
}

func stringToJSM(jsm *jsonschema.Schema, s *SchemaString) *jsonschema.Schema {
	if s == nil {
		return jsm
	}
	if jsm == nil {
		jsm = &jsonschema.Schema{}
	}

	jsm.MaxLength = s.MaxLength
	jsm.MinLength = s.MinLength
	jsm.Pattern = s.Pattern
	return jsm
}

func numberToJSM(jsm *jsonschema.Schema, n *SchemaNumber) *jsonschema.Schema {
	if n == nil {
		return jsm
	}
	if jsm == nil {
		jsm = &jsonschema.Schema{}
	}

	jsm.MultipleOf = n.MultipleOf
	jsm.Maximum = n.Maximum
	jsm.ExclusiveMaximum = n.ExclusiveMaximum
	jsm.Minimum = n.Minimum
	jsm.ExclusiveMinimum = n.ExclusiveMinimum

	return jsm
}

func arrayToJSM(jsm *jsonschema.Schema, a *SchemaArray) *jsonschema.Schema {
	if a == nil {
		return jsm
	}
	if jsm == nil {
		jsm = &jsonschema.Schema{}
	}

	if a.Items != nil {
		if a.Items.Schema != nil {
			jsm.Items.Schema = ToJSM(a.Items.Schema)
		} else {
			jsm.Items.SchemaArray = sliceToJSM(a.Items.SchemaArray)
		}
	}

	jsm.MaxItems = a.MaxItems
	jsm.MinItems = a.MinItems
	jsm.UniqueItems = a.UniqueItems
	return jsm
}

func objectToJSM(jsm *jsonschema.Schema, o *SchemaObject) *jsonschema.Schema {
	if o == nil {
		return jsm
	}
	if jsm == nil {
		jsm = &jsonschema.Schema{}
	}

	jsm.Properties = mapToNamedSchemaArray(o.Properties)
	jsm.MaxProperties = o.MaxProperties
	jsm.MinProperties = o.MinProperties
	if o.Required != nil {
		jsm.Required = &o.Required
	}
	return jsm
}

func mapToJSM(jsm *jsonschema.Schema, m *SchemaMap) *jsonschema.Schema {
	if m == nil || m.AdditionalProperties == nil {
		return jsm
	}
	if jsm == nil {
		jsm = &jsonschema.Schema{}
	}

	if m.AdditionalProperties.Schema != nil {
		jsm.AdditionalProperties.Schema = ToJSM(m.AdditionalProperties.Schema)
	} else {
		jsm.AdditionalProperties.Boolean = m.AdditionalProperties.Boolean
	}

	return jsm
}

func schemaFullToJSM(s *Schema) *jsonschema.Schema {
	jsm := commonToJSM(s)
	jsm.Schema = s.Schema
	jsm.ID = s.ID
	if s.Reference != nil {
		jsm.Ref = s.Reference.Ref
	}
	jsm.ReadOnly = s.ReadOnly
	jsm.WriteOnly = s.WriteOnly
	jsm = stringToJSM(jsm, s.SchemaString)
	jsm = numberToJSM(jsm, s.SchemaNumber)
	jsm = arrayToJSM(jsm, s.SchemaArray)
	jsm = objectToJSM(jsm, s.SchemaObject)
	jsm = mapToJSM(jsm, s.SchemaMap)

	if s.AdditionalItems != nil {
		if s.AdditionalItems.Schema != nil {
			jsm.AdditionalItems.Schema = ToJSM(s.AdditionalItems.Schema)
		} else {
			jsm.AdditionalItems.Boolean = s.AdditionalItems.Boolean
		}
	}
	jsm.PatternProperties = mapToNamedSchemaArray(s.PatternProperties)
	jsm.Dependencies = mapToNamedSchemaOrStringArrayArray(s.Dependencies)

	jsm.AllOf = sliceToJSM(s.AllOf)
	jsm.AnyOf = sliceToJSM(s.AnyOf)
	jsm.OneOf = sliceToJSM(s.OneOf)
	jsm.Not = ToJSM(s.Not)
	jsm.Definitions = mapToNamedSchemaArray(s.Definitions)

	jsm.Title = s.Title
	jsm.Description = s.Description
	jsm.Format = s.Format
	jsm.Default = s.Default

	return jsm
}
