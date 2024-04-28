package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func extensionToHcl(extension []*openapiv3.NamedAny) map[string]*Any {
	if extension == nil {
		return nil
	}
	e := make(map[string]*Any)
	for _, v := range extension {
		e[v.Name] = &Any{Value: v.Value.Value}
	}
	return e
}

func ExternalDocsToHcl(docs *openapiv3.ExternalDocs) *ExternalDocs {
	return &ExternalDocs{
		Description:            docs.Description,
		Url:                    docs.Url,
		SpecificationExtension: extensionToHcl(docs.SpecificationExtension),
	}
}

func InfoToHcl(info *openapiv3.Info) *Info {
	if info == nil {
		return nil
	}
	return &Info{
		Title:                  info.Title,
		Description:            info.Description,
		TermsOfService:         info.TermsOfService,
		Version:                info.Version,
		Contact:                ContactToHcl(info.Contact),
		License:                LicenseToHcl(info.License),
		SpecificationExtension: extensionToHcl(info.SpecificationExtension),
	}
}

func TagToHcl(tag *openapiv3.Tag) *Tag {
	return &Tag{
		Name:                   tag.Name,
		Description:            tag.Description,
		ExternalDocs:           ExternalDocsToHcl(tag.ExternalDocs),
		SpecificationExtension: extensionToHcl(tag.SpecificationExtension),
	}
}

func ContactToHcl(contact *openapiv3.Contact) *Contact {
	return &Contact{
		Name:                   contact.Name,
		Url:                    contact.Url,
		Email:                  contact.Email,
		SpecificationExtension: extensionToHcl(contact.SpecificationExtension),
	}
}

func LicenseToHcl(license *openapiv3.License) *License {
	return &License{
		Name:                   license.Name,
		Url:                    license.Url,
		SpecificationExtension: extensionToHcl(license.SpecificationExtension),
	}
}

func ServerToHcl(server *openapiv3.Server) *Server {
	s := &Server{
		Url:                    server.Url,
		Description:            server.Description,
		SpecificationExtension: extensionToHcl(server.SpecificationExtension),
	}
	if server.Variables != nil {
		for _, v := range server.Variables.AdditionalProperties {
			if s.Variables == nil {
				s.Variables = make(map[string]*ServerVariable)
			}
			s.Variables[v.Name] = ServerVariableToHcl(v.Value)
		}
	}
	return s
}

func ServerVariableToHcl(variable *openapiv3.ServerVariable) *ServerVariable {
	return &ServerVariable{
		Default:                variable.Default,
		Enum:                   variable.Enum,
		Description:            variable.Description,
		SpecificationExtension: extensionToHcl(variable.SpecificationExtension),
	}
}

func StringArrayToHcl(array *openapiv3.StringArray) *StringArray {
	return &StringArray{
		Value: array.Value,
	}
}

func SecurityRequirementToHcl(requirement *openapiv3.SecurityRequirement) *SecurityRequirement {
	s := &SecurityRequirement{}
	for _, v := range requirement.AdditionalProperties {
		if s.AdditionalProperties == nil {
			s.AdditionalProperties = make(map[string]*StringArray)
		}
		s.AdditionalProperties[v.Name] = StringArrayToHcl(v.Value)
	}
	return s
}

func DocumentToHcl(doc *openapiv3.Document) *Document {
	d := &Document{
		Openapi:                doc.Openapi,
		Info:                   InfoToHcl(doc.Info),
		Components:             ComponentsToHcl(doc.Components),
		ExternalDocs:           ExternalDocsToHcl(doc.ExternalDocs),
		SpecificationExtension: extensionToHcl(doc.SpecificationExtension),
	}
	for _, s := range doc.Servers {
		d.Servers = append(d.Servers, ServerToHcl(s))
	}
	if doc.Paths != nil {
		d.PathItems = make(map[string]*PathItem)
		for _, v := range doc.Paths.Path {
			d.PathItems[v.Name] = PathItemToHcl(v.Value)
		}
	}
	for _, s := range doc.Security {
		d.Security = append(d.Security, SecurityRequirementToHcl(s))
	}
	for _, t := range doc.Tags {
		d.Tags = append(d.Tags, TagToHcl(t))
	}

	return d
}

