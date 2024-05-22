package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func SchemaOrReferenceToHcl(schema *openapiv3.SchemaOrReference, force ...bool) *SchemaOrReference {
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
	if s == nil {
		return nil
	}
	if (force != nil && force[0]) || isFull(s) { // force to parse to Schema
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Schema{
				Schema: schemaToHcl(s),
			},
		}
	}

	common := commonToHcl(s)
	if common == nil {
		if isAllOf(s) {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_AllOf{
					AllOf: allOfToHcl(s),
				},
			}
		}
		if isOneOf(s) {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_OneOf{
					OneOf: oneOfToHcl(s),
				},
			}
		}
		if isAnyOf(s) {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_AnyOf{
					AnyOf: anyOfToHcl(s),
				},
			}
		}
	}

	switch s.Type {
	case "array":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Array{
				Array: oasArrayToHcl(s),
			},
		}
	case "object":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Object{
				Object: oasObjectToHcl(s),
			},
		}
	case "string":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_String_{
				String_: oasStringToHcl(s),
			},
		}
	case "number", "integer":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Number{
				Number: oasNumberToHcl(s),
			},
		}
	case "boolean":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Boolean{
				Boolean: OASBooleanToHcl(s),
			},
		}
	default:
	}
	return nil
}

func SchemaOrReferenceToApi(schema *SchemaOrReference) *openapiv3.SchemaOrReference {
	if schema == nil {
		return nil
	}

	if x := schema.GetReference(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Reference{
				Reference: ReferenceToApi(x),
			},
		}
	}

	s := schema.GetSchema()
	if s != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: schemaToApi(s),
			},
		}
	}

	if x := schema.GetArray(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasArrayToApi(x),
			},
		}
	}
	if x := schema.GetBoolean(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasBooleanToApi(x),
			},
		}
	}
	if x := schema.GetNumber(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasNumberToApi(x),
			},
		}
	}
	if x := schema.GetObject(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasObjectToApi(x),
			},
		}
	}
	if x := schema.GetString_(); x != nil {
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasStringToApi(x),
			},
		}
	}
	return nil
}

func anyToHcl(any *openapiv3.Any) *Any {
	if any == nil {
		return nil
	}
	return &Any{
		Value: any.Value,
	}
}

func anyToApi(any *Any) *openapiv3.Any {
	if any == nil {
		return nil
	}
	return &openapiv3.Any{
		Value: any.Value,
	}
}

func extensionToHcl(extension []*openapiv3.NamedAny) map[string]*Any {
	if extension == nil {
		return nil
	}
	e := make(map[string]*Any)
	for _, v := range extension {
		e[v.Name] = anyToHcl(v.Value)
	}
	return e
}

func extensionToApi(extention map[string]*Any) []*openapiv3.NamedAny {
	if extention == nil {
		return nil
	}
	var e []*openapiv3.NamedAny
	for k, v := range extention {
		e = append(e, &openapiv3.NamedAny{Name: k, Value: anyToApi(v)})
	}
	return e
}

func xmlToHcl(xml *openapiv3.Xml) *Xml {
	if xml == nil {
		return nil
	}
	return &Xml{
		Name:                   xml.Name,
		Namespace:              xml.Namespace,
		Prefix:                 xml.Prefix,
		Attribute:              xml.Attribute,
		Wrapped:                xml.Wrapped,
		SpecificationExtension: extensionToHcl(xml.SpecificationExtension),
	}
}

func xmlToApi(xml *Xml) *openapiv3.Xml {
	if xml == nil {
		return nil
	}
	return &openapiv3.Xml{
		Name:                   xml.Name,
		Namespace:              xml.Namespace,
		Prefix:                 xml.Prefix,
		Attribute:              xml.Attribute,
		Wrapped:                xml.Wrapped,
		SpecificationExtension: extensionToApi(xml.SpecificationExtension),
	}
}

func discriminatorToHcl(discriminator *openapiv3.Discriminator) *Discriminator {
	if discriminator == nil {
		return nil
	}
	d := &Discriminator{
		PropertyName:           discriminator.PropertyName,
		SpecificationExtension: extensionToHcl(discriminator.SpecificationExtension),
	}
	if discriminator.Mapping != nil {
		d.Mapping = make(map[string]string)
		for _, v := range discriminator.Mapping.AdditionalProperties {
			d.Mapping[v.Name] = v.Value
		}
	}
	return d
}

