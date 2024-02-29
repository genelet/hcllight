
  openapi = "3.0.3"
  info  {
    title = "OpenAPI for Vault Database Configuration"
    description = "HTTP API that gives you full access to Config and Authentication. All API routes are prefixed with /v1"
    license  {
      name = "MIT"
    }
    version = "1.0.0"
  }
  servers = [
    {
      url = "/v1"
      description = "Database Authentication and Configuration"
    }
  ]
  paths "/auth/graphauth/login"  {
    post  {
      responses "default"  {
        content "application/json" "schema"  {
          $ref = "#/components/schemas/Error"
        }
        description = "unexpected error"
      }
      responses "200"  {
        description = "Expected response to a valid request"
        content "application/json" "schema"  {
          $ref = "#/components/schemas/ConfigReport"
        }
      }
      responses "403"  {
        description = "User is not authorized"
      }
      tags = [
        "authentication"
      ]
      summary = "Login to the system"
      operationId = "graphauth-login"
      requestBody  {
        required = true
        content "application/json" "schema"  {
          $ref = "#/components/schemas/Login"
        }
      }
    }
    x-vault-unauthenticated = true
  }
  paths "/auth/graphauth/config" "get"  {
    operationId = "readAuthConfig"
    responses "default"  {
      content "application/json" "schema"  {
        $ref = "#/components/schemas/Error"
      }
      description = "unexpected error"
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
  }
  paths "/graph/config/generate" "post"  {
    security = [
      {
        vaultToken = [
          
        ]
      }
    ]
    summary = "Generate No-Code Server Programs in HCL"
    operationId = "serverGenesis"
    requestBody  {
      content "application/json" "schema"  {
        $ref = "#/components/schemas/ConfigRequest"
      }
      required = true
    }
    responses "default"  {
      content "application/json" "schema"  {
        $ref = "#/components/schemas/Error"
      }
      description = "unexpected error"
    }
    responses "200"  {
      description = "Expected response to a valid request"
      content "application/json" "schema"  {
        $ref = "#/components/schemas/ConfigReport"
      }
    }
  }
  paths "/graph/config" "get"  {
    summary = "Report current graph server config"
    operationId = "readGraphConfig"
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
  paths "/graph/config" "post"  {
    requestBody  {
      content "application/json" "schema"  {
        $ref = "#/components/schemas/ConfigRequest"
      }
      required = true
    }
    responses "200"  {
      description = "Expected response to a valid request"
      content "application/json" "schema"  {
        $ref = "#/components/schemas/ConfigReport"
      }
    }
    responses "default"  {
      content "application/json" "schema"  {
        $ref = "#/components/schemas/Error"
      }
      description = "unexpected error"
    }
    security = [
      {
        vaultToken = [
          
        ]
      }
    ]
    summary = "Upload local config to graph server"
    operationId = "createGraphConfig"
  }
  components "schemas" "DBConfig"  {
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
    type = "object"
  }
  components "schemas" "Parameters"  {
    type = "object"
    properties "path_auth_config"  {
      type = "string"
    }
    properties "vault_addr"  {
      type = "string"
    }
    properties "vault_token"  {
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
  components "schemas" "Team"  {
    type = "object"
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
    properties "dbteam"  {
      $ref = "#/components/schemas/DBTeam"
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
  components "schemas" "Auth"  {
    type = "object"
    properties "token_policies"  {
      type = "list(string)"
      items  {
        type = "string"
      }
    }
    properties "identity_policies"  {
      type = "list(string)"
      items  {
        type = "string"
      }
    }
    properties "token_type"  {
      type = "string"
    }
    properties "num_uses"  {
      type = "integer"
    }
    properties "policies"  {
      type = "list(string)"
      items  {
        type = "string"
      }
    }
    properties "orphan"  {
      type = "boolean"
    }
    properties "mfa_requirement"  {
      $ref = "#/components/schemas/MFARequirement"
    }
    properties "metadata"  {
      additionalProperties  {
        type = "string"
      }
      type = "object(string,string)"
    }
    properties "lease_duration"  {
      type = "integer"
    }
    properties "client_token"  {
      type = "string"
    }
    properties "accessor"  {
      type = "string"
    }
    properties "renewable"  {
      type = "boolean"
    }
    properties "entity_id"  {
      type = "string"
    }
  }
  components "schemas" "ConfigReport"  {
    type = "object"
    properties "lease_duration"  {
      type = "integer"
    }
    properties "wrap_info"  {
      $ref = "#/components/schemas/WrapInfo"
    }
    properties "warnings"  {
      type = "list(string)"
      items  {
        type = "string"
      }
    }
    properties "mount_type"  {
      type = "string"
    }
    properties "auth"  {
      $ref = "#/components/schemas/Auth"
    }
    properties "request_id"  {
      type = "string"
      description = "Name to associate with this request"
    }
    properties "lease_id"  {
      type = "string"
      description = "Name of the entity alias to associate with this token"
    }
    properties "renewable"  {
      type = "boolean"
    }
    properties "data"  {
      additionalProperties = true
      type = "object(string,any)"
    }
  }
  components "schemas" "ConfigRequest"  {
    required = [
      "dbconfig",
      "teams"
    ]
    type = "object"
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
  }
  components "schemas" "Error"  {
    required = [
      "code",
      "message"
    ]
    properties "message"  {
      type = "string"
    }
    properties "code"  {
      type = "integer"
      format = "int32"
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
  components "schemas" "WrapInfo"  {
    type = "object"
    properties "token"  {
      type = "string"
    }
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
  }
  components "securitySchemes" "vaultToken"  {
    type = "apiKey"
    name = "X-VAULT-TOKEN"
    in = "header"
  }
