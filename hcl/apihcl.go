package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

// DocumentFromAPI converts an openapiv3.Document object to a Document object.
func DocumentFromAPI(doc *openapiv3.Document) *Document {
	d := &Document{
		Openapi:                doc.Openapi,
		Info:                   infoFromAPI(doc.Info),
		Components:             componentsFromAPI(doc.Components),
		ExternalDocs:           externalDocsFromAPI(doc.ExternalDocs),
		SpecificationExtension: extensionFromAPI(doc.SpecificationExtension),
	}
	for _, s := range doc.Servers {
		d.Servers = append(d.Servers, serverFromAPI(s))
	}
	if doc.Paths != nil {
		d.Paths = make(map[string]*PathItemOrReference)
		for _, v := range doc.Paths.Path {
			d.Paths[v.Name] = pathItemOrReferenceFromAPI(v.Value)
		}
	}

	for _, s := range doc.Security {
		d.Security = append(d.Security, securityRequirementFromAPI(s))
	}

	for _, t := range doc.Tags {
		d.Tags = append(d.Tags, tagFromAPI(t))
	}

	return d
}

// ToAPI converts the Document object to the openapiv3.Document object.
func (self *Document) ToAPI() *openapiv3.Document {
	d := &openapiv3.Document{
		Openapi:                self.Openapi,
		Info:                   infoToAPI(self.Info),
		Servers:                []*openapiv3.Server{},
		Paths:                  &openapiv3.Paths{},
		Components:             componentsToAPI(self.Components),
		Security:               []*openapiv3.SecurityRequirement{},
		Tags:                   []*openapiv3.Tag{},
		ExternalDocs:           externalDocsToAPI(self.ExternalDocs),
		SpecificationExtension: extensionToAPI(self.SpecificationExtension),
	}
	if self.Servers != nil {
		for _, s := range self.Servers {
			d.Servers = append(d.Servers, serverToAPI(s))
		}
	}
	if self.Paths != nil {
		for k, v := range self.Paths {
			d.Paths.Path = append(d.Paths.Path,
				&openapiv3.NamedPathItem{Name: k, Value: pathItemOrReferenceToAPI(v)},
			)
		}
	}
	if self.Security != nil {
		for _, s := range self.Security {
			d.Security = append(d.Security, securityRequirementToAPI(s))
		}
	}
	if self.Tags != nil {
		for _, t := range self.Tags {
			d.Tags = append(d.Tags, tagToAPI(t))
		}
	}
	return d
}

func componentsFromAPI(components *openapiv3.Components) *Components {
	c := &Components{
		SpecificationExtension: extensionFromAPI(components.SpecificationExtension),
	}
	if components.Callbacks != nil {
		c.Callbacks = make(map[string]*CallbackOrReference)
		for _, v := range components.Callbacks.AdditionalProperties {
			c.Callbacks[v.Name] = callbackOrReferenceFromAPI(v.Value)
		}
	}
	if components.Links != nil {
		c.Links = make(map[string]*LinkOrReference)
		for _, v := range components.Links.AdditionalProperties {
			c.Links[v.Name] = linkOrReferenceFromAPI(v.Value)
		}
	}
	if components.SecuritySchemes != nil {
		c.SecuritySchemes = make(map[string]*SecuritySchemeOrReference)
		for _, v := range components.SecuritySchemes.AdditionalProperties {
			c.SecuritySchemes[v.Name] = securityschemaOrReferenceFromAPI(v.Value)
		}
	}
	if components.Examples != nil {
		c.Examples = make(map[string]*ExampleOrReference)
		for _, v := range components.Examples.AdditionalProperties {
			c.Examples[v.Name] = exampleOrReferenceFromAPI(v.Value)
		}
	}
	if components.RequestBodies != nil {
		c.RequestBodies = make(map[string]*RequestBodyOrReference)
		for _, v := range components.RequestBodies.AdditionalProperties {
			c.RequestBodies[v.Name] = requestBodyOrReferenceFromAPI(v.Value)
		}
	}
	if components.Schemas != nil {
		c.Schemas = make(map[string]*SchemaOrReference)
		for _, v := range components.Schemas.AdditionalProperties {
			c.Schemas[v.Name] = schemaOrReferenceFromAPI(v.Value, true)
		}
	}
	if components.Parameters != nil {
		c.Parameters = make(map[string]*ParameterOrReference)
		for _, v := range components.Parameters.AdditionalProperties {
			c.Parameters[v.Name] = parameterOrReferenceFromAPI(v.Value)
		}
	}
	if components.Responses != nil {
		c.Responses = make(map[string]*ResponseOrReference)
		for _, v := range components.Responses.AdditionalProperties {
			c.Responses[v.Name] = responseOrReferenceFromAPI(v.Value)
		}
	}
	if components.Headers != nil {
		c.Headers = make(map[string]*HeaderOrReference)
		for _, v := range components.Headers.AdditionalProperties {
			c.Headers[v.Name] = headerOrReferenceFromAPI(v.Value)
		}
	}

	return c
}

