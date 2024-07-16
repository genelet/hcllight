package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
	//"github.com/k0kubun/pp/v3"
)

func schemaOrReferenceFromApi(schema *openapiv3.SchemaOrReference, force ...bool) *SchemaOrReference {
	if schema == nil {
		return nil
	}

	if x := schema.GetReference(); x != nil {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Reference{
				Reference: referenceFromApi(x),
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
				Schema: schemaFromApi(s),
			},
		}
	}

	common := commonFromApi(s)
	if common == nil {
		if isAllOf(s) {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_AllOf{
					AllOf: allOfFromApi(s),
				},
			}
		}
		if isOneOf(s) {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_OneOf{
					OneOf: oneOfFromApi(s),
				},
			}
		}
		if isAnyOf(s) {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_AnyOf{
					AnyOf: anyOfFromApi(s),
				},
			}
		}
	}

	switch s.Type {
	case "array":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Array{
				Array: oasArrayFromApi(s),
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
					Map: oasMapFromApi(s),
				},
			}
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Object{
				Object: oasObjectFromApi(s),
			},
		}
	case "string":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_String_{
				String_: oasStringFromApi(s),
			},
		}
	case "number", "integer":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Number{
				Number: oasNumberFromApi(s),
			},
		}
	case "boolean":
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Boolean{
				Boolean: oasBooleanFromApi(s),
			},
		}
	default:
	}
	return nil
}

func schemaOrReferenceToApi(schema *SchemaOrReference) *openapiv3.SchemaOrReference {
	if schema == nil {
		return nil
	}

	switch schema.Oneof.(type) {
	case *SchemaOrReference_Reference:
		x := schema.GetReference()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Reference{
				Reference: referenceToApi(x),
			},
		}
	case *SchemaOrReference_AllOf:
		x := schema.GetAllOf()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: allOfToApi(x),
			},
		}
	case *SchemaOrReference_OneOf:
		x := schema.GetOneOf()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oneOfToApi(x),
			},
		}
	case *SchemaOrReference_AnyOf:
		x := schema.GetAnyOf()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: anyOfToApi(x),
			},
		}
	case *SchemaOrReference_Schema:
		s := schema.GetSchema()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: schemaToApi(s),
			},
		}
	case *SchemaOrReference_Array:
		x := schema.GetArray()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasArrayToApi(x),
			},
		}
	case *SchemaOrReference_Object:
		x := schema.GetObject()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasObjectToApi(x),
			},
		}
	case *SchemaOrReference_Map:
		x := schema.GetMap()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasMapToApi(x),
			},
		}
	case *SchemaOrReference_String_:
		x := schema.GetString_()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasStringToApi(x),
			},
		}
	case *SchemaOrReference_Number:
		x := schema.GetNumber()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasNumberToApi(x),
			},
		}
	case *SchemaOrReference_Boolean:
		x := schema.GetBoolean()
		return &openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{
				Schema: oasBooleanToApi(x),
			},
		}
	default:
	}

	return nil
}

func anyFromApi(any *openapiv3.Any) *Any {
	if any == nil {
		return nil
	}
	return &Any{
		Yaml:  any.Yaml,
		Value: any.Value,
	}
}

func anyToApi(any *Any) *openapiv3.Any {
	if any == nil {
		return nil
	}
	return &openapiv3.Any{
		Yaml:  any.Yaml,
		Value: any.Value,
	}
}

