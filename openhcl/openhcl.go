package openhcl

import (
	"github.com/genelet/hcllight/internal/hcl"
)

type AdditionalPropertiesItem any

func NewAdditionalPropertiesItem(a *hcl.AdditionalPropertiesItem) AdditionalPropertiesItem {
	if a == nil {
		return nil
	}
	if x := a.GetBoolean(); x {
		return x
	}
	if x := a.GetSchemaOrReference(); x != nil {
		return NewSchemaOrReference(x)
	}
	return nil
}

type AnyOrExpression any

func NewAnyOrExpression(a *hcl.AnyOrExpression) AnyOrExpression {
	if a == nil {
		return nil
	}
	if x := a.GetExpression(); x != nil {
		return x
	}
	return a.GetAny()
}

type Callback struct {
	Path map[string]PathItemOrReference
}

func NewCallback(a *hcl.Callback) *Callback {
	if a == nil {
		return nil
	}
	p := make(map[string]PathItemOrReference)
	if a.Path != nil {
		for k, v := range a.Path {
			p[k] = NewPathItemOrReference(v)
		}
	}
	return &Callback{
		Path: p,
	}
}

type CallbackOrReference any

func NewCallbackOrReference(a *hcl.CallbackOrReference) CallbackOrReference {
	if a == nil {
		return nil
	}
	if x := a.GetReference(); x != nil {
		return x
	}
	return NewCallback(a.GetCallback())
}

type Components struct {
	Schemas                map[string]SchemaOrReference
	Responses              map[string]ResponseOrReference
	Parameters             map[string]ParameterOrReference
	Examples               map[string]ExampleOrReference
	RequestBodies          map[string]RequestBodyOrReference
	Headers                map[string]HeaderOrReference
	SecuritySchemes        map[string]SecuritySchemeOrReference
	Links                  map[string]LinkOrReference
	Callbacks              map[string]CallbackOrReference
	SpecificationExtension map[string]*hcl.Any
}

func NewComponents(c *hcl.Components) *Components {
	if c == nil {
		return nil
	}
	comp := &Components{
		SpecificationExtension: c.SpecificationExtension,
	}
	if c.Schemas != nil {
		comp.Schemas = make(map[string]SchemaOrReference)
		for k, v := range c.Schemas {
			comp.Schemas[k] = NewSchemaOrReference(v)
		}
	}
	if c.Responses != nil {
		comp.Responses = make(map[string]ResponseOrReference)
		for k, v := range c.Responses {
			comp.Responses[k] = NewReponseOrReference(v)
		}
	}
	if c.Parameters != nil {
		comp.Parameters = make(map[string]ParameterOrReference)
		for k, v := range c.Parameters {
			comp.Parameters[k] = NewParameterOrReference(v)
		}
	}
	if c.Examples != nil {
		comp.Examples = make(map[string]ExampleOrReference)
		for k, v := range c.Examples {
			comp.Examples[k] = NewExampleOrReference(v)
		}
	}
	if c.RequestBodies != nil {
		comp.RequestBodies = make(map[string]RequestBodyOrReference)
		for k, v := range c.RequestBodies {
			comp.RequestBodies[k] = NewRequestBodyOrReference(v)
		}
	}
	if c.Headers != nil {
		comp.Headers = make(map[string]HeaderOrReference)
		for k, v := range c.Headers {
			comp.Headers[k] = NewHeaderOrReference(v)
		}
	}
	if c.SecuritySchemes != nil {
		comp.SecuritySchemes = make(map[string]SecuritySchemeOrReference)
		for k, v := range c.SecuritySchemes {
			comp.SecuritySchemes[k] = NewSecuritySchemeOrReference(v)
		}
	}
	if c.Links != nil {
		comp.Links = make(map[string]LinkOrReference)
		for k, v := range c.Links {
			comp.Links[k] = NewLinkOrReference(v)
		}
	}
	if c.Callbacks != nil {
		comp.Callbacks = make(map[string]CallbackOrReference)
		for k, v := range c.Callbacks {
			comp.Callbacks[k] = NewCallbackOrReference(v)
		}
	}
	return comp
}

type DefaultType any

func NewDefaultType(a *hcl.DefaultType) DefaultType {
	if a == nil {
		return nil
	}
	if x := a.GetBoolean(); x {
		return x
	} else if x := a.GetNumber(); x != 0 {
		return x
	} else if x := a.GetString_(); x != "" {
		return x
	}
	return nil
}

