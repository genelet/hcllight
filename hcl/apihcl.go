package hcl

import (
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func DocumentFromApi(doc *openapiv3.Document) *Document {
	d := &Document{
		Openapi:                doc.Openapi,
		Info:                   infoFromApi(doc.Info),
		Components:             ComponentsFromApi(doc.Components),
		ExternalDocs:           externalDocsFromApi(doc.ExternalDocs),
		SpecificationExtension: extensionFromApi(doc.SpecificationExtension),
	}
	for _, s := range doc.Servers {
		d.Servers = append(d.Servers, serverFromApi(s))
	}
	if doc.Paths != nil {
		d.Paths = make(map[string]*PathItemOrReference)
		for _, v := range doc.Paths.Path {
			d.Paths[v.Name] = PathItemOrReferenceFromApi(v.Value)
		}
	}

	for _, s := range doc.Security {
		d.Security = append(d.Security, securityRequirementFromApi(s))
	}

	for _, t := range doc.Tags {
		d.Tags = append(d.Tags, tagFromApi(t))
	}

	return d
}

func DocumentToApi(document *Document) *openapiv3.Document {
	if document == nil {
		return nil
	}
	d := &openapiv3.Document{
		Openapi:                document.Openapi,
		Info:                   infoToApi(document.Info),
		Servers:                []*openapiv3.Server{},
		Paths:                  &openapiv3.Paths{},
		Components:             ComponentsToApi(document.Components),
		Security:               []*openapiv3.SecurityRequirement{},
		Tags:                   []*openapiv3.Tag{},
		ExternalDocs:           externalDocsToApi(document.ExternalDocs),
		SpecificationExtension: extensionToApi(document.SpecificationExtension),
	}
	if document.Servers != nil {
		for _, s := range document.Servers {
			d.Servers = append(d.Servers, serverToApi(s))
		}
	}
	if document.Paths != nil {
		for k, v := range document.Paths {
			d.Paths.Path = append(d.Paths.Path,
				&openapiv3.NamedPathItem{Name: k, Value: PathItemOrReferenceToApi(v)},
			)
		}
	}
	if document.Security != nil {
		for _, s := range document.Security {
			d.Security = append(d.Security, securityRequirementToApi(s))
		}
	}
	if document.Tags != nil {
		for _, t := range document.Tags {
			d.Tags = append(d.Tags, tagToApi(t))
		}
	}
	return d
}

func ComponentsFromApi(components *openapiv3.Components) *Components {
	c := &Components{
		SpecificationExtension: extensionFromApi(components.SpecificationExtension),
	}
	if components.Callbacks != nil {
		c.Callbacks = make(map[string]*CallbackOrReference)
		for _, v := range components.Callbacks.AdditionalProperties {
			c.Callbacks[v.Name] = callbackOrReferenceFromApi(v.Value)
		}
	}
	if components.Links != nil {
		c.Links = make(map[string]*LinkOrReference)
		for _, v := range components.Links.AdditionalProperties {
			c.Links[v.Name] = linkOrReferenceFromApi(v.Value)
		}
	}
	if components.SecuritySchemes != nil {
		c.SecuritySchemes = make(map[string]*SecuritySchemeOrReference)
		for _, v := range components.SecuritySchemes.AdditionalProperties {
			c.SecuritySchemes[v.Name] = securitySchemaOrReferenceFromApi(v.Value)
		}
	}
	if components.Examples != nil {
		c.Examples = make(map[string]*ExampleOrReference)
		for _, v := range components.Examples.AdditionalProperties {
			c.Examples[v.Name] = exampleOrReferenceFromApi(v.Value)
		}
	}
	if components.RequestBodies != nil {
		c.RequestBodies = make(map[string]*RequestBodyOrReference)
		for _, v := range components.RequestBodies.AdditionalProperties {
			c.RequestBodies[v.Name] = requestBodyOrReferenceFromApi(v.Value)
		}
	}
	if components.Schemas != nil {
		c.Schemas = make(map[string]*SchemaOrReference)
		for _, v := range components.Schemas.AdditionalProperties {
			c.Schemas[v.Name] = SchemaOrReferenceFromApi(v.Value, true)
		}
	}
	if components.Parameters != nil {
		c.Parameters = make(map[string]*ParameterOrReference)
		for _, v := range components.Parameters.AdditionalProperties {
			c.Parameters[v.Name] = parameterOrReferenceFromApi(v.Value)
		}
	}
	if components.Responses != nil {
		c.Responses = make(map[string]*ResponseOrReference)
		for _, v := range components.Responses.AdditionalProperties {
			c.Responses[v.Name] = responseOrReferenceFromApi(v.Value)
		}
	}
	if components.Headers != nil {
		c.Headers = make(map[string]*HeaderOrReference)
		for _, v := range components.Headers.AdditionalProperties {
			c.Headers[v.Name] = headerOrReferenceFromApi(v.Value)
		}
	}

	return c
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
				&openapiv3.NamedResponseOrReference{Name: k, Value: responseOrReferenceToApi(v)},
			)
		}
	}
	if components.Parameters != nil {
		for k, v := range components.Parameters {
			c.Parameters.AdditionalProperties = append(c.Parameters.AdditionalProperties,
				&openapiv3.NamedParameterOrReference{Name: k, Value: parameterOrReferenceToApi(v)},
			)
		}
	}
	if components.Examples != nil {
		for k, v := range components.Examples {
			c.Examples.AdditionalProperties = append(c.Examples.AdditionalProperties,
				&openapiv3.NamedExampleOrReference{Name: k, Value: exampleOrReferenceToApi(v)},
			)
		}
	}
	if components.RequestBodies != nil {
		for k, v := range components.RequestBodies {
			c.RequestBodies.AdditionalProperties = append(c.RequestBodies.AdditionalProperties,
				&openapiv3.NamedRequestBodyOrReference{Name: k, Value: requestBodyOrReferenceToApi(v)},
			)
		}
	}
	if components.Headers != nil {
		for k, v := range components.Headers {
			c.Headers.AdditionalProperties = append(c.Headers.AdditionalProperties,
				&openapiv3.NamedHeaderOrReference{Name: k, Value: headerOrReferenceToApi(v)},
			)
		}
	}
	return c
}