func discriminatorToApi(discriminator *Discriminator) *openapiv3.Discriminator {
	if discriminator == nil {
		return nil
	}
	d := &openapiv3.Discriminator{
		PropertyName:           discriminator.PropertyName,
		SpecificationExtension: extensionToApi(discriminator.SpecificationExtension),
	}
	if discriminator.Mapping != nil {
		d.Mapping = &openapiv3.Strings{}
		for k, v := range discriminator.Mapping {
			d.Mapping.AdditionalProperties = append(d.Mapping.AdditionalProperties,
				&openapiv3.NamedString{Name: k, Value: v},
			)
		}
	}
	return d
}

func externalDocsToHcl(docs *openapiv3.ExternalDocs) *ExternalDocs {
	if docs == nil {
		return nil
	}
	return &ExternalDocs{
		Description:            docs.Description,
		Url:                    docs.Url,
		SpecificationExtension: extensionToHcl(docs.SpecificationExtension),
	}
}

func externalDocsToApi(externalDocs *ExternalDocs) *openapiv3.ExternalDocs {
	if externalDocs == nil {
		return nil
	}
	return &openapiv3.ExternalDocs{
		Description:            externalDocs.Description,
		Url:                    externalDocs.Url,
		SpecificationExtension: extensionToApi(externalDocs.SpecificationExtension),
	}
}

func additionalPropertiesItemToHcl(item *openapiv3.AdditionalPropertiesItem) *AdditionalPropertiesItem {
	if item == nil {
		return nil
	}
	if x := item.GetBoolean(); x {
		return &AdditionalPropertiesItem{
			Oneof: &AdditionalPropertiesItem_Boolean{
				Boolean: x,
			},
		}
	} else if x := item.GetSchemaOrReference(); x != nil {
		return &AdditionalPropertiesItem{
			Oneof: &AdditionalPropertiesItem_SchemaOrReference{
				SchemaOrReference: SchemaOrReferenceToHcl(x),
			},
		}
	}
	return nil
}

func additionalPropertiesItemToApi(additionalPropertiesItem *AdditionalPropertiesItem) *openapiv3.AdditionalPropertiesItem {
	if additionalPropertiesItem == nil {
		return nil
	}
	if x := additionalPropertiesItem.GetBoolean(); x {
		return &openapiv3.AdditionalPropertiesItem{
			Oneof: &openapiv3.AdditionalPropertiesItem_Boolean{
				Boolean: x,
			},
		}
	}
	x := additionalPropertiesItem.GetSchemaOrReference()
	return &openapiv3.AdditionalPropertiesItem{
		Oneof: &openapiv3.AdditionalPropertiesItem_SchemaOrReference{
			SchemaOrReference: SchemaOrReferenceToApi(x),
		},
	}
}

func defaultToHcl(default_ *openapiv3.DefaultType) *DefaultType {
	if default_ == nil {
		return nil
	}
	switch default_.Oneof.(type) {
	case *openapiv3.DefaultType_Boolean:
		return &DefaultType{
			Oneof: &DefaultType_Boolean{
				Boolean: default_.GetBoolean(),
			},
		}
	case *openapiv3.DefaultType_Number:
		return &DefaultType{
			Oneof: &DefaultType_Number{
				Number: default_.GetNumber(),
			},
		}
	case *openapiv3.DefaultType_String_:
		return &DefaultType{
			Oneof: &DefaultType_String_{String_: default_.GetString_()},
		}
	default:
	}
	return nil
}

func defaultTypeToApi(defaultType *DefaultType) *openapiv3.DefaultType {
	if defaultType == nil {
		return nil
	}
	if x := defaultType.GetString_(); x != "" {
		return &openapiv3.DefaultType{
			Oneof: &openapiv3.DefaultType_String_{
				String_: x,
			},
		}
	} else if x := defaultType.GetNumber(); x != 0 {
		return &openapiv3.DefaultType{
			Oneof: &openapiv3.DefaultType_Number{
				Number: x,
			},
		}
	} else if x := defaultType.GetBoolean(); x {
		return &openapiv3.DefaultType{
			Oneof: &openapiv3.DefaultType_Boolean{
				Boolean: x,
			},
		}
	}
	return nil
}

