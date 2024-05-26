
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
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
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
        scopes = map(string()),
        authorizationUrl = string(format("uri-reference")),
        refreshUrl = string(format("uri-reference"))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Info {
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      required = ["title", "version"]
      properties = {
        title = string(),
        description = string(),
        termsOfService = string(format("uri-reference")),
        contact = definitions.Contact,
        license = definitions.License,
        version = string()
      }
      additionalProperties = false
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
    ExternalDocumentation {
      type = "object"
      required = ["url"]
      properties = {
        description = string(),
        url = string(format("uri-reference"))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    CookieParameter {
      properties = {
        in = {
          enum = ["cookie"]
        },
        style = {
          enum = ["form"],
          default = form
        }
      }
      description = "Parameter in cookie"
    }
    APIKeySecurityScheme {
      type = "object"
      required = ["type", "name", "in"]
      properties = {
        in = string(enum("header", "query", "cookie")),
        description = string(),
        type = string(enum("apiKey")),
        name = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    PathItem {
      type = "object"
      properties = {
        options = definitions.Operation,
        head = definitions.Operation,
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true)),
        summary = string(),
        description = string(),
        delete = definitions.Operation,
        patch = definitions.Operation,
        trace = definitions.Operation,
        servers = array(definitions.Server),
        "$ref" = string(),
        get = definitions.Operation,
        put = definitions.Operation,
        post = definitions.Operation
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Operation {
      required = ["responses"]
      properties = {
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true)),
        operationId = string(),
        deprecated = boolean(default(false)),
        servers = array(definitions.Server),
        tags = array(string()),
        description = string(),
        externalDocs = definitions.ExternalDocumentation,
        responses = definitions.Responses,
        callbacks = map({
          oneOf = [definitions.Callback, definitions.Reference]
        }),
        security = array(definitions.SecurityRequirement),
        summary = string(),
        requestBody = {
          oneOf = [definitions.RequestBody, definitions.Reference]
        }
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
    }
    PasswordOAuthFlow {
      properties = {
        tokenUrl = string(format("uri-reference")),
        refreshUrl = string(format("uri-reference")),
        scopes = map(string())
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      required = ["tokenUrl", "scopes"]
    }
    ExampleXORExamples {
      not = {
        required = ["example", "examples"]
      }
      description = "Example and examples are mutually exclusive"
    }
    HTTPSecurityScheme {
      patternProperties = {
        "^x-" = {}
      }
      oneOf = [{
        properties = {
          scheme = string(pattern("^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
        },
        description = "Bearer"
      }, {
        description = "Non Bearer",
        properties = {
          scheme = {
            not = string(pattern("^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
          }
        },
        not = {
          required = ["bearerFormat"]
        }
      }]
      type = "object"
      required = ["scheme", "type"]
      properties = {
        description = string(),
        type = string(enum("http")),
        scheme = string(),
        bearerFormat = string()
      }
      additionalProperties = false
    }
    Link {
      type = "object"
      properties = {
        parameters = map({}),
        description = string(),
        server = definitions.Server,
        operationId = string(),
        operationRef = string(),
        requestBody = {}
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      not = {
        required = ["operationId", "operationRef"],
        description = "Operation Id and Operation Ref are mutually exclusive"
      }
    }
    ServerVariable {
      type = "object"
      required = ["default"]
      properties = {
        enum = array(string()),
        default = string(),
        description = string()
      }
      additionalProperties = false
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
        examples = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Reference, definitions.Example]
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
        },
        schemas = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Schema, definitions.Reference]
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
        links = {
          type = "object",
          patternProperties = {
            "^[a-zA-Z0-9\\.\\-_]+$" = {
              oneOf = [definitions.Reference, definitions.Link]
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
        }
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    PathParameter {
      required = ["required"]
      properties = {
        in = {
          enum = ["path"]
        },
        style = {
          default = simple,
          enum = ["matrix", "label", "simple"]
        },
        required = {
          enum = [true]
        }
      }
      description = "Parameter in path"
    }
    Schema {
      type = "object"
      properties = {
        maxProperties = integer(minimum(0)),
        writeOnly = boolean(default(false)),
        title = string(),
        minimum = number(),
        description = string(),
        properties = map({
          oneOf = [definitions.Schema, definitions.Reference]
        }),
        exclusiveMaximum = boolean(default(false)),
        maximum = number(),
        pattern = string(format("regex")),
        type = string(enum("array", "boolean", "integer", "number", "object", "string")),
        allOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        }),
        maxItems = integer(minimum(0)),
        minProperties = integer(default(0), minimum(0)),
        externalDocs = definitions.ExternalDocumentation,
        enum = array({}, minItems(1), uniqueItems(false)),
        discriminator = definitions.Discriminator,
        xml = definitions.XML,
        minLength = integer(default(0), minimum(0)),
        oneOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        }),
        minItems = integer(default(0), minimum(0)),
        multipleOf = number(minimum(0), exclusiveMinimum(true)),
        format = string(),
        nullable = boolean(default(false)),
        required = array(string(), minItems(1), uniqueItems(true)),
        exclusiveMinimum = boolean(default(false)),
        maxLength = integer(minimum(0)),
        deprecated = boolean(default(false)),
        uniqueItems = boolean(default(false)),
        readOnly = boolean(default(false)),
        anyOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        }),
        items = {
          oneOf = [definitions.Schema, definitions.Reference]
        },
        additionalProperties = {
          default = true,
          oneOf = [definitions.Schema, definitions.Reference, boolean()]
        },
        default = {},
        example = {},
        not = {
          oneOf = [definitions.Schema, definitions.Reference]
        }
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    XML {
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      properties = {
        name = string(),
        namespace = string(format("uri")),
        prefix = string(),
        attribute = boolean(default(false)),
        wrapped = boolean(default(false))
      }
    }
    Response {
      type = "object"
      required = ["description"]
      properties = {
        content = map(definitions.MediaType),
        links = map({
          oneOf = [definitions.Link, definitions.Reference]
        }),
        description = string(),
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        })
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
    AuthorizationCodeOAuthFlow {
      required = ["authorizationUrl", "tokenUrl", "scopes"]
      properties = {
        authorizationUrl = string(format("uri-reference")),
        tokenUrl = string(format("uri-reference")),
        refreshUrl = string(format("uri-reference")),
        scopes = map(string())
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
    }
    ClientCredentialsFlow {
      required = ["tokenUrl", "scopes"]
      properties = {
        tokenUrl = string(format("uri-reference")),
        refreshUrl = string(format("uri-reference")),
        scopes = map(string())
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
    }
    Callback {
      additionalProperties = definitions.PathItem
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
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
    RequestBody {
      type = "object"
      required = ["content"]
      properties = {
        required = boolean(default(false)),
        description = string(),
        content = map(definitions.MediaType)
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Reference {
      type = "object"
      required = ["$ref"]
      patternProperties = {
        "^\\$ref$" = string(format("uri-reference"))
      }
    }
    Contact {
      type = "object"
      properties = {
        url = string(format("uri-reference")),
        email = string(format("email")),
        name = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    License {
      type = "object"
      required = ["name"]
      properties = {
        url = string(format("uri-reference")),
        name = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
    Example {
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
      type = "object"
    }
    Header {
      type = "object"
      properties = {
        required = boolean(default(false)),
        explode = boolean(),
        description = string(),
        deprecated = boolean(default(false)),
        allowEmptyValue = boolean(default(false)),
        style = string(default("simple"), enum("simple")),
        allowReserved = boolean(default(false)),
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        }),
        content = {
          type = "object",
          maxProperties = 1,
          minProperties = 1,
          additionalProperties = definitions.MediaType
        },
        schema = {
          oneOf = [definitions.Schema, definitions.Reference]
        },
        example = {}
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
    }
    Parameter {
      oneOf = [definitions.PathParameter, definitions.QueryParameter, definitions.HeaderParameter, definitions.CookieParameter]
      type = "object"
      required = ["name", "in"]
      properties = {
        required = boolean(default(false)),
        allowReserved = boolean(default(false)),
        description = string(),
        in = string(),
        deprecated = boolean(default(false)),
        allowEmptyValue = boolean(default(false)),
        style = string(),
        explode = boolean(),
        name = string(),
        examples = map({
          oneOf = [definitions.Example, definitions.Reference]
        }),
        content = {
          type = "object",
          maxProperties = 1,
          minProperties = 1,
          additionalProperties = definitions.MediaType
        },
        schema = {
          oneOf = [definitions.Schema, definitions.Reference]
        },
        example = {}
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
    }
    SecurityScheme {
      oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
    }
    OAuth2SecurityScheme {
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      required = ["type", "flows"]
      properties = {
        flows = definitions.OAuthFlows,
        description = string(),
        type = string(enum("oauth2"))
      }
      additionalProperties = false
    }
    Encoding {
      type = "object"
      properties = {
        explode = boolean(),
        allowReserved = boolean(default(false)),
        contentType = string(),
        headers = map({
          oneOf = [definitions.Header, definitions.Reference]
        }),
        style = string(enum("form", "spaceDelimited", "pipeDelimited", "deepObject"))
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
    Paths {
      type = "object"
      additionalProperties = false
      patternProperties = {
        "^/" = definitions.PathItem,
        "^x-" = {}
      }
    }
    Tag {
      properties = {
        name = string(),
        description = string(),
        externalDocs = definitions.ExternalDocumentation
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
      type = "object"
      required = ["name"]
    }
    QueryParameter {
      properties = {
        in = {
          enum = ["query"]
        },
        style = {
          default = form,
          enum = ["form", "spaceDelimited", "pipeDelimited", "deepObject"]
        }
      }
      description = "Parameter in query"
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
    OAuthFlows {
      type = "object"
      properties = {
        password = definitions.PasswordOAuthFlow,
        clientCredentials = definitions.ClientCredentialsFlow,
        authorizationCode = definitions.AuthorizationCodeOAuthFlow,
        implicit = definitions.ImplicitOAuthFlow
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = {}
      }
    }
  }
