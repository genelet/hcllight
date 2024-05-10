components schema "Error" {
  code = integer
  message = string
}

components schema "Login" {
  password = string
  team = string
  username = string
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

components schema "Parameters" {
  path_auth_config = string
  vault_addr = string
  vault_token = string
}

components schema "DBTeam" {
  call_name = string
  output = list(string)
}

components schema "Auth" {
  metadata = object(string,string)
  accessor = string
  orphan = boolean
  num_uses = integer
  mfa_requirement = MFARequirement
  token_policies = list(string)
  entity_id = string
  token_type = string
  policies = list(string)
  renewable = boolean
  lease_duration = integer
  client_token = string
  identity_policies = list(string)
}

components schema "WrapInfo" {
  accessor = string
  ttl = integer
  creation_time = string
  creation_path = string
  wrapped_accessor = string
  token = string
}

components schema "ConfigReport" {
  data = object(string,any)
  wrap_info = WrapInfo
  warnings = list(string)
  mount_type = string
  lease_id = string
  request_id = string
  renewable = boolean
  lease_duration = integer
  auth = Auth
}

components schema "DBConfig" {
  dbvars = list(string)
  database = string
  dbdriver = integer
}

components schema "Team" {
  team_name = string
  dbteam = DBTeam
  meta {
    Policies = list(string)
  }
}

paths "/auth/graphauth/config" "get" {
  response = ConfigReport
}

paths "/auth/graphauth/login" "post" {
  request = Login
  response = ConfigReport
}

paths "/graph/config" "get" {
  response = ConfigReport
}

paths "/graph/config" "post" {
  request = ConfigRequest
  response = ConfigReport
}

paths "/graph/config/generate" "post" {
  request = ConfigRequest
  response = ConfigReport
}

