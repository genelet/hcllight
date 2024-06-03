
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  type = "object"
  required = ["openapi", "info", "paths"]
  properties = {
    security = array([definitions.SecurityRequirement]),
    tags = array(uniqueItems(true), [definitions.Tag]),
    paths = definitions.Paths,
    components = definitions.Components,
    openapi = string(pattern("^3\\.0\\.\\d(-.+)?$")),
    info = definitions.Info,
    externalDocs = definitions.ExternalDocumentation,
    servers = array([definitions.Server])
  }
  additionalProperties = false
  schema = "http://json-schema.org/draft-04/schema#"
  id = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
  patternProperties = {
    "^x-" = {}
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
  definitions "PathItem" {
    patternProperties = {
      "^(get|put|post|delete|options|head|patch|trace)$" = definitions.Operation,
      "^x-" = {}
    }
    type = "object"
    properties = {
      "$ref" = string(),
      summary = string(),
      description = string(),
      servers = array([definitions.Server]),
      parameters = array(uniqueItems(true), [{
        oneOf = [definitions.Parameter, definitions.Reference]
      }])
    }
    additionalProperties = false
  }
  definitions "ImplicitOAuthFlow" {
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["authorizationUrl", "scopes"]
    properties = {
      scopes = map(string()),
      authorizationUrl = string(format("uri-reference")),
      refreshUrl = string(format("uri-reference"))
    }
    additionalProperties = false
  }
  definitions "ClientCredentialsFlow" {
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
  definitions "Reference" {
    type = "object"
    required = ["$ref"]
    patternProperties = {
      "^\\$ref$" = string(format("uri-reference"))
    }
  }
  definitions "Operation" {
    type = "object"
    required = ["responses"]
    properties = {
      summary = string(),
      parameters = array(uniqueItems(true), [{
        oneOf = [definitions.Parameter, definitions.Reference]
      }]),
      deprecated = boolean(default(false)),
      security = array([definitions.SecurityRequirement]),
      responses = definitions.Responses,
      callbacks = map({
        oneOf = [definitions.Callback, definitions.Reference]
      }),
      servers = array([definitions.Server]),
      tags = array([string()]),
      description = string(),
      externalDocs = definitions.ExternalDocumentation,
      operationId = string(),
      requestBody = {
        oneOf = [definitions.RequestBody, definitions.Reference]
      }
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "Tag" {
    type = "object"
    required = ["name"]
    properties = {
      description = string(),
      externalDocs = definitions.ExternalDocumentation,
      name = string()
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
  definitions "Responses" {
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
  definitions "Discriminator" {
    type = "object"
    required = ["propertyName"]
    properties = {
      propertyName = string(),
      mapping = map(string())
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
  definitions "Header" {
    type = "object"
    properties = {
      allowReserved = boolean(default(false)),
      schema = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      example = {},
      examples = map({
        oneOf = [definitions.Example, definitions.Reference]
      }),
      required = boolean(default(false)),
      deprecated = boolean(default(false)),
      allowEmptyValue = boolean(default(false)),
      style = string(default("simple"), enum("simple")),
      explode = boolean(),
      content = {
        minProperties = 1,
        additionalProperties = definitions.MediaType,
        type = "object",
        maxProperties = 1
      },
      description = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent]
  }
  definitions "SecurityScheme" {
    oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
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
  definitions "Callback" {
    type = "object"
    additionalProperties = definitions.PathItem
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "Components" {
    type = "object"
    properties = {
      callbacks = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\.\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.Callback]
          }
        }
      },
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
      requestBodies = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\.\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.RequestBody]
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
      securitySchemes = {
        type = "object",
        patternProperties = {
          "^[a-zA-Z0-9\\.\\-_]+$" = {
            oneOf = [definitions.Reference, definitions.SecurityScheme]
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
      }
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "ExternalDocumentation" {
    properties = {
      description = string(),
      url = string(format("uri-reference"))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["url"]
  }
  definitions "Parameter" {
    properties = {
      example = {},
      examples = map({
        oneOf = [definitions.Example, definitions.Reference]
      }),
      name = string(),
      description = string(),
      style = string(),
      schema = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      explode = boolean(),
      allowReserved = boolean(default(false)),
      content = {
        type = "object",
        maxProperties = 1,
        minProperties = 1,
        additionalProperties = definitions.MediaType
      },
      in = string(),
      required = boolean(default(false)),
      deprecated = boolean(default(false)),
      allowEmptyValue = boolean(default(false))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent, definitions.ParameterLocation]
    type = "object"
    required = ["name", "in"]
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
  definitions "ServerVariable" {
    properties = {
      enum = array([string()]),
      default = string(),
      description = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["default"]
  }
  definitions "XML" {
    properties = {
      name = string(),
      namespace = string(format("uri")),
      prefix = string(),
      attribute = boolean(default(false)),
      wrapped = boolean(default(false))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
  }
  definitions "Response" {
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
    additionalProperties = false
  }
  definitions "OAuth2SecurityScheme" {
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
  definitions "AuthorizationCodeOAuthFlow" {
    type = "object"
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
  }
  definitions "Info" {
    type = "object"
    required = ["title", "version"]
    properties = {
      license = definitions.License,
      version = string(),
      title = string(),
      description = string(),
      termsOfService = string(format("uri-reference")),
      contact = definitions.Contact
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
  }
  definitions "Server" {
    properties = {
      url = string(),
      description = string(),
      variables = map(definitions.ServerVariable)
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["url"]
  }
  definitions "ExampleXORExamples" {
    not = {
      required = ["example", "examples"]
    }
    description = "Example and examples are mutually exclusive"
  }
  definitions "Link" {
    type = "object"
    properties = {
      operationId = string(),
      operationRef = string(format("uri-reference")),
      parameters = map({}),
      requestBody = {},
      description = string(),
      server = definitions.Server
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
  definitions "SecurityRequirement" {
    type = "map"
    additionalProperties = array([string()])
  }
  definitions "RequestBody" {
    properties = {
      description = string(),
      content = map(definitions.MediaType),
      required = boolean(default(false))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    required = ["content"]
  }
  definitions "OAuthFlows" {
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
    type = "object"
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
      allowReserved = boolean(default(false))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = {}
    }
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
  definitions "Schema" {
    patternProperties = {
      "^x-" = {}
    }
    type = "object"
    properties = {
      minimum = number(),
      maxLength = integer(minimum(0)),
      items = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      exclusiveMaximum = boolean(default(false)),
      uniqueItems = boolean(default(false)),
      minProperties = integer(default(0), minimum(0)),
      description = string(),
      minLength = integer(default(0), minimum(0)),
      properties = map({
        oneOf = [definitions.Schema, definitions.Reference]
      }),
      writeOnly = boolean(default(false)),
      xml = definitions.XML,
      maximum = number(),
      required = array(minItems(1), uniqueItems(true), [string()]),
      oneOf = array([{
        oneOf = [definitions.Schema, definitions.Reference]
      }]),
      externalDocs = definitions.ExternalDocumentation,
      exclusiveMinimum = boolean(default(false)),
      pattern = string(format("regex")),
      enum = array(minItems(1), uniqueItems(false), [{}]),
      allOf = array([{
        oneOf = [definitions.Schema, definitions.Reference]
      }]),
      nullable = boolean(default(false)),
      discriminator = definitions.Discriminator,
      readOnly = boolean(default(false)),
      deprecated = boolean(default(false)),
      title = string(),
      maxItems = integer(minimum(0)),
      minItems = integer(default(0), minimum(0)),
      anyOf = array([{
        oneOf = [definitions.Schema, definitions.Reference]
      }]),
      default = {},
      type = string(enum("array", "boolean", "integer", "number", "object", "string")),
      additionalProperties = {
        default = true,
        oneOf = [definitions.Schema, definitions.Reference, boolean()]
      },
      example = {},
      multipleOf = number(minimum(0), exclusiveMinimum(true)),
      maxProperties = integer(minimum(0)),
      not = {
        oneOf = [definitions.Schema, definitions.Reference]
      },
      format = string()
    }
    additionalProperties = false
  }
  definitions "ParameterLocation" {
    oneOf = [{
      required = ["required"],
      properties = {
        required = {
          enum = [true]
        },
        in = {
          enum = ["path"]
        },
        style = {
          default = simple,
          enum = ["matrix", "label", "simple"]
        }
      },
      description = "Parameter in path"
    }, {
      properties = {
        in = {
          enum = ["query"]
        },
        style = {
          default = form,
          enum = ["form", "spaceDelimited", "pipeDelimited", "deepObject"]
        }
      },
      description = "Parameter in query"
    }, {
      properties = {
        in = {
          enum = ["header"]
        },
        style = {
          default = simple,
          enum = ["simple"]
        }
      },
      description = "Parameter in header"
    }, {
      properties = {
        in = {
          enum = ["cookie"]
        },
        style = {
          default = form,
          enum = ["form"]
        }
      },
      description = "Parameter in cookie"
    }]
    description = "Parameter location"
  }