func ReferenceFromApi(reference *openapiv3.Reference) *Reference {
	if reference == nil {
		return nil
	}
	return &Reference{
		XRef:        reference.XRef,
		Summary:     reference.Summary,
		Description: reference.Description,
	}
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

func PathItemOrReferenceFromApi(path *openapiv3.PathItem) *PathItemOrReference {
	if path == nil {
		return nil
	}
	if reference := path.XRef; reference != "" {
		return &PathItemOrReference{
			Oneof: &PathItemOrReference_Reference{
				Reference: ReferenceFromApi(&openapiv3.Reference{
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
		Get:                    operationFromApi(path.Get),
		Put:                    operationFromApi(path.Put),
		Post:                   operationFromApi(path.Post),
		Delete:                 operationFromApi(path.Delete),
		Options:                operationFromApi(path.Options),
		Head:                   operationFromApi(path.Head),
		Patch:                  operationFromApi(path.Patch),
		Trace:                  operationFromApi(path.Trace),
		SpecificationExtension: extensionFromApi(path.SpecificationExtension),
	}
	for _, s := range path.Servers {
		p.Servers = append(p.Servers, serverFromApi(s))
	}
	for _, s := range path.Parameters {
		p.Parameters = append(p.Parameters, parameterOrReferenceFromApi(s))
	}
	return &PathItemOrReference{
		Oneof: &PathItemOrReference_Item{
			Item: p,
		},
	}
}

func PathItemOrReferenceToApi(item *PathItemOrReference) *openapiv3.PathItem {
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
		SpecificationExtension: extensionToApi(pathItem.SpecificationExtension),
		Get:                    operationToApi(pathItem.Get),
		Put:                    operationToApi(pathItem.Put),
		Post:                   operationToApi(pathItem.Post),
		Delete:                 operationToApi(pathItem.Delete),
		Options:                operationToApi(pathItem.Options),
		Head:                   operationToApi(pathItem.Head),
		Patch:                  operationToApi(pathItem.Patch),
		Trace:                  operationToApi(pathItem.Trace),
	}
	if pathItem.Servers != nil {
		p.Servers = []*openapiv3.Server{}
		for _, s := range pathItem.Servers {
			p.Servers = append(p.Servers, serverToApi(s))
		}
	}
	if pathItem.Parameters != nil {
		p.Parameters = []*openapiv3.ParameterOrReference{}
		for _, v := range pathItem.Parameters {
			p.Parameters = append(p.Parameters, parameterOrReferenceToApi(v))
		}
	}
	return p
}

func contactFromApi(contact *openapiv3.Contact) *Contact {
	if contact == nil {
		return nil
	}
	return &Contact{
		Name:                   contact.Name,
		Url:                    contact.Url,
		Email:                  contact.Email,
		SpecificationExtension: extensionFromApi(contact.SpecificationExtension),
	}
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

func licenseFromApi(license *openapiv3.License) *License {
	if license == nil {
		return nil
	}
	return &License{
		Name:                   license.Name,
		Url:                    license.Url,
		SpecificationExtension: extensionFromApi(license.SpecificationExtension),
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

func infoFromApi(info *openapiv3.Info) *Info {
	if info == nil {
		return nil
	}
	return &Info{
		Title:                  info.Title,
		Description:            info.Description,
		TermsOfService:         info.TermsOfService,
		Version:                info.Version,
		Contact:                contactFromApi(info.Contact),
		License:                licenseFromApi(info.License),
		SpecificationExtension: extensionFromApi(info.SpecificationExtension),
		Summary:                info.Summary,
	}
}

func infoToApi(info *Info) *openapiv3.Info {
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

func tagFromApi(tag *openapiv3.Tag) *Tag {
	if tag == nil {
		return nil
	}
	return &Tag{
		Name:                   tag.Name,
		Description:            tag.Description,
		ExternalDocs:           externalDocsFromApi(tag.ExternalDocs),
		SpecificationExtension: extensionFromApi(tag.SpecificationExtension),
	}
}

func tagToApi(tag *Tag) *openapiv3.Tag {
	if tag == nil {
		return nil
	}
	return &openapiv3.Tag{
		Name:                   tag.Name,
		Description:            tag.Description,
		ExternalDocs:           externalDocsToApi(tag.ExternalDocs),
		SpecificationExtension: extensionToApi(tag.SpecificationExtension),
	}
}

func serverVariableFromApi(variable *openapiv3.ServerVariable) *ServerVariable {
	if variable == nil {
		return nil
	}
	return &ServerVariable{
		Default:                variable.Default,
		Enum:                   variable.Enum,
		Description:            variable.Description,
		SpecificationExtension: extensionFromApi(variable.SpecificationExtension),
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

func serverFromApi(server *openapiv3.Server) *Server {
	if server == nil {
		return nil
	}
	s := &Server{
		Url:                    server.Url,
		Description:            server.Description,
		SpecificationExtension: extensionFromApi(server.SpecificationExtension),
	}
	if server.Variables != nil {
		for _, v := range server.Variables.AdditionalProperties {
			if s.Variables == nil {
				s.Variables = make(map[string]*ServerVariable)
			}
			s.Variables[v.Name] = serverVariableFromApi(v.Value)
		}
	}
	return s
}

func serverToApi(server *Server) *openapiv3.Server {
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

func stringArrayFromApi(array *openapiv3.StringArray) *StringArray {
	if array == nil {
		return nil
	}
	return &StringArray{
		Value: array.Value,
	}
}

func stringArrayToApi(stringArray *StringArray) *openapiv3.StringArray {
	if stringArray == nil {
		return nil
	}
	return &openapiv3.StringArray{
		Value: stringArray.Value,
	}
}

func oAuthFlowFromApi(flow *openapiv3.OauthFlow) *OauthFlow {
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
		SpecificationExtension: extensionFromApi(flow.SpecificationExtension),
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

func oAuthFlowsFromApi(flows *openapiv3.OauthFlows) *OauthFlows {
	if flows == nil {
		return nil
	}
	return &OauthFlows{
		Implicit:               oAuthFlowFromApi(flows.Implicit),
		Password:               oAuthFlowFromApi(flows.Password),
		ClientCredentials:      oAuthFlowFromApi(flows.ClientCredentials),
		AuthorizationCode:      oAuthFlowFromApi(flows.AuthorizationCode),
		SpecificationExtension: extensionFromApi(flows.SpecificationExtension),
	}
}

func oAuthFlowsToApi(oAuthFlows *OauthFlows) *openapiv3.OauthFlows {
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

func securityRequirementFromApi(requirement *openapiv3.SecurityRequirement) *SecurityRequirement {
	if requirement == nil {
		return nil
	}
	s := make(map[string]*StringArray)
	for _, v := range requirement.AdditionalProperties {
		s[v.Name] = stringArrayFromApi(v.Value)
	}
	return &SecurityRequirement{
		AdditionalProperties: s,
	}
}

func securityRequirementToApi(securityRequirement *SecurityRequirement) *openapiv3.SecurityRequirement {
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

func securitySchemaOrReferenceFromApi(security *openapiv3.SecuritySchemeOrReference) *SecuritySchemeOrReference {
	if security == nil {
		return nil
	}
	if x := security.GetReference(); x != nil {
		return &SecuritySchemeOrReference{
			Oneof: &SecuritySchemeOrReference_Reference{
				Reference: ReferenceFromApi(x),
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
				Flows:                  oAuthFlowsFromApi(s.Flows),
				OpenIdConnectUrl:       s.OpenIdConnectUrl,
				SpecificationExtension: extensionFromApi(s.SpecificationExtension),
			},
		},
	}
}

func securitySchemeOrReferenceToApi(securitySchemeOrReference *SecuritySchemeOrReference) *openapiv3.SecuritySchemeOrReference {
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
				Flows:                  oAuthFlowsToApi(s.Flows),
				OpenIdConnectUrl:       s.OpenIdConnectUrl,
				SpecificationExtension: extensionToApi(s.SpecificationExtension),
			},
		},
	}
}

func expressionFromApi(expression *openapiv3.Expression) *Expression {
	if expression == nil {
		return nil
	}
	expr := make(map[string]*Any)
	for _, v := range expression.AdditionalProperties {
		expr[v.Name] = anyFromApi(v.Value)
	}
	return &Expression{
		AdditionalProperties: expr,
	}
}

func expressionToApi(expression *Expression) *openapiv3.Expression {
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

func anyOrReferenceFromApi(any *openapiv3.AnyOrExpression) *AnyOrExpression {
	if any == nil {
		return nil
	}
	if x := any.GetAny(); x != nil {
		return &AnyOrExpression{
			Oneof: &AnyOrExpression_Any{
				Any: anyFromApi(x),
			},
		}
	}
	expr := any.GetExpression()
	return &AnyOrExpression{
		Oneof: &AnyOrExpression_Expression{
			Expression: expressionFromApi(expr),
		},
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
			Expression: expressionToApi(e),
		},
	}
}

func linkOrReferenceFromApi(link *openapiv3.LinkOrReference) *LinkOrReference {
	if link == nil {
		return nil
	}
	if x := link.GetReference(); x != nil {
		return &LinkOrReference{
			Oneof: &LinkOrReference_Reference{
				Reference: ReferenceFromApi(x),
			},
		}
	}

	l := link.GetLink()
	return &LinkOrReference{
		Oneof: &LinkOrReference_Link{
			Link: &Link{
				OperationRef:           l.OperationRef,
				OperationId:            l.OperationId,
				Parameters:             anyOrReferenceFromApi(l.Parameters),
				RequestBody:            anyOrReferenceFromApi(l.RequestBody),
				Description:            l.Description,
				Server:                 serverFromApi(l.Server),
				SpecificationExtension: extensionFromApi(l.SpecificationExtension),
			},
		},
	}
}

func linkOrReferenceToApi(linkOrReference *LinkOrReference) *openapiv3.LinkOrReference {
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
				Server:                 serverToApi(l.Server),
				SpecificationExtension: extensionToApi(l.SpecificationExtension),
			},
		},
	}
}

func exampleFromApi(example *openapiv3.Example) *Example {
	if example == nil {
		return nil
	}
	return &Example{
		Summary:                example.Summary,
		Description:            example.Description,
		Value:                  anyFromApi(example.Value),
		SpecificationExtension: extensionFromApi(example.SpecificationExtension),
	}
}

func exampleToApi(e *Example) *openapiv3.Example {
	return &openapiv3.Example{
		Summary:                e.Summary,
		Description:            e.Description,
		Value:                  anyToApi(e.Value),
		ExternalValue:          e.ExternalValue,
		SpecificationExtension: extensionToApi(e.SpecificationExtension),
	}
}

func exampleOrReferenceFromApi(example *openapiv3.ExampleOrReference) *ExampleOrReference {
	if example == nil {
		return nil
	}
	if x := example.GetReference(); x != nil {
		return &ExampleOrReference{
			Oneof: &ExampleOrReference_Reference{
				Reference: ReferenceFromApi(x),
			},
		}
	}

	e := example.GetExample()
	return &ExampleOrReference{
		Oneof: &ExampleOrReference_Example{
			Example: exampleFromApi(e),
		},
	}
}

func exampleOrReferenceToApi(exampleOrReference *ExampleOrReference) *openapiv3.ExampleOrReference {
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
			Example: exampleToApi(e),
		},
	}
}

func parameterFromApi(parameter *openapiv3.Parameter) *Parameter {
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
		Schema:                 SchemaOrReferenceFromApi(parameter.Schema),
		Example:                anyFromApi(parameter.Example),
		SpecificationExtension: extensionFromApi(parameter.SpecificationExtension),
	}
	if parameter.Content != nil {
		p.Content = make(map[string]*MediaType)
		for _, v := range parameter.Content.AdditionalProperties {
			p.Content[v.Name] = mediaTypeFromApi(v.Value)
		}
	}
	if parameter.Examples != nil {
		p.Examples = make(map[string]*ExampleOrReference)
		for _, v := range parameter.Examples.AdditionalProperties {
			p.Examples[v.Name] = exampleOrReferenceFromApi(v.Value)
		}
	}
	return p
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
				&openapiv3.NamedExampleOrReference{Name: k, Value: exampleOrReferenceToApi(v)},
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

func parameterOrReferenceFromApi(parameter *openapiv3.ParameterOrReference) *ParameterOrReference {
	if parameter == nil {
		return nil
	}
	if x := parameter.GetReference(); x != nil {
		return &ParameterOrReference{
			Oneof: &ParameterOrReference_Reference{
				Reference: ReferenceFromApi(x),
			},
		}
	}

	p := parameter.GetParameter()
	return &ParameterOrReference{
		Oneof: &ParameterOrReference_Parameter{
			Parameter: parameterFromApi(p),
		},
	}
}

func parameterOrReferenceToApi(parameterOrReference *ParameterOrReference) *openapiv3.ParameterOrReference {
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

func requestBodyFromApi(body *openapiv3.RequestBody) *RequestBody {
	if body == nil {
		return nil
	}
	r := &RequestBody{
		Description:            body.Description,
		Required:               body.Required,
		SpecificationExtension: extensionFromApi(body.SpecificationExtension),
	}
	if body.Content != nil {
		r.Content = make(map[string]*MediaType)
		for _, v := range body.Content.AdditionalProperties {
			r.Content[v.Name] = mediaTypeFromApi(v.Value)
		}
	}
	return r
}

func requestBodyToApi(requestBody *RequestBody) *openapiv3.RequestBody {
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

func requestBodyOrReferenceFromApi(body *openapiv3.RequestBodyOrReference) *RequestBodyOrReference {
	if body == nil {
		return nil
	}

	if x := body.GetReference(); x != nil {
		return &RequestBodyOrReference{
			Oneof: &RequestBodyOrReference_Reference{
				Reference: ReferenceFromApi(x),
			},
		}
	}

	b := body.GetRequestBody()
	return &RequestBodyOrReference{
		Oneof: &RequestBodyOrReference_RequestBody{
			RequestBody: requestBodyFromApi(b),
		},
	}
}

func requestBodyOrReferenceToApi(requestBodyOrReference *RequestBodyOrReference) *openapiv3.RequestBodyOrReference {
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
			RequestBody: requestBodyToApi(r),
		},
	}
}

func responseFromApi(response *openapiv3.Response) *Response {
	if response == nil {
		return nil
	}
	r := &Response{
		Description:            response.Description,
		Headers:                make(map[string]*HeaderOrReference),
		Content:                make(map[string]*MediaType),
		Links:                  make(map[string]*LinkOrReference),
		SpecificationExtension: extensionFromApi(response.SpecificationExtension),
	}
	if response.Headers != nil {
		for _, s := range response.Headers.AdditionalProperties {
			r.Headers[s.Name] = headerOrReferenceFromApi(s.Value)
		}
	}
	if response.Content != nil {
		for _, s := range response.Content.AdditionalProperties {
			r.Content[s.Name] = mediaTypeFromApi(s.Value)
		}
	}
	if response.Links != nil {
		for _, s := range response.Links.AdditionalProperties {
			r.Links[s.Name] = linkOrReferenceFromApi(s.Value)
		}
	}

	return r
}

func responseToApi(response *Response) *openapiv3.Response {
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
				&openapiv3.NamedHeaderOrReference{Name: k, Value: headerOrReferenceToApi(v)},
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
				&openapiv3.NamedLinkOrReference{Name: k, Value: linkOrReferenceToApi(v)},
			)
		}
	}
	return r
}

func responseOrReferenceFromApi(response *openapiv3.ResponseOrReference) *ResponseOrReference {
	if response == nil {
		return nil
	}

	if x := response.GetReference(); x != nil {
		return &ResponseOrReference{
			Oneof: &ResponseOrReference_Reference{
				Reference: ReferenceFromApi(x),
			},
		}
	}

	r := response.GetResponse()
	return &ResponseOrReference{
		Oneof: &ResponseOrReference_Response{
			Response: responseFromApi(r),
		},
	}
}

func responseOrReferenceToApi(responseOrReference *ResponseOrReference) *openapiv3.ResponseOrReference {
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
			Response: responseToApi(r),
		},
	}
}

func operationFromApi(operation *openapiv3.Operation) *Operation {
	if operation == nil {
		return nil
	}

	o := &Operation{
		Tags:                   operation.Tags,
		Summary:                operation.Summary,
		Description:            operation.Description,
		ExternalDocs:           externalDocsFromApi(operation.ExternalDocs),
		OperationId:            operation.OperationId,
		RequestBody:            requestBodyOrReferenceFromApi(operation.RequestBody),
		Deprecated:             operation.Deprecated,
		SpecificationExtension: extensionFromApi(operation.SpecificationExtension),
	}

	for _, s := range operation.Security {
		o.Security = append(o.Security, securityRequirementFromApi(s))
	}
	for _, s := range operation.Servers {
		o.Servers = append(o.Servers, serverFromApi(s))
	}
	for _, s := range operation.Parameters {
		o.Parameters = append(o.Parameters, parameterOrReferenceFromApi(s))
	}
	if operation.Callbacks != nil {
		o.Callbacks = make(map[string]*CallbackOrReference)
		for _, v := range operation.Callbacks.AdditionalProperties {
			o.Callbacks[v.Name] = callbackOrReferenceFromApi(v.Value)
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
			o.Responses[v.Name] = responseOrReferenceFromApi(v.Value)
		}
	}

	return o
}

func operationToApi(operation *Operation) *openapiv3.Operation {
	if operation == nil {
		return nil
	}
	o := &openapiv3.Operation{
		Tags:                   operation.Tags,
		Summary:                operation.Summary,
		Description:            operation.Description,
		ExternalDocs:           externalDocsToApi(operation.ExternalDocs),
		OperationId:            operation.OperationId,
		Parameters:             []*openapiv3.ParameterOrReference{},
		RequestBody:            requestBodyOrReferenceToApi(operation.RequestBody),
		Deprecated:             operation.Deprecated,
		Security:               []*openapiv3.SecurityRequirement{},
		Servers:                []*openapiv3.Server{},
		SpecificationExtension: extensionToApi(operation.SpecificationExtension),
	}
	if operation.Parameters != nil {
		for _, p := range operation.Parameters {
			o.Parameters = append(o.Parameters, parameterOrReferenceToApi(p))
		}
	}
	if operation.Responses != nil {
		o.Responses = &openapiv3.Responses{}
		for k, v := range operation.Responses {
			o.Responses.ResponseOrReference = append(o.Responses.ResponseOrReference,
				&openapiv3.NamedResponseOrReference{Name: k, Value: responseOrReferenceToApi(v)},
			)
		}
	}
	if operation.Callbacks != nil {
		for k, v := range operation.Callbacks {
			o.Callbacks.AdditionalProperties = append(o.Callbacks.AdditionalProperties,
				&openapiv3.NamedCallbackOrReference{Name: k, Value: callbackOrReferenceToApi(v)},
			)
		}
	}
	if operation.Security != nil {
		for _, s := range operation.Security {
			o.Security = append(o.Security, securityRequirementToApi(s))
		}
	}
	if operation.Servers != nil {
		for _, s := range operation.Servers {
			o.Servers = append(o.Servers, serverToApi(s))
		}
	}
	return o
}

func callbackOrReferenceFromApi(callback *openapiv3.CallbackOrReference) *CallbackOrReference {
	if callback == nil {
		return nil
	}

	if x := callback.GetReference(); x != nil {
		return &CallbackOrReference{
			Oneof: &CallbackOrReference_Reference{
				Reference: ReferenceFromApi(x),
			},
		}
	}

	cs := make(map[string]*PathItemOrReference)
	call := callback.GetCallback()
	for _, v := range call.Path {
		cs[v.Name] = PathItemOrReferenceFromApi(v.Value)
	}

	return &CallbackOrReference{
		Oneof: &CallbackOrReference_Callback{
			Callback: &Callback{
				Path: cs,
			},
		},
	}
}

func callbackOrReferenceToApi(callbackOrReference *CallbackOrReference) *openapiv3.CallbackOrReference {
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
		cs = append(cs, &openapiv3.NamedPathItem{Name: k, Value: PathItemOrReferenceToApi(v)})
	}
	return &openapiv3.CallbackOrReference{
		Oneof: &openapiv3.CallbackOrReference_Callback{
			Callback: &openapiv3.Callback{
				Path: cs,
			},
		},
	}
}

