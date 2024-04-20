components schema "Login" {
  team = string
  username = string
  password = string
}

components schema "MFARequirement" {
  mfa_request_id = string
  mfa_constraints = object(string,any)
}

components schema "Auth" {
  token_policies = list(string)
  identity_policies = list(string)
  metadata = object(string,string)
  entity_id = string
  orphan = boolean
  accessor = string
  mfa_requirement = MFARequirement
  policies = list(string)
  renewable = boolean
  client_token = string
  lease_duration = integer
  token_type = string
  num_uses = integer
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
  auth = Auth
  request_id = string
  lease_id = string
  renewable = boolean
  data = object(string,any)
  wrap_info = WrapInfo
  warnings = list(string)
  lease_duration = integer
  mount_type = string
}

components schema "ConfigRequest" {
  parameters = Parameters
  teams = object(string,Team)
  dbconfig = DBConfig
}

components schema "DBConfig" {
  dbdriver = integer
  dbvars = list(string)
  database = string
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

paths "/graph/config" "post" {
  request = ConfigRequest
  response = ConfigReport
}

paths "/graph/config" "get" {
  response = ConfigReport
}

