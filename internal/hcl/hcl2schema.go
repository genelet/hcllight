package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func oasCommonToApi(common *OASCommon) *openapiv3.Schema {
	if common == nil {
		return nil
	}
	return &openapiv3.Schema{
		ReadOnly:   common.ReadOnly,
		WriteOnly:  common.WriteOnly,
		Nullable:   common.Nullable,
		Deprecated: common.Deprecated,
	}
}

func arraySchemaToApi(typ string, allof *OASArray) *openapiv3.Schema {
	if allof == nil {
		return nil
	}
	var a []*openapiv3.SchemaOrReference
	for _, v := range allof.Items {
		a = append(a, SchemaOrReferenceToApi(v))
	}
	schema := oasCommonToApi(allof.Common)
	if schema == nil {
		schema = &openapiv3.Schema{}
	}
	schema.MaxItems = allof.MaxItems
	schema.MinItems = allof.MinItems
	schema.UniqueItems = allof.UniqueItems
	schema.Discriminator = DiscriminatorToApi(allof.Discriminator)
	schema.Example = anyToApi(allof.Example)

	switch typ {
	case "allOf":
		schema.AllOf = a
	case "oneOf":
		schema.OneOf = a
	case "anyOf":
		schema.AnyOf = a
	case "array":
		schema.Items = &openapiv3.ItemsItem{
			SchemaOrReference: a,
		}
	}
	return schema
}

func mapSchemaToApi(mapSchema *OASMap) *openapiv3.Schema {
	if mapSchema == nil {
		return nil
	}
	schema := oasCommonToApi(mapSchema.Common)
	if schema == nil {
		schema = &openapiv3.Schema{}
	}
	schema.AdditionalProperties = additionalPropertiesItemToApi(mapSchema.AdditionalProperties)
	return schema
}

func objectSchemaToApi(object *OASObject) *openapiv3.Schema {
	if object == nil {
		return nil
	}
	schema := oasCommonToApi(object.Common)
	if schema == nil {
		schema = &openapiv3.Schema{}
	}
	if object.Properties != nil {
		schema.Properties = &openapiv3.Properties{}
		for k, v := range object.Properties {
			schema.Properties.AdditionalProperties = append(schema.Properties.AdditionalProperties,
				&openapiv3.NamedSchemaOrReference{Name: k, Value: SchemaOrReferenceToApi(v)},
			)
		}
	}
	schema.MaxProperties = object.MaxProperties
	schema.MinProperties = object.MinProperties
	schema.Required = object.Required
	schema.Example = anyToApi(object.Example)
	schema.Discriminator = DiscriminatorToApi(object.Discriminator)

	return schema
}

func stringSchemaToApi(stringSchema *OASString) *openapiv3.Schema {
	if stringSchema == nil {
		return nil
	}
	schema := oasCommonToApi(stringSchema.Common)
	if schema == nil {
		schema = &openapiv3.Schema{}
	}
	schema.Format = stringSchema.Format
	schema.Pattern = stringSchema.Pattern
	schema.MaxLength = stringSchema.MaxLength
	schema.MinLength = stringSchema.MinLength
	schema.Enum = enumToApi(stringSchema.Enum)
	if stringSchema.Default != "" {
		schema.Default = &openapiv3.DefaultType{
			Oneof: &openapiv3.DefaultType_String_{
				String_: stringSchema.Default,
			},
		}
	}
	return schema
}

func numberSchemaToApi(numberSchema *OASNumber) *openapiv3.Schema {
	if numberSchema == nil {
		return nil
	}
	schema := oasCommonToApi(numberSchema.Common)
	if schema == nil {
		schema = &openapiv3.Schema{}
	}
	schema.Format = numberSchema.Format
	schema.Maximum = numberSchema.Maximum
	schema.ExclusiveMaximum = numberSchema.ExclusiveMaximum
	schema.Minimum = numberSchema.Minimum
	schema.ExclusiveMinimum = numberSchema.ExclusiveMinimum
	schema.MultipleOf = numberSchema.MultipleOf
	schema.Enum = enumToApi(numberSchema.Enum)
	if numberSchema.Default != 0 {
		schema.Default = &openapiv3.DefaultType{
			Oneof: &openapiv3.DefaultType_Number{
				Number: numberSchema.Default,
			},
		}
	}

	return schema
}

func integerSchemaToApi(integerSchema *OASInteger) *openapiv3.Schema {
	if integerSchema == nil {
		return nil
	}
	schema := oasCommonToApi(integerSchema.Common)
	if schema == nil {
		schema = &openapiv3.Schema{}
	}
	schema.Format = integerSchema.Format
	schema.Maximum = float64(integerSchema.Maximum)
	schema.ExclusiveMaximum = integerSchema.ExclusiveMaximum
	schema.Minimum = float64(integerSchema.Minimum)
	schema.ExclusiveMinimum = integerSchema.ExclusiveMinimum
	schema.MultipleOf = float64(integerSchema.MultipleOf)
	schema.Enum = enumToApi(integerSchema.Enum)
	if integerSchema.Default != 0 {
		schema.Default = &openapiv3.DefaultType{
			Oneof: &openapiv3.DefaultType_Number{
				Number: float64(integerSchema.Default),
			},
		}
	}
	return schema
}

