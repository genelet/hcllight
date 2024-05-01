package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func extensionToApi(extention map[string]*Any) []*openapiv3.NamedAny {
	if extention == nil {
		return nil
	}
	var e []*openapiv3.NamedAny
	for k, v := range extention {
		e = append(e, &openapiv3.NamedAny{Name: k, Value: &openapiv3.Any{Value: v.Value}})
	}
	return e
}

func contactToApi(contact *Contact) *openapiv3.Contact {
	if contact == nil {
		return nil
	}
	return &openapiv3.Contact{
		Name:                   contact.Name,
		Url:                    contact.Url,
		Email:                  contact.Email,
		SpecificationExtension: extensionToApi(contact.SpecificationExtension),
	}
}

func licenseToApi(license *License) *openapiv3.License {
	if license == nil {
		return nil
	}
	return &openapiv3.License{
		Name:                   license.Name,
		Url:                    license.Url,
		SpecificationExtension: extensionToApi(license.SpecificationExtension),
	}
}

func InfoToApi(info *Info) *openapiv3.Info {
	if info == nil {
		return nil
	}
	return &openapiv3.Info{
		Title:                  info.Title,
		Version:                info.Version,
		Description:            info.Description,
		TermsOfService:         info.TermsOfService,
		Contact:                contactToApi(info.Contact),
		License:                licenseToApi(info.License),
		SpecificationExtension: extensionToApi(info.SpecificationExtension),
	}
}

func ExternalDocsToApi(externalDocs *ExternalDocs) *openapiv3.ExternalDocs {
	if externalDocs == nil {
		return nil
	}
	return &openapiv3.ExternalDocs{
		Description:            externalDocs.Description,
		Url:                    externalDocs.Url,
		SpecificationExtension: extensionToApi(externalDocs.SpecificationExtension),
	}
}

func TagToApi(tag *Tag) *openapiv3.Tag {
	if tag == nil {
		return nil
	}
	return &openapiv3.Tag{
		Name:                   tag.Name,
		Description:            tag.Description,
		ExternalDocs:           ExternalDocsToApi(tag.ExternalDocs),
		SpecificationExtension: extensionToApi(tag.SpecificationExtension),
	}
}

func serverVariableToApi(serverVariable *ServerVariable) *openapiv3.ServerVariable {
	if serverVariable == nil {
		return nil
	}
	return &openapiv3.ServerVariable{
		Enum:                   serverVariable.Enum,
		Default:                serverVariable.Default,
		Description:            serverVariable.Description,
		SpecificationExtension: extensionToApi(serverVariable.SpecificationExtension),
	}
}

func ServerToApi(server *Server) *openapiv3.Server {
	if server == nil {
		return nil
	}
	s := &openapiv3.Server{
		Url:                    server.Url,
		Description:            server.Description,
		SpecificationExtension: extensionToApi(server.SpecificationExtension),
	}
	if server.Variables != nil {
		s.Variables = &openapiv3.ServerVariables{}
		for k, v := range server.Variables {
			s.Variables.AdditionalProperties = append(s.Variables.AdditionalProperties,
				&openapiv3.NamedServerVariable{Name: k, Value: serverVariableToApi(v)},
			)
		}
	}
	return s
}

func stringArrayToApi(stringArray *StringArray) *openapiv3.StringArray {
	if stringArray == nil {
		return nil
	}
	return &openapiv3.StringArray{
		Value: stringArray.Value,
	}
}

func oAuthFlowToApi(oAuthFlow *OauthFlow) *openapiv3.OauthFlow {
	if oAuthFlow == nil {
		return nil
	}
	o := &openapiv3.OauthFlow{
		AuthorizationUrl:       oAuthFlow.AuthorizationUrl,
		TokenUrl:               oAuthFlow.TokenUrl,
		RefreshUrl:             oAuthFlow.RefreshUrl,
		SpecificationExtension: extensionToApi(oAuthFlow.SpecificationExtension),
	}
	if oAuthFlow.Scopes != nil {
		o.Scopes = &openapiv3.Strings{}
		for k, v := range oAuthFlow.Scopes {
			o.Scopes.AdditionalProperties = append(o.Scopes.AdditionalProperties,
				&openapiv3.NamedString{Name: k, Value: v},
			)
		}
	}
	return o
}