func componentsToAPI(components *Components) *openapiv3.Components {
	if components == nil {
		return nil
	}
	c := &openapiv3.Components{
		SpecificationExtension: extensionToAPI(components.SpecificationExtension),
	}
	if components.Schemas != nil {
		c.Schemas = &openapiv3.SchemasOrReferences{}
		for k, v := range components.Schemas {
			c.Schemas.AdditionalProperties = append(c.Schemas.AdditionalProperties,
				&openapiv3.NamedSchemaOrReference{Name: k, Value: schemaOrReferenceToAPI(v)},
			)
		}
	}
	if components.Responses != nil {
		c.Responses = &openapiv3.ResponsesOrReferences{}
		for k, v := range components.Responses {
			c.Responses.AdditionalProperties = append(c.Responses.AdditionalProperties,
				&openapiv3.NamedResponseOrReference{Name: k, Value: responseOrReferenceToAPI(v)},
			)
		}
	}
	if components.Parameters != nil {
		c.Parameters = &openapiv3.ParametersOrReferences{}
		for k, v := range components.Parameters {
			c.Parameters.AdditionalProperties = append(c.Parameters.AdditionalProperties,
				&openapiv3.NamedParameterOrReference{Name: k, Value: parameterOrReferenceToAPI(v)},
			)
		}
	}
	if components.Examples != nil {
		c.Examples = &openapiv3.ExamplesOrReferences{}
		for k, v := range components.Examples {
			c.Examples.AdditionalProperties = append(c.Examples.AdditionalProperties,
				&openapiv3.NamedExampleOrReference{Name: k, Value: exampleOrReferenceToAPI(v)},
			)
		}
	}
	if components.RequestBodies != nil {
		c.RequestBodies = &openapiv3.RequestBodiesOrReferences{}
		for k, v := range components.RequestBodies {
			c.RequestBodies.AdditionalProperties = append(c.RequestBodies.AdditionalProperties,
				&openapiv3.NamedRequestBodyOrReference{Name: k, Value: requestBodyOrReferenceToAPI(v)},
			)
		}
	}
	if components.Headers != nil {
		c.Headers = &openapiv3.HeadersOrReferences{}
		for k, v := range components.Headers {
			c.Headers.AdditionalProperties = append(c.Headers.AdditionalProperties,
				&openapiv3.NamedHeaderOrReference{Name: k, Value: headerOrReferenceToAPI(v)},
			)
		}
	}
	if components.SecuritySchemes != nil {
		c.SecuritySchemes = &openapiv3.SecuritySchemesOrReferences{}
		for k, v := range components.SecuritySchemes {
			c.SecuritySchemes.AdditionalProperties = append(c.SecuritySchemes.AdditionalProperties,
				&openapiv3.NamedSecuritySchemeOrReference{Name: k, Value: securitySchemeOrReferenceToAPI(v)},
			)
		}
	}
	if components.Callbacks != nil {
		c.Callbacks = &openapiv3.CallbacksOrReferences{}
		for k, v := range components.Callbacks {
			c.Callbacks.AdditionalProperties = append(c.Callbacks.AdditionalProperties,
				&openapiv3.NamedCallbackOrReference{Name: k, Value: callbackOrReferenceToAPI(v)},
			)
		}
	}
	if components.Links != nil {
		c.Links = &openapiv3.LinksOrReferences{}
		for k, v := range components.Links {
			c.Links.AdditionalProperties = append(c.Links.AdditionalProperties,
				&openapiv3.NamedLinkOrReference{Name: k, Value: linkOrReferenceToAPI(v)},
			)
		}
	}

	return c
}

func referenceFromAPI(reference *openapiv3.Reference) *Reference {
	if reference == nil {
		return nil
	}
	return &Reference{
		XRef:        reference.XRef,
		Summary:     reference.Summary,
		Description: reference.Description,
	}
}

func referenceToAPI(reference *Reference) *openapiv3.Reference {
	if reference == nil {
		return nil
	}
	return &openapiv3.Reference{
		XRef:        reference.XRef,
		Summary:     reference.Summary,
		Description: reference.Description,
	}
}

func pathItemOrReferenceFromAPI(path *openapiv3.PathItem) *PathItemOrReference {
	if path == nil {
		return nil
	}
	if reference := path.XRef; reference != "" {
		return &PathItemOrReference{
			Oneof: &PathItemOrReference_Reference{
				Reference: referenceFromAPI(&openapiv3.Reference{
					XRef:        reference,
					Summary:     path.Summary,
					Description: path.Description,
				}),
			},
		}
	}

	p := &PathItem{
		Summary:                path.Summary,
		Description:            path.Description,
		Get:                    operationFromAPI(path.Get),
		Put:                    operationFromAPI(path.Put),
		Post:                   operationFromAPI(path.Post),
		Delete:                 operationFromAPI(path.Delete),
		Options:                operationFromAPI(path.Options),
		Head:                   operationFromAPI(path.Head),
		Patch:                  operationFromAPI(path.Patch),
		Trace:                  operationFromAPI(path.Trace),
		SpecificationExtension: extensionFromAPI(path.SpecificationExtension),
	}
	for _, s := range path.Servers {
		p.Servers = append(p.Servers, serverFromAPI(s))
	}
	for _, s := range path.Parameters {
		p.Parameters = append(p.Parameters, parameterOrReferenceFromAPI(s))
	}
	return &PathItemOrReference{
		Oneof: &PathItemOrReference_Item{
			Item: p,
		},
	}
}

func pathItemOrReferenceToAPI(item *PathItemOrReference) *openapiv3.PathItem {
	if item == nil {
		return nil
	}
	if x := item.GetReference(); x != nil {
		return &openapiv3.PathItem{
			XRef:        x.XRef,
			Summary:     x.Summary,
			Description: x.Description,
		}
	}

	pathItem := item.GetItem()
	p := &openapiv3.PathItem{
		Summary:                pathItem.Summary,
		Description:            pathItem.Description,
		SpecificationExtension: extensionToAPI(pathItem.SpecificationExtension),
		Get:                    operationToAPI(pathItem.Get),
		Put:                    operationToAPI(pathItem.Put),
		Post:                   operationToAPI(pathItem.Post),
		Delete:                 operationToAPI(pathItem.Delete),
		Options:                operationToAPI(pathItem.Options),
		Head:                   operationToAPI(pathItem.Head),
		Patch:                  operationToAPI(pathItem.Patch),
		Trace:                  operationToAPI(pathItem.Trace),
	}
	if pathItem.Servers != nil {
		p.Servers = []*openapiv3.Server{}
		for _, s := range pathItem.Servers {
			p.Servers = append(p.Servers, serverToAPI(s))
		}
	}
	if pathItem.Parameters != nil {
		p.Parameters = []*openapiv3.ParameterOrReference{}
		for _, v := range pathItem.Parameters {
			p.Parameters = append(p.Parameters, parameterOrReferenceToAPI(v))
		}
	}
	return p
}