type Document struct {
	Openapi                string
	Info                   *hcl.Info
	Servers                []*hcl.Server
	Paths                  map[[2]string]*Operation
	Components             *Components
	Security               []*hcl.SecurityRequirement
	Tags                   []*hcl.Tag
	ExternalDocs           *hcl.ExternalDocs
	SpecificationExtension map[string]*hcl.Any
}

func NewDocument(doc *hcl.Document) *Document {
	if doc == nil {
		return nil
	}
	d := &Document{
		Openapi:                doc.Openapi,
		Info:                   doc.Info,
		Servers:                doc.Servers,
		Components:             NewComponents(doc.Components),
		Security:               doc.Security,
		Tags:                   doc.Tags,
		ExternalDocs:           doc.ExternalDocs,
		SpecificationExtension: doc.SpecificationExtension,
	}
	if doc.Paths != nil {
		d.Paths = make(map[[2]string]*Operation)
		for k, v := range doc.Paths {
			pr := NewPathItemOrReference(v)
			for k2, v2 := range pr.(map[string]*Operation) {
				if v2 != nil {
					d.Paths[[2]string{k, k2}] = v2
				}
			}
		}
	}
	return d
}

type Encoding struct {
	ContentType            string
	Headers                map[string]HeaderOrReference
	Style                  string
	Explode                bool
	AllowReserved          bool
	SpecificationExtension map[string]*hcl.Any
}

func NewEncoding(a *hcl.Encoding) *Encoding {
	if a == nil {
		return nil
	}
	e := &Encoding{
		ContentType:            a.ContentType,
		Style:                  a.Style,
		Explode:                a.Explode,
		AllowReserved:          a.AllowReserved,
		SpecificationExtension: a.SpecificationExtension,
	}
	if a.Headers != nil {
		e.Headers = make(map[string]HeaderOrReference)
		for k, v := range a.Headers {
			e.Headers[k] = v
		}
	}
	return e
}

type ExampleOrReference any

func NewExampleOrReference(a *hcl.ExampleOrReference) ExampleOrReference {
	if a == nil {
		return nil
	}
	if x := a.GetReference(); x != nil {
		return x
	}
	return a.GetExample()
}

type Header struct {
	Description            string
	Required               bool
	Deprecated             bool
	AllowEmptyValue        bool
	Style                  string
	Explode                bool
	AllowReserved          bool
	Schema                 SchemaOrReference
	Example                *hcl.Any
	Examples               map[string]ExampleOrReference
	Content                map[string]*MediaType
	SpecificationExtension map[string]*hcl.Any
}

func NewHeader(a *hcl.Header) *Header {
	if a == nil {
		return nil
	}
	h := &Header{
		Description:            a.Description,
		Required:               a.Required,
		Deprecated:             a.Deprecated,
		AllowEmptyValue:        a.AllowEmptyValue,
		Style:                  a.Style,
		Explode:                a.Explode,
		AllowReserved:          a.AllowReserved,
		Schema:                 NewSchemaOrReference(a.Schema),
		Example:                a.Example,
		SpecificationExtension: a.SpecificationExtension,
	}
	if a.Examples != nil {
		h.Examples = make(map[string]ExampleOrReference)
		for k, v := range a.Examples {
			h.Examples[k] = NewExampleOrReference(v)
		}
	}
	if a.Content != nil {
		h.Content = make(map[string]*MediaType)
		for k, v := range a.Content {
			h.Content[k] = NewMediaType(v)
		}
	}
	return h
}

type HeaderOrReference any

func NewHeaderOrReference(a *hcl.HeaderOrReference) HeaderOrReference {
	if a == nil {
		return nil
	}
	if x := a.GetReference(); x != nil {
		return x
	}
	return NewHeader(a.GetHeader())
}

type Link struct {
	OperationRef           string
	OperationId            string
	Parameters             AnyOrExpression
	RequestBody            AnyOrExpression
	Description            string
	Server                 *hcl.Server
	SpecificationExtension map[string]*hcl.Any
}

func NewLink(a *hcl.Link) *Link {
	if a == nil {
		return nil
	}
	return &Link{
		OperationRef:           a.OperationRef,
		OperationId:            a.OperationId,
		Parameters:             NewAnyOrExpression(a.Parameters),
		RequestBody:            NewAnyOrExpression(a.RequestBody),
		Description:            a.Description,
		Server:                 a.Server,
		SpecificationExtension: a.SpecificationExtension,
	}
}