func headerFromApi(header *openapiv3.Header) *Header {
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
		Example:                anyFromApi(header.Example),
		Schema:                 SchemaOrReferenceFromApi(header.Schema),
		SpecificationExtension: extensionFromApi(header.SpecificationExtension),
	}
	if header.Examples != nil {
		h.Examples = make(map[string]*ExampleOrReference)
		for _, v := range header.Examples.AdditionalProperties {
			h.Examples[v.Name] = exampleOrReferenceFromApi(v.Value)
		}
	}
	if header.Content != nil {
		h.Content = make(map[string]*MediaType)
		for _, v := range header.Content.AdditionalProperties {
			h.Content[v.Name] = mediaTypeFromApi(v.Value)
		}
	}
	return h
}

func headerToApi(header *Header) *openapiv3.Header {
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
		Example:                anyToApi(header.Example),
		Schema:                 SchemaOrReferenceToApi(header.Schema),
		SpecificationExtension: extensionToApi(header.SpecificationExtension),
	}
	if header.Examples != nil {
		h.Examples = &openapiv3.ExamplesOrReferences{}
		for k, v := range header.Examples {
			h.Examples.AdditionalProperties = append(h.Examples.AdditionalProperties,
				&openapiv3.NamedExampleOrReference{Name: k, Value: exampleOrReferenceToApi(v)},
			)
		}
	}
	if header.Content != nil {
		h.Content = &openapiv3.MediaTypes{}
		for k, v := range header.Content {
			h.Content.AdditionalProperties = append(h.Content.AdditionalProperties,
				&openapiv3.NamedMediaType{Name: k, Value: mediaTypeToApi(v)},
			)
		}
	}
	return h
}