func ComponentsToHcl(components *openapiv3.Components) *Components {
	c := &Components{
		Schemas:                make(map[string]*Schema),
		Responses:              make(map[string]*MediaTypesOrReference),
		Parameters:             make(map[string]*Parameter),
		Examples:               make(map[string]*Example),
		RequestBodies:          make(map[string]*RequestBody),
		SpecificationExtension: extensionToHcl(components.SpecificationExtension),
	}
	if components.Callbacks != nil {
		c.Calls = make(map[string]*CallbacksOrReference)
		for _, v := range components.Callbacks.AdditionalProperties {
			c.Calls[v.Name] = CallbacksToHcl(v.Value)
		}
	}
	if components.SecuritySchemes != nil {
		c.SecuritySchemes = make(map[string]*SecurityScheme)
		for _, v := range components.SecuritySchemes.AdditionalProperties {
			c.SecuritySchemes[v.Name] = SecuritySchemeToHcl(v.Value)
		}
	}
	if components.Headers != nil {
		c.Headers = headersToHcl(components.Headers.AdditionalProperties)
	}

	for k, v := range components.Schemas {
		c.Schemas[k] = SchemaToHcl(v)
	}
	for k, v := range components.Responses {
		x, y := MediaTypesOrReferenceToHcl(v)
		if x != nil {
			c.Responses[k] = x
		}
		if y != nil {
			c.Headers[k] = y
		}
	}
	for k, v := range components.Parameters {
		c.Parameters[k] = ParameterToHcl(v)
	}
	for k, v := range components.Examples {
		c.Examples[k] = ExampleToHcl(v)
	}
	for k, v := range components.RequestBodies {
		c.RequestBodies[k] = RequestBodyToHcl(v)
	}
	for k, v := range components.Headers {
		x, y := MediaTypesOrReferenceToHcl(v)
		if x != nil {
			c.Responses[k] = x
		}
		if y != nil {
			c.Headers[k] = y
		}
	}
	for k, v := range components.SecuritySchemes {
		c.SecuritySchemes[k] = SecuritySchemeToHcl(v)
	}
	for k, v := range components.Links {
		c.Links[k] = LinkToHcl(v)
	}
	for k, v := range components.Callbacks {
		c.Callbacks[k] = CallbacksToHcl(v)
	}
	return c
}

func SchemaToHcl(schema *openapiv3.Schema) *Schema {
	s := &Schema{
		Ref:                  schema.Ref,
		Title:                schema.Title,
		MultipleOf:           schema.MultipleOf,
		Maximum:              schema.Maximum,
		ExclusiveMaximum:     schema.ExclusiveMaximum,
		Minimum:              schema.Minimum,
		ExclusiveMinimum:     schema.ExclusiveMinimum,
		MaxLength:            schema.MaxLength,
		MinLength:            schema.MinLength,
		Pattern:              schema.Pattern,
		MaxItems:             schema.MaxItems,
		MinItems:             schema.MinItems,
		UniqueItems:          schema.UniqueItems,
		MaxProperties:        schema.MaxProperties,
		MinProperties:        schema.MinProperties,
		Required:             schema.Required,
		Enum:                 schema.Enum,
		Type:                 schema.Type,
		AllOf:                make([]*Schema, 0),
		OneOf:                make([]*Schema, 0),
		AnyOf:                make([]*Schema, 0),
		Not:                  SchemaToHcl(schema.Not),
		Items:                SchemaOrReferenceToHcl(schema.Items),
		Properties:           make(map[string]*Schema),
		AdditionalProperties: SchemaOrReferenceToHcl(schema.AdditionalProperties),
		Description:          schema.Description,
		Format:               schema.Format,
		Default:              schema.Default,
		Nullable:             schema.Nullable,
		Discriminator:        DiscriminatorToHcl(schema.Discriminator),
		ReadOnly:             schema.ReadOnly,
		WriteOnly:            schema.WriteOnly,
		Example:              schema.Example,
		ExternalDocs:         ExternalDocsToHcl(schema.ExternalDocs),
		Deprecated:           schema.Deprecated,
	}
	for _, s := range schema.AllOf {
		s.AllOf = append(s.AllOf, SchemaToHcl(s))
	}
	for _, s := range schema.OneOf {
		s.OneOf = append(s.OneOf, SchemaToHcl(s))
	}
	for _, s := range schema.AnyOf {
		s.AnyOf = append(s.AnyOf, SchemaToHcl(s))
	}
	for k, v := range schema.Properties {
		s.Properties[k] = SchemaToHcl(v)
	}
	for k, v := range schema.Extensions {
		s.Extensions = append(s.Extensions, ExtensionToHcl(k, v))
	}
	return s
}

func DiscriminatorToHcl(discriminator *openapiv3.Discriminator) *Discriminator {
	d := &Discriminator{
		PropertyName: discriminator.PropertyName,
		Mapping:      make(map[string]string),
	}
	for k, v := range discriminator.Mapping {
		d.Mapping[k] = v
	}
	for k, v := range discriminator.Extensions {
		d.Extensions = append(d.Extensions, ExtensionToHcl(k, v))
	}
	return d
}

