// Copyright (c) Greetingland LLC
// MIT License
//
// Generator parser based on the original work of HashiCorp, Inc. on April 6, 2024
// file locaion: https://github.com/hashicorp/terraform-plugin-codegen-openapi/tree/main/internal/config
//
// Copyright (c) HashiCorp, Inc.
// SPDX-License-Identifier: MPL-2.0

package spider

import (
	"encoding/json"
	"testing"
)

func TestParseConfig_Valid(t *testing.T) {
	t.Parallel()

	testCases := map[string]struct {
		input string
		hcl   string
	}{
		"valid single resource": {
			input: `
provider:
  name: example

resources:
  thing:
    create:
      path: /example/path/to/things
      method: POST
    read:
      path: /example/path/to/thing/{id}
      method: GET`,
			hcl: `
  provider {
    name = "example"
  }
  resources "thing" {
	create {
	  path   = "/example/path/to/things"
	  method = "POST"
	}
	read {
	  path   = "/example/path/to/thing/{id}"
	  method = "GET"
	}
  }`,
		},
		"valid resource with parameter matches": {
			input: `
provider:
  name: example

resources:
  thing:
    create:
      path: /example/path/to/things
      method: POST
    read:
      path: /example/path/to/thing/{id}
      method: GET
    schema:
      attributes:
        aliases:
          otherId: id`,
			hcl: `
  provider {
	name = "example"
  }
  resources "thing" {
	create {
	  path   = "/example/path/to/things"
	  method = "POST"
	}
	read {
	  path   = "/example/path/to/thing/{id}"
	  method = "GET"
	}
	schema {
	  attributes {
		aliases = {
		  otherId = "id"
		}
	  }
	}
  }`,
		},
		"valid resource with overrides": {
			input: `
provider:
  name: example

resources:
  thing:
    create:
      path: /example/path/to/things
      method: POST
    read:
      path: /example/path/to/thing/{id}
      method: GET
    schema:
      attributes:
        overrides:
          hey:
            description: Here is a test description for the 'hey' property
          "hey.there":
            description: Here is a test description for the 'there' property in 'hey'
          "hey.there.nested.thing":
            description: Deeply nested property 'thing'`,
			hcl: `
  provider {
	name = "example"
  }
  resources "thing" {
	create {
	  path   = "/example/path/to/things"
	  method = "POST"
	}
	read {
	  path   = "/example/path/to/thing/{id}"
	  method = "GET"
	}
	schema {
	  attributes {
		overrides "hey" {
		  description = "Here is a test description for the 'hey' property"
		}
		overrides "hey.there" {
		  description = "Here is a test description for the 'there' property in 'hey'"
		}
		overrides "hey.there.nested.thing" {
		  description = "Deeply nested property 'thing'"
		}
	  }
	}
  }`,
		},
		"valid resource with ignores": {
			input: `
provider:
  name: example

resources:
  thing:
    create:
      path: /example/path/to/things
      method: POST
    read:
      path: /example/path/to/thing/{id}
      method: GET
    schema:
      ignores:
        - valid.ignore.combo`,
			hcl: `
  provider {
	name = "example"
  }
  resources "thing" {
	create {
	  path   = "/example/path/to/things"
	  method = "POST"
	}
	read {
	  path   = "/example/path/to/thing/{id}"
	  method = "GET"
	}
	schema {
	  ignores = ["valid.ignore.combo"]
	}
  }`,
		},
		"valid single data source": {
			input: `
provider:
  name: example

data_sources:
  thing:
    read:
      path: /example/path/to/thing/{id}
      method: GET`,
			hcl: `
  provider {
	name = "example"
  }
  data_sources "thing" {
	read {
	  path   = "/example/path/to/thing/{id}"
	  method = "GET"
	}
  }`,
		},
		"valid data source with parameter matches": {
			input: `
provider:
  name: example

data_sources:
  thing:
    read:
      path: /example/path/to/thing/{id}
      method: GET
    schema:
      attributes:
        aliases:
          otherId: id`,
			hcl: `
  provider {
	name = "example"
  }
  data_sources "thing" {
	read {
	  path   = "/example/path/to/thing/{id}"
	  method = "GET"
	}
	schema {
	  attributes {
		aliases = {
		  otherId = "id"
		}
	  }
	}
  }`,
		},
		"valid data source with overrides": {
			input: `
provider:
  name: example

data_sources:
  thing:
    read:
      path: /example/path/to/thing/{id}
      method: GET
    schema:
      attributes:
        overrides:
          hey:
            description: Here is a test description for the 'hey' property
          "hey.there":
            description: Here is a test description for the 'there' property in 'hey'
          "hey.there.nested.thing":
            description: Deeply nested property 'thing'`,
			hcl: `
  provider {
	name = "example"
  }
  data_sources "thing" {
	read {
	  path   = "/example/path/to/thing/{id}"
	  method = "GET"
	}
	schema {
	  attributes {
		overrides "hey" {
		  description = "Here is a test description for the 'hey' property"
		}
		overrides "hey.there" {
		  description = "Here is a test description for the 'there' property in 'hey'"
		}
		overrides "hey.there.nested.thing" {
		  description = "Deeply nested property 'thing'"
		}
	  }
	}
  }`,
		},
		"valid data source with ignores": {
			input: `
provider:
  name: example

data_sources:
  thing:
    read:
      path: /example/path/to/thing/{id}
      method: GET
    schema:
      ignores:
        - valid.ignore.combo`,
			hcl: `
  provider {
	name = "example"
  }
  data_sources "thing" {
	read {
	  path   = "/example/path/to/thing/{id}"
	  method = "GET"
	}
	schema {
	  ignores = ["valid.ignore.combo"]
	}
  }`,
		},
		"valid combo of resources and data sources": {
			input: `
provider:
  name: example

resources:
  thing_one:
    create:
      path: /example/path/to/things
      method: POST
    read:
      path: /example/path/to/thing/{id}
      method: GET
  thing_two:
    create:
      path: /example/path/to/things
      method: POST
    read:
      path: /example/path/to/thing/{id}
      method: GET
    update:
      path: /example/path/to/thing/{id}
      method: PATCH
    delete:
      path: /example/path/to/thing/{id}
      method: DELETE
data_sources:
  thing_one:
    read:
      path: /example/path/to/thing/{id}
      method: GET
  thing_two:
    read:
      path: /example/path/to/thing/{id}
      method: GET`,
			hcl: `
  provider {
    name = "example"
  }
  resources "thing_one" {
    create {
      path   = "/example/path/to/things"
      method = "POST"
    }
    read {
      path   = "/example/path/to/thing/{id}"
      method = "GET"
    }
  }
  resources "thing_two" {
    create {
      path   = "/example/path/to/things"
      method = "POST"
    }
    read {
      path   = "/example/path/to/thing/{id}"
      method = "GET"
    }
    update {
      path   = "/example/path/to/thing/{id}"
      method = "PATCH"
    }
    delete {
      path   = "/example/path/to/thing/{id}"
      method = "DELETE"
    }
  }
  data_sources "thing_one" {
    read {
      path   = "/example/path/to/thing/{id}"
      method = "GET"
    }
  }
  data_sources "thing_two" {
    read {
      path   = "/example/path/to/thing/{id}"
      method = "GET"
    }
  }`,
		},
	}
	for name, testCase := range testCases {
		name, testCase := name, testCase
		t.Run(name, func(t *testing.T) {
			t.Parallel()

			config1, err := ParseConfig([]byte(testCase.input), "yaml")
			if err != nil {
				t.Errorf("Unexpected error: %s", err.Error())
			}
			config2, err := ParseConfig([]byte(testCase.hcl))
			if err != nil {
				t.Fatalf("Failed to hcl unmarshal: %s", err)
			}
			bs1, err := json.Marshal(config1)
			if err != nil {
				t.Fatalf("Failed to marshal config1: %s", err)
			}
			bs2, err := json.Marshal(config2)
			if err != nil {
				t.Fatalf("Failed to marshal config2: %s", err)
			}
			if string(bs1) != string(bs2) {
				t.Fatalf("YAML:\n%s\n and HCL:\n%s\n is not equal", bs1, bs2)
			}
		})
	}
}