func contactFromAPI(contact *openapiv3.Contact) *Contact {
	if contact == nil {
		return nil
	}
	return &Contact{
		Name:                   contact.Name,
		Url:                    contact.Url,
		Email:                  contact.Email,
		SpecificationExtension: extensionFromAPI(contact.SpecificationExtension),
	}
}

func contactToAPI(contact *Contact) *openapiv3.Contact {
	if contact == nil {
		return nil
	}
	return &openapiv3.Contact{
		Name:                   contact.Name,
		Url:                    contact.Url,
		Email:                  contact.Email,
		SpecificationExtension: extensionToAPI(contact.SpecificationExtension),
	}
}

func licenseFromAPI(license *openapiv3.License) *License {
	if license == nil {
		return nil
	}
	return &License{
		Name:                   license.Name,
		Url:                    license.Url,
		SpecificationExtension: extensionFromAPI(license.SpecificationExtension),
	}
}

func licenseToAPI(license *License) *openapiv3.License {
	if license == nil {
		return nil
	}
	return &openapiv3.License{
		Name:                   license.Name,
		Url:                    license.Url,
		SpecificationExtension: extensionToAPI(license.SpecificationExtension),
	}
}

func infoFromAPI(info *openapiv3.Info) *Info {
	if info == nil {
		return nil
	}
	return &Info{
		Title:                  info.Title,
		Description:            info.Description,
		TermsOfService:         info.TermsOfService,
		Version:                info.Version,
		Contact:                contactFromAPI(info.Contact),
		License:                licenseFromAPI(info.License),
		SpecificationExtension: extensionFromAPI(info.SpecificationExtension),
		Summary:                info.Summary,
	}
}

func infoToAPI(info *Info) *openapiv3.Info {
	if info == nil {
		return nil
	}
	return &openapiv3.Info{
		Title:                  info.Title,
		Version:                info.Version,
		Description:            info.Description,
		TermsOfService:         info.TermsOfService,
		Contact:                contactToAPI(info.Contact),
		License:                licenseToAPI(info.License),
		SpecificationExtension: extensionToAPI(info.SpecificationExtension),
	}
}

func tagFromAPI(tag *openapiv3.Tag) *Tag {
	if tag == nil {
		return nil
	}
	return &Tag{
		Name:                   tag.Name,
		Description:            tag.Description,
		ExternalDocs:           externalDocsFromAPI(tag.ExternalDocs),
		SpecificationExtension: extensionFromAPI(tag.SpecificationExtension),
	}
}

func tagToAPI(tag *Tag) *openapiv3.Tag {
	if tag == nil {
		return nil
	}
	return &openapiv3.Tag{
		Name:                   tag.Name,
		Description:            tag.Description,
		ExternalDocs:           externalDocsToAPI(tag.ExternalDocs),
		SpecificationExtension: extensionToAPI(tag.SpecificationExtension),
	}
}

func serverVariableFromAPI(variable *openapiv3.ServerVariable) *ServerVariable {
	if variable == nil {
		return nil
	}
	return &ServerVariable{
		Default:                variable.Default,
		Enum:                   variable.Enum,
		Description:            variable.Description,
		SpecificationExtension: extensionFromAPI(variable.SpecificationExtension),
	}
}

func serverVariableToAPI(serverVariable *ServerVariable) *openapiv3.ServerVariable {
	if serverVariable == nil {
		return nil
	}
	return &openapiv3.ServerVariable{
		Enum:                   serverVariable.Enum,
		Default:                serverVariable.Default,
		Description:            serverVariable.Description,
		SpecificationExtension: extensionToAPI(serverVariable.SpecificationExtension),
	}
}

func serverFromAPI(server *openapiv3.Server) *Server {
	if server == nil {
		return nil
	}
	s := &Server{
		Url:                    server.Url,
		Description:            server.Description,
		SpecificationExtension: extensionFromAPI(server.SpecificationExtension),
	}
	if server.Variables != nil {
		s.Variables = make(map[string]*ServerVariable)
		for _, v := range server.Variables.AdditionalProperties {
			s.Variables[v.Name] = serverVariableFromAPI(v.Value)
		}
	}
	return s
}

func serverToAPI(server *Server) *openapiv3.Server {
	if server == nil {
		return nil
	}
	s := &openapiv3.Server{
		Url:                    server.Url,
		Description:            server.Description,
		SpecificationExtension: extensionToAPI(server.SpecificationExtension),
	}
	if server.Variables != nil {
		s.Variables = &openapiv3.ServerVariables{}
		for k, v := range server.Variables {
			s.Variables.AdditionalProperties = append(s.Variables.AdditionalProperties,
				&openapiv3.NamedServerVariable{Name: k, Value: serverVariableToAPI(v)},
			)
		}
	}
	return s
}

func stringArrayFromAPI(array *openapiv3.StringArray) *StringArray {
	if array == nil {
		return nil
	}
	return &StringArray{
		Value: array.Value,
	}
}

func stringArrayToAPI(stringArray *StringArray) *openapiv3.StringArray {
	if stringArray == nil {
		return nil
	}
	return &openapiv3.StringArray{
		Value: stringArray.Value,
	}
}

func oAuthFlowFromAPI(flow *openapiv3.OauthFlow) *OauthFlow {
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
		SpecificationExtension: extensionFromAPI(flow.SpecificationExtension),
	}
}

