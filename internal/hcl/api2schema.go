package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func oasCommonToHcl(common *openapiv3.Schema) *OASCommon {
	if common == nil {
		return nil
	}
	if common.ReadOnly || common.WriteOnly || common.Nullable || common.Deprecated == false {
		return &OASCommon{
			ReadOnly:   common.ReadOnly,
			WriteOnly:  common.WriteOnly,
			Nullable:   common.Nullable,
			Deprecated: common.Deprecated,
		}
	}
	return nil
}

func oasSchemaCheck(s *openapiv3.Schema) bool {
	if s == nil {
		return false
	}

	if s.Title != "" || s.Description != "" || s.Xml != nil || s.ExternalDocs != nil || s.Not != nil || s.SpecificationExtension != nil {
		return true
	}

	switch s.Type {
	case "array":
		if s.MultipleOf != 0 ||
			s.Minimum != 0 ||
			s.Maximum != 0 ||
			s.ExclusiveMinimum ||
			s.ExclusiveMaximum ||
			s.Enum != nil ||
			len(s.Enum) == 0 ||
			s.Default != nil ||
			s.Format != "" ||
			s.MaxProperties != 0 ||
			s.MinProperties != 0 ||
			s.Properties != nil ||
			len(s.Properties.AdditionalProperties) != 0 ||
			s.Required != nil ||
			s.AdditionalProperties != nil {
			return true
		}
	case "object":
		if s.MultipleOf != 0 ||
			s.Minimum != 0 ||
			s.Maximum != 0 ||
			s.ExclusiveMinimum ||
			s.ExclusiveMaximum ||
			s.Enum != nil ||
			len(s.Enum) != 0 ||
			s.Default != nil ||
			s.Format != "" ||
			s.Items != nil ||
			len(s.Items.SchemaOrReference) != 0 ||
			s.MaxItems != 0 ||
			s.MinItems != 0 ||
			s.UniqueItems {
			return true
		}
		if s.AdditionalProperties != nil {
			if s.Discriminator != nil ||
				s.Properties != nil ||
				len(s.Properties.AdditionalProperties) != 0 ||
				s.MaxProperties != 0 ||
				s.MinProperties != 0 ||
				s.Required != nil {
				return true
			}
		}
	case "string": // Example ignored
		if s.MultipleOf != 0 ||
			s.Maximum != 0 ||
			s.Minimum != 0 ||
			s.ExclusiveMaximum ||
			s.ExclusiveMinimum ||
			s.MaxProperties != 0 ||
			s.MinProperties != 0 ||
			s.Properties != nil ||
			len(s.Properties.AdditionalProperties) != 0 ||
			s.Required != nil ||
			s.AdditionalProperties != nil ||
			s.Items != nil ||
			len(s.Items.SchemaOrReference) != 0 ||
			s.MaxItems != 0 ||
			s.MinItems != 0 ||
			s.UniqueItems ||
			s.Discriminator != nil {
			return true
		}
	case "number", "integer": // Example ignored
		if s.MinLength != 0 ||
			s.MaxLength != 0 ||
			s.Pattern != "" ||
			s.MaxProperties != 0 ||
			s.MinProperties != 0 ||
			s.Properties != nil ||
			len(s.Properties.AdditionalProperties) != 0 ||
			s.Required != nil ||
			s.AdditionalProperties != nil ||
			s.Items != nil ||
			len(s.Items.SchemaOrReference) != 0 ||
			s.MaxItems != 0 ||
			s.MinItems != 0 ||
			s.UniqueItems ||
			s.Discriminator != nil {
			return true
		}
	case "boolean": // Example, default, & enum ignored
		if s.MultipleOf != 0 ||
			s.MinLength != 0 ||
			s.MaxLength != 0 ||
			s.Pattern != "" ||
			s.Maximum != 0 ||
			s.Minimum != 0 ||
			s.ExclusiveMaximum ||
			s.ExclusiveMinimum ||
			s.MaxProperties != 0 ||
			s.MinProperties != 0 ||
			s.Properties != nil ||
			len(s.Properties.AdditionalProperties) != 0 ||
			s.Required != nil ||
			s.AdditionalProperties != nil ||
			s.Items != nil ||
			len(s.Items.SchemaOrReference) != 0 ||
			s.MaxItems != 0 ||
			s.MinItems != 0 ||
			s.UniqueItems ||
			s.Discriminator != nil {
			return true
		}
	default:
	}
	return false
}

