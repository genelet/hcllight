
  required = ["openapi", "info"]
  schema = "https://json-schema.org/draft/2020-12/schema"
  anyOf = [{
    required = ["paths"]
  }, {
    required = ["components"]
  }, {
    required = ["webhooks"]
  }]
  description = "The description of OpenAPI v3.1.x documents without schema validation, as defined by https://spec.openapis.org/oas/v3.1.0"
  type = "object"
  properties {
    paths = $defs.paths
    webhooks = map($defs.path-item)
    security = array($defs.security-requirement)
    tags = array($defs.tag)
    externalDocs = $defs.external-documentation
    jsonSchemaDialect = string(format("uri"), default("https://spec.openapis.org/oas/3.1/dialect/base"))
    servers = array($defs.server, default())
    info = $defs.info
    components = $defs.components
    openapi = string(pattern("^3\.1\.\d+(-.+)?$"))
  }
