
  schema = "http://json-schema.org/draft-04/schema#"
  id = "http://openapis.org/v3/schema.json#"
  title = "A JSON Schema for OpenAPI 3.0."
  properties = {
    security = array(definitions.securityRequirement, uniqueItems(true)),
    tags = array(definitions.tag, uniqueItems(true)),
    externalDocs = definitions.externalDocs,
    openapi = string(),
    info = definitions.info,
    servers = array(definitions.server, uniqueItems(true)),
    paths = definitions.paths,
    components = definitions.components
  }
  additionalProperties = false
  patternProperties = {
    "^x-" = definitions.specificationExtension
  }
  description = "This is the root document object of the OpenAPI document."
  type = "object"
  required = ["openapi", "info", "paths"]
  definitions {
    examplesOrReferences = map(definitions.exampleOrReference)
    linksOrReferences = map(definitions.linkOrReference)
    expression = map(true)
    schemasOrReferences = map(definitions.schemaOrReference)
    parametersOrReferences = map(definitions.parameterOrReference)
    responsesOrReferences = map(definitions.responseOrReference)
    requestBodiesOrReferences = map(definitions.requestBodyOrReference)
    callbacksOrReferences = map(definitions.callbackOrReference)
    mediaTypes = map(definitions.mediaType)
    encodings = map(definitions.encoding)
    object = map(true)
    headersOrReferences = map(definitions.headerOrReference)
    serverVariables = map(definitions.serverVariable)
    strings = map(string())
    securitySchemesOrReferences = map(definitions.securitySchemeOrReference)
    defaultType {
      oneOf = [{
        type = "null"
      }, array(), object(), number(), boolean(), string()]
    }
    contact {
      properties = {
        email = string(format("email")),
        name = string(),
        url = string(format("uri"))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Contact information for the exposed API."
      type = "object"
    }
    securityScheme {
      properties = {
        name = string(),
        in = string(),
        scheme = string(),
        bearerFormat = string(),
        flows = definitions.oauthFlows,
        openIdConnectUrl = string(),
        type = string(),
        description = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Defines a security scheme that can be used by the operations. Supported schemes are HTTP authentication, an API key (either as a header, a cookie parameter or as a query parameter), mutual TLS (use of a client certificate), OAuth2's common flows (implicit, password, application and access code) as defined in RFC6749, and OpenID Connect.   Please note that currently (2019) the implicit flow is about to be deprecated OAuth 2.0 Security Best Current Practice. Recommended for most use case is Authorization Code Grant flow with PKCE."
      type = "object"
      required = ["type"]
    }
    components {
      type = "object"
      properties = {
        responses = definitions.responsesOrReferences,
        parameters = definitions.parametersOrReferences,
        examples = definitions.examplesOrReferences,
        securitySchemes = definitions.securitySchemesOrReferences,
        schemas = definitions.schemasOrReferences,
        requestBodies = definitions.requestBodiesOrReferences,
        links = definitions.linksOrReferences,
        callbacks = definitions.callbacksOrReferences,
        headers = definitions.headersOrReferences
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Holds a set of reusable objects for different aspects of the OAS. All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object."
    }
    schema {
      description = "The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is an extended subset of the JSON Schema Specification Wright Draft 00.  For more information about the properties, see JSON Schema Core and JSON Schema Validation. Unless stated otherwise, the property definitions follow the JSON Schema."
      type = "object"
      properties = {
        enum = properties.enum,
        minProperties = properties.minProperties,
        xml = definitions.xml,
        maxProperties = properties.maxProperties,
        maxItems = properties.maxItems,
        maxLength = properties.maxLength,
        deprecated = boolean(),
        oneOf = array(definitions.schemaOrReference, minItems(1)),
        maximum = properties.maximum,
        description = string(),
        nullable = boolean(),
        allOf = array(definitions.schemaOrReference, minItems(1)),
        exclusiveMaximum = properties.exclusiveMaximum,
        format = string(),
        required = properties.required,
        default = definitions.defaultType,
        minimum = properties.minimum,
        multipleOf = properties.multipleOf,
        minLength = properties.minLength,
        discriminator = definitions.discriminator,
        minItems = properties.minItems,
        exclusiveMinimum = properties.exclusiveMinimum,
        anyOf = array(definitions.schemaOrReference, minItems(1)),
        uniqueItems = properties.uniqueItems,
        externalDocs = definitions.externalDocs,
        example = definitions.any,
        type = string(),
        not = definitions.schema,
        properties = map(definitions.schemaOrReference),
        pattern = properties.pattern,
        title = properties.title,
        writeOnly = boolean(),
        readOnly = boolean(),
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
    }
    any {
      additionalProperties = true
    }
    parameter {
      required = ["name", "in"]
      properties = {
        content = definitions.mediaTypes,
        required = boolean(),
        style = string(),
        deprecated = boolean(),
        allowEmptyValue = boolean(),
        examples = definitions.examplesOrReferences,
        explode = boolean(),
        name = string(),
        description = string(),
        allowReserved = boolean(),
        schema = definitions.schemaOrReference,
        example = definitions.any,
        in = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Describes a single operation parameter.  A unique parameter is defined by a combination of a name and location."
      type = "object"
    }
    discriminator {
      description = "When request bodies or response payloads may be one of a number of different schemas, a `discriminator` object can be used to aid in serialization, deserialization, and validation.  The discriminator is a specific object in a schema which is used to inform the consumer of the specification of an alternative schema based on the value associated with it.  When using the discriminator, _inline_ schemas will not be considered."
      type = "object"
      required = ["propertyName"]
      properties = {
        propertyName = string(),
        mapping = definitions.strings
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
    }
    xml {
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
    anyOrExpression {
      oneOf = [definitions.any, definitions.expression]
    }
    oauthFlows {
      type = "object"
      properties = {
        password = definitions.oauthFlow,
        clientCredentials = definitions.oauthFlow,
        authorizationCode = definitions.oauthFlow,
        implicit = definitions.oauthFlow
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Allows configuration of the supported OAuth Flows."
    }
    license {
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
      type = "object"
    }
    pathItem {
      type = "object"
      properties = {
        head = definitions.operation,
        patch = definitions.operation,
        parameters = array(definitions.parameterOrReference, uniqueItems(true)),
        summary = string(),
        delete = definitions.operation,
        get = definitions.operation,
        put = definitions.operation,
        "$ref" = string(),
        description = string(),
        post = definitions.operation,
        options = definitions.operation,
        trace = definitions.operation,
        servers = array(definitions.server, uniqueItems(true))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Describes the operations available on a single path. A Path Item MAY be empty, due to ACL constraints. The path itself is still exposed to the documentation viewer but they will not know which operations and parameters are available."
    }
    operation {
      properties = {
        externalDocs = definitions.externalDocs,
        requestBody = definitions.requestBodyOrReference,
        deprecated = boolean(),
        security = array(definitions.securityRequirement, uniqueItems(true)),
        tags = array(string(), uniqueItems(true)),
        responses = definitions.responses,
        servers = array(definitions.server, uniqueItems(true)),
        description = string(),
        operationId = string(),
        callbacks = definitions.callbacksOrReferences,
        summary = string(),
        parameters = array(definitions.parameterOrReference, uniqueItems(true))
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "Describes a single API operation on a path."
      type = "object"
      required = ["responses"]
    }
    securitySchemeOrReference {
      oneOf = [definitions.securityScheme, definitions.reference]
    }
    paths {
      description = "Holds the relative paths to the individual endpoints and their operations. The path is appended to the URL from the `Server Object` in order to construct the full URL.  The Paths MAY be empty, due to ACL constraints."
      type = "object"
      additionalProperties = false
      patternProperties = {
        "^/" = definitions.pathItem,
        "^x-" = definitions.specificationExtension
      }
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
    responseOrReference {
      oneOf = [definitions.response, definitions.reference]
    }
    link {
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
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "The `Link object` represents a possible design-time link for a response. The presence of a link does not guarantee the caller's ability to successfully invoke it, rather it provides a known relationship and traversal mechanism between responses and other operations.  Unlike _dynamic_ links (i.e. links provided **in** the response payload), the OAS linking mechanism does not require link information in the runtime response.  For computing links, and providing instructions to execute them, a runtime expression is used for accessing values in an operation and using them as parameters while invoking the linked operation."
    }
    info {
      properties = {
        title = string(),
        description = string(),
        termsOfService = string(),
        contact = definitions.contact,
        license = definitions.license,
        version = string(),
        summary = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "The object provides metadata about the API. The metadata MAY be used by the clients if needed, and MAY be presented in editing or documentation generation tools for convenience."
      type = "object"
      required = ["title", "version"]
    }
    example {
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = ""
      type = "object"
      properties = {
        description = string(),
        value = definitions.any,
        externalValue = string(),
        summary = string()
      }
      additionalProperties = false
    }
    oauthFlow {
      description = "Configuration details for a supported OAuth Flow"
      type = "object"
      properties = {
        refreshUrl = string(),
        scopes = definitions.strings,
        authorizationUrl = string(),
        tokenUrl = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
    }
    parameterOrReference {
      oneOf = [definitions.parameter, definitions.reference]
    }
    callback {
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension,
        "^" = definitions.pathItem
      }
      description = "A map of possible out-of band callbacks related to the parent operation. Each value in the map is a Path Item Object that describes a set of requests that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation."
      type = "object"
    }
    header {
      type = "object"
      properties = {
        examples = definitions.examplesOrReferences,
        description = string(),
        style = string(),
        example = definitions.any,
        content = definitions.mediaTypes,
        required = boolean(),
        allowEmptyValue = boolean(),
        allowReserved = boolean(),
        explode = boolean(),
        schema = definitions.schemaOrReference,
        deprecated = boolean()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "The Header Object follows the structure of the Parameter Object with the following changes:  1. `name` MUST NOT be specified, it is given in the corresponding `headers` map. 1. `in` MUST NOT be specified, it is implicitly in `header`. 1. All traits that are affected by the location MUST be applicable to a location of `header` (for example, `style`)."
    }
    linkOrReference {
      oneOf = [definitions.link, definitions.reference]
    }
    response {
      description = "Describes a single response from an API Operation, including design-time, static  `links` to operations based on the response."
      type = "object"
      required = ["description"]
      properties = {
        description = string(),
        headers = definitions.headersOrReferences,
        content = definitions.mediaTypes,
        links = definitions.linksOrReferences
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
    }
    callbackOrReference {
      oneOf = [definitions.callback, definitions.reference]
    }
    serverVariable {
      description = "An object representing a Server Variable for server URL template substitution."
      type = "object"
      required = ["default"]
      properties = {
        description = string(),
        enum = array(string(), uniqueItems(true)),
        default = string()
      }
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
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
      patternProperties = {
        "^x-" = definitions.specificationExtension,
        "^([0-9X]{3})$" = definitions.responseOrReference
      }
      description = "A container for the expected responses of an operation. The container maps a HTTP response code to the expected response.  The documentation is not necessarily expected to cover all possible HTTP response codes because they may not be known in advance. However, documentation is expected to cover a successful operation response and any known errors.  The `default` MAY be used as a default response object for all HTTP codes  that are not covered individually by the specification.  The `Responses Object` MUST contain at least one response code, and it  SHOULD be the response for a successful operation call."
      type = "object"
      properties = {
        default = definitions.responseOrReference
      }
      additionalProperties = false
    }
    exampleOrReference {
      oneOf = [definitions.example, definitions.reference]
    }
    securityRequirement {
      type = "object"
      additionalProperties = array(string(), uniqueItems(true))
      description = "Lists the required security schemes to execute this operation. The name used for each property MUST correspond to a security scheme declared in the Security Schemes under the Components Object.  Security Requirement Objects that contain multiple schemes require that all schemes MUST be satisfied for a request to be authorized. This enables support for scenarios where multiple query parameters or HTTP headers are required to convey security information.  When a list of Security Requirement Objects is defined on the OpenAPI Object or Operation Object, only one of the Security Requirement Objects in the list needs to be satisfied to authorize the request."
    }
    headerOrReference {
      oneOf = [definitions.header, definitions.reference]
    }
    schemaOrReference {
      oneOf = [definitions.schema, definitions.reference]
    }
    server {
      description = "An object representing a Server."
      type = "object"
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
    }
    externalDocs {
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
      type = "object"
    }
    encoding {
      additionalProperties = false
      patternProperties = {
        "^x-" = definitions.specificationExtension
      }
      description = "A single encoding definition applied to a single schema property."
      type = "object"
      properties = {
        contentType = string(),
        headers = definitions.headersOrReferences,
        style = string(),
        explode = boolean(),
        allowReserved = boolean()
      }
    }
    specificationExtension {
      oneOf = [{
        type = "null"
      }, number(), boolean(), string(), object(), array()]
      description = "Any property starting with x- is valid."
    }
    requestBody {
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
      type = "object"
    }
    tag {
      description = "Adds metadata to a single tag that is used by the Operation Object. It is not mandatory to have a Tag Object per tag defined in the Operation Object instances."
      type = "object"
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
    }
    requestBodyOrReference {
      oneOf = [definitions.requestBody, definitions.reference]
    }
  }
