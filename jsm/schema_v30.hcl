
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  type = "object"
  required = ["openapi", "info", "paths"]
  properties = {
    externalDocs = definitions.ExternalDocumentation,
    servers = array(definitions.Server),
    security = array(definitions.SecurityRequirement),
    tags = array(definitions.Tag, uniqueItems(true)),
    paths = definitions.Paths,
    components = definitions.Components,
    openapi = string(pattern("^3\\.0\\.\\d(-.+)?$")),
    info = definitions.Info
  }
  additionalProperties = false
  schema = "http://json-schema.org/draft-04/schema#"
  id = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
  patternProperties = {
    "^x-" = {}
  }
  definitions {
    SecurityRequirement = map(array(string()))
    Discriminator = object({
      propertyName = string(),
      mapping = map(string())
    }, required("propertyName"))
    ImplicitOAuthFlow {
      type = "object"
      required = ["authorizationUrl", "scopes"]
      properties = {
        authorizationUrl = string(format("uri-reference")),
        refreshUrl = string(format("uri-reference")),
        scopes = map(string())
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    ServerVariable {
      type = "object"
      required = ["default"]
      properties = {
        default = string(),
        description = string(),
        enum = array(string())
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Header {
      type = "object"
      properties = {
        required = boolean(default(false)),
        allowEmptyValue = boolean(default(false)),
        allowReserved = boolean(default(false)),
        deprecated = boolean(default(false)),
        style = string(default("simple"), enum("simple")),
        explode = boolean(),
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        }),
        description = string(),
        content = {
          type = "object",
          maxProperties = 1,
          minProperties = 1,
          additionalProperties = definitions.MediaType
        },
        example = {},
        schema = {
          oneOf = [definitions.Schema, definitions.Reference]
        }
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
    }
    Paths {
      type = "object"
      additionalProperties = false
      patternProperties = {
        "^/" = definitions.PathItem,
        "^x-" = {}
      }
    }
    Tag {
      type = "object"
      required = ["name"]
      properties = {
        externalDocs = definitions.ExternalDocumentation,
        name = string(),
        description = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    SchemaXORContent {
      oneOf = [{
        required = ["schema"]
      }, {
        description = "Some properties are not allowed if content is present",
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
        }]
      }]
      not = {
        required = ["schema", "content"]
      }
      description = "Schema and content are mutually exclusive, at least one is required"
    }
    Parameter {
      type = "object"
      required = ["name", "in"]
      properties = {
        name = string(),
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        }),
        deprecated = boolean(default(false)),
        allowEmptyValue = boolean(default(false)),
        style = string(),
        allowReserved = boolean(default(false)),
        required = boolean(default(false)),
        in = string(),
        description = string(),
        explode = boolean(),
        content = {
          type = "object",
          maxProperties = 1,
          minProperties = 1,
          additionalProperties = definitions.MediaType
        },
        example = {},
        schema = {
          oneOf = [definitions.Schema, definitions.Reference]
        }
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
      oneOf = [definitions.PathParameter, definitions.QueryParameter, definitions.HeaderParameter, definitions.CookieParameter]
    }
    ExternalDocumentation {
      type = "object"
      required = ["url"]
      properties = {
        url = string(format("uri-reference")),
        description = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    CookieParameter {
      properties = {
        style = {
          default = form,
          enum = ["form"]
        },
        in = {
          enum = ["cookie"]
        }
      }
      description = "Parameter in cookie"
    }
    OAuth2SecurityScheme {
      properties = {
        type = string(enum("oauth2")),
        flows = definitions.OAuthFlows,
        description = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      required = ["type", "flows"]
    }
    OAuthFlows {
      type = "object"
      properties = {
        implicit = definitions.ImplicitOAuthFlow,
        password = definitions.PasswordOAuthFlow,
        clientCredentials = definitions.ClientCredentialsFlow,
        authorizationCode = definitions.AuthorizationCodeOAuthFlow
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Link {
      patternProperties = {
        "^x-" = {}
      }
      not = {
        required = ["operationId", "operationRef"],
        description = "Operation Id and Operation Ref are mutually exclusive"
      }
      type = "object"
      properties = {
        operationId = string(),
        operationRef = string(),
        parameters = map({}),
        description = string(),
        server = definitions.Server,
        requestBody = {}
      }
      additionalProperties = false
    }
    Encoding {
      type = "object"
      properties = {
        contentType = string(),
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        }),
        style = string(enum("form", "spaceDelimited", "pipeDelimited", "deepObject")),
        explode = boolean(),
        allowReserved = boolean(default(false))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Contact {
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      properties = {
        name = string(),
        url = string(format("uri-reference")),
        email = string(format("email"))
      }
    }
    Operation {
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      required = ["responses"]
      properties = {
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true)),
        summary = string(),
        security = array(definitions.SecurityRequirement),
        servers = array(definitions.Server),
        externalDocs = definitions.ExternalDocumentation,
        callbacks = map({
          oneOf = [definitions.Callback, definitions.Reference]
        }),
        deprecated = boolean(default(false)),
        tags = array(string()),
        operationId = string(),
        description = string(),
        responses = definitions.Responses,
        requestBody = {
          oneOf = [definitions.RequestBody, definitions.Reference]
        }
      }
    }
    QueryParameter {
      description = "Parameter in query"
      properties = {
        in = {
          enum = ["query"]
        },
        style = {
          default = form,
          enum = ["form", "spaceDelimited", "pipeDelimited", "deepObject"]
        }
      }
    }
    Info {
      type = "object"
      required = ["title", "version"]
      properties = {
        description = string(),
        termsOfService = string(format("uri-reference")),
        contact = definitions.Contact,
        license = definitions.License,
        version = string(),
        title = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    MediaType {
      type = "object"
      properties = {
        encoding = map(definitions.Encoding),
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        }),
        schema = {
          oneOf = [definitions.Schema, definitions.Reference]
        },
        example = {}
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      allOf = [definitions.ExampleXORExamples]
    }
    PathItem {
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      properties = {
        patch = definitions.Operation,
        delete = definitions.Operation,
        options = definitions.Operation,
        description = string(),
        head = definitions.Operation,
        put = definitions.Operation,
        post = definitions.Operation,
        "$ref" = string(),
        trace = definitions.Operation,
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true)),
        summary = string(),
        get = definitions.Operation,
        servers = array(definitions.Server)
      }
    }
    Callback {
      type = "object"
      additionalProperties = definitions.PathItem
      patternProperties = {
        "^x-" = {}
      }
    }
    Components {
      type = "object"
      properties = {
        responses = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Reference, definitions.Response]
            }
          }
        },
        parameters = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Reference, definitions.Parameter]
            }
          }
        },
        links = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Reference, definitions.Link]
            }
          }
        },
        schemas = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Schema, definitions.Reference]
            }
          }
        },
        examples = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Reference, definitions.Example]
            }
          }
        },
        requestBodies = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Reference, definitions.RequestBody]
            }
          }
        },
        headers = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Reference, definitions.Header]
            }
          }
        },
        securitySchemes = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Reference, definitions.SecurityScheme]
            }
          }
        },
        callbacks = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Reference, definitions.Callback]
            }
          }
        }
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Schema {
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      properties = {
        nullable = boolean(default(false)),
        externalDocs = definitions.ExternalDocumentation,
        anyOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        }),
        minimum = number(),
        format = string(),
        xml = definitions.XML,
        uniqueItems = boolean(default(false)),
        writeOnly = boolean(default(false)),
        exclusiveMinimum = boolean(default(false)),
        oneOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        }),
        allOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        }),
        maximum = number(),
        discriminator = definitions.Discriminator,
        minProperties = integer(default(0), minimum(0)),
        minLength = integer(default(0), minimum(0)),
        pattern = string(format("regex")),
        deprecated = boolean(default(false)),
        title = string(),
        required = array(string(), minItems(1), uniqueItems(true)),
        maxItems = integer(minimum(0)),
        properties = map({
          oneOf = [definitions.Schema, definitions.Reference]
        }),
        exclusiveMaximum = boolean(default(false)),
        maxProperties = integer(minimum(0)),
        minItems = integer(default(0), minimum(0)),
        type = string(enum("array", "boolean", "integer", "number", "object", "string")),
        readOnly = boolean(default(false)),
        description = string(),
        maxLength = integer(minimum(0)),
        multipleOf = number(minimum(0), exclusiveMinimum(true)),
        enum = array({}, minItems(1), uniqueItems(false)),
        items = {
          oneOf = [definitions.Schema, definitions.Reference]
        },
        example = {},
        not = {
          oneOf = [definitions.Schema, definitions.Reference]
        },
        default = {},
        additionalProperties = {
          default = true,
          oneOf = [definitions.Schema, definitions.Reference, boolean()]
        }
      }
    }
    XML {
      type = "object"
      properties = {
        wrapped = boolean(default(false)),
        name = string(),
        namespace = string(format("uri")),
        prefix = string(),
        attribute = boolean(default(false))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Response {
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      required = ["description"]
      properties = {
        description = string(),
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        }),
        content = map(definitions.MediaType),
        links = map({
          oneOf = [definitions.Link, definitions.Reference]
        })
      }
    }
    Reference {
      type = "object"
      required = ["$ref"]
      patternProperties = {
        "^\\$ref$" = string(format("uri-reference"))
      }
    }
    License {
      type = "object"
      required = ["name"]
      properties = {
        name = string(),
        url = string(format("uri-reference"))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    ExampleXORExamples {
      not = {
        required = ["example", "examples"]
      }
      description = "Example and examples are mutually exclusive"
    }
    SecurityScheme {
      oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
    }
    APIKeySecurityScheme {
      properties = {
        type = string(enum("apiKey")),
        name = string(),
        in = string(enum("header", "query", "cookie")),
        description = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      required = ["type", "name", "in"]
    }
    PasswordOAuthFlow {
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      required = ["tokenUrl", "scopes"]
      properties = {
        tokenUrl = string(format("uri-reference")),
        refreshUrl = string(format("uri-reference")),
        scopes = map(string())
      }
    }
    Server {
      type = "object"
      required = ["url"]
      properties = {
        url = string(),
        description = string(),
        variables = map(definitions.ServerVariable)
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Example {
      type = "object"
      properties = {
        summary = string(),
        description = string(),
        externalValue = string(format("uri-reference")),
        value = {}
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Responses {
      type = "object"
      minProperties = 1
      properties = {
        default = {
          oneOf = [definitions.Response, definitions.Reference]
        }
      }
      additionalProperties = false
      patternProperties = {
        "^[1-5](?:\\d{2}|XX)$" = {
          oneOf = [definitions.Response, definitions.Reference]
        },
        "^x-" = {}
      }
    }
    HeaderParameter {
      properties = {
        in = {
          enum = ["header"]
        },
        style = {
          default = simple,
          enum = ["simple"]
        }
      }
      description = "Parameter in header"
    }
    HTTPSecurityScheme {
      type = "object"
      required = ["scheme", "type"]
      properties = {
        description = string(),
        type = string(enum("http")),
        scheme = string(),
        bearerFormat = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      oneOf = [{
        properties = {
          scheme = string(pattern("^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
        },
        description = "Bearer"
      }, {
        properties = {
          scheme = {
            not = string(pattern("^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
          }
        },
        not = {
          required = ["bearerFormat"]
        },
        description = "Non Bearer"
      }]
    }
    AuthorizationCodeOAuthFlow {
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      required = ["authorizationUrl", "tokenUrl", "scopes"]
      properties = {
        authorizationUrl = string(format("uri-reference")),
        tokenUrl = string(format("uri-reference")),
        refreshUrl = string(format("uri-reference")),
        scopes = map(string())
      }
    }
    PathParameter {
      properties = {
        in = {
          enum = ["path"]
        },
        style = {
          enum = ["matrix", "label", "simple"],
          default = simple
        },
        required = {
          enum = [true]
        }
      }
      description = "Parameter in path"
      required = ["required"]
    }
    RequestBody {
      type = "object"
      required = ["content"]
      properties = {
        content = map(definitions.MediaType),
        required = boolean(default(false)),
        description = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    OpenIdConnectSecurityScheme {
      type = "object"
      required = ["type", "openIdConnectUrl"]
      properties = {
        type = string(enum("openIdConnect")),
        openIdConnectUrl = string(format("uri-reference")),
        description = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    ClientCredentialsFlow {
      type = "object"
      required = ["tokenUrl", "scopes"]
      properties = {
        refreshUrl = string(format("uri-reference")),
        scopes = map(string()),
        tokenUrl = string(format("uri-reference"))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
  }
