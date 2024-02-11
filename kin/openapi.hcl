components schema "MFARequirement" {
  mfa_request_id = string
  mfa_constraints = map(any)
}

components schema "Auth" {
  token_policies = list(string)
  token_type = string
  num_uses = integer
  accessor = string
  identity_policies = list(string)
  renewable = boolean
  policies = list(string)
  orphan = boolean
  entity_id = string
  mfa_requirement = MFARequirement
  client_token = string
  metadata = map(string)
  lease_duration = integer
}

components schema "ConfigRequest" {
  parameters = Parameters
  teams = map(Team)
  dbconfig = DBConfig
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

components schema "Error" {
  code = integer
  message = string
}

components schema "Login" {
  team = string
  username = string
  password = string
}

components schema "WrapInfo" {
  ttl = integer
  creation_time = string
  creation_path = string
  wrapped_accessor = string
  token = string
  accessor = string
}

components schema "ConfigReport" {
  warnings = list(string)
  auth = Auth
  renewable = boolean
  wrap_info = WrapInfo
  mount_type = string
  lease_id = string
  lease_duration = integer
  request_id = string
  data = map(any)
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

var {
}

paths "/auth/graphauth/config" "get" {
  request =   
  response =   ConfigReport
}

paths "/auth/graphauth/login" "post" {
  request =   Login
  response =   ConfigReport
}

paths "/graph/config" "get" {
  request =   
  response =   ConfigReport
}

paths "/graph/config" "post" {
  request =   ConfigRequest
  response =   ConfigReport
}

paths "/graph/config/generate" "post" {
  request =   ConfigRequest
  response =   ConfigReport
}

