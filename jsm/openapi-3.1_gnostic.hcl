
  patternProperties = {
    "^x-" = definitions.specificationExtension
  }
  description = "This is the root document object of the OpenAPI document."
  required = ["openapi", "info", "paths"]
  properties = {
    info = definitions.info,
    servers = array(definitions.server, uniqueItems(true)),
    paths = definitions.paths,
    components = definitions.components,
    security = array(definitions.securityRequirement, uniqueItems(true)),
    tags = array(definitions.tag, uniqueItems(true)),
    externalDocs = definitions.externalDocs,
    openapi = string()
  }
  id = "http://openapis.org/v3/schema.json#"
  title = "A JSON Schema for OpenAPI 3.0."
  type = "object"
  additionalProperties = false
  schema = "http://json-schema.org/draft-04/schema#"
  definitions "headerOrReference" {
    oneOf = [definitions.header, definitions.reference]
  }
  definitions "headersOrReferences" {
    type = "map"
    additionalProperties = definitions.headerOrReference
  }
  definitions "specificationExtension" {
    oneOf = [{
      type = "null"
    }, number(), boolean(), string(), object(), array()]
    description = "Any property starting with x- is valid."
  }
  definitions "requestBody" {
    type = "object"
    required = ["content"]
    properties = {
      content = definitions.mediaTypes,
      required = boolean(),
      description = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Describes a single request body."
  }
  definitions "example" {
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = ""
    type = "object"
    properties = {
      summary = string(),
      description = string(),
      value = definitions.any,
      externalValue = string()
    }
    additionalProperties = false
  }
  definitions "securityRequirement" {
    type = "object"
    additionalProperties = array(string(), uniqueItems(true))
    description = "Lists the required security schemes to execute this operation. The name used for each property MUST correspond to a security scheme declared in the Security Schemes under the Components Object.  Security Requirement Objects that contain multiple schemes require that all schemes MUST be satisfied for a request to be authorized. This enables support for scenarios where multiple query parameters or HTTP headers are required to convey security information.  When a list of Security Requirement Objects is defined on the OpenAPI Object or Operation Object, only one of the Security Requirement Objects in the list needs to be satisfied to authorize the request."
  }
  definitions "linksOrReferences" {
    type = "map"
    additionalProperties = definitions.linkOrReference
  }
  definitions "info" {
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "The object provides metadata about the API. The metadata MAY be used by the clients if needed, and MAY be presented in editing or documentation generation tools for convenience."
    type = "object"
    required = ["title", "version"]
    properties = {
      termsOfService = string(),
      contact = definitions.contact,
      license = definitions.license,
      version = string(),
      summary = string(),
      title = string(),
      description = string()
    }
    additionalProperties = false
  }
  definitions "link" {
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "The `Link object` represents a possible design-time link for a response. The presence of a link does not guarantee the caller's ability to successfully invoke it, rather it provides a known relationship and traversal mechanism between responses and other operations.  Unlike _dynamic_ links (i.e. links provided **in** the response payload), the OAS linking mechanism does not require link information in the runtime response.  For computing links, and providing instructions to execute them, a runtime expression is used for accessing values in an operation and using them as parameters while invoking the linked operation."
    type = "object"
    properties = {
      operationRef = string(),
      operationId = string(),
      parameters = definitions.anyOrExpression,
      requestBody = definitions.anyOrExpression,
      description = string(),
      server = definitions.server
    }
  }
  definitions "header" {
    properties = {
      content = definitions.mediaTypes,
      description = string(),
      deprecated = boolean(),
      style = string(),
      explode = boolean(),
      example = definitions.any,
      examples = definitions.examplesOrReferences,
      required = boolean(),
      allowEmptyValue = boolean(),
      allowReserved = boolean(),
      schema = definitions.schemaOrReference
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "The Header Object follows the structure of the Parameter Object with the following changes:  1. `name` MUST NOT be specified, it is given in the corresponding `headers` map. 1. `in` MUST NOT be specified, it is implicitly in `header`. 1. All traits that are affected by the location MUST be applicable to a location of `header` (for example, `style`)."
    type = "object"
  }
  definitions "xml" {
    type = "object"
    properties = {
      name = string(),
      namespace = string(),
      prefix = string(),
      attribute = boolean(),
      wrapped = boolean()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "A metadata object that allows for more fine-tuned XML model definitions.  When using arrays, XML element names are *not* inferred (for singular/plural forms) and the `name` property SHOULD be used to add that information. See examples for expected behavior."
  }
  definitions "oauthFlow" {
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Configuration details for a supported OAuth Flow"
    type = "object"
    properties = {
      tokenUrl = string(),
      refreshUrl = string(),
      scopes = definitions.strings,
      authorizationUrl = string()
    }
  }
  definitions "schemasOrReferences" {
    type = "map"
    additionalProperties = definitions.schemaOrReference
  }
  definitions "strings" {
    type = "map"
    additionalProperties = string()
  }
  definitions "mediaType" {
    type = "object"
    properties = {
      schema = definitions.schemaOrReference,
      example = definitions.any,
      examples = definitions.examplesOrReferences,
      encoding = definitions.encodings
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Each Media Type Object provides schema and examples for the media type identified by its key."
  }
  definitions "securityScheme" {
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Defines a security scheme that can be used by the operations. Supported schemes are HTTP authentication, an API key (either as a header, a cookie parameter or as a query parameter), mutual TLS (use of a client certificate), OAuth2's common flows (implicit, password, application and access code) as defined in RFC6749, and OpenID Connect.   Please note that currently (2019) the implicit flow is about to be deprecated OAuth 2.0 Security Best Current Practice. Recommended for most use case is Authorization Code Grant flow with PKCE."
    type = "object"
    required = ["type"]
    properties = {
      in = string(),
      scheme = string(),
      bearerFormat = string(),
      flows = definitions.oauthFlows,
      openIdConnectUrl = string(),
      type = string(),
      description = string(),
      name = string()
    }
    additionalProperties = false
  }
  definitions "parametersOrReferences" {
    type = "map"
    additionalProperties = definitions.parameterOrReference
  }
  definitions "encodings" {
    type = "map"
    additionalProperties = definitions.encoding
  }
  definitions "object" {
    additionalProperties = true
    type = "map"
  }
  definitions "license" {
    type = "object"
    required = ["name"]
    properties = {
      name = string(),
      url = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "License information for the exposed API."
  }
  definitions "discriminator" {
    required = ["propertyName"]
    properties = {
      propertyName = string(),
      mapping = definitions.strings
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "When request bodies or response payloads may be one of a number of different schemas, a `discriminator` object can be used to aid in serialization, deserialization, and validation.  The discriminator is a specific object in a schema which is used to inform the consumer of the specification of an alternative schema based on the value associated with it.  When using the discriminator, _inline_ schemas will not be considered."
    type = "object"
  }
  definitions "responseOrReference" {
    oneOf = [definitions.response, definitions.reference]
  }
  definitions "oauthFlows" {
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Allows configuration of the supported OAuth Flows."
    type = "object"
    properties = {
      clientCredentials = definitions.oauthFlow,
      authorizationCode = definitions.oauthFlow,
      implicit = definitions.oauthFlow,
      password = definitions.oauthFlow
    }
  }
  definitions "callbacksOrReferences" {
    type = "map"
    additionalProperties = definitions.callbackOrReference
  }
  definitions "encoding" {
    type = "object"
    properties = {
      allowReserved = boolean(),
      contentType = string(),
      headers = definitions.headersOrReferences,
      style = string(),
      explode = boolean()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "A single encoding definition applied to a single schema property."
  }
  definitions "defaultType" {
    oneOf = [{
      type = "null"
    }, array(), object(), number(), boolean(), string()]
  }
  definitions "securitySchemeOrReference" {
    oneOf = [definitions.securityScheme, definitions.reference]
  }
  definitions "responses" {
    type = "object"
    properties = {
      default = definitions.responseOrReference
    }
    additionalProperties = false
    patternProperties = {
      "^([0-9X]{3})$" = definitions.responseOrReference,
      "^x-" = definitions.specificationExtension
    }
    description = "A container for the expected responses of an operation. The container maps a HTTP response code to the expected response.  The documentation is not necessarily expected to cover all possible HTTP response codes because they may not be known in advance. However, documentation is expected to cover a successful operation response and any known errors.  The `default` MAY be used as a default response object for all HTTP codes  that are not covered individually by the specification.  The `Responses Object` MUST contain at least one response code, and it  SHOULD be the response for a successful operation call."
  }
  definitions "response" {
    description = "Describes a single response from an API Operation, including design-time, static  `links` to operations based on the response."
    type = "object"
    required = ["description"]
    properties = {
      links = definitions.linksOrReferences,
      description = string(),
      headers = definitions.headersOrReferences,
      content = definitions.mediaTypes
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
  }
  definitions "requestBodyOrReference" {
    oneOf = [definitions.requestBody, definitions.reference]
  }
  definitions "components" {
    type = "object"
    properties = {
      parameters = definitions.parametersOrReferences,
      examples = definitions.examplesOrReferences,
      securitySchemes = definitions.securitySchemesOrReferences,
      callbacks = definitions.callbacksOrReferences,
      schemas = definitions.schemasOrReferences,
      responses = definitions.responsesOrReferences,
      requestBodies = definitions.requestBodiesOrReferences,
      headers = definitions.headersOrReferences,
      links = definitions.linksOrReferences
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Holds a set of reusable objects for different aspects of the OAS. All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object."
  }
  definitions "exampleOrReference" {
    oneOf = [definitions.example, definitions.reference]
  }
  definitions "expression" {
    type = "map"
    additionalProperties = true
  }
  definitions "paths" {
    type = "object"
    additionalProperties = false
    patternProperties = {
      "^/" = definitions.pathItem,
      "^x-" = definitions.specificationExtension
    }
    description = "Holds the relative paths to the individual endpoints and their operations. The path is appended to the URL from the `Server Object` in order to construct the full URL.  The Paths MAY be empty, due to ACL constraints."
  }
  definitions "schema" {
    properties = {
      multipleOf = properties.multipleOf,
      maximum = properties.maximum,
      minProperties = properties.minProperties,
      properties = map(definitions.schemaOrReference),
      title = properties.title,
      minimum = properties.minimum,
      default = definitions.defaultType,
      description = string(),
      oneOf = array(definitions.schemaOrReference, minItems(1)),
      writeOnly = boolean(),
      deprecated = boolean(),
      minItems = properties.minItems,
      uniqueItems = properties.uniqueItems,
      maxProperties = properties.maxProperties,
      type = string(),
      pattern = properties.pattern,
      anyOf = array(definitions.schemaOrReference, minItems(1)),
      items = {
        anyOf = [definitions.schemaOrReference, array(definitions.schemaOrReference, minItems(1))]
      },
      nullable = boolean(),
      externalDocs = definitions.externalDocs,
      additionalProperties = {
        oneOf = [definitions.schemaOrReference, boolean()]
      },
      format = string(),
      xml = definitions.xml,
      example = definitions.any,
      minLength = properties.minLength,
      maxItems = properties.maxItems,
      allOf = array(definitions.schemaOrReference, minItems(1)),
      not = definitions.schema,
      discriminator = definitions.discriminator,
      readOnly = boolean(),
      maxLength = properties.maxLength,
      enum = properties.enum,
      exclusiveMaximum = properties.exclusiveMaximum,
      exclusiveMinimum = properties.exclusiveMinimum,
      required = properties.required
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is an extended subset of the JSON Schema Specification Wright Draft 00.  For more information about the properties, see JSON Schema Core and JSON Schema Validation. Unless stated otherwise, the property definitions follow the JSON Schema."
    type = "object"
  }
  definitions "callbackOrReference" {
    oneOf = [definitions.callback, definitions.reference]
  }
  definitions "operation" {
    type = "object"
    required = ["responses"]
    properties = {
      responses = definitions.responses,
      callbacks = definitions.callbacksOrReferences,
      tags = array(string(), uniqueItems(true)),
      summary = string(),
      description = string(),
      requestBody = definitions.requestBodyOrReference,
      deprecated = boolean(),
      security = array(definitions.securityRequirement, uniqueItems(true)),
      servers = array(definitions.server, uniqueItems(true)),
      externalDocs = definitions.externalDocs,
      operationId = string(),
      parameters = array(definitions.parameterOrReference, uniqueItems(true))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Describes a single API operation on a path."
  }
  definitions "reference" {
    type = "object"
    required = ["$ref"]
    properties = {
      "$ref" = string(),
      summary = string(),
      description = string()
    }
    additionalProperties = false
    description = "A simple object to allow referencing other components in the specification, internally and externally.  The Reference Object is defined by JSON Reference and follows the same structure, behavior and rules.   For this specification, reference resolution is accomplished as defined by the JSON Reference specification and not by the JSON Schema specification."
  }
  definitions "mediaTypes" {
    type = "map"
    additionalProperties = definitions.mediaType
  }
  definitions "contact" {
    type = "object"
    properties = {
      name = string(),
      url = string(format("uri")),
      email = string(format("email"))
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Contact information for the exposed API."
  }
  definitions "parameter" {
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Describes a single operation parameter.  A unique parameter is defined by a combination of a name and location."
    type = "object"
    required = ["name", "in"]
    properties = {
      in = string(),
      description = string(),
      required = boolean(),
      deprecated = boolean(),
      style = string(),
      explode = boolean(),
      name = string(),
      allowReserved = boolean(),
      schema = definitions.schemaOrReference,
      example = definitions.any,
      examples = definitions.examplesOrReferences,
      content = definitions.mediaTypes,
      allowEmptyValue = boolean()
    }
  }
  definitions "callback" {
    type = "object"
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension,
      "^" = definitions.pathItem
    }
    description = "A map of possible out-of band callbacks related to the parent operation. Each value in the map is a Path Item Object that describes a set of requests that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation."
  }
  definitions "responsesOrReferences" {
    type = "map"
    additionalProperties = definitions.responseOrReference
  }
  definitions "any" {
    additionalProperties = true
  }
  definitions "server" {
    type = "object"
    required = ["url"]
    properties = {
      variables = definitions.serverVariables,
      url = string(),
      description = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "An object representing a Server."
  }
  definitions "serverVariable" {
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "An object representing a Server Variable for server URL template substitution."
    type = "object"
    required = ["default"]
    properties = {
      enum = array(string(), uniqueItems(true)),
      default = string(),
      description = string()
    }
  }
  definitions "parameterOrReference" {
    oneOf = [definitions.parameter, definitions.reference]
  }
  definitions "externalDocs" {
    description = "Allows referencing an external resource for extended documentation."
    type = "object"
    required = ["url"]
    properties = {
      description = string(),
      url = string()
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
  }
  definitions "examplesOrReferences" {
    type = "map"
    additionalProperties = definitions.exampleOrReference
  }
  definitions "serverVariables" {
    type = "map"
    additionalProperties = definitions.serverVariable
  }
  definitions "securitySchemesOrReferences" {
    type = "map"
    additionalProperties = definitions.securitySchemeOrReference
  }
  definitions "anyOrExpression" {
    oneOf = [definitions.any, definitions.expression]
  }
  definitions "linkOrReference" {
    oneOf = [definitions.link, definitions.reference]
  }
  definitions "schemaOrReference" {
    oneOf = [definitions.schema, definitions.reference]
  }
  definitions "pathItem" {
    type = "object"
    properties = {
      parameters = array(definitions.parameterOrReference, uniqueItems(true)),
      summary = string(),
      put = definitions.operation,
      delete = definitions.operation,
      patch = definitions.operation,
      trace = definitions.operation,
      servers = array(definitions.server, uniqueItems(true)),
      "$ref" = string(),
      description = string(),
      get = definitions.operation,
      post = definitions.operation,
      options = definitions.operation,
      head = definitions.operation
    }
    additionalProperties = false
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Describes the operations available on a single path. A Path Item MAY be empty, due to ACL constraints. The path itself is still exposed to the documentation viewer but they will not know which operations and parameters are available."
  }
  definitions "tag" {
    patternProperties = {
      "^x-" = definitions.specificationExtension
    }
    description = "Adds metadata to a single tag that is used by the Operation Object. It is not mandatory to have a Tag Object per tag defined in the Operation Object instances."
    type = "object"
    required = ["name"]
    properties = {
      name = string(),
      description = string(),
      externalDocs = definitions.externalDocs
    }
    additionalProperties = false
  }
  definitions "requestBodiesOrReferences" {
    type = "map"
    additionalProperties = definitions.requestBodyOrReference
  }