func SchemaOrReferenceToHcl(schema *openapiv3.SchemaOrReference) *SchemaOrReference {
	if schema == nil {
		return nil
	}

	if x := schema.GetReference(); x != nil {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}

	s := schema.GetSchema()
	common := oasCommonToHcl(s)

	if s.AllOf != nil {
		var items []*SchemaOrReference
		for _, v := range s.AllOf {
			items = append(items, SchemaOrReferenceToHcl(v))
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_OasAllof{
				OasAllof: &OASArray{
					Type:  "allof",
					Items: items,
				},
			},
		}
	} else if s.OneOf != nil {
		var items []*SchemaOrReference
		for _, v := range s.OneOf {
			items = append(items, SchemaOrReferenceToHcl(v))
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_OasOneof{
				OasOneof: &OASArray{
					Type:  "oneof",
					Items: items,
				},
			},
		}
	} else if s.AnyOf != nil {
		var items []*SchemaOrReference
		for _, v := range s.AnyOf {
			items = append(items, SchemaOrReferenceToHcl(v))
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_OasAnyof{
				OasAnyof: &OASArray{
					Type:  "anyof",
					Items: items,
				},
			},
		}
	}

	if oasSchemaCheck(s) {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Schema{
				Schema: schemaToHcl(s),
			},
		}
	}

	switch s.Type {
	case "array":
		var items []*SchemaOrReference
		for _, v := range s.Items.SchemaOrReference {
			items = append(items, SchemaOrReferenceToHcl(v))
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Array{
				Array: &OASArray{
					Type:          s.Type,
					Common:        common,
					MaxItems:      s.MaxItems,
					MinItems:      s.MinItems,
					UniqueItems:   s.UniqueItems,
					Discriminator: DiscriminatorToHcl(s.Discriminator),
					Example:       anyToHcl(s.Example),
					Items:         items,
				},
			},
		}
	case "object":
		if s.AdditionalProperties != nil {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_Map{
					Map: &OASMap{
						Type:                 "map",
						Common:               common,
						AdditionalProperties: additionalPropertiesItemToHcl(s.AdditionalProperties),
					},
				},
			}
		}

		var properties map[string]*SchemaOrReference
		if s.Properties != nil {
			properties = make(map[string]*SchemaOrReference)
			for _, v := range s.Properties.AdditionalProperties {
				properties[v.Name] = SchemaOrReferenceToHcl(v.Value)
			}
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Object{
				Object: &OASObject{
					Type:          s.Type,
					Properties:    properties,
					Common:        common,
					MaxProperties: s.MaxProperties,
					MinProperties: s.MinProperties,
					Required:      s.Required,
					Discriminator: DiscriminatorToHcl(s.Discriminator),
				},
			},
		}
	case "string":
		str := &OASString{
			Type:      s.Type,
			Format:    s.Format,
			MinLength: s.MinLength,
			MaxLength: s.MaxLength,
			Pattern:   s.Pattern,
		}
		if s.Default != nil {
			if x := s.Default.GetString_(); x != "" {
				str.Default = x
			}
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_String_{String_: str},
		}
	case "number":
		num := &OASNumber{
			Type:             s.Type,
			Common:           common,
			Format:           s.Format,
			MultipleOf:       s.MultipleOf,
			Minimum:          s.Minimum,
			Maximum:          s.Maximum,
			ExclusiveMinimum: s.ExclusiveMinimum,
			ExclusiveMaximum: s.ExclusiveMaximum,
		}
		if s.Enum != nil {
			for _, v := range s.Enum {
				num.Enum = append(num.Enum, &Any{Value: v.Value})
			}
		}
		if s.Default != nil {
			if x := s.Default.GetNumber(); x != 0 {
				num.Default = x
			}
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Number{Number: num},
		}
	case "integer":
		integer := &OASInteger{
			Type:             s.Type,
			Format:           s.Format,
			Common:           common,
			MultipleOf:       int64(s.MultipleOf),
			Minimum:          int64(s.Minimum),
			Maximum:          int64(s.Maximum),
			ExclusiveMinimum: s.ExclusiveMinimum,
			ExclusiveMaximum: s.ExclusiveMaximum,
			Default:          int64(s.Default.GetNumber()),
		}
		if s.Enum != nil {
			for _, v := range s.Enum {
				integer.Enum = append(integer.Enum, &Any{Value: v.Value})
			}
		}
		if s.Default != nil {
			if x := s.Default.GetNumber(); x != 0 {
				integer.Default = int64(x)
			}
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Integer{Integer: integer},
		}
	case "boolean":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Boolean{
				Boolean: &OASBoolean{
					Type:    s.Type,
					Common:  common,
					Default: s.Default.GetBoolean(),
				},
			},
		}
	default:
	}
	return nil
}

