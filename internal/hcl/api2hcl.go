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

func contactToHcl(contact *openapiv3.Contact) *Contact {
	return &Contact{
		Name:                   contact.Name,
		Url:                    contact.Url,
		Email:                  contact.Email,
		SpecificationExtension: extensionToHcl(contact.SpecificationExtension),
	}
}

func licenseToHcl(license *openapiv3.License) *License {
	return &License{
		Name:                   license.Name,
		Url:                    license.Url,
		SpecificationExtension: extensionToHcl(license.SpecificationExtension),
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
		Contact:                contactToHcl(info.Contact),
		License:                licenseToHcl(info.License),
		SpecificationExtension: extensionToHcl(info.SpecificationExtension),
		Summary:                info.Summary,
	}
}

func ExternalDocsToHcl(docs *openapiv3.ExternalDocs) *ExternalDocs {
	return &ExternalDocs{
		Description:            docs.Description,
		Url:                    docs.Url,
		SpecificationExtension: extensionToHcl(docs.SpecificationExtension),
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

func serverVariableToHcl(variable *openapiv3.ServerVariable) *ServerVariable {
	return &ServerVariable{
		Default:                variable.Default,
		Enum:                   variable.Enum,
		Description:            variable.Description,
		SpecificationExtension: extensionToHcl(variable.SpecificationExtension),
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
			s.Variables[v.Name] = serverVariableToHcl(v.Value)
		}
	}
	return s
}

func stringArrayToHcl(array *openapiv3.StringArray) *StringArray {
	return &StringArray{
		Value: array.Value,
	}
}

func oAuthFlowToHcl(flow *openapiv3.OauthFlow) *OauthFlow {
	if flow == nil {
		return nil
	}
	var scope map[string]string
	if flow.Scopes != nil {
		scope = make(map[string]string)
		for _, v := range flow.Scopes.AdditionalProperties {
			scope[v.Name] = v.Value
		}
	}
	return &OauthFlow{
		AuthorizationUrl:       flow.AuthorizationUrl,
		TokenUrl:               flow.TokenUrl,
		RefreshUrl:             flow.RefreshUrl,
		Scopes:                 scope,
		SpecificationExtension: extensionToHcl(flow.SpecificationExtension),
	}
}

func OAuthFlowsToHcl(flows *openapiv3.OauthFlows) *OauthFlows {
	if flows == nil {
		return nil
	}
	return &OauthFlows{
		Implicit:               oAuthFlowToHcl(flows.Implicit),
		Password:               oAuthFlowToHcl(flows.Password),
		ClientCredentials:      oAuthFlowToHcl(flows.ClientCredentials),
		AuthorizationCode:      oAuthFlowToHcl(flows.AuthorizationCode),
		SpecificationExtension: extensionToHcl(flows.SpecificationExtension),
	}
}

func SecurityRequirementToHcl(requirement *openapiv3.SecurityRequirement) *SecurityRequirement {
	if requirement == nil {
		return nil
	}
	s := make(map[string]*StringArray)
	for _, v := range requirement.AdditionalProperties {
		s[v.Name] = stringArrayToHcl(v.Value)
	}
	return &SecurityRequirement{
		AdditionalProperties: s,
	}
}

func SecuritySchemaToHcl(security *openapiv3.SecuritySchemeOrReference) *SecuritySchemeOrReference {
	if security == nil {
		return nil
	}
	if x := security.GetReference(); x != nil {
		return &SecuritySchemeOrReference{
			Oneof: &SecuritySchemeOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}
	s := security.GetSecurityScheme()
	return &SecuritySchemeOrReference{
		Oneof: &SecuritySchemeOrReference_SecurityScheme{
			SecurityScheme: &SecurityScheme{
				Type:                   s.Type,
				Description:            s.Description,
				Name:                   s.Name,
				In:                     s.In,
				Scheme:                 s.Scheme,
				BearerFormat:           s.BearerFormat,
				Flows:                  OAuthFlowsToHcl(s.Flows),
				OpenIdConnectUrl:       s.OpenIdConnectUrl,
				SpecificationExtension: extensionToHcl(s.SpecificationExtension),
			},
		},
	}
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

func anyOrReferenceToHcl(any *openapiv3.AnyOrExpression) *AnyOrExpression {
	if any == nil {
		return nil
	}
	if x := any.GetAny(); x != nil {
		return &AnyOrExpression{
			Oneof: &AnyOrExpression_Any{
				Any: anyToHcl(x),
			},
		}
	}

	e := any.GetExpression()
	expr := make(map[string]*Any)
	for _, v := range e.AdditionalProperties {
		expr[v.Name] = anyToHcl(v.Value)
	}
	return &AnyOrExpression{
		Oneof: &AnyOrExpression_Expression{
			Expression: &Expression{
				AdditionalProperties: expr,
			},
		},
	}
}

func LinkToHcl(link *openapiv3.LinkOrReference) *LinkOrReference {
	if link == nil {
		return nil
	}
	if x := link.GetReference(); x != nil {
		return &LinkOrReference{
			Oneof: &LinkOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}

	l := link.GetLink()
	return &LinkOrReference{
		Oneof: &LinkOrReference_Link{
			Link: &Link{
				OperationRef:           l.OperationRef,
				OperationId:            l.OperationId,
				Parameters:             anyOrReferenceToHcl(l.Parameters),
				RequestBody:            anyOrReferenceToHcl(l.RequestBody),
				Description:            l.Description,
				Server:                 ServerToHcl(l.Server),
				SpecificationExtension: extensionToHcl(l.SpecificationExtension),
			},
		},
	}
}

func responseOrReferenceToRequestOrReference(res *openapiv3.ResponseOrReference) *openapiv3.RequestBodyOrReference {
	if x := res.GetReference(); x != nil {
		return &openapiv3.RequestBodyOrReference{
			Oneof: &openapiv3.RequestBodyOrReference_Reference{
				Reference: x,
			},
		}
	}
	x := res.GetResponse()
	return &openapiv3.RequestBodyOrReference{
		Oneof: &openapiv3.RequestBodyOrReference_RequestBody{
			RequestBody: &openapiv3.RequestBody{
				Content: x.Content,
			},
		},
	}
}

func ComponentsToHcl(components *openapiv3.Components) *Components {
	c := &Components{
		SpecificationExtension: extensionToHcl(components.SpecificationExtension),
	}
	if components.Callbacks != nil {
		c.Calls = make(map[string]*CallbacksOrReference)
		for _, v := range components.Callbacks.AdditionalProperties {
			c.Calls[v.Name] = CallbacksToHcl(v.Value)
		}
	}
	if components.Links != nil {
		c.Links = make(map[string]*LinkOrReference)
		for _, v := range components.Links.AdditionalProperties {
			c.Links[v.Name] = LinkToHcl(v.Value)
		}
	}
	if components.SecuritySchemes != nil {
		c.SecuritySchemes = make(map[string]*SecuritySchemeOrReference)
		for _, v := range components.SecuritySchemes.AdditionalProperties {
			c.SecuritySchemes[v.Name] = SecuritySchemaToHcl(v.Value)
		}
	}
	if components.Examples != nil {
		c.Examples = make(map[string]*ExampleOrReference)
		for _, v := range components.Examples.AdditionalProperties {
			c.Examples[v.Name] = ExampleOrReferenceToHcl(v.Value)
		}
	}
	if components.RequestBodies != nil {
		c.RequestBodies = make(map[string]*RequestBodyOrReference)
		for _, v := range components.RequestBodies.AdditionalProperties {
			c.RequestBodies[v.Name] = RequestBodyOrReferenceToHcl(v.Value)
		}
	}
	if components.Schemas != nil {
		c.Schemas = make(map[string]*SchemaOrReference)
		for _, v := range components.Schemas.AdditionalProperties {
			c.Schemas[v.Name] = SchemaOrReferenceToHcl(v.Value)
		}
	}
	if components.Parameters != nil {
		c.Parameters = make(map[string]*ParameterOrReference)
		for _, v := range components.Parameters.AdditionalProperties {
			c.Parameters[v.Name] = ParameterOrReferenceToHcl(v.Value)
		}
	}
	if components.Responses != nil {
		c.Responses = make(map[string]*RequestBodyOrReference)
		for _, v := range components.Responses.AdditionalProperties {
			c.Responses[v.Name] = RequestBodyOrReferenceToHcl(responseOrReferenceToRequestOrReference(v.Value))
		}
	}
	if components.Headers != nil {
		c.Headers = make(map[string]*SchemaOrReference)
		for _, v := range components.Headers.AdditionalProperties {
			c.Headers[v.Name] = headerOrReferenceToHcl(v.Value)
		}
	}
	if components.Schemas != nil {
		c.Schemas = make(map[string]*SchemaOrReference)
		for _, v := range components.Schemas.AdditionalProperties {
			c.Schemas[v.Name] = SchemaOrReferenceToHcl(v.Value)
		}
	}

	if components.RequestBodies != nil {
		c.RequestBodies = make(map[string]*RequestBodyOrReference)
		for _, v := range components.RequestBodies.AdditionalProperties {
			c.RequestBodies[v.Name] = RequestBodyOrReferenceToHcl(v.Value)
		}
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

	s := SchemaToHcl(schema.GetSchema())
	return &SchemaOrReference{
		Oneof: &SchemaOrReference_Array{
			Schema: s,
		},
	}
}

func ExampleOrReferenceToHcl(example *openapiv3.ExampleOrReference) *ExampleOrReference {
	if example == nil {
		return nil
	}
	if x := example.GetReference(); x != nil {
		return &ExampleOrReference{
			Oneof: &ExampleOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}

	e := example.GetExample()
	return &ExampleOrReference{
		Oneof: &ExampleOrReference_Example{
			Example: &Example{
				Summary:                e.Summary,
				Description:            e.Description,
				Value:                  anyToHcl(e.Value),
				SpecificationExtension: extensionToHcl(e.SpecificationExtension),
			},
		},
	}
}

func anyToHcl(any *openapiv3.Any) *Any {
	if any == nil {
		return nil
	}
	return &Any{
		Value: any.Value,
	}
}

func ParameterToHcl(parameter *openapiv3.Parameter) *Parameter {
	p := &Parameter{
		Name:                   parameter.Name,
		In:                     parameter.In,
		Description:            parameter.Description,
		Required:               parameter.Required,
		Deprecated:             parameter.Deprecated,
		AllowEmptyValue:        parameter.AllowEmptyValue,
		Style:                  parameter.Style,
		Explode:                parameter.Explode,
		AllowReserved:          parameter.AllowReserved,
		Schema:                 SchemaOrReferenceToHcl(parameter.Schema),
		Example:                anyToHcl(parameter.Example),
		SpecificationExtension: extensionToHcl(parameter.SpecificationExtension),
	}
	if parameter.Content != nil {
		p.Content = make(map[string]*SchemaOrReference)
		for _, v := range parameter.Content.AdditionalProperties {
			p.Content[v.Name] = mediaTypeToHcl(v.Value)
		}
	}
	if parameter.Examples != nil {
		p.Examples = make(map[string]*ExampleOrReference)
		for _, v := range parameter.Examples.AdditionalProperties {
			p.Examples[v.Name] = ExampleOrReferenceToHcl(v.Value)
		}
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
	if reference == nil {
		return nil
	}
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
			RequestBody: requestBodyToHcl(b.Content),
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
			x, y := RequestBodyOrReferenceToHcl2(v.Value)
			if x != nil {
				if o.Responses == nil {
					o.Responses = make(map[string]*RequestBodyOrReference)
				}
				o.Responses[v.Name] = x
			}
			if y != nil {
				if o.Headers == nil {
					o.Headers = make(map[string]*RequestBodyOrReference)
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

func headerOrReferenceToHcl(header *openapiv3.HeaderOrReference) *SchemaOrReference {
	if header == nil {
		return nil
	}

	if x := header.GetReference(); x != nil {
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}

	return SchemaOrReferenceToHcl(header.GetHeader().GetSchema())
}

func headersOrReferenceToHcl(headers *openapiv3.HeadersOrReferences) *RequestBodyOrReference {
	if headers == nil {
		return nil
	}

	hs := make(map[string]*SchemaOrReference)
	for _, v := range headers.AdditionalProperties {
		hs[v.Name] = headerOrReferenceToHcl(v.Value)
	}

	return &RequestBodyOrReference{
		Oneof: &RequestBodyOrReference_RequestBody{
			RequestBody: &RequestBody{
				Content: hs,
			},
		},
	}
}

func requestBodyToHcl(content *openapiv3.MediaTypes) *RequestBody {
	if content == nil {
		return nil
	}

	c := make(map[string]*SchemaOrReference)
	for _, v := range content.AdditionalProperties {
		c[v.Name] = mediaTypeToHcl(v.Value)
	}

	return &RequestBody{
		Content: c,
	}
}

func mediaTypeToHcl(mt *openapiv3.MediaType) *SchemaOrReference {
	if mt == nil {
		return nil
	}

	return SchemaOrReferenceToHcl(mt.GetSchema())
}

func RequestBodyOrReferenceToHcl2(response *openapiv3.ResponseOrReference) (*RequestBodyOrReference, *RequestBodyOrReference) {
	if response == nil {
		return nil, nil
	}

	if x := response.GetReference(); x != nil {
		return &RequestBodyOrReference{
			Oneof: &RequestBodyOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}, nil
	}

	r := response.GetResponse()
	mt := requestBodyToHcl(r.Content)
	return &RequestBodyOrReference{
		Oneof: &RequestBodyOrReference_RequestBody{
			RequestBody: mt,
		},
	}, headersOrReferenceToHcl(r.Headers)
}
