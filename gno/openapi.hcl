components schema "Login" {
  team = string
  username = string
  password = string
}

components schema "MFARequirement" {
  mfa_constraints = object(string,any)
  mfa_request_id = string
}

components schema "Auth" {
  renewable = boolean
  mfa_requirement = MFARequirement
  num_uses = integer
  accessor = string
  policies = list(string)
  entity_id = string
  token_type = string
  client_token = string
  token_policies = list(string)
  identity_policies = list(string)
  metadata = object(string,string)
  lease_duration = integer
  orphan = boolean
}

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
  request_id = string
  lease_id = string
  lease_duration = integer
  wrap_info = WrapInfo
  warnings = list(string)
  renewable = boolean
  data = object(string,any)
  mount_type = string
}

components schema "ConfigRequest" {
  dbconfig = DBConfig
  parameters = Parameters
  teams = object(string,Team)
}

components schema "DBConfig" {
  dbvars = list(string)
  database = string
  dbdriver = integer
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

paths "/auth/graphauth/login" "post" {
  request = Login
  response = ConfigReport
}

paths "/auth/graphauth/config" "get" {
  response = ConfigReport
}

paths "/graph/config/generate" "post" {
  request = ConfigRequest
  response = ConfigReport
}

paths "/graph/config" "get" {
  response = ConfigReport
}

paths "/graph/config" "post" {
  request = ConfigRequest
  response = ConfigReport
}

