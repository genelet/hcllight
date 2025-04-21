package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func schemaOrReferenceFromAPI(schema *openapiv3.SchemaOrReference, force ...bool) *SchemaOrReference {
	if schema == nil {
		return nil
	}

	if x := schema.GetReference(); x != nil {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Reference{
				Reference: referenceFromAPI(x),
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
				Schema: schemaFromAPI(s),
			},
		}
	}

	common := commonFromAPI(s)
	if common == nil {
		if isAllOf(s) {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_AllOf{
					AllOf: allOfFromAPI(s),
				},
			}
		}
		if isOneOf(s) {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_OneOf{
					OneOf: oneOfFromAPI(s),
				},
			}
		}
		if isAnyOf(s) {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_AnyOf{
					AnyOf: anyOfFromAPI(s),
				},
			}
		}
	}

	switch s.Type {
	case "array":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Array{
				Array: oasArrayFromAPI(s),
			},
		}
	case "object":
		if isMap(s) {
			if common != nil {
				s.Type = "map"
				common.Type = "map"
			}
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_Map{
					Map: oasMapFromAPI(s),
				},
			}
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Object{
				Object: oasObjectFromAPI(s),
			},
		}
	case "string":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_String_{
				String_: oasStringFromAPI(s),
			},
		}
	case "number", "integer":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Number{
				Number: oasNumberFromAPI(s),
			},
		}
	case "boolean":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Boolean{
				Boolean: oasBooleanFromAPI(s),
			},
		}
	default:
	}
	return nil
}

func schemaOrReferenceToAPI(schema *SchemaOrReference) *openapiv3.SchemaOrReference {
	if schema == nil {
		return nil
	}

	switch schema.Oneof.(type) {
	case *SchemaOrReference_Reference:
		x := schema.GetReference()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Reference{
				Reference: referenceToAPI(x),
			},
		}
	case *SchemaOrReference_AllOf:
		x := schema.GetAllOf()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: allOfToAPI(x),
			},
		}
	case *SchemaOrReference_OneOf:
		x := schema.GetOneOf()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oneOfToAPI(x),
			},
		}
	case *SchemaOrReference_AnyOf:
		x := schema.GetAnyOf()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: anyOfToAPI(x),
			},
		}
	case *SchemaOrReference_Schema:
		s := schema.GetSchema()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: schemaToAPI(s),
			},
		}
	case *SchemaOrReference_Array:
		x := schema.GetArray()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasArrayToAPI(x),
			},
		}
	case *SchemaOrReference_Object:
		x := schema.GetObject()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasObjectToAPI(x),
			},
		}
	case *SchemaOrReference_Map:
		x := schema.GetMap()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasMapToAPI(x),
			},
		}
	case *SchemaOrReference_String_:
		x := schema.GetString_()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasStringToAPI(x),
			},
		}
	case *SchemaOrReference_Number:
		x := schema.GetNumber()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasNumberToAPI(x),
			},
		}
	case *SchemaOrReference_Boolean:
		x := schema.GetBoolean()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasBooleanToAPI(x),
			},
		}
	default:
	}

	return nil
}

func anyFromAPI(any *openapiv3.Any) *Any {
	if any == nil {
		return nil
	}
	return &Any{
		Yaml:  any.Yaml,
		Value: any.Value,
	}
}

func anyToAPI(any *Any) *openapiv3.Any {
	if any == nil {
		return nil
	}
	return &openapiv3.Any{
		Yaml:  any.Yaml,
		Value: any.Value,
	}
}

func extensionFromAPI(extension []*openapiv3.NamedAny) map[string]*Any {
	if extension == nil {
		return nil
	}
	e := make(map[string]*Any)
	for _, v := range extension {
		e[v.Name] = anyFromAPI(v.Value)
	}
	return e
}