func oAuthFlowToAPI(oAuthFlow *OauthFlow) *openapiv3.OauthFlow {
	if oAuthFlow == nil {
		return nil
	}
	o := &openapiv3.OauthFlow{
		AuthorizationUrl:       oAuthFlow.AuthorizationUrl,
		TokenUrl:               oAuthFlow.TokenUrl,
		RefreshUrl:             oAuthFlow.RefreshUrl,
		SpecificationExtension: extensionToAPI(oAuthFlow.SpecificationExtension),
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

func oAuthFlowsFromAPI(flows *openapiv3.OauthFlows) *OauthFlows {
	if flows == nil {
		return nil
	}
	return &OauthFlows{
		Implicit:               oAuthFlowFromAPI(flows.Implicit),
		Password:               oAuthFlowFromAPI(flows.Password),
		ClientCredentials:      oAuthFlowFromAPI(flows.ClientCredentials),
		AuthorizationCode:      oAuthFlowFromAPI(flows.AuthorizationCode),
		SpecificationExtension: extensionFromAPI(flows.SpecificationExtension),
	}
}

func oAuthFlowsToAPI(oAuthFlows *OauthFlows) *openapiv3.OauthFlows {
	if oAuthFlows == nil {
		return nil
	}
	return &openapiv3.OauthFlows{
		Implicit:               oAuthFlowToAPI(oAuthFlows.Implicit),
		Password:               oAuthFlowToAPI(oAuthFlows.Password),
		ClientCredentials:      oAuthFlowToAPI(oAuthFlows.ClientCredentials),
		AuthorizationCode:      oAuthFlowToAPI(oAuthFlows.AuthorizationCode),
		SpecificationExtension: extensionToAPI(oAuthFlows.SpecificationExtension),
	}
}

func securityRequirementFromAPI(requirement *openapiv3.SecurityRequirement) *SecurityRequirement {
	if requirement == nil {
		return nil
	}
	s := make(map[string]*StringArray)
	for _, v := range requirement.AdditionalProperties {
		s[v.Name] = stringArrayFromAPI(v.Value)
	}
	return &SecurityRequirement{
		AdditionalProperties: s,
	}
}

func securityRequirementToAPI(securityRequirement *SecurityRequirement) *openapiv3.SecurityRequirement {
	if securityRequirement == nil {
		return nil
	}
	s := &openapiv3.SecurityRequirement{}
	if securityRequirement.AdditionalProperties != nil {
		for k, v := range securityRequirement.AdditionalProperties {
			s.AdditionalProperties = append(s.AdditionalProperties,
				&openapiv3.NamedStringArray{Name: k, Value: stringArrayToAPI(v)},
			)
		}
	}
	return s
}

func securityschemaOrReferenceFromAPI(security *openapiv3.SecuritySchemeOrReference) *SecuritySchemeOrReference {
	if security == nil {
		return nil
	}
	if x := security.GetReference(); x != nil {
		return &SecuritySchemeOrReference{
			Oneof: &SecuritySchemeOrReference_Reference{
				Reference: referenceFromAPI(x),
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
				Flows:                  oAuthFlowsFromAPI(s.Flows),
				OpenIdConnectUrl:       s.OpenIdConnectUrl,
				SpecificationExtension: extensionFromAPI(s.SpecificationExtension),
			},
		},
	}
}

func securitySchemeOrReferenceToAPI(securitySchemeOrReference *SecuritySchemeOrReference) *openapiv3.SecuritySchemeOrReference {
	if securitySchemeOrReference == nil {
		return nil
	}
	if x := securitySchemeOrReference.GetReference(); x != nil {
		return &openapiv3.SecuritySchemeOrReference{
			Oneof: &openapiv3.SecuritySchemeOrReference_Reference{
				Reference: referenceToAPI(x),
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
				Flows:                  oAuthFlowsToAPI(s.Flows),
				OpenIdConnectUrl:       s.OpenIdConnectUrl,
				SpecificationExtension: extensionToAPI(s.SpecificationExtension),
			},
		},
	}
}

func expressionFromAPI(expression *openapiv3.Expression) *Expression {
	if expression == nil {
		return nil
	}
	expr := make(map[string]*Any)
	for _, v := range expression.AdditionalProperties {
		expr[v.Name] = anyFromAPI(v.Value)
	}
	return &Expression{
		AdditionalProperties: expr,
	}
}

func expressionToAPI(expression *Expression) *openapiv3.Expression {
	if expression == nil {
		return nil
	}
	var ap []*openapiv3.NamedAny
	for k, v := range expression.AdditionalProperties {
		ap = append(ap, &openapiv3.NamedAny{Name: k, Value: &openapiv3.Any{Value: v.Value}})
	}
	return &openapiv3.Expression{
		AdditionalProperties: ap,
	}
}

func anyOrReferenceFromAPI(any *openapiv3.AnyOrExpression) *AnyOrExpression {
	if any == nil {
		return nil
	}
	if x := any.GetAny(); x != nil {
		return &AnyOrExpression{
			Oneof: &AnyOrExpression_Any{
				Any: anyFromAPI(x),
			},
		}
	}
	expr := any.GetExpression()
	return &AnyOrExpression{
		Oneof: &AnyOrExpression_Expression{
			Expression: expressionFromAPI(expr),
		},
	}
}

func anyOrReferenceToAPI(anyOrReference *AnyOrExpression) *openapiv3.AnyOrExpression {
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
			Expression: expressionToAPI(e),
		},
	}
}

func linkOrReferenceFromAPI(link *openapiv3.LinkOrReference) *LinkOrReference {
	if link == nil {
		return nil
	}
	if x := link.GetReference(); x != nil {
		return &LinkOrReference{
			Oneof: &LinkOrReference_Reference{
				Reference: referenceFromAPI(x),
			},
		}
	}

	l := link.GetLink()
	return &LinkOrReference{
		Oneof: &LinkOrReference_Link{
			Link: &Link{
				OperationRef:           l.OperationRef,
				OperationId:            l.OperationId,
				Parameters:             anyOrReferenceFromAPI(l.Parameters),
				RequestBody:            anyOrReferenceFromAPI(l.RequestBody),
				Description:            l.Description,
				Server:                 serverFromAPI(l.Server),
				SpecificationExtension: extensionFromAPI(l.SpecificationExtension),
			},
		},
	}
}

