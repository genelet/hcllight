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
	if contact == nil {
		return nil
	}
	return &Contact{
		Name:                   contact.Name,
		Url:                    contact.Url,
		Email:                  contact.Email,
		SpecificationExtension: extensionToHcl(contact.SpecificationExtension),
	}
}

func licenseToHcl(license *openapiv3.License) *License {
	if license == nil {
		return nil
	}
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
	if docs == nil {
		return nil
	}
	return &ExternalDocs{
		Description:            docs.Description,
		Url:                    docs.Url,
		SpecificationExtension: extensionToHcl(docs.SpecificationExtension),
	}
}

func TagToHcl(tag *openapiv3.Tag) *Tag {
	if tag == nil {
		return nil
	}
	return &Tag{
		Name:                   tag.Name,
		Description:            tag.Description,
		ExternalDocs:           ExternalDocsToHcl(tag.ExternalDocs),
		SpecificationExtension: extensionToHcl(tag.SpecificationExtension),
	}
}

func serverVariableToHcl(variable *openapiv3.ServerVariable) *ServerVariable {
	if variable == nil {
		return nil
	}
	return &ServerVariable{
		Default:                variable.Default,
		Enum:                   variable.Enum,
		Description:            variable.Description,
		SpecificationExtension: extensionToHcl(variable.SpecificationExtension),
	}
}