func extensionToAPI(extention map[string]*Any) []*openapiv3.NamedAny {
	if extention == nil {
		return nil
	}
	var e []*openapiv3.NamedAny
	for k, v := range extention {
		e = append(e, &openapiv3.NamedAny{Name: k, Value: anyToAPI(v)})
	}
	return e
}

func xmlFromAPI(xml *openapiv3.Xml) *Xml {
	if xml == nil {
		return nil
	}
	return &Xml{
		Name:                   xml.Name,
		Namespace:              xml.Namespace,
		Prefix:                 xml.Prefix,
		Attribute:              xml.Attribute,
		Wrapped:                xml.Wrapped,
		SpecificationExtension: extensionFromAPI(xml.SpecificationExtension),
	}
}

func xmlToAPI(xml *Xml) *openapiv3.Xml {
	if xml == nil {
		return nil
	}
	return &openapiv3.Xml{
		Name:                   xml.Name,
		Namespace:              xml.Namespace,
		Prefix:                 xml.Prefix,
		Attribute:              xml.Attribute,
		Wrapped:                xml.Wrapped,
		SpecificationExtension: extensionToAPI(xml.SpecificationExtension),
	}
}

func discriminatorFromAPI(discriminator *openapiv3.Discriminator) *Discriminator {
	if discriminator == nil {
		return nil
	}
	d := &Discriminator{
		PropertyName:           discriminator.PropertyName,
		SpecificationExtension: extensionFromAPI(discriminator.SpecificationExtension),
	}
	if discriminator.Mapping != nil {
		d.Mapping = make(map[string]string)
		for _, v := range discriminator.Mapping.AdditionalProperties {
			d.Mapping[v.Name] = v.Value
		}
	}
	return d
}

func discriminatorToAPI(discriminator *Discriminator) *openapiv3.Discriminator {
	if discriminator == nil {
		return nil
	}
	d := &openapiv3.Discriminator{
		PropertyName:           discriminator.PropertyName,
		SpecificationExtension: extensionToAPI(discriminator.SpecificationExtension),
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

func externalDocsFromAPI(docs *openapiv3.ExternalDocs) *ExternalDocs {
	if docs == nil {
		return nil
	}
	return &ExternalDocs{
		Description:            docs.Description,
		Url:                    docs.Url,
		SpecificationExtension: extensionFromAPI(docs.SpecificationExtension),
	}
}

func externalDocsToAPI(externalDocs *ExternalDocs) *openapiv3.ExternalDocs {
	if externalDocs == nil {
		return nil
	}
	return &openapiv3.ExternalDocs{
		Description:            externalDocs.Description,
		Url:                    externalDocs.Url,
		SpecificationExtension: extensionToAPI(externalDocs.SpecificationExtension),
	}
}

func additionalPropertiesItemFromAPI(item *openapiv3.AdditionalPropertiesItem) *AdditionalPropertiesItem {
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
				SchemaOrReference: schemaOrReferenceFromAPI(x),
			},
		}
	}
	return nil
}

func additionalPropertiesItemToAPI(additionalPropertiesItem *AdditionalPropertiesItem) *openapiv3.AdditionalPropertiesItem {
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
			SchemaOrReference: schemaOrReferenceToAPI(x),
		},
	}
}

