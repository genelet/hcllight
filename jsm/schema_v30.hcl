
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  type = "object"
  required = ["openapi", "info", "paths"]
  additionalProperties = false
  schema = "http://json-schema.org/draft-04/schema#"
  id = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
  properties {
    servers = array(definitions.Server)
    security = array(definitions.SecurityRequirement)
    tags = array(definitions.Tag, true)
    paths = definitions.Paths
    components = definitions.Components
    openapi = string("^3\.0\.\d(-.+)?$")
    info = definitions.Info
    externalDocs = definitions.ExternalDocumentation
  }
  patternProperties {
    ^x- {}
  }
  definitions {
    Discriminator = object({
      propertyName = string(),
      mapping = map(string())
    }, ["propertyName"])
    SecurityRequirement = map(array(string()))
    Info {
      type = "object"
      required = ["title", "version"]
      additionalProperties = false
      properties {
        description = string()
        termsOfService = string("uri-reference")
        contact = definitions.Contact
        license = definitions.License
        version = string()
        title = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    Components {
      type = "object"
      additionalProperties = false
      properties {
        schemas {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Schema, definitions.Reference]
            }
          }
        }
        parameters {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.Parameter]
            }
          }
        }
        headers {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.Header]
            }
          }
        }
        securitySchemes {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.SecurityScheme]
            }
          }
        }
        links {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.Link]
            }
          }
        }
        responses {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.Response]
            }
          }
        }
        examples {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.Example]
            }
          }
        }
        requestBodies {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.RequestBody]
            }
          }
        }
        callbacks {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.Callback]
            }
          }
        }
      }
      patternProperties {
        ^x- {}
      }
    }
    Schema {
      type = "object"
      additionalProperties = false
      properties {
        nullable = bool(false)
        maxProperties = integer(0)
        maxItems = integer(0)
        maxLength = integer(0)
        anyOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        format = string()
        pattern = string("regex")
        required = array(string(), 1, true)
        discriminator = definitions.Discriminator
        writeOnly = bool(false)
        title = string()
        type = string(["array", "boolean", "integer", "number", "object", "string"])
        description = string()
        deprecated = bool(false)
        multipleOf = number(0, true)
        properties = map({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        readOnly = bool(false)
        externalDocs = definitions.ExternalDocumentation
        exclusiveMaximum = bool(false)
        exclusiveMinimum = bool(false)
        xml = definitions.XML
        maximum = number()
        allOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        minItems = integer(0, 0)
        minLength = integer(0, 0)
        enum = array({}, 1, false)
        minimum = number()
        minProperties = integer(0, 0)
        uniqueItems = bool(false)
        oneOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        additionalProperties {
          default = true
          oneOf = [definitions.Schema, definitions.Reference, bool()]
        }
        default {}
        not {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        items {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        example {}
      }
      patternProperties {
        ^x- {}
      }
    }
    MediaType {
      type = "object"
      additionalProperties = false
      allOf = [definitions.ExampleXORExamples]
      properties {
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        encoding = map(definitions.Encoding)
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        example {}
      }
      patternProperties {
        ^x- {}
      }
    }
    Header {
      additionalProperties = false
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      type = "object"
      properties {
        allowEmptyValue = bool(false)
        allowReserved = bool(false)
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        description = string()
        style = string(["simple"], "simple")
        explode = bool()
        required = bool(false)
        deprecated = bool(false)
        example {}
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        content {
          minProperties = 1
          additionalProperties = definitions.MediaType
          type = "object"
          maxProperties = 1
        }
      }
      patternProperties {
        ^x- {}
      }
    }
    ExampleXORExamples {
      not = {
        required = ["example", "examples"]
      }
      description = "Example and examples are mutually exclusive"
    }
    PathParameter {
      required = ["required"]
      description = "Parameter in path"
      properties {
        in {
          enum = ["path"]
        }
        style {
          default = simple
          enum = ["matrix", "label", "simple"]
        }
        required {
          enum = [true]
        }
      }
    }
    PasswordOAuthFlow {
      required = ["tokenUrl", "scopes"]
      additionalProperties = false
      type = "object"
      properties {
        tokenUrl = string("uri-reference")
        refreshUrl = string("uri-reference")
        scopes = map(string())
      }
      patternProperties {
        ^x- {}
      }
    }
    License {
      type = "object"
      required = ["name"]
      additionalProperties = false
      properties {
        name = string()
        url = string("uri-reference")
      }
      patternProperties {
        ^x- {}
      }
    }
    Paths {
      type = "object"
      additionalProperties = false
      patternProperties {
        ^\/ = definitions.PathItem
        ^x- {}
      }
    }
    OAuthFlows {
      type = "object"
      additionalProperties = false
      properties {
        implicit = definitions.ImplicitOAuthFlow
        password = definitions.PasswordOAuthFlow
        clientCredentials = definitions.ClientCredentialsFlow
        authorizationCode = definitions.AuthorizationCodeOAuthFlow
      }
      patternProperties {
        ^x- {}
      }
    }
    Encoding {
      type = "object"
      additionalProperties = false
      properties {
        explode = bool()
        allowReserved = bool(false)
        contentType = string()
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        })
        style = string(["form", "spaceDelimited", "pipeDelimited", "deepObject"])
      }
      patternProperties {
        ^x- {}
      }
    }
    Example {
      type = "object"
      additionalProperties = false
      properties {
        description = string()
        externalValue = string("uri-reference")
        summary = string()
        value {}
      }
      patternProperties {
        ^x- {}
      }
    }
    PathItem {
      additionalProperties = false
      type = "object"
      properties {
        put = definitions.Operation
        trace = definitions.Operation
        summary = string()
        get = definitions.Operation
        description = string()
        head = definitions.Operation
        delete = definitions.Operation
        servers = array(definitions.Server)
        $ref = string()
        patch = definitions.Operation
        post = definitions.Operation
        options = definitions.Operation
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, true)
      }
      patternProperties {
        ^x- {}
      }
    }
    Responses {
      type = "object"
      minProperties = 1
      additionalProperties = false
      properties {
        default {
          oneOf = [definitions.Response, definitions.Reference]
        }
      }
      patternProperties {
        ^[1-5](?:\d{2}|XX)$ {
          oneOf = [definitions.Response, definitions.Reference]
        }
        ^x- {}
      }
    }
    ExternalDocumentation {
      type = "object"
      required = ["url"]
      additionalProperties = false
      properties {
        description = string()
        url = string("uri-reference")
      }
      patternProperties {
        ^x- {}
      }
    }
    SchemaXORContent {
      description = "Schema and content are mutually exclusive, at least one is required"
      oneOf = [{
        required = ["schema"]
      }, {
        required = ["content"],
        allOf = [{
          not = {
            required = ["style"]
          }
        }, {
          not = {
            required = ["explode"]
          }
        }, {
          not = {
            required = ["allowReserved"]
          }
        }, {
          not = {
            required = ["example"]
          }
        }, {
          not = {
            required = ["examples"]
          }
        }],
        description = "Some properties are not allowed if content is present"
      }]
      not = {
        required = ["schema", "content"]
      }
    }
    OpenIdConnectSecurityScheme {
      required = ["type", "openIdConnectUrl"]
      additionalProperties = false
      type = "object"
      properties {
        type = string(["openIdConnect"])
        openIdConnectUrl = string("uri-reference")
        description = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    ImplicitOAuthFlow {
      additionalProperties = false
      type = "object"
      required = ["authorizationUrl", "scopes"]
      properties {
        authorizationUrl = string("uri-reference")
        refreshUrl = string("uri-reference")
        scopes = map(string())
      }
      patternProperties {
        ^x- {}
      }
    }
    Contact {
      type = "object"
      additionalProperties = false
      properties {
        name = string()
        url = string("uri-reference")
        email = string("email")
      }
      patternProperties {
        ^x- {}
      }
    }
    ServerVariable {
      additionalProperties = false
      type = "object"
      required = ["default"]
      properties {
        default = string()
        description = string()
        enum = array(string())
      }
      patternProperties {
        ^x- {}
      }
    }
    Response {
      type = "object"
      required = ["description"]
      additionalProperties = false
      properties {
        content = map(definitions.MediaType)
        links = map({
          oneOf = [definitions.Link, definitions.Reference]
        })
        description = string()
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        })
      }
      patternProperties {
        ^x- {}
      }
    }
    HeaderParameter {
      description = "Parameter in header"
      properties {
        in {
          enum = ["header"]
        }
        style {
          default = simple
          enum = ["simple"]
        }
      }
    }
    APIKeySecurityScheme {
      type = "object"
      required = ["type", "name", "in"]
      additionalProperties = false
      properties {
        type = string(["apiKey"])
        name = string()
        in = string(["header", "query", "cookie"])
        description = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    Parameter {
      type = "object"
      required = ["name", "in"]
      additionalProperties = false
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      oneOf = [definitions.PathParameter, definitions.QueryParameter, definitions.HeaderParameter, definitions.CookieParameter]
      properties {
        name = string()
        required = bool(false)
        style = string()
        explode = bool()
        allowEmptyValue = bool(false)
        allowReserved = bool(false)
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        description = string()
        deprecated = bool(false)
        in = string()
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        content {
          type = "object"
          maxProperties = 1
          minProperties = 1
          additionalProperties = definitions.MediaType
        }
        example {}
      }
      patternProperties {
        ^x- {}
      }
    }
    CookieParameter {
      description = "Parameter in cookie"
      properties {
        in {
          enum = ["cookie"]
        }
        style {
          enum = ["form"]
          default = form
        }
      }
    }
    Reference {
      type = "object"
      required = ["$ref"]
      patternProperties {
        ^\$ref$ = string("uri-reference")
      }
    }
    XML {
      type = "object"
      additionalProperties = false
      properties {
        wrapped = bool(false)
        name = string()
        namespace = string("uri")
        prefix = string()
        attribute = bool(false)
      }
      patternProperties {
        ^x- {}
      }
    }
    Operation {
      type = "object"
      required = ["responses"]
      additionalProperties = false
      properties {
        security = array(definitions.SecurityRequirement)
        servers = array(definitions.Server)
        externalDocs = definitions.ExternalDocumentation
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, true)
        responses = definitions.Responses
        tags = array(string())
        description = string()
        summary = string()
        deprecated = bool(false)
        operationId = string()
        callbacks = map({
          oneOf = [definitions.Callback, definitions.Reference]
        })
        requestBody {
          oneOf = [definitions.RequestBody, definitions.Reference]
        }
      }
      patternProperties {
        ^x- {}
      }
    }
    RequestBody {
      type = "object"
      required = ["content"]
      additionalProperties = false
      properties {
        content = map(definitions.MediaType)
        required = bool(false)
        description = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    SecurityScheme {
      oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
    }
    OAuth2SecurityScheme {
      type = "object"
      required = ["type", "flows"]
      additionalProperties = false
      properties {
        description = string()
        type = string(["oauth2"])
        flows = definitions.OAuthFlows
      }
      patternProperties {
        ^x- {}
      }
    }
    Callback {
      type = "object"
      additionalProperties = definitions.PathItem
      patternProperties {
        ^x- {}
      }
    }
    Server {
      type = "object"
      required = ["url"]
      additionalProperties = false
      properties {
        variables = map(definitions.ServerVariable)
        url = string()
        description = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    Tag {
      type = "object"
      required = ["name"]
      additionalProperties = false
      properties {
        description = string()
        externalDocs = definitions.ExternalDocumentation
        name = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    QueryParameter {
      description = "Parameter in query"
      properties {
        in {
          enum = ["query"]
        }
        style {
          default = form
          enum = ["form", "spaceDelimited", "pipeDelimited", "deepObject"]
        }
      }
    }
    HTTPSecurityScheme {
      additionalProperties = false
      oneOf = [{
        description = "Bearer",
        properties = {
          scheme = string("^[Bb][Ee][Aa][Rr][Ee][Rr]$")
        }
      }, {
        not = {
          required = ["bearerFormat"]
        },
        description = "Non Bearer",
        properties = {
          scheme = {
            not = string("^[Bb][Ee][Aa][Rr][Ee][Rr]$")
          }
        }
      }]
      type = "object"
      required = ["scheme", "type"]
      properties {
        description = string()
        type = string(["http"])
        scheme = string()
        bearerFormat = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    ClientCredentialsFlow {
      type = "object"
      required = ["tokenUrl", "scopes"]
      additionalProperties = false
      properties {
        tokenUrl = string("uri-reference")
        refreshUrl = string("uri-reference")
        scopes = map(string())
      }
      patternProperties {
        ^x- {}
      }
    }
    AuthorizationCodeOAuthFlow {
      type = "object"
      required = ["authorizationUrl", "tokenUrl", "scopes"]
      additionalProperties = false
      properties {
        tokenUrl = string("uri-reference")
        refreshUrl = string("uri-reference")
        scopes = map(string())
        authorizationUrl = string("uri-reference")
      }
      patternProperties {
        ^x- {}
      }
    }
    Link {
      type = "object"
      additionalProperties = false
      not = {
        required = ["operationId", "operationRef"],
        description = "Operation Id and Operation Ref are mutually exclusive"
      }
      properties {
        description = string()
        server = definitions.Server
        operationId = string()
        operationRef = string()
        parameters = map({})
        requestBody {}
      }
      patternProperties {
        ^x- {}
      }
    }
  }