func commonToHcl(s *openapiv3.Schema) *SchemaCommon {
	if s == nil || !isCommon(s) {
		return nil
	}
	common := &SchemaCommon{
		Type:    s.Type,
		Format:  s.Format,
		Default: defaultToHcl(s.Default),
	}
	if s.Enum != nil {
		for _, v := range s.Enum {
			common.Enum = append(common.Enum, &Any{Value: v.Value})
		}
	}

	return common
}

func commonToApi(s *SchemaCommon) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := &openapiv3.Schema{
		Type:    s.Type,
		Format:  s.Format,
		Default: defaultTypeToApi(s.Default),
	}
	if s.Enum != nil {
		for _, v := range s.Enum {
			schema.Enum = append(schema.Enum, &openapiv3.Any{Value: v.Value})
		}
	}
	return schema
}

func OASBooleanToHcl(s *openapiv3.Schema) *OASBoolean {
	if s == nil || s.Type != "boolean" {
		return nil
	}

	return &OASBoolean{
		Common: commonToHcl(s),
	}
}

func oasBooleanToApi(s *OASBoolean) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := commonToApi(s.Common)
	schema.Type = "boolean"
	return schema
}

func numberToHcl(s *openapiv3.Schema) *SchemaNumber {
	if s == nil || !isNumber(s) {
		return nil
	}
	number := &SchemaNumber{
		MultipleOf:       s.MultipleOf,
		Minimum:          s.Minimum,
		Maximum:          s.Maximum,
		ExclusiveMinimum: s.ExclusiveMinimum,
		ExclusiveMaximum: s.ExclusiveMaximum,
	}

	return number
}

func numberToApi(s *SchemaNumber) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return &openapiv3.Schema{
		MultipleOf:       s.MultipleOf,
		Minimum:          s.Minimum,
		Maximum:          s.Maximum,
		ExclusiveMinimum: s.ExclusiveMinimum,
		ExclusiveMaximum: s.ExclusiveMaximum,
	}
}

func oasNumberToHcl(s *openapiv3.Schema) *OASNumber {
	if s == nil || !isNumber(s) {
		return nil
	}

	return &OASNumber{
		Common: commonToHcl(s),
		Number: numberToHcl(s),
	}
}

func plusCommon(s *openapiv3.Schema, c *SchemaCommon) *openapiv3.Schema {
	if s == nil || c == nil {
		return s
	}
	s.Type = c.Type
	s.Format = c.Format
	s.Default = defaultTypeToApi(c.Default)
	for _, v := range c.Enum {
		s.Enum = append(s.Enum, &openapiv3.Any{Value: v.Value})
	}
	return s
}

func oasNumberToApi(s *OASNumber) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(numberToApi(s.Number), s.Common)
}

func stringToHcl(s *openapiv3.Schema) *SchemaString {
	if s == nil || !isString(s) {
		return nil
	}
	str := &SchemaString{
		MinLength: s.MinLength,
		MaxLength: s.MaxLength,
		Pattern:   s.Pattern,
	}

	return str
}

func stringToApi(s *SchemaString) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return &openapiv3.Schema{
		MinLength: s.MinLength,
		MaxLength: s.MaxLength,
		Pattern:   s.Pattern,
	}
}

func oasStringToHcl(s *openapiv3.Schema) *OASString {
	if s == nil || !isString(s) {
		return nil
	}

	return &OASString{
		Common:  commonToHcl(s),
		String_: stringToHcl(s),
	}
}

func oasStringToApi(s *OASString) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(stringToApi(s.String_), s.Common)
}

