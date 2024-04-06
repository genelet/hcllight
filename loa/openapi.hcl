components schema "Login" {
  team = object(string,{})
  username = object(string,{})
  password = object(string,{})
}

components schema "MFARequirement" {
  mfa_request_id = object(string,{})
  mfa_constraints = object(string,any)
}

components schema "Auth" {
  identity_policies = object(string,{})
  entity_id = object(string,{})
  token_type = object(string,{})
  num_uses = object(string,{})
  policies = object(string,{})
  orphan = object(string,{})
  client_token = object(string,{})
  renewable = object(string,{})
  mfa_requirement = MFARequirement
  accessor = object(string,{})
  token_policies = object(string,{})
  metadata = object(string,object(string,{}))
  lease_duration = object(string,{})
}

components schema "WrapInfo" {
  wrapped_accessor = object(string,{})
  token = object(string,{})
  accessor = object(string,{})
  ttl = object(string,{})
  creation_time = object(string,{})
  creation_path = object(string,{})
}

components schema "ConfigReport" {
  request_id = object(string,{})
  lease_id = object(string,{})
  renewable = object(string,{})
  data = object(string,any)
  wrap_info = WrapInfo
  auth = Auth
  lease_duration = object(string,{})
  warnings = object(string,{})
  mount_type = object(string,{})
}

components schema "ConfigRequest" {
  dbconfig = DBConfig
  parameters = Parameters
  teams = object(string,Team)
}

components schema "DBConfig" {
  database = object(string,{})
  dbdriver = object(string,{})
  dbvars = object(string,{})
}

components schema "Parameters" {
  path_auth_config = object(string,{})
  vault_addr = object(string,{})
  vault_token = object(string,{})
}

components schema "DBTeam" {
  call_name = object(string,{})
  output = object(string,{})
}

components schema "Team" {
  team_name = object(string,{})
  dbteam = DBTeam
  meta {
    Policies = object(string,{})
  }
}

components schema "Error" {
  code = object(string,{})
  message = object(string,{})
}

paths "/auth/graphauth/login" "post" {
  request = Login
  response = Error
}

paths "/auth/graphauth/config" "get" {
  response = Error
}

paths "/graph/config/generate" "post" {
  request = ConfigRequest
  response = Error
}

paths "/graph/config" "get" {
  response = Error
}

paths "/graph/config" "post" {
  request = ConfigRequest
  response = Error
}