func defaultFromAPI(default_ *openapiv3.DefaultType) *DefaultType {
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

func defaultTypeToAPI(defaultType *DefaultType) *openapiv3.DefaultType {
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

func commonFromAPI(s *openapiv3.Schema) *SchemaCommon {
	if s == nil || !isCommon(s) {
		return nil
	}
	common := &SchemaCommon{
		Type:        s.Type,
		Format:      s.Format,
		Description: s.Description,
		Default:     defaultFromAPI(s.Default),
		Example:     anyFromAPI(s.Example),
		Nullable:    s.Nullable,
		ReadOnly:    s.ReadOnly,
		WriteOnly:   s.WriteOnly,
		Deprecated:  s.Deprecated,
	}
	if s.Enum != nil {
		for _, v := range s.Enum {
			common.Enum = append(common.Enum, anyFromAPI(v))
		}
	}

	return common
}

func commonToAPI(s *SchemaCommon) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	x := s.Type
	if x == "map" {
		x = "object"
	}
	schema := &openapiv3.Schema{
		Type:        x,
		Format:      s.Format,
		Description: s.Description,
		Default:     defaultTypeToAPI(s.Default),
		Example:     anyToAPI(s.Example),
		Nullable:    s.Nullable,
		ReadOnly:    s.ReadOnly,
		WriteOnly:   s.WriteOnly,
		Deprecated:  s.Deprecated,
	}
	if s.Enum != nil {
		for _, v := range s.Enum {
			schema.Enum = append(schema.Enum, anyToAPI(v))
		}
	}
	return schema
}

func oasBooleanFromAPI(s *openapiv3.Schema) *OASBoolean {
	if s == nil || s.Type != "boolean" {
		return nil
	}

	return &OASBoolean{
		Common: commonFromAPI(s),
	}
}

func oasBooleanToAPI(s *OASBoolean) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := commonToAPI(s.Common)
	schema.Type = "boolean"
	return schema
}

func numberFromAPI(s *openapiv3.Schema) *SchemaNumber {
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

func numberToAPI(s *SchemaNumber) *openapiv3.Schema {
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

func oasNumberFromAPI(s *openapiv3.Schema) *OASNumber {
	if s == nil || (!isNumber(s) && !isCommon(s)) {
		return nil
	}

	return &OASNumber{
		Common: commonFromAPI(s),
		Number: numberFromAPI(s),
	}
}

func plusCommon(s *openapiv3.Schema, c *SchemaCommon) *openapiv3.Schema {
	if s == nil && c == nil {
		return nil
	}
	if s == nil {
		s = &openapiv3.Schema{}
	}
	x := c.Type
	if x == "map" {
		x = "object"
	}
	s.Type = x
	s.Format = c.Format
	s.Description = c.Description
	s.Default = defaultTypeToAPI(c.Default)
	s.Example = anyToAPI(c.Example)
	s.Nullable = c.Nullable
	s.ReadOnly = c.ReadOnly
	s.WriteOnly = c.WriteOnly
	s.Deprecated = c.Deprecated
	for _, v := range c.Enum {
		s.Enum = append(s.Enum, anyToAPI(v))
	}
	return s
}

func oasNumberToAPI(s *OASNumber) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(numberToAPI(s.Number), s.Common)
}

func stringFromAPI(s *openapiv3.Schema) *SchemaString {
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

func stringToAPI(s *SchemaString) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return &openapiv3.Schema{
		MinLength: s.MinLength,
		MaxLength: s.MaxLength,
		Pattern:   s.Pattern,
	}
}

func oasStringFromAPI(s *openapiv3.Schema) *OASString {
	if s == nil || (!isString(s) && !isCommon(s)) {
		return nil
	}

	return &OASString{
		Common:  commonFromAPI(s),
		String_: stringFromAPI(s),
	}
}

func oasStringToAPI(s *OASString) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(stringToAPI(s.String_), s.Common)
}

func arrayFromAPI(s *openapiv3.Schema) *SchemaArray {
	if s == nil || !isArray(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.Items.SchemaOrReference {
		items = append(items, schemaOrReferenceFromAPI(v))
	}
	return &SchemaArray{
		Items:       items,
		MaxItems:    s.MaxItems,
		MinItems:    s.MinItems,
		UniqueItems: s.UniqueItems,
	}
}

func arrayToAPI(s *SchemaArray) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := &openapiv3.Schema{
		MaxItems:    s.MaxItems,
		MinItems:    s.MinItems,
		UniqueItems: s.UniqueItems,
	}
	for _, v := range s.Items {
		if schema.Items == nil {
			schema.Items = &openapiv3.ItemsItem{}
		}
		schema.Items.SchemaOrReference = append(schema.Items.SchemaOrReference, schemaOrReferenceToAPI(v))
	}
	return schema
}