func booleanSchemaToApi(booleanSchema *OASBoolean) *openapiv3.Schema {
	if booleanSchema == nil {
		return nil
	}
	schema := oasCommonToApi(booleanSchema.Common)
	if schema == nil {
		schema = &openapiv3.Schema{}
	}
	if booleanSchema.Default != false {
		schema.Default = &openapiv3.DefaultType{
			Oneof: &openapiv3.DefaultType_Boolean{
				Boolean: booleanSchema.Default,
			},
		}
	}
	return schema
}

func SchemaOrReferenceToApi(schemaOrReference *SchemaOrReference) *openapiv3.SchemaOrReference {
	if schemaOrReference == nil {
		return nil
	}
	if x := schemaOrReference.GetReference(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Reference{
				Reference: ReferenceToApi(x),
			},
		}
	}

	if x := schemaOrReference.GetOasAllof(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: arraySchemaToApi("allOf", x),
			},
		}
	} else if x := schemaOrReference.GetOasAnyof(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: arraySchemaToApi("anyOf", x),
			},
		}
	} else if x := schemaOrReference.GetOasOneof(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: arraySchemaToApi("oneOf", x),
			},
		}
	} else if x := schemaOrReference.GetArray(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: arraySchemaToApi("array", x),
			},
		}
	} else if x := schemaOrReference.GetMap(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: mapSchemaToApi(x),
			},
		}
	} else if x := schemaOrReference.GetObject(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: objectSchemaToApi(x),
			},
		}
	} else if x := schemaOrReference.GetString_(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: stringSchemaToApi(x),
			},
		}
	} else if x := schemaOrReference.GetNumber(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: numberSchemaToApi(x),
			},
		}
	} else if x := schemaOrReference.GetInteger(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: integerSchemaToApi(x),
			},
		}
	} else if x := schemaOrReference.GetBoolean(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: booleanSchemaToApi(x),
			},
		}
	} else if x := schemaOrReference.GetSchema(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: schemaToApi(x),
			},
		}
	}
	return nil
}

func schemaToApi(schema *Schema) *openapiv3.Schema {
	if schema == nil {
		return nil
	}
	s := &openapiv3.Schema{
		Nullable:               schema.Nullable,
		Discriminator:          DiscriminatorToApi(schema.Discriminator),
		Xml:                    XmlToApi(schema.Xml),
		ExternalDocs:           ExternalDocsToApi(schema.ExternalDocs),
		MultipleOf:             schema.MultipleOf,
		Maximum:                schema.Maximum,
		ExclusiveMaximum:       schema.ExclusiveMaximum,
		Minimum:                schema.Minimum,
		ExclusiveMinimum:       schema.ExclusiveMinimum,
		MaxLength:              schema.MaxLength,
		MinLength:              schema.MinLength,
		Pattern:                schema.Pattern,
		ReadOnly:               schema.ReadOnly,
		WriteOnly:              schema.WriteOnly,
		Deprecated:             schema.Deprecated,
		Title:                  schema.Title,
		Description:            schema.Description,
		Default:                defaultTypeToApi(schema.Default),
		Example:                anyToApi(schema.Example),
		Type:                   schema.Type,
		Format:                 schema.Format,
		MaxItems:               schema.MaxItems,
		MinItems:               schema.MinItems,
		UniqueItems:            schema.UniqueItems,
		MaxProperties:          schema.MaxProperties,
		MinProperties:          schema.MinProperties,
		Required:               schema.Required,
		AdditionalProperties:   additionalPropertiesItemToApi(schema.AdditionalProperties),
		SpecificationExtension: extensionToApi(schema.SpecificationExtension),
	}
	if schema.Not != nil {
		s.Not = SchemaOrReferenceToApi(schema.Not).GetSchema()
	}
	if schema.Properties != nil {
		s.Properties = &openapiv3.Properties{}
		for k, v := range schema.Properties {
			s.Properties.AdditionalProperties = append(s.Properties.AdditionalProperties,
				&openapiv3.NamedSchemaOrReference{Name: k, Value: SchemaOrReferenceToApi(v)},
			)
		}
	}
	if schema.Items != nil {
		var a []*openapiv3.SchemaOrReference
		for _, v := range schema.Items {
			a = append(a, SchemaOrReferenceToApi(v))
		}
		s.Items = &openapiv3.ItemsItem{
			SchemaOrReference: a,
		}
	}
	if schema.Enum != nil {
		for _, v := range schema.Enum {
			s.Enum = append(s.Enum, &openapiv3.Any{Value: v.Value})
		}
	}
	if schema.AllOf != nil {
		s.AllOf = []*openapiv3.SchemaOrReference{}
		for _, v := range schema.AllOf {
			s.AllOf = append(s.AllOf, SchemaOrReferenceToApi(v))
		}
	}
	if schema.OneOf != nil {
		s.OneOf = []*openapiv3.SchemaOrReference{}
		for _, v := range schema.OneOf {
			s.OneOf = append(s.OneOf, SchemaOrReferenceToApi(v))
		}
	}
	if schema.AnyOf != nil {
		s.AnyOf = []*openapiv3.SchemaOrReference{}
		for _, v := range schema.AnyOf {
			s.AnyOf = append(s.AnyOf, SchemaOrReferenceToApi(v))
		}
	}

	return nil
}