func arrayToHcl(s *openapiv3.Schema) *SchemaArray {
	if s == nil || !isArray(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.Items.SchemaOrReference {
		items = append(items, SchemaOrReferenceToHcl(v))
	}
	return &SchemaArray{
		Items:       items,
		MaxItems:    s.MaxItems,
		MinItems:    s.MinItems,
		UniqueItems: s.UniqueItems,
	}
}

func arrayToApi(s *SchemaArray) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := &openapiv3.Schema{
		MaxItems:    s.MaxItems,
		MinItems:    s.MinItems,
		UniqueItems: s.UniqueItems,
	}
	for _, v := range s.Items {
		schema.Items.SchemaOrReference = append(schema.Items.SchemaOrReference, SchemaOrReferenceToApi(v))
	}
	return schema
}

func oasArrayToHcl(s *openapiv3.Schema) *OASArray {
	if s == nil || !isArray(s) {
		return nil
	}

	return &OASArray{
		Common: commonToHcl(s),
		Array:  arrayToHcl(s),
	}
}

func oasArrayToApi(s *OASArray) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(arrayToApi(s.Array), s.Common)
}

func objectToHcl(s *openapiv3.Schema) *SchemaObject {
	if s == nil || !isObject(s) {
		return nil
	}
	var properties map[string]*SchemaOrReference
	if s.Properties != nil {
		properties = make(map[string]*SchemaOrReference)
		for _, v := range s.Properties.AdditionalProperties {
			properties[v.Name] = SchemaOrReferenceToHcl(v.Value)
		}
	}
	return &SchemaObject{
		Properties:    properties,
		MaxProperties: s.MaxProperties,
		MinProperties: s.MinProperties,
		Required:      s.Required,
	}
}

func objectToApi(s *SchemaObject) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := &openapiv3.Schema{
		MaxProperties: s.MaxProperties,
		MinProperties: s.MinProperties,
		Required:      s.Required,
	}
	if s.Properties != nil {
		schema.Properties = &openapiv3.Properties{}
		for k, v := range s.Properties {
			schema.Properties.AdditionalProperties = append(schema.Properties.AdditionalProperties,
				&openapiv3.NamedSchemaOrReference{Name: k, Value: SchemaOrReferenceToApi(v)},
			)
		}
	}
	return schema
}

func oasObjectToHcl(s *openapiv3.Schema) *OASObject {
	if s == nil || !isObject(s) {
		return nil
	}

	return &OASObject{
		Common: commonToHcl(s),
		Object: objectToHcl(s),
	}
}

func oasObjectToApi(s *OASObject) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(objectToApi(s.Object), s.Common)
}

func mapToHcl(s *openapiv3.Schema) *SchemaMap {
	if s == nil || !isMap(s) {
		return nil
	}
	return &SchemaMap{
		AdditionalProperties: additionalPropertiesItemToHcl(s.AdditionalProperties),
	}
}

func mapToApi(s *SchemaMap) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return &openapiv3.Schema{
		AdditionalProperties: additionalPropertiesItemToApi(s.AdditionalProperties),
	}
}

func oasMapToHcl(s *openapiv3.Schema) *OASMap {
	if s == nil || !isMap(s) {
		return nil
	}

	return &OASMap{
		Common: commonToHcl(s),
		Map:    mapToHcl(s),
	}
}

func oasMapToApi(s *OASMap) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(mapToApi(s.Map), s.Common)
}

func allOfToHcl(s *openapiv3.Schema) *SchemaAllOf {
	if s == nil || !isAllOf(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.AllOf {
		items = append(items, SchemaOrReferenceToHcl(v))
	}
	return &SchemaAllOf{
		Items: items,
	}
}

func allOfToApi(s *SchemaAllOf) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := &openapiv3.Schema{}
	for _, v := range s.Items {
		schema.AllOf = append(schema.AllOf, SchemaOrReferenceToApi(v))
	}
	return schema
}

func oneOfToHcl(s *openapiv3.Schema) *SchemaOneOf {
	if s == nil || !isOneOf(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.OneOf {
		items = append(items, SchemaOrReferenceToHcl(v))
	}
	return &SchemaOneOf{
		Items: items,
	}
}

func oneOfToApi(s *SchemaOneOf) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := &openapiv3.Schema{}
	for _, v := range s.Items {
		schema.OneOf = append(schema.OneOf, SchemaOrReferenceToApi(v))
	}
	return schema
}