type LinkOrReference any

func NewLinkOrReference(a *hcl.LinkOrReference) LinkOrReference {
	if a == nil {
		return nil
	}
	if x := a.GetReference(); x != nil {
		return x
	}
	return NewLink(a.GetLink())
}

type MediaType struct {
	//Description            string
	Schema                 SchemaOrReference
	Example                *hcl.Any
	Examples               map[string]ExampleOrReference
	Encoding               map[string]*Encoding
	SpecificationExtension map[string]*hcl.Any
}

func NewMediaType(a *hcl.MediaType, description ...string) *MediaType {
	if a == nil {
		return nil
	}
	mt := &MediaType{
		Schema:                 NewSchemaOrReference(a.Schema),
		Example:                a.Example,
		SpecificationExtension: a.SpecificationExtension,
	}
	//if len(description) > 0 {
	//	mt.Description = description[0]
	//}
	if a.Examples != nil {
		mt.Examples = make(map[string]ExampleOrReference)
		for k, v := range a.Examples {
			mt.Examples[k] = v
		}
	}
	if a.Encoding != nil {
		mt.Encoding = make(map[string]*Encoding)
		for k, v := range a.Encoding {
			mt.Encoding[k] = NewEncoding(v)
		}
	}
	return mt
}

type OASArray struct {
	Type          string
	Common        *hcl.OASCommon
	Items         []SchemaOrReference
	MaxItems      int64
	MinItems      int64
	UniqueItems   bool
	Discriminator *hcl.Discriminator
	Example       *hcl.Any
}

func NewOASArray(a *hcl.OASArray) *OASArray {
	if a == nil {
		return nil
	}
	arr := &OASArray{
		Type:          a.Type,
		Common:        a.Common,
		MaxItems:      a.MaxItems,
		MinItems:      a.MinItems,
		UniqueItems:   a.UniqueItems,
		Discriminator: a.Discriminator,
		Example:       a.Example,
	}
	if a.Items != nil {
		arr.Items = make([]SchemaOrReference, len(a.Items))
		for i, v := range a.Items {
			arr.Items[i] = NewSchemaOrReference(v)
		}
	}
	return arr
}

type OASMap struct {
	Type                 string
	Common               *hcl.OASCommon
	AdditionalProperties AdditionalPropertiesItem
}

func NewOASMap(a *hcl.OASMap) *OASMap {
	if a == nil {
		return nil
	}
	return &OASMap{
		Type:                 a.Type,
		Common:               a.Common,
		AdditionalProperties: NewAdditionalPropertiesItem(a.AdditionalProperties),
	}
}

type OASObject struct {
	Type          string
	Common        *hcl.OASCommon
	Properties    map[string]SchemaOrReference
	MaxProperties int64
	MinProperties int64
	Required      []string
	Discriminator *hcl.Discriminator
	Example       *hcl.Any
}

func NewOASObject(a *hcl.OASObject) *OASObject {
	if a == nil {
		return nil
	}
	object := &OASObject{
		Type:          a.Type,
		Common:        a.Common,
		MaxProperties: a.MaxProperties,
		MinProperties: a.MinProperties,
		Required:      a.Required,
		Discriminator: a.Discriminator,
		Example:       a.Example,
	}
	if a.Properties != nil {
		object.Properties = make(map[string]SchemaOrReference)
		for k, v := range a.Properties {
			object.Properties[k] = NewSchemaOrReference(v)
		}
	}
	return object
}

type Operation struct {
	Tags                   []string
	Summary                string
	Description            string
	ExternalDocs           *hcl.ExternalDocs
	OperationId            string
	Parameters             []ParameterOrReference
	RequestBody            RequestBodyOrReference
	Responses              map[string]ResponseOrReference
	Callbacks              map[string]CallbackOrReference
	Deprecated             bool
	Security               []*hcl.SecurityRequirement
	Servers                []*hcl.Server
	SpecificationExtension map[string]*hcl.Any
}

