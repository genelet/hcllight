TEST_FOLDER = "__test__"
EXECUTION_ID = random(6)
version = 2
say = {
    for k, v in {hello: "world"}: k => v if k == "hello"
}

options  = var.override_options ? var.override_options : var.default_options
result = {for s in var.list : s => upper(s)}

variable "users" {
	overrise_options = true
	list = ["a", "b", "c"]
  type = map(object({
    is_admin = bool
    name = "john"
  }))
}
  
locals {
  admin_users = {
    for name, user in var.users : name => user
    if user.is_admin
  }
  regular_users = {
    for name, user in var.users : name => user
    if !user.is_admin
  }
}

job check "this is a temporal job" {
  python "run.py" {}
}

job e2e "running integration tests" {

  python "app-e2e.py" {
    root_dir = var.TEST_FOLDER
    python_version = version + 6
  }

  slack {
    channel  = "slack-my-channel"
    message = "Job execution ${EXECUTION_ID} completed successfully"
  }
}