func headerOrReferenceFromApi(header *openapiv3.HeaderOrReference) *HeaderOrReference {
	if header == nil {
		return nil
	}

	if x := header.GetReference(); x != nil {
		return &HeaderOrReference{
			Oneof: &HeaderOrReference_Reference{
				Reference: ReferenceFromApi(x),
			},
		}
	}

	x := header.GetHeader()
	return &HeaderOrReference{
		Oneof: &HeaderOrReference_Header{
			Header: headerFromApi(x),
		},
	}
}

func headerOrReferenceToApi(headerOrReference *HeaderOrReference) *openapiv3.HeaderOrReference {
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
			Header: headerToApi(h),
		},
	}
}

func mediaTypeFromApi(mt *openapiv3.MediaType) *MediaType {
	if mt == nil {
		return nil
	}

	m := &MediaType{
		Schema:                 SchemaOrReferenceFromApi(mt.Schema),
		Example:                anyFromApi(mt.Example),
		SpecificationExtension: extensionFromApi(mt.SpecificationExtension),
	}
	if mt.Examples != nil {
		m.Examples = make(map[string]*ExampleOrReference)
		for _, v := range mt.Examples.AdditionalProperties {
			m.Examples[v.Name] = exampleOrReferenceFromApi(v.Value)
		}
	}
	if mt.Encoding != nil {
		m.Encoding = make(map[string]*Encoding)
		for _, v := range mt.Encoding.AdditionalProperties {
			m.Encoding[v.Name] = encodingFromApi(v.Value)
		}
	}
	return m
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
				&openapiv3.NamedExampleOrReference{Name: k, Value: exampleOrReferenceToApi(v)},
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

func encodingFromApi(encoding *openapiv3.Encoding) *Encoding {
	if encoding == nil {
		return nil
	}

	e := &Encoding{
		ContentType:            encoding.ContentType,
		Headers:                make(map[string]*HeaderOrReference),
		Style:                  encoding.Style,
		Explode:                encoding.Explode,
		AllowReserved:          encoding.AllowReserved,
		SpecificationExtension: extensionFromApi(encoding.SpecificationExtension),
	}
	if encoding.Headers != nil {
		for _, v := range encoding.Headers.AdditionalProperties {
			e.Headers[v.Name] = headerOrReferenceFromApi(v.Value)
		}
	}
	return e
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
				&openapiv3.NamedHeaderOrReference{Name: k, Value: headerOrReferenceToApi(v)},
			)
		}
	}
	return e
}
