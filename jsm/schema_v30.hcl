
  schema = "http://json-schema.org/draft-04/schema#"
  id = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  type = "object"
  required = ["openapi", "info", "paths"]
  additionalProperties = false
  properties {
    info = definitions.Info
    externalDocs = definitions.ExternalDocumentation
    servers = array(definitions.Server)
    security = array(definitions.SecurityRequirement)
    tags = array(definitions.Tag, uniqueItems(true))
    paths = definitions.Paths
    components = definitions.Components
    openapi = string(pattern("^3\.0\.\d(-.+)?$"))
  }
  patternProperties {
    ^x- {}
  }
  definitions {
    Discriminator = object({
      propertyName = string(),
      mapping = map(string())
    }, required("propertyName"))
    SecurityRequirement = map(array(string()))
    Operation {
      type = "object"
      required = ["responses"]
      additionalProperties = false
      properties {
        security = array(definitions.SecurityRequirement)
        tags = array(string())
        externalDocs = definitions.ExternalDocumentation
        operationId = string()
        callbacks = map({
          oneOf = [definitions.Callback, definitions.Reference]
        })
        responses = definitions.Responses
        description = string()
        deprecated = boolean(default(false))
        servers = array(definitions.Server)
        summary = string()
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
        requestBody {
          oneOf = [definitions.RequestBody, definitions.Reference]
        }
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
    SecurityScheme {
      oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
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
        parameters = map({})
        description = string()
        server = definitions.Server
        requestBody {}
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
        externalValue = string(format("uri-reference"))
        value {}
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
    Parameter {
      additionalProperties = false
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      oneOf = [definitions.PathParameter, definitions.QueryParameter, definitions.HeaderParameter, definitions.CookieParameter]
      type = "object"
      required = ["name", "in"]
      properties {
        explode = boolean()
        in = string()
        deprecated = boolean(default(false))
        allowReserved = boolean(default(false))
        required = boolean(default(false))
        description = string()
        style = string()
        allowEmptyValue = boolean(default(false))
        name = string()
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        content {
          type = "object"
          maxProperties = 1
          minProperties = 1
          additionalProperties = definitions.MediaType
        }
        example {}
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
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
        tokenUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
      }
      patternProperties {
        ^x- {}
      }
    }
    ExampleXORExamples {
      description = "Example and examples are mutually exclusive"
      not = {
        required = ["example", "examples"]
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
    OAuthFlows {
      additionalProperties = false
      type = "object"
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
      additionalProperties = false
      type = "object"
      properties {
        contentType = string()
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        })
        style = string(enum("form", "spaceDelimited", "pipeDelimited", "deepObject"))
        explode = boolean()
        allowReserved = boolean(default(false))
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
    AuthorizationCodeOAuthFlow {
      required = ["authorizationUrl", "tokenUrl", "scopes"]
      additionalProperties = false
      type = "object"
      properties {
        scopes = map(string())
        authorizationUrl = string(format("uri-reference"))
        tokenUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
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
    OpenIdConnectSecurityScheme {
      additionalProperties = false
      type = "object"
      required = ["type", "openIdConnectUrl"]
      properties {
        type = string(enum("openIdConnect"))
        openIdConnectUrl = string(format("uri-reference"))
        description = string()
      }
      patternProperties {
        ^x- {}
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
        ^x- {}
      }
    }
    HTTPSecurityScheme {
      type = "object"
      required = ["scheme", "type"]
      additionalProperties = false
      oneOf = [{
        description = "Bearer",
        properties = {
          scheme = string(pattern("^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
        }
      }, {
        not = {
          required = ["bearerFormat"]
        },
        description = "Non Bearer",
        properties = {
          scheme = {
            not = string(pattern("^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
          }
        }
      }]
      properties {
        scheme = string()
        bearerFormat = string()
        description = string()
        type = string(enum("http"))
      }
      patternProperties {
        ^x- {}
      }
    }
    Info {
      additionalProperties = false
      type = "object"
      required = ["title", "version"]
      properties {
        version = string()
        title = string()
        description = string()
        termsOfService = string(format("uri-reference"))
        contact = definitions.Contact
        license = definitions.License
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
        url = string(format("uri-reference"))
      }
      patternProperties {
        ^x- {}
      }
    }
    Callback {
      additionalProperties = definitions.PathItem
      type = "object"
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
          default = form
          enum = ["form"]
        }
      }
    }
    ClientCredentialsFlow {
      additionalProperties = false
      type = "object"
      required = ["tokenUrl", "scopes"]
      properties {
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
        tokenUrl = string(format("uri-reference"))
      }
      patternProperties {
        ^x- {}
      }
    }
    Schema {
      type = "object"
      additionalProperties = false
      properties {
        nullable = boolean(default(false))
        allOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        minimum = number()
        minProperties = integer(default(0), minimum(0))
        maxProperties = integer(minimum(0))
        deprecated = boolean(default(false))
        properties = map({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        enum = array({}, minItems(1), uniqueItems(false))
        pattern = string(format("regex"))
        discriminator = definitions.Discriminator
        required = array(string(), minItems(1), uniqueItems(true))
        minLength = integer(default(0), minimum(0))
        maximum = number()
        exclusiveMaximum = boolean(default(false))
        title = string()
        maxLength = integer(minimum(0))
        anyOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        description = string()
        format = string()
        oneOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        externalDocs = definitions.ExternalDocumentation
        exclusiveMinimum = boolean(default(false))
        xml = definitions.XML
        multipleOf = number(minimum(0), exclusiveMinimum(true))
        uniqueItems = boolean(default(false))
        writeOnly = boolean(default(false))
        readOnly = boolean(default(false))
        minItems = integer(default(0), minimum(0))
        maxItems = integer(minimum(0))
        type = string(enum("array", "boolean", "integer", "number", "object", "string"))
        additionalProperties {
          default = true
          oneOf = [definitions.Schema, definitions.Reference, boolean()]
        }
        not {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        items {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        default {}
        example {}
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
    RequestBody {
      type = "object"
      required = ["content"]
      additionalProperties = false
      properties {
        content = map(definitions.MediaType)
        required = boolean(default(false))
        description = string()
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
        url = string(format("uri-reference"))
        email = string(format("email"))
      }
      patternProperties {
        ^x- {}
      }
    }
    Server {
      required = ["url"]
      additionalProperties = false
      type = "object"
      properties {
        url = string()
        description = string()
        variables = map(definitions.ServerVariable)
      }
      patternProperties {
        ^x- {}
      }
    }
    XML {
      type = "object"
      additionalProperties = false
      properties {
        prefix = string()
        attribute = boolean(default(false))
        wrapped = boolean(default(false))
        name = string()
        namespace = string(format("uri"))
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
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        })
        content = map(definitions.MediaType)
        links = map({
          oneOf = [definitions.Link, definitions.Reference]
        })
        description = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    Header {
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      type = "object"
      additionalProperties = false
      properties {
        deprecated = boolean(default(false))
        allowEmptyValue = boolean(default(false))
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        required = boolean(default(false))
        style = string(default("simple"), enum("simple"))
        explode = boolean()
        allowReserved = boolean(default(false))
        description = string()
        example {}
        content {
          additionalProperties = definitions.MediaType
          type = "object"
          maxProperties = 1
          minProperties = 1
        }
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
      }
      patternProperties {
        ^x- {}
      }
    }
    PathItem {
      type = "object"
      additionalProperties = false
      properties {
        delete = definitions.Operation
        servers = array(definitions.Server)
        patch = definitions.Operation
        get = definitions.Operation
        summary = string()
        trace = definitions.Operation
        description = string()
        put = definitions.Operation
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
        $ref = string()
        head = definitions.Operation
        post = definitions.Operation
        options = definitions.Operation
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
        name = string()
        description = string()
        externalDocs = definitions.ExternalDocumentation
      }
      patternProperties {
        ^x- {}
      }
    }
    APIKeySecurityScheme {
      additionalProperties = false
      type = "object"
      required = ["type", "name", "in"]
      properties {
        type = string(enum("apiKey"))
        name = string()
        in = string(enum("header", "query", "cookie"))
        description = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    Reference {
      type = "object"
      required = ["$ref"]
      patternProperties {
        ^\$ref$ = string(format("uri-reference"))
      }
    }
    ServerVariable {
      type = "object"
      required = ["default"]
      additionalProperties = false
      properties {
        enum = array(string())
        default = string()
        description = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    ImplicitOAuthFlow {
      required = ["authorizationUrl", "scopes"]
      additionalProperties = false
      type = "object"
      properties {
        authorizationUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
      }
      patternProperties {
        ^x- {}
      }
    }
  }
