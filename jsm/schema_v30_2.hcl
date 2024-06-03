
  schema = "http://json-schema.org/draft-04/schema#"
  id = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
  patternProperties = {
    "^x-" = {}
  }
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  type = "object"
  required = ["openapi", "info", "paths"]
  properties = {
    servers = array(definitions.Server),
    security = array(definitions.SecurityRequirement),
    tags = array(definitions.Tag, uniqueItems(true)),
    paths = definitions.Paths,
    components = definitions.Components,
    openapi = string(pattern("^3\\.0\\.\\d(-.+)?$")),
    info = definitions.Info,
    externalDocs = definitions.ExternalDocumentation
  }
  additionalProperties = false
  definitions "License" {
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
  definitions "Link" {
    patternProperties = {
      "^x-" = {}
    }
    not = {
      required = ["operationId", "operationRef"],
      description = "Operation Id and Operation Ref are mutually exclusive"
    }
    type = "object"
    properties = {
      requestBody = {},
      description = string(),
      server = definitions.Server,
      operationId = string(),
      operationRef = string(),
      parameters = map({})
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
  definitions "Schema" {
    type = "object"
    properties = {
      example = {},
      externalDocs = definitions.ExternalDocumentation,
      type = string(enum("array", "boolean", "integer", "number", "object", "string")),
      nullable = boolean(default()),
      maxLength = integer(minimum(0)),
      minimum = number(),
      discriminator = definitions.Discriminator,
      maximum = number(),
      multipleOf = number(minimum(0), exclusiveMinimum(true)),
      pattern = string(format("regex")),
      minProperties = integer(default(), minimum(0)),
      additionalProperties = {
        default = lvexpr:{val:{boolValue:true}},
        oneOf = [definitions.Schema, definitions.Reference, boolean()]
      },
      minItems = integer(default(), minimum(0)),
      maxItems = integer(minimum(0)),
      exclusiveMaximum = boolean(default()),
      default = {},
      not = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      description = string(),
      maxProperties = integer(minimum(0)),
      writeOnly = boolean(default()),
      minLength = integer(default(), minimum(0)),
      anyOf = array({
        oneOf = [definitions.Schema, definitions.Reference]
      }),
      properties = map({
        oneOf = [definitions.Schema, definitions.Reference]
      }),
      format = string(),
      uniqueItems = boolean(default()),
      xml = definitions.XML,
      exclusiveMinimum = boolean(default()),
      readOnly = boolean(default()),
      allOf = array({
        oneOf = [definitions.Schema, definitions.Reference]
      }),
      oneOf = array({
        oneOf = [definitions.Schema, definitions.Reference]
      }),
      items = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      required = array(minItems(1), uniqueItems(true)),
      deprecated = boolean(default()),
      title = string(),
      enum = array({}, minItems(1), uniqueItems(false))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "XML" {
    additionalProperties = false
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
  }
  definitions "Tag" {
    required = ["name"]
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
  definitions "ExternalDocumentation" {
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
  definitions "Example" {
    type = "object"
    properties = {
      value = {},
      externalValue = string(format("uri-reference")),
      summary = string(),
      description = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "Operation" {
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
      responses = definitions.Responses,
      callbacks = map({
        oneOf = [definitions.Callback, definitions.Reference]
      }),
      servers = array(definitions.Server),
      externalDocs = definitions.ExternalDocumentation,
      summary = string(),
      operationId = string(),
      deprecated = boolean(default()),
      security = array(definitions.SecurityRequirement),
      description = string(),
      requestBody = {
        oneOf = [definitions.RequestBody, definitions.Reference]
      },
      tags = array()
    }
  }
  definitions "RequestBody" {
    type = "object"
    required = ["content"]
    properties = {
      required = boolean(default()),
      description = string(),
      content = map(definitions.MediaType)
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "ExampleXORExamples" {
    description = "Example and examples are mutually exclusive"
    not = {
      required = ["example", "examples"]
    }
  }
  definitions "Components" {
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    properties = {
      headers = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\\\.\\\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.Header]
          }
        }
      },
      securitySchemes = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\\\.\\\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.SecurityScheme]
          }
        }
      },
      callbacks = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\\\.\\\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.Callback]
          }
        }
      },
      parameters = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\\\.\\\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.Parameter]
          }
        }
      },
      schemas = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\\\.\\\\-_]+$" = {
            oneOf = [definitions.Schema, definitions.Reference]
          }
        }
      },
      examples = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\\\.\\\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.Example]
          }
        }
      },
      requestBodies = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\\\.\\\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.RequestBody]
          }
        }
      },
      links = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\\\.\\\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.Link]
          }
        }
      },
      responses = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\\\.\\\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.Response]
          }
        }
      }
    }
  }
  definitions "CookieParameter" {
    properties = {
      in = {
        enum = ["cookie"]
      },
      style = {
        default = stexpr:{traversal:{tRoot:{name:"form"}}},
        enum = ["form"]
      }
    }
    description = "Parameter in cookie"
  }
  definitions "QueryParameter" {
    properties = {
      in = {
        enum = ["query"]
      },
      style = {
        default = stexpr:{traversal:{tRoot:{name:"form"}}},
        enum = ["form", "spaceDelimited", "pipeDelimited", "deepObject"]
      }
    }
    description = "Parameter in query"
  }
  definitions "SchemaXORContent" {
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
  definitions "HTTPSecurityScheme" {
    type = "object"
    required = ["scheme", "type"]
    properties = {
      type = string(enum("http")),
      scheme = string(),
      bearerFormat = string(),
      description = string()
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
        scheme = string(pattern("^[Bb][Ee][Aa][Rr][Ee][Rr]$"))
      },
      not = {
        required = ["bearerFormat"]
      },
      description = "Non Bearer"
    }]
  }
  definitions "PathParameter" {
    required = ["required"]
    properties = {
      style = {
        default = stexpr:{traversal:{tRoot:{name:"simple"}}},
        enum = ["matrix", "label", "simple"]
      },
      required = {
        enum = []
      },
      in = {
        enum = ["path"]
      }
    }
    description = "Parameter in path"
  }
  definitions "SecurityScheme" {
    oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
  }
  definitions "PathItem" {
    properties = {
      "$ref" = string(),
      description = string(),
      put = definitions.Operation,
      post = definitions.Operation,
      summary = string(),
      head = definitions.Operation,
      patch = definitions.Operation,
      get = definitions.Operation,
      options = definitions.Operation,
      trace = definitions.Operation,
      servers = array(definitions.Server),
      delete = definitions.Operation,
      parameters = array({
        oneOf = [definitions.Parameter, definitions.Reference]
      }, uniqueItems(true))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
  }
  definitions "SecurityRequirement" {
    type = "map"
    additionalProperties = array()
  }
  definitions "OpenIdConnectSecurityScheme" {
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["type", "openIdConnectUrl"]
    properties = {
      openIdConnectUrl = string(format("uri-reference")),
      description = string(),
      type = string(enum("openIdConnect"))
    }
    additionalProperties = false
  }
  definitions "Parameter" {
    allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
    oneOf = [definitions.PathParameter, definitions.QueryParameter, definitions.HeaderParameter, definitions.CookieParameter]
    type = "object"
    required = ["name", "in"]
    properties = {
      required = boolean(default()),
      name = string(),
      in = string(),
      deprecated = boolean(default()),
      schema = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      allowEmptyValue = boolean(default()),
      style = string(),
      explode = boolean(),
      content = {
        type = "object",
        maxProperties = 1,
        minProperties = 1,
        additionalProperties = definitions.MediaType
      },
      example = {},
      description = string(),
      allowReserved = boolean(default()),
      examples = map({
        oneOf = [definitions.Example, definitions.Reference]
      })
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "Callback" {
    type = "object"
    additionalProperties = definitions.PathItem
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
  definitions "Encoding" {
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
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "AuthorizationCodeOAuthFlow" {
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["authorizationUrl", "tokenUrl", "scopes"]
    properties = {
      refreshUrl = string(format("uri-reference")),
      scopes = map(string()),
      authorizationUrl = string(format("uri-reference")),
      tokenUrl = string(format("uri-reference"))
    }
  }
  definitions "OAuth2SecurityScheme" {
    required = ["type", "flows"]
    properties = {
      description = string(),
      type = string(enum("oauth2")),
      flows = definitions.OAuthFlows
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
  }
  definitions "Paths" {
    type = "object"
    additionalProperties = false
    patternProperties = {
      "^/" = definitions.PathItem,
      "^x-" = {}
    }
  }
  definitions "Discriminator" {
    type = "object"
    required = ["propertyName"]
    properties = {
      propertyName = string(),
      mapping = map(string())
    }
  }
  definitions "Header" {
    patternProperties = {
      "^x-" = {}
    }
    allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
    type = "object"
    properties = {
      explode = boolean(),
      schema = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      content = {
        type = "object",
        maxProperties = 1,
        minProperties = 1,
        additionalProperties = definitions.MediaType
      },
      required = boolean(default()),
      deprecated = boolean(default()),
      style = string(default("simple"), enum("simple")),
      allowReserved = boolean(default()),
      example = {},
      examples = map({
        oneOf = [definitions.Example, definitions.Reference]
      }),
      description = string(),
      allowEmptyValue = boolean(default())
    }
    additionalProperties = false
  }
  definitions "ServerVariable" {
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["default"]
    properties = {
      description = string(),
      enum = array(),
      default = string()
    }
    additionalProperties = false
  }
  definitions "HeaderParameter" {
    description = "Parameter in header"
    properties = {
      in = {
        enum = ["header"]
      },
      style = {
        default = stexpr:{traversal:{tRoot:{name:"simple"}}},
        enum = ["simple"]
      }
    }
  }
  definitions "APIKeySecurityScheme" {
    type = "object"
    required = ["type", "name", "in"]
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
  }
  definitions "Responses" {
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
    additionalProperties = false
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
  definitions "MediaType" {
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    allOf = [definitions.ExampleXORExamples]
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
  }
  definitions "ClientCredentialsFlow" {
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
  definitions "Info" {
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
  definitions "Server" {
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
