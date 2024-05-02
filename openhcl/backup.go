package openhcl

/*
import (
	"github.com/genelet/hcllight/internal/hcl"
	"google.golang.org/protobuf/runtime/protoimpl"
)

func callbacksOrReferenceToOpen(calls map[string]*hcl.CallbacksOrReference) map[[2]string]*PathItem {
	if calls == nil {
		return nil
	}
	openCalls := make(map[[2]string]*PathItem)
	for k, v := range calls {
		if x := v.GetReference(); x != nil {
			openCalls[[2]string{k, x.XRef}] = nil
		} else {
			x := v.GetCallBacks()
			for key, val := range x.Path {
				openCalls[[2]string{k, key}] = hclToOpenPathItem(val)
			}
		}
	}
	return openCalls
}

func linksOrReferenceToOpen(links map[string]*hcl.LinkOrReference) map[[2]string]*hcl.Link {
	if links == nil {
		return nil
	}
	openLinks := make(map[[2]string]*hcl.Link)
	for k, v := range links {
		if x := v.GetReference(); x != nil {
			openLinks[[2]string{k, x.XRef}] = nil
		} else {
			openLinks[[2]string{k, ""}] = v.GetLink()
		}
	}
	return openLinks
}

func securitySchemeOrReferenceToOpen(securitySchemes map[string]*hcl.SecuritySchemeOrReference) map[[2]string]*hcl.SecurityScheme {
	if securitySchemes == nil {
		return nil
	}
	openSecuritySchemes := make(map[[2]string]*hcl.SecurityScheme)
	for k, v := range securitySchemes {
		if x := v.GetReference(); x != nil {
			openSecuritySchemes[[2]string{k, x.XRef}] = nil
		} else {
			openSecuritySchemes[[2]string{k, ""}] = v.GetSecurityScheme()
		}
	}
	return openSecuritySchemes
}

func exampleOrReferenceToOpen(examples map[string]*hcl.ExampleOrReference) map[[2]string]*hcl.Example {
	if examples == nil {
		return nil
	}
	openExamples := make(map[[2]string]*hcl.Example)
	for k, v := range examples {
		if x := v.GetReference(); x != nil {
			openExamples[[2]string{k, x.XRef}] = nil
		} else {
			openExamples[[2]string{k, ""}] = v.GetExample()
		}
	}
	return openExamples
}

func parameterOrReferenceToOpen(parameters map[string]*hcl.ParameterOrReference) map[[2]string]*hcl.Parameter {
	if parameters == nil {
		return nil
	}
	openParameters := make(map[[2]string]*hcl.Parameter)
	for k, v := range parameters {
		if x := v.GetReference(); x != nil {
			openParameters[[2]string{k, x.XRef}] = nil
		} else {
			x := v.GetParameter()
			openParameters[[2]string{k, x.Name}] = x
		}
	}
	return openParameters
}

func pathItemsToOpen(pathItems map[string]*hcl.PathItem) map[[2]string]*hcl.Operation {
	if pathItems == nil {
		return nil
	}
	openPathItems := make(map[[2]string]*hcl.Operation)
	for k, v := range pathItems {
		if v.GetXRef() != "" {
			openPathItems[[2]string{k, v.GetXRef()}] = nil
			continue
		}
		if v.GetTrace() != nil {
			openPathItems[[2]string{k, "trace"}] = v.GetTrace()
		}
		if v.GetPatch() != nil {
			openPathItems[[2]string{k, "patch"}] = v.GetPatch()
		}
		if v.GetHead() != nil {
			openPathItems[[2]string{k, "head"}] = v.GetHead()
		}
		if v.GetOptions() != nil {
			openPathItems[[2]string{k, "options"}] = v.GetOptions()
		}
		if v.GetDelete() != nil {
			openPathItems[[2]string{k, "delete"}] = v.GetDelete()
		}
		if v.GetPost() != nil {
			openPathItems[[2]string{k, "post"}] = v.GetPost()
		}
		if v.GetPut() != nil {
			openPathItems[[2]string{k, "put"}] = v.GetPut()
		}
		if v.GetGet() != nil {
			openPathItems[[2]string{k, "get"}] = v.GetGet()
		}
		if v.GetSummary() != "" || v.GetDescription() != "" || v.GetServers() != nil || v.GetParameters() != nil {
			openPathItems[[2]string{k, "common"}] = &hcl.Operation{
				Summary:     v.GetSummary(),
				Description: v.GetDescription(),
				Servers:     v.GetServers(),
				Parameters:  v.GetParameters(),
			}
		}
	}
	return openPathItems
}

type Components struct {
	Schemas                map[string]*hcl.SchemaOrReference
	Responses              map[[2]string]*hcl.SchemaOrReference
	Headers                map[string]*hcl.SchemaOrReference
	Parameters             map[[2]string]*hcl.Parameter
	RequestBodies          map[[2]string]*hcl.SchemaOrReference
	Examples               map[[2]string]*hcl.Example
	SecuritySchemes        map[[2]string]*hcl.SecurityScheme
	Links                  map[[2]string]*hcl.Link
	Callbacks              map[[2]string]*hcl.CallbackOrReference
	SpecificationExtension map[string]*hcl.Any
}

type Document struct {
	Openapi                string
	Info                   *hcl.Info
	Servers                []*hcl.Server
	PathItems              map[[2]string]*hcl.Operation
	Components             *Components
	Security               []*hcl.SecurityRequirement
	Tags                   []*hcl.Tag
	ExternalDocs           *hcl.ExternalDocs
	SpecificationExtension []map[string]*hcl.Any
}

type Operation struct {
	Tags                   []string
	Summary                string
	Description            string
	ExternalDocs           *ExternalDocs
	OperationId            string
	Parameters             []*ParameterOrReference
	RequestBody            *MediaTypesOrReference
	Responses              map[string]*MediaTypesOrReference
	Headers                map[string]*MediaTypesOrReference
	Calls                  map[string]*CallbacksOrReference
	Deprecated             bool
	Security               []*SecurityRequirement
	Servers                []*Server
	SpecificationExtension map[string]*Any
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
	Schema                 *SchemaOrReference
	Example                *Any
	Examples               map[string]*ExampleOrReference
	Content                map[string]*SchemaOrReference
	SpecificationExtension map[string]*Any
}

type ParameterOrReference any

type PathItem struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	XRef                   string
	Summary                string
	Description            string
	Get                    *Operation
	Put                    *Operation
	Post                   *Operation
	Delete                 *Operation
	Options                *Operation
	Head                   *Operation
	Patch                  *Operation
	Trace                  *Operation
	Servers                []*Server
	Parameters             []*ParameterOrReference
	SpecificationExtension map[string]*Any
}

type Reference struct {
	XRef        string
	Summary     string
	Description string
}

type MediaTypes struct {
	Content map[string]*SchemaOrReference
}

type MediaTypesOrReference any

type OASString struct {
	Format    string
	Required  bool
	MinLength int64
	MaxLength int64
	Pattern   string
	Default   string
}

type OASNumber struct {
	Format           string
	Required         bool
	Maximum          float64
	Minimum          float64
	MultipleOf       float64
	ExclusiveMaximum bool
	ExclusiveMinimum bool
	Default          float64
}

type OASInteger struct {
	Format           string
	Required         bool
	Maximum          int64
	Minimum          int64
	MultipleOf       int64
	ExclusiveMaximum bool
	ExclusiveMinimum bool
	Default          int64
}

type OASBoolean struct {
	Required bool
	Default  bool
}

type OASObject struct {
	Properties map[string]*SchemaOrReference
}

type OASArray struct {
	Items []*SchemaOrReference
}

type SchemaOrReference any

type SecurityRequirement struct {
	AdditionalProperties map[string]*StringArray
}

type SecuritySchemeOrReference any

type Server struct {
	Url                    string
	Description            string
	Variables              map[string]*ServerVariable
	SpecificationExtension map[string]*Any
}
*/