func SchemaOrReferenceToHcl(schema *openapiv3.SchemaOrReference) *SchemaOrReference {
	s := &SchemaOrReference{
		Schema: SchemaToHcl(schema.Schema),
		Ref:    schema.Ref,
	}
	for k, v := range schema.Extensions {
		s.Extensions = append(s.Extensions, ExtensionToHcl(k, v))
	}
	return s
}

func EncodingToHcl(encoding *openapiv3.Encoding) *Encoding {
	e := &Encoding{
		ContentType:   encoding.ContentType,
		Headers:       make(map[string]*Header),
		Style:         encoding.Style,
		Explode:       encoding.Explode,
		AllowReserved: encoding.AllowReserved,
	}
	for k, v := range encoding.Headers {
		e.Headers[k] = HeaderToHcl(v)
	}
	for k, v := range encoding.Extensions {
		e.Extensions = append(e.Extensions, ExtensionToHcl(k, v))
	}
	return e
}

func ExampleToHcl(example *openapiv3.Example) *Example {
	e := &Example{
		Summary:       example.Summary,
		Description:   example.Description,
		Value:         example.Value,
		ExternalValue: example.ExternalValue,
	}
	for k, v := range example.Extensions {
		e.Extensions = append(e.Extensions, ExtensionToHcl(k, v))
	}
	return e
}

func RequestBodyToHcl(body *openapiv3.RequestBody) *RequestBody {
	r := &RequestBody{
		Ref:         body.Ref,
		Description: body.Description,
		Content:     make(map[string]*MediaType),
		Required:    body.Required,
	}
	for k, v := range body.Content {
		r.Content[k] = MediaTypeToHcl(v)
	}
	for k, v := range body.Extensions {
		r.Extensions = append(r.Extensions, ExtensionToHcl(k, v))
	}
	return r
}

func ParameterToHcl(parameter *openapiv3.Parameter) *Parameter {
	p := &Parameter{
		Ref:             parameter.Ref,
		Name:            parameter.Name,
		In:              parameter.In,
		Description:     parameter.Description,
		Required:        parameter.Required,
		Deprecated:      parameter.Deprecated,
		AllowEmptyValue: parameter.AllowEmptyValue,
		Style:           parameter.Style,
		Explode:         parameter.Explode,
		AllowReserved:   parameter.AllowReserved,
		Schema:          SchemaOrReferenceToHcl(parameter.Schema),
		Content:         make(map[string]*MediaType),
		Examples:        make(map[string]*Example),
	}
	for k, v := range parameter.Content {
		p.Content[k] = MediaTypeToHcl(v)
	}
	for k, v := range parameter.Examples {
		p.Examples[k] = ExampleToHcl(v)
	}
	for k, v := range parameter.Extensions {
		p.Extensions = append(p.Extensions, ExtensionToHcl(k, v))
	}
	return p
}

func PathItemToHcl(path *openapiv3.PathItem) *PathItem {
	p := &PathItem{
		XRef:                   path.XRef,
		Summary:                path.Summary,
		Description:            path.Description,
		Get:                    OperationToHcl(path.Get),
		Put:                    OperationToHcl(path.Put),
		Post:                   OperationToHcl(path.Post),
		Delete:                 OperationToHcl(path.Delete),
		Options:                OperationToHcl(path.Options),
		Head:                   OperationToHcl(path.Head),
		Patch:                  OperationToHcl(path.Patch),
		Trace:                  OperationToHcl(path.Trace),
		SpecificationExtension: extensionToHcl(path.SpecificationExtension),
	}
	for _, s := range path.Servers {
		p.Servers = append(p.Servers, ServerToHcl(s))
	}
	for _, s := range path.Parameters {
		p.Parameters = append(p.Parameters, ParameterOrReferenceToHcl(s))
	}
	return p
}

func ReferenceToHcl(reference *openapiv3.Reference) *Reference {
	return &Reference{
		XRef:        reference.XRef,
		Summary:     reference.Summary,
		Description: reference.Description,
	}
}

