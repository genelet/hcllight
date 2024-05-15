
  additionalProperties = false
  schema = "http://json-schema.org/draft-04/schema#"
  id = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  type = "object"
x = "^x-"
  required = ["openapi", "info", "paths"]
  properties {
    security = array(definitions.SecurityRequirement)
    tags = array(definitions.Tag, uniqueItems(true))
    paths = definitions.Paths
    components = definitions.Components
    openapi = string(pattern("^3\\.0\\.\\d(-.+)?$"))
    info = definitions.Info
    externalDocs = definitions.ExternalDocumentation
    servers = array(definitions.Server)
  }
  patternProperties {
    x {}
  }
  definitions {
    Discriminator = object({
      propertyName = string(),
      mapping = map(string())
    }, required("propertyName"))
    SecurityRequirement = map(array(string()))
    Encoding {
      type = "object"
      additionalProperties = false
      properties {
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        })
        style = string(enum("form", "spaceDelimited", "pipeDelimited", "deepObject"))
        explode = boolean()
        allowReserved = boolean(default(false))
        contentType = string()
      }
      patternProperties {
        "^x-" {}
      }
    }
    HeaderParameter {
      description = "Parameter in header"
      properties {
        style {
          default = simple
          enum = ["simple"]
        }
        in {
          enum = ["header"]
        }
      }
    }
    RequestBody {
      required = ["content"]
      additionalProperties = false
      type = "object"
      properties {
        description = string()
        content = map(definitions.MediaType)
        required = boolean(default(false))
      }
      patternProperties {
        "^x-" {}
      }
    }
    HTTPSecurityScheme {
      type = "object"
      required = ["scheme", "type"]
      additionalProperties = false
      oneOf = [{
        description = "Bearer",
        properties = {
          scheme = string(pattern("\^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
        }
      }, {
        not = {
          required = ["bearerFormat"]
        },
        description = "Non Bearer",
        properties = {
          scheme = {
            not = string(pattern("\^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
          }
        }
      }]
      properties {
        description = string()
        type = string(enum("http"))
        scheme = string()
        bearerFormat = string()
      }
      patternProperties {
        "^x-" {}
      }
    }
    PasswordOAuthFlow {
      type = "object"
      required = ["tokenUrl", "scopes"]
      additionalProperties = false
      properties {
        tokenUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
      }
      patternProperties {
        "^x-" {}
      }
    }
    XML {
      type = "object"
      additionalProperties = false
      properties {
        name = string()
        namespace = string(format("uri"))
        prefix = string()
        attribute = boolean(default(false))
        wrapped = boolean(default(false))
      }
      patternProperties {
        "^x-" {}
      }
    }
    Example {
      type = "object"
      additionalProperties = false
      properties {
        externalValue = string(format("uri-reference"))
        summary = string()
        description = string()
        value {}
      }
      patternProperties {
        "^x-" {}
      }
    }
    SchemaXORContent {
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
      description = "Schema and content are mutually exclusive, at least one is required"
    }
    Server {
      type = "object"
      required = ["url"]
      additionalProperties = false
      properties {
        url = string()
        description = string()
        variables = map(definitions.ServerVariable)
      }
      patternProperties {
        "^x-" {}
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
        "^[1-5](?:\d{2}|XX)$" {
          oneOf = [definitions.Response, definitions.Reference]
        }
        "^x-" {}
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
    SecurityScheme {
      oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
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
    APIKeySecurityScheme {
      required = ["type", "name", "in"]
      additionalProperties = false
      type = "object"
      properties {
        name = string()
        in = string(enum("header", "query", "cookie"))
        description = string()
        type = string(enum("apiKey"))
      }
      patternProperties {
        "^x-" {}
      }
    }
    Link {
      additionalProperties = false
      not = {
        required = ["operationId", "operationRef"],
        description = "Operation Id and Operation Ref are mutually exclusive"
      }
      type = "object"
      properties {
        parameters = map({})
        description = string()
        server = definitions.Server
        operationId = string()
        operationRef = string()
        requestBody {}
      }
      patternProperties {
        "^x-" {}
      }
    }
    Schema {
      additionalProperties = false
      type = "object"
      properties {
        properties = map({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        pattern = string(format("regex"))
        format = string()
        discriminator = definitions.Discriminator
        minItems = integer(default(0), minimum(0))
        writeOnly = boolean(default(false))
        oneOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        multipleOf = number(minimum(0), exclusiveMinimum(true))
        uniqueItems = boolean(default(false))
        readOnly = boolean(default(false))
        maxLength = integer(minimum(0))
        exclusiveMinimum = boolean(default(false))
        minProperties = integer(default(0), minimum(0))
        minLength = integer(default(0), minimum(0))
        type = string(enum("array", "boolean", "integer", "number", "object", "string"))
        xml = definitions.XML
        externalDocs = definitions.ExternalDocumentation
        allOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        maxProperties = integer(minimum(0))
        anyOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        deprecated = boolean(default(false))
        description = string()
        maximum = number()
        required = array(string(), minItems(1), uniqueItems(true))
        nullable = boolean(default(false))
        maxItems = integer(minimum(0))
        minimum = number()
        exclusiveMaximum = boolean(default(false))
        enum = array({}, minItems(1), uniqueItems(false))
        title = string()
        example {}
        items {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        additionalProperties {
          default = true
          oneOf = [definitions.Schema, definitions.Reference, boolean()]
        }
        default {}
        not {
          oneOf = [definitions.Schema, definitions.Reference]
        }
      }
      patternProperties {
        "^x-" {}
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
        "^x-" {}
      }
    }
    ExternalDocumentation {
      type = "object"
      required = ["url"]
      additionalProperties = false
      properties {
        description = string()
        url = string(format("uri-reference"))
      }
      patternProperties {
        "^x-" {}
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
        style {
          default = simple
          enum = ["matrix", "label", "simple"]
        }
        required {
          enum = [true]
        }
        in {
          enum = ["path"]
        }
      }
    }
    Response {
      type = "object"
      required = ["description"]
      additionalProperties = false
      properties {
        links = map({
          oneOf = [definitions.Link, definitions.Reference]
        })
        description = string()
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        })
        content = map(definitions.MediaType)
      }
      patternProperties {
        "^x-" {}
      }
    }
    Reference {
      type = "object"
      required = ["$ref"]
      patternProperties {
        "^\$ref$" = string(format("uri-reference"))
      }
    }
    License {
      type = "object"
      required = ["name"]
      additionalProperties = false
      properties {
        name = string()
        url = string(format("uri-reference"))
      }
      patternProperties {
        "^x-" {}
      }
    }
    Header {
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      type = "object"
      additionalProperties = false
      properties {
        required = boolean(default(false))
        style = string(default("simple"), enum("simple"))
        allowReserved = boolean(default(false))
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        deprecated = boolean(default(false))
        allowEmptyValue = boolean(default(false))
        explode = boolean()
        description = string()
        content {
          type = "object"
          maxProperties = 1
          minProperties = 1
          additionalProperties = definitions.MediaType
        }
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        example {}
      }
      patternProperties {
        "^x-" {}
      }
    }
    Paths {
      type = "object"
      additionalProperties = false
      patternProperties {
        "^\/" = definitions.PathItem
        "^x-" {}
      }
    }
    Info {
      type = "object"
      required = ["title", "version"]
      additionalProperties = false
      properties {
        description = string()
        termsOfService = string(format("uri-reference"))
        contact = definitions.Contact
        license = definitions.License
        version = string()
        title = string()
      }
      patternProperties {
        "^x-" {}
      }
    }
    ServerVariable {
      type = "object"
      required = ["default"]
      additionalProperties = false
      properties {
        description = string()
        enum = array(string())
        default = string()
      }
      patternProperties {
        "^x-" {}
      }
    }
    Components {
      type = "object"
      additionalProperties = false
      properties {
        requestBodies {
          type = "object"
          patternProperties {
            "^[a-zA-Z0-9\.\-_]+$" {
              oneOf = [definitions.Reference, definitions.RequestBody]
            }
          }
        }
        links {
          type = "object"
          patternProperties {
            "^[a-zA-Z0-9\.\-_]+$" {
              oneOf = [definitions.Reference, definitions.Link]
            }
          }
        }
        callbacks {
          type = "object"
          patternProperties {
            "^[a-zA-Z0-9\.\-_]+$" {
              oneOf = [definitions.Reference, definitions.Callback]
            }
          }
        }
        headers {
          type = "object"
          patternProperties {
            "^[a-zA-Z0-9\.\-_]+$" {
              oneOf = [definitions.Reference, definitions.Header]
            }
          }
        }
        securitySchemes {
          type = "object"
          patternProperties {
            "^[a-zA-Z0-9\.\-_]+$" {
              oneOf = [definitions.Reference, definitions.SecurityScheme]
            }
          }
        }
        schemas {
          type = "object"
          patternProperties {
            "^[a-zA-Z0-9\.\-_]+$" {
              oneOf = [definitions.Schema, definitions.Reference]
            }
          }
        }
        responses {
          type = "object"
          patternProperties {
            "^[a-zA-Z0-9\.\-_]+$" {
              oneOf = [definitions.Reference, definitions.Response]
            }
          }
        }
        parameters {
          type = "object"
          patternProperties {
            "^[a-zA-Z0-9\.\-_]+$" {
              oneOf = [definitions.Reference, definitions.Parameter]
            }
          }
        }
        examples {
          type = "object"
          patternProperties {
            "^[a-zA-Z0-9\.\-_]+$" {
              oneOf = [definitions.Reference, definitions.Example]
            }
          }
        }
      }
      patternProperties {
        "^x-" {}
      }
    }
    MediaType {
      additionalProperties = false
      allOf = [definitions.ExampleXORExamples]
      type = "object"
      properties {
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        encoding = map(definitions.Encoding)
        example {}
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
      }
      patternProperties {
        "^x-" {}
      }
    }
    Operation {
      required = ["responses"]
      additionalProperties = false
      type = "object"
      properties {
        deprecated = boolean(default(false))
        security = array(definitions.SecurityRequirement)
        servers = array(definitions.Server)
        responses = definitions.Responses
        summary = string()
        description = string()
        callbacks = map({
          oneOf = [definitions.Callback, definitions.Reference]
        })
        tags = array(string())
        externalDocs = definitions.ExternalDocumentation
        operationId = string()
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
        requestBody {
          oneOf = [definitions.RequestBody, definitions.Reference]
        }
      }
      patternProperties {
        "^x-" {}
      }
    }
    OAuthFlows {
      type = "object"
      additionalProperties = false
      properties {
        password = definitions.PasswordOAuthFlow
        clientCredentials = definitions.ClientCredentialsFlow
        authorizationCode = definitions.AuthorizationCodeOAuthFlow
        implicit = definitions.ImplicitOAuthFlow
      }
      patternProperties {
        "^x-" {}
      }
    }
    ImplicitOAuthFlow {
      type = "object"
      required = ["authorizationUrl", "scopes"]
      additionalProperties = false
      properties {
        authorizationUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
      }
      patternProperties {
        "^x-" {}
      }
    }
    ClientCredentialsFlow {
      type = "object"
      required = ["tokenUrl", "scopes"]
      additionalProperties = false
      properties {
        tokenUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
      }
      patternProperties {
        "^x-" {}
      }
    }
    Contact {
      type = "object"
      additionalProperties = false
      properties {
        name = string()
        url = string(format("uri-reference"))
        email = string(format("email"))
      }
      patternProperties {
        "^x-" {}
      }
    }
    PathItem {
      type = "object"
      additionalProperties = false
      properties {
        head = definitions.Operation
        options = definitions.Operation
        patch = definitions.Operation
        put = definitions.Operation
        get = definitions.Operation
        servers = array(definitions.Server)
        summary = string()
        "$ref" = string()
        delete = definitions.Operation
        trace = definitions.Operation
        description = string()
        post = definitions.Operation
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
      }
      patternProperties {
        "^x-" {}
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
        in = string()
        allowReserved = boolean(default(false))
        style = string()
        description = string()
        required = boolean(default(false))
        deprecated = boolean(default(false))
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        allowEmptyValue = boolean(default(false))
        explode = boolean()
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        example {}
        content {
          minProperties = 1
          additionalProperties = definitions.MediaType
          type = "object"
          maxProperties = 1
        }
      }
      patternProperties {
        "^x-" {}
      }
    }
    OAuth2SecurityScheme {
      type = "object"
      required = ["type", "flows"]
      additionalProperties = false
      properties {
        type = string(enum("oauth2"))
        flows = definitions.OAuthFlows
        description = string()
      }
      patternProperties {
        "^x-" {}
      }
    }
    OpenIdConnectSecurityScheme {
      type = "object"
      required = ["type", "openIdConnectUrl"]
      additionalProperties = false
      properties {
        type = string(enum("openIdConnect"))
        openIdConnectUrl = string(format("uri-reference"))
        description = string()
      }
      patternProperties {
        "^x-" {}
      }
    }
    AuthorizationCodeOAuthFlow {
      additionalProperties = false
      type = "object"
      required = ["authorizationUrl", "tokenUrl", "scopes"]
      properties {
        authorizationUrl = string(format("uri-reference"))
        tokenUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
      }
      patternProperties {
        "^x-" {}
      }
    }
    Callback {
      type = "object"
      additionalProperties = definitions.PathItem
      patternProperties {
        "^x-" {}
      }
    }
  }
