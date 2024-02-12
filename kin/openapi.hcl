components schema "Auth" {
  lease_duration = integer
  orphan = boolean
  entity_id = string
  token_type = string
  renewable = boolean
  mfa_requirement = MFARequirement
  client_token = string
  accessor = string
  num_uses = integer
  token_policies = list(string)
  identity_policies = list(string)
  metadata = map(string)
  policies = list(string)
}

components schema "WrapInfo" {
  wrapped_accessor = string
  token = string
  accessor = string
  ttl = integer
  creation_time = string
  creation_path = string
}

components schema "ConfigReport" {
  mount_type = string
  auth = Auth
  request_id = string
  wrap_info = WrapInfo
  data = map(any)
  renewable = boolean
  warnings = list(string)
  lease_id = string
  lease_duration = integer
}

components schema "ConfigRequest" {
  dbconfig = DBConfig
  parameters = Parameters
  teams = map(Team)
}

components schema "Parameters" {
  path_auth_config = string
  vault_addr = string
  vault_token = string
}

components schema "Team" {
  dbteam = DBTeam
  team_name = string
  meta {
    Policies = list(string)
  }
}

components schema "Login" {
  team = string
  username = string
  password = string
}

components schema "DBConfig" {
  database = string
  dbdriver = integer
  dbvars = list(string)
}

components schema "DBTeam" {
  output = list(string)
  call_name = string
}

components schema "Error" {
  code = integer
  message = string
}

components schema "MFARequirement" {
  mfa_request_id = string
  mfa_constraints = map(any)
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