func extensionFromApi(extension []*openapiv3.NamedAny) map[string]*Any {
	if extension == nil {
		return nil
	}
	e := make(map[string]*Any)
	for _, v := range extension {
		e[v.Name] = anyFromApi(v.Value)
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

func xmlFromApi(xml *openapiv3.Xml) *Xml {
	if xml == nil {
		return nil
	}
	return &Xml{
		Name:                   xml.Name,
		Namespace:              xml.Namespace,
		Prefix:                 xml.Prefix,
		Attribute:              xml.Attribute,
		Wrapped:                xml.Wrapped,
		SpecificationExtension: extensionFromApi(xml.SpecificationExtension),
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

func discriminatorFromApi(discriminator *openapiv3.Discriminator) *Discriminator {
	if discriminator == nil {
		return nil
	}
	d := &Discriminator{
		PropertyName:           discriminator.PropertyName,
		SpecificationExtension: extensionFromApi(discriminator.SpecificationExtension),
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

func externalDocsFromApi(docs *openapiv3.ExternalDocs) *ExternalDocs {
	if docs == nil {
		return nil
	}
	return &ExternalDocs{
		Description:            docs.Description,
		Url:                    docs.Url,
		SpecificationExtension: extensionFromApi(docs.SpecificationExtension),
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

func additionalPropertiesItemFromApi(item *openapiv3.AdditionalPropertiesItem) *AdditionalPropertiesItem {
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
				SchemaOrReference: schemaOrReferenceFromApi(x),
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
			SchemaOrReference: schemaOrReferenceToApi(x),
		},
	}
}

func defaultFromApi(default_ *openapiv3.DefaultType) *DefaultType {
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

func commonFromApi(s *openapiv3.Schema) *SchemaCommon {
	if s == nil || !isCommon(s) {
		return nil
	}
	common := &SchemaCommon{
		Type:        s.Type,
		Format:      s.Format,
		Description: s.Description,
		Default:     defaultFromApi(s.Default),
		Example:     anyFromApi(s.Example),
	}
	if s.Enum != nil {
		for _, v := range s.Enum {
			common.Enum = append(common.Enum, anyFromApi(v))
		}
	}

	return common
}

func commonToApi(s *SchemaCommon) *openapiv3.Schema {
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
		Default:     defaultTypeToApi(s.Default),
		Example:     anyToApi(s.Example),
	}
	if s.Enum != nil {
		for _, v := range s.Enum {
			schema.Enum = append(schema.Enum, anyToApi(v))
		}
	}
	return schema
}

func oasBooleanFromApi(s *openapiv3.Schema) *OASBoolean {
	if s == nil || s.Type != "boolean" {
		return nil
	}

	return &OASBoolean{
		Common: commonFromApi(s),
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

func numberFromApi(s *openapiv3.Schema) *SchemaNumber {
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

func oasNumberFromApi(s *openapiv3.Schema) *OASNumber {
	if s == nil || (!isNumber(s) && !isCommon(s)) {
		return nil
	}

	return &OASNumber{
		Common: commonFromApi(s),
		Number: numberFromApi(s),
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
	s.Default = defaultTypeToApi(c.Default)
	s.Example = anyToApi(c.Example)
	for _, v := range c.Enum {
		s.Enum = append(s.Enum, anyToApi(v))
	}
	return s
}

func oasNumberToApi(s *OASNumber) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(numberToApi(s.Number), s.Common)
}

func stringFromApi(s *openapiv3.Schema) *SchemaString {
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

func oasStringFromApi(s *openapiv3.Schema) *OASString {
	if s == nil || (!isString(s) && !isCommon(s)) {
		return nil
	}

	return &OASString{
		Common:  commonFromApi(s),
		String_: stringFromApi(s),
	}
}

func oasStringToApi(s *OASString) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(stringToApi(s.String_), s.Common)
}

func arrayFromApi(s *openapiv3.Schema) *SchemaArray {
	if s == nil || !isArray(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.Items.SchemaOrReference {
		items = append(items, schemaOrReferenceFromApi(v))
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
		if schema.Items == nil {
			schema.Items = &openapiv3.ItemsItem{}
		}
		schema.Items.SchemaOrReference = append(schema.Items.SchemaOrReference, schemaOrReferenceToApi(v))
	}
	return schema
}

func oasArrayFromApi(s *openapiv3.Schema) *OASArray {
	if s == nil || (!isArray(s) && !isCommon(s)) {
		return nil
	}

	return &OASArray{
		Common: commonFromApi(s),
		Array:  arrayFromApi(s),
	}
}

func oasArrayToApi(s *OASArray) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(arrayToApi(s.Array), s.Common)
}

func objectFromApi(s *openapiv3.Schema) *SchemaObject {
	if s == nil || !isObject(s) {
		return nil
	}
	var properties map[string]*SchemaOrReference
	if s.Properties != nil {
		properties = make(map[string]*SchemaOrReference)
		for _, v := range s.Properties.AdditionalProperties {
			properties[v.Name] = schemaOrReferenceFromApi(v.Value)
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
				&openapiv3.NamedSchemaOrReference{Name: k, Value: schemaOrReferenceToApi(v)},
			)
		}
	}
	return schema
}

func oasObjectFromApi(s *openapiv3.Schema) *OASObject {
	if s == nil || (!isObject(s) && !isCommon(s)) {
		return nil
	}

	return &OASObject{
		Common: commonFromApi(s),
		Object: objectFromApi(s),
	}
}

func oasObjectToApi(s *OASObject) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(objectToApi(s.Object), s.Common)
}

func mapFromApi(s *openapiv3.Schema) *SchemaMap {
	if s == nil || !isMap(s) {
		return nil
	}
	return &SchemaMap{
		AdditionalProperties: additionalPropertiesItemFromApi(s.AdditionalProperties),
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

func oasMapFromApi(s *openapiv3.Schema) *OASMap {
	if s == nil || (!isMap(s) && !isCommon(s)) {
		return nil
	}

	return &OASMap{
		Common: commonFromApi(s),
		Map:    mapFromApi(s),
	}
}

func oasMapToApi(s *OASMap) *openapiv3.Schema {
	if s == nil {
		return nil
	}
	return plusCommon(mapToApi(s.Map), s.Common)
}

func allOfFromApi(s *openapiv3.Schema) *SchemaAllOf {
	if s == nil || !isAllOf(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.AllOf {
		items = append(items, schemaOrReferenceFromApi(v))
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
		schema.AllOf = append(schema.AllOf, schemaOrReferenceToApi(v))
	}
	return schema
}

func oneOfFromApi(s *openapiv3.Schema) *SchemaOneOf {
	if s == nil || !isOneOf(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.OneOf {
		items = append(items, schemaOrReferenceFromApi(v))
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
		schema.OneOf = append(schema.OneOf, schemaOrReferenceToApi(v))
	}
	return schema
}

func anyOfFromApi(s *openapiv3.Schema) *SchemaAnyOf {
	if s == nil || !isAnyOf(s) {
		return nil
	}
	var items []*SchemaOrReference
	for _, v := range s.AnyOf {
		items = append(items, schemaOrReferenceFromApi(v))
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
		schema.AnyOf = append(schema.AnyOf, schemaOrReferenceToApi(v))
	}
	return schema
}

func schemaFromApi(schema *openapiv3.Schema) *Schema {
	if schema == nil {
		return nil
	}

	return &Schema{
		Nullable:     schema.Nullable,
		ReadOnly:     schema.ReadOnly,
		WriteOnly:    schema.WriteOnly,
		Xml:          xmlFromApi(schema.Xml),
		ExternalDocs: externalDocsFromApi(schema.ExternalDocs),
		Deprecated:   schema.Deprecated,
		Title:        schema.Title,
		Not: schemaOrReferenceFromApi(&openapiv3.SchemaOrReference{
			Oneof: &openapiv3.SchemaOrReference_Schema{Schema: schema.Not}}),
		Discriminator:          discriminatorFromApi(schema.Discriminator),
		SpecificationExtension: extensionFromApi(schema.SpecificationExtension),
		AllOf:                  allOfFromApi(schema),
		OneOf:                  oneOfFromApi(schema),
		AnyOf:                  anyOfFromApi(schema),
		Object:                 objectFromApi(schema),
		Array:                  arrayFromApi(schema),
		Map:                    mapFromApi(schema),
		String_:                stringFromApi(schema),
		Number:                 numberFromApi(schema),
		Common:                 commonFromApi(schema),
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
		Deprecated:             schema.Deprecated,
		Title:                  schema.Title,
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
		y := x.Type
		if y == "map" {
			y = "object"
		}
		s.Type = y
		s.Format = x.Format
		s.Description = x.Description
		s.Example = x.Example
		s.Default = x.Default
		s.Enum = x.Enum
	}

	return s
}
