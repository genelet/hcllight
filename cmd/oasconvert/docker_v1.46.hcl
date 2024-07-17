
  openapi = "3.0.1"
  servers = [{
    url = "/v1.46"
  }]
  tags = [{
    name = "Container",
    description = "Create and manage containers."
  }, {
    name = "Image"
  }, {
    name = "Network",
    description = "Networks are user-defined networks that containers can be attached to.\\nSee the [networking documentation](https://docs.docker.com/network/)\\nfor more information."
  }, {
    name = "Volume",
    description = "Create and manage persistent storage that can be attached to containers."
  }, {
    name = "Exec",
    description = "Run new commands inside running containers. Refer to the\\n[command-line reference](https://docs.docker.com/engine/reference/commandline/exec/)\\nfor more information.\\n\\nTo exec a command in a container, you first need to create an exec instance,\\nthen start it. These two API endpoints are wrapped up in a single command-line\\ncommand, `docker exec`."
  }, {
    description = "Engines can be clustered together in a swarm. Refer to the\\n[swarm mode documentation](https://docs.docker.com/engine/swarm/)\\nfor more information.",
    name = "Swarm"
  }, {
    name = "Node",
    description = "Nodes are instances of the Engine participating in a swarm. Swarm mode\\nmust be enabled for these endpoints to work."
  }, {
    name = "Service",
    description = "Services are the definitions of tasks to run on a swarm. Swarm mode must\\nbe enabled for these endpoints to work."
  }, {
    name = "Task",
    description = "A task is a container running on a swarm. It is the atomic scheduling unit\\nof swarm. Swarm mode must be enabled for these endpoints to work."
  }, {
    name = "Secret",
    description = "Secrets are sensitive data that can be used by services. Swarm mode must\\nbe enabled for these endpoints to work."
  }, {
    name = "Config",
    description = "Configs are application configurations that can be used by services. Swarm\\nmode must be enabled for these endpoints to work."
  }, {
    name = "Plugin"
  }, {
    name = "System"
  }]
  info {
    description = "The Engine API is an HTTP API served by Docker Engine. It is the API the\\nDocker client uses to communicate with the Engine, so everything the Docker\\nclient can do can be done with the API.\\n\\nMost of the client's commands map directly to API endpoints (e.g. `docker ps`\\nis `GET /containers/json`). The notable exception is running containers,\\nwhich consists of several API calls.\\n\\n# Errors\\n\\nThe API uses standard HTTP status codes to indicate the success or failure\\nof the API call. The body of the response will be JSON in the following\\nformat:\\n\\n```\\n{\\n  \"message\": \"page not found\"\\n}\\n```\\n\\n# Versioning\\n\\nThe API is usually changed in each release, so API calls are versioned to\\nensure that clients don't break. To lock to a specific version of the API,\\nyou prefix the URL with its version, for example, call `/v1.30/info` to use\\nthe v1.30 version of the `/info` endpoint. If the API version specified in\\nthe URL is not supported by the daemon, a HTTP `400 Bad Request` error message\\nis returned.\\n\\nIf you omit the version-prefix, the current version of the API (v1.46) is used.\\nFor example, calling `/info` is the same as calling `/v1.46/info`. Using the\\nAPI without a version-prefix is deprecated and will be removed in a future release.\\n\\nEngine releases in the near future should support this version of the API,\\nso your client will continue to work even if it is talking to a newer Engine.\\n\\nThe API uses an open schema model, which means server may add extra properties\\nto responses. Likewise, the server will ignore any extra query parameters and\\nrequest body properties. When you write clients, you need to ignore additional\\nproperties in responses to ensure they do not break when talking to newer\\ndaemons.\\n\\n\\n# Authentication\\n\\nAuthentication for registries is handled client side. The client has to send\\nauthentication details to various endpoints that need to communicate with\\nregistries, such as `POST /images/(name)/push`. These are sent as\\n`X-Registry-Auth` header as a [base64url encoded](https://tools.ietf.org/html/rfc4648#section-5)\\n(JSON) string with the following structure:\\n\\n```\\n{\\n  \"username\": \"string\",\\n  \"password\": \"string\",\\n  \"email\": \"string\",\\n  \"serveraddress\": \"string\"\\n}\\n```\\n\\nThe `serveraddress` is a domain/IP without a protocol. Throughout this\\nstructure, double quotes are required.\\n\\nIf you have already got an identity token from the [`/auth` endpoint](#operation/SystemAuth),\\nyou can just pass this instead of credentials:\\n\\n```\\n{\\n  \"identitytoken\": \"9cbaf023786cd7...\"\\n}\\n```"
    version = "1.46"
    title = "Docker Engine API"
    specificationExtension {
      x-logo = "url: https://docs.docker.com/assets/images/logo-docker-main.png"
    }
  }
  paths "/nodes/{id}" "get" {
    summary = "Inspect a node"
    operationId = "NodeInspect"
    tags = ["Node"]
    parameters "id" {
      description = "The ID or name of the node"
      schema = string()
      required = true
      in = "path"
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.Node
      }
      content "text/plain" {
        schema = components.schemas.Node
      }
    }
    responses "404" {
      description = "no such node"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/nodes/{id}" "delete" {
    summary = "Delete a node"
    operationId = "NodeDelete"
    tags = ["Node"]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID or name of the node"
      schema = string()
    }
    parameters "force" {
      in = "query"
      description = "Force remove a node from the swarm"
      schema = boolean(default(false))
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
    }
    responses "404" {
      description = "no such node"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/configs/{id}" "get" {
    summary = "Inspect a config"
    operationId = "ConfigInspect"
    tags = ["Config"]
    parameters "id" {
      required = true
      in = "path"
      description = "ID of the config"
      schema = string()
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        example = "ID: ktnbjxoalbkvbvedmg1urrz8h\\nVersion:\\n    Index: 11\\nCreatedAt: 2016-11-05T01:20:17.327670065Z\\nUpdatedAt: 2016-11-05T01:20:17.327670065Z\\nSpec:\\n    Name: app-dev.crt"
        schema = components.schemas.Config
      }
    }
    responses "404" {
      description = "config not found"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/configs/{id}" "delete" {
    tags = ["Config"]
    summary = "Delete a config"
    operationId = "ConfigDelete"
    parameters "id" {
      required = true
      in = "path"
      description = "ID of the config"
      schema = string()
    }
    responses "404" {
      description = "config not found"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "204" {
      description = "no error"
    }
  }
  paths "/containers/{id}/attach" "post" {
    operationId = "ContainerAttach"
    summary = "Attach to a container"
    description = "Attach to a container to read its output or send it input. You can attach\\nto the same container multiple times and you can reattach to containers\\nthat have been detached.\\n\\nEither the `stream` or `logs` parameter must be `true` for this endpoint\\nto do anything.\\n\\nSee the [documentation for the `docker attach` command](https://docs.docker.com/engine/reference/commandline/attach/)\\nfor more details.\\n\\n### Hijacking\\n\\nThis endpoint hijacks the HTTP connection to transport `stdin`, `stdout`,\\nand `stderr` on the same socket.\\n\\nThis is the response from the daemon for an attach request:\\n\\n```\\nHTTP/1.1 200 OK\\nContent-Type: application/vnd.docker.raw-stream\\n\\n[STREAM]\\n```\\n\\nAfter the headers and two new lines, the TCP connection can now be used\\nfor raw, bidirectional communication between the client and server.\\n\\nTo hint potential proxies about connection hijacking, the Docker client\\ncan also optionally send connection upgrade headers.\\n\\nFor example, the client sends this request to upgrade the connection:\\n\\n```\\nPOST /containers/16253994b7c4/attach?stream=1&stdout=1 HTTP/1.1\\nUpgrade: tcp\\nConnection: Upgrade\\n```\\n\\nThe Docker daemon will respond with a `101 UPGRADED` response, and will\\nsimilarly follow with the raw stream:\\n\\n```\\nHTTP/1.1 101 UPGRADED\\nContent-Type: application/vnd.docker.raw-stream\\nConnection: Upgrade\\nUpgrade: tcp\\n\\n[STREAM]\\n```\\n\\n### Stream format\\n\\nWhen the TTY setting is disabled in [`POST /containers/create`](#operation/ContainerCreate),\\nthe HTTP Content-Type header is set to application/vnd.docker.multiplexed-stream\\nand the stream over the hijacked connected is multiplexed to separate out\\n`stdout` and `stderr`. The stream consists of a series of frames, each\\ncontaining a header and a payload.\\n\\nThe header contains the information which the stream writes (`stdout` or\\n`stderr`). It also contains the size of the associated frame encoded in\\nthe last four bytes (`uint32`).\\n\\nIt is encoded on the first eight bytes like this:\\n\\n```go\\nheader := [8]byte{STREAM_TYPE, 0, 0, 0, SIZE1, SIZE2, SIZE3, SIZE4}\\n```\\n\\n`STREAM_TYPE` can be:\\n\\n- 0: `stdin` (is written on `stdout`)\\n- 1: `stdout`\\n- 2: `stderr`\\n\\n`SIZE1, SIZE2, SIZE3, SIZE4` are the four bytes of the `uint32` size\\nencoded as big endian.\\n\\nFollowing the header is the payload, which is the specified number of\\nbytes of `STREAM_TYPE`.\\n\\nThe simplest way to implement this protocol is the following:\\n\\n1. Read 8 bytes.\\n2. Choose `stdout` or `stderr` depending on the first byte.\\n3. Extract the frame size from the last four bytes.\\n4. Read the extracted size and output it on the correct output.\\n5. Goto 1.\\n\\n### Stream format when using a TTY\\n\\nWhen the TTY setting is enabled in [`POST /containers/create`](#operation/ContainerCreate),\\nthe stream is not multiplexed. The data exchanged over the hijacked\\nconnection is simply the raw data from the process PTY and client's\\n`stdin`."
    tags = ["Container"]
    parameters "id" {
      description = "ID or name of the container"
      schema = string()
      required = true
      in = "path"
    }
    parameters "detachKeys" {
      in = "query"
      description = "Override the key sequence for detaching a container.Format is a single\\ncharacter `[a-Z]` or `ctrl-<value>` where `<value>` is one of: `a-z`,\\n`@`, `^`, `[`, `,` or `_`."
      schema = string()
    }
    parameters "logs" {
      in = "query"
      description = "Replay previous logs from the container.\\n\\nThis is useful for attaching to a container that has started and you\\nwant to output everything since the container started.\\n\\nIf `stream` is also enabled, once all the previous output has been\\nreturned, it will seamlessly transition into streaming current\\noutput."
      schema = boolean(default(false))
    }
    parameters "stream" {
      in = "query"
      description = "Stream attached streams from the time the request was made onwards."
      schema = boolean(default(false))
    }
    parameters "stdin" {
      in = "query"
      description = "Attach to `stdin`"
      schema = boolean(default(false))
    }
    parameters "stdout" {
      description = "Attach to `stdout`"
      schema = boolean(default(false))
      in = "query"
    }
    parameters "stderr" {
      schema = boolean(default(false))
      in = "query"
      description = "Attach to `stderr`"
    }
    responses "404" {
      description = "no such container"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
      }
    }
    responses "500" {
      description = "server error"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "101" {
      description = "no error, hints proxy about hijacking"
    }
    responses "200" {
      description = "no error, no upgrade header found"
    }
    responses "400" {
      description = "bad parameter"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/exec/{id}/json" "get" {
    operationId = "ExecInspect"
    tags = ["Exec"]
    summary = "Inspect an exec instance"
    description = "Return low-level information about an exec instance."
    parameters "id" {
      description = "Exec instance ID"
      schema = string()
      required = true
      in = "path"
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        example = "CanRemove: false\\nContainerID: b53ee82b53a40c7dca428523e34f741f3abc51d9f297a14ff874bf761b995126\\nDetachKeys: \"\"\\nExitCode: 2\\nID: f33bbfb39f5b142420f4759b2348913bd4a8d1a6d7fd56499cb41a1bb91d7b3b\\nOpenStderr: true\\nOpenStdin: true\\nOpenStdout: true\\nProcessConfig:\\n    arguments:\\n        - -c\\n        - exit 2\\n    entrypoint: sh\\n    privileged: false\\n    tty: true\\n    user: \"1000\"\\nRunning: false\\nPid: 42000"
        schema = {
          title = "ExecInspectResponse",
          type = "object",
          properties = {
            ProcessConfig = components.schemas.ProcessConfig,
            OpenStdout = boolean(),
            ExitCode = integer(),
            OpenStderr = boolean(),
            ContainerID = string(),
            OpenStdin = boolean(),
            DetachKeys = string(),
            Running = boolean(),
            Pid = integer(description("The system process ID for the exec process.")),
            CanRemove = boolean(),
            ID = string()
          }
        }
      }
    }
    responses "404" {
      description = "No such exec instance"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/swarm/init" "post" {
    tags = ["Swarm"]
    operationId = "SwarmInit"
    summary = "Initialize a new swarm"
    requestBody {
      required = true
      content "application/json" {
        schema = {
          title = "SwarmInitRequest",
          type = "object",
          example = {
            SubnetSize = "24",
            ForceNewCluster = "false",
            Spec = "map[CAConfig:map[] Dispatcher:map[] EncryptionConfig:map[AutoLockManagers:false] Orchestration:map[] Raft:map[]]",
            ListenAddr = "0.0.0.0:2377",
            AdvertiseAddr = "192.168.1.1:2377",
            DataPathPort = "4789",
            DefaultAddrPool = "[10.10.0.0/8 20.20.0.0/8]"
          },
          properties = {
            Spec = components.schemas.SwarmSpec,
            ListenAddr = string(description("Listen address used for inter-manager communication, as well\\nas determining the networking interface used for the VXLAN\\nTunnel Endpoint (VTEP). This can either be an address/port\\ncombination in the form `192.168.1.1:4567`, or an interface\\nfollowed by a port number, like `eth0:4567`. If the port number\\nis omitted, the default swarm listening port is used.")),
            AdvertiseAddr = string(description("Externally reachable address advertised to other nodes. This\\ncan either be an address/port combination in the form\\n`192.168.1.1:4567`, or an interface followed by a port number,\\nlike `eth0:4567`. If the port number is omitted, the port\\nnumber from the listen address is used. If `AdvertiseAddr` is\\nnot specified, it will be automatically detected when possible.")),
            DataPathAddr = string(description("Address or interface to use for data path traffic (format:\\n`<ip|interface>`), for example,  `192.168.1.1`, or an interface,\\nlike `eth0`. If `DataPathAddr` is unspecified, the same address\\nas `AdvertiseAddr` is used.\\n\\nThe `DataPathAddr` specifies the address that global scope\\nnetwork drivers will publish towards other  nodes in order to\\nreach the containers running on this node. Using this parameter\\nit is possible to separate the container data traffic from the\\nmanagement traffic of the cluster.")),
            DataPathPort = integer(format("uint32"), description("DataPathPort specifies the data path port number for data traffic.\\nAcceptable port range is 1024 to 49151.\\nif no port is set or is set to 0, default port 4789 will be used.")),
            DefaultAddrPool = array(description("Default Address Pool specifies default subnet pools for global\\nscope networks."), [string(example())]),
            ForceNewCluster = boolean(description("Force creation of a new swarm.")),
            SubnetSize = integer(format("uint32"), description("SubnetSize specifies the subnet size of the networks created\\nfrom the default subnet pool."))
          }
        }
      }
      content "text/plain" {
        schema = {
          title = "SwarmInitRequest",
          type = "object",
          example = {
            SubnetSize = "24",
            ForceNewCluster = "false",
            Spec = "map[CAConfig:map[] Dispatcher:map[] EncryptionConfig:map[AutoLockManagers:false] Orchestration:map[] Raft:map[]]",
            ListenAddr = "0.0.0.0:2377",
            AdvertiseAddr = "192.168.1.1:2377",
            DataPathPort = "4789",
            DefaultAddrPool = "[10.10.0.0/8 20.20.0.0/8]"
          },
          properties = {
            AdvertiseAddr = string(description("Externally reachable address advertised to other nodes. This\\ncan either be an address/port combination in the form\\n`192.168.1.1:4567`, or an interface followed by a port number,\\nlike `eth0:4567`. If the port number is omitted, the port\\nnumber from the listen address is used. If `AdvertiseAddr` is\\nnot specified, it will be automatically detected when possible.")),
            DataPathAddr = string(description("Address or interface to use for data path traffic (format:\\n`<ip|interface>`), for example,  `192.168.1.1`, or an interface,\\nlike `eth0`. If `DataPathAddr` is unspecified, the same address\\nas `AdvertiseAddr` is used.\\n\\nThe `DataPathAddr` specifies the address that global scope\\nnetwork drivers will publish towards other  nodes in order to\\nreach the containers running on this node. Using this parameter\\nit is possible to separate the container data traffic from the\\nmanagement traffic of the cluster.")),
            DataPathPort = integer(format("uint32"), description("DataPathPort specifies the data path port number for data traffic.\\nAcceptable port range is 1024 to 49151.\\nif no port is set or is set to 0, default port 4789 will be used.")),
            DefaultAddrPool = array(description("Default Address Pool specifies default subnet pools for global\\nscope networks."), [string(example())]),
            ForceNewCluster = boolean(description("Force creation of a new swarm.")),
            SubnetSize = integer(format("uint32"), description("SubnetSize specifies the subnet size of the networks created\\nfrom the default subnet pool.")),
            Spec = components.schemas.SwarmSpec,
            ListenAddr = string(description("Listen address used for inter-manager communication, as well\\nas determining the networking interface used for the VXLAN\\nTunnel Endpoint (VTEP). This can either be an address/port\\ncombination in the form `192.168.1.1:4567`, or an interface\\nfollowed by a port number, like `eth0:4567`. If the port number\\nis omitted, the default swarm listening port is used."))
          }
        }
      }
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = string(description("The node ID"), example("7v2t30z9blmxuhnyo6s4cpenp"))
      }
      content "text/plain" {
        schema = string(description("The node ID"), example("7v2t30z9blmxuhnyo6s4cpenp"))
      }
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is already part of a swarm"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/secrets/{id}" "get" {
    summary = "Inspect a secret"
    operationId = "SecretInspect"
    tags = ["Secret"]
    parameters "id" {
      required = true
      in = "path"
      description = "ID of the secret"
      schema = string()
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        example = "ID: ktnbjxoalbkvbvedmg1urrz8h\\nVersion:\\n    Index: 11\\nCreatedAt: 2016-11-05T01:20:17.327670065Z\\nUpdatedAt: 2016-11-05T01:20:17.327670065Z\\nSpec:\\n    Name: app-dev.crt\\n    Labels:\\n        foo: bar\\n    Driver:\\n        Name: secret-bucket\\n        Options:\\n            OptionA: value for driver option A\\n            OptionB: value for driver option B"
        schema = components.schemas.Secret
      }
    }
    responses "404" {
      description = "secret not found"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/secrets/{id}" "delete" {
    operationId = "SecretDelete"
    summary = "Delete a secret"
    tags = ["Secret"]
    parameters "id" {
      required = true
      description = "ID of the secret"
      in = "path"
      schema = string()
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "204" {
      description = "no error"
    }
    responses "404" {
      description = "secret not found"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/wait" "post" {
    summary = "Wait for a container"
    description = "Block until a container stops, then returns the exit code."
    operationId = "ContainerWait"
    tags = ["Container"]
    parameters "id" {
      in = "path"
      description = "ID or name of the container"
      schema = string()
      required = true
    }
    parameters "condition" {
      in = "query"
      description = "Wait until a container state reaches the given condition.\\n\\nDefaults to `not-running` if omitted or empty."
      schema = string(default("not-running"), enum("not-running", "next-exit", "removed"))
    }
    responses "200" {
      description = "The container has exit."
      content "application/json" {
        schema = components.schemas.ContainerWaitResponse
      }
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/events" "get" {
    tags = ["System"]
    summary = "Monitor events"
    description = "Stream real-time events from the server.\\n\\nVarious objects within Docker report events when something happens to them.\\n\\nContainers report these events: `attach`, `commit`, `copy`, `create`, `destroy`, `detach`, `die`, `exec_create`, `exec_detach`, `exec_start`, `exec_die`, `export`, `health_status`, `kill`, `oom`, `pause`, `rename`, `resize`, `restart`, `start`, `stop`, `top`, `unpause`, `update`, and `prune`\\n\\nImages report these events: `create, `delete`, `import`, `load`, `pull`, `push`, `save`, `tag`, `untag`, and `prune`\\n\\nVolumes report these events: `create`, `mount`, `unmount`, `destroy`, and `prune`\\n\\nNetworks report these events: `create`, `connect`, `disconnect`, `destroy`, `update`, `remove`, and `prune`\\n\\nThe Docker daemon reports these events: `reload`\\n\\nServices report these events: `create`, `update`, and `remove`\\n\\nNodes report these events: `create`, `update`, and `remove`\\n\\nSecrets report these events: `create`, `update`, and `remove`\\n\\nConfigs report these events: `create`, `update`, and `remove`\\n\\nThe Builder reports `prune` events"
    operationId = "SystemEvents"
    parameters "since" {
      description = "Show events created since this timestamp then stream new events."
      schema = string()
      in = "query"
    }
    parameters "until" {
      in = "query"
      description = "Show events created until this timestamp then stop streaming."
      schema = string()
    }
    parameters "filters" {
      in = "query"
      description = "A JSON encoded value of filters (a `map[string][]string`) to process on the event list. Available filters:\\n\\n- `config=<string>` config name or ID\\n- `container=<string>` container name or ID\\n- `daemon=<string>` daemon name or ID\\n- `event=<string>` event type\\n- `image=<string>` image name or ID\\n- `label=<string>` image or container label\\n- `network=<string>` network name or ID\\n- `node=<string>` node ID\\n- `plugin`=<string> plugin name or ID\\n- `scope`=<string> local or swarm\\n- `secret=<string>` secret name or ID\\n- `service=<string>` service name or ID\\n- `type=<string>` object to filter by, one of `container`, `image`, `volume`, `network`, `daemon`, `plugin`, `node`, `service`, `secret` or `config`\\n- `volume=<string>` volume name"
      schema = string()
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.EventMessage
      }
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/plugins/{name}/upgrade" "post" {
    summary = "Upgrade a plugin"
    operationId = "PluginUpgrade"
    tags = ["Plugin"]
    parameters "name" {
      required = true
      in = "path"
      description = "The name of the plugin. The `:latest` tag is optional, and is the\\ndefault if omitted."
      schema = string()
    }
    parameters "remote" {
      description = "Remote reference to upgrade to.\\n\\nThe `:latest` tag is optional, and is used as the default if omitted."
      in = "query"
      schema = string()
      required = true
    }
    parameters "X-Registry-Auth" {
      description = "A base64url-encoded auth configuration to use when pulling a plugin\\nfrom a registry.\\n\\nRefer to the [authentication section](#section/Authentication) for\\ndetails."
      schema = string()
      in = "header"
    }
    requestBody {
      content "application/json" {
        schema = array(example(["map[Description: Name:network Value:[host]]", "map[Description: Name:mount Value:[/data]]", "map[Description: Name:device Value:[/dev/cpu_dma_latency]]"]), [components.schemas.PluginPrivilege])
      }
      content "text/plain" {
        schema = array(example(["map[Description: Name:network Value:[host]]", "map[Description: Name:mount Value:[/data]]", "map[Description: Name:device Value:[/dev/cpu_dma_latency]]"]), [components.schemas.PluginPrivilege])
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "204" {
      description = "no error"
    }
    responses "404" {
      description = "plugin not installed"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/swarm/update" "post" {
    summary = "Update a swarm"
    operationId = "SwarmUpdate"
    tags = ["Swarm"]
    parameters "version" {
      in = "query"
      description = "The version number of the swarm object being updated. This is\\nrequired to avoid conflicting writes."
      schema = integer(format("int64"))
      required = true
    }
    parameters "rotateWorkerToken" {
      schema = boolean(default(false))
      in = "query"
      description = "Rotate the worker join token."
    }
    parameters "rotateManagerToken" {
      in = "query"
      description = "Rotate the manager join token."
      schema = boolean(default(false))
    }
    parameters "rotateManagerUnlockKey" {
      description = "Rotate the manager unlock key."
      schema = boolean(default(false))
      in = "query"
    }
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.SwarmSpec
      }
      content "text/plain" {
        schema = components.schemas.SwarmSpec
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/configs" "get" {
    summary = "List configs"
    operationId = "ConfigList"
    tags = ["Config"]
    parameters "filters" {
      schema = string()
      in = "query"
      description = "A JSON encoded value of the filters (a `map[string][]string`) to\\nprocess on the configs list.\\n\\nAvailable filters:\\n\\n- `id=<config id>`\\n- `label=<key> or label=<key>=value`\\n- `name=<config name>`\\n- `names=<config name>`"
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = array(example(["map[CreatedAt:2016-11-05T01:20:17.327670065Z ID:ktnbjxoalbkvbvedmg1urrz8h Spec:map[Name:server.conf] UpdatedAt:2016-11-05T01:20:17.327670065Z Version:map[Index:11]]"]), [components.schemas.Config])
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/json" "get" {
    operationId = "ContainerInspect"
    summary = "Inspect a container"
    description = "Return low-level information about a container."
    tags = ["Container"]
    parameters "id" {
      schema = string()
      required = true
      in = "path"
      description = "ID or name of the container"
    }
    parameters "size" {
      description = "Return the size of container as fields `SizeRw` and `SizeRootFs`"
      in = "query"
      schema = boolean(default(false))
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        example = "AppArmorProfile: \"\"\\nArgs:\\n    - -c\\n    - exit 9\\nConfig:\\n    AttachStderr: true\\n    AttachStdin: false\\n    AttachStdout: true\\n    Cmd:\\n        - /bin/sh\\n        - -c\\n        - exit 9\\n    Domainname: \"\"\\n    Env:\\n        - PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\\n    Healthcheck:\\n        Test:\\n            - CMD-SHELL\\n            - exit 0\\n    Hostname: ba033ac44011\\n    Image: ubuntu\\n    Labels:\\n        com.example.vendor: Acme\\n        com.example.license: GPL\\n        com.example.version: \"1.0\"\\n    MacAddress: \"\"\\n    NetworkDisabled: false\\n    OpenStdin: false\\n    StdinOnce: false\\n    Tty: false\\n    User: \"\"\\n    Volumes:\\n        /volumes/data: {}\\n    WorkingDir: \"\"\\n    StopSignal: SIGTERM\\n    StopTimeout: 10\\nCreated: 2015-01-06T15:47:31.485331387Z\\nDriver: overlay2\\nExecIDs:\\n    - b35395de42bc8abd327f9dd65d913b9ba28c74d2f0734eeeae84fa1c616a0fca\\n    - 3fc1232e5cd20c8de182ed81178503dc6437f4e7ef12b52cc5e8de020652f1c4\\nHostConfig:\\n    MaximumIOps: 0\\n    MaximumIOBps: 0\\n    BlkioWeight: 0\\n    BlkioWeightDevice:\\n        - {}\\n    BlkioDeviceReadBps:\\n        - {}\\n    BlkioDeviceWriteBps:\\n        - {}\\n    BlkioDeviceReadIOps:\\n        - {}\\n    BlkioDeviceWriteIOps:\\n        - {}\\n    ContainerIDFile: \"\"\\n    CpusetCpus: \"\"\\n    CpusetMems: \"\"\\n    CpuPercent: 80\\n    CpuShares: 0\\n    CpuPeriod: 100000\\n    CpuRealtimePeriod: 1000000\\n    CpuRealtimeRuntime: 10000\\n    Devices: []\\n    DeviceRequests:\\n        - Driver: nvidia\\n          Count: -1\\n          DeviceIDs\":\\n            - \"0\"\\n            - \"1\"\\n            - GPU-fef8089b-4820-abfc-e83e-94318197576e\\n          Capabilities:\\n            - - gpu\\n              - nvidia\\n              - compute\\n          Options:\\n            property1: string\\n            property2: string\\n    IpcMode: \"\"\\n    Memory: 0\\n    MemorySwap: 0\\n    MemoryReservation: 0\\n    OomKillDisable: false\\n    OomScoreAdj: 500\\n    NetworkMode: bridge\\n    PidMode: \"\"\\n    PortBindings: {}\\n    Privileged: false\\n    ReadonlyRootfs: false\\n    PublishAllPorts: false\\n    RestartPolicy:\\n        MaximumRetryCount: 2\\n        Name: on-failure\\n    LogConfig:\\n        Type: json-file\\n    Sysctls:\\n        net.ipv4.ip_forward: \"1\"\\n    Ulimits:\\n        - {}\\n    VolumeDriver: \"\"\\n    ShmSize: 67108864\\nHostnamePath: /var/lib/docker/containers/ba033ac4401106a3b513bc9d639eee123ad78ca3616b921167cd74b20e25ed39/hostname\\nHostsPath: /var/lib/docker/containers/ba033ac4401106a3b513bc9d639eee123ad78ca3616b921167cd74b20e25ed39/hosts\\nLogPath: /var/lib/docker/containers/1eb5fabf5a03807136561b3c00adcd2992b535d624d5e18b6cdc6a6844d9767b/1eb5fabf5a03807136561b3c00adcd2992b535d624d5e18b6cdc6a6844d9767b-json.log\\nId: ba033ac4401106a3b513bc9d639eee123ad78ca3616b921167cd74b20e25ed39\\nImage: 04c5d3b7b0656168630d3ba35d8889bd0e9caafcaeb3004d2bfbc47e7c5d35d2\\nMountLabel: \"\"\\nName: /boring_euclid\\nNetworkSettings:\\n    Bridge: \"\"\\n    SandboxID: \"\"\\n    HairpinMode: false\\n    LinkLocalIPv6Address: \"\"\\n    LinkLocalIPv6PrefixLen: 0\\n    SandboxKey: \"\"\\n    EndpointID: \"\"\\n    Gateway: \"\"\\n    GlobalIPv6Address: \"\"\\n    GlobalIPv6PrefixLen: 0\\n    IPAddress: \"\"\\n    IPPrefixLen: 0\\n    IPv6Gateway: \"\"\\n    MacAddress: \"\"\\n    Networks:\\n        bridge:\\n            NetworkID: 7ea29fc1412292a2d7bba362f9253545fecdfa8ce9a6e37dd10ba8bee7129812\\n            EndpointID: 7587b82f0dada3656fda26588aee72630c6fab1536d36e394b2bfbcf898c971d\\n            Gateway: 172.17.0.1\\n            IPAddress: 172.17.0.2\\n            IPPrefixLen: 16\\n            IPv6Gateway: \"\"\\n            GlobalIPv6Address: \"\"\\n            GlobalIPv6PrefixLen: 0\\n            MacAddress: 02:42:ac:12:00:02\\nPath: /bin/sh\\nProcessLabel: \"\"\\nResolvConfPath: /var/lib/docker/containers/ba033ac4401106a3b513bc9d639eee123ad78ca3616b921167cd74b20e25ed39/resolv.conf\\nRestartCount: 1\\nState:\\n    Error: \"\"\\n    ExitCode: 9\\n    FinishedAt: 2015-01-06T15:47:32.080254511Z\\n    Health:\\n        Status: healthy\\n        FailingStreak: 0\\n        Log:\\n            - Start: 2019-12-22T10:59:05.6385933Z\\n              End: 2019-12-22T10:59:05.8078452Z\\n              ExitCode: 0\\n              Output: \"\"\\n    OOMKilled: false\\n    Dead: false\\n    Paused: false\\n    Pid: 0\\n    Restarting: false\\n    Running: true\\n    StartedAt: 2015-01-06T15:47:32.072697474Z\\n    Status: running\\nMounts:\\n    - Name: fac362...80535\\n      Source: /data\\n      Destination: /data\\n      Driver: local\\n      Mode: ro,Z\\n      RW: false\\n      Propagation: "
        schema = {
          title = "ContainerInspectResponse",
          type = "object",
          properties = {
            GraphDriver = components.schemas.GraphDriverData,
            SizeRw = integer(format("int64"), description("The size of files that have been created or changed by this\\ncontainer.")),
            HostnamePath = string(),
            HostConfig = components.schemas.HostConfig,
            LogPath = string(),
            Path = string(description("The path to the command being run")),
            Mounts = array([components.schemas.MountPoint]),
            ExecIDs = {
              description = "IDs of exec instances that are running in the container.",
              items = [string()],
              nullable = true,
              type = "array"
            },
            HostsPath = string(),
            NetworkSettings = components.schemas.NetworkSettings,
            ResolvConfPath = string(),
            Created = string(description("The time the container was created")),
            Config = components.schemas.ContainerConfig,
            MountLabel = string(),
            RestartCount = integer(),
            Driver = string(),
            Platform = string(),
            Image = string(description("The container's image ID")),
            State = components.schemas.ContainerState,
            Id = string(description("The ID of the container")),
            Name = string(),
            AppArmorProfile = string(),
            Args = array(description("The arguments to the command being run"), [string()]),
            ProcessLabel = string(),
            SizeRootFs = integer(format("int64"), description("The total size of all the files in this container."))
          }
        }
      }
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/version" "get" {
    tags = ["System"]
    summary = "Get version"
    description = "Returns the version of Docker that is running and various information about the system that Docker is running on."
    operationId = "SystemVersion"
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.SystemVersion
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/plugins" "get" {
    summary = "List plugins"
    description = "Returns information about installed plugins."
    operationId = "PluginList"
    tags = ["Plugin"]
    parameters "filters" {
      in = "query"
      description = "A JSON encoded value of the filters (a `map[string][]string`) to\\nprocess on the plugin list.\\n\\nAvailable filters:\\n\\n- `capability=<capability name>`\\n- `enable=<true>|<false>`"
      schema = string()
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        schema = array([components.schemas.Plugin])
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/secrets/create" "post" {
    summary = "Create a secret"
    operationId = "SecretCreate"
    tags = ["Secret"]
    requestBody {
      content "application/json" {
        schema = allOf(components.schemas.SecretSpec, object(example({
          Name = "app-key.crt",
          Labels = "map[foo:bar]",
          Data = "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg==",
          Driver = "map[Name:secret-bucket Options:map[OptionA:value for driver option A OptionB:value for driver option B]]"
        })))
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "201" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.IdResponse
      }
    }
    responses "409" {
      description = "name conflicts with an existing object"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/containers/create" "post" {
    summary = "Create a container"
    operationId = "ContainerCreate"
    tags = ["Container"]
    parameters "name" {
      in = "query"
      schema = string(pattern("^/?[a-zA-Z0-9][a-zA-Z0-9_.-]+$"))
      description = "Assign the specified name to the container. Must match\\n`/?[a-zA-Z0-9][a-zA-Z0-9_.-]+`."
    }
    parameters "platform" {
      description = "Platform in the format `os[/arch[/variant]]` used for image lookup.\\n\\nWhen specified, the daemon checks if the requested image is present\\nin the local image cache with the given OS and Architecture, and\\notherwise returns a `404` status.\\n\\nIf the option is not set, the host's native OS and Architecture are\\nused to look up the image in the image cache. However, if no platform\\nis passed and the given image does exist in the local image cache,\\nbut its OS or architecture does not match, the container is created\\nwith the available image, and a warning is added to the `Warnings`\\nfield in the response, for example;\\n\\n    WARNING: The requested image's platform (linux/arm64/v8) does not\\n             match the detected host platform (linux/amd64) and no\\n             specific platform was requested"
      schema = string()
      in = "query"
    }
    requestBody {
      description = "Container to create"
      required = true
      content "application/json" {
        schema = allOf(components.schemas.ContainerConfig, object({
          HostConfig = components.schemas.HostConfig,
          NetworkingConfig = components.schemas.NetworkingConfig
        }))
      }
      content "application/octet-stream" {
        schema = allOf(components.schemas.ContainerConfig, object({
          HostConfig = components.schemas.HostConfig,
          NetworkingConfig = components.schemas.NetworkingConfig
        }))
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "201" {
      description = "Container created successfully"
      content "application/json" {
        schema = components.schemas.ContainerCreateResponse
      }
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "no such image"
      content "application/json" {
        example = "message: 'No such image: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "409" {
      description = "conflict"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/containers/{id}/stop" "post" {
    summary = "Stop a container"
    operationId = "ContainerStop"
    tags = ["Container"]
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the container"
      schema = string()
    }
    parameters "signal" {
      description = "Signal to send to the container as an integer or string (e.g. `SIGINT`)."
      in = "query"
      schema = string()
    }
    parameters "t" {
      description = "Number of seconds to wait before killing the container"
      in = "query"
      schema = integer()
    }
    responses "304" {
      description = "container already stopped"
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "204" {
      description = "no error"
    }
  }
  paths "/images/{name}/history" "get" {
    summary = "Get the history of an image"
    description = "Return parent layers of an image."
    operationId = "ImageHistory"
    tags = ["Image"]
    parameters "name" {
      in = "path"
      description = "Image name or ID"
      schema = string()
      required = true
    }
    responses "200" {
      description = "List of image layers"
      content "application/json" {
        example = "- Id: 3db9c44f45209632d6050b35958829c3a2aa256d81b9a7be45b362ff85c54710\\n  Created: 1398108230\\n  CreatedBy: '/bin/sh -c #(nop) ADD file:eb15dbd63394e063b805a3c32ca7bf0266ef64676d5a6fab4801f2e81e2a5148 in /'\\n  Tags:\\n    - ubuntu:lucid\\n    - ubuntu:10.04\\n  Size: 182964289\\n  Comment: \"\"\\n- Id: 6cfa4d1f33fb861d4d114f43b25abd0ac737509268065cdfd69d544a59c85ab8\\n  Created: 1398108222\\n  CreatedBy: '/bin/sh -c #(nop) MAINTAINER Tianon Gravi <admwiggin@gmail.com> - mkimage-debootstrap.sh -i iproute,iputils-ping,ubuntu-minimal -t lucid.tar.xz lucid http://archive.ubuntu.com/ubuntu/'\\n  Tags: []\\n  Size: 0\\n  Comment: \"\"\\n- Id: 511136ea3c5a64f264b78b5433614aec563103b4d4702f3ba7d4d2698e22c158\\n  Created: 1371157430\\n  CreatedBy: \"\"\\n  Tags:\\n    - scratch12:latest\\n    - scratch:latest\\n  Size: 0\\n  Comment: Imported from -"
        schema = array([{
          title = "HistoryResponseItem",
          type = "object",
          description = "individual image layer information in response to ImageHistory operation",
          required = ["Comment", "Created", "CreatedBy", "Id", "Size", "Tags"],
          specificationExtension = {
            "x-go-name" = "HistoryResponseItem"
          },
          properties = {
            Tags = array([string()]),
            Size = integer(format("int64")),
            Comment = string(),
            Id = string(),
            Created = integer(format("int64")),
            CreatedBy = string()
          }
        }])
      }
    }
    responses "404" {
      description = "No such image"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/images/{name}/tag" "post" {
    summary = "Tag an image"
    description = "Tag an image so that it becomes part of a repository."
    operationId = "ImageTag"
    tags = ["Image"]
    parameters "name" {
      required = true
      in = "path"
      description = "Image name or ID to tag."
      schema = string()
    }
    parameters "repo" {
      in = "query"
      description = "The repository to tag in. For example, `someuser/someimage`."
      schema = string()
    }
    parameters "tag" {
      in = "query"
      description = "The name of the new tag."
      schema = string()
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "201" {
      description = "No error"
    }
    responses "400" {
      description = "Bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "No such image"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "409" {
      description = "Conflict"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/images/prune" "post" {
    summary = "Delete unused images"
    operationId = "ImagePrune"
    tags = ["Image"]
    parameters "filters" {
      description = "Filters to process on the prune list, encoded as JSON (a `map[string][]string`). Available filters:\\n\\n- `dangling=<boolean>` When set to `true` (or `1`), prune only\\n   unused *and* untagged images. When set to `false`\\n   (or `0`), all unused images are pruned.\\n- `until=<string>` Prune images created before this timestamp. The `<timestamp>` can be Unix timestamps, date formatted timestamps, or Go duration strings (e.g. `10m`, `1h30m`) computed relative to the daemon machine’s time.\\n- `label` (`label=<key>`, `label=<key>=<value>`, `label!=<key>`, or `label!=<key>=<value>`) Prune images with (or without, in case `label!=...` is used) the specified labels."
      schema = string()
      in = "query"
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        schema = {
          title = "ImagePruneResponse",
          type = "object",
          properties = {
            SpaceReclaimed = integer(format("int64"), description("Disk space reclaimed in bytes")),
            ImagesDeleted = array(description("Images that were deleted"), [components.schemas.ImageDeleteResponseItem])
          }
        }
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/volumes/{name}" "put" {
    summary = "Update a volume. Valid only for Swarm cluster volumes"
    operationId = "VolumeUpdate"
    tags = ["Volume"]
    parameters "name" {
      schema = string()
      required = true
      in = "path"
      description = "The name or ID of the volume"
    }
    parameters "version" {
      in = "query"
      description = "The version number of the volume being updated. This is required to\\navoid conflicting writes. Found in the volume's `ClusterVolume`\\nfield."
      schema = integer(format("int64"))
      required = true
    }
    requestBody {
      description = "The spec of the volume to update. Currently, only Availability may\\nchange. All other fields must remain unchanged."
      content "application/json" {
        schema = object(description("Volume configuration"), {
          Spec = components.schemas.ClusterVolumeSpec
        })
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "no such volume"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/volumes/{name}" "delete" {
    tags = ["Volume"]
    summary = "Remove a volume"
    description = "Instruct the driver to remove the volume."
    operationId = "VolumeDelete"
    parameters "name" {
      required = true
      in = "path"
      description = "Volume name or ID"
      schema = string()
    }
    parameters "force" {
      description = "Force the removal of the volume"
      in = "query"
      schema = boolean(default(false))
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "204" {
      description = "The volume was removed"
    }
    responses "404" {
      description = "No such volume or volume driver"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "409" {
      description = "Volume is in use and cannot be removed"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/volumes/{name}" "get" {
    summary = "Inspect a volume"
    operationId = "VolumeInspect"
    tags = ["Volume"]
    parameters "name" {
      description = "Volume name or ID"
      schema = string()
      required = true
      in = "path"
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        schema = components.schemas.Volume
      }
    }
    responses "404" {
      description = "No such volume"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/nodes" "get" {
    operationId = "NodeList"
    summary = "List nodes"
    tags = ["Node"]
    parameters "filters" {
      in = "query"
      description = "Filters to process on the nodes list, encoded as JSON (a `map[string][]string`).\\n\\nAvailable filters:\\n- `id=<node id>`\\n- `label=<engine label>`\\n- `membership=`(`accepted`|`pending`)`\\n- `name=<node name>`\\n- `node.label=<node label>`\\n- `role=`(`manager`|`worker`)`"
      schema = string()
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = array([components.schemas.Node])
      }
      content "text/plain" {
        schema = array([components.schemas.Node])
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/plugins/privileges" "get" {
    summary = "Get plugin privileges"
    operationId = "GetPluginPrivileges"
    tags = ["Plugin"]
    parameters "remote" {
      schema = string()
      required = true
      in = "query"
      description = "The name of the plugin. The `:latest` tag is optional, and is the\\ndefault if omitted."
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = array(example(["map[Description: Name:network Value:[host]]", "map[Description: Name:mount Value:[/data]]", "map[Description: Name:device Value:[/dev/cpu_dma_latency]]"]), [components.schemas.PluginPrivilege])
      }
      content "text/plain" {
        schema = array(example(["map[Description: Name:network Value:[host]]", "map[Description: Name:mount Value:[/data]]", "map[Description: Name:device Value:[/dev/cpu_dma_latency]]"]), [components.schemas.PluginPrivilege])
      }
    }
  }
  paths "/containers/{id}/logs" "get" {
    operationId = "ContainerLogs"
    tags = ["Container"]
    summary = "Get container logs"
    description = "Get `stdout` and `stderr` logs from a container.\\n\\nNote: This endpoint works only for containers with the `json-file` or\\n`journald` logging driver."
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the container"
      schema = string()
    }
    parameters "follow" {
      in = "query"
      description = "Keep connection after returning logs."
      schema = boolean(default(false))
    }
    parameters "stdout" {
      in = "query"
      description = "Return logs from `stdout`"
      schema = boolean(default(false))
    }
    parameters "stderr" {
      description = "Return logs from `stderr`"
      schema = boolean(default(false))
      in = "query"
    }
    parameters "since" {
      in = "query"
      description = "Only return logs since this time, as a UNIX timestamp"
      schema = integer(default(0))
    }
    parameters "until" {
      in = "query"
      description = "Only return logs before this time, as a UNIX timestamp"
      schema = integer(default(0))
    }
    parameters "timestamps" {
      description = "Add timestamps to every log line"
      in = "query"
      schema = boolean(default(false))
    }
    parameters "tail" {
      in = "query"
      description = "Only return this number of log lines from the end of the logs.\\nSpecify as an integer or `all` to output all log lines."
      schema = string(default("all"))
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
      }
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "logs returned as a stream in response body.\\nFor the stream format, [see the documentation for the attach endpoint](#operation/ContainerAttach).\\nNote that unlike the attach endpoint, the logs endpoint does not\\nupgrade the connection and does not set Content-Type."
      content "application/vnd.docker.raw-stream" {
        schema = string(format("binary"))
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = string(format("binary"))
      }
    }
  }
  paths "/containers/{id}/stats" "get" {
    description = "This endpoint returns a live stream of a container’s resource usage\\nstatistics.\\n\\nThe `precpu_stats` is the CPU statistic of the *previous* read, and is\\nused to calculate the CPU usage percentage. It is not an exact copy\\nof the `cpu_stats` field.\\n\\nIf either `precpu_stats.online_cpus` or `cpu_stats.online_cpus` is\\nnil then for compatibility with older daemons the length of the\\ncorresponding `cpu_usage.percpu_usage` array should be used.\\n\\nOn a cgroup v2 host, the following fields are not set\\n* `blkio_stats`: all fields other than `io_service_bytes_recursive`\\n* `cpu_stats`: `cpu_usage.percpu_usage`\\n* `memory_stats`: `max_usage` and `failcnt`\\nAlso, `memory_stats.stats` fields are incompatible with cgroup v1.\\n\\nTo calculate the values shown by the `stats` command of the docker cli tool\\nthe following formulas can be used:\\n* used_memory = `memory_stats.usage - memory_stats.stats.cache`\\n* available_memory = `memory_stats.limit`\\n* Memory usage % = `(used_memory / available_memory) * 100.0`\\n* cpu_delta = `cpu_stats.cpu_usage.total_usage - precpu_stats.cpu_usage.total_usage`\\n* system_cpu_delta = `cpu_stats.system_cpu_usage - precpu_stats.system_cpu_usage`\\n* number_cpus = `lenght(cpu_stats.cpu_usage.percpu_usage)` or `cpu_stats.online_cpus`\\n* CPU usage % = `(cpu_delta / system_cpu_delta) * number_cpus * 100.0`"
    operationId = "ContainerStats"
    tags = ["Container"]
    summary = "Get container stats based on resource usage"
    parameters "id" {
      description = "ID or name of the container"
      schema = string()
      required = true
      in = "path"
    }
    parameters "stream" {
      schema = boolean(default(true))
      in = "query"
      description = "Stream the output. If false, the stats will be output once and then\\nit will disconnect."
    }
    parameters "one-shot" {
      in = "query"
      description = "Only get a single stat instead of waiting for 2 cycles. Must be used\\nwith `stream=false`."
      schema = boolean(default(false))
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        example = "read: 2015-01-08T22:57:31.547920715Z\\npids_stats:\\n    current: 3\\nnetworks:\\n    eth0:\\n        rx_bytes: 5338\\n        rx_dropped: 0\\n        rx_errors: 0\\n        rx_packets: 36\\n        tx_bytes: 648\\n        tx_dropped: 0\\n        tx_errors: 0\\n        tx_packets: 8\\n    eth5:\\n        rx_bytes: 4641\\n        rx_dropped: 0\\n        rx_errors: 0\\n        rx_packets: 26\\n        tx_bytes: 690\\n        tx_dropped: 0\\n        tx_errors: 0\\n        tx_packets: 9\\nmemory_stats:\\n    stats:\\n        total_pgmajfault: 0\\n        cache: 0\\n        mapped_file: 0\\n        total_inactive_file: 0\\n        pgpgout: 414\\n        rss: 6537216\\n        total_mapped_file: 0\\n        writeback: 0\\n        unevictable: 0\\n        pgpgin: 477\\n        total_unevictable: 0\\n        pgmajfault: 0\\n        total_rss: 6537216\\n        total_rss_huge: 6291456\\n        total_writeback: 0\\n        total_inactive_anon: 0\\n        rss_huge: 6291456\\n        hierarchical_memory_limit: 67108864\\n        total_pgfault: 964\\n        total_active_file: 0\\n        active_anon: 6537216\\n        total_active_anon: 6537216\\n        total_pgpgout: 414\\n        total_cache: 0\\n        inactive_anon: 0\\n        active_file: 0\\n        pgfault: 964\\n        inactive_file: 0\\n        total_pgpgin: 477\\n    max_usage: 6651904\\n    usage: 6537216\\n    failcnt: 0\\n    limit: 67108864\\nblkio_stats: {}\\ncpu_stats:\\n    cpu_usage:\\n        percpu_usage:\\n            - 8646879\\n            - 24472255\\n            - 36438778\\n            - 30657443\\n        usage_in_usermode: 50000000\\n        total_usage: 100215355\\n        usage_in_kernelmode: 30000000\\n    system_cpu_usage: 739306590000000\\n    online_cpus: 4\\n    throttling_data:\\n        periods: 0\\n        throttled_periods: 0\\n        throttled_time: 0\\nprecpu_stats:\\n    cpu_usage:\\n        percpu_usage:\\n            - 8646879\\n            - 24350896\\n            - 36438778\\n            - 30657443\\n        usage_in_usermode: 50000000\\n        total_usage: 100093996\\n        usage_in_kernelmode: 30000000\\n    system_cpu_usage: 9492140000000\\n    online_cpus: 4\\n    throttling_data:\\n        periods: 0\\n        throttled_periods: 0\\n        throttled_time: 0"
        schema = object()
      }
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/attach/ws" "get" {
    summary = "Attach to a container via a websocket"
    operationId = "ContainerAttachWebsocket"
    tags = ["Container"]
    parameters "id" {
      in = "path"
      description = "ID or name of the container"
      schema = string()
      required = true
    }
    parameters "detachKeys" {
      in = "query"
      description = "Override the key sequence for detaching a container.Format is a single\\ncharacter `[a-Z]` or `ctrl-<value>` where `<value>` is one of: `a-z`,\\n`@`, `^`, `[`, `,`, or `_`."
      schema = string()
    }
    parameters "logs" {
      in = "query"
      description = "Return logs"
      schema = boolean(default(false))
    }
    parameters "stream" {
      in = "query"
      description = "Return stream"
      schema = boolean(default(false))
    }
    parameters "stdin" {
      in = "query"
      description = "Attach to `stdin`"
      schema = boolean(default(false))
    }
    parameters "stdout" {
      in = "query"
      description = "Attach to `stdout`"
      schema = boolean(default(false))
    }
    parameters "stderr" {
      in = "query"
      description = "Attach to `stderr`"
      schema = boolean(default(false))
    }
    responses "200" {
      description = "no error, no upgrade header found"
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "101" {
      description = "no error, hints proxy about hijacking"
    }
  }
  paths "/images/load" "post" {
    operationId = "ImageLoad"
    summary = "Import images"
    description = "Load a set of images and tags into a repository.\\n\\nFor details on the format, see the [export image endpoint](#operation/ImageGet)."
    tags = ["Image"]
    parameters "quiet" {
      description = "Suppress progress details during load."
      in = "query"
      schema = boolean(default(false))
    }
    requestBody {
      description = "Tar archive containing images"
      content "application/x-tar" {
        schema = string(format("binary"))
      }
    }
    responses "200" {
      description = "no error"
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "imagesTarball"
    }
  }
  paths "/services/{id}/logs" "get" {
    summary = "Get service logs"
    description = "Get `stdout` and `stderr` logs from a service. See also\\n[`/containers/{id}/logs`](#operation/ContainerLogs).\\n\\n**Note**: This endpoint works only for services with the `local`,\\n`json-file` or `journald` logging drivers."
    operationId = "ServiceLogs"
    tags = ["Service"]
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the service"
      schema = string()
    }
    parameters "details" {
      description = "Show service context and extra details provided to logs."
      schema = boolean(default(false))
      in = "query"
    }
    parameters "follow" {
      in = "query"
      schema = boolean(default(false))
      description = "Keep connection after returning logs."
    }
    parameters "stdout" {
      in = "query"
      description = "Return logs from `stdout`"
      schema = boolean(default(false))
    }
    parameters "stderr" {
      in = "query"
      description = "Return logs from `stderr`"
      schema = boolean(default(false))
    }
    parameters "since" {
      in = "query"
      description = "Only return logs since this time, as a UNIX timestamp"
      schema = integer(default(0))
    }
    parameters "timestamps" {
      in = "query"
      description = "Add timestamps to every log line"
      schema = boolean(default(false))
    }
    parameters "tail" {
      description = "Only return this number of log lines from the end of the logs.\\nSpecify as an integer or `all` to output all log lines."
      in = "query"
      schema = string(default("all"))
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "logs returned as a stream in response body"
      content "application/vnd.docker.raw-stream" {
        schema = string(format("binary"))
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = string(format("binary"))
      }
    }
    responses "404" {
      description = "no such service"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        example = "message: 'No such service: c2ada9df5af8'"
      }
    }
    responses "500" {
      description = "server error"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/kill" "post" {
    operationId = "ContainerKill"
    summary = "Kill a container"
    tags = ["Container"]
    description = "Send a POSIX signal to a container, defaulting to killing to the\\ncontainer."
    parameters "id" {
      in = "path"
      description = "ID or name of the container"
      schema = string()
      required = true
    }
    parameters "signal" {
      in = "query"
      description = "Signal to send to the container as an integer or string (e.g. `SIGINT`)."
      schema = string(default("SIGKILL"))
    }
    responses "409" {
      description = "container is not running"
      content "application/json" {
        example = "message: Container d37cde0fe4ad63c3a7252023b2f9800282894247d145cb5933ddf6e52cc03a28 is not running"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "204" {
      description = "no error"
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/configs/create" "post" {
    operationId = "ConfigCreate"
    summary = "Create a config"
    tags = ["Config"]
    requestBody {
      content "application/json" {
        schema = allOf(components.schemas.ConfigSpec, object(example({
          Name = "server.conf",
          Labels = "map[foo:bar]",
          Data = "VEhJUyBJUyBOT1QgQSBSRUFMIENFUlRJRklDQVRFCg=="
        })))
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "201" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.IdResponse
      }
    }
    responses "409" {
      description = "name conflicts with an existing object"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/containers/{id}/unpause" "post" {
    description = "Resume a container which has been paused."
    operationId = "ContainerUnpause"
    tags = ["Container"]
    summary = "Unpause a container"
    parameters "id" {
      required = true
      description = "ID or name of the container"
      in = "path"
      schema = string()
    }
    responses "204" {
      description = "no error"
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/images/{name}/push" "post" {
    summary = "Push an image"
    tags = ["Image"]
    description = "Push an image to a registry.\\n\\nIf you wish to push an image on to a private registry, that image must\\nalready have a tag which references the registry. For example,\\n`registry.example.com/myimage:latest`.\\n\\nThe push is cancelled if the HTTP connection is closed."
    operationId = "ImagePush"
    parameters "name" {
      required = true
      in = "path"
      description = "Image name or ID."
      schema = string()
    }
    parameters "tag" {
      schema = string()
      in = "query"
      description = "The tag to associate with the image on the registry."
    }
    parameters "X-Registry-Auth" {
      required = true
      in = "header"
      description = "A base64url-encoded auth configuration.\\n\\nRefer to the [authentication section](#section/Authentication) for\\ndetails."
      schema = string()
    }
    parameters "platform" {
      in = "query"
      description = "Select a platform-specific manifest to be pushed. OCI platform (JSON encoded)"
      schema = {
        nullable = true,
        type = "string"
      }
    }
    responses "500" {
      description = "Server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "No error"
    }
    responses "404" {
      description = "No such image"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/exec" "post" {
    operationId = "ContainerExec"
    tags = ["Exec"]
    summary = "Create an exec instance"
    description = "Run a command inside a running container."
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of container"
      schema = string()
    }
    requestBody {
      description = "Exec configuration"
      required = true
      content "application/json" {
        schema = {
          title = "ExecConfig",
          type = "object",
          example = {
            Cmd = "[date]",
            Env = "[FOO=bar BAZ=quux]",
            AttachStdin = "false",
            AttachStdout = "true",
            AttachStderr = "true",
            DetachKeys = "ctrl-p,ctrl-q",
            Tty = "false"
          },
          properties = {
            Env = array(description("A list of environment variables in the form `[\"VAR=value\", ...]`."), [string()]),
            AttachStdin = boolean(description("Attach to `stdin` of the exec command.")),
            Cmd = array(description("Command to run, as a string or array of strings."), [string()]),
            AttachStdout = boolean(description("Attach to `stdout` of the exec command.")),
            AttachStderr = boolean(description("Attach to `stderr` of the exec command.")),
            Tty = boolean(description("Allocate a pseudo-TTY.")),
            ConsoleSize = {
              nullable = true,
              type = "array",
              description = "Initial console size, as an `[height, width]` array.",
              minItems = 2,
              maxItems = 2,
              items = [integer()]
            },
            DetachKeys = string(description("Override the key sequence for detaching a container. Format is\\na single character `[a-Z]` or `ctrl-<value>` where `<value>`\\nis one of: `a-z`, `@`, `^`, `[`, `,` or `_`.")),
            WorkingDir = string(description("The working directory for the exec process inside the container.")),
            Privileged = boolean(description("Runs the exec process with extended privileges."), default(false)),
            User = string(description("The user, and optionally, group to run the exec process inside\\nthe container. Format is one of: `user`, `user:group`, `uid`,\\nor `uid:gid`."))
          }
        }
      }
    }
    responses "201" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.IdResponse
      }
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "409" {
      description = "container is paused"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "execConfig"
    }
  }
  paths "/swarm/unlock" "post" {
    summary = "Unlock a locked manager"
    operationId = "SwarmUnlock"
    tags = ["Swarm"]
    requestBody {
      required = true
      content "application/json" {
        schema = {
          title = "SwarmUnlockRequest",
          type = "object",
          example = {
            UnlockKey = "SWMKEY-1-7c37Cc8654o6p38HnroywCi19pllOnGtbdZEgtKxZu8"
          },
          properties = {
            UnlockKey = string(description("The swarm's unlock key."))
          }
        }
      }
    }
    responses "200" {
      description = "no error"
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/volumes/create" "post" {
    summary = "Create a volume"
    operationId = "VolumeCreate"
    tags = ["Volume"]
    requestBody {
      description = "Volume configuration"
      required = true
      content "application/json" {
        schema = components.schemas.VolumeCreateOptions
      }
    }
    responses "201" {
      description = "The volume was created successfully"
      content "application/json" {
        schema = components.schemas.Volume
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "volumeConfig"
    }
  }
  paths "/networks/{id}" "get" {
    tags = ["Network"]
    summary = "Inspect a network"
    operationId = "NetworkInspect"
    parameters "id" {
      required = true
      in = "path"
      description = "Network ID or name"
      schema = string()
    }
    parameters "verbose" {
      description = "Detailed inspect output for troubleshooting"
      in = "query"
      schema = boolean(default(false))
    }
    parameters "scope" {
      in = "query"
      description = "Filter the network by scope (swarm, global, or local)"
      schema = string()
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        schema = components.schemas.Network
      }
    }
    responses "404" {
      description = "Network not found"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/networks/{id}" "delete" {
    tags = ["Network"]
    operationId = "NetworkDelete"
    summary = "Remove a network"
    parameters "id" {
      schema = string()
      required = true
      in = "path"
      description = "Network ID or name"
    }
    responses "204" {
      description = "No error"
    }
    responses "403" {
      description = "operation not supported for pre-defined networks"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "no such network"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/secrets" "get" {
    summary = "List secrets"
    operationId = "SecretList"
    tags = ["Secret"]
    parameters "filters" {
      in = "query"
      description = "A JSON encoded value of the filters (a `map[string][]string`) to\\nprocess on the secrets list.\\n\\nAvailable filters:\\n\\n- `id=<secret id>`\\n- `label=<key> or label=<key>=value`\\n- `name=<secret name>`\\n- `names=<secret name>`"
      schema = string()
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = array(example(["map[CreatedAt:2017-07-20T13:55:28.678958722Z ID:blt1owaxmitz71s9v5zh81zun Spec:map[Driver:map[Name:secret-bucket Options:map[OptionA:value for driver option A OptionB:value for driver option B]] Labels:map[some.label:some.value] Name:mysql-passwd] UpdatedAt:2017-07-20T13:55:28.678958722Z Version:map[Index:85]]", "map[CreatedAt:2016-11-05T01:20:17.327670065Z ID:ktnbjxoalbkvbvedmg1urrz8h Spec:map[Labels:map[foo:bar] Name:app-dev.crt] UpdatedAt:2016-11-05T01:20:17.327670065Z Version:map[Index:11]]"]), [components.schemas.Secret])
      }
    }
  }
  paths "/images/get" "get" {
    summary = "Export several images"
    description = "Get a tarball containing all images and metadata for several image\\nrepositories.\\n\\nFor each value of the `names` parameter: if it is a specific name and\\ntag (e.g. `ubuntu:latest`), then only that image (and its parents) are\\nreturned; if it is an image ID, similarly only that image (and its parents)\\nare returned and there would be no names referenced in the 'repositories'\\nfile for this image ID.\\n\\nFor details on the format, see the [export image endpoint](#operation/ImageGet)."
    operationId = "ImageGetAll"
    tags = ["Image"]
    parameters "names" {
      description = "Image names to filter by"
      style = "form"
      in = "query"
      schema = array([string()])
    }
    responses "500" {
      description = "server error"
      content "application/x-tar" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
      content "application/x-tar" {
        schema = string(format("binary"))
      }
    }
  }
  paths "/plugins/{name}/disable" "post" {
    summary = "Disable a plugin"
    operationId = "PluginDisable"
    tags = ["Plugin"]
    parameters "name" {
      required = true
      in = "path"
      description = "The name of the plugin. The `:latest` tag is optional, and is the\\ndefault if omitted."
      schema = string()
    }
    parameters "force" {
      in = "query"
      description = "Force disable a plugin even if still in use."
      schema = boolean()
    }
    responses "200" {
      description = "no error"
    }
    responses "404" {
      description = "plugin is not installed"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/top" "get" {
    tags = ["Container"]
    summary = "List processes running inside a container"
    description = "On Unix systems, this is done by running the `ps` command. This endpoint\\nis not supported on Windows."
    operationId = "ContainerTop"
    parameters "id" {
      in = "path"
      description = "ID or name of the container"
      schema = string()
      required = true
    }
    parameters "ps_args" {
      schema = string(default("-ef"))
      in = "query"
      description = "The arguments to pass to `ps`. For example, `aux`"
    }
    responses "200" {
      description = "no error"
      content "text/plain" {
        schema = {
          title = "ContainerTopResponse",
          type = "object",
          description = "OK response to ContainerTop operation",
          properties = {
            Titles = array(description("The ps column titles"), [string()]),
            Processes = array(description("Each process running in the container, where each is process\\nis an array of values corresponding to the titles."), [array([string()])])
          }
        }
      }
      content "application/json" {
        schema = {
          title = "ContainerTopResponse",
          type = "object",
          description = "OK response to ContainerTop operation",
          properties = {
            Titles = array(description("The ps column titles"), [string()]),
            Processes = array(description("Each process running in the container, where each is process\\nis an array of values corresponding to the titles."), [array([string()])])
          }
        }
        example = "Titles:\\n    - UID\\n    - PID\\n    - PPID\\n    - C\\n    - STIME\\n    - TTY\\n    - TIME\\n    - CMD\\nProcesses:\\n    - - root\\n      - \"13642\"\\n      - \"882\"\\n      - \"0\"\\n      - 17:03\\n      - pts/0\\n      - 00:00:00\\n      - /bin/bash\\n    - - root\\n      - \"13735\"\\n      - \"13642\"\\n      - \"0\"\\n      - 17:06\\n      - pts/0\\n      - 00:00:00\\n      - sleep 10"
      }
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/images/{name}/json" "get" {
    summary = "Inspect an image"
    description = "Return low-level information about an image."
    operationId = "ImageInspect"
    tags = ["Image"]
    parameters "name" {
      in = "path"
      description = "Image name or id"
      schema = string()
      required = true
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        schema = components.schemas.ImageInspect
      }
    }
    responses "404" {
      description = "No such image"
      content "application/json" {
        example = "message: 'No such image: someimage (tag: latest)'"
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/images/search" "get" {
    summary = "Search images"
    description = "Search for an image on Docker Hub."
    operationId = "ImageSearch"
    tags = ["Image"]
    parameters "term" {
      required = true
      in = "query"
      description = "Term to search"
      schema = string()
    }
    parameters "limit" {
      in = "query"
      description = "Maximum number of results to return"
      schema = integer()
    }
    parameters "filters" {
      in = "query"
      description = "A JSON encoded value of the filters (a `map[string][]string`) to process on the images list. Available filters:\\n\\n- `is-official=(true|false)`\\n- `stars=<number>` Matches images that has at least 'number' stars."
      schema = string()
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        example = "- description: A minimal Docker image based on Alpine Linux with a complete package index and only 5 MB in size!\\n  is_official: true\\n  is_automated: false\\n  name: alpine\\n  star_count: 10093\\n- description: Busybox base image.\\n  is_official: true\\n  is_automated: false\\n  name: Busybox base image.\\n  star_count: 3037\\n- description: The PostgreSQL object-relational database system provides reliability and data integrity.\\n  is_official: true\\n  is_automated: false\\n  name: postgres\\n  star_count: 12408"
        schema = array([{
          title = "ImageSearchResponseItem",
          type = "object",
          properties = {
            is_official = boolean(),
            is_automated = boolean(description("Whether this repository has automated builds enabled.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: This field is deprecated and will always be \"false\"."), example(false)),
            name = string(),
            star_count = integer(),
            description = string()
          }
        }])
      }
    }
  }
  paths "/info" "get" {
    summary = "Get system information"
    operationId = "SystemInfo"
    tags = ["System"]
    responses "200" {
      description = "No error"
      content "application/json" {
        schema = components.schemas.SystemInfo
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/plugins/{name}/json" "get" {
    summary = "Inspect a plugin"
    operationId = "PluginInspect"
    tags = ["Plugin"]
    parameters "name" {
      in = "path"
      description = "The name of the plugin. The `:latest` tag is optional, and is the\\ndefault if omitted."
      schema = string()
      required = true
    }
    responses "200" {
      description = "no error"
      content "text/plain" {
        schema = components.schemas.Plugin
      }
      content "application/json" {
        schema = components.schemas.Plugin
      }
    }
    responses "404" {
      description = "plugin is not installed"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/restart" "post" {
    tags = ["Container"]
    operationId = "ContainerRestart"
    summary = "Restart a container"
    parameters "id" {
      schema = string()
      required = true
      description = "ID or name of the container"
      in = "path"
    }
    parameters "signal" {
      in = "query"
      description = "Signal to send to the container as an integer or string (e.g. `SIGINT`)."
      schema = string()
    }
    parameters "t" {
      schema = integer()
      in = "query"
      description = "Number of seconds to wait before killing the container"
    }
    responses "204" {
      description = "no error"
    }
    responses "404" {
      description = "no such container"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/build" "post" {
    summary = "Build an image"
    description = "Build an image from a tar archive with a `Dockerfile` in it.\\n\\nThe `Dockerfile` specifies how the image is built from the tar archive. It is typically in the archive's root, but can be at a different path or have a different name by specifying the `dockerfile` parameter. [See the `Dockerfile` reference for more information](https://docs.docker.com/engine/reference/builder/).\\n\\nThe Docker daemon performs a preliminary validation of the `Dockerfile` before starting the build, and returns an error if the syntax is incorrect. After that, each instruction is run one-by-one until the ID of the new image is output.\\n\\nThe build is canceled if the client drops the connection by quitting or being killed."
    operationId = "ImageBuild"
    tags = ["Image"]
    parameters "dockerfile" {
      in = "query"
      description = "Path within the build context to the `Dockerfile`. This is ignored if `remote` is specified and points to an external `Dockerfile`."
      schema = string(default("Dockerfile"))
    }
    parameters "t" {
      in = "query"
      description = "A name and optional tag to apply to the image in the `name:tag` format. If you omit the tag the default `latest` value is assumed. You can provide several `t` parameters."
      schema = string()
    }
    parameters "extrahosts" {
      in = "query"
      schema = string()
      description = "Extra hosts to add to /etc/hosts"
    }
    parameters "remote" {
      schema = string()
      in = "query"
      description = "A Git repository URI or HTTP/HTTPS context URI. If the URI points to a single text file, the file’s contents are placed into a file called `Dockerfile` and the image is built from that file. If the URI points to a tarball, the file is downloaded by the daemon and the contents therein used as the context for the build. If the URI points to a tarball and the `dockerfile` parameter is also specified, there must be a file with the corresponding path inside the tarball."
    }
    parameters "q" {
      schema = boolean(default(false))
      in = "query"
      description = "Suppress verbose build output."
    }
    parameters "nocache" {
      description = "Do not use the cache when building the image."
      in = "query"
      schema = boolean(default(false))
    }
    parameters "cachefrom" {
      description = "JSON array of images used for build cache resolution."
      schema = string()
      in = "query"
    }
    parameters "pull" {
      in = "query"
      description = "Attempt to pull the image even if an older image exists locally."
      schema = string()
    }
    parameters "rm" {
      in = "query"
      description = "Remove intermediate containers after a successful build."
      schema = boolean(default(true))
    }
    parameters "forcerm" {
      in = "query"
      description = "Always remove intermediate containers, even upon failure."
      schema = boolean(default(false))
    }
    parameters "memory" {
      schema = integer()
      description = "Set memory limit for build."
      in = "query"
    }
    parameters "memswap" {
      in = "query"
      description = "Total memory (memory + swap). Set as `-1` to disable swap."
      schema = integer()
    }
    parameters "cpushares" {
      description = "CPU shares (relative weight)."
      schema = integer()
      in = "query"
    }
    parameters "cpusetcpus" {
      description = "CPUs in which to allow execution (e.g., `0-3`, `0,1`)."
      in = "query"
      schema = string()
    }
    parameters "cpuperiod" {
      in = "query"
      description = "The length of a CPU period in microseconds."
      schema = integer()
    }
    parameters "cpuquota" {
      in = "query"
      description = "Microseconds of CPU time that the container can get in a CPU period."
      schema = integer()
    }
    parameters "buildargs" {
      in = "query"
      description = "JSON map of string pairs for build-time variables. Users pass these values at build-time. Docker uses the buildargs as the environment context for commands run via the `Dockerfile` RUN instruction, or for variable expansion in other `Dockerfile` instructions. This is not meant for passing secret values.\\n\\nFor example, the build arg `FOO=bar` would become `{\"FOO\":\"bar\"}` in JSON. This would result in the query parameter `buildargs={\"FOO\":\"bar\"}`. Note that `{\"FOO\":\"bar\"}` should be URI component encoded.\\n\\n[Read more about the buildargs instruction.](https://docs.docker.com/engine/reference/builder/#arg)"
      schema = string()
    }
    parameters "shmsize" {
      in = "query"
      description = "Size of `/dev/shm` in bytes. The size must be greater than 0. If omitted the system uses 64MB."
      schema = integer()
    }
    parameters "squash" {
      schema = boolean()
      in = "query"
      description = "Squash the resulting images layers into a single layer. *(Experimental release only.)*"
    }
    parameters "labels" {
      in = "query"
      description = "Arbitrary key/value labels to set on the image, as a JSON map of string pairs."
      schema = string()
    }
    parameters "networkmode" {
      description = "Sets the networking mode for the run commands during build. Supported\\nstandard values are: `bridge`, `host`, `none`, and `container:<name|id>`.\\nAny other value is taken as a custom network's name or ID to which this\\ncontainer should connect to."
      in = "query"
      schema = string()
    }
    parameters "Content-type" {
      schema = string(default("application/x-tar"), enum("application/x-tar"))
      in = "header"
    }
    parameters "X-Registry-Config" {
      in = "header"
      description = "This is a base64-encoded JSON object with auth configurations for multiple registries that a build may refer to.\\n\\nThe key is a registry URL, and the value is an auth configuration object, [as described in the authentication section](#section/Authentication). For example:\\n\\n```\\n{\\n  \"docker.example.com\": {\\n    \"username\": \"janedoe\",\\n    \"password\": \"hunter2\"\\n  },\\n  \"https://index.docker.io/v1/\": {\\n    \"username\": \"mobydock\",\\n    \"password\": \"conta1n3rize14\"\\n  }\\n}\\n```\\n\\nOnly the registry domain name (and port if not the default 443) are required. However, for legacy reasons, the Docker Hub registry must be specified with both a `https://` prefix and a `/v1/` suffix even though Docker will prefer to use the v2 registry API."
      schema = string()
    }
    parameters "platform" {
      schema = string()
      in = "query"
      description = "Platform in the format os[/arch[/variant]]"
    }
    parameters "target" {
      in = "query"
      description = "Target build stage"
      schema = string()
    }
    parameters "outputs" {
      in = "query"
      description = "BuildKit output configuration"
      schema = string()
    }
    parameters "version" {
      in = "query"
      description = "Version of the builder backend to use.\\n\\n- `1` is the first generation classic (deprecated) builder in the Docker daemon (default)\\n- `2` is [BuildKit](https://github.com/moby/buildkit)"
      schema = string(default("1"), enum("1", "2"))
    }
    requestBody {
      description = "A tar archive compressed with one of the following algorithms: identity (no compression), gzip, bzip2, xz."
      content "application/octet-stream" {
        schema = string(format("binary"))
      }
    }
    responses "400" {
      description = "Bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
    }
    specificationExtension {
      x-codegen-request-body-name = "inputStream"
    }
  }
  paths "/containers/prune" "post" {
    summary = "Delete stopped containers"
    tags = ["Container"]
    operationId = "ContainerPrune"
    parameters "filters" {
      in = "query"
      description = "Filters to process on the prune list, encoded as JSON (a `map[string][]string`).\\n\\nAvailable filters:\\n- `until=<timestamp>` Prune containers created before this timestamp. The `<timestamp>` can be Unix timestamps, date formatted timestamps, or Go duration strings (e.g. `10m`, `1h30m`) computed relative to the daemon machine’s time.\\n- `label` (`label=<key>`, `label=<key>=<value>`, `label!=<key>`, or `label!=<key>=<value>`) Prune containers with (or without, in case `label!=...` is used) the specified labels."
      schema = string()
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        schema = {
          title = "ContainerPruneResponse",
          type = "object",
          properties = {
            ContainersDeleted = array(description("Container IDs that were deleted"), [string()]),
            SpaceReclaimed = integer(format("int64"), description("Disk space reclaimed in bytes"))
          }
        }
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/commit" "post" {
    summary = "Create a new image from a container"
    operationId = "ImageCommit"
    tags = ["Image"]
    parameters "container" {
      in = "query"
      description = "The ID or name of the container to commit"
      schema = string()
    }
    parameters "repo" {
      description = "Repository name for the created image"
      in = "query"
      schema = string()
    }
    parameters "tag" {
      in = "query"
      description = "Tag name for the create image"
      schema = string()
    }
    parameters "comment" {
      in = "query"
      description = "Commit message"
      schema = string()
    }
    parameters "author" {
      in = "query"
      description = "Author of the image (e.g., `John Hannibal Smith <hannibal@a-team.com>`)"
      schema = string()
    }
    parameters "pause" {
      in = "query"
      description = "Whether to pause the container before committing"
      schema = boolean(default(true))
    }
    parameters "changes" {
      in = "query"
      description = "`Dockerfile` instructions to apply while committing"
      schema = string()
    }
    requestBody {
      description = "The container configuration"
      content "application/json" {
        schema = components.schemas.ContainerConfig
      }
    }
    responses "201" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.IdResponse
      }
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "containerConfig"
    }
  }
  paths "/plugins/{name}/enable" "post" {
    summary = "Enable a plugin"
    operationId = "PluginEnable"
    tags = ["Plugin"]
    parameters "name" {
      required = true
      in = "path"
      description = "The name of the plugin. The `:latest` tag is optional, and is the\\ndefault if omitted."
      schema = string()
    }
    parameters "timeout" {
      description = "Set the HTTP client timeout (in seconds)"
      schema = integer(default(0))
      in = "query"
    }
    responses "404" {
      description = "plugin is not installed"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
    }
  }
  paths "/services/{id}/update" "post" {
    summary = "Update a service"
    operationId = "ServiceUpdate"
    tags = ["Service"]
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of service."
      schema = string()
    }
    parameters "version" {
      required = true
      in = "query"
      description = "The version number of the service object being updated. This is\\nrequired to avoid conflicting writes.\\nThis version number should be the value as currently set on the\\nservice *before* the update. You can find the current version by\\ncalling `GET /services/{id}`"
      schema = integer()
    }
    parameters "registryAuthFrom" {
      in = "query"
      description = "If the `X-Registry-Auth` header is not specified, this parameter\\nindicates where to find registry authorization credentials."
      schema = string(default("spec"), enum("spec", "previous-spec"))
    }
    parameters "rollback" {
      in = "query"
      description = "Set to this parameter to `previous` to cause a server-side rollback\\nto the previous service spec. The supplied spec will be ignored in\\nthis case."
      schema = string()
    }
    parameters "X-Registry-Auth" {
      in = "header"
      description = "A base64url-encoded auth configuration for pulling from private\\nregistries.\\n\\nRefer to the [authentication section](#section/Authentication) for\\ndetails."
      schema = string()
    }
    requestBody {
      required = true
      content "application/json" {
        schema = allOf(components.schemas.ServiceSpec, object(example({
          Name = "top",
          TaskTemplate = "map[ContainerSpec:map[Args:[top] Image:busybox OomScoreAdj:0] ForceUpdate:0 Placement:map[] Resources:map[Limits:map[] Reservations:map[]] RestartPolicy:map[Condition:any MaxAttempts:0]]",
          Mode = "map[Replicated:map[Replicas:1]]",
          UpdateConfig = "map[Delay:1000000000 FailureAction:pause MaxFailureRatio:0.15 Monitor:15000000000 Parallelism:2]",
          RollbackConfig = "map[Delay:1000000000 FailureAction:pause MaxFailureRatio:0.15 Monitor:15000000000 Parallelism:1]",
          EndpointSpec = "map[Mode:vip]"
        })))
      }
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "no such service"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.ServiceUpdateResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/system/df" "get" {
    operationId = "SystemDataUsage"
    tags = ["System"]
    summary = "Get data usage information"
    parameters "type" {
      style = "form"
      schema = array([string(enum("container", "image", "volume", "build-cache"))])
      explode = true
      in = "query"
      description = "Object types, for which to compute and return data."
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = {
          title = "SystemDataUsageResponse",
          type = "object",
          example = {
            LayersSize = "1092588",
            Images = "[map[Containers:1 Created:1466724217 Id:sha256:2b8fd9751c4c0f5dd266fcae00707e67a2545ef34f9a29354585f93dac906749 Labels:map[] ParentId: RepoDigests:[busybox@sha256:a59906e33509d14c036c8678d687bd4eec81ed7c4b8ce907b888c607f6a1e0e6] RepoTags:[busybox:latest] SharedSize:0 Size:1092588]]",
            Containers = "[map[Command:top Created:1472592424 HostConfig:map[NetworkMode:default] Id:e575172ed11dc01bfce087fb27bee502db149e1a0fad7c296ad300bbff178148 Image:busybox ImageID:sha256:2b8fd9751c4c0f5dd266fcae00707e67a2545ef34f9a29354585f93dac906749 Labels:map[] Mounts:[] Names:[/top] NetworkSettings:map[Networks:map[bridge:map[EndpointID:8ed5115aeaad9abb174f68dcf135b49f11daf597678315231a32ca28441dec6a Gateway:172.18.0.1 GlobalIPv6Address: GlobalIPv6PrefixLen:0 IPAddress:172.18.0.2 IPPrefixLen:16 IPv6Gateway: MacAddress:02:42:ac:12:00:02 NetworkID:d687bc59335f0e5c9ee8193e5612e8aee000c8c62ea170cfb99c098f95899d92]]] Ports:[] SizeRootFs:1092588 State:exited Status:Exited (0) 56 minutes ago]]",
            Volumes = "[map[Driver:local Mountpoint:/var/lib/docker/volumes/my-volume/_data Name:my-volume Scope:local UsageData:map[RefCount:2 Size:10920104]]]",
            BuildCache = "[map[CreatedAt:2021-06-28T13:31:01.474619385Z Description:pulled from docker.io/library/debian@sha256:234cb88d3020898631af0ccbbcca9a66ae7306ecd30c9720690858c1b007d2a0 ID:hw53o5aio51xtltp5xjp8v7fx InUse:false LastUsedAt:2021-07-07T22:02:32.738075951Z Parents:[] Shared:true Size:0 Type:regular UsageCount:26] map[CreatedAt:2021-06-28T13:31:03.002625487Z Description:mount / from exec /bin/sh -c echo 'Binary::apt::APT::Keep-Downloaded-Packages \"true\";' > /etc/apt/apt.conf.d/keep-cache ID:ndlpt0hhvkqcdfkputsk4cq9c InUse:false LastUsedAt:2021-07-07T22:02:32.773909517Z Parents:[ndlpt0hhvkqcdfkputsk4cq9c] Shared:true Size:51 Type:regular UsageCount:26]]"
          },
          properties = {
            Containers = array([components.schemas.ContainerSummary]),
            Volumes = array([components.schemas.Volume]),
            BuildCache = array([components.schemas.BuildCache]),
            LayersSize = integer(format("int64")),
            Images = array([components.schemas.ImageSummary])
          }
        }
      }
      content "text/plain" {
        schema = {
          title = "SystemDataUsageResponse",
          type = "object",
          example = {
            BuildCache = "[map[CreatedAt:2021-06-28T13:31:01.474619385Z Description:pulled from docker.io/library/debian@sha256:234cb88d3020898631af0ccbbcca9a66ae7306ecd30c9720690858c1b007d2a0 ID:hw53o5aio51xtltp5xjp8v7fx InUse:false LastUsedAt:2021-07-07T22:02:32.738075951Z Parents:[] Shared:true Size:0 Type:regular UsageCount:26] map[CreatedAt:2021-06-28T13:31:03.002625487Z Description:mount / from exec /bin/sh -c echo 'Binary::apt::APT::Keep-Downloaded-Packages \"true\";' > /etc/apt/apt.conf.d/keep-cache ID:ndlpt0hhvkqcdfkputsk4cq9c InUse:false LastUsedAt:2021-07-07T22:02:32.773909517Z Parents:[ndlpt0hhvkqcdfkputsk4cq9c] Shared:true Size:51 Type:regular UsageCount:26]]",
            LayersSize = "1092588",
            Images = "[map[Containers:1 Created:1466724217 Id:sha256:2b8fd9751c4c0f5dd266fcae00707e67a2545ef34f9a29354585f93dac906749 Labels:map[] ParentId: RepoDigests:[busybox@sha256:a59906e33509d14c036c8678d687bd4eec81ed7c4b8ce907b888c607f6a1e0e6] RepoTags:[busybox:latest] SharedSize:0 Size:1092588]]",
            Containers = "[map[Command:top Created:1472592424 HostConfig:map[NetworkMode:default] Id:e575172ed11dc01bfce087fb27bee502db149e1a0fad7c296ad300bbff178148 Image:busybox ImageID:sha256:2b8fd9751c4c0f5dd266fcae00707e67a2545ef34f9a29354585f93dac906749 Labels:map[] Mounts:[] Names:[/top] NetworkSettings:map[Networks:map[bridge:map[EndpointID:8ed5115aeaad9abb174f68dcf135b49f11daf597678315231a32ca28441dec6a Gateway:172.18.0.1 GlobalIPv6Address: GlobalIPv6PrefixLen:0 IPAddress:172.18.0.2 IPPrefixLen:16 IPv6Gateway: MacAddress:02:42:ac:12:00:02 NetworkID:d687bc59335f0e5c9ee8193e5612e8aee000c8c62ea170cfb99c098f95899d92]]] Ports:[] SizeRootFs:1092588 State:exited Status:Exited (0) 56 minutes ago]]",
            Volumes = "[map[Driver:local Mountpoint:/var/lib/docker/volumes/my-volume/_data Name:my-volume Scope:local UsageData:map[RefCount:2 Size:10920104]]]"
          },
          properties = {
            LayersSize = integer(format("int64")),
            Images = array([components.schemas.ImageSummary]),
            Containers = array([components.schemas.ContainerSummary]),
            Volumes = array([components.schemas.Volume]),
            BuildCache = array([components.schemas.BuildCache])
          }
        }
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/networks/prune" "post" {
    summary = "Delete unused networks"
    operationId = "NetworkPrune"
    tags = ["Network"]
    parameters "filters" {
      in = "query"
      description = "Filters to process on the prune list, encoded as JSON (a `map[string][]string`).\\n\\nAvailable filters:\\n- `until=<timestamp>` Prune networks created before this timestamp. The `<timestamp>` can be Unix timestamps, date formatted timestamps, or Go duration strings (e.g. `10m`, `1h30m`) computed relative to the daemon machine’s time.\\n- `label` (`label=<key>`, `label=<key>=<value>`, `label!=<key>`, or `label!=<key>=<value>`) Prune networks with (or without, in case `label!=...` is used) the specified labels."
      schema = string()
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        schema = {
          title = "NetworkPruneResponse",
          type = "object",
          properties = {
            NetworksDeleted = array(description("Networks that were deleted"), [string()])
          }
        }
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/tasks/{id}/logs" "get" {
    summary = "Get task logs"
    description = "Get `stdout` and `stderr` logs from a task.\\nSee also [`/containers/{id}/logs`](#operation/ContainerLogs).\\n\\n**Note**: This endpoint works only for services with the `local`,\\n`json-file` or `journald` logging drivers."
    operationId = "TaskLogs"
    tags = ["Task"]
    parameters "id" {
      required = true
      in = "path"
      description = "ID of the task"
      schema = string()
    }
    parameters "details" {
      description = "Show task context and extra details provided to logs."
      schema = boolean(default(false))
      in = "query"
    }
    parameters "follow" {
      in = "query"
      description = "Keep connection after returning logs."
      schema = boolean(default(false))
    }
    parameters "stdout" {
      in = "query"
      description = "Return logs from `stdout`"
      schema = boolean(default(false))
    }
    parameters "stderr" {
      schema = boolean(default(false))
      in = "query"
      description = "Return logs from `stderr`"
    }
    parameters "since" {
      in = "query"
      description = "Only return logs since this time, as a UNIX timestamp"
      schema = integer(default(0))
    }
    parameters "timestamps" {
      in = "query"
      description = "Add timestamps to every log line"
      schema = boolean(default(false))
    }
    parameters "tail" {
      in = "query"
      description = "Only return this number of log lines from the end of the logs.\\nSpecify as an integer or `all` to output all log lines."
      schema = string(default("all"))
    }
    responses "200" {
      description = "logs returned as a stream in response body"
      content "application/vnd.docker.multiplexed-stream" {
        schema = string(format("binary"))
      }
      content "application/vnd.docker.raw-stream" {
        schema = string(format("binary"))
      }
    }
    responses "404" {
      description = "no such task"
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        example = "message: 'No such task: c2ada9df5af8'"
      }
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/exec/{id}/resize" "post" {
    tags = ["Exec"]
    summary = "Resize an exec instance"
    description = "Resize the TTY session used by an exec instance. This endpoint only works\\nif `tty` was specified as part of creating and starting the exec instance."
    operationId = "ExecResize"
    parameters "id" {
      in = "path"
      description = "Exec instance ID"
      schema = string()
      required = true
    }
    parameters "h" {
      description = "Height of the TTY session in characters"
      schema = integer()
      in = "query"
    }
    parameters "w" {
      schema = integer()
      in = "query"
      description = "Width of the TTY session in characters"
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "No error"
    }
    responses "400" {
      description = "bad parameter"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "No such exec instance"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/plugins/{name}" "delete" {
    summary = "Remove a plugin"
    operationId = "PluginDelete"
    tags = ["Plugin"]
    parameters "name" {
      required = true
      in = "path"
      description = "The name of the plugin. The `:latest` tag is optional, and is the\\ndefault if omitted."
      schema = string()
    }
    parameters "force" {
      in = "query"
      description = "Disable the plugin before removing. This may result in issues if the\\nplugin is in use by a container."
      schema = boolean(default(false))
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.Plugin
      }
      content "text/plain" {
        schema = components.schemas.Plugin
      }
    }
    responses "404" {
      description = "plugin is not installed"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/plugins/{name}/set" "post" {
    summary = "Configure a plugin"
    operationId = "PluginSet"
    tags = ["Plugin"]
    parameters "name" {
      required = true
      in = "path"
      description = "The name of the plugin. The `:latest` tag is optional, and is the\\ndefault if omitted."
      schema = string()
    }
    requestBody {
      content "application/json" {
        schema = array(example(["DEBUG=1"]), [string()])
      }
    }
    responses "404" {
      description = "Plugin not installed"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "204" {
      description = "No error"
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/auth" "post" {
    summary = "Check auth configuration"
    description = "Validate credentials for a registry and, if available, get an identity\\ntoken for accessing the registry without password."
    operationId = "SystemAuth"
    tags = ["System"]
    requestBody {
      description = "Authentication to check"
      content "application/json" {
        schema = components.schemas.AuthConfig
      }
    }
    responses "200" {
      description = "An identity token was generated successfully."
      content "application/json" {
        example = "Status: Login Succeeded\\nIdentityToken: 9cbaf023786cd7..."
        schema = {
          title = "SystemAuthResponse",
          type = "object",
          required = ["Status"],
          properties = {
            Status = string(description("The status of the authentication")),
            IdentityToken = string(description("An opaque token used to authenticate a user after a successful login"))
          }
        }
      }
    }
    responses "204" {
      description = "No error"
    }
    responses "401" {
      description = "Auth error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "authConfig"
    }
  }
  paths "/plugins/create" "post" {
    summary = "Create a plugin"
    operationId = "PluginCreate"
    tags = ["Plugin"]
    parameters "name" {
      in = "query"
      description = "The name of the plugin. The `:latest` tag is optional, and is the\\ndefault if omitted."
      schema = string()
      required = true
    }
    requestBody {
      description = "Path to tar containing plugin rootfs and manifest"
      content "application/x-tar" {
        schema = string(format("binary"))
      }
    }
    responses "204" {
      description = "no error"
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "tarContext"
    }
  }
  paths "/plugins/{name}/push" "post" {
    tags = ["Plugin"]
    summary = "Push a plugin"
    description = "Push a plugin to the registry."
    operationId = "PluginPush"
    parameters "name" {
      description = "The name of the plugin. The `:latest` tag is optional, and is the\\ndefault if omitted."
      schema = string()
      required = true
      in = "path"
    }
    responses "404" {
      description = "plugin not installed"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
    }
  }
  paths "/containers/{id}/start" "post" {
    operationId = "ContainerStart"
    summary = "Start a container"
    tags = ["Container"]
    parameters "id" {
      description = "ID or name of the container"
      schema = string()
      required = true
      in = "path"
    }
    parameters "detachKeys" {
      description = "Override the key sequence for detaching a container. Format is a\\nsingle character `[a-Z]` or `ctrl-<value>` where `<value>` is one\\nof: `a-z`, `@`, `^`, `[`, `,` or `_`."
      in = "query"
      schema = string()
    }
    responses "304" {
      description = "container already started"
    }
    responses "404" {
      description = "no such container"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "204" {
      description = "no error"
    }
  }
  paths "/containers/{id}" "delete" {
    tags = ["Container"]
    summary = "Remove a container"
    operationId = "ContainerDelete"
    parameters "id" {
      description = "ID or name of the container"
      schema = string()
      required = true
      in = "path"
    }
    parameters "v" {
      in = "query"
      description = "Remove anonymous volumes associated with the container."
      schema = boolean(default(false))
    }
    parameters "force" {
      in = "query"
      description = "If the container is running, kill it before removing it."
      schema = boolean(default(false))
    }
    parameters "link" {
      in = "query"
      description = "Remove the specified link associated with the container."
      schema = boolean(default(false))
    }
    responses "204" {
      description = "no error"
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "no such container"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "409" {
      description = "conflict"
      content "application/json" {
        example = "message: |\\n    You cannot remove a running container: c2ada9df5af8. Stop the\\n    container before attempting removal or force remove"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/tasks" "get" {
    summary = "List tasks"
    operationId = "TaskList"
    tags = ["Task"]
    parameters "filters" {
      schema = string()
      description = "A JSON encoded value of the filters (a `map[string][]string`) to\\nprocess on the tasks list.\\n\\nAvailable filters:\\n\\n- `desired-state=(running | shutdown | accepted)`\\n- `id=<task id>`\\n- `label=key` or `label=\"key=value\"`\\n- `name=<task name>`\\n- `node=<node id or name>`\\n- `service=<service name>`"
      in = "query"
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = array(example(["map[CreatedAt:2016-06-07T21:07:31.171892745Z DesiredState:running ID:0kzzo1i0y4jz6027t0k7aezc7 NetworksAttachments:[map[Addresses:[10.255.0.10/16] Network:map[CreatedAt:2016-06-07T20:31:11.912919752Z DriverState:map[Name:overlay Options:map[com.docker.network.driver.overlay.vxlanid_list:256]] ID:4qvuz4ko70xaltuqbt8956gd1 IPAMOptions:map[Configs:[map[Gateway:10.255.0.1 Subnet:10.255.0.0/16]] Driver:map[Name:default]] Spec:map[DriverConfiguration:map[] IPAMOptions:map[Configs:[map[Gateway:10.255.0.1 Subnet:10.255.0.0/16]] Driver:map[]] Labels:map[com.docker.swarm.internal:true] Name:ingress] UpdatedAt:2016-06-07T21:07:29.955277358Z Version:map[Index:18]]]] NodeID:60gvrl6tm78dmak4yl7srz94v ServiceID:9mnpnzenvg8p8tdbtq4wvbkcz Slot:1 Spec:map[ContainerSpec:map[Image:redis] Placement:map[] Resources:map[Limits:map[] Reservations:map[]] RestartPolicy:map[Condition:any MaxAttempts:0]] Status:map[ContainerStatus:map[ContainerID:e5d62702a1b48d01c3e02ca1e0212a250801fa8d67caca0b6f35919ebc12f035 PID:677] Message:started State:running Timestamp:2016-06-07T21:07:31.290032978Z] UpdatedAt:2016-06-07T21:07:31.376370513Z Version:map[Index:71]]", "map[CreatedAt:2016-06-07T21:07:30.019104782Z DesiredState:shutdown ID:1yljwbmlr8er2waf8orvqpwms Name:hopeful_cori NetworksAttachments:[map[Addresses:[10.255.0.5/16] Network:map[CreatedAt:2016-06-07T20:31:11.912919752Z DriverState:map[Name:overlay Options:map[com.docker.network.driver.overlay.vxlanid_list:256]] ID:4qvuz4ko70xaltuqbt8956gd1 IPAMOptions:map[Configs:[map[Gateway:10.255.0.1 Subnet:10.255.0.0/16]] Driver:map[Name:default]] Spec:map[DriverConfiguration:map[] IPAMOptions:map[Configs:[map[Gateway:10.255.0.1 Subnet:10.255.0.0/16]] Driver:map[]] Labels:map[com.docker.swarm.internal:true] Name:ingress] UpdatedAt:2016-06-07T21:07:29.955277358Z Version:map[Index:18]]]] NodeID:60gvrl6tm78dmak4yl7srz94v ServiceID:9mnpnzenvg8p8tdbtq4wvbkcz Slot:1 Spec:map[ContainerSpec:map[Image:redis] Placement:map[] Resources:map[Limits:map[] Reservations:map[]] RestartPolicy:map[Condition:any MaxAttempts:0]] Status:map[ContainerStatus:map[ContainerID:1cf8d63d18e79668b0004a4be4c6ee58cddfad2dae29506d8781581d0688a213] Message:shutdown State:shutdown Timestamp:2016-06-07T21:07:30.202183143Z] UpdatedAt:2016-06-07T21:07:30.231958098Z Version:map[Index:30]]"]), [components.schemas.Task])
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/export" "get" {
    operationId = "ContainerExport"
    summary = "Export a container"
    description = "Export the contents of a container as a tarball."
    tags = ["Container"]
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the container"
      schema = string()
    }
    responses "200" {
      description = "no error"
    }
    responses "404" {
      description = "no such container"
      content "application/octet-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
      }
    }
    responses "500" {
      description = "server error"
      content "application/octet-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/resize" "post" {
    summary = "Resize a container TTY"
    description = "Resize the TTY for a container."
    operationId = "ContainerResize"
    tags = ["Container"]
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the container"
      schema = string()
    }
    parameters "h" {
      in = "query"
      description = "Height of the TTY session in characters"
      schema = integer()
    }
    parameters "w" {
      in = "query"
      description = "Width of the TTY session in characters"
      schema = integer()
    }
    responses "200" {
      description = "no error"
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "cannot resize container"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/networks/{id}/connect" "post" {
    operationId = "NetworkConnect"
    summary = "Connect a container to a network"
    description = "The network must be either a local-scoped network or a swarm-scoped network with the `attachable` option set. A network cannot be re-attached to a running container"
    tags = ["Network"]
    parameters "id" {
      description = "Network ID or name"
      in = "path"
      schema = string()
      required = true
    }
    requestBody {
      required = true
      content "application/json" {
        schema = {
          title = "NetworkConnectRequest",
          type = "object",
          example = {
            Container = "3613f73ba0e4",
            EndpointConfig = "map[IPAMConfig:map[IPv4Address:172.24.56.89 IPv6Address:2001:db8::5689] MacAddress:02:42:ac:12:05:02]"
          },
          properties = {
            Container = string(description("The ID or name of the container to connect to the network.")),
            EndpointConfig = components.schemas.EndpointSettings
          }
        }
      }
    }
    responses "403" {
      description = "Operation forbidden"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "Network or container not found"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "No error"
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "container"
    }
  }
  paths "/services" "get" {
    summary = "List services"
    operationId = "ServiceList"
    tags = ["Service"]
    parameters "filters" {
      description = "A JSON encoded value of the filters (a `map[string][]string`) to\\nprocess on the services list.\\n\\nAvailable filters:\\n\\n- `id=<service id>`\\n- `label=<service label>`\\n- `mode=[\"replicated\"|\"global\"]`\\n- `name=<service name>`"
      schema = string()
      in = "query"
    }
    parameters "status" {
      in = "query"
      description = "Include service status, with count of running and desired tasks."
      schema = boolean()
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = array([components.schemas.Service])
      }
      content "text/plain" {
        schema = array([components.schemas.Service])
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/pause" "post" {
    operationId = "ContainerPause"
    tags = ["Container"]
    summary = "Pause a container"
    description = "Use the freezer cgroup to suspend all processes in a container.\\n\\nTraditionally, when suspending a process the `SIGSTOP` signal is used,\\nwhich is observable by the process being suspended. With the freezer\\ncgroup the process is unaware, and unable to capture, that it is being\\nsuspended, and subsequently resumed."
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the container"
      schema = string()
    }
    responses "204" {
      description = "no error"
    }
    responses "404" {
      description = "no such container"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/configs/{id}/update" "post" {
    operationId = "ConfigUpdate"
    summary = "Update a Config"
    tags = ["Config"]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID or name of the config"
      schema = string()
    }
    parameters "version" {
      required = true
      in = "query"
      description = "The version number of the config object being updated. This is\\nrequired to avoid conflicting writes."
      schema = integer(format("int64"))
    }
    requestBody {
      description = "The spec of the config to update. Currently, only the Labels field\\ncan be updated. All other fields must remain unchanged from the\\n[ConfigInspect endpoint](#operation/ConfigInspect) response values."
      content "application/json" {
        schema = components.schemas.ConfigSpec
      }
      content "text/plain" {
        schema = components.schemas.ConfigSpec
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "no such config"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/containers/{id}/update" "post" {
    operationId = "ContainerUpdate"
    tags = ["Container"]
    summary = "Update a container"
    description = "Change various configuration options of a container without having to\\nrecreate it."
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the container"
      schema = string()
    }
    requestBody {
      required = true
      content "application/json" {
        schema = allOf(components.schemas.Resources, object({
          RestartPolicy = components.schemas.RestartPolicy
        }))
      }
    }
    responses "200" {
      description = "The container has been updated."
      content "application/json" {
        schema = {
          title = "ContainerUpdateResponse",
          type = "object",
          description = "OK response to ContainerUpdate operation",
          properties = {
            Warnings = array([string()])
          }
        }
      }
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "update"
    }
  }
  paths "/exec/{id}/start" "post" {
    summary = "Start an exec instance"
    description = "Starts a previously set up exec instance. If detach is true, this endpoint\\nreturns immediately after starting the command. Otherwise, it sets up an\\ninteractive session with the command."
    operationId = "ExecStart"
    tags = ["Exec"]
    parameters "id" {
      required = true
      in = "path"
      description = "Exec instance ID"
      schema = string()
    }
    requestBody {
      content "application/json" {
        schema = {
          example = {
            Detach = "false",
            Tty = "true",
            ConsoleSize = "[80 64]"
          },
          title = "ExecStartConfig",
          type = "object",
          properties = {
            Detach = boolean(description("Detach from the command.")),
            Tty = boolean(description("Allocate a pseudo-TTY.")),
            ConsoleSize = {
              nullable = true,
              type = "array",
              description = "Initial console size, as an `[height, width]` array.",
              minItems = 2,
              maxItems = 2,
              items = [integer()]
            }
          }
        }
      }
    }
    responses "409" {
      description = "Container is stopped or paused"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "No error"
    }
    responses "404" {
      description = "No such exec instance"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
      content "application/vnd.docker.multiplexed-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "execStartConfig"
    }
  }
  paths "/distribution/{name}/json" "get" {
    summary = "Get image information from the registry"
    description = "Return image digest and platform information by contacting the registry."
    operationId = "DistributionInspect"
    tags = ["Distribution"]
    parameters "name" {
      schema = string()
      required = true
      in = "path"
      description = "Image name or id"
    }
    responses "200" {
      description = "descriptor and platform information"
      content "application/json" {
        schema = components.schemas.DistributionInspect
      }
    }
    responses "401" {
      description = "Failed authentication or no image found"
      content "application/json" {
        example = "message: 'No such image: someimage (tag: latest)'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/images/{name}" "delete" {
    summary = "Remove an image"
    description = "Remove an image, along with any untagged parent images that were\\nreferenced by that image.\\n\\nImages can't be removed if they have descendant images, are being\\nused by a running container or are being used by a build."
    operationId = "ImageDelete"
    tags = ["Image"]
    parameters "name" {
      in = "path"
      description = "Image name or ID"
      schema = string()
      required = true
    }
    parameters "force" {
      in = "query"
      description = "Remove the image even if it is being used by stopped containers or has other tags"
      schema = boolean(default(false))
    }
    parameters "noprune" {
      in = "query"
      description = "Do not delete untagged parent images"
      schema = boolean(default(false))
    }
    responses "409" {
      description = "Conflict"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "The image was deleted successfully"
      content "application/json" {
        schema = array([components.schemas.ImageDeleteResponseItem])
        example = "- Untagged: 3e2f21a89f\\n- Deleted: 3e2f21a89f\\n- Deleted: 53b4f83ac9"
      }
    }
    responses "404" {
      description = "No such image"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/images/{name}/get" "get" {
    summary = "Export an image"
    description = "Get a tarball containing all images and metadata for a repository.\\n\\nIf `name` is a specific name and tag (e.g. `ubuntu:latest`), then only that image (and its parents) are returned. If `name` is an image ID, similarly only that image (and its parents) are returned, but with the exclusion of the `repositories` file in the tarball, as there were no image names referenced.\\n\\n### Image tarball format\\n\\nAn image tarball contains one directory per image layer (named using its long ID), each containing these files:\\n\\n- `VERSION`: currently `1.0` - the file format version\\n- `json`: detailed layer information, similar to `docker inspect layer_id`\\n- `layer.tar`: A tarfile containing the filesystem changes in this layer\\n\\nThe `layer.tar` file contains `aufs` style `.wh..wh.aufs` files and directories for storing attribute changes and deletions.\\n\\nIf the tarball defines a repository, the tarball should also include a `repositories` file at the root that contains a list of repository and tag names mapped to layer IDs.\\n\\n```json\\n{\\n  \"hello-world\": {\\n    \"latest\": \"565a9d68a73f6706862bfe8409a7f659776d4d60a8d096eb4a3cbce6999cc2a1\"\\n  }\\n}\\n```"
    operationId = "ImageGet"
    tags = ["Image"]
    parameters "name" {
      required = true
      in = "path"
      description = "Image name or ID"
      schema = string()
    }
    responses "200" {
      description = "no error"
      content "application/x-tar" {
        schema = string(format("binary"))
      }
    }
    responses "500" {
      description = "server error"
      content "application/x-tar" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/tasks/{id}" "get" {
    operationId = "TaskInspect"
    tags = ["Task"]
    summary = "Inspect a task"
    parameters "id" {
      schema = string()
      required = true
      in = "path"
      description = "ID of the task"
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.Task
      }
    }
    responses "404" {
      description = "no such task"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/json" "get" {
    tags = ["Container"]
    summary = "List containers"
    description = "Returns a list of containers. For details on the format, see the\\n[inspect endpoint](#operation/ContainerInspect).\\n\\nNote that it uses a different, smaller representation of a container\\nthan inspecting a single container. For example, the list of linked\\ncontainers is not propagated ."
    operationId = "ContainerList"
    parameters "all" {
      in = "query"
      description = "Return all containers. By default, only running containers are shown."
      schema = boolean(default(false))
    }
    parameters "limit" {
      in = "query"
      description = "Return this number of most recently created containers, including\\nnon-running ones."
      schema = integer()
    }
    parameters "size" {
      in = "query"
      description = "Return the size of container as fields `SizeRw` and `SizeRootFs`."
      schema = boolean(default(false))
    }
    parameters "filters" {
      in = "query"
      description = "Filters to process on the container list, encoded as JSON (a\\n`map[string][]string`). For example, `{\"status\": [\"paused\"]}` will\\nonly return paused containers.\\n\\nAvailable filters:\\n\\n- `ancestor`=(`<image-name>[:<tag>]`, `<image id>`, or `<image@digest>`)\\n- `before`=(`<container id>` or `<container name>`)\\n- `expose`=(`<port>[/<proto>]`|`<startport-endport>/[<proto>]`)\\n- `exited=<int>` containers with exit code of `<int>`\\n- `health`=(`starting`|`healthy`|`unhealthy`|`none`)\\n- `id=<ID>` a container's ID\\n- `isolation=`(`default`|`process`|`hyperv`) (Windows daemon only)\\n- `is-task=`(`true`|`false`)\\n- `label=key` or `label=\"key=value\"` of a container label\\n- `name=<name>` a container's name\\n- `network`=(`<network id>` or `<network name>`)\\n- `publish`=(`<port>[/<proto>]`|`<startport-endport>/[<proto>]`)\\n- `since`=(`<container id>` or `<container name>`)\\n- `status=`(`created`|`restarting`|`running`|`removing`|`paused`|`exited`|`dead`)\\n- `volume`=(`<volume name>` or `<mount point destination>`)"
      schema = string()
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = array([components.schemas.ContainerSummary])
        example = "- Id: 8dfafdbc3a40\\n  Names:\\n    - /boring_feynman\\n  Image: ubuntu:latest\\n  ImageID: d74508fb6632491cea586a1fd7d748dfc5274cd6fdfedee309ecdcbc2bf5cb82\\n  Command: echo 1\\n  Created: 1367854155\\n  State: Exited\\n  Status: Exit 0\\n  Ports:\\n    - PrivatePort: 2222\\n      PublicPort: 3333\\n      Type: tcp\\n  Labels:\\n    com.example.vendor: Acme\\n    com.example.license: GPL\\n    com.example.version: \"1.0\"\\n  SizeRw: 12288\\n  SizeRootFs: 0\\n  HostConfig:\\n    NetworkMode: default\\n    Annotations:\\n        io.kubernetes.docker.type: container\\n  NetworkSettings:\\n    Networks:\\n        bridge:\\n            NetworkID: 7ea29fc1412292a2d7bba362f9253545fecdfa8ce9a6e37dd10ba8bee7129812\\n            EndpointID: 2cdc4edb1ded3631c81f57966563e5c8525b81121bb3706a9a9a3ae102711f3f\\n            Gateway: 172.17.0.1\\n            IPAddress: 172.17.0.2\\n            IPPrefixLen: 16\\n            IPv6Gateway: \"\"\\n            GlobalIPv6Address: \"\"\\n            GlobalIPv6PrefixLen: 0\\n            MacAddress: 02:42:ac:11:00:02\\n  Mounts:\\n    - Name: fac362...80535\\n      Source: /data\\n      Destination: /data\\n      Driver: local\\n      Mode: ro,Z\\n      RW: false\\n      Propagation: \"\"\\n- Id: 9cd87474be90\\n  Names:\\n    - /coolName\\n  Image: ubuntu:latest\\n  ImageID: d74508fb6632491cea586a1fd7d748dfc5274cd6fdfedee309ecdcbc2bf5cb82\\n  Command: echo 222222\\n  Created: 1367854155\\n  State: Exited\\n  Status: Exit 0\\n  Ports: []\\n  Labels: {}\\n  SizeRw: 12288\\n  SizeRootFs: 0\\n  HostConfig:\\n    NetworkMode: default\\n    Annotations:\\n        io.kubernetes.docker.type: container\\n        io.kubernetes.sandbox.id: 3befe639bed0fd6afdd65fd1fa84506756f59360ec4adc270b0fdac9be22b4d3\\n  NetworkSettings:\\n    Networks:\\n        bridge:\\n            NetworkID: 7ea29fc1412292a2d7bba362f9253545fecdfa8ce9a6e37dd10ba8bee7129812\\n            EndpointID: 88eaed7b37b38c2a3f0c4bc796494fdf51b270c2d22656412a2ca5d559a64d7a\\n            Gateway: 172.17.0.1\\n            IPAddress: 172.17.0.8\\n            IPPrefixLen: 16\\n            IPv6Gateway: \"\"\\n            GlobalIPv6Address: \"\"\\n            GlobalIPv6PrefixLen: 0\\n            MacAddress: 02:42:ac:11:00:08\\n  Mounts: []\\n- Id: 3176a2479c92\\n  Names:\\n    - /sleepy_dog\\n  Image: ubuntu:latest\\n  ImageID: d74508fb6632491cea586a1fd7d748dfc5274cd6fdfedee309ecdcbc2bf5cb82\\n  Command: echo 3333333333333333\\n  Created: 1367854154\\n  State: Exited\\n  Status: Exit 0\\n  Ports: []\\n  Labels: {}\\n  SizeRw: 12288\\n  SizeRootFs: 0\\n  HostConfig:\\n    NetworkMode: default\\n    Annotations:\\n        io.kubernetes.image.id: d74508fb6632491cea586a1fd7d748dfc5274cd6fdfedee309ecdcbc2bf5cb82\\n        io.kubernetes.image.name: ubuntu:latest\\n  NetworkSettings:\\n    Networks:\\n        bridge:\\n            NetworkID: 7ea29fc1412292a2d7bba362f9253545fecdfa8ce9a6e37dd10ba8bee7129812\\n            EndpointID: 8b27c041c30326d59cd6e6f510d4f8d1d570a228466f956edf7815508f78e30d\\n            Gateway: 172.17.0.1\\n            IPAddress: 172.17.0.6\\n            IPPrefixLen: 16\\n            IPv6Gateway: \"\"\\n            GlobalIPv6Address: \"\"\\n            GlobalIPv6PrefixLen: 0\\n            MacAddress: 02:42:ac:11:00:06\\n  Mounts: []\\n- Id: 4cb07b47f9fb\\n  Names:\\n    - /running_cat\\n  Image: ubuntu:latest\\n  ImageID: d74508fb6632491cea586a1fd7d748dfc5274cd6fdfedee309ecdcbc2bf5cb82\\n  Command: echo 444444444444444444444444444444444\\n  Created: 1367854152\\n  State: Exited\\n  Status: Exit 0\\n  Ports: []\\n  Labels: {}\\n  SizeRw: 12288\\n  SizeRootFs: 0\\n  HostConfig:\\n    NetworkMode: default\\n    Annotations:\\n        io.kubernetes.config.source: api\\n  NetworkSettings:\\n    Networks:\\n        bridge:\\n            NetworkID: 7ea29fc1412292a2d7bba362f9253545fecdfa8ce9a6e37dd10ba8bee7129812\\n            EndpointID: d91c7b2f0644403d7ef3095985ea0e2370325cd2332ff3a3225c4247328e66e9\\n            Gateway: 172.17.0.1\\n            IPAddress: 172.17.0.5\\n            IPPrefixLen: 16\\n            IPv6Gateway: \"\"\\n            GlobalIPv6Address: \"\"\\n            GlobalIPv6PrefixLen: 0\\n            MacAddress: 02:42:ac:11:00:05\\n  Mounts: []"
      }
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/_ping" "get" {
    summary = "Ping"
    description = "This is a dummy endpoint you can use to test if the server is accessible."
    operationId = "SystemPing"
    tags = ["System"]
    responses "200" {
      description = "no error"
      content "text/plain" {
        schema = string(example("OK"))
      }
      headers "Docker-Experimental" {
        description = "If the server is running with experimental mode enabled"
        schema = boolean()
      }
      headers "Cache-Control" {
        schema = string(default("no-cache, no-store, must-revalidate"))
      }
      headers "Pragma" {
        schema = string(default("no-cache"))
      }
      headers "API-Version" {
        description = "Max API Version the server supports"
        schema = string()
      }
      headers "Builder-Version" {
        description = "Default version of docker image builder\\n\\nThe default on Linux is version \"2\" (BuildKit), but the daemon\\ncan be configured to recommend version \"1\" (classic Builder).\\nWindows does not yet support BuildKit for native Windows images,\\nand uses \"1\" (classic builder) as a default.\\n\\nThis value is a recommendation as advertised by the daemon, and\\nit is up to the client to choose which builder to use."
        schema = string(default("2"))
      }
      headers "Swarm" {
        description = "Contains information about Swarm status of the daemon,\\nand if the daemon is acting as a manager or worker node."
        schema = string(default("inactive"), enum("inactive", "pending", "error", "locked", "active/worker", "active/manager"))
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      headers "Cache-Control" {
        schema = string(default("no-cache, no-store, must-revalidate"))
      }
      headers "Pragma" {
        schema = string(default("no-cache"))
      }
    }
  }
  paths "/_ping" "head" {
    description = "This is a dummy endpoint you can use to test if the server is accessible."
    operationId = "SystemPingHead"
    tags = ["System"]
    summary = "Ping"
    responses "200" {
      description = "no error"
      content "text/plain" {
        schema = string(example("(empty)"))
      }
      headers "API-Version" {
        description = "Max API Version the server supports"
        schema = string()
      }
      headers "Builder-Version" {
        description = "Default version of docker image builder"
        schema = string()
      }
      headers "Swarm" {
        description = "Contains information about Swarm status of the daemon,\\nand if the daemon is acting as a manager or worker node."
        schema = string(default("inactive"), enum("inactive", "pending", "error", "locked", "active/worker", "active/manager"))
      }
      headers "Docker-Experimental" {
        description = "If the server is running with experimental mode enabled"
        schema = boolean()
      }
      headers "Cache-Control" {
        schema = string(default("no-cache, no-store, must-revalidate"))
      }
      headers "Pragma" {
        schema = string(default("no-cache"))
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/networks/{id}/disconnect" "post" {
    summary = "Disconnect a container from a network"
    operationId = "NetworkDisconnect"
    tags = ["Network"]
    parameters "id" {
      required = true
      in = "path"
      description = "Network ID or name"
      schema = string()
    }
    requestBody {
      required = true
      content "application/json" {
        schema = {
          title = "NetworkDisconnectRequest",
          type = "object",
          properties = {
            Container = string(description("The ID or name of the container to disconnect from the network.")),
            Force = boolean(description("Force the container to disconnect from the network."))
          }
        }
      }
    }
    responses "200" {
      description = "No error"
    }
    responses "403" {
      description = "Operation not supported for swarm scoped networks"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "Network or container not found"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "container"
    }
  }
  paths "/networks/create" "post" {
    operationId = "NetworkCreate"
    summary = "Create a network"
    tags = ["Network"]
    requestBody {
      description = "Network configuration"
      required = true
      content "application/json" {
        schema = {
          title = "NetworkCreateRequest",
          type = "object",
          required = ["Name"],
          properties = {
            Options = map(string(), description("Network specific options to be used by the drivers."), example({
              com.docker.network.bridge.host_binding_ipv4 = "0.0.0.0",
              com.docker.network.bridge.name = "docker0",
              com.docker.network.driver.mtu = "1500",
              com.docker.network.bridge.default_bridge = "true",
              com.docker.network.bridge.enable_icc = "true",
              com.docker.network.bridge.enable_ip_masquerade = "true"
            })),
            Labels = map(string(), description("User-defined key/value metadata."), example({
              com.example.some-label = "some-value",
              com.example.some-other-label = "some-other-value"
            })),
            Attachable = boolean(description("Globally scoped network is manually attachable by regular\\ncontainers from workers in swarm mode."), example(true)),
            Ingress = boolean(description("Ingress network is the network which provides the routing-mesh\\nin swarm mode."), example(false)),
            ConfigOnly = boolean(description("Creates a config-only network. Config-only networks are placeholder\\nnetworks for network configurations to be used by other networks.\\nConfig-only networks cannot be used directly to run containers\\nor services."), default(false), example(false)),
            Internal = boolean(description("Restrict external access to the network.")),
            IPAM = components.schemas.IPAM,
            EnableIPv6 = boolean(description("Enable IPv6 on the network."), example(true)),
            Driver = string(description("Name of the network driver plugin to use."), default("bridge"), example("bridge")),
            Scope = string(description("The level at which the network exists (e.g. `swarm` for cluster-wide\\nor `local` for machine level).")),
            ConfigFrom = components.schemas.ConfigReference,
            Name = string(description("The network's name."), example("my_network"))
          }
        }
      }
    }
    responses "201" {
      description = "Network created successfully"
      content "application/json" {
        schema = components.schemas.NetworkCreateResponse
      }
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "403" {
      description = "Forbidden operation. This happens when trying to create a network named after a pre-defined network,\\nor when trying to create an overlay network on a daemon which is not part of a Swarm cluster."
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "plugin not found"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "networkConfig"
    }
  }
  paths "/swarm/join" "post" {
    tags = ["Swarm"]
    summary = "Join an existing swarm"
    operationId = "SwarmJoin"
    requestBody {
      required = true
      content "application/json" {
        schema = {
          title = "SwarmJoinRequest",
          type = "object",
          example = {
            ListenAddr = "0.0.0.0:2377",
            AdvertiseAddr = "192.168.1.1:2377",
            RemoteAddrs = "[node1:2377]",
            JoinToken = "SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-7p73s1dx5in4tatdymyhg9hu2"
          },
          properties = {
            DataPathAddr = string(description("Address or interface to use for data path traffic (format:\\n`<ip|interface>`), for example,  `192.168.1.1`, or an interface,\\nlike `eth0`. If `DataPathAddr` is unspecified, the same address\\nas `AdvertiseAddr` is used.\\n\\nThe `DataPathAddr` specifies the address that global scope\\nnetwork drivers will publish towards other nodes in order to\\nreach the containers running on this node. Using this parameter\\nit is possible to separate the container data traffic from the\\nmanagement traffic of the cluster.")),
            RemoteAddrs = array(description("Addresses of manager nodes already participating in the swarm."), [string()]),
            JoinToken = string(description("Secret token for joining this swarm.")),
            ListenAddr = string(description("Listen address used for inter-manager communication if the node\\ngets promoted to manager, as well as determining the networking\\ninterface used for the VXLAN Tunnel Endpoint (VTEP).")),
            AdvertiseAddr = string(description("Externally reachable address advertised to other nodes. This\\ncan either be an address/port combination in the form\\n`192.168.1.1:4567`, or an interface followed by a port number,\\nlike `eth0:4567`. If the port number is omitted, the port\\nnumber from the listen address is used. If `AdvertiseAddr` is\\nnot specified, it will be automatically detected when possible."))
          }
        }
      }
      content "text/plain" {
        schema = {
          title = "SwarmJoinRequest",
          type = "object",
          example = {
            JoinToken = "SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-7p73s1dx5in4tatdymyhg9hu2",
            ListenAddr = "0.0.0.0:2377",
            AdvertiseAddr = "192.168.1.1:2377",
            RemoteAddrs = "[node1:2377]"
          },
          properties = {
            RemoteAddrs = array(description("Addresses of manager nodes already participating in the swarm."), [string()]),
            JoinToken = string(description("Secret token for joining this swarm.")),
            ListenAddr = string(description("Listen address used for inter-manager communication if the node\\ngets promoted to manager, as well as determining the networking\\ninterface used for the VXLAN Tunnel Endpoint (VTEP).")),
            AdvertiseAddr = string(description("Externally reachable address advertised to other nodes. This\\ncan either be an address/port combination in the form\\n`192.168.1.1:4567`, or an interface followed by a port number,\\nlike `eth0:4567`. If the port number is omitted, the port\\nnumber from the listen address is used. If `AdvertiseAddr` is\\nnot specified, it will be automatically detected when possible.")),
            DataPathAddr = string(description("Address or interface to use for data path traffic (format:\\n`<ip|interface>`), for example,  `192.168.1.1`, or an interface,\\nlike `eth0`. If `DataPathAddr` is unspecified, the same address\\nas `AdvertiseAddr` is used.\\n\\nThe `DataPathAddr` specifies the address that global scope\\nnetwork drivers will publish towards other nodes in order to\\nreach the containers running on this node. Using this parameter\\nit is possible to separate the container data traffic from the\\nmanagement traffic of the cluster."))
          }
        }
      }
    }
    responses "400" {
      description = "bad parameter"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is already part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/swarm/unlockkey" "get" {
    summary = "Get the unlock key"
    operationId = "SwarmUnlockkey"
    tags = ["Swarm"]
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = {
          title = "UnlockKeyResponse",
          type = "object",
          example = {
            UnlockKey = "SWMKEY-1-7c37Cc8654o6p38HnroywCi19pllOnGtbdZEgtKxZu8"
          },
          properties = {
            UnlockKey = string(description("The swarm's unlock key."))
          }
        }
      }
      content "text/plain" {
        schema = {
          title = "UnlockKeyResponse",
          type = "object",
          example = {
            UnlockKey = "SWMKEY-1-7c37Cc8654o6p38HnroywCi19pllOnGtbdZEgtKxZu8"
          },
          properties = {
            UnlockKey = string(description("The swarm's unlock key."))
          }
        }
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/services/create" "post" {
    operationId = "ServiceCreate"
    summary = "Create a service"
    tags = ["Service"]
    parameters "X-Registry-Auth" {
      in = "header"
      description = "A base64url-encoded auth configuration for pulling from private\\nregistries.\\n\\nRefer to the [authentication section](#section/Authentication) for\\ndetails."
      schema = string()
    }
    requestBody {
      required = true
      content "application/json" {
        schema = allOf(components.schemas.ServiceSpec, object(example({
          Name = "web",
          TaskTemplate = "map[ContainerSpec:map[DNSConfig:map[Nameservers:[8.8.8.8] Options:[timeout:3] Search:[example.org]] Hosts:[10.10.10.10 host1 ABCD:EF01:2345:6789:ABCD:EF01:2345:6789 host2] Image:nginx:alpine Mounts:[map[ReadOnly:true Source:web-data Target:/usr/share/nginx/html Type:volume VolumeOptions:map[DriverConfig:map[] Labels:map[com.example.something:something-value]]]] OomScoreAdj:0 Secrets:[map[File:map[GID:33 Mode:384 Name:www.example.org.key UID:33] SecretID:fpjqlhnwb19zds35k8wn80lq9 SecretName:example_org_domain_key]] User:33] LogDriver:map[Name:json-file Options:map[max-file:3 max-size:10M]] Placement:map[] Resources:map[Limits:map[MemoryBytes:104857600] Reservations:map[]] RestartPolicy:map[Condition:on-failure Delay:10000000000 MaxAttempts:10]]",
          Mode = "map[Replicated:map[Replicas:4]]",
          UpdateConfig = "map[Delay:1000000000 FailureAction:pause MaxFailureRatio:0.15 Monitor:15000000000 Parallelism:2]",
          RollbackConfig = "map[Delay:1000000000 FailureAction:pause MaxFailureRatio:0.15 Monitor:15000000000 Parallelism:1]",
          EndpointSpec = "map[Ports:[map[Protocol:tcp PublishedPort:8080 TargetPort:80]]]",
          Labels = "map[foo:bar]"
        })))
      }
    }
    responses "409" {
      description = "name conflicts with an existing service"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "201" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.ServiceCreateResponse
      }
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "403" {
      description = "network is not eligible for services"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/swarm/leave" "post" {
    operationId = "SwarmLeave"
    summary = "Leave a swarm"
    tags = ["Swarm"]
    parameters "force" {
      in = "query"
      description = "Force leave swarm, even if this is the last manager or that it will\\nbreak the cluster."
      schema = boolean(default(false))
    }
    responses "200" {
      description = "no error"
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/images/json" "get" {
    description = "Returns a list of images on the server. Note that it uses a different, smaller representation of an image than inspecting a single image."
    operationId = "ImageList"
    tags = ["Image"]
    summary = "List Images"
    parameters "all" {
      in = "query"
      description = "Show all images. Only images from a final layer (no children) are shown by default."
      schema = boolean(default(false))
    }
    parameters "filters" {
      in = "query"
      description = "A JSON encoded value of the filters (a `map[string][]string`) to\\nprocess on the images list.\\n\\nAvailable filters:\\n\\n- `before`=(`<image-name>[:<tag>]`,  `<image id>` or `<image@digest>`)\\n- `dangling=true`\\n- `label=key` or `label=\"key=value\"` of an image label\\n- `reference`=(`<image-name>[:<tag>]`)\\n- `since`=(`<image-name>[:<tag>]`,  `<image id>` or `<image@digest>`)\\n- `until=<timestamp>`"
      schema = string()
    }
    parameters "shared-size" {
      in = "query"
      description = "Compute and show shared size as a `SharedSize` field on each image."
      schema = boolean(default(false))
    }
    parameters "digests" {
      description = "Show digest information as a `RepoDigests` field on each image."
      in = "query"
      schema = boolean(default(false))
    }
    responses "200" {
      description = "Summary image data for the images matching the query"
      content "application/json" {
        schema = array([components.schemas.ImageSummary])
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/volumes" "get" {
    operationId = "VolumeList"
    summary = "List volumes"
    tags = ["Volume"]
    parameters "filters" {
      description = "JSON encoded value of the filters (a `map[string][]string`) to\\nprocess on the volumes list. Available filters:\\n\\n- `dangling=<boolean>` When set to `true` (or `1`), returns all\\n   volumes that are not in use by a container. When set to `false`\\n   (or `0`), only volumes that are in use by one or more\\n   containers are returned.\\n- `driver=<volume-driver-name>` Matches volumes based on their driver.\\n- `label=<key>` or `label=<key>:<value>` Matches volumes based on\\n   the presence of a `label` alone or a `label` and a value.\\n- `name=<volume-name>` Matches all or part of a volume name."
      schema = string(format("json"))
      in = "query"
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "Summary volume data that matches the query"
      content "application/json" {
        schema = components.schemas.VolumeListResponse
      }
    }
  }
  paths "/containers/{id}/rename" "post" {
    operationId = "ContainerRename"
    tags = ["Container"]
    summary = "Rename a container"
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the container"
      schema = string()
    }
    parameters "name" {
      description = "New name for the container"
      schema = string()
      required = true
      in = "query"
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "204" {
      description = "no error"
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "409" {
      description = "name already in use"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/images/create" "post" {
    summary = "Create an image"
    description = "Pull or import an image."
    operationId = "ImageCreate"
    tags = ["Image"]
    parameters "fromImage" {
      in = "query"
      description = "Name of the image to pull. The name may include a tag or digest. This parameter may only be used when pulling an image. The pull is cancelled if the HTTP connection is closed."
      schema = string()
    }
    parameters "fromSrc" {
      in = "query"
      description = "Source to import. The value may be a URL from which the image can be retrieved or `-` to read the image from the request body. This parameter may only be used when importing an image."
      schema = string()
    }
    parameters "repo" {
      description = "Repository name given to an image when it is imported. The repo may include a tag. This parameter may only be used when importing an image."
      schema = string()
      in = "query"
    }
    parameters "tag" {
      description = "Tag or digest. If empty when pulling an image, this causes all tags for the given image to be pulled."
      schema = string()
      in = "query"
    }
    parameters "message" {
      in = "query"
      description = "Set commit message for imported image."
      schema = string()
    }
    parameters "X-Registry-Auth" {
      in = "header"
      description = "A base64url-encoded auth configuration.\\n\\nRefer to the [authentication section](#section/Authentication) for\\ndetails."
      schema = string()
    }
    parameters "changes" {
      in = "query"
      description = "Apply `Dockerfile` instructions to the image that is created,\\nfor example: `changes=ENV DEBUG=true`.\\nNote that `ENV DEBUG=true` should be URI component encoded.\\n\\nSupported `Dockerfile` instructions:\\n`CMD`|`ENTRYPOINT`|`ENV`|`EXPOSE`|`ONBUILD`|`USER`|`VOLUME`|`WORKDIR`"
      style = "form"
      schema = array([string()])
    }
    parameters "platform" {
      in = "query"
      description = "Platform in the format os[/arch[/variant]].\\n\\nWhen used in combination with the `fromImage` option, the daemon checks\\nif the given image is present in the local image cache with the given\\nOS and Architecture, and otherwise attempts to pull the image. If the\\noption is not set, the host's native OS and Architecture are used.\\nIf the given image does not exist in the local image cache, the daemon\\nattempts to pull the image with the host's native OS and Architecture.\\nIf the given image does exists in the local image cache, but its OS or\\narchitecture does not match, a warning is produced.\\n\\nWhen used with the `fromSrc` option to import an image from an archive,\\nthis option sets the platform information for the imported image. If\\nthe option is not set, the host's native OS and Architecture are used\\nfor the imported image."
      schema = string()
    }
    requestBody {
      description = "Image content if the value `-` has been specified in fromSrc query parameter"
      content "text/plain" {
        schema = string()
      }
      content "application/octet-stream" {
        schema = string()
      }
    }
    responses "200" {
      description = "no error"
    }
    responses "404" {
      description = "repository does not exist or no read access"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "inputImage"
    }
  }
  paths "/nodes/{id}/update" "post" {
    summary = "Update a node"
    operationId = "NodeUpdate"
    tags = ["Node"]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the node"
      schema = string()
    }
    parameters "version" {
      required = true
      in = "query"
      description = "The version number of the node object being updated. This is required\\nto avoid conflicting writes."
      schema = integer(format("int64"))
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.NodeSpec
      }
      content "text/plain" {
        schema = components.schemas.NodeSpec
      }
    }
    responses "200" {
      description = "no error"
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "no such node"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/swarm" "get" {
    summary = "Inspect swarm"
    operationId = "SwarmInspect"
    tags = ["Swarm"]
    responses "503" {
      description = "node is not part of a swarm"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
      content "text/plain" {
        schema = components.schemas.Swarm
      }
      content "application/json" {
        schema = components.schemas.Swarm
      }
    }
    responses "404" {
      description = "no such swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/archive" "head" {
    summary = "Get information about files in a container"
    description = "A response header `X-Docker-Container-Path-Stat` is returned, containing\\na base64 - encoded JSON object with some filesystem header information\\nabout the path."
    operationId = "ContainerArchiveInfo"
    tags = ["Container"]
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the container"
      schema = string()
    }
    parameters "path" {
      in = "query"
      description = "Resource in the container’s filesystem to archive."
      schema = string()
      required = true
    }
    responses "404" {
      description = "Container or path does not exist"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
      headers "X-Docker-Container-Path-Stat" {
        description = "A base64 - encoded JSON object with some filesystem header\\ninformation about the path"
        schema = string()
      }
    }
    responses "400" {
      description = "Bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/archive" "get" {
    tags = ["Container"]
    summary = "Get an archive of a filesystem resource in a container"
    description = "Get a tar archive of a resource in the filesystem of container id."
    operationId = "ContainerArchive"
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the container"
      schema = string()
    }
    parameters "path" {
      schema = string()
      required = true
      in = "query"
      description = "Resource in the container’s filesystem to archive."
    }
    responses "200" {
      description = "no error"
    }
    responses "400" {
      description = "Bad parameter"
      content "application/x-tar" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "Container or path does not exist"
      content "application/x-tar" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
      }
    }
    responses "500" {
      description = "server error"
      content "application/x-tar" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/containers/{id}/archive" "put" {
    tags = ["Container"]
    summary = "Extract an archive of files or folders to a directory in a container"
    description = "Upload a tar archive to be extracted to a path in the filesystem of container id.\\n`path` parameter is asserted to be a directory. If it exists as a file, 400 error\\nwill be returned with message \"not a directory\"."
    operationId = "PutContainerArchive"
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of the container"
      schema = string()
    }
    parameters "path" {
      schema = string()
      required = true
      in = "query"
      description = "Path to a directory in the container to extract the archive’s contents into."
    }
    parameters "noOverwriteDirNonDir" {
      in = "query"
      description = "If `1`, `true`, or `True` then it will be an error if unpacking the\\ngiven content would cause an existing directory to be replaced with\\na non-directory and vice versa."
      schema = string()
    }
    parameters "copyUIDGID" {
      in = "query"
      description = "If `1`, `true`, then it will copy UID/GID maps to the dest file or\\ndir"
      schema = string()
    }
    requestBody {
      required = true
      description = "The input stream must be a tar archive compressed with one of the\\nfollowing algorithms: `identity` (no compression), `gzip`, `bzip2`,\\nor `xz`."
      content "application/octet-stream" {
        schema = string(format("binary"))
      }
      content "application/x-tar" {
        schema = string(format("binary"))
      }
    }
    responses "403" {
      description = "Permission denied, the volume or container rootfs is marked as read-only."
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "No such container or path does not exist inside the container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "The content was extracted successfully"
    }
    responses "400" {
      description = "Bad parameter"
      content "application/json" {
        example = "message: not a directory"
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "inputStream"
    }
  }
  paths "/plugins/pull" "post" {
    operationId = "PluginPull"
    summary = "Install a plugin"
    description = "Pulls and installs a plugin. After the plugin is installed, it can be\\nenabled using the [`POST /plugins/{name}/enable` endpoint](#operation/PostPluginsEnable)."
    tags = ["Plugin"]
    parameters "remote" {
      required = true
      in = "query"
      description = "Remote reference for plugin to install.\\n\\nThe `:latest` tag is optional, and is used as the default if omitted."
      schema = string()
    }
    parameters "name" {
      in = "query"
      description = "Local name for the pulled plugin.\\n\\nThe `:latest` tag is optional, and is used as the default if omitted."
      schema = string()
    }
    parameters "X-Registry-Auth" {
      in = "header"
      description = "A base64url-encoded auth configuration to use when pulling a plugin\\nfrom a registry.\\n\\nRefer to the [authentication section](#section/Authentication) for\\ndetails."
      schema = string()
    }
    requestBody {
      content "application/json" {
        schema = array(example(["map[Description: Name:network Value:[host]]", "map[Description: Name:mount Value:[/data]]", "map[Description: Name:device Value:[/dev/cpu_dma_latency]]"]), [components.schemas.PluginPrivilege])
      }
      content "text/plain" {
        schema = array(example(["map[Description: Name:network Value:[host]]", "map[Description: Name:mount Value:[/data]]", "map[Description: Name:device Value:[/dev/cpu_dma_latency]]"]), [components.schemas.PluginPrivilege])
      }
    }
    responses "204" {
      description = "no error"
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/session" "post" {
    summary = "Initialize interactive session"
    description = "Start a new interactive session with a server. Session allows server to\\ncall back to the client for advanced capabilities.\\n\\n### Hijacking\\n\\nThis endpoint hijacks the HTTP connection to HTTP2 transport that allows\\nthe client to expose gPRC services on that connection.\\n\\nFor example, the client sends this request to upgrade the connection:\\n\\n```\\nPOST /session HTTP/1.1\\nUpgrade: h2c\\nConnection: Upgrade\\n```\\n\\nThe Docker daemon responds with a `101 UPGRADED` response follow with\\nthe raw stream:\\n\\n```\\nHTTP/1.1 101 UPGRADED\\nConnection: Upgrade\\nUpgrade: h2c\\n```"
    operationId = "Session"
    tags = ["Session"]
    responses "400" {
      description = "bad parameter"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/vnd.docker.raw-stream" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "101" {
      description = "no error, hijacking successful"
    }
  }
  paths "/networks" "get" {
    operationId = "NetworkList"
    tags = ["Network"]
    summary = "List networks"
    description = "Returns a list of networks. For details on the format, see the\\n[network inspect endpoint](#operation/NetworkInspect).\\n\\nNote that it uses a different, smaller representation of a network than\\ninspecting a single network. For example, the list of containers attached\\nto the network is not propagated in API versions 1.28 and up."
    parameters "filters" {
      in = "query"
      description = "JSON encoded value of the filters (a `map[string][]string`) to process\\non the networks list.\\n\\nAvailable filters:\\n\\n- `dangling=<boolean>` When set to `true` (or `1`), returns all\\n   networks that are not in use by a container. When set to `false`\\n   (or `0`), only networks that are in use by one or more\\n   containers are returned.\\n- `driver=<driver-name>` Matches a network's driver.\\n- `id=<network-id>` Matches all or part of a network ID.\\n- `label=<key>` or `label=<key>=<value>` of a network label.\\n- `name=<network-name>` Matches all or part of a network name.\\n- `scope=[\"swarm\"|\"global\"|\"local\"]` Filters networks by scope (`swarm`, `global`, or `local`).\\n- `type=[\"custom\"|\"builtin\"]` Filters networks by type. The `custom` keyword returns all user-defined networks."
      schema = string()
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        example = "- Name: bridge\\n  Id: f2de39df4171b0dc801e8002d1d999b77256983dfc63041c0f34030aa3977566\\n  Created: 2016-10-19T06:21:00.416543526Z\\n  Scope: local\\n  Driver: bridge\\n  EnableIPv6: false\\n  Internal: false\\n  Attachable: false\\n  Ingress: false\\n  IPAM:\\n    Driver: default\\n    Config:\\n        - Subnet: 172.17.0.0/16\\n  Options:\\n    com.docker.network.bridge.default_bridge: \"true\"\\n    com.docker.network.bridge.enable_icc: \"true\"\\n    com.docker.network.bridge.enable_ip_masquerade: \"true\"\\n    com.docker.network.bridge.host_binding_ipv4: 0.0.0.0\\n    com.docker.network.bridge.name: docker0\\n    com.docker.network.driver.mtu: \"1500\"\\n- Name: none\\n  Id: e086a3893b05ab69242d3c44e49483a3bbbd3a26b46baa8f61ab797c1088d794\\n  Created: 0001-01-01T00:00:00Z\\n  Scope: local\\n  Driver: \"null\"\\n  EnableIPv6: false\\n  Internal: false\\n  Attachable: false\\n  Ingress: false\\n  IPAM:\\n    Driver: default\\n    Config: []\\n  Containers: {}\\n  Options: {}\\n- Name: host\\n  Id: 13e871235c677f196c4e1ecebb9dc733b9b2d2ab589e30c539efeda84a24215e\\n  Created: 0001-01-01T00:00:00Z\\n  Scope: local\\n  Driver: host\\n  EnableIPv6: false\\n  Internal: false\\n  Attachable: false\\n  Ingress: false\\n  IPAM:\\n    Driver: default\\n    Config: []\\n  Containers: {}\\n  Options: {}"
        schema = array([components.schemas.Network])
      }
    }
  }
  paths "/secrets/{id}/update" "post" {
    summary = "Update a Secret"
    operationId = "SecretUpdate"
    tags = ["Secret"]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID or name of the secret"
      schema = string()
    }
    parameters "version" {
      required = true
      in = "query"
      description = "The version number of the secret object being updated. This is\\nrequired to avoid conflicting writes."
      schema = integer(format("int64"))
    }
    requestBody {
      description = "The spec of the secret to update. Currently, only the Labels field\\ncan be updated. All other fields must remain unchanged from the\\n[SecretInspect endpoint](#operation/SecretInspect) response values."
      content "application/json" {
        schema = components.schemas.SecretSpec
      }
      content "text/plain" {
        schema = components.schemas.SecretSpec
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
    }
    responses "400" {
      description = "bad parameter"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "404" {
      description = "no such secret"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    specificationExtension {
      x-codegen-request-body-name = "body"
    }
  }
  paths "/services/{id}" "get" {
    operationId = "ServiceInspect"
    summary = "Inspect a service"
    tags = ["Service"]
    parameters "id" {
      description = "ID or name of service."
      in = "path"
      schema = string()
      required = true
    }
    parameters "insertDefaults" {
      in = "query"
      description = "Fill empty fields with default values."
      schema = boolean(default(false))
    }
    responses "404" {
      description = "no such service"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
      content "application/json" {
        schema = components.schemas.Service
      }
      content "text/plain" {
        schema = components.schemas.Service
      }
    }
  }
  paths "/services/{id}" "delete" {
    operationId = "ServiceDelete"
    summary = "Delete a service"
    tags = ["Service"]
    parameters "id" {
      required = true
      in = "path"
      description = "ID or name of service."
      schema = string()
    }
    responses "404" {
      description = "no such service"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "503" {
      description = "node is not part of a swarm"
      content "text/plain" {
        schema = components.schemas.ErrorResponse
      }
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "no error"
    }
  }
  paths "/containers/{id}/changes" "get" {
    tags = ["Container"]
    operationId = "ContainerChanges"
    summary = "Get changes on a container’s filesystem"
    description = "Returns which files in a container's filesystem have been added, deleted,\\nor modified. The `Kind` of modification can be one of:\\n\\n- `0`: Modified (\"C\")\\n- `1`: Added (\"A\")\\n- `2`: Deleted (\"D\")"
    parameters "id" {
      required = true
      description = "ID or name of the container"
      in = "path"
      schema = string()
    }
    responses "200" {
      description = "The list of changes"
      content "application/json" {
        example = "- Path: /dev\\n  Kind: 0\\n- Path: /dev/kmsg\\n  Kind: 1\\n- Path: /test\\n  Kind: 1"
        schema = array([components.schemas.FilesystemChange])
      }
    }
    responses "404" {
      description = "no such container"
      content "application/json" {
        example = "message: 'No such container: c2ada9df5af8'"
        schema = components.schemas.ErrorResponse
      }
    }
    responses "500" {
      description = "server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  paths "/build/prune" "post" {
    summary = "Delete builder cache"
    operationId = "BuildPrune"
    tags = ["Image"]
    parameters "keep-storage" {
      in = "query"
      description = "Amount of disk space in bytes to keep for cache"
      schema = integer(format("int64"))
    }
    parameters "all" {
      in = "query"
      description = "Remove all types of build cache"
      schema = boolean()
    }
    parameters "filters" {
      in = "query"
      description = "A JSON encoded value of the filters (a `map[string][]string`) to\\nprocess on the list of build cache objects.\\n\\nAvailable filters:\\n\\n- `until=<timestamp>` remove cache older than `<timestamp>`. The `<timestamp>` can be Unix timestamps, date formatted timestamps, or Go duration strings (e.g. `10m`, `1h30m`) computed relative to the daemon's local time.\\n- `id=<id>`\\n- `parent=<id>`\\n- `type=<string>`\\n- `description=<string>`\\n- `inuse`\\n- `shared`\\n- `private`"
      schema = string()
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        schema = {
          title = "BuildPruneResponse",
          type = "object",
          properties = {
            SpaceReclaimed = integer(format("int64"), description("Disk space reclaimed in bytes")),
            CachesDeleted = array([string(description("ID of build cache object"))])
          }
        }
      }
    }
  }
  paths "/volumes/prune" "post" {
    summary = "Delete unused volumes"
    operationId = "VolumePrune"
    tags = ["Volume"]
    parameters "filters" {
      in = "query"
      description = "Filters to process on the prune list, encoded as JSON (a `map[string][]string`).\\n\\nAvailable filters:\\n- `label` (`label=<key>`, `label=<key>=<value>`, `label!=<key>`, or `label!=<key>=<value>`) Prune volumes with (or without, in case `label!=...` is used) the specified labels.\\n- `all` (`all=true`) - Consider all (local) volumes for pruning and not just anonymous volumes."
      schema = string()
    }
    responses "200" {
      description = "No error"
      content "application/json" {
        schema = {
          title = "VolumePruneResponse",
          type = "object",
          properties = {
            SpaceReclaimed = integer(format("int64"), description("Disk space reclaimed in bytes")),
            VolumesDeleted = array(description("Volumes that were deleted"), [string()])
          }
        }
      }
    }
    responses "500" {
      description = "Server error"
      content "application/json" {
        schema = components.schemas.ErrorResponse
      }
    }
  }
  components "schemas" "CreateImageInfo" {
    type = "object"
    properties {
      id = string()
      error = string()
      errorDetail = components.schemas.ErrorDetail
      status = string()
      progress = string()
      progressDetail = components.schemas.ProgressDetail
    }
  }
  components "schemas" "Port" {
    type = "object"
    description = "An open port on a container"
    example = {
      PublicPort = "80",
      Type = "tcp",
      PrivatePort = "8080"
    }
    required = ["PrivatePort", "Type"]
    properties {
      PrivatePort = integer(format("uint16"), description("Port on the container"))
      PublicPort = integer(format("uint16"), description("Port exposed on the host"))
      Type = string(enum("tcp", "udp", "sctp"))
      IP = string(format("ip-address"), description("Host IP address that the container's port is mapped to"))
    }
  }
  components "schemas" "Task" {
    type = "object"
    example = {
      ID = "0kzzo1i0y4jz6027t0k7aezc7",
      CreatedAt = "2016-06-07T21:07:31.171892745Z",
      Slot = "1",
      Status = "map[ContainerStatus:map[ContainerID:e5d62702a1b48d01c3e02ca1e0212a250801fa8d67caca0b6f35919ebc12f035 PID:677] Message:started State:running Timestamp:2016-06-07T21:07:31.290032978Z]",
      DesiredState = "running",
      NetworksAttachments = "[map[Addresses:[10.255.0.10/16] Network:map[CreatedAt:2016-06-07T20:31:11.912919752Z DriverState:map[Name:overlay Options:map[com.docker.network.driver.overlay.vxlanid_list:256]] ID:4qvuz4ko70xaltuqbt8956gd1 IPAMOptions:map[Configs:[map[Gateway:10.255.0.1 Subnet:10.255.0.0/16]] Driver:map[Name:default]] Spec:map[DriverConfiguration:map[] IPAMOptions:map[Configs:[map[Gateway:10.255.0.1 Subnet:10.255.0.0/16]] Driver:map[]] Labels:map[com.docker.swarm.internal:true] Name:ingress] UpdatedAt:2016-06-07T21:07:29.955277358Z Version:map[Index:18]]]]",
      Version = "map[Index:71]",
      UpdatedAt = "2016-06-07T21:07:31.376370513Z",
      Spec = "map[ContainerSpec:map[Image:redis] Placement:map[] Resources:map[Limits:map[] Reservations:map[]] RestartPolicy:map[Condition:any MaxAttempts:0]]",
      ServiceID = "9mnpnzenvg8p8tdbtq4wvbkcz",
      NodeID = "60gvrl6tm78dmak4yl7srz94v",
      AssignedGenericResources = "[map[DiscreteResourceSpec:map[Kind:SSD Value:3]] map[NamedResourceSpec:map[Kind:GPU Value:UUID1]] map[NamedResourceSpec:map[Kind:GPU Value:UUID2]]]"
    }
    properties {
      JobIteration = components.schemas.ObjectVersion
      Labels = map(string(), description("User-defined key/value metadata."))
      ServiceID = string(description("The ID of the service this task is part of."))
      Slot = integer()
      NodeID = string(description("The ID of the node that this task is on."))
      UpdatedAt = string(format("dateTime"))
      CreatedAt = string(format("dateTime"))
      AssignedGenericResources = components.schemas.GenericResources
      Name = string(description("Name of the task."))
      DesiredState = components.schemas.TaskState
      ID = string(description("The ID of the task."))
      Version = components.schemas.ObjectVersion
      Spec = components.schemas.TaskSpec
      Status = components.schemas.TaskStatus
    }
  }
  components "schemas" "LocalNodeState" {
    default = ""
    example = "active"
    enum = [, "inactive", "pending", "active", "error", "locked"]
    type = "string"
    description = "Current local status of this node."
  }
  components "schemas" "OCIDescriptor" {
    type = "object"
    description = "A descriptor struct containing digest, media type, and size, as defined in\\nthe [OCI Content Descriptors Specification](https://github.com/opencontainers/image-spec/blob/v1.0.1/descriptor.md)."
    specificationExtension {
      x-go-name = "Descriptor"
    }
    properties {
      digest = string(description("The digest of the targeted content."), example("sha256:c0537ff6a5218ef531ece93d4984efc99bbf3f7497c0a7726c88e2bb7584dc96"))
      size = integer(format("int64"), description("The size in bytes of the blob."), example(3987495))
      mediaType = string(description("The media type of the object this schema refers to."), example("application/vnd.docker.distribution.manifest.v2+json"))
    }
  }
  components "schemas" "RestartPolicy" {
    type = "object"
    description = "The behavior to apply when the container exits. The default is not to\\nrestart.\\n\\nAn ever increasing delay (double the previous delay, starting at 100ms) is\\nadded before each restart to prevent flooding the server."
    properties {
      Name = string(description("- Empty string means not to restart\\n- `no` Do not automatically restart\\n- `always` Always restart\\n- `unless-stopped` Restart always except when the user has manually stopped the container\\n- `on-failure` Restart only when the container exit code is non-zero"), enum(, "no", "always", "unless-stopped", "on-failure"))
      MaximumRetryCount = integer(description("If `on-failure` is used, the number of times to retry before giving up."))
    }
  }
  components "schemas" "PortMap" {
    type = "object"
    description = "PortMap describes the mapping of container ports to host ports, using the\\ncontainer's port-number and protocol as key in the format `<port>/<protocol>`,\\nfor example, `80/udp`.\\n\\nIf a container's port is mapped for multiple protocols, separate entries\\nare added to the mapping table."
    example = {
      443/tcp = "[map[HostIp:127.0.0.1 HostPort:4443]]",
      80/tcp = "[map[HostIp:0.0.0.0 HostPort:80] map[HostIp:0.0.0.0 HostPort:8080]]",
      80/udp = "[map[HostIp:0.0.0.0 HostPort:80]]",
      53/udp = "[map[HostIp:0.0.0.0 HostPort:53]]"
    }
    additionalProperties = {
      nullable = true,
      type = "array",
      items = [components.schemas.PortBinding]
    }
  }
  components "schemas" "BuildCache" {
    description = "BuildCache contains information about a build cache record."
    type = "object"
    properties {
      Size = integer(description("Amount of disk space used by the build cache (in bytes)."), example(51))
      LastUsedAt = {
        nullable = true,
        type = "string",
        format = "dateTime",
        description = "Date and time at which the build cache was last used in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds.",
        example = "2017-08-09T07:09:37.632105588Z"
      }
      ID = string(description("Unique ID of the build cache record."), example("ndlpt0hhvkqcdfkputsk4cq9c"))
      Type = string(description("Cache record type."), example("regular"), enum("internal", "frontend", "source.local", "source.git.checkout", "exec.cachemount", "regular"))
      UsageCount = integer(example(26))
      Parents = {
        nullable = true,
        type = "array",
        description = "List of parent build cache record IDs.",
        example = ["hw53o5aio51xtltp5xjp8v7fx"],
        items = [string()]
      }
      InUse = boolean(description("Indicates if the build cache is in use."), example(false))
      Shared = boolean(description("Indicates if the build cache is shared."), example(true))
      CreatedAt = string(format("dateTime"), description("Date and time at which the build cache was created in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds."), example("2016-08-18T10:44:24.496525531Z"))
      Parent = {
        nullable = true,
        type = "string",
        description = "ID of the parent build cache record.\\n\\n> **Deprecated**: This field is deprecated, and omitted if empty.",
        example = 
      }
      Description = string(description("Description of the build-step that produced the build cache."), example("mount / from exec /bin/sh -c echo 'Binary::apt::APT::Keep-Downloaded-Packages \"true\";' > /etc/apt/apt.conf.d/keep-cache"))
    }
  }
  components "schemas" "ServiceSpec" {
    type = "object"
    description = "User modifiable configuration for a service."
    properties {
      TaskTemplate = components.schemas.TaskSpec
      Mode = object(description("Scheduling mode for the service."), {
        Replicated = object({
          Replicas = integer(format("int64"))
        }),
        Global = object(),
        ReplicatedJob = object(description("The mode used for services with a finite number of tasks that run\\nto a completed state."), {
          MaxConcurrent = integer(format("int64"), description("The maximum number of replicas to run simultaneously."), default(1)),
          TotalCompletions = integer(format("int64"), description("The total number of replicas desired to reach the Completed\\nstate. If unset, will default to the value of `MaxConcurrent`"))
        }),
        GlobalJob = object(description("The mode used for services which run a task to the completed state\\non each valid node."))
      })
      UpdateConfig = object(description("Specification for the update strategy of the service."), {
        Order = string(description("The order of operations when rolling out an updated task. Either\\nthe old task is shut down before the new task is started, or the\\nnew task is started before the old task is shut down."), enum("stop-first", "start-first")),
        Parallelism = integer(format("int64"), description("Maximum number of tasks to be updated in one iteration (0 means\\nunlimited parallelism).")),
        Delay = integer(format("int64"), description("Amount of time between updates, in nanoseconds.")),
        FailureAction = string(description("Action to take if an updated task fails to run, or stops running\\nduring the update."), enum("continue", "pause", "rollback")),
        Monitor = integer(format("int64"), description("Amount of time to monitor each updated task for failures, in\\nnanoseconds.")),
        MaxFailureRatio = number(description("The fraction of tasks that may fail during an update before the\\nfailure action is invoked, specified as a floating point number\\nbetween 0 and 1."))
      })
      RollbackConfig = object(description("Specification for the rollback strategy of the service."), {
        Delay = integer(format("int64"), description("Amount of time between rollback iterations, in nanoseconds.")),
        FailureAction = string(description("Action to take if an rolled back task fails to run, or stops\\nrunning during the rollback."), enum("continue", "pause")),
        Monitor = integer(format("int64"), description("Amount of time to monitor each rolled back task for failures, in\\nnanoseconds.")),
        MaxFailureRatio = number(description("The fraction of tasks that may fail during a rollback before the\\nfailure action is invoked, specified as a floating point number\\nbetween 0 and 1.")),
        Order = string(description("The order of operations when rolling back a task. Either the old\\ntask is shut down before the new task is started, or the new task\\nis started before the old task is shut down."), enum("stop-first", "start-first")),
        Parallelism = integer(format("int64"), description("Maximum number of tasks to be rolled back in one iteration (0 means\\nunlimited parallelism)."))
      })
      Networks = array(description("Specifies which networks the service should attach to.\\n\\nDeprecated: This field is deprecated since v1.44. The Networks field in TaskSpec should be used instead."), [components.schemas.NetworkAttachmentConfig])
      EndpointSpec = components.schemas.EndpointSpec
      Name = string(description("Name of the service."))
      Labels = map(string(), description("User-defined key/value metadata."))
    }
  }
  components "schemas" "ClusterVolumeSpec" {
    type = "object"
    description = "Cluster-specific options used to create the volume."
    properties {
      Group = string(description("Group defines the volume group of this volume. Volumes belonging to\\nthe same group can be referred to by group name when creating\\nServices.  Referring to a volume by group instructs Swarm to treat\\nvolumes in that group interchangeably for the purpose of scheduling.\\nVolumes with an empty string for a group technically all belong to\\nthe same, emptystring group."))
      AccessMode = object(description("Defines how the volume is used by tasks."), {
        Sharing = string(description("The number and way that different tasks can use this volume\\nat one time.\\n- `none` The volume may only be used by one task at a time.\\n- `readonly` The volume may be used by any number of tasks, but they all must mount the volume as readonly\\n- `onewriter` The volume may be used by any number of tasks, but only one may mount it as read/write.\\n- `all` The volume may have any number of readers and writers."), default("none"), enum("none", "readonly", "onewriter", "all")),
        MountVolume = object(description("Options for using this volume as a Mount-type volume.\\n\\n    Either MountVolume or BlockVolume, but not both, must be\\n    present.\\n  properties:\\n    FsType:\\n      type: \"string\"\\n      description: |\\n        Specifies the filesystem type for the mount volume.\\n        Optional.\\n    MountFlags:\\n      type: \"array\"\\n      description: |\\n        Flags to pass when mounting the volume. Optional.\\n      items:\\n        type: \"string\"\\nBlockVolume:\\n  type: \"object\"\\n  description: |\\n    Options for using this volume as a Block-type volume.\\n    Intentionally empty.")),
        Secrets = array(description("Swarm Secrets that are passed to the CSI storage plugin when\\noperating on this volume."), [object(description("One cluster volume secret entry. Defines a key-value pair that\\nis passed to the plugin."), {
          Secret = string(description("Secret is the swarm Secret object from which to read data.\\nThis can be a Secret name or ID. The Secret data is\\nretrieved by swarm and used as the value of the key-value\\npair passed to the plugin.")),
          Key = string(description("Key is the name of the key of the key-value pair passed to\\nthe plugin."))
        })]),
        AccessibilityRequirements = object(description("Requirements for the accessible topology of the volume. These\\nfields are optional. For an in-depth description of what these\\nfields mean, see the CSI specification."), {
          Requisite = array(description("A list of required topologies, at least one of which the\\nvolume must be accessible from."), [components.schemas.Topology]),
          Preferred = array(description("A list of topologies that the volume should attempt to be\\nprovisioned in."), [components.schemas.Topology])
        }),
        CapacityRange = object(description("The desired capacity that the volume should be created with. If\\nempty, the plugin will decide the capacity."), {
          RequiredBytes = integer(format("int64"), description("The volume must be at least this big. The value of 0\\nindicates an unspecified minimum")),
          LimitBytes = integer(format("int64"), description("The volume must not be bigger than this. The value of 0\\nindicates an unspecified maximum."))
        }),
        Availability = string(description("The availability of the volume for use in tasks.\\n- `active` The volume is fully available for scheduling on the cluster\\n- `pause` No new workloads should use the volume, but existing workloads are not stopped.\\n- `drain` All workloads using this volume should be stopped and rescheduled, and no new ones should be started."), default("active"), enum("active", "pause", "drain")),
        Scope = string(description("The set of nodes this volume can be used on at one time.\\n- `single` The volume may only be scheduled to one node at a time.\\n- `multi` the volume may be scheduled to any supported number of nodes at a time."), default("single"), enum("single", "multi"))
      })
    }
  }
  components "schemas" "Topology" {
    type = "object"
    description = "A map of topological domains to topological segments. For in depth\\ndetails, see documentation for the Topology object in the CSI\\nspecification."
    additionalProperties = string()
  }
  components "schemas" "ManagerStatus" {
    nullable = true
    type = "object"
    description = "ManagerStatus represents the status of a manager.\\n\\nIt provides the current status of a node's manager component, if the node\\nis a manager."
    specificationExtension {
      x-nullable = "true"
    }
    properties {
      Leader = boolean(default(false), example(true))
      Reachability = components.schemas.Reachability
      Addr = string(description("The IP address and port at which the manager is reachable."), example("10.0.0.46:2377"))
    }
  }
  components "schemas" "ContainerSummary" {
    type = "object"
    properties {
      Status = string(description("Additional human-readable status of this container (e.g. `Exit 0`)"))
      ImageID = string(description("The ID of the image that this container was created from"))
      Labels = map(string(), description("User-defined key/value metadata."))
      Id = {
        description = "The ID of this container",
        type = "string",
        specificationExtension = {
          "x-go-name" = "ID"
        }
      }
      Command = string(description("Command to run when starting the container"))
      Created = integer(format("int64"), description("When the container was created"))
      SizeRootFs = integer(format("int64"), description("The total size of all the files in this container"))
      NetworkSettings = object(description("A summary of the container's network settings"), {
        Networks = map(components.schemas.EndpointSettings)
      })
      SizeRw = integer(format("int64"), description("The size of files that have been created or changed by this container"))
      State = string(description("The state of this container (e.g. `Exited`)"))
      Mounts = array([components.schemas.MountPoint])
      Image = string(description("The name of the image used when creating this container"))
      HostConfig = object({
        NetworkMode = string(),
        Annotations = {
          additionalProperties = string(),
          nullable = true,
          type = "object",
          description = "Arbitrary key-value metadata attached to container"
        }
      })
      Names = array(description("The names that this container has been given"), [string()])
      Ports = array(description("The ports exposed by this container"), [components.schemas.Port])
    }
  }
  components "schemas" "IndexInfo" {
    nullable = true
    type = "object"
    description = "IndexInfo contains information about a registry."
    specificationExtension {
      x-nullable = "true"
    }
    properties {
      Mirrors = array(description("List of mirrors, expressed as URIs."), example(["https://hub-mirror.corp.example.com:5000/", "https://registry-2.docker.io/", "https://registry-3.docker.io/"]), [string()])
      Secure = boolean(description("Indicates if the registry is part of the list of insecure\\nregistries.\\n\\nIf `false`, the registry is insecure. Insecure registries accept\\nun-encrypted (HTTP) and/or untrusted (HTTPS with certificates from\\nunknown CAs) communication.\\n\\n> **Warning**: Insecure registries can be useful when running a local\\n> registry. However, because its use creates security vulnerabilities\\n> it should ONLY be enabled for testing purposes. For increased\\n> security, users should add their CA to their system's list of\\n> trusted CAs instead of enabling this option."), example(true))
      Official = boolean(description("Indicates whether this is an official registry (i.e., Docker Hub / docker.io)"), example(true))
      Name = string(description("Name of the registry, such as \"docker.io\"."), example("docker.io"))
    }
  }
  components "schemas" "Limit" {
    type = "object"
    description = "An object describing a limit on resources which can be requested by a task."
    properties {
      NanoCPUs = integer(format("int64"), example(4000000000))
      MemoryBytes = integer(format("int64"), example(8272408576))
      Pids = integer(format("int64"), description("Limits the maximum number of PIDs in the container. Set `0` for unlimited."), default(0), example(100))
    }
  }
  components "schemas" "Reachability" {
    enum = ["unknown", "unreachable", "reachable"]
    type = "string"
    description = "Reachability represents the reachability of a node."
    example = "reachable"
  }
  components "schemas" "EndpointPortConfig" {
    type = "object"
    properties {
      Name = string()
      Protocol = string(enum("tcp", "udp", "sctp"))
      TargetPort = integer(description("The port inside the container."))
      PublishedPort = integer(description("The port on the swarm hosts."))
      PublishMode = string(description("The mode in which port is published.\\n\\n<p><br /></p>\\n\\n- \"ingress\" makes the target port accessible on every node,\\n  regardless of whether there is a task for the service running on\\n  that node or not.\\n- \"host\" bypasses the routing mesh and publish the port directly on\\n  the swarm node where that service is running."), default("ingress"), example("ingress"), enum("ingress", "host"))
    }
  }
  components "schemas" "ContainerWaitExitError" {
    description = "container waiting error, if any"
    type = "object"
    specificationExtension {
      x-go-name = "WaitExitError"
    }
    properties {
      Message = string(description("Details of an error"))
    }
  }
  components "schemas" "BuildInfo" {
    type = "object"
    properties {
      id = string()
      stream = string()
      error = string()
      errorDetail = components.schemas.ErrorDetail
      status = string()
      progress = string()
      progressDetail = components.schemas.ProgressDetail
      aux = components.schemas.ImageID
    }
  }
  components "schemas" "TLSInfo" {
    type = "object"
    description = "Information about the issuer of leaf TLS certificates and the trusted root\\nCA certificate."
    example = {
      CertIssuerPublicKey = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEmT9XIw9h1qoNclv9VeHmf/Vi6/uI2vFXdBveXTpcPjqx6i9wNazchk1XWV/dKTKvSh9xyGKmiIeRcE4OiMnJ1A==",
      TrustRoot = "-----BEGIN CERTIFICATE-----\\nMIIBajCCARCgAwIBAgIUbYqrLSOSQHoxD8CwG6Bi2PJi9c8wCgYIKoZIzj0EAwIw\\nEzERMA8GA1UEAxMIc3dhcm0tY2EwHhcNMTcwNDI0MjE0MzAwWhcNMzcwNDE5MjE0\\nMzAwWjATMREwDwYDVQQDEwhzd2FybS1jYTBZMBMGByqGSM49AgEGCCqGSM49AwEH\\nA0IABJk/VyMPYdaqDXJb/VXh5n/1Yuv7iNrxV3Qb3l06XD46seovcDWs3IZNV1lf\\n3Skyr0ofcchipoiHkXBODojJydSjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMB\\nAf8EBTADAQH/MB0GA1UdDgQWBBRUXxuRcnFjDfR/RIAUQab8ZV/n4jAKBggqhkjO\\nPQQDAgNIADBFAiAy+JTe6Uc3KyLCMiqGl2GyWGQqQDEcO3/YG36x7om65AIhAJvz\\npxv6zFeVEkAEEkqIYi0omA9+CjanB/6Bz4n1uw8H\\n-----END CERTIFICATE-----",
      CertIssuerSubject = "MBMxETAPBgNVBAMTCHN3YXJtLWNh"
    }
    properties {
      TrustRoot = string(description("The root CA certificate(s) that are used to validate leaf TLS\\ncertificates."))
      CertIssuerSubject = string(description("The base64-url-safe-encoded raw subject bytes of the issuer."))
      CertIssuerPublicKey = string(description("The base64-url-safe-encoded raw public key bytes of the issuer."))
    }
  }
  components "schemas" "DistributionInspect" {
    title = "DistributionInspectResponse"
    type = "object"
    description = "Describes the result obtained from contacting the registry to retrieve\\nimage metadata."
    required = ["Descriptor", "Platforms"]
    specificationExtension {
      x-go-name = "DistributionInspect"
    }
    properties {
      Platforms = array(description("An array containing all platforms supported by the image."), [components.schemas.OCIPlatform])
      Descriptor = components.schemas.OCIDescriptor
    }
  }
  components "schemas" "NetworkSettings" {
    type = "object"
    description = "NetworkSettings exposes the network settings in the API"
    properties {
      IPv6Gateway = string(description("IPv6 gateway address for this network.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: This field is only propagated when attached to the\\n> default \"bridge\" network. Use the information from the \"bridge\"\\n> network inside the `Networks` map instead, which contains the same\\n> information. This field was deprecated in Docker 1.9 and is scheduled\\n> to be removed in Docker 17.12.0"), example("2001:db8:2::100"))
      LinkLocalIPv6PrefixLen = integer(description("Prefix length of the IPv6 unicast address.\\n\\nDeprecated: This field is never set and will be removed in a future release."))
      EndpointID = string(description("EndpointID uniquely represents a service endpoint in a Sandbox.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: This field is only propagated when attached to the\\n> default \"bridge\" network. Use the information from the \"bridge\"\\n> network inside the `Networks` map instead, which contains the same\\n> information. This field was deprecated in Docker 1.9 and is scheduled\\n> to be removed in Docker 17.12.0"), example("b88f5b905aabf2893f3cbc4ee42d1ea7980bbc0a92e2c8922b1e1795298afb0b"))
      Gateway = string(description("Gateway address for the default \"bridge\" network.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: This field is only propagated when attached to the\\n> default \"bridge\" network. Use the information from the \"bridge\"\\n> network inside the `Networks` map instead, which contains the same\\n> information. This field was deprecated in Docker 1.9 and is scheduled\\n> to be removed in Docker 17.12.0"), example("172.17.0.1"))
      GlobalIPv6Address = string(description("Global IPv6 address for the default \"bridge\" network.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: This field is only propagated when attached to the\\n> default \"bridge\" network. Use the information from the \"bridge\"\\n> network inside the `Networks` map instead, which contains the same\\n> information. This field was deprecated in Docker 1.9 and is scheduled\\n> to be removed in Docker 17.12.0"), example("2001:db8::5689"))
      SandboxID = string(description("SandboxID uniquely represents a container's network stack."), example("9d12daf2c33f5959c8bf90aa513e4f65b561738661003029ec84830cd503a0c3"))
      LinkLocalIPv6Address = string(description("IPv6 unicast address using the link-local prefix.\\n\\nDeprecated: This field is never set and will be removed in a future release."), example())
      Networks = map(components.schemas.EndpointSettings, description("Information about all networks that the container is connected to."))
      IPPrefixLen = integer(description("Mask length of the IPv4 address.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: This field is only propagated when attached to the\\n> default \"bridge\" network. Use the information from the \"bridge\"\\n> network inside the `Networks` map instead, which contains the same\\n> information. This field was deprecated in Docker 1.9 and is scheduled\\n> to be removed in Docker 17.12.0"), example(16))
      GlobalIPv6PrefixLen = integer(description("Mask length of the global IPv6 address.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: This field is only propagated when attached to the\\n> default \"bridge\" network. Use the information from the \"bridge\"\\n> network inside the `Networks` map instead, which contains the same\\n> information. This field was deprecated in Docker 1.9 and is scheduled\\n> to be removed in Docker 17.12.0"), example(64))
      HairpinMode = boolean(description("Indicates if hairpin NAT should be enabled on the virtual interface.\\n\\nDeprecated: This field is never set and will be removed in a future release."), example(false))
      Ports = components.schemas.PortMap
      IPAddress = string(description("IPv4 address for the default \"bridge\" network.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: This field is only propagated when attached to the\\n> default \"bridge\" network. Use the information from the \"bridge\"\\n> network inside the `Networks` map instead, which contains the same\\n> information. This field was deprecated in Docker 1.9 and is scheduled\\n> to be removed in Docker 17.12.0"), example("172.17.0.4"))
      Bridge = string(description("Name of the default bridge interface when dockerd's --bridge flag is set."), example("docker0"))
      SecondaryIPv6Addresses = {
        type = "array",
        description = "Deprecated: This field is never set and will be removed in a future release.",
        items = [components.schemas.Address],
        nullable = true
      }
      SecondaryIPAddresses = {
        description = "Deprecated: This field is never set and will be removed in a future release.",
        items = [components.schemas.Address],
        nullable = true,
        type = "array"
      }
      MacAddress = string(description("MAC address for the container on the default \"bridge\" network.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: This field is only propagated when attached to the\\n> default \"bridge\" network. Use the information from the \"bridge\"\\n> network inside the `Networks` map instead, which contains the same\\n> information. This field was deprecated in Docker 1.9 and is scheduled\\n> to be removed in Docker 17.12.0"), example("02:42:ac:11:00:04"))
      SandboxKey = string(description("SandboxKey is the full path of the netns handle"), example("/var/run/docker/netns/8ab54b426c38"))
    }
  }
  components "schemas" "ImageInspect" {
    type = "object"
    description = "Information about an image in the local image cache."
    properties {
      GraphDriver = components.schemas.GraphDriverData
      Author = string(description("Name of the author that was specified when committing the image, or as\\nspecified through MAINTAINER (deprecated) in the Dockerfile."), example())
      Config = components.schemas.ImageConfig
      Architecture = string(description("Hardware CPU architecture that the image runs on."), example("arm"))
      Id = string(description("ID is the content-addressable ID of an image.\\n\\nThis identifier is a content-addressable digest calculated from the\\nimage's configuration (which includes the digests of layers used by\\nthe image).\\n\\nNote that this digest differs from the `RepoDigests` below, which\\nholds digests of image manifests that reference the image."), example("sha256:ec3f0931a6e6b6855d76b2d7b0be30e81860baccd891b2e243280bf1cd8ad710"))
      Metadata = object(description("Additional metadata of the image in the local cache. This information\\nis local to the daemon, and not part of the image itself."), {
        LastTagTime = {
          format = "dateTime",
          description = "Date and time at which the image was last tagged in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds.\\n\\nThis information is only available if the image was tagged locally,\\nand omitted otherwise.",
          example = "2022-02-28T14:40:02.623929178Z",
          nullable = true,
          type = "string"
        }
      })
      DockerVersion = string(description("The version of Docker that was used to build the image.\\n\\nDepending on how the image was created, this field may be empty."), example("27.0.1"))
      OsVersion = {
        nullable = true,
        type = "string",
        description = "Operating System version the image is built to run on (especially\\nfor Windows).",
        example = 
      }
      Parent = string(description("ID of the parent image.\\n\\nDepending on how the image was created, this field may be empty and\\nis only set for images that were built/created locally. This field\\nis empty if the image was pulled from an image registry."), example())
      Comment = string(description("Optional message that was set when committing or importing the image."), example())
      Size = integer(format("int64"), description("Total size of the image including all layers it is composed of."), example(1239828))
      Os = string(description("Operating System the image is built to run on."), example("linux"))
      VirtualSize = integer(format("int64"), description("Total size of the image including all layers it is composed of.\\n\\nDeprecated: this field is omitted in API v1.44, but kept for backward compatibility. Use Size instead."), example(1239828))
      Created = {
        nullable = true,
        type = "string",
        format = "dateTime",
        description = "Date and time at which the image was created, formatted in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds.\\n\\nThis information is only available if present in the image,\\nand omitted otherwise.",
        example = "2022-02-04T21:20:12.497794809Z"
      }
      Variant = {
        type = "string",
        description = "CPU architecture variant (presently ARM-only).",
        example = "v7",
        nullable = true
      }
      RepoTags = array(description("List of image names/tags in the local image cache that reference this\\nimage.\\n\\nMultiple image tags can refer to the same image, and this list may be\\nempty if no tags reference the image, in which case the image is\\n\"untagged\", in which case it can still be referenced by its ID."), example(["example:1.0", "example:latest", "example:stable", "internal.registry.example.com:5000/example:1.0"]), [string()])
      RootFS = object(description("Information about the image's RootFS, including the layer IDs."), required(["Type"]), {
        Type = string(example("layers")),
        Layers = array(example(["sha256:1834950e52ce4d5a88a1bbd131c537f4d0e56d10ff0dd69e66be3b7dfa9df7e6", "sha256:5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef"]), [string()])
      })
      RepoDigests = array(description("List of content-addressable digests of locally available image manifests\\nthat the image is referenced from. Multiple manifests can refer to the\\nsame image.\\n\\nThese digests are usually only available if the image was either pulled\\nfrom a registry, or if the image was pushed to a registry, which is when\\nthe manifest is generated and its digest calculated."), example(["example@sha256:afcc7f1ac1b49db317a7196c902e61c6c3c4607d63599ee1a82d702d249a0ccb", "internal.registry.example.com:5000/example@sha256:b69959407d21e8a062e0416bf13405bb2b71ed7a84dde4158ebafacfa06f5578"]), [string()])
    }
  }
  components "schemas" "ProcessConfig" {
    type = "object"
    properties {
      tty = boolean()
      entrypoint = string()
      arguments = array([string()])
      privileged = boolean()
      user = string()
    }
  }
  components "schemas" "ChangeType" {
    type = "integer"
    format = "uint8"
    description = "Kind of change\\n\\nCan be one of:\\n\\n- `0`: Modified (\"C\")\\n- `1`: Added (\"A\")\\n- `2`: Deleted (\"D\")"
    enum = [0, 1, 2]
    specificationExtension {
      x-nullable = "false"
    }
  }
  components "schemas" "ContainerWaitResponse" {
    required = ["StatusCode"]
    title = "ContainerWaitResponse"
    type = "object"
    description = "OK response to ContainerWait operation"
    specificationExtension {
      x-go-name = "WaitResponse"
    }
    properties {
      StatusCode = integer(format("int64"), description("Exit code of the container"))
      Error = components.schemas.ContainerWaitExitError
    }
  }
  components "schemas" "Platform" {
    type = "object"
    description = "Platform represents the platform (Arch/OS)."
    properties {
      Architecture = string(description("Architecture represents the hardware architecture (for example,\\n`x86_64`)."), example("x86_64"))
      OS = string(description("OS represents the Operating System (for example, `linux` or `windows`)."), example("linux"))
    }
  }
  components "schemas" "TaskStatus" {
    description = "represents the status of a task."
    type = "object"
    properties {
      Err = string()
      ContainerStatus = components.schemas.ContainerStatus
      PortStatus = components.schemas.PortStatus
      Timestamp = string(format("dateTime"))
      State = components.schemas.TaskState
      Message = string()
    }
  }
  components "schemas" "DeviceMapping" {
    description = "A device mapping between the host and container"
    example = {
      PathOnHost = "/dev/deviceName",
      PathInContainer = "/dev/deviceName",
      CgroupPermissions = "mrw"
    }
    type = "object"
    properties {
      CgroupPermissions = string()
      PathOnHost = string()
      PathInContainer = string()
    }
  }
  components "schemas" "DeviceRequest" {
    type = "object"
    description = "A request for devices to be sent to device drivers"
    properties {
      Driver = string(example("nvidia"))
      Count = integer(example(-1))
      DeviceIDs = array(example(["0", "1", "GPU-fef8089b-4820-abfc-e83e-94318197576e"]), [string()])
      Capabilities = array(description("A list of capabilities; an OR list of AND lists of capabilities."), example(["[gpu nvidia compute]"]), [array([string()])])
      Options = map(string(), description("Driver-specific options, specified as a key/value pairs. These options\\nare passed directly to the driver."))
    }
  }
  components "schemas" "ThrottleDevice" {
    type = "object"
    properties {
      Path = string(description("Device path"))
      Rate = integer(format("int64"), description("Rate"))
    }
  }
  components "schemas" "GraphDriverData" {
    type = "object"
    description = "Information about the storage driver used to store the container's and\\nimage's filesystem."
    required = ["Data", "Name"]
    properties {
      Data = map(string(), description("Low-level storage metadata, provided as key/value pairs.\\n\\nThis information is driver-specific, and depends on the storage-driver\\nin use, and should be used for informational purposes only."), example({
        MergedDir = "/var/lib/docker/overlay2/ef749362d13333e65fc95c572eb525abbe0052e16e086cb64bc3b98ae9aa6d74/merged",
        UpperDir = "/var/lib/docker/overlay2/ef749362d13333e65fc95c572eb525abbe0052e16e086cb64bc3b98ae9aa6d74/diff",
        WorkDir = "/var/lib/docker/overlay2/ef749362d13333e65fc95c572eb525abbe0052e16e086cb64bc3b98ae9aa6d74/work"
      }))
      Name = string(description("Name of the storage driver."), example("overlay2"))
    }
  }
  components "schemas" "FilesystemChange" {
    type = "object"
    description = "Change in the container's filesystem."
    required = ["Kind", "Path"]
    properties {
      Path = string(description("Path to file or directory that has changed."))
      Kind = components.schemas.ChangeType
    }
  }
  components "schemas" "VolumeCreateOptions" {
    type = "object"
    description = "Volume configuration"
    title = "VolumeConfig"
    specificationExtension {
      x-go-name = "CreateOptions"
    }
    properties {
      Name = string(description("The new volume's name. If not specified, Docker generates a name."), example("tardis"))
      Driver = string(description("Name of the volume driver to use."), default("local"), example("custom"))
      DriverOpts = map(string(), description("A mapping of driver options and values. These options are\\npassed directly to the driver and are driver specific."), example({
        device = "tmpfs",
        o = "size=100m,uid=1000",
        type = "tmpfs"
      }))
      Labels = map(string(), description("User-defined key/value metadata."), example({
        com.example.some-label = "some-value",
        com.example.some-other-label = "some-other-value"
      }))
      ClusterVolumeSpec = components.schemas.ClusterVolumeSpec
    }
  }
  components "schemas" "ResourceObject" {
    type = "object"
    description = "An object describing the resources which can be advertised by a node and\\nrequested by a task."
    properties {
      NanoCPUs = integer(format("int64"), example(4000000000))
      MemoryBytes = integer(format("int64"), example(8272408576))
      GenericResources = components.schemas.GenericResources
    }
  }
  components "schemas" "NodeState" {
    description = "NodeState represents the state of a node."
    example = "ready"
    enum = ["unknown", "down", "ready", "disconnected"]
    type = "string"
  }
  components "schemas" "Service" {
    type = "object"
    example = {
      Spec = "map[EndpointSpec:map[Mode:vip Ports:[map[Protocol:tcp PublishedPort:30001 TargetPort:6379]]] Mode:map[Replicated:map[Replicas:1]] Name:hopeful_cori RollbackConfig:map[Delay:1000000000 FailureAction:pause MaxFailureRatio:0.15 Monitor:15000000000 Parallelism:1] TaskTemplate:map[ContainerSpec:map[Image:redis] ForceUpdate:0 Placement:map[] Resources:map[Limits:map[] Reservations:map[]] RestartPolicy:map[Condition:any MaxAttempts:0]] UpdateConfig:map[Delay:1000000000 FailureAction:pause MaxFailureRatio:0.15 Monitor:15000000000 Parallelism:1]]",
      Endpoint = "map[Ports:[map[Protocol:tcp PublishedPort:30001 TargetPort:6379]] Spec:map[Mode:vip Ports:[map[Protocol:tcp PublishedPort:30001 TargetPort:6379]]] VirtualIPs:[map[Addr:10.255.0.2/16 NetworkID:4qvuz4ko70xaltuqbt8956gd1] map[Addr:10.255.0.3/16 NetworkID:4qvuz4ko70xaltuqbt8956gd1]]]",
      ID = "9mnpnzenvg8p8tdbtq4wvbkcz",
      Version = "map[Index:19]",
      CreatedAt = "2016-06-07T21:05:51.880065305Z",
      UpdatedAt = "2016-06-07T21:07:29.962229872Z"
    }
    properties {
      JobStatus = object(description("The status of the service when it is in one of ReplicatedJob or\\nGlobalJob modes. Absent on Replicated and Global mode services. The\\nJobIteration is an ObjectVersion, but unlike the Service's version,\\ndoes not need to be sent with an update request."), {
        JobIteration = components.schemas.ObjectVersion,
        LastExecution = string(format("dateTime"), description("The last time, as observed by the server, that this job was\\nstarted."))
      })
      Version = components.schemas.ObjectVersion
      CreatedAt = string(format("dateTime"))
      Endpoint = object({
        VirtualIPs = array([object({
          NetworkID = string(),
          Addr = string()
        })]),
        Spec = components.schemas.EndpointSpec,
        Ports = array([components.schemas.EndpointPortConfig])
      })
      ID = string()
      ServiceStatus = object(description("The status of the service's tasks. Provided only when requested as\\npart of a ServiceList operation."), {
        RunningTasks = integer(format("uint64"), description("The number of tasks for the service currently in the Running state."), example(7)),
        DesiredTasks = integer(format("uint64"), description("The number of tasks for the service desired to be running.\\nFor replicated services, this is the replica count from the\\nservice spec. For global services, this is computed by taking\\ncount of all tasks for the service with a Desired State other\\nthan Shutdown."), example(10)),
        CompletedTasks = integer(format("uint64"), description("The number of tasks for a job that are in the Completed state.\\nThis field must be cross-referenced with the service type, as the\\nvalue of 0 may mean the service is not in a job mode, or it may\\nmean the job-mode service has no tasks yet Completed."))
      })
      UpdatedAt = string(format("dateTime"))
      Spec = components.schemas.ServiceSpec
      UpdateStatus = object(description("The status of a service update."), {
        State = string(enum("updating", "paused", "completed")),
        StartedAt = string(format("dateTime")),
        CompletedAt = string(format("dateTime")),
        Message = string()
      })
    }
  }
  components "schemas" "Mount" {
    type = "object"
    properties {
      Type = string(description("The mount type. Available types:\\n\\n- `bind` Mounts a file or directory from the host into the container. Must exist prior to creating the container.\\n- `volume` Creates a volume with the given name and options (or uses a pre-existing volume with the same name and options). These are **not** removed when the container is removed.\\n- `tmpfs` Create a tmpfs with the given options. The mount source cannot be specified for tmpfs.\\n- `npipe` Mounts a named pipe from the host into the container. Must exist prior to creating the container.\\n- `cluster` a Swarm cluster volume"), enum("bind", "volume", "tmpfs", "npipe", "cluster"))
      ReadOnly = boolean(description("Whether the mount should be read-only."))
      Consistency = string(description("The consistency requirement for the mount: `default`, `consistent`, `cached`, or `delegated`."))
      BindOptions = object(description("Optional configuration for the `bind` type."), {
        NonRecursive = boolean(description("Disable recursive bind mount."), default(false)),
        CreateMountpoint = boolean(description("Create mount point on host if missing"), default(false)),
        ReadOnlyNonRecursive = boolean(description("Make the mount non-recursively read-only, but still leave the mount recursive\\n(unless NonRecursive is set to `true` in conjunction).\\n\\nAddded in v1.44, before that version all read-only mounts were\\nnon-recursive by default. To match the previous behaviour this\\nwill default to `true` for clients on versions prior to v1.44."), default(false)),
        ReadOnlyForceRecursive = boolean(description("Raise an error if the mount cannot be made recursively read-only."), default(false)),
        Propagation = string(description("A propagation mode with the value `[r]private`, `[r]shared`, or `[r]slave`."), enum("private", "rprivate", "shared", "rshared", "slave", "rslave"))
      })
      VolumeOptions = object(description("Optional configuration for the `volume` type."), {
        NoCopy = boolean(description("Populate volume with data from the target."), default(false)),
        Labels = map(string(), description("User-defined key/value metadata.")),
        DriverConfig = object(description("Map of driver specific options"), {
          Name = string(description("Name of the driver to use to create the volume.")),
          Options = map(string(), description("key/value map of driver specific options."))
        }),
        Subpath = string(description("Source path inside the volume. Must be relative without any back traversals."), example("dir-inside-volume/subdirectory"))
      })
      TmpfsOptions = object(description("Optional configuration for the `tmpfs` type."), {
        SizeBytes = integer(format("int64"), description("The size for the tmpfs mount in bytes.")),
        Mode = integer(description("The permission mode for the tmpfs mount in an integer.")),
        Options = array(description("The options to be passed to the tmpfs mount. An array of arrays.\\nFlag options should be provided as 1-length arrays. Other types\\nshould be provided as as 2-length arrays, where the first item is\\nthe key and the second the value."), example(["[noexec]"]), [array(maxItems(2), minItems(1), [string()])])
      })
      Target = string(description("Container path."))
      Source = string(description("Mount source (e.g. a volume name, a host path)."))
    }
  }
  components "schemas" "NodeSpec" {
    example = {
      Availability = "active",
      Name = "node-name",
      Role = "manager",
      Labels = "map[foo:bar]"
    }
    type = "object"
    properties {
      Role = string(description("Role of the node."), example("manager"), enum("worker", "manager"))
      Availability = string(description("Availability of the node."), example("active"), enum("active", "pause", "drain"))
      Name = string(description("Name for the node."), example("my-node"))
      Labels = map(string(), description("User-defined key/value metadata."))
    }
  }
  components "schemas" "ContainerState" {
    nullable = true
    type = "object"
    description = "ContainerState stores container's running state. It's part of ContainerJSONBase\\nand will be returned by the \"inspect\" command."
    specificationExtension {
      x-nullable = "true"
    }
    properties {
      Error = string()
      OOMKilled = boolean(description("Whether a process within this container has been killed because it ran\\nout of memory since the container was last started."), example(false))
      ExitCode = integer(description("The last exit code of this container"), example(0))
      FinishedAt = string(description("The time when this container last exited."), example("2020-01-06T09:07:59.461876391Z"))
      Dead = boolean(example(false))
      Paused = boolean(description("Whether this container is paused."), example(false))
      Pid = integer(description("The process ID of this container"), example(1234))
      Status = string(description("String representation of the container state. Can be one of \"created\",\\n\"running\", \"paused\", \"restarting\", \"removing\", \"exited\", or \"dead\"."), example("running"), enum("created", "running", "paused", "restarting", "removing", "exited", "dead"))
      Restarting = boolean(description("Whether this container is restarting."), example(false))
      StartedAt = string(description("The time when this container was last started."), example("2020-01-06T09:06:59.461876391Z"))
      Health = components.schemas.Health
      Running = boolean(description("Whether this container is running.\\n\\nNote that a running container can be _paused_. The `Running` and `Paused`\\nbooleans are not mutually exclusive:\\n\\nWhen pausing a container (on Linux), the freezer cgroup is used to suspend\\nall processes in the container. Freezing the process requires the process to\\nbe running. As a result, paused containers are both `Running` _and_ `Paused`.\\n\\nUse the `Status` field instead to determine if a container's state is \"running\"."), example(true))
    }
  }
  components "schemas" "SystemVersion" {
    type = "object"
    description = "Response of Engine API: GET \"/version"
    properties {
      KernelVersion = string(description("The kernel version (`uname -r`) that the daemon is running on.\\n\\nThis field is omitted when empty."), example("6.8.0-31-generic"))
      BuildTime = string(description("The date and time that the daemon was compiled."), example("2020-06-22T15:49:27.000000000+00:00"))
      ApiVersion = string(description("The default (and highest) API version that is supported by the daemon"), example("1.46"))
      Platform = object(required(["Name"]), {
        Name = string()
      })
      Version = string(description("The version of the daemon"), example("27.0.1"))
      Os = string(description("The operating system that the daemon is running on (\"linux\" or \"windows\")"), example("linux"))
      Arch = string(description("The architecture that the daemon is running on"), example("amd64"))
      MinAPIVersion = string(description("The minimum API version that is supported by the daemon"), example("1.24"))
      GitCommit = string(description("The Git commit of the source code that was used to build the daemon"), example("48a66213fe"))
      GoVersion = string(description("The version Go used to compile the daemon, and the version of the Go\\nruntime in use."), example("go1.21.11"))
      Experimental = boolean(description("Indicates if the daemon is started with experimental features enabled.\\n\\nThis field is omitted when empty / false."), example(true))
      Components = array(description("Information about system components"), [{
        type = "object",
        required = ["Name", "Version"],
        specificationExtension = {
          "x-go-name" = "ComponentVersion"
        },
        properties = {
          Name = string(description("Name of the component"), example("Engine")),
          Version = string(description("Version of the component"), example("27.0.1")),
          Details = {
            description = "Key/value pairs of strings with additional information about the\\ncomponent. These values are intended for informational purposes\\nonly, and their content is not defined, and not part of the API\\nspecification.\\n\\nThese messages can be printed by the client as information to the user.",
            nullable = true,
            type = "object"
          }
        }
      }])
    }
  }
  components "schemas" "Runtime" {
    type = "object"
    description = "Runtime describes an [OCI compliant](https://github.com/opencontainers/runtime-spec)\\nruntime.\\n\\nThe runtime is invoked by the daemon via the `containerd` daemon. OCI\\nruntimes act as an interface to the Linux kernel namespaces, cgroups,\\nand SELinux."
    properties {
      path = string(description("Name and, optional, path, of the OCI executable binary.\\n\\nIf the path is omitted, the daemon searches the host's `$PATH` for the\\nbinary and uses the first result."), example("/usr/local/bin/my-oci-runtime"))
      runtimeArgs = {
        type = "array",
        description = "List of command-line arguments to pass to the runtime when invoked.",
        example = ["--debug", "--systemd-cgroup=false"],
        items = [string()],
        nullable = true
      }
      status = {
        additionalProperties = string(),
        nullable = true,
        type = "object",
        description = "Information specific to the runtime.\\n\\nWhile this API specification does not define data provided by runtimes,\\nthe following well-known properties may be provided by runtimes:\\n\\n`org.opencontainers.runtime-spec.features`: features structure as defined\\nin the [OCI Runtime Specification](https://github.com/opencontainers/runtime-spec/blob/main/features.md),\\nin a JSON string representation.\\n\\n<p><br /></p>\\n\\n> **Note**: The information returned in this field, including the\\n> formatting of values and labels, should not be considered stable,\\n> and may change without notice.",
        example = {
          org.opencontainers.runtime-spec.features = "{\"ociVersionMin\":\"1.0.0\",\"ociVersionMax\":\"1.1.0\",\"...\":\"...\"}"
        }
      }
    }
  }
  components "schemas" "ImageConfig" {
    type = "object"
    description = "Configuration of the image. These fields are used as defaults\\nwhen starting a container from the image."
    example = {
      Labels = "map[com.example.some-label:some-value com.example.some-other-label:some-other-value]",
      StopSignal = "SIGTERM",
      Shell = "[/bin/sh -c]",
      Tty = "false",
      Cmd = "[/bin/sh]",
      Healthcheck = "map[Interval:0 Retries:0 StartInterval:0 StartPeriod:0 Test:[string] Timeout:0]",
      Volumes = "map[/app/config:map[] /app/data:map[]]",
      WorkingDir = "/public/",
      StdinOnce = "false",
      ArgsEscaped = "true",
      Image = ,
      Hostname = ,
      AttachStdin = "false",
      AttachStdout = "false",
      AttachStderr = "false",
      ExposedPorts = "map[443/tcp:map[] 80/tcp:map[]]",
      OnBuild = "[]",
      Domainname = ,
      User = "web:web",
      OpenStdin = "false",
      Env = "[PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin]",
      Entrypoint = "[]"
    }
    properties {
      WorkingDir = string(description("The working directory for commands to run in."), example("/public/"))
      AttachStdout = boolean(description("Whether to attach to `stdout`.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always false. It must not be used, and will be removed in API v1.47."), default(false), example(false))
      ExposedPorts = {
        description = "An object mapping ports to an empty object in the form:\\n\\n`{\"<port>/<tcp|udp|sctp>\": {}}`",
        example = {
          80/tcp = "map[]",
          443/tcp = "map[]"
        },
        additionalProperties = object(),
        nullable = true,
        type = "object"
      }
      NetworkDisabled = {
        example = false,
        nullable = true,
        type = "boolean",
        description = "Disable networking for the container.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always omitted. It must not be used, and will be removed in API v1.47.",
        default = false
      }
      MacAddress = {
        nullable = true,
        type = "string",
        description = "MAC address of the container.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always omitted. It must not be used, and will be removed in API v1.47.",
        default = ,
        example = 
      }
      Domainname = string(description("The domain name to use for the container.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always empty. It must not be used, and will be removed in API v1.47."), example())
      Tty = boolean(description("Attach standard streams to a TTY, including `stdin` if it is not closed.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always false. It must not be used, and will be removed in API v1.47."), default(false), example(false))
      Healthcheck = components.schemas.HealthConfig
      StdinOnce = boolean(description("Close `stdin` after one attached client disconnects.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always false. It must not be used, and will be removed in API v1.47."), default(false), example(false))
      Labels = map(string(), description("User-defined key/value metadata."), example({
        com.example.some-label = "some-value",
        com.example.some-other-label = "some-other-value"
      }))
      AttachStdin = boolean(description("Whether to attach to `stdin`.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always false. It must not be used, and will be removed in API v1.47."), default(false), example(false))
      Entrypoint = array(description("The entry point for the container as a string or an array of strings.\\n\\nIf the array consists of exactly one empty string (`[\"\"]`) then the\\nentry point is reset to system default (i.e., the entry point used by\\ndocker when there is no `ENTRYPOINT` instruction in the `Dockerfile`)."), example([]), [string()])
      OpenStdin = boolean(description("Open `stdin`\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always false. It must not be used, and will be removed in API v1.47."), default(false), example(false))
      Cmd = array(description("Command to run specified as a string or an array of strings."), example(["/bin/sh"]), [string()])
      AttachStderr = boolean(description("Whether to attach to `stderr`.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always false. It must not be used, and will be removed in API v1.47."), default(false), example(false))
      ArgsEscaped = {
        type = "boolean",
        description = "Command is already escaped (Windows only)",
        default = false,
        example = false,
        nullable = true
      }
      OnBuild = {
        nullable = true,
        type = "array",
        description = "`ONBUILD` metadata that were defined in the image's `Dockerfile`.",
        example = [],
        items = [string()]
      }
      StopTimeout = {
        nullable = true,
        type = "integer",
        description = "Timeout to stop a container in seconds.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always omitted. It must not be used, and will be removed in API v1.47."
      }
      Shell = {
        nullable = true,
        type = "array",
        description = "Shell for when `RUN`, `CMD`, and `ENTRYPOINT` uses a shell.",
        example = ["/bin/sh", "-c"],
        items = [string()]
      }
      Image = string(description("The name (or reference) of the image to use when creating the container,\\nor which was used when the container was created.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always empty. It must not be used, and will be removed in API v1.47."), default(), example())
      Volumes = map(object(), description("An object mapping mount point paths inside the container to empty\\nobjects."), example({
        /app/data = "map[]",
        /app/config = "map[]"
      }))
      Env = array(description("A list of environment variables to set inside the container in the\\nform `[\"VAR=value\", ...]`. A variable without `=` is removed from the\\nenvironment, rather than to have an empty value."), example(["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"]), [string()])
      StopSignal = {
        example = "SIGTERM",
        nullable = true,
        type = "string",
        description = "Signal to stop a container as a string or unsigned integer."
      }
      User = string(description("The user that commands are run as inside the container."), example("web:web"))
      Hostname = string(description("The hostname to use for the container, as a valid RFC 1123 hostname.\\n\\n<p><br /></p>\\n\\n> **Deprecated**: this field is not part of the image specification and is\\n> always empty. It must not be used, and will be removed in API v1.47."), example())
    }
  }
  components "schemas" "AuthConfig" {
    example = {
      username = "hannibal",
      password = "xxxx",
      serveraddress = "https://index.docker.io/v1/"
    }
    type = "object"
    properties {
      password = string()
      email = string()
      serveraddress = string()
      username = string()
    }
  }
  components "schemas" "Config" {
    type = "object"
    properties {
      ID = string()
      Version = components.schemas.ObjectVersion
      CreatedAt = string(format("dateTime"))
      UpdatedAt = string(format("dateTime"))
      Spec = components.schemas.ConfigSpec
    }
  }
  components "schemas" "Health" {
    nullable = true
    type = "object"
    description = "Health stores information about the container's healthcheck results."
    specificationExtension {
      x-nullable = "true"
    }
    properties {
      Status = string(description("Status is one of `none`, `starting`, `healthy` or `unhealthy`\\n\\n- \"none\"      Indicates there is no healthcheck\\n- \"starting\"  Starting indicates that the container is not yet ready\\n- \"healthy\"   Healthy indicates that the container is running correctly\\n- \"unhealthy\" Unhealthy indicates that the container has a problem"), example("healthy"), enum("none", "starting", "healthy", "unhealthy"))
      FailingStreak = integer(description("FailingStreak is the number of consecutive failures"), example(0))
      Log = array(description("Log contains the last few results (oldest first)"), [components.schemas.HealthcheckResult])
    }
  }
  components "schemas" "ClusterVolume" {
    type = "object"
    description = "Options and information specific to, and only present on, Swarm CSI\\ncluster volumes."
    properties {
      CreatedAt = string(format("dateTime"))
      UpdatedAt = string(format("dateTime"))
      Spec = components.schemas.ClusterVolumeSpec
      Info = object(description("Information about the global status of the volume."), {
        AccessibleTopology = array(description("The topology this volume is actually accessible from."), [components.schemas.Topology]),
        CapacityBytes = integer(format("int64"), description("The capacity of the volume in bytes. A value of 0 indicates that\\nthe capacity is unknown.")),
        VolumeContext = map(string(), description("A map of strings to strings returned from the storage plugin when\\nthe volume is created.")),
        VolumeID = string(description("The ID of the volume as returned by the CSI storage plugin. This\\nis distinct from the volume's ID as provided by Docker. This ID\\nis never used by the user when communicating with Docker to refer\\nto this volume. If the ID is blank, then the Volume has not been\\nsuccessfully created in the plugin yet."))
      })
      PublishStatus = array(description("The status of the volume as it pertains to its publishing and use on\\nspecific nodes"), [object({
        NodeID = string(description("The ID of the Swarm node the volume is published on.")),
        State = string(description("The published state of the volume.\\n* `pending-publish` The volume should be published to this node, but the call to the controller plugin to do so has not yet been successfully completed.\\n* `published` The volume is published successfully to the node.\\n* `pending-node-unpublish` The volume should be unpublished from the node, and the manager is awaiting confirmation from the worker that it has done so.\\n* `pending-controller-unpublish` The volume is successfully unpublished from the node, but has not yet been successfully unpublished on the controller."), enum("pending-publish", "published", "pending-node-unpublish", "pending-controller-unpublish")),
        PublishContext = map(string(), description("A map of strings to strings returned by the CSI controller\\nplugin when a volume is published."))
      })])
      ID = string(description("The Swarm ID of this volume. Because cluster volumes are Swarm\\nobjects, they have an ID, unlike non-cluster volumes. This ID can\\nbe used to refer to the Volume instead of the name."))
      Version = components.schemas.ObjectVersion
    }
  }
  components "schemas" "IdResponse" {
    type = "object"
    description = "Response to an API call that returns just an Id"
    required = ["Id"]
    properties {
      Id = string(description("The id of the newly created object."))
    }
  }
  components "schemas" "PortStatus" {
    type = "object"
    description = "represents the port status of a task's host ports whose service has published host ports"
    properties {
      Ports = array([components.schemas.EndpointPortConfig])
    }
  }
  components "schemas" "ContainerdInfo" {
    type = "object"
    description = "Information for connecting to the containerd instance that is used by the daemon.\\nThis is included for debugging purposes only."
    properties {
      Namespaces = object(description("The namespaces that the daemon uses for running containers and\\nplugins in containerd. These namespaces can be configured in the\\ndaemon configuration, and are considered to be used exclusively\\nby the daemon, Tampering with the containerd instance may cause\\nunexpected behavior.\\n\\nAs these namespaces are considered to be exclusively accessed\\nby the daemon, it is not recommended to change these values,\\nor to change them to a value that is used by other systems,\\nsuch as cri-containerd."), {
        Containers = string(description("The default containerd namespace used for containers managed\\nby the daemon.\\n\\nThe default namespace for containers is \"moby\", but will be\\nsuffixed with the `<uid>.<gid>` of the remapped `root` if\\nuser-namespaces are enabled and the containerd image-store\\nis used."), default("moby"), example("moby")),
        Plugins = string(description("The default containerd namespace used for plugins managed by\\nthe daemon.\\n\\nThe default namespace for plugins is \"plugins.moby\", but will be\\nsuffixed with the `<uid>.<gid>` of the remapped `root` if\\nuser-namespaces are enabled and the containerd image-store\\nis used."), default("plugins.moby"), example("plugins.moby"))
      })
      Address = string(description("The address of the containerd socket."), example("/run/containerd/containerd.sock"))
    }
  }
  components "schemas" "Commit" {
    type = "object"
    description = "Commit holds the Git-commit (SHA1) that a binary was built from, as\\nreported in the version-string of external tools, such as `containerd`,\\nor `runC`."
    properties {
      ID = string(description("Actual commit ID of external tool."), example("cfb82a876ecc11b5ca0977d1733adbe58599088a"))
      Expected = string(description("Commit ID of external tool expected by dockerd as set at build time."), example("2d41c047c83e09a6d61d464906feb2a2f3c52aa4"))
    }
  }
  components "schemas" "SwarmInfo" {
    type = "object"
    description = "Represents generic information about swarm."
    properties {
      NodeAddr = string(description("IP address at which this node can be reached by other nodes in the\\nswarm."), default(), example("10.0.0.46"))
      LocalNodeState = components.schemas.LocalNodeState
      Error = string(default())
      NodeID = string(description("Unique identifier of for this node in the swarm."), default(), example("k67qz4598weg5unwwffg6z1m1"))
      RemoteManagers = {
        nullable = true,
        type = "array",
        description = "List of ID's and addresses of other managers in the swarm.",
        example = ["map[Addr:10.0.0.158:2377 NodeID:71izy0goik036k48jg985xnds]", "map[Addr:10.0.0.159:2377 NodeID:79y6h1o4gv8n120drcprv5nmc]", "map[Addr:10.0.0.46:2377 NodeID:k67qz4598weg5unwwffg6z1m1]"],
        items = [components.schemas.PeerNode]
      }
      Managers = {
        type = "integer",
        description = "Total number of managers in the swarm.",
        example = 3,
        nullable = true
      }
      Cluster = components.schemas.ClusterInfo
      ControlAvailable = boolean(default(false), example(true))
      Nodes = {
        nullable = true,
        type = "integer",
        description = "Total number of nodes in the swarm.",
        example = 4
      }
    }
  }
  components "schemas" "SecretSpec" {
    type = "object"
    properties {
      Data = string(description("Base64-url-safe-encoded ([RFC 4648](https://tools.ietf.org/html/rfc4648#section-5))\\ndata to store as secret.\\n\\nThis field is only used to _create_ a secret, and is not returned by\\nother endpoints."), example())
      Driver = components.schemas.Driver
      Templating = components.schemas.Driver
      Name = string(description("User-defined name of the secret."))
      Labels = map(string(), description("User-defined key/value metadata."), example({
        com.example.some-label = "some-value",
        com.example.some-other-label = "some-other-value"
      }))
    }
  }
  components "schemas" "HostConfig" {
    description = "Container configuration that depends on the host we are running on"
    allOf = [components.schemas.Resources, object({
      AutoRemove = boolean(description("Automatically remove the container when the container's process\\nexits. This has no effect if `RestartPolicy` is set.")),
      CgroupnsMode = string(description("cgroup namespace mode for the container. Possible values are:\\n\\n- `\"private\"`: the container runs in its own private cgroup namespace\\n- `\"host\"`: use the host system's cgroup namespace\\n\\nIf not specified, the daemon default is used, which can either be `\"private\"`\\nor `\"host\"`, depending on daemon version, kernel support and configuration."), enum("private", "host")),
      DnsSearch = array(description("A list of DNS search domains."), [string()]),
      PidMode = string(description("Set the PID (Process) Namespace mode for the container. It can be\\neither:\\n\\n- `\"container:<name|id>\"`: joins another container's PID namespace\\n- `\"host\"`: use the host's PID namespace inside the container")),
      UsernsMode = string(description("Sets the usernamespace mode for the container when usernamespace\\nremapping option is enabled.")),
      ReadonlyRootfs = boolean(description("Mount the container's root filesystem as read only.")),
      StorageOpt = map(string(), description("Storage driver options for this container, in the form `{\"size\": \"120G\"}`.")),
      Tmpfs = map(string(), description("A map of container directories which should be replaced by tmpfs\\nmounts, and their corresponding mount options. For example:\\n\\n```\\n{ \"/run\": \"rw,noexec,nosuid,size=65536k\" }\\n```")),
      ContainerIDFile = string(description("Path to a file where the container ID is written")),
      LogConfig = object(description("The logging configuration for this container"), {
        Type = string(enum("json-file", "syslog", "journald", "gelf", "fluentd", "awslogs", "splunk", "etwlogs", "none")),
        Config = map(string())
      }),
      NetworkMode = string(description("Network mode to use for this container. Supported standard values\\nare: `bridge`, `host`, `none`, and `container:<name|id>`. Any\\nother value is taken as a custom network's name to which this\\ncontainer should connect to.")),
      Privileged = boolean(description("Gives the container full access to the host.")),
      PublishAllPorts = boolean(description("Allocates an ephemeral host port for all of a container's\\nexposed ports.\\n\\nPorts are de-allocated when the container stops and allocated when\\nthe container starts. The allocated port might be changed when\\nrestarting the container.\\n\\nThe port is selected from the ephemeral port range that depends on\\nthe kernel. For example, on Linux the range is defined by\\n`/proc/sys/net/ipv4/ip_local_port_range`.")),
      ShmSize = integer(format("int64"), description("Size of `/dev/shm` in bytes. If omitted, the system uses 64MB.")),
      Sysctls = map(string(), description("A list of kernel parameters (sysctls) to set in the container.\\nFor example:\\n\\n```\\n{\"net.ipv4.ip_forward\": \"1\"}\\n```")),
      ReadonlyPaths = array(description("The list of paths to be set as read-only inside the container\\n(this overrides the default set of paths)."), [string()]),
      OomScoreAdj = integer(description("An integer value containing the score given to the container in\\norder to tune OOM killer preferences."), example(500)),
      Mounts = array(description("Specification for mounts to be added to the container."), [components.schemas.Mount]),
      CapAdd = array(description("A list of kernel capabilities to add to the container. Conflicts\\nwith option 'Capabilities'."), [string()]),
      UTSMode = string(description("UTS namespace to use for the container.")),
      Isolation = string(description("Isolation technology of the container. (Windows only)"), enum("default", "process", "hyperv")),
      RestartPolicy = components.schemas.RestartPolicy,
      Dns = array(description("A list of DNS servers for the container to use."), [string()]),
      ExtraHosts = array(description("A list of hostnames/IP mappings to add to the container's `/etc/hosts`\\nfile. Specified in the form `[\"hostname:IP\"]`."), [string()]),
      SecurityOpt = array(description("A list of string values to customize labels for MLS systems, such\\nas SELinux."), [string()]),
      Runtime = string(description("Runtime to use with this container.")),
      DnsOptions = array(description("A list of DNS options."), [string()]),
      GroupAdd = array(description("A list of additional groups that the container process will run as."), [string()]),
      IpcMode = string(description("IPC sharing mode for the container. Possible values are:\\n\\n- `\"none\"`: own private IPC namespace, with /dev/shm not mounted\\n- `\"private\"`: own private IPC namespace\\n- `\"shareable\"`: own private IPC namespace, with a possibility to share it with other containers\\n- `\"container:<name|id>\"`: join another (shareable) container's IPC namespace\\n- `\"host\"`: use the host system's IPC namespace\\n\\nIf not specified, daemon default is used, which can either be `\"private\"`\\nor `\"shareable\"`, depending on daemon version and configuration.")),
      PortBindings = components.schemas.PortMap,
      VolumesFrom = array(description("A list of volumes to inherit from another container, specified in\\nthe form `<container name>[:<ro|rw>]`."), [string()]),
      ConsoleSize = {
        nullable = true,
        type = "array",
        description = "Initial console size, as an `[height, width]` array.",
        minItems = 2,
        maxItems = 2,
        items = [integer()]
      },
      Annotations = map(string(), description("Arbitrary non-identifying metadata attached to container and\\nprovided to the runtime when the container is started.")),
      CapDrop = array(description("A list of kernel capabilities to drop from the container. Conflicts\\nwith option 'Capabilities'."), [string()]),
      Cgroup = string(description("Cgroup to use for the container.")),
      Binds = array(description("A list of volume bindings for this container. Each volume binding\\nis a string in one of these forms:\\n\\n- `host-src:container-dest[:options]` to bind-mount a host path\\n  into the container. Both `host-src`, and `container-dest` must\\n  be an _absolute_ path.\\n- `volume-name:container-dest[:options]` to bind-mount a volume\\n  managed by a volume driver into the container. `container-dest`\\n  must be an _absolute_ path.\\n\\n`options` is an optional, comma-delimited list of:\\n\\n- `nocopy` disables automatic copying of data from the container\\n  path to the volume. The `nocopy` flag only applies to named volumes.\\n- `[ro|rw]` mounts a volume read-only or read-write, respectively.\\n  If omitted or set to `rw`, volumes are mounted read-write.\\n- `[z|Z]` applies SELinux labels to allow or deny multiple containers\\n  to read and write to the same volume.\\n    - `z`: a _shared_ content label is applied to the content. This\\n      label indicates that multiple containers can share the volume\\n      content, for both reading and writing.\\n    - `Z`: a _private unshared_ label is applied to the content.\\n      This label indicates that only the current container can use\\n      a private volume. Labeling systems such as SELinux require\\n      proper labels to be placed on volume content that is mounted\\n      into a container. Without a label, the security system can\\n      prevent a container's processes from using the content. By\\n      default, the labels set by the host operating system are not\\n      modified.\\n- `[[r]shared|[r]slave|[r]private]` specifies mount\\n  [propagation behavior](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt).\\n  This only applies to bind-mounted volumes, not internal volumes\\n  or named volumes. Mount propagation requires the source mount\\n  point (the location where the source directory is mounted in the\\n  host operating system) to have the correct propagation properties.\\n  For shared volumes, the source mount point must be set to `shared`.\\n  For slave volumes, the mount must be set to either `shared` or\\n  `slave`."), [string()]),
      Links = array(description("A list of links for the container in the form `container_name:alias`."), [string()]),
      MaskedPaths = array(description("The list of paths to be masked inside the container (this overrides\\nthe default set of paths)."), [string()]),
      VolumeDriver = string(description("Driver that this container uses to mount volumes."))
    })]
  }
  components "schemas" "PortBinding" {
    type = "object"
    description = "PortBinding represents a binding between a host IP address and a host\\nport."
    properties {
      HostIp = string(description("Host IP address that the container's port is mapped to."), example("127.0.0.1"))
      HostPort = string(description("Host port number that the container's port is mapped to."), example("4443"))
    }
  }
  components "schemas" "ImageSummary" {
    type = "object"
    required = ["Containers", "Created", "Id", "Labels", "ParentId", "RepoDigests", "RepoTags", "SharedSize", "Size"]
    specificationExtension {
      x-go-name = "Summary"
    }
    properties {
      Created = integer(description("Date and time at which the image was created as a Unix timestamp\\n(number of seconds sinds EPOCH)."), example(1644009612))
      SharedSize = integer(format("int64"), description("Total size of image layers that are shared between this image and other\\nimages.\\n\\nThis size is not calculated by default. `-1` indicates that the value\\nhas not been set / calculated."), example(1239828))
      Labels = map(string(), description("User-defined key/value metadata."), example({
        com.example.some-other-label = "some-other-value",
        com.example.some-label = "some-value"
      }))
      ParentId = string(description("ID of the parent image.\\n\\nDepending on how the image was created, this field may be empty and\\nis only set for images that were built/created locally. This field\\nis empty if the image was pulled from an image registry."), example())
      VirtualSize = integer(format("int64"), description("Total size of the image including all layers it is composed of.\\n\\nDeprecated: this field is omitted in API v1.44, but kept for backward compatibility. Use Size instead."), example(172064416))
      Containers = integer(description("Number of containers using this image. Includes both stopped and running\\ncontainers.\\n\\nThis size is not calculated by default, and depends on which API endpoint\\nis used. `-1` indicates that the value has not been set / calculated."), example(2))
      Id = string(description("ID is the content-addressable ID of an image.\\n\\nThis identifier is a content-addressable digest calculated from the\\nimage's configuration (which includes the digests of layers used by\\nthe image).\\n\\nNote that this digest differs from the `RepoDigests` below, which\\nholds digests of image manifests that reference the image."), example("sha256:ec3f0931a6e6b6855d76b2d7b0be30e81860baccd891b2e243280bf1cd8ad710"))
      RepoTags = array(description("List of image names/tags in the local image cache that reference this\\nimage.\\n\\nMultiple image tags can refer to the same image, and this list may be\\nempty if no tags reference the image, in which case the image is\\n\"untagged\", in which case it can still be referenced by its ID."), example(["example:1.0", "example:latest", "example:stable", "internal.registry.example.com:5000/example:1.0"]), [string()])
      RepoDigests = array(description("List of content-addressable digests of locally available image manifests\\nthat the image is referenced from. Multiple manifests can refer to the\\nsame image.\\n\\nThese digests are usually only available if the image was either pulled\\nfrom a registry, or if the image was pushed to a registry, which is when\\nthe manifest is generated and its digest calculated."), example(["example@sha256:afcc7f1ac1b49db317a7196c902e61c6c3c4607d63599ee1a82d702d249a0ccb", "internal.registry.example.com:5000/example@sha256:b69959407d21e8a062e0416bf13405bb2b71ed7a84dde4158ebafacfa06f5578"]), [string()])
      Size = integer(format("int64"), description("Total size of the image including all layers it is composed of."), example(172064416))
    }
  }
  components "schemas" "SwarmSpec" {
    type = "object"
    description = "User modifiable swarm configuration."
    properties {
      Name = string(description("Name of the swarm."), example("default"))
      Labels = map(string(), description("User-defined key/value metadata."), example({
        com.example.corp.department = "engineering",
        com.example.corp.type = "production"
      }))
      Orchestration = {
        type = "object",
        description = "Orchestration configuration.",
        nullable = true,
        properties = {
          TaskHistoryRetentionLimit = integer(format("int64"), description("The number of historic tasks to keep per instance or node. If\\nnegative, never remove completed or failed tasks."), example(10))
        }
      }
      Raft = object(description("Raft configuration."), {
        SnapshotInterval = integer(format("uint64"), description("The number of log entries between snapshots."), example(10000)),
        KeepOldSnapshots = integer(format("uint64"), description("The number of snapshots to keep beyond the current snapshot.")),
        LogEntriesForSlowFollowers = integer(format("uint64"), description("The number of log entries to keep around to sync up slow followers\\nafter a snapshot is created."), example(500)),
        ElectionTick = integer(description("The number of ticks that a follower will wait for a message from\\nthe leader before becoming a candidate and starting an election.\\n`ElectionTick` must be greater than `HeartbeatTick`.\\n\\nA tick currently defaults to one second, so these translate\\ndirectly to seconds currently, but this is NOT guaranteed."), example(3)),
        HeartbeatTick = integer(description("The number of ticks between heartbeats. Every HeartbeatTick ticks,\\nthe leader will send a heartbeat to the followers.\\n\\nA tick currently defaults to one second, so these translate\\ndirectly to seconds currently, but this is NOT guaranteed."), example(1))
      })
      Dispatcher = {
        nullable = true,
        type = "object",
        description = "Dispatcher configuration.",
        properties = {
          HeartbeatPeriod = integer(format("int64"), description("The delay for an agent to send a heartbeat to the dispatcher."), example(5000000000))
        }
      }
      CAConfig = {
        description = "CA configuration.",
        nullable = true,
        type = "object",
        properties = {
          SigningCACert = string(description("The desired signing CA certificate for all swarm node TLS leaf\\ncertificates, in PEM format.")),
          SigningCAKey = string(description("The desired signing CA key for all swarm node TLS leaf certificates,\\nin PEM format.")),
          ForceRotate = integer(format("uint64"), description("An integer whose purpose is to force swarm to generate a new\\nsigning CA certificate and key, if none have been specified in\\n`SigningCACert` and `SigningCAKey`")),
          NodeCertExpiry = integer(format("int64"), description("The duration node certificates are issued for."), example(7776000000000000)),
          ExternalCAs = array(description("Configuration for forwarding signing requests to an external\\ncertificate authority."), [object({
            Protocol = string(description("Protocol for communication with the external CA (currently\\nonly `cfssl` is supported)."), default("cfssl"), enum("cfssl")),
            URL = string(description("URL where certificate signing requests should be sent.")),
            Options = map(string(), description("An object with key/value pairs that are interpreted as\\nprotocol-specific options for the external CA driver.")),
            CACert = string(description("The root CA certificate (in PEM format) this external CA uses\\nto issue TLS certificates (assumed to be to the current swarm\\nroot CA certificate if not provided)."))
          })])
        }
      }
      EncryptionConfig = object(description("Parameters related to encryption-at-rest."), {
        AutoLockManagers = boolean(description("If set, generate a key and use it to lock data stored on the\\nmanagers."), example(false))
      })
      TaskDefaults = object(description("Defaults for creating tasks in this cluster."), {
        LogDriver = object(description("The log driver to use for tasks created in the orchestrator if\\nunspecified by a service.\\n\\nUpdating this value only affects new tasks. Existing tasks continue\\nto use their previously configured log driver until recreated."), {
          Name = string(description("The log driver to use as a default for new tasks."), example("json-file")),
          Options = map(string(), description("Driver-specific options for the selectd log driver, specified\\nas key/value pairs."), example({
            max-file = "10",
            max-size = "100m"
          }))
        })
      })
    }
  }
  components "schemas" "ContainerStatus" {
    type = "object"
    description = "represents the status of a container."
    properties {
      ExitCode = integer()
      ContainerID = string()
      PID = integer()
    }
  }
  components "schemas" "ImageDeleteResponseItem" {
    type = "object"
    specificationExtension {
      x-go-name = "DeleteResponse"
    }
    properties {
      Untagged = string(description("The image ID of an image that was untagged"))
      Deleted = string(description("The image ID of an image that was deleted"))
    }
  }
  components "schemas" "VolumeListResponse" {
    description = "Volume list response"
    title = "VolumeListResponse"
    type = "object"
    specificationExtension {
      x-go-name = "ListResponse"
    }
    properties {
      Volumes = array(description("List of volumes"), [components.schemas.Volume])
      Warnings = array(description("Warnings that occurred when fetching the list of volumes."), example([]), [string()])
    }
  }
  components "schemas" "MountPoint" {
    type = "object"
    description = "MountPoint represents a mount point configuration inside the container.\\nThis is used for reporting the mountpoints in use by a container."
    properties {
      Mode = string(description("Mode is a comma separated list of options supplied by the user when\\ncreating the bind/volume mount.\\n\\nThe default is platform-specific (`\"z\"` on Linux, empty on Windows)."), example("z"))
      RW = boolean(description("Whether the mount is mounted writable (read-write)."), example(true))
      Propagation = string(description("Propagation describes how mounts are propagated from the host into the\\nmount point, and vice-versa. Refer to the [Linux kernel documentation](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt)\\nfor details. This field is not used on Windows."), example())
      Type = string(description("The mount type:\\n\\n- `bind` a mount of a file or directory from the host into the container.\\n- `volume` a docker volume with the given `Name`.\\n- `tmpfs` a `tmpfs`.\\n- `npipe` a named pipe from the host into the container.\\n- `cluster` a Swarm cluster volume"), example("volume"), enum("bind", "volume", "tmpfs", "npipe", "cluster"))
      Name = string(description("Name is the name reference to the underlying data defined by `Source`\\ne.g., the volume name."), example("myvolume"))
      Source = string(description("Source location of the mount.\\n\\nFor volumes, this contains the storage location of the volume (within\\n`/var/lib/docker/volumes/`). For bind-mounts, and `npipe`, this contains\\nthe source (host) part of the bind-mount. For `tmpfs` mount points, this\\nfield is empty."), example("/var/lib/docker/volumes/myvolume/_data"))
      Destination = string(description("Destination is the path relative to the container root (`/`) where\\nthe `Source` is mounted inside the container."), example("/usr/share/nginx/html/"))
      Driver = string(description("Driver is the volume driver used to create the volume (if it is a volume)."), example("local"))
    }
  }
  components "schemas" "SystemInfo" {
    type = "object"
    properties {
      HttpsProxy = string(description("HTTPS-proxy configured for the daemon. This value is obtained from the\\n[`HTTPS_PROXY`](https://www.gnu.org/software/wget/manual/html_node/Proxies.html) environment variable.\\nCredentials ([user info component](https://tools.ietf.org/html/rfc3986#section-3.2.1)) in the proxy URL\\nare masked in the API response.\\n\\nContainers do not automatically inherit this configuration."), example("https://xxxxx:xxxxx@proxy.corp.example.com:4443"))
      ExperimentalBuild = boolean(description("Indicates if experimental features are enabled on the daemon."), example(true))
      Isolation = string(description("Represents the isolation technology to use as a default for containers.\\nThe supported values are platform-specific.\\n\\nIf no isolation value is specified on daemon start, on Windows client,\\nthe default is `hyperv`, and on Windows server, the default is `process`.\\n\\nThis option is currently not used on other platforms."), default("default"), enum("default", "hyperv", "process"))
      InitCommit = components.schemas.Commit
      NCPU = integer(description("The number of logical CPUs usable by the daemon.\\n\\nThe number of available CPUs is checked by querying the operating\\nsystem when the daemon starts. Changes to operating system CPU\\nallocation after the daemon is started are not reflected."), example(4))
      OSVersion = string(description("Version of the host's operating system\\n\\n<p><br /></p>\\n\\n> **Note**: The information returned in this field, including its\\n> very existence, and the formatting of values, should not be considered\\n> stable, and may change without notice."), example("24.04"))
      NFd = integer(description("The total number of file Descriptors in use by the daemon process.\\n\\nThis information is only returned if debug-mode is enabled."), example(64))
      SecurityOptions = array(description("List of security features that are enabled on the daemon, such as\\napparmor, seccomp, SELinux, user-namespaces (userns), rootless and\\nno-new-privileges.\\n\\nAdditional configuration options for each security feature may\\nbe present, and are included as a comma-separated list of key/value\\npairs."), example(["name=apparmor", "name=seccomp,profile=default", "name=selinux", "name=userns", "name=rootless"]), [string()])
      ID = string(description("Unique identifier of the daemon.\\n\\n<p><br /></p>\\n\\n> **Note**: The format of the ID itself is not part of the API, and\\n> should not be considered stable."), example("7TRN:IPZB:QYBB:VPBQ:UMPP:KARE:6ZNR:XE6T:7EWV:PKF4:ZOJD:TPYS"))
      Labels = array(description("User-defined labels (key/value metadata) as set on the daemon.\\n\\n<p><br /></p>\\n\\n> **Note**: When part of a Swarm, nodes can both have _daemon_ labels,\\n> set through the daemon configuration, and _node_ labels, set from a\\n> manager node in the Swarm. Node labels are not included in this\\n> field. Node labels can be retrieved using the `/nodes/(id)` endpoint\\n> on a manager node in the Swarm."), example(["storage=ssd", "production"]), [string()])
      ProductLicense = string(description("Reports a summary of the product license on the daemon.\\n\\nIf a commercial license has been applied to the daemon, information\\nsuch as number of nodes, and expiration are included."), example("Community Engine"))
      IndexServerAddress = string(description("Address / URL of the index server that is used for image search,\\nand as a default for user authentication for Docker Hub and Docker Cloud."), default("https://index.docker.io/v1/"), example("https://index.docker.io/v1/"))
      OperatingSystem = string(description("Name of the host's operating system, for example: \"Ubuntu 24.04 LTS\"\\nor \"Windows Server 2016 Datacenter"), example("Ubuntu 24.04 LTS"))
      Architecture = string(description("Hardware architecture of the host, as returned by the Go runtime\\n(`GOARCH`).\\n\\nA full list of possible values can be found in the [Go documentation](https://go.dev/doc/install/source#environment)."), example("x86_64"))
      KernelMemoryTCP = boolean(description("Indicates if the host has kernel memory TCP limit support enabled. This\\nfield is omitted if not supported.\\n\\nKernel memory TCP limits are not supported when using cgroups v2, which\\ndoes not support the corresponding `memory.kmem.tcp.limit_in_bytes` cgroup."), example(true))
      Runtimes = map(components.schemas.Runtime, description("List of [OCI compliant](https://github.com/opencontainers/runtime-spec)\\nruntimes configured on the daemon. Keys hold the \"name\" used to\\nreference the runtime.\\n\\nThe Docker daemon relies on an OCI compliant runtime (invoked via the\\n`containerd` daemon) as its interface to the Linux kernel namespaces,\\ncgroups, and SELinux.\\n\\nThe default runtime is `runc`, and automatically configured. Additional\\nruntimes can be configured by the user and will be listed here."), example({
        runc = "map[path:runc]",
        runc-master = "map[path:/go/bin/runc]",
        custom = "map[path:/usr/local/bin/my-oci-runtime runtimeArgs:[--debug --systemd-cgroup=false]]"
      }))
      DriverStatus = array(description("Information specific to the storage driver, provided as\\n\"label\" / \"value\" pairs.\\n\\nThis information is provided by the storage driver, and formatted\\nin a way consistent with the output of `docker info` on the command\\nline.\\n\\n<p><br /></p>\\n\\n> **Note**: The information returned in this field, including the\\n> formatting of values and labels, should not be considered stable,\\n> and may change without notice."), example(["[Backing Filesystem extfs]", "[Supports d_type true]", "[Native Overlay Diff true]"]), [array([string()])])
      MemoryLimit = boolean(description("Indicates if the host has memory limit support enabled."), example(true))
      Name = string(description("Hostname of the host."), example("node5.corp.example.com"))
      NoProxy = string(description("Comma-separated list of domain extensions for which no proxy should be\\nused. This value is obtained from the [`NO_PROXY`](https://www.gnu.org/software/wget/manual/html_node/Proxies.html)\\nenvironment variable.\\n\\nContainers do not automatically inherit this configuration."), example("*.local, 169.254/16"))
      CPUShares = boolean(description("Indicates if CPU Shares limiting is supported by the host."), example(true))
      MemTotal = integer(format("int64"), description("Total amount of physical memory available on the host, in bytes."), example(2095882240))
      Images = integer(description("Total number of images on the host.\\n\\nBoth _tagged_ and _untagged_ (dangling) images are counted."), example(508))
      KernelVersion = string(description("Kernel version of the host.\\n\\nOn Linux, this information obtained from `uname`. On Windows this\\ninformation is queried from the <kbd>HKEY_LOCAL_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\</kbd>\\nregistry value, for example _\"10.0 14393 (14393.1198.amd64fre.rs1_release_sec.170427-1353)\"_."), example("6.8.0-31-generic"))
      ContainersRunning = integer(description("Number of containers with status `\"running\"`."), example(3))
      DockerRootDir = string(description("Root directory of persistent Docker state.\\n\\nDefaults to `/var/lib/docker` on Linux, and `C:\\ProgramData\\docker`\\non Windows."), example("/var/lib/docker"))
      CgroupDriver = string(description("The driver to use for managing cgroups."), default("cgroupfs"), example("cgroupfs"), enum("cgroupfs", "systemd", "none"))
      BridgeNfIptables = boolean(description("Indicates if `bridge-nf-call-iptables` is available on the host."), example(true))
      InitBinary = string(description("Name and, optional, path of the `docker-init` binary.\\n\\nIf the path is omitted, the daemon searches the host's `$PATH` for the\\nbinary and uses the first result."), example("docker-init"))
      CDISpecDirs = array(description("List of directories where (Container Device Interface) CDI\\nspecifications are located.\\n\\nThese specifications define vendor-specific modifications to an OCI\\nruntime specification for a container being created.\\n\\nAn empty list indicates that CDI device injection is disabled.\\n\\nNote that since using CDI device injection requires the daemon to have\\nexperimental enabled. For non-experimental daemons an empty list will\\nalways be returned."), example(["/etc/cdi", "/var/run/cdi"]), [string()])
      BridgeNfIp6tables = boolean(description("Indicates if `bridge-nf-call-ip6tables` is available on the host."), example(true))
      Containerd = components.schemas.ContainerdInfo
      Plugins = components.schemas.PluginsInfo
      Driver = string(description("Name of the storage driver in use."), example("overlay2"))
      DefaultAddressPools = array(description("List of custom default address pools for local networks, which can be\\nspecified in the daemon.json file or dockerd option.\\n\\nExample: a Base \"10.10.0.0/16\" with Size 24 will define the set of 256\\n10.10.[0-255].0/24 address pools."), [object({
        Base = string(description("The network address in CIDR format"), example("10.10.0.0/16")),
        Size = integer(description("The network pool size"), example(24))
      })])
      RegistryConfig = components.schemas.RegistryServiceConfig
      RuncCommit = components.schemas.Commit
      CgroupVersion = string(description("The version of the cgroup."), default("1"), example("1"), enum("1", "2"))
      Warnings = array(description("List of warnings / informational messages about missing features, or\\nissues related to the daemon configuration.\\n\\nThese messages can be printed by the client as information to the user."), example(["WARNING: No memory limit support", "WARNING: bridge-nf-call-iptables is disabled", "WARNING: bridge-nf-call-ip6tables is disabled"]), [string()])
      GenericResources = components.schemas.GenericResources
      CPUSet = boolean(description("Indicates if CPUsets (cpuset.cpus, cpuset.mems) are supported by the host.\\n\\nSee [cpuset(7)](https://www.kernel.org/doc/Documentation/cgroup-v1/cpusets.txt)"), example(true))
      NGoroutines = integer(description("The  number of goroutines that currently exist.\\n\\nThis information is only returned if debug-mode is enabled."), example(174))
      LoggingDriver = string(description("The logging driver to use as a default for new containers."))
      LiveRestoreEnabled = boolean(description("Indicates if live restore is enabled.\\n\\nIf enabled, containers are kept running when the daemon is shutdown\\nor upon daemon start if running containers are detected."), default(false), example(false))
      IPv4Forwarding = boolean(description("Indicates IPv4 forwarding is enabled."), example(true))
      Debug = boolean(description("Indicates if the daemon is running in debug-mode / with debug-level\\nlogging enabled."), example(true))
      ContainerdCommit = components.schemas.Commit
      NEventsListener = integer(description("Number of event listeners subscribed."), example(30))
      OomKillDisable = boolean(description("Indicates if OOM killer disable is supported on the host."))
      SystemTime = string(description("Current system-time in [RFC 3339](https://www.ietf.org/rfc/rfc3339.txt)\\nformat with nano-seconds."), example("2017-08-08T20:28:29.06202363Z"))
      Swarm = components.schemas.SwarmInfo
      ContainersPaused = integer(description("Number of containers with status `\"paused\"`."), example(1))
      CpuCfsQuota = boolean(description("Indicates if CPU CFS(Completely Fair Scheduler) quota is supported by\\nthe host."), example(true))
      ContainersStopped = integer(description("Number of containers with status `\"stopped\"`."), example(10))
      SwapLimit = boolean(description("Indicates if the host has memory swap limit support enabled."), example(true))
      HttpProxy = string(description("HTTP-proxy configured for the daemon. This value is obtained from the\\n[`HTTP_PROXY`](https://www.gnu.org/software/wget/manual/html_node/Proxies.html) environment variable.\\nCredentials ([user info component](https://tools.ietf.org/html/rfc3986#section-3.2.1)) in the proxy URL\\nare masked in the API response.\\n\\nContainers do not automatically inherit this configuration."), example("http://xxxxx:xxxxx@proxy.corp.example.com:8080"))
      ServerVersion = string(description("Version string of the daemon."), example("27.0.1"))
      DefaultRuntime = string(description("Name of the default OCI runtime that is used when starting containers.\\n\\nThe default can be overridden per-container at create time."), default("runc"), example("runc"))
      Containers = integer(description("Total number of containers on the host."), example(14))
      PidsLimit = boolean(description("Indicates if the host kernel has PID limit support enabled."), example(true))
      CpuCfsPeriod = boolean(description("Indicates if CPU CFS(Completely Fair Scheduler) period is supported by\\nthe host."), example(true))
      OSType = string(description("Generic type of the operating system of the host, as returned by the\\nGo runtime (`GOOS`).\\n\\nCurrently returned values are \"linux\" and \"windows\". A full list of\\npossible values can be found in the [Go documentation](https://go.dev/doc/install/source#environment)."), example("linux"))
    }
  }
  components "schemas" "Resources" {
    type = "object"
    description = "A container's resources (cgroups config, ulimits, etc)"
    properties {
      BlkioWeight = integer(description("Block IO weight (relative weight)."), maximum(1000))
      CgroupParent = string(description("Path to `cgroups` under which the container's `cgroup` is created. If\\nthe path is not absolute, the path is considered to be relative to the\\n`cgroups` path of the init process. Cgroups are created if they do not\\nalready exist."))
      IOMaximumBandwidth = integer(format("int64"), description("Maximum IO in bytes per second for the container system drive\\n(Windows only)."))
      Memory = integer(format("int64"), description("Memory limit in bytes."), default(0))
      KernelMemoryTCP = integer(format("int64"), description("Hard limit for kernel TCP buffer memory (in bytes). Depending on the\\nOCI runtime in use, this option may be ignored. It is no longer supported\\nby the default (runc) runtime.\\n\\nThis field is omitted when empty."))
      CpuPercent = integer(format("int64"), description("The usable percentage of the available CPUs (Windows only).\\n\\nOn Windows Server containers, the processor resource controls are\\nmutually exclusive. The order of precedence is `CPUCount` first, then\\n`CPUShares`, and `CPUPercent` last."))
      BlkioDeviceReadBps = array(description("Limit read rate (bytes per second) from a device, in the form:\\n\\n```\\n[{\"Path\": \"device_path\", \"Rate\": rate}]\\n```"), [components.schemas.ThrottleDevice])
      BlkioDeviceWriteBps = array(description("Limit write rate (bytes per second) to a device, in the form:\\n\\n```\\n[{\"Path\": \"device_path\", \"Rate\": rate}]\\n```"), [components.schemas.ThrottleDevice])
      BlkioDeviceReadIOps = array(description("Limit read rate (IO per second) from a device, in the form:\\n\\n```\\n[{\"Path\": \"device_path\", \"Rate\": rate}]\\n```"), [components.schemas.ThrottleDevice])
      PidsLimit = {
        nullable = true,
        type = "integer",
        format = "int64",
        description = "Tune a container's PIDs limit. Set `0` or `-1` for unlimited, or `null`\\nto not change."
      }
      MemoryReservation = integer(format("int64"), description("Memory soft limit in bytes."))
      DeviceCgroupRules = array(description("a list of cgroup rules to apply to the container"), [string(example("c 13:* rwm"))])
      DeviceRequests = array(description("A list of requests for devices to be sent to device drivers."), [components.schemas.DeviceRequest])
      MemorySwap = integer(format("int64"), description("Total memory limit (memory + swap). Set as `-1` to enable unlimited\\nswap."))
      BlkioWeightDevice = array(description("Block IO weight (relative device weight) in the form:\\n\\n```\\n[{\"Path\": \"device_path\", \"Weight\": weight}]\\n```"), [object({
        Path = string(),
        Weight = integer()
      })])
      Devices = array(description("A list of devices to add to the container."), [components.schemas.DeviceMapping])
      CpuRealtimePeriod = integer(format("int64"), description("The length of a CPU real-time period in microseconds. Set to 0 to\\nallocate no time allocated to real-time tasks."))
      CpuRealtimeRuntime = integer(format("int64"), description("The length of a CPU real-time runtime in microseconds. Set to 0 to\\nallocate no time allocated to real-time tasks."))
      CpusetMems = string(description("Memory nodes (MEMs) in which to allow execution (0-3, 0,1). Only\\neffective on NUMA systems."))
      CpuCount = integer(format("int64"), description("The number of usable CPUs (Windows only).\\n\\nOn Windows Server containers, the processor resource controls are\\nmutually exclusive. The order of precedence is `CPUCount` first, then\\n`CPUShares`, and `CPUPercent` last."))
      MemorySwappiness = integer(format("int64"), description("Tune a container's memory swappiness behavior. Accepts an integer\\nbetween 0 and 100."), maximum(100))
      CpuQuota = integer(format("int64"), description("Microseconds of CPU time that the container can get in a CPU period."))
      CpusetCpus = string(description("CPUs in which to allow execution (e.g., `0-3`, `0,1`)."), example("0-3"))
      BlkioDeviceWriteIOps = array(description("Limit write rate (IO per second) to a device, in the form:\\n\\n```\\n[{\"Path\": \"device_path\", \"Rate\": rate}]\\n```"), [components.schemas.ThrottleDevice])
      CpuPeriod = integer(format("int64"), description("The length of a CPU period in microseconds."))
      NanoCpus = integer(format("int64"), description("CPU quota in units of 10<sup>-9</sup> CPUs."))
      OomKillDisable = boolean(description("Disable OOM Killer for the container."))
      CpuShares = integer(description("An integer value representing this container's relative CPU weight\\nversus other containers."))
      Init = {
        nullable = true,
        type = "boolean",
        description = "Run an init inside the container that forwards signals and reaps\\nprocesses. This field is omitted if empty, and the default (as\\nconfigured on the daemon) is used."
      }
      Ulimits = array(description("A list of resource limits to set in the container. For example:\\n\\n```\\n{\"Name\": \"nofile\", \"Soft\": 1024, \"Hard\": 2048}\\n```"), [object({
        Soft = integer(description("Soft limit")),
        Hard = integer(description("Hard limit")),
        Name = string(description("Name of ulimit"))
      })])
      IOMaximumIOps = integer(format("int64"), description("Maximum IOps for the container system drive (Windows only)"))
    }
  }
  components "schemas" "GenericResources" {
    type = "array"
    description = "User-defined resources can be either Integer resources (e.g, `SSD=3`) or\\nString resources (e.g, `GPU=UUID1`)."
    example = ["map[DiscreteResourceSpec:map[Kind:SSD Value:3]]", "map[NamedResourceSpec:map[Kind:GPU Value:UUID1]]", "map[NamedResourceSpec:map[Kind:GPU Value:UUID2]]"]
    items = [object({
      NamedResourceSpec = object({
        Kind = string(),
        Value = string()
      }),
      DiscreteResourceSpec = object({
        Value = integer(format("int64")),
        Kind = string()
      })
    })]
  }
  components "schemas" "Network" {
    type = "object"
    properties {
      IPAM = components.schemas.IPAM
      Attachable = boolean(description("Wheter a global / swarm scope network is manually attachable by regular\\ncontainers from workers in swarm mode."), default(false), example(false))
      ConfigFrom = components.schemas.ConfigReference
      Driver = string(description("The name of the driver used to create the network (e.g. `bridge`,\\n`overlay`)."), example("overlay"))
      Internal = boolean(description("Whether the network is created to only allow internal networking\\nconnectivity."), default(false), example(false))
      Ingress = boolean(description("Whether the network is providing the routing-mesh for the swarm cluster."), default(false), example(false))
      ConfigOnly = boolean(description("Whether the network is a config-only network. Config-only networks are\\nplaceholder networks for network configurations to be used by other\\nnetworks. Config-only networks cannot be used directly to run containers\\nor services."), default(false))
      Name = string(description("Name of the network."), example("my_network"))
      EnableIPv6 = boolean(description("Whether the network was created with IPv6 enabled."), example(false))
      Containers = map(components.schemas.NetworkContainer, description("Contains endpoints attached to the network."), example({
        19a4d5d687db25203351ed79d478946f861258f018fe384f229f2efa4b23513c = "map[EndpointID:628cadb8bcb92de107b2a1e516cbffe463e321f548feb37697cce00ad694f21a IPv4Address:172.19.0.2/16 IPv6Address: MacAddress:02:42:ac:13:00:02 Name:test]"
      }))
      Scope = string(description("The level at which the network exists (e.g. `swarm` for cluster-wide\\nor `local` for machine level)"), example("local"))
      Labels = map(string(), description("User-defined key/value metadata."), example({
        com.example.some-label = "some-value",
        com.example.some-other-label = "some-other-value"
      }))
      Peers = {
        description = "List of peer nodes for an overlay network. This field is only present\\nfor overlay networks, and omitted for other network types.",
        items = [components.schemas.PeerInfo],
        nullable = true,
        type = "array"
      }
      Created = string(format("dateTime"), description("Date and time at which the network was created in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds."), example("2016-10-19T04:33:30.360899459Z"))
      Id = string(description("ID that uniquely identifies a network on a single machine."), example("7d86d31b1478e7cca9ebed7e73aa0fdeec46c5ca29497431d3007d2d9e15ed99"))
      Options = map(string(), description("Network-specific options uses when creating the network."), example({
        com.docker.network.bridge.default_bridge = "true",
        com.docker.network.bridge.enable_icc = "true",
        com.docker.network.bridge.enable_ip_masquerade = "true",
        com.docker.network.bridge.host_binding_ipv4 = "0.0.0.0",
        com.docker.network.bridge.name = "docker0",
        com.docker.network.driver.mtu = "1500"
      }))
    }
  }
  components "schemas" "TaskSpec" {
    type = "object"
    description = "User modifiable task configuration."
    properties {
      ForceUpdate = integer(description("A counter that triggers an update even if no relevant parameters have\\nbeen changed."))
      LogDriver = object(description("Specifies the log driver to use for tasks created from this spec. If\\nnot present, the default one for the swarm will be used, finally\\nfalling back to the engine default if not specified."), {
        Name = string(),
        Options = map(string())
      })
      PluginSpec = object(description("Plugin spec for the service.  *(Experimental release only.)*\\n\\n<p><br /></p>\\n\\n> **Note**: ContainerSpec, NetworkAttachmentSpec, and PluginSpec are\\n> mutually exclusive. PluginSpec is only used when the Runtime field\\n> is set to `plugin`. NetworkAttachmentSpec is used when the Runtime\\n> field is set to `attachment`."), {
        Disabled = boolean(description("Disable the plugin once scheduled.")),
        PluginPrivilege = array([components.schemas.PluginPrivilege]),
        Name = string(description("The name or 'alias' to use for the plugin.")),
        Remote = string(description("The plugin image reference to use."))
      })
      Resources = object(description("Resource requirements which apply to each individual container created\\nas part of the service."), {
        Limits = components.schemas.Limit,
        Reservations = components.schemas.ResourceObject
      })
      Runtime = string(description("Runtime is the type of runtime specified for the task executor."))
      RestartPolicy = object(description("Specification for the restart policy which applies to containers\\ncreated as part of this service."), {
        Window = integer(format("int64"), description("Windows is the time window used to evaluate the restart policy\\n(default value is 0, which is unbounded)."), default(0)),
        Condition = string(description("Condition for restart."), enum("none", "on-failure", "any")),
        Delay = integer(format("int64"), description("Delay between restart attempts.")),
        MaxAttempts = integer(format("int64"), description("Maximum attempts to restart a given container before giving up\\n(default value is 0, which is ignored)."), default(0))
      })
      Placement = object({
        Platforms = array(description("Platforms stores all the platforms that the service's image can\\nrun on. This field is used in the platform filter for scheduling.\\nIf empty, then the platform filter is off, meaning there are no\\nscheduling restrictions."), [components.schemas.Platform]),
        Constraints = array(description("An array of constraint expressions to limit the set of nodes where\\na task can be scheduled. Constraint expressions can either use a\\n_match_ (`==`) or _exclude_ (`!=`) rule. Multiple constraints find\\nnodes that satisfy every expression (AND match). Constraints can\\nmatch node or Docker Engine labels as follows:\\n\\nnode attribute       | matches                        | example\\n---------------------|--------------------------------|-----------------------------------------------\\n`node.id`            | Node ID                        | `node.id==2ivku8v2gvtg4`\\n`node.hostname`      | Node hostname                  | `node.hostname!=node-2`\\n`node.role`          | Node role (`manager`/`worker`) | `node.role==manager`\\n`node.platform.os`   | Node operating system          | `node.platform.os==windows`\\n`node.platform.arch` | Node architecture              | `node.platform.arch==x86_64`\\n`node.labels`        | User-defined node labels       | `node.labels.security==high`\\n`engine.labels`      | Docker Engine's labels         | `engine.labels.operatingsystem==ubuntu-24.04`\\n\\n`engine.labels` apply to Docker Engine labels like operating system,\\ndrivers, etc. Swarm administrators add `node.labels` for operational\\npurposes by using the [`node update endpoint`](#operation/NodeUpdate)."), example(["node.hostname!=node3.corp.example.com", "node.role!=manager", "node.labels.type==production", "node.platform.os==linux", "node.platform.arch==x86_64"]), [string()]),
        Preferences = array(description("Preferences provide a way to make the scheduler aware of factors\\nsuch as topology. They are provided in order from highest to\\nlowest precedence."), example(["map[Spread:map[SpreadDescriptor:node.labels.datacenter]]", "map[Spread:map[SpreadDescriptor:node.labels.rack]]"]), [object({
          Spread = object({
            SpreadDescriptor = string(description("label descriptor, such as `engine.labels.az`."))
          })
        })]),
        MaxReplicas = integer(format("int64"), description("Maximum number of replicas for per node (default value is 0, which\\nis unlimited)"), default(0))
      })
      Networks = array(description("Specifies which networks the service should attach to."), [components.schemas.NetworkAttachmentConfig])
      ContainerSpec = object(description("Container spec for the service.\\n\\n<p><br /></p>\\n\\n> **Note**: ContainerSpec, NetworkAttachmentSpec, and PluginSpec are\\n> mutually exclusive. PluginSpec is only used when the Runtime field\\n> is set to `plugin`. NetworkAttachmentSpec is used when the Runtime\\n> field is set to `attachment`."), {
        Hostname = string(description("The hostname to use for the container, as a valid\\n[RFC 1123](https://tools.ietf.org/html/rfc1123) hostname.")),
        Privileges = object(description("Security options for the container"), {
          AppArmor = object(description("Options for configuring AppArmor on the container"), {
            Mode = string(enum("default", "disabled"))
          }),
          NoNewPrivileges = boolean(description("Configuration of the no_new_privs bit in the container")),
          CredentialSpec = object(description("CredentialSpec for managed service account (Windows only)"), {
            Config = string(description("Load credential spec from a Swarm Config with the given ID.\\nThe specified config must also be present in the Configs\\nfield with the Runtime property set.\\n\\n<p><br /></p>\\n\\n\\n> **Note**: `CredentialSpec.File`, `CredentialSpec.Registry`,\\n> and `CredentialSpec.Config` are mutually exclusive."), example("0bt9dmxjvjiqermk6xrop3ekq")),
            File = string(description("Load credential spec from this file. The file is read by\\nthe daemon, and must be present in the `CredentialSpecs`\\nsubdirectory in the docker data directory, which defaults\\nto `C:\\ProgramData\\Docker\\` on Windows.\\n\\nFor example, specifying `spec.json` loads\\n`C:\\ProgramData\\Docker\\CredentialSpecs\\spec.json`.\\n\\n<p><br /></p>\\n\\n> **Note**: `CredentialSpec.File`, `CredentialSpec.Registry`,\\n> and `CredentialSpec.Config` are mutually exclusive."), example("spec.json")),
            Registry = string(description("Load credential spec from this value in the Windows\\nregistry. The specified registry value must be located in:\\n\\n`HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Virtualization\\Containers\\CredentialSpecs`\\n\\n<p><br /></p>\\n\\n\\n> **Note**: `CredentialSpec.File`, `CredentialSpec.Registry`,\\n> and `CredentialSpec.Config` are mutually exclusive."))
          }),
          SELinuxContext = object(description("SELinux labels of the container"), {
            Level = string(description("SELinux level label")),
            Disable = boolean(description("Disable SELinux")),
            User = string(description("SELinux user label")),
            Role = string(description("SELinux role label")),
            Type = string(description("SELinux type label"))
          }),
          Seccomp = object(description("Options for configuring seccomp on the container"), {
            Mode = string(enum("default", "unconfined", "custom")),
            Profile = string(description("The custom seccomp profile as a json object"))
          })
        }),
        StopGracePeriod = integer(format("int64"), description("Amount of time to wait for the container to terminate before\\nforcefully killing it.")),
        DNSConfig = object(description("Specification for DNS related configurations in resolver configuration\\nfile (`resolv.conf`)."), {
          Nameservers = array(description("The IP addresses of the name servers."), [string()]),
          Search = array(description("A search list for host-name lookup."), [string()]),
          Options = array(description("A list of internal resolver variables to be modified (e.g.,\\n`debug`, `ndots:3`, etc.)."), [string()])
        }),
        OomScoreAdj = integer(format("int64"), description("An integer value containing the score given to the container in\\norder to tune OOM killer preferences."), example(0)),
        Isolation = string(description("Isolation technology of the containers running the service.\\n(Windows only)"), enum("default", "process", "hyperv")),
        Ulimits = array(description("A list of resource limits to set in the container. For example: `{\"Name\": \"nofile\", \"Soft\": 1024, \"Hard\": 2048}`"), [object({
          Soft = integer(description("Soft limit")),
          Hard = integer(description("Hard limit")),
          Name = string(description("Name of ulimit"))
        })]),
        Image = string(description("The image name to use for the container")),
        Command = array(description("The command to be run in the image."), [string()]),
        User = string(description("The user inside the container.")),
        Labels = map(string(), description("User-defined key/value data.")),
        CapabilityDrop = array(description("A list of kernel capabilities to drop from the default set\\nfor the container."), example(["CAP_NET_RAW"]), [string()]),
        StopSignal = string(description("Signal to stop the container.")),
        Configs = array(description("Configs contains references to zero or more configs that will be\\nexposed to the service."), [object({
          File = object(description("File represents a specific target that is backed by a file.\\n\\n<p><br /><p>\\n\\n> **Note**: `Configs.File` and `Configs.Runtime` are mutually exclusive"), {
            Name = string(description("Name represents the final filename in the filesystem.")),
            UID = string(description("UID represents the file UID.")),
            GID = string(description("GID represents the file GID.")),
            Mode = integer(format("uint32"), description("Mode represents the FileMode of the file."))
          }),
          Runtime = object(description("Runtime represents a target that is not mounted into the\\ncontainer but is used by the task\\n\\n<p><br /><p>\\n\\n> **Note**: `Configs.File` and `Configs.Runtime` are mutually\\n> exclusive")),
          ConfigID = string(description("ConfigID represents the ID of the specific config that we're\\nreferencing.")),
          ConfigName = string(description("ConfigName is the name of the config that this references,\\nbut this is just provided for lookup/display purposes. The\\nconfig in the reference will be identified by its ID."))
        })]),
        Sysctls = map(string(), description("Set kernel namedspaced parameters (sysctls) in the container.\\nThe Sysctls option on services accepts the same sysctls as the\\nare supported on containers. Note that while the same sysctls are\\nsupported, no guarantees or checks are made about their\\nsuitability for a clustered environment, and it's up to the user\\nto determine whether a given sysctl will work properly in a\\nService.")),
        OpenStdin = boolean(description("Open `stdin`")),
        Mounts = array(description("Specification for mounts to be added to containers created as part\\nof the service."), [components.schemas.Mount]),
        CapabilityAdd = array(description("A list of kernel capabilities to add to the default set\\nfor the container."), example(["CAP_NET_RAW", "CAP_SYS_ADMIN", "CAP_SYS_CHROOT", "CAP_SYSLOG"]), [string()]),
        Env = array(description("A list of environment variables in the form `VAR=value`."), [string()]),
        Dir = string(description("The working directory for commands to run in.")),
        Groups = array(description("A list of additional groups that the container process will run as."), [string()]),
        Secrets = array(description("Secrets contains references to zero or more secrets that will be\\nexposed to the service."), [object({
          File = object(description("File represents a specific target that is backed by a file."), {
            Name = string(description("Name represents the final filename in the filesystem.")),
            UID = string(description("UID represents the file UID.")),
            GID = string(description("GID represents the file GID.")),
            Mode = integer(format("uint32"), description("Mode represents the FileMode of the file."))
          }),
          SecretID = string(description("SecretID represents the ID of the specific secret that we're\\nreferencing.")),
          SecretName = string(description("SecretName is the name of the secret that this references,\\nbut this is just provided for lookup/display purposes. The\\nsecret in the reference will be identified by its ID."))
        })]),
        Init = {
          nullable = true,
          type = "boolean",
          description = "Run an init inside the container that forwards signals and reaps\\nprocesses. This field is omitted if empty, and the default (as\\nconfigured on the daemon) is used."
        },
        Args = array(description("Arguments to the command."), [string()]),
        TTY = boolean(description("Whether a pseudo-TTY should be allocated.")),
        Hosts = array(description("A list of hostname/IP mappings to add to the container's `hosts`\\nfile. The format of extra hosts is specified in the\\n[hosts(5)](http://man7.org/linux/man-pages/man5/hosts.5.html)\\nman page:\\n\\n    IP_address canonical_hostname [aliases...]"), [string()]),
        ReadOnly = boolean(description("Mount the container's root filesystem as read only.")),
        HealthCheck = components.schemas.HealthConfig
      })
      NetworkAttachmentSpec = object(description("Read-only spec type for non-swarm containers attached to swarm overlay\\nnetworks.\\n\\n<p><br /></p>\\n\\n> **Note**: ContainerSpec, NetworkAttachmentSpec, and PluginSpec are\\n> mutually exclusive. PluginSpec is only used when the Runtime field\\n> is set to `plugin`. NetworkAttachmentSpec is used when the Runtime\\n> field is set to `attachment`."), {
        ContainerID = string(description("ID of the container represented by this task"))
      })
    }
  }
  components "schemas" "NetworkingConfig" {
    type = "object"
    description = "NetworkingConfig represents the container's networking configuration for\\neach of its interfaces.\\nIt is used for the networking configs specified in the `docker create`\\nand `docker network connect` commands."
    example = {
      EndpointsConfig = "map[database_nw:map[] isolated_nw:map[Aliases:[server_x server_y] IPAMConfig:map[IPv4Address:172.20.30.33 IPv6Address:2001:db8:abcd::3033 LinkLocalIPs:[169.254.34.68 fe80::3468]] Links:[container_1 container_2] MacAddress:02:42:ac:12:05:02]]"
    }
    properties {
      EndpointsConfig = map(components.schemas.EndpointSettings, description("A mapping of network name to endpoint configuration for that network.\\nThe endpoint configuration can be left empty to connect to that\\nnetwork with no particular endpoint configuration."))
    }
  }
  components "schemas" "Volume" {
    type = "object"
    required = ["Driver", "Labels", "Mountpoint", "Name", "Options", "Scope"]
    properties {
      Labels = map(string(), description("User-defined key/value metadata."), example({
        com.example.some-label = "some-value",
        com.example.some-other-label = "some-other-value"
      }))
      ClusterVolume = components.schemas.ClusterVolume
      UsageData = {
        type = "object",
        description = "Usage details about the volume. This information is used by the\\n`GET /system/df` endpoint, and omitted in other endpoints.",
        required = ["RefCount", "Size"],
        nullable = true,
        specificationExtension = {
          "x-go-name" = "UsageData"
        },
        properties = {
          Size = integer(format("int64"), description("Amount of disk space used by the volume (in bytes). This information\\nis only available for volumes created with the `\"local\"` volume\\ndriver. For volumes created with other volume drivers, this field\\nis set to `-1` (\"not available\")"), default(-1)),
          RefCount = integer(format("int64"), description("The number of containers referencing this volume. This field\\nis set to `-1` if the reference-count is not available."), default(-1))
        }
      }
      Mountpoint = string(description("Mount path of the volume on the host."), example("/var/lib/docker/volumes/tardis"))
      CreatedAt = string(format("dateTime"), description("Date/Time the volume was created."), example("2016-06-07T20:31:11.853781916Z"))
      Status = map(object(), description("Low-level details about the volume, provided by the volume driver.\\nDetails are returned as a map with key/value pairs:\\n`{\"key\":\"value\",\"key2\":\"value2\"}`.\\n\\nThe `Status` field is optional, and is omitted if the volume driver\\ndoes not support this feature."), example({
        hello = "world"
      }))
      Name = string(description("Name of the volume."), example("tardis"))
      Options = map(string(), description("The driver specific options used when creating the volume."), example({
        device = "tmpfs",
        o = "size=100m,uid=1000",
        type = "tmpfs"
      }))
      Driver = string(description("Name of the volume driver used by the volume."), example("custom"))
      Scope = string(description("The level at which the volume exists. Either `global` for cluster-wide,\\nor `local` for machine level."), default("local"), example("local"), enum("local", "global"))
    }
  }
  components "schemas" "PluginInterfaceType" {
    required = ["Capability", "Prefix", "Version"]
    type = "object"
    specificationExtension {
      x-nullable = "false"
    }
    properties {
      Prefix = string()
      Capability = string()
      Version = string()
    }
  }
  components "schemas" "PluginPrivilege" {
    type = "object"
    description = "Describes a permission the user has to accept upon installing\\nthe plugin."
    specificationExtension {
      x-go-name = "PluginPrivilege"
    }
    properties {
      Value = array(example(["host"]), [string()])
      Name = string(example("network"))
      Description = string()
    }
  }
  components "schemas" "NodeStatus" {
    type = "object"
    description = "NodeStatus represents the status of a node.\\n\\nIt provides the current status of the node, as seen by the manager."
    properties {
      State = components.schemas.NodeState
      Message = string(example())
      Addr = string(description("IP address of the node."), example("172.17.0.2"))
    }
  }
  components "schemas" "ServiceUpdateResponse" {
    type = "object"
    example = {
      Warnings = "[unable to pin image doesnotexist:latest to digest: image library/doesnotexist:latest not found]"
    }
    properties {
      Warnings = array(description("Optional warning messages"), [string()])
    }
  }
  components "schemas" "PluginDevice" {
    type = "object"
    required = ["Description", "Name", "Path", "Settable"]
    specificationExtension {
      x-nullable = "false"
    }
    properties {
      Settable = array([string()])
      Path = string(example("/dev/fuse"))
      Name = string()
      Description = string()
    }
  }
  components "schemas" "Node" {
    type = "object"
    properties {
      Description = components.schemas.NodeDescription
      Status = components.schemas.NodeStatus
      ManagerStatus = components.schemas.ManagerStatus
      ID = string(example("24ifsmvkjbyhk"))
      Version = components.schemas.ObjectVersion
      CreatedAt = string(format("dateTime"), description("Date and time at which the node was added to the swarm in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds."), example("2016-08-18T10:44:24.496525531Z"))
      UpdatedAt = string(format("dateTime"), description("Date and time at which the node was last updated in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds."), example("2017-08-09T07:09:37.632105588Z"))
      Spec = components.schemas.NodeSpec
    }
  }
  components "schemas" "ConfigSpec" {
    type = "object"
    properties {
      Templating = components.schemas.Driver
      Name = string(description("User-defined name of the config."))
      Labels = map(string(), description("User-defined key/value metadata."))
      Data = string(description("Base64-url-safe-encoded ([RFC 4648](https://tools.ietf.org/html/rfc4648#section-5))\\nconfig data."))
    }
  }
  components "schemas" "OCIPlatform" {
    type = "object"
    description = "Describes the platform which the image in the manifest runs on, as defined\\nin the [OCI Image Index Specification](https://github.com/opencontainers/image-spec/blob/v1.0.1/image-index.md)."
    specificationExtension {
      x-go-name = "Platform"
    }
    properties {
      architecture = string(description("The CPU architecture, for example `amd64` or `ppc64`."), example("arm"))
      os = string(description("The operating system, for example `linux` or `windows`."), example("windows"))
      os.version = string(description("Optional field specifying the operating system version, for example on\\nWindows `10.0.19041.1165`."), example("10.0.19041.1165"))
      os.features = array(description("Optional field specifying an array of strings, each listing a required\\nOS feature (for example on Windows `win32k`)."), example(["win32k"]), [string()])
      variant = string(description("Optional field specifying a variant of the CPU, for example `v7` to\\nspecify ARMv7 when architecture is `arm`."), example("v7"))
    }
  }
  components "schemas" "ProgressDetail" {
    type = "object"
    properties {
      current = integer()
      total = integer()
    }
  }
  components "schemas" "PluginEnv" {
    required = ["Description", "Name", "Settable", "Value"]
    type = "object"
    specificationExtension {
      x-nullable = "false"
    }
    properties {
      Name = string()
      Description = string()
      Settable = array([string()])
      Value = string()
    }
  }
  components "schemas" "Secret" {
    type = "object"
    properties {
      UpdatedAt = string(format("dateTime"), example("2017-07-20T13:55:28.678958722Z"))
      Spec = components.schemas.SecretSpec
      ID = string(example("blt1owaxmitz71s9v5zh81zun"))
      Version = components.schemas.ObjectVersion
      CreatedAt = string(format("dateTime"), example("2017-07-20T13:55:28.678958722Z"))
    }
  }
  components "schemas" "IPAM" {
    type = "object"
    properties {
      Options = map(string(), description("Driver-specific options, specified as a map."), example({
        foo = "bar"
      }))
      Driver = string(description("Name of the IPAM driver to use."), default("default"), example("default"))
      Config = array(description("List of IPAM configuration options, specified as a map:\\n\\n```\\n{\"Subnet\": <CIDR>, \"IPRange\": <CIDR>, \"Gateway\": <IP address>, \"AuxAddress\": <device_name:IP address>}\\n```"), [components.schemas.IPAMConfig])
    }
  }
  components "schemas" "PushImageInfo" {
    type = "object"
    properties {
      progress = string()
      progressDetail = components.schemas.ProgressDetail
      error = string()
      status = string()
    }
  }
  components "schemas" "NodeDescription" {
    type = "object"
    description = "NodeDescription encapsulates the properties of the Node as reported by the\\nagent."
    properties {
      Platform = components.schemas.Platform
      Resources = components.schemas.ResourceObject
      Engine = components.schemas.EngineDescription
      TLSInfo = components.schemas.TLSInfo
      Hostname = string(example("bf3067039e47"))
    }
  }
  components "schemas" "ContainerCreateResponse" {
    title = "ContainerCreateResponse"
    type = "object"
    description = "OK response to ContainerCreate operation"
    required = ["Id", "Warnings"]
    specificationExtension {
      x-go-name = "CreateResponse"
    }
    properties {
      Warnings = array(description("Warnings encountered when creating the container"), example([]), [string()])
      Id = string(description("The ID of the created container"), example("ede54ee1afda366ab42f824e8a5ffd195155d853ceaec74a927f249ea270c743"))
    }
  }
  components "schemas" "RegistryServiceConfig" {
    nullable = true
    type = "object"
    description = "RegistryServiceConfig stores daemon registry services configuration."
    specificationExtension {
      x-nullable = "true"
    }
    properties {
      Mirrors = array(description("List of registry URLs that act as a mirror for the official\\n(`docker.io`) registry."), example(["https://hub-mirror.corp.example.com:5000/", "https://[2001:db8:a0b:12f0::1]/"]), [string()])
      AllowNondistributableArtifactsCIDRs = array(description("List of IP ranges to which nondistributable artifacts can be pushed,\\nusing the CIDR syntax [RFC 4632](https://tools.ietf.org/html/4632).\\n\\nSome images (for example, Windows base images) contain artifacts\\nwhose distribution is restricted by license. When these images are\\npushed to a registry, restricted artifacts are not included.\\n\\nThis configuration override this behavior, and enables the daemon to\\npush nondistributable artifacts to all registries whose resolved IP\\naddress is within the subnet described by the CIDR syntax.\\n\\nThis option is useful when pushing images containing\\nnondistributable artifacts to a registry on an air-gapped network so\\nhosts on that network can pull the images without connecting to\\nanother server.\\n\\n> **Warning**: Nondistributable artifacts typically have restrictions\\n> on how and where they can be distributed and shared. Only use this\\n> feature to push artifacts to private registries and ensure that you\\n> are in compliance with any terms that cover redistributing\\n> nondistributable artifacts."), example(["::1/128", "127.0.0.0/8"]), [string()])
      AllowNondistributableArtifactsHostnames = array(description("List of registry hostnames to which nondistributable artifacts can be\\npushed, using the format `<hostname>[:<port>]` or `<IP address>[:<port>]`.\\n\\nSome images (for example, Windows base images) contain artifacts\\nwhose distribution is restricted by license. When these images are\\npushed to a registry, restricted artifacts are not included.\\n\\nThis configuration override this behavior for the specified\\nregistries.\\n\\nThis option is useful when pushing images containing\\nnondistributable artifacts to a registry on an air-gapped network so\\nhosts on that network can pull the images without connecting to\\nanother server.\\n\\n> **Warning**: Nondistributable artifacts typically have restrictions\\n> on how and where they can be distributed and shared. Only use this\\n> feature to push artifacts to private registries and ensure that you\\n> are in compliance with any terms that cover redistributing\\n> nondistributable artifacts."), example(["registry.internal.corp.example.com:3000", "[2001:db8:a0b:12f0::1]:443"]), [string()])
      InsecureRegistryCIDRs = array(description("List of IP ranges of insecure registries, using the CIDR syntax\\n([RFC 4632](https://tools.ietf.org/html/4632)). Insecure registries\\naccept un-encrypted (HTTP) and/or untrusted (HTTPS with certificates\\nfrom unknown CAs) communication.\\n\\nBy default, local registries (`127.0.0.0/8`) are configured as\\ninsecure. All other registries are secure. Communicating with an\\ninsecure registry is not possible if the daemon assumes that registry\\nis secure.\\n\\nThis configuration override this behavior, insecure communication with\\nregistries whose resolved IP address is within the subnet described by\\nthe CIDR syntax.\\n\\nRegistries can also be marked insecure by hostname. Those registries\\nare listed under `IndexConfigs` and have their `Secure` field set to\\n`false`.\\n\\n> **Warning**: Using this option can be useful when running a local\\n> registry, but introduces security vulnerabilities. This option\\n> should therefore ONLY be used for testing purposes. For increased\\n> security, users should add their CA to their system's list of trusted\\n> CAs instead of enabling this option."), example(["::1/128", "127.0.0.0/8"]), [string()])
      IndexConfigs = map(components.schemas.IndexInfo, example({
        127.0.0.1:5000 = "map[Mirrors:[] Name:127.0.0.1:5000 Official:false Secure:false]",
        [2001:db8:a0b:12f0::1]:80 = "map[Mirrors:[] Name:[2001:db8:a0b:12f0::1]:80 Official:false Secure:false]",
        docker.io = "map[Mirrors:[https://hub-mirror.corp.example.com:5000/] Name:docker.io Official:true Secure:true]",
        registry.internal.corp.example.com:3000 = "map[Mirrors:[] Name:registry.internal.corp.example.com:3000 Official:false Secure:false]"
      }))
    }
  }
  components "schemas" "ContainerConfig" {
    type = "object"
    description = "Configuration for a container that is portable between hosts."
    properties {
      Domainname = string(description("The domain name to use for the container."))
      ExposedPorts = {
        nullable = true,
        type = "object",
        description = "An object mapping ports to an empty object in the form:\\n\\n`{\"<port>/<tcp|udp|sctp>\": {}}`",
        example = {
          80/tcp = "map[]",
          443/tcp = "map[]"
        },
        additionalProperties = object()
      }
      Cmd = array(description("Command to run specified as a string or an array of strings."), example(["/bin/sh"]), [string()])
      Healthcheck = components.schemas.HealthConfig
      StopTimeout = {
        description = "Timeout to stop a container in seconds.",
        nullable = true,
        type = "integer"
      }
      Volumes = map(object(), description("An object mapping mount point paths inside the container to empty\\nobjects."))
      WorkingDir = string(description("The working directory for commands to run in."), example("/public/"))
      AttachStderr = boolean(description("Whether to attach to `stderr`."), default(true))
      OpenStdin = boolean(description("Open `stdin`"), default(false))
      StdinOnce = boolean(description("Close `stdin` after one attached client disconnects"), default(false))
      StopSignal = {
        example = "SIGTERM",
        nullable = true,
        type = "string",
        description = "Signal to stop a container as a string or unsigned integer."
      }
      OnBuild = {
        nullable = true,
        type = "array",
        description = "`ONBUILD` metadata that were defined in the image's `Dockerfile`.",
        example = [],
        items = [string()]
      }
      Shell = {
        example = ["/bin/sh", "-c"],
        items = [string()],
        nullable = true,
        type = "array",
        description = "Shell for when `RUN`, `CMD`, and `ENTRYPOINT` uses a shell."
      }
      MacAddress = {
        nullable = true,
        type = "string",
        description = "MAC address of the container.\\n\\nDeprecated: this field is deprecated in API v1.44 and up. Use EndpointSettings.MacAddress instead."
      }
      Env = array(description("A list of environment variables to set inside the container in the\\nform `[\"VAR=value\", ...]`. A variable without `=` is removed from the\\nenvironment, rather than to have an empty value."), example(["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"]), [string()])
      Entrypoint = array(description("The entry point for the container as a string or an array of strings.\\n\\nIf the array consists of exactly one empty string (`[\"\"]`) then the\\nentry point is reset to system default (i.e., the entry point used by\\ndocker when there is no `ENTRYPOINT` instruction in the `Dockerfile`)."), example([]), [string()])
      Hostname = string(description("The hostname to use for the container, as a valid RFC 1123 hostname."), example("439f4e91bd1d"))
      Tty = boolean(description("Attach standard streams to a TTY, including `stdin` if it is not closed."), default(false))
      ArgsEscaped = {
        nullable = true,
        type = "boolean",
        description = "Command is already escaped (Windows only)",
        default = false,
        example = false
      }
      AttachStdin = boolean(description("Whether to attach to `stdin`."), default(false))
      NetworkDisabled = {
        nullable = true,
        type = "boolean",
        description = "Disable networking for the container."
      }
      Image = string(description("The name (or reference) of the image to use when creating the container,\\nor which was used when the container was created."), example("example-image:1.0"))
      User = string(description("The user that commands are run as inside the container."))
      AttachStdout = boolean(description("Whether to attach to `stdout`."), default(true))
      Labels = map(string(), description("User-defined key/value metadata."), example({
        com.example.some-label = "some-value",
        com.example.some-other-label = "some-other-value"
      }))
    }
  }
  components "schemas" "IPAMConfig" {
    type = "object"
    properties {
      Subnet = string(example("172.20.0.0/16"))
      IPRange = string(example("172.20.10.0/24"))
      Gateway = string(example("172.20.10.11"))
      AuxiliaryAddresses = map(string())
    }
  }
  components "schemas" "NetworkContainer" {
    type = "object"
    properties {
      IPv6Address = string(example())
      Name = string(example("container_1"))
      EndpointID = string(example("628cadb8bcb92de107b2a1e516cbffe463e321f548feb37697cce00ad694f21a"))
      MacAddress = string(example("02:42:ac:13:00:02"))
      IPv4Address = string(example("172.19.0.2/16"))
    }
  }
  components "schemas" "PeerNode" {
    type = "object"
    description = "Represents a peer-node in the swarm"
    properties {
      Addr = string(description("IP address and ports at which this node can be reached."))
      NodeID = string(description("Unique identifier of for this node in the swarm."))
    }
  }
  components "schemas" "ImageID" {
    example = {
      ID = "sha256:85f05633ddc1c50679be2b16a0479ab6f7637f8884e0cfe0f4d20e1ebb3d6e7c"
    }
    type = "object"
    description = "Image ID or Digest"
    properties {
      ID = string()
    }
  }
  components "schemas" "ClusterInfo" {
    nullable = true
    type = "object"
    description = "ClusterInfo represents information about the swarm as is returned by the\\n\"/info\" endpoint. Join-tokens are not included."
    specificationExtension {
      x-nullable = "true"
    }
    properties {
      ID = string(description("The ID of the swarm."), example("abajmipo7b4xz5ip2nrla6b11"))
      SubnetSize = integer(format("uint32"), description("SubnetSize specifies the subnet size of the networks created from the\\ndefault subnet pool."), example(24), maximum(29))
      TLSInfo = components.schemas.TLSInfo
      RootRotationInProgress = boolean(description("Whether there is currently a root CA rotation in progress for the swarm"), example(false))
      DataPathPort = integer(format("uint32"), description("DataPathPort specifies the data path port number for data traffic.\\nAcceptable port range is 1024 to 49151.\\nIf no port is set or is set to 0, the default port (4789) is used."), example(4789))
      Version = components.schemas.ObjectVersion
      CreatedAt = string(format("dateTime"), description("Date and time at which the swarm was initialised in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds."), example("2016-08-18T10:44:24.496525531Z"))
      UpdatedAt = string(format("dateTime"), description("Date and time at which the swarm was last updated in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds."), example("2017-08-09T07:09:37.632105588Z"))
      Spec = components.schemas.SwarmSpec
      DefaultAddrPool = array(description("Default Address Pool specifies default subnet pools for global scope\\nnetworks."), [string(format("CIDR"), example())])
    }
  }
  components "schemas" "HealthcheckResult" {
    type = "object"
    description = "HealthcheckResult stores information about a single run of a healthcheck probe"
    nullable = true
    specificationExtension {
      x-nullable = "true"
    }
    properties {
      End = string(format("dateTime"), description("Date and time at which this check ended in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds."), example("2020-01-04T10:45:21.364524523Z"))
      ExitCode = integer(description("ExitCode meanings:\\n\\n- `0` healthy\\n- `1` unhealthy\\n- `2` reserved (considered unhealthy)\\n- other values: error running probe"), example(0))
      Output = string(description("Output from last check"))
      Start = string(format("date-time"), description("Date and time at which this check started in\\n[RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) format with nano-seconds."), example("2020-01-04T10:44:24.496525531Z"))
    }
  }
  components "schemas" "NetworkCreateResponse" {
    title = "NetworkCreateResponse"
    type = "object"
    description = "OK response to NetworkCreate operation"
    required = ["Id", "Warning"]
    specificationExtension {
      x-go-name = "CreateResponse"
    }
    properties {
      Id = string(description("The ID of the created network."), example("b5c4fc71e8022147cd25de22b22173de4e3b170134117172eb595cb91b4e7e5d"))
      Warning = string(description("Warnings encountered when creating the container"), example())
    }
  }
  components "schemas" "Swarm" {
    allOf = [components.schemas.ClusterInfo, object({
      JoinTokens = components.schemas.JoinTokens
    })]
  }
  components "schemas" "TaskState" {
    enum = ["new", "allocated", "pending", "assigned", "accepted", "preparing", "ready", "starting", "running", "complete", "shutdown", "failed", "rejected", "remove", "orphaned"]
    type = "string"
  }
  components "schemas" "NetworkAttachmentConfig" {
    description = "Specifies how a service should be attached to a particular network."
    type = "object"
    properties {
      DriverOpts = map(string(), description("Driver attachment options for the network target."))
      Target = string(description("The target network for attachment. Must be a network name or ID."))
      Aliases = array(description("Discoverable alternate names for the service on this network."), [string()])
    }
  }
  components "schemas" "JoinTokens" {
    type = "object"
    description = "JoinTokens contains the tokens workers and managers need to join the swarm."
    properties {
      Manager = string(description("The token managers can use to join the swarm."), example("SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-7p73s1dx5in4tatdymyhg9hu2"))
      Worker = string(description("The token workers can use to join the swarm."), example("SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-1awxwuwd3z9j1z3puu7rcgdbx"))
    }
  }
  components "schemas" "PeerInfo" {
    type = "object"
    description = "PeerInfo represents one peer of an overlay network."
    properties {
      Name = string(description("ID of the peer-node in the Swarm cluster."), example("6869d7c1732b"))
      IP = string(description("IP-address of the peer-node in the Swarm cluster."), example("10.133.77.91"))
    }
  }
  components "schemas" "EndpointSettings" {
    type = "object"
    description = "Configuration for a network endpoint."
    properties {
      Links = array(example(["container_1", "container_2"]), [string()])
      EndpointID = string(description("Unique ID for the service endpoint in a Sandbox."), example("b88f5b905aabf2893f3cbc4ee42d1ea7980bbc0a92e2c8922b1e1795298afb0b"))
      IPAddress = string(description("IPv4 address."), example("172.17.0.4"))
      Aliases = array(example(["server_x", "server_y"]), [string()])
      NetworkID = string(description("Unique ID of the network."), example("08754567f1f40222263eab4102e1c733ae697e8e354aa9cd6e18d7402835292a"))
      IPPrefixLen = integer(description("Mask length of the IPv4 address."), example(16))
      DNSNames = array(description("List of all DNS names an endpoint has on a specific network. This\\nlist is based on the container name, network aliases, container short\\nID, and hostname.\\n\\nThese DNS names are non-fully qualified but can contain several dots.\\nYou can get fully qualified DNS names by appending `.<network-name>`.\\nFor instance, if container name is `my.ctr` and the network is named\\n`testnet`, `DNSNames` will contain `my.ctr` and the FQDN will be\\n`my.ctr.testnet`."), example(["foobar", "server_x", "server_y", "my.ctr"]), [string()])
      IPAMConfig = components.schemas.EndpointIPAMConfig
      GlobalIPv6Address = string(description("Global IPv6 address."), example("2001:db8::5689"))
      IPv6Gateway = string(description("IPv6 gateway address."), example("2001:db8:2::100"))
      GlobalIPv6PrefixLen = integer(format("int64"), description("Mask length of the global IPv6 address."), example(64))
      DriverOpts = {
        example = {
          com.example.some-label = "some-value",
          com.example.some-other-label = "some-other-value"
        },
        additionalProperties = string(),
        nullable = true,
        type = "object",
        description = "DriverOpts is a mapping of driver options and values. These options\\nare passed directly to the driver and are driver specific."
      }
      Gateway = string(description("Gateway address for this network."), example("172.17.0.1"))
      MacAddress = string(description("MAC address for the endpoint on this network. The network driver might ignore this parameter."), example("02:42:ac:11:00:04"))
    }
  }
  components "schemas" "Plugin" {
    type = "object"
    description = "A plugin for the Engine API"
    required = ["Config", "Enabled", "Name", "Settings"]
    properties {
      Config = object(description("The config of a plugin."), required(["Args", "Description", "Documentation", "Entrypoint", "Env", "Interface", "IpcHost", "Linux", "Mounts", "Network", "PidHost", "PropagatedMount", "WorkDir"]), {
        Interface = object(description("The interface between Docker and the plugin"), required(["Socket", "Types"]), {
          Types = array(example(["docker.volumedriver/1.0"]), [components.schemas.PluginInterfaceType]),
          Socket = string(example("plugins.sock")),
          ProtocolScheme = string(description("Protocol to use for clients connecting to the plugin."), example("some.protocol/v1.0"), enum(, "moby.plugins.http/v1"))
        }),
        PropagatedMount = string(example("/mnt/volumes")),
        PidHost = boolean(example(false)),
        Args = object(required(["Description", "Name", "Settable", "Value"]), {
          Name = string(example("args")),
          Description = string(example("command line arguments")),
          Settable = array([string()]),
          Value = array([string()])
        }),
        Documentation = string(example("https://docs.docker.com/engine/extend/plugins/")),
        Entrypoint = array(example(["/usr/bin/sample-volume-plugin", "/data"]), [string()]),
        WorkDir = string(example("/bin/")),
        Network = object(required(["Type"]), {
          Type = string(example("host"))
        }),
        Env = array(example(["map[Description:If set, prints debug messages Name:DEBUG Value:0]"]), [components.schemas.PluginEnv]),
        Description = string(example("A sample volume plugin for Docker")),
        Linux = object(required(["AllowAllDevices", "Capabilities", "Devices"]), {
          Capabilities = array(example(["CAP_SYS_ADMIN", "CAP_SYSLOG"]), [string()]),
          AllowAllDevices = boolean(example(false)),
          Devices = array([components.schemas.PluginDevice])
        }),
        Mounts = array([components.schemas.PluginMount]),
        rootfs = object({
          type = string(example("layers")),
          diff_ids = array(example(["sha256:675532206fbf3030b8458f88d6e26d4eb1577688a25efec97154c94e8b6b4887", "sha256:e216a057b1cb1efc11f8a268f37ef62083e70b1b38323ba252e25ac88904a7e8"]), [string()])
        }),
        DockerVersion = string(description("Docker Version used to create the plugin"), example("17.06.0-ce")),
        User = object({
          GID = integer(format("uint32"), example(1000)),
          UID = integer(format("uint32"), example(1000))
        }),
        IpcHost = boolean(example(false))
      })
      Id = string(example("5724e2c8652da337ab2eedd19fc6fc0ec908e4bd907c7421bf6a8dfc70c4c078"))
      Name = string(example("tiborvass/sample-volume-plugin"))
      Enabled = boolean(description("True if the plugin is running. False if the plugin is not running, only installed."), example(true))
      Settings = object(description("Settings that can be modified by users."), required(["Args", "Devices", "Env", "Mounts"]), {
        Args = array([string()]),
        Devices = array([components.schemas.PluginDevice]),
        Mounts = array([components.schemas.PluginMount]),
        Env = array(example(["DEBUG=0"]), [string()])
      })
      PluginReference = string(description("plugin remote reference used to push/pull the plugin"), example("localhost:5000/tiborvass/sample-volume-plugin:latest"))
    }
  }
  components "schemas" "PluginsInfo" {
    type = "object"
    description = "Available plugins per type.\\n\\n<p><br /></p>\\n\\n> **Note**: Only unmanaged (V1) plugins are included in this list.\\n> V1 plugins are \"lazily\" loaded, and are not returned in this list\\n> if there is no resource using the plugin."
    properties {
      Log = array(description("Names of available logging-drivers, and logging-driver plugins."), example(["awslogs", "fluentd", "gcplogs", "gelf", "journald", "json-file", "splunk", "syslog"]), [string()])
      Volume = array(description("Names of available volume-drivers, and network-driver plugins."), example(["local"]), [string()])
      Network = array(description("Names of available network-drivers, and network-driver plugins."), example(["bridge", "host", "ipvlan", "macvlan", "null", "overlay"]), [string()])
      Authorization = array(description("Names of available authorization plugins."), example(["img-authz-plugin", "hbm"]), [string()])
    }
  }
  components "schemas" "HealthConfig" {
    type = "object"
    description = "A test to perform to check that the container is healthy."
    properties {
      Timeout = integer(format("int64"), description("The time to wait before considering the check to have hung. It should\\nbe 0 or at least 1000000 (1 ms). 0 means inherit."))
      Retries = integer(description("The number of consecutive failures needed to consider a container as\\nunhealthy. 0 means inherit."))
      StartPeriod = integer(format("int64"), description("Start period for the container to initialize before starting\\nhealth-retries countdown in nanoseconds. It should be 0 or at least\\n1000000 (1 ms). 0 means inherit."))
      StartInterval = integer(format("int64"), description("The time to wait between checks in nanoseconds during the start period.\\nIt should be 0 or at least 1000000 (1 ms). 0 means inherit."))
      Test = array(description("The test to perform. Possible values are:\\n\\n- `[]` inherit healthcheck from image or parent image\\n- `[\"NONE\"]` disable healthcheck\\n- `[\"CMD\", args...]` exec arguments directly\\n- `[\"CMD-SHELL\", command]` run command with system's default shell"), [string()])
      Interval = integer(format("int64"), description("The time to wait between checks in nanoseconds. It should be 0 or at\\nleast 1000000 (1 ms). 0 means inherit."))
    }
  }
  components "schemas" "Driver" {
    type = "object"
    description = "Driver represents a driver (network, logging, secrets)."
    required = ["Name"]
    properties {
      Options = map(string(), description("Key/value map of driver-specific options."), example({
        OptionA = "value for driver-specific option A",
        OptionB = "value for driver-specific option B"
      }))
      Name = string(description("Name of the driver."), example("some-driver"))
    }
  }
  components "schemas" "EventMessage" {
    type = "object"
    description = "EventMessage represents the information an event contains."
    title = "SystemEventsResponse"
    properties {
      Type = string(description("The type of object emitting the event"), example("container"), enum("builder", "config", "container", "daemon", "image", "network", "node", "plugin", "secret", "service", "volume"))
      Action = string(description("The type of event"), example("create"))
      Actor = components.schemas.EventActor
      scope = string(description("Scope of the event. Engine events are `local` scope. Cluster (Swarm)\\nevents are `swarm` scope."), enum("local", "swarm"))
      time = integer(format("int64"), description("Timestamp of event"), example(1629574695))
      timeNano = integer(format("int64"), description("Timestamp of event, with nanosecond accuracy"), example(1629574695515049984))
    }
  }
  components "schemas" "Address" {
    type = "object"
    description = "Address represents an IPv4 or IPv6 IP address."
    properties {
      Addr = string(description("IP address."))
      PrefixLen = integer(description("Mask length of the IP address."))
    }
  }
  components "schemas" "ErrorResponse" {
    description = "Represents an error."
    example = {
      message = "Something went wrong."
    }
    required = ["message"]
    type = "object"
    properties {
      message = string(description("The error message."))
    }
  }
  components "schemas" "EndpointSpec" {
    type = "object"
    description = "Properties that can be configured to access and load balance a service."
    properties {
      Mode = string(description("The mode of resolution to use for internal load balancing between tasks."), default("vip"), enum("vip", "dnsrr"))
      Ports = array(description("List of exposed ports that this service is accessible on from the\\noutside. Ports can only be provided if `vip` resolution mode is used."), [components.schemas.EndpointPortConfig])
    }
  }
  components "schemas" "ServiceCreateResponse" {
    type = "object"
    description = "contains the information returned to a client on the\\ncreation of a new service."
    properties {
      ID = string(description("The ID of the created service."), example("ak7w3gjqoa3kuz8xcpnyy0pvl"))
      Warnings = {
        type = "array",
        description = "Optional warning message.\\n\\nFIXME(thaJeztah): this should have \"omitempty\" in the generated type.",
        example = ["unable to pin image doesnotexist:latest to digest: image library/doesnotexist:latest not found"],
        items = [string()],
        nullable = true
      }
    }
  }
  components "schemas" "EventActor" {
    type = "object"
    description = "Actor describes something that generates events, like a container, network,\\nor a volume."
    properties {
      Attributes = map(string(), description("Various key/value attributes of the object, depending on its type."), example({
        image = "alpine:latest",
        name = "my-container",
        com.example.some-label = "some-label-value"
      }))
      ID = string(description("The ID of the object emitting the event"), example("ede54ee1afda366ab42f824e8a5ffd195155d853ceaec74a927f249ea270c743"))
    }
  }
  components "schemas" "ConfigReference" {
    type = "object"
    description = "The config-only network source to provide the configuration for\\nthis network."
    properties {
      Network = string(description("The name of the config-only network that provides the network's\\nconfiguration. The specified network must be an existing config-only\\nnetwork. Only network names are allowed, not network IDs."), example("config_only_network_01"))
    }
  }
  components "schemas" "ErrorDetail" {
    type = "object"
    properties {
      code = integer()
      message = string()
    }
  }
  components "schemas" "EndpointIPAMConfig" {
    nullable = true
    type = "object"
    description = "EndpointIPAMConfig represents an endpoint's IPAM configuration."
    specificationExtension {
      x-nullable = "true"
    }
    properties {
      IPv6Address = string(example("2001:db8:abcd::3033"))
      LinkLocalIPs = array(example(["169.254.34.68", "fe80::3468"]), [string()])
      IPv4Address = string(example("172.20.30.33"))
    }
  }
  components "schemas" "PluginMount" {
    type = "object"
    required = ["Description", "Destination", "Name", "Options", "Settable", "Source", "Type"]
    specificationExtension {
      x-nullable = "false"
    }
    properties {
      Type = string(example("bind"))
      Options = array(example(["rbind", "rw"]), [string()])
      Name = string(example("some-mount"))
      Description = string(example("This is a mount that's used by the plugin."))
      Settable = array([string()])
      Source = string(example("/var/lib/docker/plugins/"))
      Destination = string(example("/mnt/state"))
    }
  }
  components "schemas" "ObjectVersion" {
    type = "object"
    description = "The version number of the object such as node, service, etc. This is needed\\nto avoid conflicting writes. The client must send the version number along\\nwith the modified specification when updating these objects.\\n\\nThis approach ensures safe concurrency and determinism in that the change\\non the object may not be applied if the version number has changed from the\\nlast read. In other words, if two update requests specify the same base\\nversion, only one of the requests can succeed. As a result, two separate\\nupdate requests that happen at the same time will not unintentionally\\noverwrite each other."
    properties {
      Index = integer(format("uint64"), example(373531))
    }
  }
  components "schemas" "EngineDescription" {
    type = "object"
    description = "EngineDescription provides information about an engine."
    properties {
      Plugins = array(example(["map[Name:awslogs Type:Log]", "map[Name:fluentd Type:Log]", "map[Name:gcplogs Type:Log]", "map[Name:gelf Type:Log]", "map[Name:journald Type:Log]", "map[Name:json-file Type:Log]", "map[Name:splunk Type:Log]", "map[Name:syslog Type:Log]", "map[Name:bridge Type:Network]", "map[Name:host Type:Network]", "map[Name:ipvlan Type:Network]", "map[Name:macvlan Type:Network]", "map[Name:null Type:Network]", "map[Name:overlay Type:Network]", "map[Name:local Type:Volume]", "map[Name:localhost:5000/vieux/sshfs:latest Type:Volume]", "map[Name:vieux/sshfs:latest Type:Volume]"]), [object({
        Name = string(),
        Type = string()
      })])
      EngineVersion = string(example("17.06.0"))
      Labels = map(string(), example({
        foo = "bar"
      }))
    }
  }
  specificationExtension {
    x-original-swagger-version = "2.0"
  }
