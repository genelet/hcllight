
  anyOf = [{
    required = ["paths"]
  }, {
    required = ["components"]
  }, {
    required = ["webhooks"]
  }]
  description = "The description of OpenAPI v3.1.x documents without schema validation, as defined by https://spec.openapis.org/oas/v3.1.0"
  type = "object"
  required = ["openapi", "info"]
  schema = "https://json-schema.org/draft/2020-12/schema"
  properties {
    tags = array($defs.tag)
    openapi = string(pattern("^3\.1\.\d+(-.+)?$"))
    info = $defs.info
    components = $defs.components
    externalDocs = $defs.external-documentation
    servers = array($defs.server, default())
    webhooks = map($defs.path-item)
    security = array($defs.security-requirement)
    jsonSchemaDialect = string(format("uri"), default("https://spec.openapis.org/oas/3.1/dialect/base"))
    paths = $defs.paths
  }