func anyOfToHcl(s *openapiv3.Schema) *SchemaAnyOf {
	if s == nil || !isAnyOf(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.AnyOf {
		items = append(items, SchemaOrReferenceToHcl(v))
	}
	return &SchemaAnyOf{
		Items: items,
	}
}

func anyOfToApi(s *SchemaAnyOf) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := &openapiv3.Schema{}
	for _, v := range s.Items {
		schema.AnyOf = append(schema.AnyOf, SchemaOrReferenceToApi(v))
	}
	return schema
}

func schemaToHcl(schema *openapiv3.Schema) *Schema {
	if schema == nil {
		return nil
	}

	return &Schema{
		Nullable:     schema.Nullable,
		ReadOnly:     schema.ReadOnly,
		WriteOnly:    schema.WriteOnly,
		Xml:          xmlToHcl(schema.Xml),
		ExternalDocs: externalDocsToHcl(schema.ExternalDocs),
		Example:      anyToHcl(schema.Example),
		Deprecated:   schema.Deprecated,
		Title:        schema.Title,
		Description:  schema.Description,
		Not: SchemaOrReferenceToHcl(&openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{Schema: schema.Not}}),
		Discriminator:          discriminatorToHcl(schema.Discriminator),
		SpecificationExtension: extensionToHcl(schema.SpecificationExtension),
		AllOf:                  allOfToHcl(schema),
		OneOf:                  oneOfToHcl(schema),
		AnyOf:                  anyOfToHcl(schema),
		Object:                 objectToHcl(schema),
		Array:                  arrayToHcl(schema),
		Map:                    mapToHcl(schema),
		String_:                stringToHcl(schema),
		Number:                 numberToHcl(schema),
		Common:                 commonToHcl(schema),
	}
}

func schemaToApi(schema *Schema) *openapiv3.Schema {
	if schema == nil {
		return nil
	}

	s := &openapiv3.Schema{
		Nullable:               schema.Nullable,
		ReadOnly:               schema.ReadOnly,
		WriteOnly:              schema.WriteOnly,
		Xml:                    xmlToApi(schema.Xml),
		ExternalDocs:           externalDocsToApi(schema.ExternalDocs),
		Example:                anyToApi(schema.Example),
		Deprecated:             schema.Deprecated,
		Title:                  schema.Title,
		Description:            schema.Description,
		Discriminator:          discriminatorToApi(schema.Discriminator),
		SpecificationExtension: extensionToApi(schema.SpecificationExtension),
	}
	if schema.Not != nil {
		s.Not = schemaToApi(schema.Not.GetSchema())
	}
	if schema.AllOf != nil {
		s.AllOf = allOfToApi(schema.AllOf).AllOf
	}
	if schema.OneOf != nil {
		s.OneOf = oneOfToApi(schema.OneOf).OneOf
	}
	if schema.AnyOf != nil {
		s.AnyOf = anyOfToApi(schema.AnyOf).AnyOf
	}
	if schema.Object != nil {
		x := objectToApi(schema.Object)
		s.Properties = x.Properties
		s.MaxProperties = x.MaxProperties
		s.MinProperties = x.MinProperties
		s.Required = x.Required
	}
	if schema.Array != nil {
		x := arrayToApi(schema.Array)
		s.Items = x.Items
		s.MaxItems = x.MaxItems
		s.MinItems = x.MinItems
		s.UniqueItems = x.UniqueItems
	}
	if schema.Map != nil {
		x := mapToApi(schema.Map)
		s.AdditionalProperties = x.AdditionalProperties
	}
	if schema.String_ != nil {
		x := stringToApi(schema.String_)
		s.MinLength = x.MinLength
		s.MaxLength = x.MaxLength
		s.Pattern = x.Pattern
	}
	if schema.Number != nil {
		x := numberToApi(schema.Number)
		s.MultipleOf = x.MultipleOf
		s.Minimum = x.Minimum
		s.Maximum = x.Maximum
		s.ExclusiveMinimum = x.ExclusiveMinimum
		s.ExclusiveMaximum = x.ExclusiveMaximum
	}
	if schema.Common != nil {
		x := commonToApi(schema.Common)
		s.Type = x.Type
		s.Format = x.Format
		s.Default = x.Default
		s.Enum = x.Enum
	}

	return s
}

/*
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
*/