func oasArrayFromAPI(s *openapiv3.Schema) *OASArray {
	if s == nil || (!isArray(s) && !isCommon(s)) {
		return nil
	}

	return &OASArray{
		Common: commonFromAPI(s),
		Array:  arrayFromAPI(s),
	}
}

func oasArrayToAPI(s *OASArray) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(arrayToAPI(s.Array), s.Common)
}

func objectFromAPI(s *openapiv3.Schema) *SchemaObject {
	if s == nil || !isObject(s) {
		return nil
	}
	var properties map[string]*SchemaOrReference
	if s.Properties != nil {
		properties = make(map[string]*SchemaOrReference)
		for _, v := range s.Properties.AdditionalProperties {
			properties[v.Name] = schemaOrReferenceFromAPI(v.Value)
		}
	}
	return &SchemaObject{
		Properties:    properties,
		MaxProperties: s.MaxProperties,
		MinProperties: s.MinProperties,
		Required:      s.Required,
	}
}

func objectToAPI(s *SchemaObject) *openapiv3.Schema {
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
				&openapiv3.NamedSchemaOrReference{Name: k, Value: schemaOrReferenceToAPI(v)},
			)
		}
	}
	return schema
}

func oasObjectFromAPI(s *openapiv3.Schema) *OASObject {
	if s == nil || (!isObject(s) && !isCommon(s)) {
		return nil
	}

	return &OASObject{
		Common: commonFromAPI(s),
		Object: objectFromAPI(s),
	}
}

func oasObjectToAPI(s *OASObject) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(objectToAPI(s.Object), s.Common)
}

func mapFromAPI(s *openapiv3.Schema) *SchemaMap {
	if s == nil || !isMap(s) {
		return nil
	}
	return &SchemaMap{
		AdditionalProperties: additionalPropertiesItemFromAPI(s.AdditionalProperties),
	}
}

func mapToAPI(s *SchemaMap) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return &openapiv3.Schema{
		AdditionalProperties: additionalPropertiesItemToAPI(s.AdditionalProperties),
	}
}

func oasMapFromAPI(s *openapiv3.Schema) *OASMap {
	if s == nil || (!isMap(s) && !isCommon(s)) {
		return nil
	}

	return &OASMap{
		Common: commonFromAPI(s),
		Map:    mapFromAPI(s),
	}
}

func oasMapToAPI(s *OASMap) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(mapToAPI(s.Map), s.Common)
}

func allOfFromAPI(s *openapiv3.Schema) *SchemaAllOf {
	if s == nil || !isAllOf(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.AllOf {
		items = append(items, schemaOrReferenceFromAPI(v))
	}
	return &SchemaAllOf{
		Items: items,
	}
}

func allOfToAPI(s *SchemaAllOf) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := &openapiv3.Schema{}
	for _, v := range s.Items {
		schema.AllOf = append(schema.AllOf, schemaOrReferenceToAPI(v))
	}
	return schema
}

func oneOfFromAPI(s *openapiv3.Schema) *SchemaOneOf {
	if s == nil || !isOneOf(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.OneOf {
		items = append(items, schemaOrReferenceFromAPI(v))
	}
	return &SchemaOneOf{
		Items: items,
	}
}

func oneOfToAPI(s *SchemaOneOf) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := &openapiv3.Schema{}
	for _, v := range s.Items {
		schema.OneOf = append(schema.OneOf, schemaOrReferenceToAPI(v))
	}
	return schema
}