func ParameterOrReferenceToHcl(parameter *openapiv3.ParameterOrReference) *ParameterOrReference {
	if parameter == nil {
		return nil
	}
	if x := parameter.GetReference(); x != nil {
		return &ParameterOrReference{
			Oneof: &ParameterOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}

	p := parameter.GetParameter()
	return &ParameterOrReference{
		Oneof: &ParameterOrReference_Parameter{
			Parameter: ParameterToHcl(p),
		},
	}
}

func RequestBodyOrReferenceToHcl(body *openapiv3.RequestBodyOrReference) *RequestBodyOrReference {
	if body == nil {
		return nil
	}

	if x := body.GetReference(); x != nil {
		return &RequestBodyOrReference{
			Oneof: &RequestBodyOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}

	b := body.GetRequestBody()
	return &RequestBodyOrReference{
		Oneof: &RequestBodyOrReference_RequestBody{
			RequestBody: RequestBodyToHcl(b),
		},
	}
}

func OperationToHcl(operation *openapiv3.Operation) *Operation {
	o := &Operation{
		Tags:                   operation.Tags,
		Summary:                operation.Summary,
		Description:            operation.Description,
		ExternalDocs:           ExternalDocsToHcl(operation.ExternalDocs),
		OperationId:            operation.OperationId,
		RequestBody:            RequestBodyOrReferenceToHcl(operation.RequestBody),
		Deprecated:             operation.Deprecated,
		SpecificationExtension: extensionToHcl(operation.SpecificationExtension),
	}

	for _, s := range operation.Security {
		o.Security = append(o.Security, SecurityRequirementToHcl(s))
	}
	for _, s := range operation.Servers {
		o.Servers = append(o.Servers, ServerToHcl(s))
	}
	for _, s := range operation.Parameters {
		o.Parameters = append(o.Parameters, ParameterOrReferenceToHcl(s))
	}
	if operation.Callbacks != nil {
		o.Calls = make(map[string]*CallbacksOrReference)
		for _, v := range operation.Callbacks.AdditionalProperties {
			o.Calls[v.Name] = CallbacksToHcl(v.Value)
		}
	}
	if operation.Responses != nil {
		if operation.Responses.Default != nil {
			operation.Responses.ResponseOrReference = append(operation.Responses.ResponseOrReference, &openapiv3.NamedResponseOrReference{
				Name:  "default",
				Value: operation.Responses.Default,
			})
		}
		for _, v := range operation.Responses.ResponseOrReference {
			x, y := MediaTypesOrReferenceToHcl(v.Value)
			if x != nil {
				if o.Responses == nil {
					o.Responses = make(map[string]*MediaTypesOrReference)
				}
				o.Responses[v.Name] = x
			}
			if y != nil {
				if o.Headers == nil {
					o.Headers = make(map[string]*MediaTypesOrReference)
				}
				o.Headers[v.Name] = y
			}
		}
	}

	return o
}

func CallbacksToHcl(callbacks *openapiv3.CallbackOrReference) *CallbacksOrReference {
	if callbacks == nil {
		return nil
	}

	if x := callbacks.GetReference(); x != nil {
		return &CallbacksOrReference{
			Oneof: &CallbacksOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}

	cs := make(map[string]*PathItem)
	call := callbacks.GetCallback()
	for _, v := range call.Path {
		cs[v.Name] = PathItemToHcl(v.Value)
	}

	return &CallbacksOrReference{
		Oneof: &CallbacksOrReference_CallBacks{
			CallBacks: &Callbacks{
				Path: cs,
			},
		},
	}
}

func headersToHcl(headers *openapiv3.HeadersOrReferences) *MediaTypesOrReference {
	if headers == nil {
		return nil
	}

	hs := make(map[string]*SchemaOrReference)
	for _, v := range headers.AdditionalProperties {
		value := v.Value
		if ref := value.GetReference(); ref != nil {
			hs[v.Name] = &SchemaOrReference{
				Oneof: &SchemaOrReference_Reference{
					Reference: ReferenceToHcl(ref),
				},
			}
		} else {
			hs[v.Name] = SchemaOrReferenceToHcl(value.GetHeader().GetSchema())
		}
	}

	return &MediaTypesOrReference{
		Oneof: &MediaTypesOrReference_MediaTypes{
			MediaTypes: &MediaTypes{
				Content: hs,
			},
		},
	}
}

func mediaTypesToHcl(content *openapiv3.MediaTypes) *MediaTypesOrReference {
	if content == nil {
		return nil
	}

	cs := make(map[string]*SchemaOrReference)
	for _, v := range content.AdditionalProperties {
		value := v.Value
		if ref := value.Schema.GetReference(); ref != nil {
			cs[v.Name] = &SchemaOrReference{
				Oneof: &SchemaOrReference_Reference{
					Reference: ReferenceToHcl(ref),
				},
			}
		} else {
			cs[v.Name] = SchemaOrReferenceToHcl(value.GetSchema())
		}
	}

	return &MediaTypesOrReference{
		Oneof: &MediaTypesOrReference_MediaTypes{
			MediaTypes: &MediaTypes{
				Content: cs,
			},
		},
	}
}

func MediaTypesOrReferenceToHcl(response *openapiv3.ResponseOrReference) (*MediaTypesOrReference, *MediaTypesOrReference) {
	if response == nil {
		return nil, nil
	}

	if x := response.GetReference(); x != nil {
		return &MediaTypesOrReference{
			Oneof: &MediaTypesOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}, nil
	}

	r := response.GetResponse()
	return mediaTypesToHcl(r.Content), headersToHcl(r.Headers)
}
