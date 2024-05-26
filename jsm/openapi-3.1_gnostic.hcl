
  type = "object"
  required = ["openapi", "info", "paths"]
  properties = {
    paths = definitions.paths,
    components = definitions.components,
    security = array(definitions.securityRequirement, uniqueItems(true)),
    tags = array(definitions.tag, uniqueItems(true)),
    externalDocs = definitions.externalDocs,
    openapi = string(),
    info = definitions.info,
    servers = array(definitions.server, uniqueItems(true))
  }
  schema = "http://json-schema.org/draft-04/schema#"
  id = "http://openapis.org/v3/schema.json#"
  title = "A JSON Schema for OpenAPI 3.0."
  description = "This is the root document object of the OpenAPI document."
  additionalProperties = false
  patternProperties = {
    "^x-" = definitions.specificationExtension
  }
  definitions {
    responsesOrReferences = map(definitions.responseOrReference)
    headersOrReferences = map(definitions.headerOrReference)
    parametersOrReferences = map(definitions.parameterOrReference)
    mediaTypes = map(definitions.mediaType)
    object = map(true)
    strings = map(string())
    examplesOrReferences = map(definitions.exampleOrReference)
    callbacksOrReferences = map(definitions.callbackOrReference)
    requestBodiesOrReferences = map(definitions.requestBodyOrReference)
    linksOrReferences = map(definitions.linkOrReference)
    serverVariables = map(definitions.serverVariable)
    schemasOrReferences = map(definitions.schemaOrReference)
    expression = map(true)
    securitySchemesOrReferences = map(definitions.securitySchemeOrReference)
    encodings = map(definitions.encoding)
    header {
      type = "object"
      properties = {
        example = definitions.any,
        description = string(),
        deprecated = boolean(),
        style = string(),
        examples = definitions.examplesOrReferences,
        content = definitions.mediaTypes,
        allowEmptyValue = boolean(),
        schema = definitions.schemaOrReference,
        explode = boolean(),
        required = boolean(),
        allowReserved = boolean()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "The Header Object follows the structure of the Parameter Object with the following changes:  1. `name` MUST NOT be specified, it is given in the corresponding `headers` map. 1. `in` MUST NOT be specified, it is implicitly in `header`. 1. All traits that are affected by the location MUST be applicable to a location of `header` (for example, `style`)."
    }
    reference {
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
    schema {
      properties = {
        description = string(),
        anyOf = array(definitions.schemaOrReference, minItems(1)),
        title = properties.title,
        default = definitions.defaultType,
        enum = properties.enum,
        oneOf = array(definitions.schemaOrReference, minItems(1)),
        not = definitions.schema,
        maxLength = properties.maxLength,
        xml = definitions.xml,
        example = definitions.any,
        format = string(),
        uniqueItems = properties.uniqueItems,
        minLength = properties.minLength,
        minItems = properties.minItems,
        writeOnly = boolean(),
        exclusiveMinimum = properties.exclusiveMinimum,
        minProperties = properties.minProperties,
        allOf = array(definitions.schemaOrReference, minItems(1)),
        maxProperties = properties.maxProperties,
        required = properties.required,
        multipleOf = properties.multipleOf,
        nullable = boolean(),
        deprecated = boolean(),
        type = string(),
        readOnly = boolean(),
        maximum = properties.maximum,
        externalDocs = definitions.externalDocs,
        properties = map(definitions.schemaOrReference),
        discriminator = definitions.discriminator,
        minimum = properties.minimum,
        exclusiveMaximum = properties.exclusiveMaximum,
        maxItems = properties.maxItems,
        pattern = properties.pattern,
        additionalProperties = {
          oneOf = [definitions.schemaOrReference, boolean()]
        },
        items = {
          anyOf = [definitions.schemaOrReference, array(definitions.schemaOrReference, minItems(1))]
        }
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is an extended subset of the JSON Schema Specification Wright Draft 00.  For more information about the properties, see JSON Schema Core and JSON Schema Validation. Unless stated otherwise, the property definitions follow the JSON Schema."
      type = "object"
    }
    contact {
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
      type = "object"
    }
    operation {
      description = "Describes a single API operation on a path."
      type = "object"
      required = ["responses"]
      properties = {
        callbacks = definitions.callbacksOrReferences,
        operationId = string(),
        parameters = array(definitions.parameterOrReference, uniqueItems(true)),
        summary = string(),
        responses = definitions.responses,
        tags = array(string(), uniqueItems(true)),
        requestBody = definitions.requestBodyOrReference,
        deprecated = boolean(),
        servers = array(definitions.server, uniqueItems(true)),
        description = string(),
        externalDocs = definitions.externalDocs,
        security = array(definitions.securityRequirement, uniqueItems(true))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
    }
    xml {
      type = "object"
      properties = {
        attribute = boolean(),
        wrapped = boolean(),
        name = string(),
        namespace = string(),
        prefix = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "A metadata object that allows for more fine-tuned XML model definitions.  When using arrays, XML element names are *not* inferred (for singular/plural forms) and the `name` property SHOULD be used to add that information. See examples for expected behavior."
    }
    responseOrReference {
      oneOf = [definitions.response, definitions.reference]
    }
    response {
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Describes a single response from an API Operation, including design-time, static  `links` to operations based on the response."
      type = "object"
      required = ["description"]
      properties = {
        description = string(),
        headers = definitions.headersOrReferences,
        content = definitions.mediaTypes,
        links = definitions.linksOrReferences
      }
    }
    components {
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Holds a set of reusable objects for different aspects of the OAS. All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object."
      type = "object"
      properties = {
        links = definitions.linksOrReferences,
        schemas = definitions.schemasOrReferences,
        headers = definitions.headersOrReferences,
        responses = definitions.responsesOrReferences,
        parameters = definitions.parametersOrReferences,
        examples = definitions.examplesOrReferences,
        callbacks = definitions.callbacksOrReferences,
        requestBodies = definitions.requestBodiesOrReferences,
        securitySchemes = definitions.securitySchemesOrReferences
      }
      additionalProperties = false
    }
    example {
      description = ""
      type = "object"
      properties = {
        externalValue = string(),
        summary = string(),
        description = string(),
        value = definitions.any
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
    }
    linkOrReference {
      oneOf = [definitions.link, definitions.reference]
    }
    securitySchemeOrReference {
      oneOf = [definitions.securityScheme, definitions.reference]
    }
    specificationExtension {
      oneOf = [{
        type = "null"
      }, number(), boolean(), string(), object(), array()]
      description = "Any property starting with x- is valid."
    }
    server {
      required = ["url"]
      properties = {
        url = string(),
        description = string(),
        variables = definitions.serverVariables
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "An object representing a Server."
      type = "object"
    }
    parameter {
      type = "object"
      required = ["name", "in"]
      properties = {
        content = definitions.mediaTypes,
        description = string(),
        style = string(),
        required = boolean(),
        name = string(),
        example = definitions.any,
        explode = boolean(),
        examples = definitions.examplesOrReferences,
        schema = definitions.schemaOrReference,
        in = string(),
        deprecated = boolean(),
        allowEmptyValue = boolean(),
        allowReserved = boolean()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Describes a single operation parameter.  A unique parameter is defined by a combination of a name and location."
    }
    encoding {
      description = "A single encoding definition applied to a single schema property."
      type = "object"
      properties = {
        contentType = string(),
        headers = definitions.headersOrReferences,
        style = string(),
        explode = boolean(),
        allowReserved = boolean()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
    }
    tag {
      required = ["name"]
      properties = {
        name = string(),
        description = string(),
        externalDocs = definitions.externalDocs
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Adds metadata to a single tag that is used by the Operation Object. It is not mandatory to have a Tag Object per tag defined in the Operation Object instances."
      type = "object"
    }
    requestBodyOrReference {
      oneOf = [definitions.requestBody, definitions.reference]
    }
    oauthFlows {
      type = "object"
      properties = {
        implicit = definitions.oauthFlow,
        password = definitions.oauthFlow,
        clientCredentials = definitions.oauthFlow,
        authorizationCode = definitions.oauthFlow
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Allows configuration of the supported OAuth Flows."
    }
    exampleOrReference {
      oneOf = [definitions.example, definitions.reference]
    }
    parameterOrReference {
      oneOf = [definitions.parameter, definitions.reference]
    }
    any {
      additionalProperties = true
    }
    license {
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "License information for the exposed API."
      type = "object"
      required = ["name"]
      properties = {
        name = string(),
        url = string()
      }
    }
    paths {
      type = "object"
      additionalProperties = false
      patternProperties = {
        "^/" = definitions.pathItem,
        "^x-" = definitions.specificationExtension
      }
      description = "Holds the relative paths to the individual endpoints and their operations. The path is appended to the URL from the `Server Object` in order to construct the full URL.  The Paths MAY be empty, due to ACL constraints."
    }
    pathItem {
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Describes the operations available on a single path. A Path Item MAY be empty, due to ACL constraints. The path itself is still exposed to the documentation viewer but they will not know which operations and parameters are available."
      type = "object"
      properties = {
        head = definitions.operation,
        put = definitions.operation,
        parameters = array(definitions.parameterOrReference, uniqueItems(true)),
        patch = definitions.operation,
        servers = array(definitions.server, uniqueItems(true)),
        options = definitions.operation,
        summary = string(),
        post = definitions.operation,
        description = string(),
        get = definitions.operation,
        trace = definitions.operation,
        "$ref" = string(),
        delete = definitions.operation
      }
      additionalProperties = false
    }
    oauthFlow {
      type = "object"
      properties = {
        scopes = definitions.strings,
        authorizationUrl = string(),
        tokenUrl = string(),
        refreshUrl = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Configuration details for a supported OAuth Flow"
    }
    headerOrReference {
      oneOf = [definitions.header, definitions.reference]
    }
    discriminator {
      type = "object"
      required = ["propertyName"]
      properties = {
        mapping = definitions.strings,
        propertyName = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "When request bodies or response payloads may be one of a number of different schemas, a `discriminator` object can be used to aid in serialization, deserialization, and validation.  The discriminator is a specific object in a schema which is used to inform the consumer of the specification of an alternative schema based on the value associated with it.  When using the discriminator, _inline_ schemas will not be considered."
    }
    requestBody {
      description = "Describes a single request body."
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
    }
    callback {
      additionalProperties = false
      patternProperties = {
        "^" = definitions.pathItem,
        "^x-" = definitions.specificationExtension
      }
      description = "A map of possible out-of band callbacks related to the parent operation. Each value in the map is a Path Item Object that describes a set of requests that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation."
      type = "object"
    }
    link {
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "The `Link object` represents a possible design-time link for a response. The presence of a link does not guarantee the caller's ability to successfully invoke it, rather it provides a known relationship and traversal mechanism between responses and other operations.  Unlike _dynamic_ links (i.e. links provided **in** the response payload), the OAS linking mechanism does not require link information in the runtime response.  For computing links, and providing instructions to execute them, a runtime expression is used for accessing values in an operation and using them as parameters while invoking the linked operation."
      type = "object"
      properties = {
        description = string(),
        server = definitions.server,
        operationRef = string(),
        operationId = string(),
        parameters = definitions.anyOrExpression,
        requestBody = definitions.anyOrExpression
      }
      additionalProperties = false
    }
    securityScheme {
      type = "object"
      required = ["type"]
      properties = {
        scheme = string(),
        bearerFormat = string(),
        flows = definitions.oauthFlows,
        openIdConnectUrl = string(),
        type = string(),
        description = string(),
        name = string(),
        in = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Defines a security scheme that can be used by the operations. Supported schemes are HTTP authentication, an API key (either as a header, a cookie parameter or as a query parameter), mutual TLS (use of a client certificate), OAuth2's common flows (implicit, password, application and access code) as defined in RFC6749, and OpenID Connect.   Please note that currently (2019) the implicit flow is about to be deprecated OAuth 2.0 Security Best Current Practice. Recommended for most use case is Authorization Code Grant flow with PKCE."
    }
    securityRequirement {
      type = "object"
      additionalProperties = array(string(), uniqueItems(true))
      description = "Lists the required security schemes to execute this operation. The name used for each property MUST correspond to a security scheme declared in the Security Schemes under the Components Object.  Security Requirement Objects that contain multiple schemes require that all schemes MUST be satisfied for a request to be authorized. This enables support for scenarios where multiple query parameters or HTTP headers are required to convey security information.  When a list of Security Requirement Objects is defined on the OpenAPI Object or Operation Object, only one of the Security Requirement Objects in the list needs to be satisfied to authorize the request."
    }
    info {
      required = ["title", "version"]
      properties = {
        summary = string(),
        title = string(),
        description = string(),
        termsOfService = string(),
        contact = definitions.contact,
        license = definitions.license,
        version = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "The object provides metadata about the API. The metadata MAY be used by the clients if needed, and MAY be presented in editing or documentation generation tools for convenience."
      type = "object"
    }
    externalDocs {
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
      description = "Allows referencing an external resource for extended documentation."
    }
    anyOrExpression {
      oneOf = [definitions.any, definitions.expression]
    }
    defaultType {
      oneOf = [{
        type = "null"
      }, array(), object(), number(), boolean(), string()]
    }
    serverVariable {
      type = "object"
      required = ["default"]
      properties = {
        default = string(),
        description = string(),
        enum = array(string(), uniqueItems(true))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "An object representing a Server Variable for server URL template substitution."
    }
    mediaType {
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
    responses {
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
    callbackOrReference {
      oneOf = [definitions.callback, definitions.reference]
    }
    schemaOrReference {
      oneOf = [definitions.schema, definitions.reference]
    }
  }
