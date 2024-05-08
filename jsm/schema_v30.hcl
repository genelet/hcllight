{
    type = "object",
    required = ["openapi", "info", "paths"],
    additionalProperties = ,
    description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3",
    properties = {
      tags = array(true),
      paths = definitions.Paths,
      components = definitions.Components,
      openapi = string("^3\.0\.\d(-.+)?$"),
      info = definitions.Info,
      externalDocs = definitions.ExternalDocumentation,
      servers = array(),
      security = array()
    },
    patternProperties = {
      ^x- = {}
    },
    definitions = {
      SecurityRequirement = object(),
      Discriminator = object({
    mapping = object(),
    propertyName = string()
  }, ["propertyName"]),
      ExternalDocumentation = {
        type = "object",
        required = ["url"],
        additionalProperties = ,
        properties = {
          description = string(),
          url = string("uri-reference")
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Encoding = {
        type = "object",
        additionalProperties = ,
        properties = {
          allowReserved = bool(),
          contentType = string(),
          headers = object(),
          style = string(["form", "spaceDelimited", "pipeDelimited", "deepObject"]),
          explode = bool()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      ServerVariable = {
        type = "object",
        required = ["default"],
        additionalProperties = ,
        properties = {
          enum = array(),
          default = string(),
          description = string()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Schema = {
        type = "object",
        additionalProperties = ,
        properties = {
          deprecated = bool(),
          title = string(),
          nullable = bool(),
          minItems = integer(, ),
          maxItems = integer(),
          maximum = number(),
          multipleOf = number(, true),
          exclusiveMinimum = bool(),
          pattern = string("regex"),
          maxLength = integer(),
          minimum = number(),
          exclusiveMaximum = bool(),
          discriminator = definitions.Discriminator,
          minLength = integer(, ),
          minProperties = integer(, ),
          uniqueItems = bool(),
          anyOf = array(),
          readOnly = bool(),
          externalDocs = definitions.ExternalDocumentation,
          format = string(),
          allOf = array(),
          type = string(["array", "boolean", "integer", "number", "object", "string"]),
          xml = definitions.XML,
          required = array(1, true),
          properties = object(),
          writeOnly = bool(),
          oneOf = array(),
          description = string(),
          enum = array(1, ),
          maxProperties = integer(),
          not = {
            oneOf = [definitions.Schema, definitions.Reference]
          },
          items = {
            oneOf = [definitions.Schema, definitions.Reference]
          },
          example = {},
          additionalProperties = {
            default = true,
            oneOf = [definitions.Schema, definitions.Reference, bool()]
          },
          default = {}
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Paths = {
        type = "object",
        additionalProperties = ,
        patternProperties = {
          ^\/ = definitions.PathItem,
          ^x- = {}
        }
      },
      Responses = {
        type = "object",
        minProperties = 1,
        additionalProperties = ,
        properties = {
          default = {
            oneOf = [definitions.Response, definitions.Reference]
          }
        },
        patternProperties = {
          ^x- = {},
          ^[1-5](?:\d{2}|XX)$ = {
            oneOf = [definitions.Response, definitions.Reference]
          }
        }
      },
      Components = {
        additionalProperties = ,
        type = "object",
        properties = {
          schemas = {
            type = "object",
            patternProperties = {
              ^[a-zA-Z0-9\.\-_]+$ = {
                oneOf = [definitions.Schema, definitions.Reference]
              }
            }
          },
          requestBodies = {
            type = "object",
            patternProperties = {
              ^[a-zA-Z0-9\.\-_]+$ = {
                oneOf = [definitions.Reference, definitions.RequestBody]
              }
            }
          },
          links = {
            type = "object",
            patternProperties = {
              ^[a-zA-Z0-9\.\-_]+$ = {
                oneOf = [definitions.Reference, definitions.Link]
              }
            }
          },
          callbacks = {
            type = "object",
            patternProperties = {
              ^[a-zA-Z0-9\.\-_]+$ = {
                oneOf = [definitions.Reference, definitions.Callback]
              }
            }
          },
          responses = {
            type = "object",
            patternProperties = {
              ^[a-zA-Z0-9\.\-_]+$ = {
                oneOf = [definitions.Reference, definitions.Response]
              }
            }
          },
          parameters = {
            type = "object",
            patternProperties = {
              ^[a-zA-Z0-9\.\-_]+$ = {
                oneOf = [definitions.Reference, definitions.Parameter]
              }
            }
          },
          examples = {
            type = "object",
            patternProperties = {
              ^[a-zA-Z0-9\.\-_]+$ = {
                oneOf = [definitions.Reference, definitions.Example]
              }
            }
          },
          headers = {
            type = "object",
            patternProperties = {
              ^[a-zA-Z0-9\.\-_]+$ = {
                oneOf = [definitions.Reference, definitions.Header]
              }
            }
          },
          securitySchemes = {
            type = "object",
            patternProperties = {
              ^[a-zA-Z0-9\.\-_]+$ = {
                oneOf = [definitions.Reference, definitions.SecurityScheme]
              }
            }
          }
        },
        patternProperties = {
          ^x- = {}
        }
      },
      QueryParameter = {
        description = "Parameter in query",
        properties = {
          in = {
            enum = ["query"]
          },
          style = {
            default = form,
            enum = ["form", "spaceDelimited", "pipeDelimited", "deepObject"]
          }
        }
      },
      Callback = {
        additionalProperties = definitions.PathItem,
        type = "object",
        patternProperties = {
          ^x- = {}
        }
      },
      PathItem = {
        type = "object",
        additionalProperties = ,
        properties = {
          options = definitions.Operation,
          servers = array(),
          parameters = array(true),
          description = string(),
          get = definitions.Operation,
          post = definitions.Operation,
          put = definitions.Operation,
          delete = definitions.Operation,
          $ref = string(),
          head = definitions.Operation,
          trace = definitions.Operation,
          patch = definitions.Operation,
          summary = string()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      PathParameter = {
        required = ["required"],
        description = "Parameter in path",
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
      },
      OAuth2SecurityScheme = {
        required = ["type", "flows"],
        additionalProperties = ,
        type = "object",
        properties = {
          type = string(["oauth2"]),
          flows = definitions.OAuthFlows,
          description = string()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Link = {
        type = "object",
        additionalProperties = ,
        not = {
          required = ["operationId", "operationRef"],
          description = "Operation Id and Operation Ref are mutually exclusive"
        },
        properties = {
          operationRef = string(),
          parameters = object(),
          description = string(),
          server = definitions.Server,
          operationId = string(),
          requestBody = {}
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Parameter = {
        type = "object",
        required = ["name", "in"],
        additionalProperties = ,
        allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent],
        oneOf = [definitions.PathParameter, definitions.QueryParameter, definitions.HeaderParameter, definitions.CookieParameter],
        properties = {
          examples = object(),
          name = string(),
          required = bool(),
          allowReserved = bool(),
          in = string(),
          description = string(),
          style = string(),
          explode = bool(),
          deprecated = bool(),
          allowEmptyValue = bool(),
          schema = {
            oneOf = [definitions.Schema, definitions.Reference]
          },
          content = {
            maxProperties = 1,
            minProperties = 1,
            additionalProperties = definitions.MediaType,
            type = "object"
          },
          example = {}
        },
        patternProperties = {
          ^x- = {}
        }
      },
      HTTPSecurityScheme = {
        type = "object",
        required = ["scheme", "type"],
        additionalProperties = ,
        oneOf = [{
          description = "Bearer",
          properties = {
            scheme = string("^[Bb][Ee][Aa][Rr][Ee][Rr]$")
          }
        }, {
          description = "Non Bearer",
          not = {
            required = ["bearerFormat"]
          },
          properties = {
            scheme = {
              not = string("^[Bb][Ee][Aa][Rr][Ee][Rr]$")
            }
          }
        }],
        properties = {
          bearerFormat = string(),
          description = string(),
          type = string(["http"]),
          scheme = string()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      OAuthFlows = {
        type = "object",
        additionalProperties = ,
        properties = {
          password = definitions.PasswordOAuthFlow,
          clientCredentials = definitions.ClientCredentialsFlow,
          authorizationCode = definitions.AuthorizationCodeOAuthFlow,
          implicit = definitions.ImplicitOAuthFlow
        },
        patternProperties = {
          ^x- = {}
        }
      },
      ExampleXORExamples = {
        not = {
          required = ["example", "examples"]
        },
        description = "Example and examples are mutually exclusive"
      },
      CookieParameter = {
        description = "Parameter in cookie",
        properties = {
          in = {
            enum = ["cookie"]
          },
          style = {
            default = form,
            enum = ["form"]
          }
        }
      },
      RequestBody = {
        additionalProperties = ,
        type = "object",
        required = ["content"],
        properties = {
          required = bool(),
          description = string(),
          content = object()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      APIKeySecurityScheme = {
        type = "object",
        required = ["type", "name", "in"],
        additionalProperties = ,
        properties = {
          description = string(),
          type = string(["apiKey"]),
          name = string(),
          in = string(["header", "query", "cookie"])
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Info = {
        type = "object",
        required = ["title", "version"],
        additionalProperties = ,
        properties = {
          termsOfService = string("uri-reference"),
          contact = definitions.Contact,
          license = definitions.License,
          version = string(),
          title = string(),
          description = string()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Header = {
        additionalProperties = ,
        allOf = [definitions.ExampleXORExamples, definitions.SchemaXORContent],
        type = "object",
        properties = {
          style = string(["simple"], "simple"),
          explode = bool(),
          description = string(),
          required = bool(),
          allowEmptyValue = bool(),
          allowReserved = bool(),
          examples = object(),
          deprecated = bool(),
          schema = {
            oneOf = [definitions.Schema, definitions.Reference]
          },
          example = {},
          content = {
            maxProperties = 1,
            minProperties = 1,
            additionalProperties = definitions.MediaType,
            type = "object"
          }
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Operation = {
        additionalProperties = ,
        type = "object",
        required = ["responses"],
        properties = {
          security = array(),
          parameters = array(true),
          description = string(),
          externalDocs = definitions.ExternalDocumentation,
          operationId = string(),
          responses = definitions.Responses,
          deprecated = bool(),
          servers = array(),
          callbacks = object(),
          tags = array(),
          summary = string(),
          requestBody = {
            oneOf = [definitions.RequestBody, definitions.Reference]
          }
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Tag = {
        required = ["name"],
        additionalProperties = ,
        type = "object",
        properties = {
          externalDocs = definitions.ExternalDocumentation,
          name = string(),
          description = string()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Contact = {
        type = "object",
        additionalProperties = ,
        properties = {
          name = string(),
          url = string("uri-reference"),
          email = string("email")
        },
        patternProperties = {
          ^x- = {}
        }
      },
      SchemaXORContent = {
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
        }],
        not = {
          required = ["schema", "content"]
        },
        description = "Schema and content are mutually exclusive, at least one is required"
      },
      AuthorizationCodeOAuthFlow = {
        type = "object",
        required = ["authorizationUrl", "tokenUrl", "scopes"],
        additionalProperties = ,
        properties = {
          scopes = object(),
          authorizationUrl = string("uri-reference"),
          tokenUrl = string("uri-reference"),
          refreshUrl = string("uri-reference")
        },
        patternProperties = {
          ^x- = {}
        }
      },
      OpenIdConnectSecurityScheme = {
        type = "object",
        required = ["type", "openIdConnectUrl"],
        additionalProperties = ,
        properties = {
          type = string(["openIdConnect"]),
          openIdConnectUrl = string("uri-reference"),
          description = string()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      ImplicitOAuthFlow = {
        type = "object",
        required = ["authorizationUrl", "scopes"],
        additionalProperties = ,
        properties = {
          authorizationUrl = string("uri-reference"),
          refreshUrl = string("uri-reference"),
          scopes = object()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      ClientCredentialsFlow = {
        type = "object",
        required = ["tokenUrl", "scopes"],
        additionalProperties = ,
        properties = {
          refreshUrl = string("uri-reference"),
          scopes = object(),
          tokenUrl = string("uri-reference")
        },
        patternProperties = {
          ^x- = {}
        }
      },
      License = {
        additionalProperties = ,
        type = "object",
        required = ["name"],
        properties = {
          name = string(),
          url = string("uri-reference")
        },
        patternProperties = {
          ^x- = {}
        }
      },
      XML = {
        type = "object",
        additionalProperties = ,
        properties = {
          namespace = string("uri"),
          prefix = string(),
          attribute = bool(),
          wrapped = bool(),
          name = string()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Response = {
        type = "object",
        required = ["description"],
        additionalProperties = ,
        properties = {
          headers = object(),
          content = object(),
          links = object(),
          description = string()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Example = {
        type = "object",
        additionalProperties = ,
        properties = {
          summary = string(),
          description = string(),
          externalValue = string("uri-reference"),
          value = {}
        },
        patternProperties = {
          ^x- = {}
        }
      },
      SecurityScheme = {
        oneOf = [definitions.APIKeySecurityScheme, definitions.HTTPSecurityScheme, definitions.OAuth2SecurityScheme, definitions.OpenIdConnectSecurityScheme]
      },
      PasswordOAuthFlow = {
        type = "object",
        required = ["tokenUrl", "scopes"],
        additionalProperties = ,
        properties = {
          refreshUrl = string("uri-reference"),
          scopes = object(),
          tokenUrl = string("uri-reference")
        },
        patternProperties = {
          ^x- = {}
        }
      },
      Reference = {
        type = "object",
        required = ["$ref"],
        patternProperties = {
          ^\$ref$ = string("uri-reference")
        }
      },
      Server = {
        additionalProperties = ,
        type = "object",
        required = ["url"],
        properties = {
          url = string(),
          description = string(),
          variables = object()
        },
        patternProperties = {
          ^x- = {}
        }
      },
      MediaType = {
        type = "object",
        additionalProperties = ,
        allOf = [definitions.ExampleXORExamples],
        properties = {
          examples = object(),
          encoding = object(),
          schema = {
            oneOf = [definitions.Schema, definitions.Reference]
          },
          example = {}
        },
        patternProperties = {
          ^x- = {}
        }
      },
      HeaderParameter = {
        description = "Parameter in header",
        properties = {
          in = {
            enum = ["header"]
          },
          style = {
            default = simple,
            enum = ["simple"]
          }
        }
      }
    }
  }