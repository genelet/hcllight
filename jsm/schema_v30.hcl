
  description = "The description of OpenAPI v3.0.x documents, as defined by https://spec.openapis.org/oas/v3.0.3"
  type = "object"
  required = ["openapi", "info", "paths"]
  additionalProperties = false
  schema = "http://json-schema.org/draft-04/schema#"
  id = "https://spec.openapis.org/oas/3.0/schema/2021-09-28"
  properties {
    components = definitions.Components
    info = definitions.Info
    externalDocs = definitions.ExternalDocumentation
    servers = array(definitions.Server)
    security = array(definitions.SecurityRequirement)
    tags = array(definitions.Tag, uniqueItems(true))
    paths = definitions.Paths
  }
  definitions {
    SecurityRequirement = map(array(string()))
    Discriminator = object({
      propertyName = string(),
      mapping = map(string())
    }, required("propertyName"))
    Example {
      type = "object"
      additionalProperties = false
      properties {
        externalValue = string(format("uri-reference"))
        summary = string()
        description = string()
        value {}
      }
    }
    PathItem {
      type = "object"
      additionalProperties = false
      properties {
        summary = string()
        delete = definitions.Operation
        parameters = array({
          oneOf = [definitions.Parameter, definitions.Reference]
        }, uniqueItems(true))
        get = definitions.Operation
        post = definitions.Operation
        servers = array(definitions.Server)
        patch = definitions.Operation
        trace = definitions.Operation
        head = definitions.Operation
        description = string()
        put = definitions.Operation
        options = definitions.Operation
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
    }
    Schema {
      additionalProperties = false
      type = "object"
      properties {
        oneOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        uniqueItems = boolean(default(false))
        properties = map({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        format = string()
        title = string()
        maximum = number()
        allOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        xml = definitions.XML
        deprecated = boolean(default(false))
        type = string(enum("array", "boolean", "integer", "number", "object", "string"))
        minLength = integer(default(0), minimum(0))
        pattern = string(format("regex"))
        minProperties = integer(default(0), minimum(0))
        discriminator = definitions.Discriminator
        externalDocs = definitions.ExternalDocumentation
        nullable = boolean(default(false))
        anyOf = array({
          oneOf = [definitions.Schema, definitions.Reference]
        })
        writeOnly = boolean(default(false))
        exclusiveMinimum = boolean(default(false))
        exclusiveMaximum = boolean(default(false))
        minimum = number()
        minItems = integer(default(0), minimum(0))
        maxItems = integer(minimum(0))
        multipleOf = number(minimum(0), exclusiveMinimum(true))
        readOnly = boolean(default(false))
        description = string()
        required = array(string(), minItems(1), uniqueItems(true))
        maxProperties = integer(minimum(0))
        maxLength = integer(minimum(0))
        enum = array({}, minItems(1), uniqueItems(false))
        not {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        default {}
        items {
          oneOf = [definitions.Schema, definitions.Reference]
        }
        additionalProperties {
          default = true
          oneOf = [definitions.Schema, definitions.Reference, boolean()]
        }
        example {}
      }
    }
  }