func OAuthFlowsToApi(oAuthFlows *OauthFlows) *openapiv3.OauthFlows {
	if oAuthFlows == nil {
		return nil
	}
	return &openapiv3.OauthFlows{
		Implicit:               oAuthFlowToApi(oAuthFlows.Implicit),
		Password:               oAuthFlowToApi(oAuthFlows.Password),
		ClientCredentials:      oAuthFlowToApi(oAuthFlows.ClientCredentials),
		AuthorizationCode:      oAuthFlowToApi(oAuthFlows.AuthorizationCode),
		SpecificationExtension: extensionToApi(oAuthFlows.SpecificationExtension),
	}
}

func SecurityRequirementToApi(securityRequirement *SecurityRequirement) *openapiv3.SecurityRequirement {
	if securityRequirement == nil {
		return nil
	}
	s := &openapiv3.SecurityRequirement{}
	if securityRequirement.AdditionalProperties != nil {
		for k, v := range securityRequirement.AdditionalProperties {
			s.AdditionalProperties = append(s.AdditionalProperties,
				&openapiv3.NamedStringArray{Name: k, Value: stringArrayToApi(v)},
			)
		}
	}
	return s
}

func ReferenceToApi(reference *Reference) *openapiv3.Reference {
	if reference == nil {
		return nil
	}
	return &openapiv3.Reference{
		XRef:        reference.XRef,
		Summary:     reference.Summary,
		Description: reference.Description,
	}
}

