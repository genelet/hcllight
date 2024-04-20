components schema "Login" {
  team = string
  username = string
  password = string
}

components schema "WrapInfo" {
  token = string
  accessor = string
  ttl = integer
  creation_time = string
  creation_path = string
  wrapped_accessor = string
}

components schema "ConfigReport" {
  wrap_info = WrapInfo
  auth = Auth
  data = object(string,any)
  warnings = list(string)
  request_id = string
  lease_duration = integer
  mount_type = string
  lease_id = string
  renewable = boolean
}

components schema "DBConfig" {
  database = string
  dbdriver = integer
  dbvars = list(string)
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

components schema "Auth" {
  orphan = boolean
  lease_duration = integer
  mfa_requirement = MFARequirement
  client_token = string
  policies = list(string)
  num_uses = integer
  accessor = string
  token_type = string
  identity_policies = list(string)
  renewable = boolean
  entity_id = string
  token_policies = list(string)
  metadata = object(string,string)
}

components schema "ConfigRequest" {
  dbconfig = DBConfig
  parameters = Parameters
  teams = object(string,Team)
}

components schema "Parameters" {
  path_auth_config = string
  vault_addr = string
  vault_token = string
}

components schema "DBTeam" {
  output = list(string)
  call_name = string
}

paths "/auth/graphauth/config" "get" {
  response = ConfigReport
}

paths "/auth/graphauth/login" "post" {
  request = Login
  response = ConfigReport
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