func linkOrReferenceToAPI(linkOrReference *LinkOrReference) *openapiv3.LinkOrReference {
	if linkOrReference == nil {
		return nil
	}
	if x := linkOrReference.GetReference(); x != nil {
		return &openapiv3.LinkOrReference{
			Oneof: &openapiv3.LinkOrReference_Reference{
				Reference: referenceToAPI(x),
			},
		}
	}

	l := linkOrReference.GetLink()
	return &openapiv3.LinkOrReference{
		Oneof: &openapiv3.LinkOrReference_Link{
			Link: &openapiv3.Link{
				OperationRef:           l.OperationRef,
				OperationId:            l.OperationId,
				Parameters:             anyOrReferenceToAPI(l.Parameters),
				RequestBody:            anyOrReferenceToAPI(l.RequestBody),
				Description:            l.Description,
				Server:                 serverToAPI(l.Server),
				SpecificationExtension: extensionToAPI(l.SpecificationExtension),
			},
		},
	}
}

func exampleFromAPI(example *openapiv3.Example) *Example {
	if example == nil {
		return nil
	}
	return &Example{
		Summary:                example.Summary,
		Description:            example.Description,
		Value:                  anyFromAPI(example.Value),
		SpecificationExtension: extensionFromAPI(example.SpecificationExtension),
	}
}

func exampleToAPI(e *Example) *openapiv3.Example {
	return &openapiv3.Example{
		Summary:                e.Summary,
		Description:            e.Description,
		Value:                  anyToAPI(e.Value),
		ExternalValue:          e.ExternalValue,
		SpecificationExtension: extensionToAPI(e.SpecificationExtension),
	}
}

func exampleOrReferenceFromAPI(example *openapiv3.ExampleOrReference) *ExampleOrReference {
	if example == nil {
		return nil
	}
	if x := example.GetReference(); x != nil {
		return &ExampleOrReference{
			Oneof: &ExampleOrReference_Reference{
				Reference: referenceFromAPI(x),
			},
		}
	}

	e := example.GetExample()
	return &ExampleOrReference{
		Oneof: &ExampleOrReference_Example{
			Example: exampleFromAPI(e),
		},
	}
}

func exampleOrReferenceToAPI(exampleOrReference *ExampleOrReference) *openapiv3.ExampleOrReference {
	if exampleOrReference == nil {
		return nil
	}
	if x := exampleOrReference.GetReference(); x != nil {
		return &openapiv3.ExampleOrReference{
			Oneof: &openapiv3.ExampleOrReference_Reference{
				Reference: referenceToAPI(x),
			},
		}
	}

	e := exampleOrReference.GetExample()
	return &openapiv3.ExampleOrReference{
		Oneof: &openapiv3.ExampleOrReference_Example{
			Example: exampleToAPI(e),
		},
	}
}

func parameterFromAPI(parameter *openapiv3.Parameter) *Parameter {
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
		Schema:                 schemaOrReferenceFromAPI(parameter.Schema),
		Example:                anyFromAPI(parameter.Example),
		SpecificationExtension: extensionFromAPI(parameter.SpecificationExtension),
	}
	if parameter.Content != nil {
		p.Content = make(map[string]*MediaType)
		for _, v := range parameter.Content.AdditionalProperties {
			p.Content[v.Name] = mediaTypeFromAPI(v.Value)
		}
	}
	if parameter.Examples != nil {
		p.Examples = make(map[string]*ExampleOrReference)
		for _, v := range parameter.Examples.AdditionalProperties {
			p.Examples[v.Name] = exampleOrReferenceFromAPI(v.Value)
		}
	}
	return p
}

func parameterToAPI(parameter *Parameter) *openapiv3.Parameter {
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
		Schema:                 schemaOrReferenceToAPI(parameter.Schema),
		Example:                anyToAPI(parameter.Example),
		SpecificationExtension: extensionToAPI(parameter.SpecificationExtension),
	}
	if parameter.Examples != nil {
		p.Examples = &openapiv3.ExamplesOrReferences{}
		for k, v := range parameter.Examples {
			p.Examples.AdditionalProperties = append(p.Examples.AdditionalProperties,
				&openapiv3.NamedExampleOrReference{Name: k, Value: exampleOrReferenceToAPI(v)},
			)
		}
	}
	if parameter.Content != nil {
		p.Content = &openapiv3.MediaTypes{}
		for k, v := range parameter.Content {
			p.Content.AdditionalProperties = append(p.Content.AdditionalProperties,
				&openapiv3.NamedMediaType{Name: k, Value: mediaTypeToAPI(v)},
			)
		}
	}
	return p
}

func parameterOrReferenceFromAPI(parameter *openapiv3.ParameterOrReference) *ParameterOrReference {
	if parameter == nil {
		return nil
	}
	if x := parameter.GetReference(); x != nil {
		return &ParameterOrReference{
			Oneof: &ParameterOrReference_Reference{
				Reference: referenceFromAPI(x),
			},
		}
	}

	p := parameter.GetParameter()
	return &ParameterOrReference{
		Oneof: &ParameterOrReference_Parameter{
			Parameter: parameterFromAPI(p),
		},
	}
}

func parameterOrReferenceToAPI(parameterOrReference *ParameterOrReference) *openapiv3.ParameterOrReference {
	if parameterOrReference == nil {
		return nil
	}
	if x := parameterOrReference.GetReference(); x != nil {
		return &openapiv3.ParameterOrReference{
			Oneof: &openapiv3.ParameterOrReference_Reference{
				Reference: referenceToAPI(x),
			},
		}
	}

	p := parameterOrReference.GetParameter()
	return &openapiv3.ParameterOrReference{
		Oneof: &openapiv3.ParameterOrReference_Parameter{
			Parameter: parameterToAPI(p),
		},
	}
}