func NewOperation(op *hcl.Operation) *Operation {
	if op == nil {
		return nil
	}
	o := &Operation{
		Tags:                   op.Tags,
		Summary:                op.Summary,
		Description:            op.Description,
		ExternalDocs:           op.ExternalDocs,
		OperationId:            op.OperationId,
		RequestBody:            NewRequestBodyOrReference(op.RequestBody),
		Deprecated:             op.Deprecated,
		Security:               op.Security,
		Servers:                op.Servers,
		SpecificationExtension: op.SpecificationExtension,
	}
	if op.Parameters != nil {
		o.Parameters = make([]ParameterOrReference, len(op.Parameters))
		for i, v := range op.Parameters {
			o.Parameters[i] = NewParameterOrReference(v)
		}
	}
	if op.Responses != nil {
		o.Responses = make(map[string]ResponseOrReference)
		for k, v := range op.Responses {
			o.Responses[k] = NewReponseOrReference(v)
		}
	}
	if op.Callbacks != nil {
		o.Callbacks = make(map[string]CallbackOrReference)
		for k, v := range op.Callbacks {
			o.Callbacks[k] = NewCallbackOrReference(v)
		}
	}
	return o
}

type Parameter struct {
	Name                   string
	In                     string
	Description            string
	Required               bool
	Deprecated             bool
	AllowEmptyValue        bool
	Style                  string
	Explode                bool
	AllowReserved          bool
	Schema                 SchemaOrReference
	Example                *hcl.Any
	Examples               map[string]ExampleOrReference
	Content                map[string]*MediaType
	SpecificationExtension map[string]*hcl.Any
}

func NewParameter(param *hcl.Parameter) *Parameter {
	if param == nil {
		return nil
	}
	p := &Parameter{
		Name:                   param.Name,
		In:                     param.In,
		Description:            param.Description,
		Required:               param.Required,
		Deprecated:             param.Deprecated,
		AllowEmptyValue:        param.AllowEmptyValue,
		Style:                  param.Style,
		Explode:                param.Explode,
		AllowReserved:          param.AllowReserved,
		Schema:                 NewSchemaOrReference(param.Schema),
		Example:                param.Example,
		SpecificationExtension: param.SpecificationExtension,
	}
	if param.Examples != nil {
		p.Examples = make(map[string]ExampleOrReference)
		for k, v := range param.Examples {
			p.Examples[k] = v
		}
	}
	if param.Content != nil {
		p.Content = make(map[string]*MediaType)
		for k, v := range param.Content {
			p.Content[k] = NewMediaType(v)
		}
	}
	return p
}

type ParameterOrReference any

func NewParameterOrReference(param *hcl.ParameterOrReference) ParameterOrReference {
	if param == nil {
		return nil
	}
	if x := param.GetReference(); x != nil {
		return x
	}
	return NewParameter(param.GetParameter())
}

type PathItem struct {
	Operations map[string]*Operation
}

type PathItemOrReference any

func NewPathItemOrReference(pathItem *hcl.PathItem) PathItemOrReference {
	if pathItem == nil {
		return nil
	}
	if pathItem.XRef != "" {
		return &hcl.Reference{
			XRef: pathItem.XRef,
		}
	}
	p := make(map[string]*Operation)
	if pathItem.Get != nil {
		p["get"] = NewOperation(pathItem.Get)
	}
	if pathItem.Put != nil {
		p["put"] = NewOperation(pathItem.Put)
	}
	if pathItem.Post != nil {
		p["post"] = NewOperation(pathItem.Post)
	}
	if pathItem.Delete != nil {
		p["delete"] = NewOperation(pathItem.Delete)
	}
	if pathItem.Options != nil {
		p["options"] = NewOperation(pathItem.Options)
	}
	if pathItem.Head != nil {
		p["head"] = NewOperation(pathItem.Head)
	}
	if pathItem.Patch != nil {
		p["patch"] = NewOperation(pathItem.Patch)
	}
	if pathItem.Trace != nil {
		p["trace"] = NewOperation(pathItem.Trace)
	}
	if (pathItem.Servers != nil && len(pathItem.Servers) > 0) || pathItem.Summary != "" || pathItem.Description != "" || (pathItem.Parameters != nil && len(pathItem.Parameters) > 0) || (pathItem.SpecificationExtension != nil && len(pathItem.SpecificationExtension) > 0) {
		p["common"] = &Operation{
			Summary:                pathItem.Summary,
			Description:            pathItem.Description,
			Servers:                pathItem.Servers,
			SpecificationExtension: pathItem.SpecificationExtension,
		}
		if pathItem.Parameters != nil {
			p["common"].Parameters = make([]ParameterOrReference, len(pathItem.Parameters))
			for i, v := range pathItem.Parameters {
				p["common"].Parameters[i] = NewParameterOrReference(v)
			}
		}
	}

	return p
}

