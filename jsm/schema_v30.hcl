
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  type = "object"
  required = ["openapi", "info", "paths"]
  additionalProperties = false
  schema = "http://json-schema.org/draft-04/schema#"
  id = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
  properties {
    security = array(definitions.SecurityRequirement)
    tags = array(definitions.Tag, uniqueItems(true))
    paths = definitions.Paths
    components = definitions.Components
    openapi = string(pattern("^3\.0\.\d(-.+)?$"))
    info = definitions.Info
    externalDocs = definitions.ExternalDocumentation
    servers = array(definitions.Server)
  }
  patternProperties {
    ^x- {}
  }
  definitions {
    SecurityRequirement = map(array(string()))
    Discriminator = object({
      propertyName = string(),
      mapping = map(string())
    }, required("propertyName"))
    Info {
      type = "object"
      required = ["title", "version"]
      additionalProperties = false
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
    Parameter {
      required = ["name", "in"]
      additionalProperties = false
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      oneOf = [definitions.PathParameter, definitions.QueryParameter, definitions.HeaderParameter, definitions.CookieParameter]
      type = "object"
      properties {
        deprecated = boolean(default(false))
        style = string()
        explode = boolean()
        allowReserved = boolean(default(false))
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        allowEmptyValue = boolean(default(false))
        in = string()
        required = boolean(default(false))
        name = string()
        description = string()
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        content {
          maxProperties = 1
          minProperties = 1
          additionalProperties = definitions.MediaType
          type = "object"
        }
        example {}
      }
      patternProperties {
        ^x- {}
      }
    }
    HTTPSecurityScheme {
      oneOf = [{
        description = "Bearer",
        properties = {
          scheme = string(pattern("^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
        }
      }, {
        description = "Non Bearer",
        not = {
          required = ["bearerFormat"]
        },
        properties = {
          scheme = {
            not = string(pattern("^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
          }
        }
      }]
      type = "object"
      required = ["scheme", "type"]
      additionalProperties = false
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
    Example {
      type = "object"
      additionalProperties = false
      properties {
        description = string()
        externalValue = string(format("uri-reference"))
        summary = string()
        value {}
      }
      patternProperties {
        ^x- {}
      }
    }
    Tag {
      additionalProperties = false
      type = "object"
      required = ["name"]
      properties {
        externalDocs = definitions.ExternalDocumentation
        name = string()
        description = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    SecurityScheme {
      oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
    }
    Operation {
      required = ["responses"]
      additionalProperties = false
      type = "object"
      properties {
        description = string()
        responses = definitions.Responses
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
        callbacks = map({
          oneOf = [definitions.Callback, definitions.Reference]
        })
        security = array(definitions.SecurityRequirement)
        tags = array(string())
        summary = string()
        operationId = string()
        externalDocs = definitions.ExternalDocumentation
        deprecated = boolean(default(false))
        servers = array(definitions.Server)
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
        description = string()
        content = map(definitions.MediaType)
        required = boolean(default(false))
      }
      patternProperties {
        ^x- {}
      }
    }
    OAuth2SecurityScheme {
      type = "object"
      required = ["type", "flows"]
      additionalProperties = false
      properties {
        flows = definitions.OAuthFlows
        description = string()
        type = string(enum("oauth2"))
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
        ^x- {}
      }
    }
    AuthorizationCodeOAuthFlow {
      type = "object"
      required = ["authorizationUrl", "tokenUrl", "scopes"]
      additionalProperties = false
      properties {
        tokenUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
        authorizationUrl = string(format("uri-reference"))
      }
      patternProperties {
        ^x- {}
      }
    }
    Components {
      type = "object"
      additionalProperties = false
      properties {
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
        parameters {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.Parameter]
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
        headers {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.Header]
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
        ^x- {}
      }
    }
    Header {
      type = "object"
      additionalProperties = false
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      properties {
        allowReserved = boolean(default(false))
        explode = boolean()
        description = string()
        deprecated = boolean(default(false))
        allowEmptyValue = boolean(default(false))
        style = string(default("simple"), enum("simple"))
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        required = boolean(default(false))
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
    Paths {
      type = "object"
      additionalProperties = false
      patternProperties {
        ^\/ = definitions.PathItem
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
      type = "object"
      required = ["tokenUrl", "scopes"]
      additionalProperties = false
      properties {
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
        tokenUrl = string(format("uri-reference"))
      }
      patternProperties {
        ^x- {}
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
        ^x- {}
      }
    }
    PasswordOAuthFlow {
      additionalProperties = false
      type = "object"
      required = ["tokenUrl", "scopes"]
      properties {
        scopes = map(string())
        tokenUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
      }
      patternProperties {
        ^x- {}
      }
    }
    Encoding {
      type = "object"
      additionalProperties = false
      properties {
        explode = boolean()
        allowReserved = boolean(default(false))
        contentType = string()
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        })
        style = string(enum("form", "spaceDelimited", "pipeDelimited", "deepObject"))
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
    Schema {
      type = "object"
      additionalProperties = false
      properties {
        maxProperties = integer(minimum(0))
        description = string()
        minItems = integer(default(0), minimum(0))
        writeOnly = boolean(default(false))
        uniqueItems = boolean(default(false))
        minLength = integer(default(0), minimum(0))
        minProperties = integer(default(0), minimum(0))
        nullable = boolean(default(false))
        externalDocs = definitions.ExternalDocumentation
        required = array(string(), minItems(1), uniqueItems(true))
        discriminator = definitions.Discriminator
        deprecated = boolean(default(false))
        properties = map({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        format = string()
        maxItems = integer(minimum(0))
        title = string()
        maximum = number()
        maxLength = integer(minimum(0))
        readOnly = boolean(default(false))
        multipleOf = number(minimum(0), exclusiveMinimum(true))
        type = string(enum("array", "boolean", "integer", "number", "object", "string"))
        exclusiveMaximum = boolean(default(false))
        xml = definitions.XML
        exclusiveMinimum = boolean(default(false))
        minimum = number()
        allOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        oneOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        enum = array({}, minItems(1), uniqueItems(false))
        pattern = string(format("regex"))
        anyOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        items {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        example {}
        default {}
        additionalProperties {
          oneOf = [definitions.Schema, definitions.Reference, boolean()]
          default = true
        }
        not {
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
        get = definitions.Operation
        put = definitions.Operation
        head = definitions.Operation
        servers = array(definitions.Server)
        delete = definitions.Operation
        options = definitions.Operation
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
        $ref = string()
        summary = string()
        description = string()
        post = definitions.Operation
        patch = definitions.Operation
        trace = definitions.Operation
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
    APIKeySecurityScheme {
      type = "object"
      required = ["type", "name", "in"]
      additionalProperties = false
      properties {
        name = string()
        in = string(enum("header", "query", "cookie"))
        description = string()
        type = string(enum("apiKey"))
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
    ServerVariable {
      type = "object"
      required = ["default"]
      additionalProperties = false
      properties {
        default = string()
        description = string()
        enum = array(string())
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
        encoding = map(definitions.Encoding)
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        example {}
      }
      patternProperties {
        ^x- {}
      }
    }
  }
