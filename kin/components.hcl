components schema "ConfigReport" {
  renewable = boolean
  warnings = list(string)
  auth = Auth
  wrap_info = WrapInfo
  mount_type = string
  request_id = string
  lease_id = string
  lease_duration = integer
  data = map(any)
}

components schema "Team" {
  dbteam = DBTeam
  team_name = string
  meta {
    Policies = list(string)
  }
}

components schema "ConfigRequest" {
  teams = map(Team)
  dbconfig = DBConfig
  parameters = Parameters
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
  output = list(string)
  call_name = string
}

components schema "Login" {
  username = string
  password = string
  team = string
}

components schema "MFARequirement" {
  mfa_constraints = map(any)
  mfa_request_id = string
}

components schema "Auth" {
  token_policies = list(string)
  metadata = map(string)
  token_type = string
  renewable = boolean
  identity_policies = list(string)
  entity_id = string
  orphan = boolean
  client_token = string
  num_uses = integer
  mfa_requirement = MFARequirement
  policies = list(string)
  lease_duration = integer
  accessor = string
}

components schema "WrapInfo" {
  wrapped_accessor = string
  token = string
  accessor = string
  ttl = integer
  creation_time = string
  creation_path = string
}

components schema "Error" {
  code = integer
  message = string
}

var {
}

paths "/graph/config/generate" "post" {
  request =   ConfigRequest
  response =   ConfigReport
}

paths "/auth/graphauth/config" "get" {
  request =   
  response =   ConfigReport
}

paths "/auth/graphauth/login" "post" {
  request =   Login
  response =   ConfigReport
}

paths "/graph/config" "post" {
  request =   ConfigRequest
  response =   ConfigReport
}

paths "/graph/config" "get" {
  request =   
  response =   ConfigReport
}