func anyOfFromAPI(s *openapiv3.Schema) *SchemaAnyOf {
	if s == nil || !isAnyOf(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.AnyOf {
		items = append(items, schemaOrReferenceFromAPI(v))
	}
	return &SchemaAnyOf{
		Items: items,
	}
}

func anyOfToAPI(s *SchemaAnyOf) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	schema := &openapiv3.Schema{}
	for _, v := range s.Items {
		schema.AnyOf = append(schema.AnyOf, schemaOrReferenceToAPI(v))
	}
	return schema
}

func schemaFromAPI(schema *openapiv3.Schema) *Schema {
	if schema == nil {
		return nil
	}

	return &Schema{
		Xml:          xmlFromAPI(schema.Xml),
		ExternalDocs: externalDocsFromAPI(schema.ExternalDocs),
		Title:        schema.Title,
		Not: schemaOrReferenceFromAPI(&openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{Schema: schema.Not}}),
		Discriminator:          discriminatorFromAPI(schema.Discriminator),
		SpecificationExtension: extensionFromAPI(schema.SpecificationExtension),
		AllOf:                  allOfFromAPI(schema),
		OneOf:                  oneOfFromAPI(schema),
		AnyOf:                  anyOfFromAPI(schema),
		Object:                 objectFromAPI(schema),
		Array:                  arrayFromAPI(schema),
		Map:                    mapFromAPI(schema),
		String_:                stringFromAPI(schema),
		Number:                 numberFromAPI(schema),
		Common:                 commonFromAPI(schema),
	}
}

func schemaToAPI(schema *Schema) *openapiv3.Schema {
	if schema == nil {
		return nil
	}

	s := &openapiv3.Schema{
		Xml:                    xmlToAPI(schema.Xml),
		ExternalDocs:           externalDocsToAPI(schema.ExternalDocs),
		Title:                  schema.Title,
		Discriminator:          discriminatorToAPI(schema.Discriminator),
		SpecificationExtension: extensionToAPI(schema.SpecificationExtension),
	}
	if schema.Not != nil {
		s.Not = schemaToAPI(schema.Not.GetSchema())
	}
	if schema.AllOf != nil {
		s.AllOf = allOfToAPI(schema.AllOf).AllOf
	}
	if schema.OneOf != nil {
		s.OneOf = oneOfToAPI(schema.OneOf).OneOf
	}
	if schema.AnyOf != nil {
		s.AnyOf = anyOfToAPI(schema.AnyOf).AnyOf
	}
	if schema.Object != nil {
		x := objectToAPI(schema.Object)
		s.Properties = x.Properties
		s.MaxProperties = x.MaxProperties
		s.MinProperties = x.MinProperties
		s.Required = x.Required
	}
	if schema.Array != nil {
		x := arrayToAPI(schema.Array)
		s.Items = x.Items
		s.MaxItems = x.MaxItems
		s.MinItems = x.MinItems
		s.UniqueItems = x.UniqueItems
	}
	if schema.Map != nil {
		x := mapToAPI(schema.Map)
		s.AdditionalProperties = x.AdditionalProperties
	}
	if schema.String_ != nil {
		x := stringToAPI(schema.String_)
		s.MinLength = x.MinLength
		s.MaxLength = x.MaxLength
		s.Pattern = x.Pattern
	}
	if schema.Number != nil {
		x := numberToAPI(schema.Number)
		s.MultipleOf = x.MultipleOf
		s.Minimum = x.Minimum
		s.Maximum = x.Maximum
		s.ExclusiveMinimum = x.ExclusiveMinimum
		s.ExclusiveMaximum = x.ExclusiveMaximum
	}
	if schema.Common != nil {
		x := commonToAPI(schema.Common)
		y := x.Type
		if y == "map" {
			y = "object"
		}
		s.Type = y
		s.Format = x.Format
		s.Description = x.Description
		s.Example = x.Example
		s.Default = x.Default
		s.Nullable = x.Nullable
		s.ReadOnly = x.ReadOnly
		s.WriteOnly = x.WriteOnly
		s.Deprecated = x.Deprecated
		s.Enum = x.Enum
	}

	return s
}
