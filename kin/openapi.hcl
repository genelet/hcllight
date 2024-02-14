components schema "WrapInfo" {
  creation_path = string
  wrapped_accessor = string
  token = string
  accessor = string
  ttl = integer
  creation_time = string
}

components schema "ConfigReport" {
  auth = Auth
  data = object(string,any)
  lease_duration = integer
  warnings = list(string)
  mount_type = string
  request_id = string
  lease_id = string
  renewable = boolean
  wrap_info = WrapInfo
}

components schema "DBConfig" {
  dbvars = list(string)
  database = string
  dbdriver = integer
}

components schema "Login" {
  team = string
  username = string
  password = string
}

components schema "Auth" {
  metadata = object(string,string)
  num_uses = integer
  client_token = string
  lease_duration = integer
  token_type = string
  entity_id = string
  mfa_requirement = MFARequirement
  renewable = boolean
  accessor = string
  identity_policies = list(string)
  policies = list(string)
  token_policies = list(string)
  orphan = boolean
}

components schema "Parameters" {
  path_auth_config = string
  vault_addr = string
  vault_token = string
}

components schema "DBTeam" {
  call_name = string
  output = list(string)
}

components schema "Team" {
  team_name = string
  dbteam = DBTeam
  meta {
    Policies = list(string)
  }
}

components schema "Error" {
  code = integer
  message = string
}

components schema "MFARequirement" {
  mfa_request_id = string
  mfa_constraints = object(string,any)
}

components schema "ConfigRequest" {
  dbconfig = DBConfig
  parameters = Parameters
  teams = object(string,Team)
}

paths "/graph/config" "post" {
  request = ConfigRequest
  response = ConfigReport
}

paths "/graph/config" "get" {
  response = ConfigReport
}

paths "/graph/config/generate" "post" {
  request = ConfigRequest
  response = ConfigReport
}

paths "/auth/graphauth/config" "get" {
  response = ConfigReport
}

paths "/auth/graphauth/login" "post" {
  request = Login
  response = ConfigReport
}