func requestBodyFromAPI(body *openapiv3.RequestBody) *RequestBody {
	if body == nil {
		return nil
	}
	r := &RequestBody{
		Description:            body.Description,
		Required:               body.Required,
		SpecificationExtension: extensionFromAPI(body.SpecificationExtension),
	}
	if body.Content != nil {
		r.Content = make(map[string]*MediaType)
		for _, v := range body.Content.AdditionalProperties {
			r.Content[v.Name] = mediaTypeFromAPI(v.Value)
		}
	}
	return r
}

func requestBodyToAPI(requestBody *RequestBody) *openapiv3.RequestBody {
	if requestBody == nil {
		return nil
	}
	r := &openapiv3.RequestBody{
		Description:            requestBody.Description,
		Content:                &openapiv3.MediaTypes{},
		Required:               requestBody.Required,
		SpecificationExtension: extensionToAPI(requestBody.SpecificationExtension),
	}
	if requestBody.Content != nil {
		for k, v := range requestBody.Content {
			r.Content.AdditionalProperties = append(r.Content.AdditionalProperties,
				&openapiv3.NamedMediaType{Name: k, Value: mediaTypeToAPI(v)},
			)
		}
	}
	return r
}

func requestBodyOrReferenceFromAPI(body *openapiv3.RequestBodyOrReference) *RequestBodyOrReference {
	if body == nil {
		return nil
	}

	if x := body.GetReference(); x != nil {
		return &RequestBodyOrReference{
			Oneof: &RequestBodyOrReference_Reference{
				Reference: referenceFromAPI(x),
			},
		}
	}

	b := body.GetRequestBody()
	return &RequestBodyOrReference{
		Oneof: &RequestBodyOrReference_RequestBody{
			RequestBody: requestBodyFromAPI(b),
		},
	}
}

func requestBodyOrReferenceToAPI(requestBodyOrReference *RequestBodyOrReference) *openapiv3.RequestBodyOrReference {
	if requestBodyOrReference == nil {
		return nil
	}
	if x := requestBodyOrReference.GetReference(); x != nil {
		return &openapiv3.RequestBodyOrReference{
			Oneof: &openapiv3.RequestBodyOrReference_Reference{
				Reference: referenceToAPI(x),
			},
		}
	}

	r := requestBodyOrReference.GetRequestBody()
	return &openapiv3.RequestBodyOrReference{
		Oneof: &openapiv3.RequestBodyOrReference_RequestBody{
			RequestBody: requestBodyToAPI(r),
		},
	}
}

func responseFromAPI(response *openapiv3.Response) *Response {
	if response == nil {
		return nil
	}
	r := &Response{
		Description:            response.Description,
		SpecificationExtension: extensionFromAPI(response.SpecificationExtension),
	}
	if response.Headers != nil {
		r.Headers = make(map[string]*HeaderOrReference)
		for _, s := range response.Headers.AdditionalProperties {
			r.Headers[s.Name] = headerOrReferenceFromAPI(s.Value)
		}
	}
	if response.Content != nil {
		r.Content = make(map[string]*MediaType)
		for _, s := range response.Content.AdditionalProperties {
			r.Content[s.Name] = mediaTypeFromAPI(s.Value)
		}
	}
	if response.Links != nil {
		r.Links = make(map[string]*LinkOrReference)
		for _, s := range response.Links.AdditionalProperties {
			r.Links[s.Name] = linkOrReferenceFromAPI(s.Value)
		}
	}

	return r
}

func responseToAPI(response *Response) *openapiv3.Response {
	if response == nil {
		return nil
	}
	r := &openapiv3.Response{
		Description:            response.Description,
		Headers:                &openapiv3.HeadersOrReferences{},
		Content:                &openapiv3.MediaTypes{},
		Links:                  &openapiv3.LinksOrReferences{},
		SpecificationExtension: extensionToAPI(response.SpecificationExtension),
	}
	if response.Headers != nil {
		for k, v := range response.Headers {
			r.Headers.AdditionalProperties = append(r.Headers.AdditionalProperties,
				&openapiv3.NamedHeaderOrReference{Name: k, Value: headerOrReferenceToAPI(v)},
			)
		}
	}
	if response.Content != nil {
		for k, v := range response.Content {
			r.Content.AdditionalProperties = append(r.Content.AdditionalProperties,
				&openapiv3.NamedMediaType{Name: k, Value: mediaTypeToAPI(v)},
			)
		}
	}
	if response.Links != nil {
		for k, v := range response.Links {
			r.Links.AdditionalProperties = append(r.Links.AdditionalProperties,
				&openapiv3.NamedLinkOrReference{Name: k, Value: linkOrReferenceToAPI(v)},
			)
		}
	}
	return r
}

func responseOrReferenceFromAPI(response *openapiv3.ResponseOrReference) *ResponseOrReference {
	if response == nil {
		return nil
	}

	if x := response.GetReference(); x != nil {
		return &ResponseOrReference{
			Oneof: &ResponseOrReference_Reference{
				Reference: referenceFromAPI(x),
			},
		}
	}

	r := response.GetResponse()
	return &ResponseOrReference{
		Oneof: &ResponseOrReference_Response{
			Response: responseFromAPI(r),
		},
	}
}

func responseOrReferenceToAPI(responseOrReference *ResponseOrReference) *openapiv3.ResponseOrReference {
	if responseOrReference == nil {
		return nil
	}
	if x := responseOrReference.GetReference(); x != nil {
		return &openapiv3.ResponseOrReference{
			Oneof: &openapiv3.ResponseOrReference_Reference{
				Reference: referenceToAPI(x),
			},
		}
	}

	r := responseOrReference.GetResponse()
	return &openapiv3.ResponseOrReference{
		Oneof: &openapiv3.ResponseOrReference_Response{
			Response: responseToAPI(r),
		},
	}
}