func schemaToHcl(schema *openapiv3.Schema) *Schema {
	if schema == nil {
		return nil
	}
	s := &Schema{
		Type:                   schema.Type,
		Format:                 schema.Format,
		Title:                  schema.Title,
		Default:                defaultToHcl(schema.Default),
		Maximum:                schema.Maximum,
		ExclusiveMaximum:       schema.ExclusiveMaximum,
		Minimum:                schema.Minimum,
		ExclusiveMinimum:       schema.ExclusiveMinimum,
		MaxLength:              schema.MaxLength,
		MinLength:              schema.MinLength,
		Pattern:                schema.Pattern,
		MaxItems:               schema.MaxItems,
		MinItems:               schema.MinItems,
		UniqueItems:            schema.UniqueItems,
		MultipleOf:             schema.MultipleOf,
		Required:               schema.Required,
		ReadOnly:               schema.ReadOnly,
		WriteOnly:              schema.WriteOnly,
		Xml:                    xmlToHcl(schema.Xml),
		ExternalDocs:           ExternalDocsToHcl(schema.ExternalDocs),
		Example:                anyToHcl(schema.Example),
		Deprecated:             schema.Deprecated,
		Discriminator:          DiscriminatorToHcl(schema.Discriminator),
		Nullable:               schema.Nullable,
		SpecificationExtension: extensionToHcl(schema.SpecificationExtension),
	}
	if schema.Not != nil {
		n := &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: schema.Not,
			},
		}
		s.Not = SchemaOrReferenceToHcl(n)
	}
	if schema.Enum != nil {
		for _, v := range schema.Enum {
			s.Enum = append(s.Enum, &Any{Value: v.Value})
		}
	}
	if schema.Items != nil {
		for _, v := range schema.Items.SchemaOrReference {
			s.Items = append(s.Items, SchemaOrReferenceToHcl(v))
		}
	}
	if schema.Properties != nil {
		s.Properties = make(map[string]*SchemaOrReference)
		for _, v := range schema.Properties.AdditionalProperties {
			s.Properties[v.Name] = SchemaOrReferenceToHcl(v.Value)
		}
	}
	if schema.AdditionalProperties != nil {
		s.AdditionalProperties = additionalPropertiesItemToHcl(schema.AdditionalProperties)
	}
	if schema.AllOf != nil {
		for _, v := range schema.AllOf {
			s.AllOf = append(s.AllOf, SchemaOrReferenceToHcl(v))
		}
	}
	if schema.OneOf != nil {
		for _, v := range schema.OneOf {
			s.OneOf = append(s.OneOf, SchemaOrReferenceToHcl(v))
		}
	}
	if schema.AnyOf != nil {
		for _, v := range schema.AnyOf {
			s.AnyOf = append(s.AnyOf, SchemaOrReferenceToHcl(v))
		}
	}
	return s
}

func schemaToSchemaOrReference(schema *Schema) *SchemaOrReference {
	if schema == nil {
		return nil
	}
	return &SchemaOrReference{
		Oneof: &SchemaOrReference_Schema{
			Schema: schema,
		},
	}
}
