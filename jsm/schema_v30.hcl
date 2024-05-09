
  type = "object"
  required = ["openapi", "info", "paths"]
  additionalProperties = false
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  properties {
    openapi = string("^3\.0\.\d(-.+)?$")
    info = definitions.Info
    externalDocs = definitions.ExternalDocumentation
    servers = array()
    security = array()
    tags = array(true)
    paths = definitions.Paths
    components = definitions.Components
  }
  patternProperties {
    ^x- {}
  }
  definitions {
    Discriminator = object({
    propertyName = string(),
    mapping = object()
  }, ["propertyName"])
    SecurityRequirement = object()
    XML {
      type = "object"
      additionalProperties = false
      properties {
        namespace = string("uri")
        prefix = string()
        attribute = bool(false)
        wrapped = bool(false)
        name = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    PathItem {
      type = "object"
      additionalProperties = false
      properties {
        servers = array()
        $ref = string()
        parameters = array(true)
        options = definitions.Operation
        summary = string()
        get = definitions.Operation
        post = definitions.Operation
        trace = definitions.Operation
        head = definitions.Operation
        description = string()
        patch = definitions.Operation
        put = definitions.Operation
        delete = definitions.Operation
      }
      patternProperties {
        ^x- {}
      }
    }
    Components {
      type = "object"
      additionalProperties = false
      properties {
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
        schemas {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Schema, definitions.Reference]
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
        parameters {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.Parameter]
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
    Paths {
      type = "object"
      additionalProperties = false
      patternProperties {
        ^\/ = definitions.PathItem
        ^x- {}
      }
    }
    Operation {
      type = "object"
      required = ["responses"]
      additionalProperties = false
      properties {
        security = array()
        servers = array()
        summary = string()
        description = string()
        externalDocs = definitions.ExternalDocumentation
        operationId = string()
        responses = definitions.Responses
        deprecated = bool(false)
        tags = array()
        parameters = array(true)
        callbacks = object()
        requestBody {
          oneOf = [definitions.RequestBody, definitions.Reference]
        }
      }
      patternProperties {
        ^x- {}
      }
    }
    OpenIdConnectSecurityScheme {
      type = "object"
      required = ["type", "openIdConnectUrl"]
      additionalProperties = false
      properties {
        openIdConnectUrl = string("uri-reference")
        description = string()
        type = string(["openIdConnect"])
      }
      patternProperties {
        ^x- {}
      }
    }
    OAuthFlows {
      type = "object"
      additionalProperties = false
      properties {
        clientCredentials = definitions.ClientCredentialsFlow
        authorizationCode = definitions.AuthorizationCodeOAuthFlow
        implicit = definitions.ImplicitOAuthFlow
        password = definitions.PasswordOAuthFlow
      }
      patternProperties {
        ^x- {}
      }
    }
    Example {
      type = "object"
      additionalProperties = false
      properties {
        summary = string()
        description = string()
        externalValue = string("uri-reference")
        value {}
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
        ^x- {}
        ^[1-5](?:\d{2}|XX)$ {
          oneOf = [definitions.Response, definitions.Reference]
        }
      }
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
    HTTPSecurityScheme {
      type = "object"
      required = ["scheme", "type"]
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
      properties {
        scheme = string()
        bearerFormat = string()
        description = string()
        type = string(["http"])
      }
      patternProperties {
        ^x- {}
      }
    }
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
    Response {
      required = ["description"]
      additionalProperties = false
      type = "object"
      properties {
        description = string()
        headers = object()
        content = object()
        links = object()
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
        required = bool(false)
        name = string()
        description = string()
        deprecated = bool(false)
        in = string()
        allowEmptyValue = bool(false)
        style = string()
        explode = bool()
        examples = object()
        allowReserved = bool(false)
        example {}
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        content {
          type = "object"
          maxProperties = 1
          minProperties = 1
          additionalProperties = definitions.MediaType
        }
      }
      patternProperties {
        ^x- {}
      }
    }
    OAuth2SecurityScheme {
      required = ["type", "flows"]
      additionalProperties = false
      type = "object"
      properties {
        flows = definitions.OAuthFlows
        description = string()
        type = string(["oauth2"])
      }
      patternProperties {
        ^x- {}
      }
    }
    PasswordOAuthFlow {
      additionalProperties = false
      type = "object"
      required = ["tokenUrl", "scopes"]
      properties {
        refreshUrl = string("uri-reference")
        scopes = object()
        tokenUrl = string("uri-reference")
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
          enum = ["simple"]
          default = simple
        }
      }
    }
    CookieParameter {
      description = "Parameter in cookie"
      properties {
        in {
          enum = ["cookie"]
        }
        style {
          default = form
          enum = ["form"]
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
    Tag {
      type = "object"
      required = ["name"]
      additionalProperties = false
      properties {
        externalDocs = definitions.ExternalDocumentation
        name = string()
        description = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    ExternalDocumentation {
      additionalProperties = false
      type = "object"
      required = ["url"]
      properties {
        description = string()
        url = string("uri-reference")
      }
      patternProperties {
        ^x- {}
      }
    }
    SchemaXORContent {
      oneOf = [{
        required = ["schema"]
      }, {
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
        description = "Some properties are not allowed if content is present",
        required = ["content"]
      }]
      not = {
        required = ["schema", "content"]
      }
      description = "Schema and content are mutually exclusive, at least one is required"
    }
    RequestBody {
      type = "object"
      required = ["content"]
      additionalProperties = false
      properties {
        description = string()
        content = object()
        required = bool(false)
      }
      patternProperties {
        ^x- {}
      }
    }
    SecurityScheme {
      oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
    }
    ImplicitOAuthFlow {
      type = "object"
      required = ["authorizationUrl", "scopes"]
      additionalProperties = false
      properties {
        authorizationUrl = string("uri-reference")
        refreshUrl = string("uri-reference")
        scopes = object()
      }
      patternProperties {
        ^x- {}
      }
    }
    ClientCredentialsFlow {
      required = ["tokenUrl", "scopes"]
      additionalProperties = false
      type = "object"
      properties {
        tokenUrl = string("uri-reference")
        refreshUrl = string("uri-reference")
        scopes = object()
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
      additionalProperties = false
      type = "object"
      required = ["url"]
      properties {
        url = string()
        description = string()
        variables = object()
      }
      patternProperties {
        ^x- {}
      }
    }
    APIKeySecurityScheme {
      type = "object"
      required = ["type", "name", "in"]
      additionalProperties = false
      properties {
        name = string()
        in = string(["header", "query", "cookie"])
        description = string()
        type = string(["apiKey"])
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
        operationId = string()
        operationRef = string()
        parameters = object()
        description = string()
        server = definitions.Server
        requestBody {}
      }
      patternProperties {
        ^x- {}
      }
    }
    MediaType {
      allOf = [definitions.ExampleXORExamples]
      type = "object"
      additionalProperties = false
      properties {
        examples = object()
        encoding = object()
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
        allowReserved = bool(false)
        description = string()
        explode = bool()
        examples = object()
        required = bool(false)
        deprecated = bool(false)
        allowEmptyValue = bool(false)
        style = string(["simple"], "simple")
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        example {}
        content {
          maxProperties = 1
          minProperties = 1
          additionalProperties = definitions.MediaType
          type = "object"
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
    ServerVariable {
      additionalProperties = false
      type = "object"
      required = ["default"]
      properties {
        default = string()
        description = string()
        enum = array()
      }
      patternProperties {
        ^x- {}
      }
    }
    Schema {
      type = "object"
      additionalProperties = false
      properties {
        xml = definitions.XML
        required = array(1, true)
        maxLength = integer()
        properties = object()
        minProperties = integer(0, )
        maximum = number()
        exclusiveMinimum = bool(false)
        description = string()
        oneOf = array()
        pattern = string("regex")
        uniqueItems = bool(false)
        readOnly = bool(false)
        maxItems = integer()
        minItems = integer(0, )
        nullable = bool(false)
        externalDocs = definitions.ExternalDocumentation
        allOf = array()
        title = string()
        type = string(["array", "boolean", "integer", "number", "object", "string"])
        discriminator = definitions.Discriminator
        deprecated = bool(false)
        enum = array(1, false)
        exclusiveMaximum = bool(false)
        multipleOf = number(, true)
        format = string()
        anyOf = array()
        maxProperties = integer()
        minLength = integer(0, )
        writeOnly = bool(false)
        minimum = number()
        items {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        default {}
        not {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        example {}
        additionalProperties {
          default = true
          oneOf = [definitions.Schema, definitions.Reference, bool()]
        }
      }
      patternProperties {
        ^x- {}
      }
    }
    AuthorizationCodeOAuthFlow {
      required = ["authorizationUrl", "tokenUrl", "scopes"]
      additionalProperties = false
      type = "object"
      properties {
        scopes = object()
        authorizationUrl = string("uri-reference")
        tokenUrl = string("uri-reference")
        refreshUrl = string("uri-reference")
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
        headers = object()
        style = string(["form", "spaceDelimited", "pipeDelimited", "deepObject"])
      }
      patternProperties {
        ^x- {}
      }
    }
  }
