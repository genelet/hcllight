
  schema = "http://json-schema.org/draft-04/schema#"
  id = "http://openapis.org/v3/schema.json#"
  title = "A JSON Schema for OpenAPI 3.0."
  description = "This is the root document object of the OpenAPI document."
  type = "object"
  required = ["openapi", "info", "paths"]
  additionalProperties = false
  properties {
    info = definitions.info
    servers = array(definitions.server, uniqueItems(true))
    paths = definitions.paths
    components = definitions.components
    security = array(definitions.securityRequirement, uniqueItems(true))
    tags = array(definitions.tag, uniqueItems(true))
    externalDocs = definitions.externalDocs
    openapi = string()
  }
  patternProperties {
    ^x- = definitions.specificationExtension
  }
  definitions {
    expression = map(true)
    securitySchemesOrReferences = map(definitions.securitySchemeOrReference)
    strings = map(string())
    schemasOrReferences = map(definitions.schemaOrReference)
    mediaTypes = map(definitions.mediaType)
    object = map(true)
    responsesOrReferences = map(definitions.responseOrReference)
    linksOrReferences = map(definitions.linkOrReference)
    examplesOrReferences = map(definitions.exampleOrReference)
    parametersOrReferences = map(definitions.parameterOrReference)
    encodings = map(definitions.encoding)
    headersOrReferences = map(definitions.headerOrReference)
    requestBodiesOrReferences = map(definitions.requestBodyOrReference)
    serverVariables = map(definitions.serverVariable)
    callbacksOrReferences = map(definitions.callbackOrReference)
    any {
      additionalProperties = true
    }
    pathItem {
      type = "object"
      additionalProperties = false
      description = "Describes the operations available on a single path. A Path Item MAY be empty, due to ACL constraints. The path itself is still exposed to the documentation viewer but they will not know which operations and parameters are available."
      properties {
        trace = definitions.operation
        $ref = string()
        post = definitions.operation
        servers = array(definitions.server, uniqueItems(true))
        parameters = array(definitions.parameterOrReference, uniqueItems(true))
        put = definitions.operation
        head = definitions.operation
        patch = definitions.operation
        get = definitions.operation
        delete = definitions.operation
        options = definitions.operation
        summary = string()
        description = string()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    exampleOrReference {
      oneOf = [definitions.example, definitions.reference]
    }
    operation {
      type = "object"
      required = ["responses"]
      additionalProperties = false
      description = "Describes a single API operation on a path."
      properties {
        servers = array(definitions.server, uniqueItems(true))
        description = string()
        parameters = array(definitions.parameterOrReference, uniqueItems(true))
        requestBody = definitions.requestBodyOrReference
        summary = string()
        responses = definitions.responses
        callbacks = definitions.callbacksOrReferences
        deprecated = boolean()
        tags = array(string(), uniqueItems(true))
        operationId = string()
        security = array(definitions.securityRequirement, uniqueItems(true))
        externalDocs = definitions.externalDocs
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    license {
      type = "object"
      required = ["name"]
      additionalProperties = false
      description = "License information for the exposed API."
      properties {
        name = string()
        url = string()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    link {
      type = "object"
      additionalProperties = false
      description = "The `Link object` represents a possible design-time link for a response. The presence of a link does not guarantee the caller's ability to successfully invoke it, rather it provides a known relationship and traversal mechanism between responses and other operations.  Unlike _dynamic_ links (i.e. links provided **in** the response payload), the OAS linking mechanism does not require link information in the runtime response.  For computing links, and providing instructions to execute them, a runtime expression is used for accessing values in an operation and using them as parameters while invoking the linked operation."
      properties {
        operationRef = string()
        operationId = string()
        parameters = definitions.anyOrExpression
        requestBody = definitions.anyOrExpression
        description = string()
        server = definitions.server
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    info {
      description = "The object provides metadata about the API. The metadata MAY be used by the clients if needed, and MAY be presented in editing or documentation generation tools for convenience."
      type = "object"
      required = ["title", "version"]
      additionalProperties = false
      properties {
        summary = string()
        title = string()
        description = string()
        termsOfService = string()
        contact = definitions.contact
        license = definitions.license
        version = string()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    components {
      type = "object"
      additionalProperties = false
      description = "Holds a set of reusable objects for different aspects of the OAS. All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object."
      properties {
        callbacks = definitions.callbacksOrReferences
        links = definitions.linksOrReferences
        schemas = definitions.schemasOrReferences
        parameters = definitions.parametersOrReferences
        examples = definitions.examplesOrReferences
        headers = definitions.headersOrReferences
        requestBodies = definitions.requestBodiesOrReferences
        responses = definitions.responsesOrReferences
        securitySchemes = definitions.securitySchemesOrReferences
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    encoding {
      type = "object"
      additionalProperties = false
      description = "A single encoding definition applied to a single schema property."
      properties {
        allowReserved = boolean()
        contentType = string()
        headers = definitions.headersOrReferences
        style = string()
        explode = boolean()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    contact {
      type = "object"
      additionalProperties = false
      description = "Contact information for the exposed API."
      properties {
        email = string(format("email"))
        name = string()
        url = string(format("uri"))
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    responseOrReference {
      oneOf = [definitions.response, definitions.reference]
    }
    callbackOrReference {
      oneOf = [definitions.callback, definitions.reference]
    }
    header {
      type = "object"
      additionalProperties = false
      description = "The Header Object follows the structure of the Parameter Object with the following changes:  1. `name` MUST NOT be specified, it is given in the corresponding `headers` map. 1. `in` MUST NOT be specified, it is implicitly in `header`. 1. All traits that are affected by the location MUST be applicable to a location of `header` (for example, `style`)."
      properties {
        explode = boolean()
        allowReserved = boolean()
        schema = definitions.schemaOrReference
        deprecated = boolean()
        content = definitions.mediaTypes
        required = boolean()
        allowEmptyValue = boolean()
        description = string()
        style = string()
        example = definitions.any
        examples = definitions.examplesOrReferences
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    securitySchemeOrReference {
      oneOf = [definitions.securityScheme, definitions.reference]
    }
    serverVariable {
      type = "object"
      required = ["default"]
      additionalProperties = false
      description = "An object representing a Server Variable for server URL template substitution."
      properties {
        enum = array(string(), uniqueItems(true))
        default = string()
        description = string()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    securityRequirement {
      type = "object"
      additionalProperties = array(string(), uniqueItems(true))
      description = "Lists the required security schemes to execute this operation. The name used for each property MUST correspond to a security scheme declared in the Security Schemes under the Components Object.  Security Requirement Objects that contain multiple schemes require that all schemes MUST be satisfied for a request to be authorized. This enables support for scenarios where multiple query parameters or HTTP headers are required to convey security information.  When a list of Security Requirement Objects is defined on the OpenAPI Object or Operation Object, only one of the Security Requirement Objects in the list needs to be satisfied to authorize the request."
    }
    schemaOrReference {
      oneOf = [definitions.schema, definitions.reference]
    }
    example {
      type = "object"
      additionalProperties = false
      description = ""
      properties {
        summary = string()
        description = string()
        value = definitions.any
        externalValue = string()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    securityScheme {
      type = "object"
      required = ["type"]
      additionalProperties = false
      description = "Defines a security scheme that can be used by the operations. Supported schemes are HTTP authentication, an API key (either as a header, a cookie parameter or as a query parameter), mutual TLS (use of a client certificate), OAuth2's common flows (implicit, password, application and access code) as defined in RFC6749, and OpenID Connect.   Please note that currently (2019) the implicit flow is about to be deprecated OAuth 2.0 Security Best Current Practice. Recommended for most use case is Authorization Code Grant flow with PKCE."
      properties {
        bearerFormat = string()
        flows = definitions.oauthFlows
        openIdConnectUrl = string()
        type = string()
        description = string()
        name = string()
        in = string()
        scheme = string()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    parameter {
      description = "Describes a single operation parameter.  A unique parameter is defined by a combination of a name and location."
      type = "object"
      required = ["name", "in"]
      additionalProperties = false
      properties {
        in = string()
        description = string()
        deprecated = boolean()
        example = definitions.any
        style = string()
        explode = boolean()
        allowReserved = boolean()
        schema = definitions.schemaOrReference
        examples = definitions.examplesOrReferences
        content = definitions.mediaTypes
        required = boolean()
        name = string()
        allowEmptyValue = boolean()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    externalDocs {
      type = "object"
      required = ["url"]
      additionalProperties = false
      description = "Allows referencing an external resource for extended documentation."
      properties {
        description = string()
        url = string()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    callback {
      type = "object"
      additionalProperties = false
      description = "A map of possible out-of band callbacks related to the parent operation. Each value in the map is a Path Item Object that describes a set of requests that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation."
      patternProperties {
        ^x- = definitions.specificationExtension
        ^ = definitions.pathItem
      }
    }
    server {
      type = "object"
      required = ["url"]
      additionalProperties = false
      description = "An object representing a Server."
      properties {
        url = string()
        description = string()
        variables = definitions.serverVariables
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    specificationExtension {
      oneOf = [{
        type = "null"
      }, number(), boolean(), string(), object(), array()]
      description = "Any property starting with x- is valid."
    }
    anyOrExpression {
      oneOf = [definitions.any, definitions.expression]
    }
    headerOrReference {
      oneOf = [definitions.header, definitions.reference]
    }
    linkOrReference {
      oneOf = [definitions.link, definitions.reference]
    }
    tag {
      required = ["name"]
      additionalProperties = false
      description = "Adds metadata to a single tag that is used by the Operation Object. It is not mandatory to have a Tag Object per tag defined in the Operation Object instances."
      type = "object"
      properties {
        description = string()
        externalDocs = definitions.externalDocs
        name = string()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    mediaType {
      type = "object"
      additionalProperties = false
      description = "Each Media Type Object provides schema and examples for the media type identified by its key."
      properties {
        encoding = definitions.encodings
        schema = definitions.schemaOrReference
        example = definitions.any
        examples = definitions.examplesOrReferences
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    schema {
      type = "object"
      additionalProperties = false
      description = "The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is an extended subset of the JSON Schema Specification Wright Draft 00.  For more information about the properties, see JSON Schema Core and JSON Schema Validation. Unless stated otherwise, the property definitions follow the JSON Schema."
      properties {
        default = definitions.defaultType
        nullable = boolean()
        description = string()
        discriminator = definitions.discriminator
        title = properties.title
        minItems = properties.minItems
        maxProperties = properties.maxProperties
        deprecated = boolean()
        properties = map(definitions.schemaOrReference)
        minimum = properties.minimum
        oneOf = array(definitions.schemaOrReference, minItems(1))
        minLength = properties.minLength
        exclusiveMaximum = properties.exclusiveMaximum
        pattern = properties.pattern
        example = definitions.any
        not = definitions.schema
        exclusiveMinimum = properties.exclusiveMinimum
        readOnly = boolean()
        format = string()
        anyOf = array(definitions.schemaOrReference, minItems(1))
        maximum = properties.maximum
        maxItems = properties.maxItems
        multipleOf = properties.multipleOf
        allOf = array(definitions.schemaOrReference, minItems(1))
        required = properties.required
        type = string()
        writeOnly = boolean()
        uniqueItems = properties.uniqueItems
        minProperties = properties.minProperties
        externalDocs = definitions.externalDocs
        xml = definitions.xml
        maxLength = properties.maxLength
        enum = properties.enum
        additionalProperties {
          oneOf = [definitions.schemaOrReference, boolean()]
        }
        items {
          anyOf = [definitions.schemaOrReference, array(definitions.schemaOrReference, minItems(1))]
        }
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    oauthFlows {
      type = "object"
      additionalProperties = false
      description = "Allows configuration of the supported OAuth Flows."
      properties {
        implicit = definitions.oauthFlow
        password = definitions.oauthFlow
        clientCredentials = definitions.oauthFlow
        authorizationCode = definitions.oauthFlow
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    requestBody {
      additionalProperties = false
      description = "Describes a single request body."
      type = "object"
      required = ["content"]
      properties {
        description = string()
        content = definitions.mediaTypes
        required = boolean()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    responses {
      type = "object"
      additionalProperties = false
      description = "A container for the expected responses of an operation. The container maps a HTTP response code to the expected response.  The documentation is not necessarily expected to cover all possible HTTP response codes because they may not be known in advance. However, documentation is expected to cover a successful operation response and any known errors.  The `default` MAY be used as a default response object for all HTTP codes  that are not covered individually by the specification.  The `Responses Object` MUST contain at least one response code, and it  SHOULD be the response for a successful operation call."
      properties {
        default = definitions.responseOrReference
      }
      patternProperties {
        ^([0-9X]{3})$ = definitions.responseOrReference
        ^x- = definitions.specificationExtension
      }
    }
    response {
      type = "object"
      required = ["description"]
      additionalProperties = false
      description = "Describes a single response from an API Operation, including design-time, static  `links` to operations based on the response."
      properties {
        description = string()
        headers = definitions.headersOrReferences
        content = definitions.mediaTypes
        links = definitions.linksOrReferences
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    discriminator {
      required = ["propertyName"]
      additionalProperties = false
      description = "When request bodies or response payloads may be one of a number of different schemas, a `discriminator` object can be used to aid in serialization, deserialization, and validation.  The discriminator is a specific object in a schema which is used to inform the consumer of the specification of an alternative schema based on the value associated with it.  When using the discriminator, _inline_ schemas will not be considered."
      type = "object"
      properties {
        propertyName = string()
        mapping = definitions.strings
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    oauthFlow {
      type = "object"
      additionalProperties = false
      description = "Configuration details for a supported OAuth Flow"
      properties {
        refreshUrl = string()
        scopes = definitions.strings
        authorizationUrl = string()
        tokenUrl = string()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    paths {
      additionalProperties = false
      description = "Holds the relative paths to the individual endpoints and their operations. The path is appended to the URL from the `Server Object` in order to construct the full URL.  The Paths MAY be empty, due to ACL constraints."
      type = "object"
      patternProperties {
        ^/ = definitions.pathItem
        ^x- = definitions.specificationExtension
      }
    }
    xml {
      type = "object"
      additionalProperties = false
      description = "A metadata object that allows for more fine-tuned XML model definitions.  When using arrays, XML element names are *not* inferred (for singular/plural forms) and the `name` property SHOULD be used to add that information. See examples for expected behavior."
      properties {
        attribute = boolean()
        wrapped = boolean()
        name = string()
        namespace = string()
        prefix = string()
      }
      patternProperties {
        ^x- = definitions.specificationExtension
      }
    }
    parameterOrReference {
      oneOf = [definitions.parameter, definitions.reference]
    }
    requestBodyOrReference {
      oneOf = [definitions.requestBody, definitions.reference]
    }
    defaultType {
      oneOf = [{
        type = "null"
      }, array(), object(), number(), boolean(), string()]
    }
    reference {
      type = "object"
      required = ["$ref"]
      additionalProperties = false
      description = "A simple object to allow referencing other components in the specification, internally and externally.  The Reference Object is defined by JSON Reference and follows the same structure, behavior and rules.   For this specification, reference resolution is accomplished as defined by the JSON Reference specification and not by the JSON Schema specification."
      properties {
        $ref = string()
        summary = string()
        description = string()
      }
    }
  }