func ServerToHcl(server *openapiv3.Server) *Server {
	if server == nil {
		return nil
	}
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
	if array == nil {
		return nil
	}
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

func SecuritySchemaOrReferenceToHcl(security *openapiv3.SecuritySchemeOrReference) *SecuritySchemeOrReference {
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
		d.Paths = make(map[string]*PathItem)
		for _, v := range doc.Paths.Path {
			d.Paths[v.Name] = PathItemToHcl(v.Value)
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

func LinkOrReferenceToHcl(link *openapiv3.LinkOrReference) *LinkOrReference {
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

func ComponentsToHcl(components *openapiv3.Components) *Components {
	c := &Components{
		SpecificationExtension: extensionToHcl(components.SpecificationExtension),
	}
	if components.Callbacks != nil {
		c.Callbacks = make(map[string]*CallbackOrReference)
		for _, v := range components.Callbacks.AdditionalProperties {
			c.Callbacks[v.Name] = CallbackToHcl(v.Value)
		}
	}
	if components.Links != nil {
		c.Links = make(map[string]*LinkOrReference)
		for _, v := range components.Links.AdditionalProperties {
			c.Links[v.Name] = LinkOrReferenceToHcl(v.Value)
		}
	}
	if components.SecuritySchemes != nil {
		c.SecuritySchemes = make(map[string]*SecuritySchemeOrReference)
		for _, v := range components.SecuritySchemes.AdditionalProperties {
			c.SecuritySchemes[v.Name] = SecuritySchemaOrReferenceToHcl(v.Value)
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
		c.Responses = make(map[string]*ResponseOrReference)
		for _, v := range components.Responses.AdditionalProperties {
			c.Responses[v.Name] = ResponseOrReferenceToHcl(v.Value)
		}
	}
	if components.Headers != nil {
		c.Headers = make(map[string]*HeaderOrReference)
		for _, v := range components.Headers.AdditionalProperties {
			c.Headers[v.Name] = HeaderOrReferenceToHcl(v.Value)
		}
	}

	return c
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

func DiscriminatorToHcl(discriminator *openapiv3.Discriminator) *Discriminator {
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

func oasCommonToHcl(common *openapiv3.Schema) *OASCommon {
	if common == nil {
		return nil
	}
	if common.Title == "" && common.Description == "" && common.Nullable == false && common.Deprecated == false && common.Example == nil && common.Xml == nil && common.ExternalDocs == nil && common.SpecificationExtension == nil {
		return &OASCommon{
			Title:                  common.Title,
			Description:            common.Description,
			Nullable:               common.Nullable,
			Deprecated:             common.Deprecated,
			Example:                anyToHcl(common.Example),
			Xml:                    xmlToHcl(common.Xml),
			ExternalDocs:           ExternalDocsToHcl(common.ExternalDocs),
			SpecificationExtension: extensionToHcl(common.SpecificationExtension),
		}
	}
	return nil
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

	/*
		if s.Enum != nil {
			items := make([]*Any, 0)
			for _, v := range s.Enum {
				items = append(items, &Any{Value: v.Value})
			}
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_Enum{
					Enum: &AnyArray{
						Anies: items,
					},
				},
			}
		} else
	*/
	if s.AllOf != nil {
		var items []*SchemaOrReference
		for _, v := range s.AllOf {
			items = append(items, SchemaOrReferenceToHcl(v))
		}
		return &SchemaOrReference{
			Oneof: &SchemaOrReference_OasAllof{
				OasAllof: &OASArray{
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
					Items: items,
				},
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
					Common:        common,
					MaxItems:      s.MaxItems,
					MinItems:      s.MinItems,
					UniqueItems:   s.UniqueItems,
					Not:           schemaToHcl(s.Not),
					Discriminator: DiscriminatorToHcl(s.Discriminator),
					Items:         items,
				},
			},
		}
	case "object":
		if s.AdditionalProperties != nil {
			return &SchemaOrReference{
				Oneof: &SchemaOrReference_Map{
					Map: &OASMap{
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
					Properties:    properties,
					Common:        common,
					MaxProperties: s.MaxProperties,
					MinProperties: s.MinProperties,
					Required:      s.Required,
					ReadOnly:      s.ReadOnly,
					WriteOnly:     s.WriteOnly,
					Not:           schemaToHcl(s.Not),
					Discriminator: DiscriminatorToHcl(s.Discriminator),
				},
			},
		}
	case "string":
		str := &OASString{
			Format: s.Format,
			//Required:  s.Required,
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
	default:
	}
	return nil
}

// convert v3.Schema to v3.SchemaOrReference first
func schemaToHcl(schema *openapiv3.Schema) *SchemaOrReference {
	if schema == nil {
		return nil
	}
	sr := &openapiv3.SchemaOrReference{
		Oneof: &openapiv3.SchemaOrReference_Schema{
			Schema: schema,
		},
	}
	return SchemaOrReferenceToHcl(sr)
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

func parameterToHcl(parameter *openapiv3.Parameter) *Parameter {
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
		p.Content = make(map[string]*MediaType)
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
			Parameter: parameterToHcl(p),
		},
	}
}

func requestBodyToHcl(body *openapiv3.RequestBody) *RequestBody {
	if body == nil {
		return nil
	}
	r := &RequestBody{
		Description:            body.Description,
		Required:               body.Required,
		SpecificationExtension: extensionToHcl(body.SpecificationExtension),
	}
	if body.Content != nil {
		r.Content = make(map[string]*MediaType)
		for _, v := range body.Content.AdditionalProperties {
			r.Content[v.Name] = mediaTypeToHcl(v.Value)
		}
	}
	return r
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
			RequestBody: requestBodyToHcl(b),
		},
	}
}

func responseToHcl(response *openapiv3.Response) *Response {
	if response == nil {
		return nil
	}
	r := &Response{
		Description:            response.Description,
		Headers:                make(map[string]*HeaderOrReference),
		Content:                make(map[string]*MediaType),
		Links:                  make(map[string]*LinkOrReference),
		SpecificationExtension: extensionToHcl(response.SpecificationExtension),
	}
	if response.Headers != nil {
		for _, s := range response.Headers.AdditionalProperties {
			r.Headers[s.Name] = HeaderOrReferenceToHcl(s.Value)
		}
	}
	if response.Content != nil {
		for _, s := range response.Content.AdditionalProperties {
			r.Content[s.Name] = mediaTypeToHcl(s.Value)
		}
	}
	if response.Links != nil {
		for _, s := range response.Links.AdditionalProperties {
			r.Links[s.Name] = LinkOrReferenceToHcl(s.Value)
		}
	}

	return r
}

func ResponseOrReferenceToHcl(response *openapiv3.ResponseOrReference) *ResponseOrReference {
	if response == nil {
		return nil
	}

	if x := response.GetReference(); x != nil {
		return &ResponseOrReference{
			Oneof: &ResponseOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}

	r := response.GetResponse()
	return &ResponseOrReference{
		Oneof: &ResponseOrReference_Response{
			Response: responseToHcl(r),
		},
	}
}

func OperationToHcl(operation *openapiv3.Operation) *Operation {
	if operation == nil {
		return nil
	}

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
		o.Callbacks = make(map[string]*CallbackOrReference)
		for _, v := range operation.Callbacks.AdditionalProperties {
			o.Callbacks[v.Name] = CallbackToHcl(v.Value)
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
			o.Responses[v.Name] = ResponseOrReferenceToHcl(v.Value)
		}
	}

	return o
}

func CallbackToHcl(callback *openapiv3.CallbackOrReference) *CallbackOrReference {
	if callback == nil {
		return nil
	}

	if x := callback.GetReference(); x != nil {
		return &CallbackOrReference{
			Oneof: &CallbackOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}

	cs := make(map[string]*PathItem)
	call := callback.GetCallback()
	for _, v := range call.Path {
		cs[v.Name] = PathItemToHcl(v.Value)
	}

	return &CallbackOrReference{
		Oneof: &CallbackOrReference_Callback{
			Callback: &Callback{
				Path: cs,
			},
		},
	}
}

func headerToHcl(header *openapiv3.Header) *Header {
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
		Example:                anyToHcl(header.Example),
		Schema:                 SchemaOrReferenceToHcl(header.Schema),
		SpecificationExtension: extensionToHcl(header.SpecificationExtension),
	}
	if header.Examples != nil {
		h.Examples = make(map[string]*ExampleOrReference)
		for _, v := range header.Examples.AdditionalProperties {
			h.Examples[v.Name] = ExampleOrReferenceToHcl(v.Value)
		}
	}
	if header.Content != nil {
		h.Content = make(map[string]*MediaType)
		for _, v := range header.Content.AdditionalProperties {
			h.Content[v.Name] = mediaTypeToHcl(v.Value)
		}
	}
	return h
}

func HeaderOrReferenceToHcl(header *openapiv3.HeaderOrReference) *HeaderOrReference {
	if header == nil {
		return nil
	}

	if x := header.GetReference(); x != nil {
		return &HeaderOrReference{
			Oneof: &HeaderOrReference_Reference{
				Reference: ReferenceToHcl(x),
			},
		}
	}

	x := header.GetHeader()
	return &HeaderOrReference{
		Oneof: &HeaderOrReference_Header{
			Header: headerToHcl(x),
		},
	}
}

func mediaTypeToHcl(mt *openapiv3.MediaType) *MediaType {
	if mt == nil {
		return nil
	}

	m := &MediaType{
		Schema:                 SchemaOrReferenceToHcl(mt.Schema),
		Example:                anyToHcl(mt.Example),
		SpecificationExtension: extensionToHcl(mt.SpecificationExtension),
	}
	if mt.Examples != nil {
		m.Examples = make(map[string]*ExampleOrReference)
		for _, v := range mt.Examples.AdditionalProperties {
			m.Examples[v.Name] = ExampleOrReferenceToHcl(v.Value)
		}
	}
	if mt.Encoding != nil {
		m.Encoding = make(map[string]*Encoding)
		for _, v := range mt.Encoding.AdditionalProperties {
			m.Encoding[v.Name] = encodingToHcl(v.Value)
		}
	}
	return m
}

func encodingToHcl(encoding *openapiv3.Encoding) *Encoding {
	if encoding == nil {
		return nil
	}

	e := &Encoding{
		ContentType:            encoding.ContentType,
		Headers:                make(map[string]*HeaderOrReference),
		Style:                  encoding.Style,
		Explode:                encoding.Explode,
		AllowReserved:          encoding.AllowReserved,
		SpecificationExtension: extensionToHcl(encoding.SpecificationExtension),
	}
	if encoding.Headers != nil {
		for _, v := range encoding.Headers.AdditionalProperties {
			e.Headers[v.Name] = HeaderOrReferenceToHcl(v.Value)
		}
	}
	return e
}
