
  id = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  type = "object"
  required = ["openapi", "info", "paths"]
  additionalProperties = false
  schema = "http://json-schema.org/draft-04/schema#"
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
    SecurityRequirement = map(array(string()))
    Discriminator = object({
      propertyName = string(),
      mapping = map(string())
    }, required("propertyName"))
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
    XML {
      additionalProperties = false
      type = "object"
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
    Parameter {
      required = ["name", "in"]
      additionalProperties = false
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      oneOf = [definitions.PathParameter, definitions.QueryParameter, definitions.HeaderParameter, definitions.CookieParameter]
      type = "object"
      properties {
        allowReserved = boolean(default(false))
        style = string()
        required = boolean(default(false))
        description = string()
        deprecated = boolean(default(false))
        in = string()
        explode = boolean()
        name = string()
        allowEmptyValue = boolean(default(false))
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
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
    PasswordOAuthFlow {
      type = "object"
      required = ["tokenUrl", "scopes"]
      additionalProperties = false
      properties {
        scopes = map(string())
        tokenUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
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
    Response {
      type = "object"
      required = ["description"]
      additionalProperties = false
      properties {
        description = string()
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        })
        content = map(definitions.MediaType)
        links = map({
          oneOf = [definitions.Link, definitions.Reference]
        })
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
    PathParameter {
      required = ["required"]
      description = "Parameter in path"
      properties {
        in {
          enum = ["path"]
        }
        style {
          enum = ["matrix", "label", "simple"]
          default = simple
        }
        required {
          enum = [true]
        }
      }
    }
    RequestBody {
      required = ["content"]
      additionalProperties = false
      type = "object"
      properties {
        required = boolean(default(false))
        description = string()
        content = map(definitions.MediaType)
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
        scopes = map(string())
        tokenUrl = string(format("uri-reference"))
        refreshUrl = string(format("uri-reference"))
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
    Paths {
      type = "object"
      additionalProperties = false
      patternProperties {
        ^\/ = definitions.PathItem
        ^x- {}
      }
    }
    Encoding {
      type = "object"
      additionalProperties = false
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
    Server {
      type = "object"
      required = ["url"]
      additionalProperties = false
      properties {
        description = string()
        variables = map(definitions.ServerVariable)
        url = string()
      }
      patternProperties {
        ^x- {}
      }
    }
    License {
      additionalProperties = false
      type = "object"
      required = ["name"]
      properties {
        name = string()
        url = string(format("uri-reference"))
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
    Contact {
      type = "object"
      additionalProperties = false
      properties {
        email = string(format("email"))
        name = string()
        url = string(format("uri-reference"))
      }
      patternProperties {
        ^x- {}
      }
    }
    PathItem {
      type = "object"
      additionalProperties = false
      properties {
        description = string()
        $ref = string()
        get = definitions.Operation
        trace = definitions.Operation
        head = definitions.Operation
        put = definitions.Operation
        servers = array(definitions.Server)
        options = definitions.Operation
        patch = definitions.Operation
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
        delete = definitions.Operation
        post = definitions.Operation
        summary = string()
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
          enum = ["form", "spaceDelimited", "pipeDelimited", "deepObject"]
          default = form
        }
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
        ^x- {}
      }
    }
    Info {
      type = "object"
      required = ["title", "version"]
      additionalProperties = false
      properties {
        license = definitions.License
        version = string()
        title = string()
        description = string()
        termsOfService = string(format("uri-reference"))
        contact = definitions.Contact
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
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      type = "object"
      additionalProperties = false
      properties {
        style = string(default("simple"), enum("simple"))
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        })
        description = string()
        allowReserved = boolean(default(false))
        explode = boolean()
        required = boolean(default(false))
        deprecated = boolean(default(false))
        allowEmptyValue = boolean(default(false))
        schema {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        example {}
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
    APIKeySecurityScheme {
      type = "object"
      required = ["type", "name", "in"]
      additionalProperties = false
      properties {
        in = string(enum("header", "query", "cookie"))
        description = string()
        type = string(enum("apiKey"))
        name = string()
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
    Operation {
      required = ["responses"]
      additionalProperties = false
      type = "object"
      properties {
        tags = array(string())
        description = string()
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
        responses = definitions.Responses
        security = array(definitions.SecurityRequirement)
        callbacks = map({
          oneOf = [definitions.Callback, definitions.Reference]
        })
        deprecated = boolean(default(false))
        summary = string()
        servers = array(definitions.Server)
        externalDocs = definitions.ExternalDocumentation
        operationId = string()
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
        ^[1-5](?:\d{2}|XX)$ {
          oneOf = [definitions.Response, definitions.Reference]
        }
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
    Schema {
      type = "object"
      additionalProperties = false
      properties {
        deprecated = boolean(default(false))
        minLength = integer(default(0), minimum(0))
        externalDocs = definitions.ExternalDocumentation
        pattern = string(format("regex"))
        oneOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        readOnly = boolean(default(false))
        format = string()
        multipleOf = number(minimum(0), exclusiveMinimum(true))
        required = array(string(), minItems(1), uniqueItems(true))
        title = string()
        maximum = number()
        maxItems = integer(minimum(0))
        anyOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        allOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        exclusiveMinimum = boolean(default(false))
        description = string()
        nullable = boolean(default(false))
        maxLength = integer(minimum(0))
        maxProperties = integer(minimum(0))
        minimum = number()
        uniqueItems = boolean(default(false))
        enum = array({}, minItems(1), uniqueItems(false))
        type = string(enum("array", "boolean", "integer", "number", "object", "string"))
        properties = map({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        discriminator = definitions.Discriminator
        minProperties = integer(default(0), minimum(0))
        exclusiveMaximum = boolean(default(false))
        minItems = integer(default(0), minimum(0))
        xml = definitions.XML
        writeOnly = boolean(default(false))
        example {}
        not {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        items {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        additionalProperties {
          default = true
          oneOf = [definitions.Schema, definitions.Reference, boolean()]
        }
        default {}
      }
      patternProperties {
        ^x- {}
      }
    }
  }
