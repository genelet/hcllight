
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
    Example {
      additionalProperties = false
      type = "object"
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
        type = string(enum("http"))
        scheme = string()
        bearerFormat = string()
        description = string()
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
    Schema {
      type = "object"
      additionalProperties = false
      properties {
        writeOnly = boolean(default(false))
        type = string(enum("array", "boolean", "integer", "number", "object", "string"))
        maxLength = integer(minimum(0))
        multipleOf = number(minimum(0), exclusiveMinimum(true))
        maxProperties = integer(minimum(0))
        format = string()
        pattern = string(format("regex"))
        anyOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        exclusiveMaximum = boolean(default(false))
        required = array(string(), minItems(1), uniqueItems(true))
        minimum = number()
        oneOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        allOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        enum = array({}, minItems(1), uniqueItems(false))
        title = string()
        description = string()
        xml = definitions.XML
        uniqueItems = boolean(default(false))
        minLength = integer(default(0), minimum(0))
        properties = map({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        externalDocs = definitions.ExternalDocumentation
        exclusiveMinimum = boolean(default(false))
        nullable = boolean(default(false))
        maxItems = integer(minimum(0))
        deprecated = boolean(default(false))
        maximum = number()
        minItems = integer(default(0), minimum(0))
        discriminator = definitions.Discriminator
        minProperties = integer(default(0), minimum(0))
        readOnly = boolean(default(false))
        additionalProperties {
          oneOf = [definitions.Schema, definitions.Reference, boolean()]
          default = true
        }
        items {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        example {}
        default {}
        not {
          oneOf = [definitions.Schema, definitions.Reference]
        }
      }
      patternProperties {
        ^x- {}
      }
    }
    XML {
      type = "object"
      additionalProperties = false
      properties {
        wrapped = boolean(default(false))
        name = string()
        namespace = string(format("uri"))
        prefix = string()
        attribute = boolean(default(false))
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
    OpenIdConnectSecurityScheme {
      type = "object"
      required = ["type", "openIdConnectUrl"]
      additionalProperties = false
      properties {
        openIdConnectUrl = string(format("uri-reference"))
        description = string()
        type = string(enum("openIdConnect"))
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
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
        authorizationUrl = string(format("uri-reference"))
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
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
        authorizationUrl = string(format("uri-reference"))
        tokenUrl = string(format("uri-reference"))
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
    Server {
      required = ["url"]
      additionalProperties = false
      type = "object"
      properties {
        variables = map(definitions.ServerVariable)
        url = string()
        description = string()
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
    ExampleXORExamples {
      not = {
        required = ["example", "examples"]
      }
      description = "Example and examples are mutually exclusive"
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
    SecurityScheme {
      oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
    }
    APIKeySecurityScheme {
      type = "object"
      required = ["type", "name", "in"]
      additionalProperties = false
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
    Header {
      type = "object"
      additionalProperties = false
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      properties {
        deprecated = boolean(default(false))
        explode = boolean()
        allowReserved = boolean(default(false))
        description = string()
        allowEmptyValue = boolean(default(false))
        style = string(default("simple"), enum("simple"))
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        required = boolean(default(false))
        example {}
        content {
          type = "object"
          maxProperties = 1
          minProperties = 1
          additionalProperties = definitions.MediaType
        }
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
      }
      patternProperties {
        ^x- {}
      }
    }
    Parameter {
      required = ["name", "in"]
      additionalProperties = false
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      oneOf = [definitions.PathParameter, definitions.QueryParameter, definitions.HeaderParameter, definitions.CookieParameter]
      type = "object"
      properties {
        allowEmptyValue = boolean(default(false))
        style = string()
        explode = boolean()
        description = string()
        deprecated = boolean(default(false))
        in = string()
        allowReserved = boolean(default(false))
        required = boolean(default(false))
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        name = string()
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
    OAuth2SecurityScheme {
      type = "object"
      required = ["type", "flows"]
      additionalProperties = false
      properties {
        description = string()
        type = string(enum("oauth2"))
        flows = definitions.OAuthFlows
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
    Info {
      additionalProperties = false
      type = "object"
      required = ["title", "version"]
      properties {
        contact = definitions.Contact
        license = definitions.License
        version = string()
        title = string()
        description = string()
        termsOfService = string(format("uri-reference"))
      }
      patternProperties {
        ^x- {}
      }
    }
    Contact {
      additionalProperties = false
      type = "object"
      properties {
        name = string()
        url = string(format("uri-reference"))
        email = string(format("email"))
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
        head = definitions.Operation
        trace = definitions.Operation
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
        summary = string()
        get = definitions.Operation
        post = definitions.Operation
        description = string()
        servers = array(definitions.Server)
        $ref = string()
        patch = definitions.Operation
        put = definitions.Operation
        options = definitions.Operation
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
          default = form
          enum = ["form"]
        }
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
    PathParameter {
      description = "Parameter in path"
      required = ["required"]
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
    QueryParameter {
      description = "Parameter in query"
      properties {
        in {
          enum = ["query"]
        }
        style {
          enum = ["form", "spaceDelimited", "pipeDelimited", "deepObject"]
          default = form
        }
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
        operationRef = string()
        parameters = map({})
        description = string()
        server = definitions.Server
        operationId = string()
        requestBody {}
      }
      patternProperties {
        ^x- {}
      }
    }
    Components {
      additionalProperties = false
      type = "object"
      properties {
        links {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.Link]
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
        securitySchemes {
          type = "object"
          patternProperties {
            ^[a-zA-Z0-9\.\-_]+$ {
              oneOf = [definitions.Reference, definitions.SecurityScheme]
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
        servers = array(definitions.Server)
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
        responses = definitions.Responses
        tags = array(string())
        summary = string()
        externalDocs = definitions.ExternalDocumentation
        deprecated = boolean(default(false))
        security = array(definitions.SecurityRequirement)
        description = string()
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
    ClientCredentialsFlow {
      required = ["tokenUrl", "scopes"]
      additionalProperties = false
      type = "object"
      properties {
        refreshUrl = string(format("uri-reference"))
        scopes = map(string())
        tokenUrl = string(format("uri-reference"))
      }
      patternProperties {
        ^x- {}
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
    ExternalDocumentation {
      type = "object"
      required = ["url"]
      additionalProperties = false
      properties {
        url = string(format("uri-reference"))
        description = string()
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
  }