func operationFromAPI(operation *openapiv3.Operation) *Operation {
	if operation == nil {
		return nil
	}

	o := &Operation{
		Tags:                   operation.Tags,
		Summary:                operation.Summary,
		Description:            operation.Description,
		ExternalDocs:           externalDocsFromAPI(operation.ExternalDocs),
		OperationId:            operation.OperationId,
		RequestBody:            requestBodyOrReferenceFromAPI(operation.RequestBody),
		Deprecated:             operation.Deprecated,
		SpecificationExtension: extensionFromAPI(operation.SpecificationExtension),
	}

	for _, s := range operation.Security {
		o.Security = append(o.Security, securityRequirementFromAPI(s))
	}
	for _, s := range operation.Servers {
		o.Servers = append(o.Servers, serverFromAPI(s))
	}
	for _, s := range operation.Parameters {
		o.Parameters = append(o.Parameters, parameterOrReferenceFromAPI(s))
	}
	if operation.Callbacks != nil {
		o.Callbacks = make(map[string]*CallbackOrReference)
		for _, v := range operation.Callbacks.AdditionalProperties {
			o.Callbacks[v.Name] = callbackOrReferenceFromAPI(v.Value)
		}
	}
	if operation.Responses != nil {
		if operation.Responses.Default != nil {
			operation.Responses.ResponseOrReference = append(operation.Responses.ResponseOrReference, &openapiv3.NamedResponseOrReference{
				Name:  "default",
				Value: operation.Responses.Default,
			})
		}
		o.Responses = make(map[string]*ResponseOrReference)
		for _, v := range operation.Responses.ResponseOrReference {
			o.Responses[v.Name] = responseOrReferenceFromAPI(v.Value)
		}
	}

	return o
}

func operationToAPI(operation *Operation) *openapiv3.Operation {
	if operation == nil {
		return nil
	}
	o := &openapiv3.Operation{
		Tags:                   operation.Tags,
		Summary:                operation.Summary,
		Description:            operation.Description,
		ExternalDocs:           externalDocsToAPI(operation.ExternalDocs),
		OperationId:            operation.OperationId,
		Parameters:             []*openapiv3.ParameterOrReference{},
		RequestBody:            requestBodyOrReferenceToAPI(operation.RequestBody),
		Deprecated:             operation.Deprecated,
		Security:               []*openapiv3.SecurityRequirement{},
		Servers:                []*openapiv3.Server{},
		SpecificationExtension: extensionToAPI(operation.SpecificationExtension),
	}
	if operation.Parameters != nil {
		for _, p := range operation.Parameters {
			o.Parameters = append(o.Parameters, parameterOrReferenceToAPI(p))
		}
	}
	if operation.Responses != nil {
		o.Responses = &openapiv3.Responses{}
		for k, v := range operation.Responses {
			o.Responses.ResponseOrReference = append(o.Responses.ResponseOrReference,
				&openapiv3.NamedResponseOrReference{Name: k, Value: responseOrReferenceToAPI(v)},
			)
		}
	}
	if operation.Callbacks != nil {
		for k, v := range operation.Callbacks {
			o.Callbacks.AdditionalProperties = append(o.Callbacks.AdditionalProperties,
				&openapiv3.NamedCallbackOrReference{Name: k, Value: callbackOrReferenceToAPI(v)},
			)
		}
	}
	if operation.Security != nil {
		for _, s := range operation.Security {
			o.Security = append(o.Security, securityRequirementToAPI(s))
		}
	}
	if operation.Servers != nil {
		for _, s := range operation.Servers {
			o.Servers = append(o.Servers, serverToAPI(s))
		}
	}
	return o
}

func callbackOrReferenceFromAPI(callback *openapiv3.CallbackOrReference) *CallbackOrReference {
	if callback == nil {
		return nil
	}

	if x := callback.GetReference(); x != nil {
		return &CallbackOrReference{
			Oneof: &CallbackOrReference_Reference{
				Reference: referenceFromAPI(x),
			},
		}
	}

	call := callback.GetCallback()
	if call == nil {
		return nil
	}
	cs := make(map[string]*PathItemOrReference)
	for _, v := range call.Path {
		cs[v.Name] = pathItemOrReferenceFromAPI(v.Value)
	}

	return &CallbackOrReference{
		Oneof: &CallbackOrReference_Callback{
			Callback: &Callback{
				Path: cs,
			},
		},
	}
}

func callbackOrReferenceToAPI(callbackOrReference *CallbackOrReference) *openapiv3.CallbackOrReference {
	if callbackOrReference == nil {
		return nil
	}
	if x := callbackOrReference.GetReference(); x != nil {
		return &openapiv3.CallbackOrReference{
			Oneof: &openapiv3.CallbackOrReference_Reference{
				Reference: referenceToAPI(x),
			},
		}
	}

	c := callbackOrReference.GetCallback()
	var cs []*openapiv3.NamedPathItem
	for k, v := range c.Path {
		cs = append(cs, &openapiv3.NamedPathItem{Name: k, Value: pathItemOrReferenceToAPI(v)})
	}
	return &openapiv3.CallbackOrReference{
		Oneof: &openapiv3.CallbackOrReference_Callback{
			Callback: &openapiv3.Callback{
				Path: cs,
			},
		},
	}
}

func headerFromAPI(header *openapiv3.Header) *Header {
	if header == nil {
		return nil
	}
	h := &Header{
		Description:            header.Description,
		Required:               header.Required,
		Deprecated:             header.Deprecated,
		AllowEmptyValue:        header.AllowEmptyValue,
		Style:                  header.Style,
		Explode:                header.Explode,
		AllowReserved:          header.AllowReserved,
		Example:                anyFromAPI(header.Example),
		Schema:                 schemaOrReferenceFromAPI(header.Schema),
		SpecificationExtension: extensionFromAPI(header.SpecificationExtension),
	}
	if header.Examples != nil {
		h.Examples = make(map[string]*ExampleOrReference)
		for _, v := range header.Examples.AdditionalProperties {
			h.Examples[v.Name] = exampleOrReferenceFromAPI(v.Value)
		}
	}
	if header.Content != nil {
		h.Content = make(map[string]*MediaType)
		for _, v := range header.Content.AdditionalProperties {
			h.Content[v.Name] = mediaTypeFromAPI(v.Value)
		}
	}
	return h
}

