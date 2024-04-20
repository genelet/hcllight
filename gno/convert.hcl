
  openapi = "3.0.3"
  info  {
    version = "1.0.0"
    title = "OpenAPI for Vault Database Configuration"
    description = "HTTP API that gives you full access to Config and Authentication. All API routes are prefixed with /v1"
    license  {
      name = "MIT"
    }
  }
  servers = [
    {
      url = "/v1"
      description = "Database Authentication and Configuration"
    }
  ]
  paths "/auth/graphauth/login"  {
    post  {
      responses "200"  {
        description = "Expected response to a valid request"
        content "application/json" "schema"  {
          $ref = "#/components/schemas/ConfigReport"
        }
      }
      responses "403"  {
        description = "User is not authorized"
      }
      responses "default"  {
        description = "unexpected error"
        content "application/json" "schema"  {
          $ref = "#/components/schemas/Error"
        }
      }
      tags = [
        "authentication"
      ]
      summary = "Login to the system"
      operationId = "graphauth-login"
      requestBody  {
        content "application/json" "schema"  {
          $ref = "#/components/schemas/Login"
        }
        required = true
      }
    }
    x-vault-unauthenticated = true
  }
  paths "/auth/graphauth/config" "get"  {
    responses "default"  {
      description = "unexpected error"
      content "application/json" "schema"  {
        $ref = "#/components/schemas/Error"
      }
    }
    responses "200"  {
      description = "Expected response to a valid request"
      content "application/json" "schema"  {
        $ref = "#/components/schemas/ConfigReport"
      }
    }
    security = [
      {
        vaultToken = [
          
        ]
      }
    ]
    summary = "Report current server config"
    operationId = "readAuthConfig"
  }
  paths "/graph/config/generate" "post"  {
    summary = "Generate No-Code Server Programs in HCL"
    operationId = "serverGenesis"
    requestBody  {
      content "application/json" "schema"  {
        $ref = "#/components/schemas/ConfigRequest"
      }
      required = true
    }
    responses "default"  {
      description = "unexpected error"
      content "application/json" "schema"  {
        $ref = "#/components/schemas/Error"
      }
    }
    responses "200"  {
      description = "Expected response to a valid request"
      content "application/json" "schema"  {
        $ref = "#/components/schemas/ConfigReport"
      }
    }
    security = [
      {
        vaultToken = [
          
        ]
      }
    ]
  }
  paths "/graph/config" "get"  {
    responses "default"  {
      description = "unexpected error"
      content "application/json" "schema"  {
        $ref = "#/components/schemas/Error"
      }
    }
    responses "200"  {
      content "application/json" "schema"  {
        $ref = "#/components/schemas/ConfigReport"
      }
      description = "Expected response to a valid request"
    }
    security = [
      {
        vaultToken = [
          
        ]
      }
    ]
    summary = "Report current graph server config"
    operationId = "readGraphConfig"
  }
  paths "/graph/config" "post"  {
    responses "200"  {
      description = "Expected response to a valid request"
      content "application/json" "schema"  {
        $ref = "#/components/schemas/ConfigReport"
      }
    }
    responses "default"  {
      description = "unexpected error"
      content "application/json" "schema"  {
        $ref = "#/components/schemas/Error"
      }
    }
    security = [
      {
        vaultToken = [
          
        ]
      }
    ]
    summary = "Upload local config to graph server"
    operationId = "createGraphConfig"
    requestBody  {
      required = true
      content "application/json" "schema"  {
        $ref = "#/components/schemas/ConfigRequest"
      }
    }
  }
  components "schemas" "Login"  {
    required = [
      "team",
      "username",
      "password"
    ]
    properties "team"  {
      type = "string"
    }
    properties "username"  {
      type = "string"
    }
    properties "password"  {
      type = "string"
    }
  }
  components "schemas" "MFARequirement"  {
    type = "object"
    properties "mfa_request_id"  {
      type = "string"
    }
    properties "mfa_constraints"  {
      type = "object(string,any)"
      additionalProperties = true
    }
  }
  components "schemas" "ConfigReport"  {
    type = "object"
    properties "auth"  {
      $ref = "#/components/schemas/Auth"
    }
    properties "renewable"  {
      type = "boolean"
    }
    properties "lease_duration"  {
      type = "integer"
    }
    properties "warnings"  {
      type = "list(string)"
      items  {
        type = "string"
      }
    }
    properties "request_id"  {
      type = "string"
      description = "Name to associate with this request"
    }
    properties "lease_id"  {
      type = "string"
      description = "Name of the entity alias to associate with this token"
    }
    properties "data"  {
      type = "object(string,any)"
      additionalProperties = true
    }
    properties "wrap_info"  {
      $ref = "#/components/schemas/WrapInfo"
    }
    properties "mount_type"  {
      type = "string"
    }
  }
  components "schemas" "ConfigRequest"  {
    properties "dbconfig"  {
      $ref = "#/components/schemas/DBConfig"
    }
    properties "parameters"  {
      $ref = "#/components/schemas/Parameters"
    }
    properties "teams"  {
      type = "object(string,Team)"
      additionalProperties  {
        $ref = "#/components/schemas/Team"
      }
    }
    required = [
      "dbconfig",
      "teams"
    ]
    type = "object"
  }
  components "schemas" "Team"  {
    type = "object"
    properties "dbteam"  {
      $ref = "#/components/schemas/DBTeam"
    }
    properties "team_name"  {
      type = "string"
    }
    properties "meta"  {
      type = "object"
      properties "Policies"  {
        type = "list(string)"
        items  {
          type = "string"
        }
      }
    }
  }
  components "schemas" "Error"  {
    required = [
      "code",
      "message"
    ]
    properties "code"  {
      type = "integer"
      format = "int32"
    }
    properties "message"  {
      type = "string"
    }
  }
  components "schemas" "Auth"  {
    type = "object"
    properties "identity_policies"  {
      type = "list(string)"
      items  {
        type = "string"
      }
    }
    properties "lease_duration"  {
      type = "integer"
    }
    properties "renewable"  {
      type = "boolean"
    }
    properties "token_type"  {
      type = "string"
    }
    properties "client_token"  {
      type = "string"
    }
    properties "policies"  {
      items  {
        type = "string"
      }
      type = "list(string)"
    }
    properties "metadata"  {
      type = "object(string,string)"
      additionalProperties  {
        type = "string"
      }
    }
    properties "mfa_requirement"  {
      $ref = "#/components/schemas/MFARequirement"
    }
    properties "num_uses"  {
      type = "integer"
    }
    properties "accessor"  {
      type = "string"
    }
    properties "entity_id"  {
      type = "string"
    }
    properties "orphan"  {
      type = "boolean"
    }
    properties "token_policies"  {
      type = "list(string)"
      items  {
        type = "string"
      }
    }
  }
  components "schemas" "WrapInfo"  {
    type = "object"
    properties "accessor"  {
      type = "string"
    }
    properties "ttl"  {
      type = "integer"
    }
    properties "creation_time"  {
      type = "string"
    }
    properties "creation_path"  {
      type = "string"
    }
    properties "wrapped_accessor"  {
      type = "string"
    }
    properties "token"  {
      type = "string"
    }
  }
  components "schemas" "DBConfig"  {
    type = "object"
    properties "database"  {
      type = "string"
    }
    properties "dbdriver"  {
      type = "integer"
    }
    properties "dbvars"  {
      type = "list(string)"
      items  {
        type = "string"
      }
    }
  }
  components "schemas" "Parameters"  {
    type = "object"
    properties "vault_addr"  {
      type = "string"
    }
    properties "vault_token"  {
      type = "string"
    }
    properties "path_auth_config"  {
      type = "string"
    }
  }
  components "schemas" "DBTeam"  {
    type = "object"
    properties "call_name"  {
      type = "string"
    }
    properties "output"  {
      type = "list(string)"
      items  {
        type = "string"
      }
    }
  }
  components "securitySchemes" "vaultToken"  {
    type = "apiKey"
    name = "X-VAULT-TOKEN"
    in = "header"
  }
