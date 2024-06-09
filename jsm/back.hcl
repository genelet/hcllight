
  additionalProperties = false
  schema = "http://json-schema.org/draft-04/schema#"
  id = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
  patternProperties = {
    "^x-" = {}
  }
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  type = "object"
  required = ["openapi", "info", "paths"]
  properties = {
    info = definitions.Info,
    externalDocs = definitions.ExternalDocumentation,
    servers = array(definitions.Server),
    security = array(definitions.SecurityRequirement),
    tags = array(definitions.Tag, uniqueItems(true)),
    paths = definitions.Paths,
    components = definitions.Components,
    openapi = string(pattern("^3\\.0\\.\\d(-.+)?$"))
  }
  definitions "Contact" {
    type = "object"
    properties = {
      name = string(),
      url = string(format("uri-reference")),
      email = string(format("email"))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "Paths" {
    type = "object"
    additionalProperties = false
    patternProperties = {
      "^/" = definitions.PathItem,
      "^x-" = {}
    }
  }
  definitions "Parameter" {
    type = "object"
    required = ["name", "in"]
    properties = {
      in = string(),
      example = {},
      name = string(),
      description = string(),
      required = boolean(default()),
      schema = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      content = {
        type = "object",
        maxProperties = 1,
        minProperties = 1
      },
      examples = map({
        oneOf = [definitions.Example, definitions.Reference]
      }),
      style = string(),
      explode = boolean(),
      allowReserved = boolean(default()),
      allowEmptyValue = boolean(default()),
      deprecated = boolean(default())
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
    oneOf = [definitions.PathParameter, definitions.QueryParameter, definitions.HeaderParameter, definitions.CookieParameter]
  }
  definitions "XML" {
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    properties = {
      namespace = string(format("uri")),
      prefix = string(),
      attribute = boolean(default()),
      wrapped = boolean(default()),
      name = string()
    }
    additionalProperties = false
  }
  definitions "Tag" {
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
  definitions "Info" {
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["title", "version"]
    properties = {
      version = string(),
      title = string(),
      description = string(),
      termsOfService = string(format("uri-reference")),
      contact = definitions.Contact,
      license = definitions.License
    }
    additionalProperties = false
  }
  definitions "OAuth2SecurityScheme" {
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["type", "flows"]
    properties = {
      type = string(enum("oauth2")),
      flows = definitions.OAuthFlows,
      description = string()
    }
  }
  definitions "ExternalDocumentation" {
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
  definitions "PathParameter" {
    required = ["required"]
    properties = {
      in = {
        enum = ["path"]
      },
      style = {
        default = stexpr:{traversal:{tRoot:{name:"simple"}}},
        enum = ["matrix", "label", "simple"]
      },
      required = {
        enum = []
      }
    }
    description = "Parameter in path"
  }
  definitions "PasswordOAuthFlow" {
    type = "object"
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
  }
  definitions "OpenIdConnectSecurityScheme" {
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["type", "openIdConnectUrl"]
    properties = {
      type = string(enum("openIdConnect")),
      openIdConnectUrl = string(format("uri-reference")),
      description = string()
    }
    additionalProperties = false
  }
  definitions "License" {
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
  definitions "OAuthFlows" {
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
  definitions "APIKeySecurityScheme" {
    type = "object"
    required = ["type", "name", "in"]
    properties = {
      name = string(),
      in = string(enum("header", "query", "cookie")),
      description = string(),
      type = string(enum("apiKey"))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "HeaderParameter" {
    properties = {
      in = {
        enum = ["header"]
      },
      style = {
        default = stexpr:{traversal:{tRoot:{name:"simple"}}},
        enum = ["simple"]
      }
    }
    description = "Parameter in header"
  }
  definitions "ClientCredentialsFlow" {
    type = "object"
    required = ["tokenUrl", "scopes"]
    properties = {
      scopes = map(string()),
      tokenUrl = string(format("uri-reference")),
      refreshUrl = string(format("uri-reference"))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "Components" {
    type = "object"
    properties = {
      examples = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\.\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.Example]
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
      securitySchemes = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\.\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.SecurityScheme]
          }
        }
      },
      responses = {
        patternProperties = {
          "^[a-zA-Z0-9\\.\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.Response]
          }
        },
        type = "object"
      },
      requestBodies = {
        patternProperties = {
          "^[a-zA-Z0-9\\.\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.RequestBody]
          }
        },
        type = "object"
      },
      callbacks = {
        patternProperties = {
          "^[a-zA-Z0-9\\.\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.Callback]
          }
        },
        type = "object"
      },
      schemas = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\.\\-_]+$" = {
            oneOf = [definitions.Schema, definitions.Reference]
          }
        }
      }
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "SecurityRequirement" {
    type = "array"
  }
  definitions "SecurityScheme" {
    oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
  }
  definitions "Header" {
    type = "object"
    properties = {
      example = {},
      examples = map({
        oneOf = [definitions.Example, definitions.Reference]
      }),
      allowEmptyValue = boolean(default()),
      style = string(default("simple"), enum("simple")),
      explode = boolean(),
      deprecated = boolean(default()),
      allowReserved = boolean(default()),
      content = {
        type = "object",
        maxProperties = 1,
        minProperties = 1
      },
      schema = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      description = string(),
      required = boolean(default())
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
  }
  definitions "Server" {
    required = ["url"]
    properties = {
      description = string(),
      variables = map(definitions.ServerVariable),
      url = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
  }
  definitions "QueryParameter" {
    properties = {
      style = {
        enum = ["form", "spaceDelimited", "pipeDelimited", "deepObject"],
        default = stexpr:{traversal:{tRoot:{name:"form"}}}
      },
      in = {
        enum = ["query"]
      }
    }
    description = "Parameter in query"
  }
  definitions "RequestBody" {
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["content"]
    properties = {
      required = boolean(default()),
      description = string(),
      content = map(definitions.MediaType)
    }
    additionalProperties = false
  }
  definitions "MediaType" {
    type = "object"
    properties = {
      schema = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      example = {},
      examples = map({
        oneOf = [definitions.Example, definitions.Reference]
      }),
      encoding = map(definitions.Encoding)
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    allOf = [definitions.ExampleXORExamples]
  }
  definitions "Responses" {
    additionalProperties = false
    patternProperties = {
      "^[1-5](?:\\d{2}|XX)$" = {
        oneOf = [definitions.Response, definitions.Reference]
      },
      "^x-" = {}
    }
    type = "object"
    minProperties = 1
    properties = {
      default = {
        oneOf = [definitions.Response, definitions.Reference]
      }
    }
  }
  definitions "Link" {
    additionalProperties = false
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
      requestBody = {},
      description = string(),
      server = definitions.Server
    }
  }
  definitions "AuthorizationCodeOAuthFlow" {
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["authorizationUrl", "tokenUrl", "scopes"]
    properties = {
      tokenUrl = string(format("uri-reference")),
      refreshUrl = string(format("uri-reference")),
      scopes = map(string()),
      authorizationUrl = string(format("uri-reference"))
    }
    additionalProperties = false
  }
  definitions "Response" {
    type = "object"
    required = ["description"]
    properties = {
      links = map({
        oneOf = [definitions.Link, definitions.Reference]
      }),
      description = string(),
      headers = map({
        oneOf = [definitions.Header, definitions.Reference]
      }),
      content = map(definitions.MediaType)
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "PathItem" {
    properties = {
      options = definitions.Operation,
      patch = definitions.Operation,
      trace = definitions.Operation,
      parameters = array({
        oneOf = [definitions.Parameter, definitions.Reference]
      }, uniqueItems(true)),
      "$ref" = string(),
      description = string(),
      put = definitions.Operation,
      delete = definitions.Operation,
      servers = array(definitions.Server),
      summary = string(),
      head = definitions.Operation,
      get = definitions.Operation,
      post = definitions.Operation
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
  }
  definitions "ExampleXORExamples" {
    description = "Example and examples are mutually exclusive"
    not = {
      required = ["example", "examples"]
    }
  }
  definitions "Operation" {
    required = ["responses"]
    properties = {
      externalDocs = definitions.ExternalDocumentation,
      parameters = array({
        oneOf = [definitions.Parameter, definitions.Reference]
      }, uniqueItems(true)),
      requestBody = {
        oneOf = [definitions.RequestBody, definitions.Reference]
      },
      responses = definitions.Responses,
      callbacks = map({
        oneOf = [definitions.Callback, definitions.Reference]
      }),
      deprecated = boolean(default()),
      servers = array(definitions.Server),
      tags = array(),
      summary = string(),
      description = string(),
      operationId = string(),
      security = array(definitions.SecurityRequirement)
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
  }
  definitions "SchemaXORContent" {
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
  definitions "Encoding" {
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    properties = {
      contentType = string(),
      headers = map({
        oneOf = [definitions.Header, definitions.Reference]
      }),
      style = string(enum("form", "spaceDelimited", "pipeDelimited", "deepObject")),
      explode = boolean(),
      allowReserved = boolean(default())
    }
    additionalProperties = false
  }
  definitions "ImplicitOAuthFlow" {
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
  definitions "ServerVariable" {
    type = "object"
    required = ["default"]
    properties = {
      enum = array(),
      default = string(),
      description = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "CookieParameter" {
    properties = {
      style = {
        default = stexpr:{traversal:{tRoot:{name:"form"}}},
        enum = ["form"]
      },
      in = {
        enum = ["cookie"]
      }
    }
    description = "Parameter in cookie"
  }
  definitions "Callback" {
    type = "object"
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "Reference" {
    type = "object"
    required = ["$ref"]
    patternProperties = {
      "^\\$ref$" = string(format("uri-reference"))
    }
  }
  definitions "Discriminator" {
    type = "object"
    required = ["propertyName"]
    properties = {
      mapping = map(string()),
      propertyName = string()
    }
  }
  definitions "Schema" {
    properties = {
      nullable = boolean(default()),
      exclusiveMaximum = boolean(default()),
      maximum = number(),
      enum = array({}, minItems(1), uniqueItems(false)),
      minItems = integer(default(), minimum(0)),
      multipleOf = number(minimum(0), exclusiveMinimum(true)),
      type = string(enum("array", "boolean", "integer", "number", "object", "string")),
      discriminator = definitions.Discriminator,
      pattern = string(format("regex")),
      exclusiveMinimum = boolean(default()),
      title = string(),
      readOnly = boolean(default()),
      maxProperties = integer(minimum(0)),
      format = string(),
      allOf = array({
        oneOf = [definitions.Schema, definitions.Reference]
      }),
      default = {},
      minLength = integer(default(), minimum(0)),
      not = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      required = array(minItems(1), uniqueItems(true)),
      externalDocs = definitions.ExternalDocumentation,
      additionalProperties = {
        default = lvexpr:{val:{boolValue:true}},
        oneOf = [definitions.Schema, definitions.Reference, boolean()]
      },
      minimum = number(),
      properties = map({
        oneOf = [definitions.Schema, definitions.Reference]
      }),
      uniqueItems = boolean(default()),
      minProperties = integer(default(), minimum(0)),
      maxItems = integer(minimum(0)),
      anyOf = array({
        oneOf = [definitions.Schema, definitions.Reference]
      }),
      example = {},
      writeOnly = boolean(default()),
      maxLength = integer(minimum(0)),
      oneOf = array({
        oneOf = [definitions.Schema, definitions.Reference]
      }),
      deprecated = boolean(default()),
      xml = definitions.XML,
      description = string(),
      items = {
        oneOf = [definitions.Schema, definitions.Reference]
      }
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
  }
  definitions "Example" {
    type = "object"
    properties = {
      description = string(),
      value = {},
      externalValue = string(format("uri-reference")),
      summary = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "HTTPSecurityScheme" {
    type = "object"
    required = ["scheme", "type"]
    properties = {
      bearerFormat = string(),
      description = string(),
      type = string(enum("http")),
      scheme = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    oneOf = [
      {
        description = "Bearer"
      },
      {
        properties = {
          scheme = string(pattern("^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
        },
        not = {
          required = ["bearerFormat"]
        },
        description = "Non Bearer"
      }
    ]
  }