func headerToAPI(header *Header) *openapiv3.Header {
	if header == nil {
		return nil
	}
	h := &openapiv3.Header{
		Description:            header.Description,
		Required:               header.Required,
		Deprecated:             header.Deprecated,
		AllowEmptyValue:        header.AllowEmptyValue,
		Style:                  header.Style,
		Explode:                header.Explode,
		AllowReserved:          header.AllowReserved,
		Example:                anyToAPI(header.Example),
		Schema:                 schemaOrReferenceToAPI(header.Schema),
		SpecificationExtension: extensionToAPI(header.SpecificationExtension),
	}
	if header.Examples != nil {
		h.Examples = &openapiv3.ExamplesOrReferences{}
		for k, v := range header.Examples {
			h.Examples.AdditionalProperties = append(h.Examples.AdditionalProperties,
				&openapiv3.NamedExampleOrReference{Name: k, Value: exampleOrReferenceToAPI(v)},
			)
		}
	}
	if header.Content != nil {
		h.Content = &openapiv3.MediaTypes{}
		for k, v := range header.Content {
			h.Content.AdditionalProperties = append(h.Content.AdditionalProperties,
				&openapiv3.NamedMediaType{Name: k, Value: mediaTypeToAPI(v)},
			)
		}
	}
	return h
}

func headerOrReferenceFromAPI(header *openapiv3.HeaderOrReference) *HeaderOrReference {
	if header == nil {
		return nil
	}

	if x := header.GetReference(); x != nil {
		return &HeaderOrReference{
			Oneof: &HeaderOrReference_Reference{
				Reference: referenceFromAPI(x),
			},
		}
	}

	x := header.GetHeader()
	return &HeaderOrReference{
		Oneof: &HeaderOrReference_Header{
			Header: headerFromAPI(x),
		},
	}
}

func headerOrReferenceToAPI(headerOrReference *HeaderOrReference) *openapiv3.HeaderOrReference {
	if headerOrReference == nil {
		return nil
	}
	if x := headerOrReference.GetReference(); x != nil {
		return &openapiv3.HeaderOrReference{
			Oneof: &openapiv3.HeaderOrReference_Reference{
				Reference: referenceToAPI(x),
			},
		}
	}

	h := headerOrReference.GetHeader()
	return &openapiv3.HeaderOrReference{
		Oneof: &openapiv3.HeaderOrReference_Header{
			Header: headerToAPI(h),
		},
	}
}

func mediaTypeFromAPI(mt *openapiv3.MediaType) *MediaType {
	if mt == nil {
		return nil
	}

	m := &MediaType{
		Schema:                 schemaOrReferenceFromAPI(mt.Schema),
		Example:                anyFromAPI(mt.Example),
		SpecificationExtension: extensionFromAPI(mt.SpecificationExtension),
	}
	if mt.Examples != nil {
		m.Examples = make(map[string]*ExampleOrReference)
		for _, v := range mt.Examples.AdditionalProperties {
			m.Examples[v.Name] = exampleOrReferenceFromAPI(v.Value)
		}
	}
	if mt.Encoding != nil {
		m.Encoding = make(map[string]*Encoding)
		for _, v := range mt.Encoding.AdditionalProperties {
			m.Encoding[v.Name] = encodingFromAPI(v.Value)
		}
	}
	return m
}

func mediaTypeToAPI(mediaType *MediaType) *openapiv3.MediaType {
	if mediaType == nil {
		return nil
	}
	m := &openapiv3.MediaType{
		Schema:                 schemaOrReferenceToAPI(mediaType.Schema),
		Example:                anyToAPI(mediaType.Example),
		SpecificationExtension: extensionToAPI(mediaType.SpecificationExtension),
	}
	if mediaType.Examples != nil {
		m.Examples = &openapiv3.ExamplesOrReferences{}
		for k, v := range mediaType.Examples {
			m.Examples.AdditionalProperties = append(m.Examples.AdditionalProperties,
				&openapiv3.NamedExampleOrReference{Name: k, Value: exampleOrReferenceToAPI(v)},
			)
		}
	}
	if mediaType.Encoding != nil {
		m.Encoding = &openapiv3.Encodings{}
		for k, v := range mediaType.Encoding {
			m.Encoding.AdditionalProperties = append(m.Encoding.AdditionalProperties,
				&openapiv3.NamedEncoding{Name: k, Value: encodingToAPI(v)},
			)
		}
	}
	return m
}

func encodingFromAPI(encoding *openapiv3.Encoding) *Encoding {
	if encoding == nil {
		return nil
	}

	e := &Encoding{
		ContentType:            encoding.ContentType,
		Style:                  encoding.Style,
		Explode:                encoding.Explode,
		AllowReserved:          encoding.AllowReserved,
		SpecificationExtension: extensionFromAPI(encoding.SpecificationExtension),
	}
	if encoding.Headers != nil {
		e.Headers = make(map[string]*HeaderOrReference)
		for _, v := range encoding.Headers.AdditionalProperties {
			e.Headers[v.Name] = headerOrReferenceFromAPI(v.Value)
		}
	}
	return e
}

func encodingToAPI(encoding *Encoding) *openapiv3.Encoding {
	if encoding == nil {
		return nil
	}
	e := &openapiv3.Encoding{
		ContentType:            encoding.ContentType,
		Style:                  encoding.Style,
		Explode:                encoding.Explode,
		AllowReserved:          encoding.AllowReserved,
		SpecificationExtension: extensionToAPI(encoding.SpecificationExtension),
	}
	if encoding.Headers != nil {
		e.Headers = &openapiv3.HeadersOrReferences{}
		for k, v := range encoding.Headers {
			e.Headers.AdditionalProperties = append(e.Headers.AdditionalProperties,
				&openapiv3.NamedHeaderOrReference{Name: k, Value: headerOrReferenceToAPI(v)},
			)
		}
	}
	return e
}