func SecuritySchemeOrReferenceToApi(securitySchemeOrReference *SecuritySchemeOrReference) *openapiv3.SecuritySchemeOrReference {
	if securitySchemeOrReference == nil {
		return nil
	}
	if x := securitySchemeOrReference.GetReference(); x != nil {
		return &openapiv3.SecuritySchemeOrReference{
			Oneof: &openapiv3.SecuritySchemeOrReference_Reference{
				Reference: ReferenceToApi(x),
			},
		}
	}

	s := securitySchemeOrReference.GetSecurityScheme()
	return &openapiv3.SecuritySchemeOrReference{
		Oneof: &openapiv3.SecuritySchemeOrReference_SecurityScheme{
			SecurityScheme: &openapiv3.SecurityScheme{
				Type:                   s.Type,
				Description:            s.Description,
				Name:                   s.Name,
				In:                     s.In,
				Scheme:                 s.Scheme,
				BearerFormat:           s.BearerFormat,
				Flows:                  OAuthFlowsToApi(s.Flows),
				OpenIdConnectUrl:       s.OpenIdConnectUrl,
				SpecificationExtension: extensionToApi(s.SpecificationExtension),
			},
		},
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

func anyOrReferenceToApi(anyOrReference *AnyOrExpression) *openapiv3.AnyOrExpression {
	if anyOrReference == nil {
		return nil
	}
	if x := anyOrReference.GetAny(); x != nil {
		return &openapiv3.AnyOrExpression{
			Oneof: &openapiv3.AnyOrExpression_Any{
				Any: &openapiv3.Any{Value: x.Value},
			},
		}
	}
	e := anyOrReference.GetExpression()
	return &openapiv3.AnyOrExpression{
		Oneof: &openapiv3.AnyOrExpression_Expression{
			Expression: &openapiv3.Expression{
				AdditionalProperties: extensionToApi(e),
			},
		},
	}
	/*
		expr := &openapiv3.Expression{}
		for k, v := range e {
			expr.AdditionalProperties = append(expr.AdditionalProperties, anyToApi(v))
		}
		return &openapiv3.AnyOrExpression{
			Oneof: &openapiv3.AnyOrExpression_Expression{
				Expression: expr,
			},
		}
	*/
}

func LinkOrReferenceToApi(linkOrReference *LinkOrReference) *openapiv3.LinkOrReference {
	if linkOrReference == nil {
		return nil
	}
	if x := linkOrReference.GetReference(); x != nil {
		return &openapiv3.LinkOrReference{
			Oneof: &openapiv3.LinkOrReference_Reference{
				Reference: ReferenceToApi(x),
			},
		}
	}

	l := linkOrReference.GetLink()
	return &openapiv3.LinkOrReference{
		Oneof: &openapiv3.LinkOrReference_Link{
			Link: &openapiv3.Link{
				OperationRef:           l.OperationRef,
				OperationId:            l.OperationId,
				Parameters:             anyOrReferenceToApi(l.Parameters),
				RequestBody:            anyOrReferenceToApi(l.RequestBody),
				Description:            l.Description,
				Server:                 ServerToApi(l.Server),
				SpecificationExtension: extensionToApi(l.SpecificationExtension),
			},
		},
	}
}

func ExampleOrReferenceToApi(exampleOrReference *ExampleOrReference) *openapiv3.ExampleOrReference {
	if exampleOrReference == nil {
		return nil
	}
	if x := exampleOrReference.GetReference(); x != nil {
		return &openapiv3.ExampleOrReference{
			Oneof: &openapiv3.ExampleOrReference_Reference{
				Reference: ReferenceToApi(x),
			},
		}
	}

	e := exampleOrReference.GetExample()
	return &openapiv3.ExampleOrReference{
		Oneof: &openapiv3.ExampleOrReference_Example{
			Example: &openapiv3.Example{
				Summary:                e.Summary,
				Description:            e.Description,
				Value:                  anyToApi(e.Value),
				ExternalValue:          e.ExternalValue,
				SpecificationExtension: extensionToApi(e.SpecificationExtension),
			},
		},
	}
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

	s := schemaOrReference.GetSchema()
	return &openapiv3.SchemaOrReference{
		Oneof: &openapiv3.SchemaOrReference_Schema{
			Schema: SchemaToApi(s),
		},
	}
}

func parameterToApi(parameter *Parameter) *openapiv3.Parameter {
	if parameter == nil {
		return nil
	}
	p := &openapiv3.Parameter{
		Name:                   parameter.Name,
		In:                     parameter.In,
		Description:            parameter.Description,
		Required:               parameter.Required,
		Deprecated:             parameter.Deprecated,
		AllowEmptyValue:        parameter.AllowEmptyValue,
		Style:                  parameter.Style,
		Explode:                parameter.Explode,
		AllowReserved:          parameter.AllowReserved,
		Schema:                 SchemaOrReferenceToApi(parameter.Schema),
		Example:                anyToApi(parameter.Example),
		SpecificationExtension: extensionToApi(parameter.SpecificationExtension),
	}
	if parameter.Examples != nil {
		p.Examples = &openapiv3.ExamplesOrReferences{}
		for k, v := range parameter.Examples {
			p.Examples.AdditionalProperties = append(p.Examples.AdditionalProperties,
				&openapiv3.NamedExampleOrReference{Name: k, Value: ExampleOrReferenceToApi(v)},
			)
		}
	}
	if parameter.Content != nil {
		p.Content = &openapiv3.MediaTypes{}
		for k, v := range parameter.Content {
			p.Content.AdditionalProperties = append(p.Content.AdditionalProperties,
				&openapiv3.NamedMediaType{Name: k, Value: mediaTypeToApi(v)},
			)
		}
	}
	return p
}

func ParameterOrReferenceToApi(parameterOrReference *ParameterOrReference) *openapiv3.ParameterOrReference {
	if parameterOrReference == nil {
		return nil
	}
	if x := parameterOrReference.GetReference(); x != nil {
		return &openapiv3.ParameterOrReference{
			Oneof: &openapiv3.ParameterOrReference_Reference{
				Reference: ReferenceToApi(x),
			},
		}
	}

	p := parameterOrReference.GetParameter()
	return &openapiv3.ParameterOrReference{
		Oneof: &openapiv3.ParameterOrReference_Parameter{
			Parameter: parameterToApi(p),
		},
	}
}

func encodingToApi(encoding *Encoding) *openapiv3.Encoding {
	if encoding == nil {
		return nil
	}
	e := &openapiv3.Encoding{
		ContentType:            encoding.ContentType,
		Style:                  encoding.Style,
		Explode:                encoding.Explode,
		AllowReserved:          encoding.AllowReserved,
		SpecificationExtension: extensionToApi(encoding.SpecificationExtension),
	}
	if encoding.Headers != nil {
		e.Headers = &openapiv3.HeadersOrReferences{}
		for k, v := range encoding.Headers {
			e.Headers.AdditionalProperties = append(e.Headers.AdditionalProperties,
				&openapiv3.NamedHeaderOrReference{Name: k, Value: HeaderOrReferenceToApi(v)},
			)
		}
	}
	return e
}

func mediaTypeToApi(mediaType *MediaType) *openapiv3.MediaType {
	if mediaType == nil {
		return nil
	}
	m := &openapiv3.MediaType{
		Schema:                 SchemaOrReferenceToApi(mediaType.Schema),
		Example:                anyToApi(mediaType.Example),
		SpecificationExtension: extensionToApi(mediaType.SpecificationExtension),
	}
	if mediaType.Examples != nil {
		m.Examples = &openapiv3.ExamplesOrReferences{}
		for k, v := range mediaType.Examples {
			m.Examples.AdditionalProperties = append(m.Examples.AdditionalProperties,
				&openapiv3.NamedExampleOrReference{Name: k, Value: ExampleOrReferenceToApi(v)},
			)
		}
	}
	if mediaType.Encoding != nil {
		m.Encoding = &openapiv3.Encodings{}
		for k, v := range mediaType.Encoding {
			m.Encoding.AdditionalProperties = append(m.Encoding.AdditionalProperties,
				&openapiv3.NamedEncoding{Name: k, Value: encodingToApi(v)},
			)
		}
	}
	return m
}

func HeaderOrReferenceToApi(headerOrReference *HeaderOrReference) *openapiv3.HeaderOrReference {
	if headerOrReference == nil {
		return nil
	}
	if x := headerOrReference.GetReference(); x != nil {
		return &openapiv3.HeaderOrReference{
			Oneof: &openapiv3.HeaderOrReference_Reference{
				Reference: ReferenceToApi(x),
			},
		}
	}

	h := headerOrReference.GetHeader()
	return &openapiv3.HeaderOrReference{
		Oneof: &openapiv3.HeaderOrReference_Header{
			Header: &openapiv3.Header{
				Description:            h.Description,
				Required:               h.Required,
				Deprecated:             h.Deprecated,
				AllowEmptyValue:        h.AllowEmptyValue,
				Style:                  h.Style,
				Explode:                h.Explode,
				AllowReserved:          h.AllowReserved,
				Schema:                 SchemaOrReferenceToApi(h.Schema),
				Example:                anyToApi(h.Example),
				Examples:               &openapiv3.ExamplesOrReferences{},
				Content:                &openapiv3.MediaTypes{},
				SpecificationExtension: extensionToApi(h.SpecificationExtension),
			},
		},
	}
}

func OperationToApi(operation *Operation) *openapiv3.Operation {
	if operation == nil {
		return nil
	}
	o := &openapiv3.Operation{
		Tags:                   operation.Tags,
		Summary:                operation.Summary,
		Description:            operation.Description,
		ExternalDocs:           ExternalDocsToApi(operation.ExternalDocs),
		OperationId:            operation.OperationId,
		Parameters:             []*openapiv3.ParameterOrReference{},
		RequestBody:            RequestBodyOrReferenceToApi(operation.RequestBody),
		Deprecated:             operation.Deprecated,
		Security:               []*openapiv3.SecurityRequirement{},
		Servers:                []*openapiv3.Server{},
		SpecificationExtension: extensionToApi(operation.SpecificationExtension),
	}
	if operation.Parameters != nil {
		for _, p := range operation.Parameters {
			o.Parameters = append(o.Parameters, ParameterOrReferenceToApi(p))
		}
	}
	if operation.Responses != nil {
		o.Responses = &openapiv3.Responses{}
		for k, v := range operation.Responses {
			o.Responses.ResponseOrReference = append(o.Responses.ResponseOrReference,
				&openapiv3.NamedResponseOrReference{Name: k, Value: ResponseOrReferenceToApi(v)},
			)
		}
	}
	if operation.Callbacks != nil {
		for k, v := range operation.Callbacks {
			o.Callbacks.AdditionalProperties = append(o.Callbacks.AdditionalProperties,
				&openapiv3.NamedCallbackOrReference{Name: k, Value: CallbackOrReferenceToApi(v)},
			)
		}
	}
	if operation.Security != nil {
		for _, s := range operation.Security {
			o.Security = append(o.Security, SecurityRequirementToApi(s))
		}
	}
	if operation.Servers != nil {
		for _, s := range operation.Servers {
			o.Servers = append(o.Servers, ServerToApi(s))
		}
	}
	return o
}

func CallbackOrReferenceToApi(callbackOrReference *CallbackOrReference) *openapiv3.CallbackOrReference {
	if callbackOrReference == nil {
		return nil
	}
	if x := callbackOrReference.GetReference(); x != nil {
		return &openapiv3.CallbackOrReference{
			Oneof: &openapiv3.CallbackOrReference_Reference{
				Reference: ReferenceToApi(x),
			},
		}
	}

	c := callbackOrReference.GetCallback()
	var cs []*openapiv3.NamedPathItem
	for k, v := range c.Path {
		cs = append(cs, &openapiv3.NamedPathItem{Name: k, Value: PathItemToApi(v)})
	}
	return &openapiv3.CallbackOrReference{
		Oneof: &openapiv3.CallbackOrReference_Callback{
			Callback: &openapiv3.Callback{
				Path: cs,
			},
		},
	}
}

func RequestBodyToApi(requestBody *RequestBody) *openapiv3.RequestBody {
	if requestBody == nil {
		return nil
	}
	r := &openapiv3.RequestBody{
		Description:            requestBody.Description,
		Content:                &openapiv3.MediaTypes{},
		Required:               requestBody.Required,
		SpecificationExtension: extensionToApi(requestBody.SpecificationExtension),
	}
	if requestBody.Content != nil {
		for k, v := range requestBody.Content {
			r.Content.AdditionalProperties = append(r.Content.AdditionalProperties,
				&openapiv3.NamedMediaType{Name: k, Value: mediaTypeToApi(v)},
			)
		}
	}
	return r
}

func RequestBodyOrReferenceToApi(requestBodyOrReference *RequestBodyOrReference) *openapiv3.RequestBodyOrReference {
	if requestBodyOrReference == nil {
		return nil
	}
	if x := requestBodyOrReference.GetReference(); x != nil {
		return &openapiv3.RequestBodyOrReference{
			Oneof: &openapiv3.RequestBodyOrReference_Reference{
				Reference: ReferenceToApi(x),
			},
		}
	}

	r := requestBodyOrReference.GetRequestBody()
	return &openapiv3.RequestBodyOrReference{
		Oneof: &openapiv3.RequestBodyOrReference_RequestBody{
			RequestBody: RequestBodyToApi(r),
		},
	}
}

func ResponseToApi(response *Response) *openapiv3.Response {
	if response == nil {
		return nil
	}
	r := &openapiv3.Response{
		Description:            response.Description,
		Headers:                &openapiv3.HeadersOrReferences{},
		Content:                &openapiv3.MediaTypes{},
		Links:                  &openapiv3.LinksOrReferences{},
		SpecificationExtension: extensionToApi(response.SpecificationExtension),
	}
	if response.Headers != nil {
		for k, v := range response.Headers {
			r.Headers.AdditionalProperties = append(r.Headers.AdditionalProperties,
				&openapiv3.NamedHeaderOrReference{Name: k, Value: HeaderOrReferenceToApi(v)},
			)
		}
	}
	if response.Content != nil {
		for k, v := range response.Content {
			r.Content.AdditionalProperties = append(r.Content.AdditionalProperties,
				&openapiv3.NamedMediaType{Name: k, Value: mediaTypeToApi(v)},
			)
		}
	}
	if response.Links != nil {
		for k, v := range response.Links {
			r.Links.AdditionalProperties = append(r.Links.AdditionalProperties,
				&openapiv3.NamedLinkOrReference{Name: k, Value: LinkOrReferenceToApi(v)},
			)
		}
	}
	return r
}

func ResponseOrReferenceToApi(responseOrReference *ResponseOrReference) *openapiv3.ResponseOrReference {
	if responseOrReference == nil {
		return nil
	}
	if x := responseOrReference.GetReference(); x != nil {
		return &openapiv3.ResponseOrReference{
			Oneof: &openapiv3.ResponseOrReference_Reference{
				Reference: ReferenceToApi(x),
			},
		}
	}

	r := responseOrReference.GetResponse()
	return &openapiv3.ResponseOrReference{
		Oneof: &openapiv3.ResponseOrReference_Response{
			Response: ResponseToApi(r),
		},
	}
}

func PathItemToApi(pathItem *PathItem) *openapiv3.PathItem {
	if pathItem == nil {
		return nil
	}
	p := &openapiv3.PathItem{
		XRef:                   pathItem.XRef,
		Summary:                pathItem.Summary,
		Description:            pathItem.Description,
		SpecificationExtension: extensionToApi(pathItem.SpecificationExtension),
		Get:                    OperationToApi(pathItem.Get),
		Put:                    OperationToApi(pathItem.Put),
		Post:                   OperationToApi(pathItem.Post),
		Delete:                 OperationToApi(pathItem.Delete),
		Options:                OperationToApi(pathItem.Options),
		Head:                   OperationToApi(pathItem.Head),
		Patch:                  OperationToApi(pathItem.Patch),
		Trace:                  OperationToApi(pathItem.Trace),
	}
	if pathItem.Servers != nil {
		p.Servers = []*openapiv3.Server{}
		for _, s := range pathItem.Servers {
			p.Servers = append(p.Servers, ServerToApi(s))
		}
	}
	if pathItem.Parameters != nil {
		p.Parameters = []*openapiv3.ParameterOrReference{}
		for _, v := range pathItem.Parameters {
			p.Parameters = append(p.Parameters, ParameterOrReferenceToApi(v))
		}
	}
	return p
}

func ComponentsToApi(components *Components) *openapiv3.Components {
	if components == nil {
		return nil
	}
	c := &openapiv3.Components{
		SpecificationExtension: extensionToApi(components.SpecificationExtension),
	}
	if components.Schemas != nil {
		for k, v := range components.Schemas {
			c.Schemas.AdditionalProperties = append(c.Schemas.AdditionalProperties,
				&openapiv3.NamedSchemaOrReference{Name: k, Value: SchemaOrReferenceToApi(v)},
			)
		}
	}
	if components.Responses != nil {
		for k, v := range components.Responses {
			c.Responses.AdditionalProperties = append(c.Responses.AdditionalProperties,
				&openapiv3.NamedResponseOrReference{Name: k, Value: ResponseOrReferenceToApi(v)},
			)
		}
	}
	if components.Parameters != nil {
		for k, v := range components.Parameters {
			c.Parameters.AdditionalProperties = append(c.Parameters.AdditionalProperties,
				&openapiv3.NamedParameterOrReference{Name: k, Value: ParameterOrReferenceToApi(v)},
			)
		}
	}
	if components.Examples != nil {
		for k, v := range components.Examples {
			c.Examples.AdditionalProperties = append(c.Examples.AdditionalProperties,
				&openapiv3.NamedExampleOrReference{Name: k, Value: ExampleOrReferenceToApi(v)},
			)
		}
	}
	if components.RequestBodies != nil {
		for k, v := range components.RequestBodies {
			c.RequestBodies.AdditionalProperties = append(c.RequestBodies.AdditionalProperties,
				&openapiv3.NamedRequestBodyOrReference{Name: k, Value: RequestBodyOrReferenceToApi(v)},
			)
		}
	}
	if components.Headers != nil {
		for k, v := range components.Headers {
			c.Headers.AdditionalProperties = append(c.Headers.AdditionalProperties,
				&openapiv3.NamedHeaderOrReference{Name: k, Value: HeaderOrReferenceToApi(v)},
			)
		}
	}
	return c
}

func DocumentToApi(document *Document) *openapiv3.Document {
	if document == nil {
		return nil
	}
	d := &openapiv3.Document{
		Openapi:                document.Openapi,
		Info:                   InfoToApi(document.Info),
		Servers:                []*openapiv3.Server{},
		Paths:                  &openapiv3.Paths{},
		Components:             ComponentsToApi(document.Components),
		Security:               []*openapiv3.SecurityRequirement{},
		Tags:                   []*openapiv3.Tag{},
		ExternalDocs:           ExternalDocsToApi(document.ExternalDocs),
		SpecificationExtension: extensionToApi(document.SpecificationExtension),
	}
	if document.Servers != nil {
		for _, s := range document.Servers {
			d.Servers = append(d.Servers, ServerToApi(s))
		}
	}
	if document.Paths != nil {
		for k, v := range document.Paths {
			d.Paths.Path = append(d.Paths.Path,
				&openapiv3.NamedPathItem{Name: k, Value: PathItemToApi(v)},
			)
		}
	}
	if document.Security != nil {
		for _, s := range document.Security {
			d.Security = append(d.Security, SecurityRequirementToApi(s))
		}
	}
	if document.Tags != nil {
		for _, t := range document.Tags {
			d.Tags = append(d.Tags, TagToApi(t))
		}
	}
	return d
}