type RequestBody struct {
	Description            string
	Content                map[string]*MediaType
	Required               bool
	SpecificationExtension map[string]*hcl.Any
}

func NewRequestBody(a *hcl.RequestBody) *RequestBody {
	if a == nil {
		return nil
	}
	r := &RequestBody{
		Description:            a.Description,
		Required:               a.Required,
		SpecificationExtension: a.SpecificationExtension,
	}
	if a.Content != nil {
		r.Content = make(map[string]*MediaType)
		for k, v := range a.Content {
			r.Content[k] = NewMediaType(v)
		}
	}
	return r
}

type RequestBodyOrReference any

func NewRequestBodyOrReference(a *hcl.RequestBodyOrReference) RequestBodyOrReference {
	if a == nil {
		return nil
	}

	if x := a.GetReference(); x != nil {
		return x
	}
	return NewRequestBody(a.GetRequestBody())
}

func NewRequestBodyOrReferenceMap2(a *hcl.RequestBodyOrReference) map[[2]string]*MediaType {
	if a == nil {
		return nil
	}

	if x := a.GetReference(); x != nil {
		return map[[2]string]*MediaType{
			{"", x.XRef}: nil,
		}
	}
	x := a.GetRequestBody()
	description := x.GetDescription()
	k2 := ""
	if x.GetRequired() {
		k2 = "required"
	}
	r := make(map[[2]string]*MediaType)
	for k, v := range x.GetContent() {
		r[[2]string{k, k2}] = NewMediaType(v, description)
	}
	return r
}

type Response struct {
	Description            string
	Headers                map[string]HeaderOrReference
	Content                map[string]*MediaType
	Links                  map[string]LinkOrReference
	SpecificationExtension map[string]*hcl.Any
}

func NewReponse(a *hcl.Response) *Response {
	if a == nil {
		return nil
	}
	r := &Response{
		Description:            a.Description,
		SpecificationExtension: a.SpecificationExtension,
	}
	if a.Headers != nil {
		r.Headers = make(map[string]HeaderOrReference)
		for k, v := range a.Headers {
			r.Headers[k] = NewHeaderOrReference(v)
		}
	}
	if a.Content != nil {
		r.Content = make(map[string]*MediaType)
		for k, v := range a.Content {
			r.Content[k] = NewMediaType(v)
		}
	}
	if a.Links != nil {
		r.Links = make(map[string]LinkOrReference)
		for k, v := range a.Links {
			r.Links[k] = NewLinkOrReference(v)
		}
	}
	return r
}

type ResponseOrReference any

func NewReponseOrReference(r *hcl.ResponseOrReference) ResponseOrReference {
	if r == nil {
		return nil
	}
	if x := r.GetReference(); x != nil {
		return x
	}
	return NewReponse(r.GetResponse())
}

type SchemaOrReference any

func NewSchemaOrReference(a *hcl.SchemaOrReference) SchemaOrReference {
	if a == nil {
		return nil
	}

	switch a.Oneof.(type) {
	case *hcl.SchemaOrReference_Reference:
		return a.GetReference()
	case *hcl.SchemaOrReference_Array:
		return NewOASArray(a.GetArray())
	case *hcl.SchemaOrReference_Map:
		return NewOASMap(a.GetMap())
	case *hcl.SchemaOrReference_Object:
		return NewOASObject(a.GetObject())
	case *hcl.SchemaOrReference_OasAllof:
		return NewOASArray(a.GetOasAllof())
	case *hcl.SchemaOrReference_OasAnyof:
		return NewOASArray(a.GetOasAnyof())
	case *hcl.SchemaOrReference_OasOneof:
		return NewOASArray(a.GetOasOneof())
	case *hcl.SchemaOrReference_Boolean:
		return a.GetBoolean()
	case *hcl.SchemaOrReference_Integer:
		return a.GetInteger()
	case *hcl.SchemaOrReference_Number:
		return a.GetNumber()
	case *hcl.SchemaOrReference_String_:
		return a.GetString_()
	case *hcl.SchemaOrReference_Schema:
		return a.GetSchema()
	default:
	}

	return nil
}

type SecuritySchemeOrReference any

func NewSecuritySchemeOrReference(a *hcl.SecuritySchemeOrReference) SecuritySchemeOrReference {
	if a == nil {
		return nil
	}
	if x := a.GetReference(); x != nil {
		return x
	}
	return a.GetSecurityScheme()
}
