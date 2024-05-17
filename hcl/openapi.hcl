
  openapi = "3.0.2"
  servers = [{
    url = "/api/v3"
  }]
  info {
    termsOfService = "http://swagger.io/terms/"
    version = "1.0.19"
    title = "Swagger Petstore - OpenAPI 3.0"
    description = "This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about
Swagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!
You can now help us improve the API whether it's by making changes to the definition itself or to the code.
That way, with time, we can improve the API in general, and expose some of the new features in OAS3.

Some useful links:
- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)
- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)"
    contact {
      email = "apiteam@swagger.io"
    }
    license {
      name = "Apache 2.0"
      url = "http://www.apache.org/licenses/LICENSE-2.0.html"
    }
  }
  tags "pet" {
    description = "Everything about your Pets"
    externalDocs {
      url = "http://swagger.io"
      description = "Find out more"
    }
  }
  tags "store" {
    description = "Access to Petstore orders"
    externalDocs {
      url = "http://swagger.io"
      description = "Find out more about our store"
    }
  }
  tags "user" {
    description = "Operations about user"
  }
  externalDocs {
    url = "http://swagger.io"
    description = "Find out more about Swagger"
  }
  pathItem "/store/inventory" "get" {
    description = "Returns a map of status codes to quantities"
    operationId = "getInventory"
    summary = "Returns pet inventories by status"
    tags = ["store"]
    security = [{
      api_key = []
    }]
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = map(integer("int32"))
      }
    }
  }
  pathItem "/store/order/{orderId}" "get" {
    summary = "Find purchase order by ID"
    description = "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions."
    operationId = "getOrderById"
    tags = ["store"]
    parameter "orderId" {
      description = "ID of order that needs to be fetched"
      schema = integer("int64")
      required = true
      in = "path"
    }
    response "404" {
      description = "Order not found"
    }
    response "200" {
      description = "successful operation"
      content "application/xml" {
        schema = #.
      }
      content "application/json" {
        schema = #.
      }
    }
    response "400" {
      description = "Invalid ID supplied"
    }
  }
  pathItem "/store/order/{orderId}" "delete" {
    summary = "Delete purchase order by ID"
    description = "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
    operationId = "deleteOrder"
    tags = ["store"]
    parameter "orderId" {
      in = "path"
      description = "ID of the order that needs to be deleted"
      schema = integer("int64")
      required = true
    }
    response "404" {
      description = "Order not found"
    }
    response "400" {
      description = "Invalid ID supplied"
    }
  }
  pathItem "/user/login" "get" {
    operationId = "loginUser"
    summary = "Logs user into the system"
    tags = ["user"]
    parameter "username" {
      in = "query"
      description = "The user name for login"
      schema = string()
    }
    parameter "password" {
      description = "The password for login in clear text"
      schema = string()
      in = "query"
    }
    response "200" {
      description = "successful operation"
      content "application/xml" {
        schema = string()
      }
      content "application/json" {
        schema = string()
      }
      header "X-Rate-Limit" {
        description = "calls per hour allowed by the user"
        schema = integer("int32")
      }
      header "X-Expires-After" {
        description = "date in UTC when token expires"
        schema = string("date-time")
      }
    }
    response "400" {
      description = "Invalid username/password supplied"
    }
  }
  pathItem "/user/{username}" "put" {
    summary = "Update user"
    description = "This can only be done by the logged in user."
    operationId = "updateUser"
    tags = ["user"]
    parameter "username" {
      required = true
      in = "path"
      description = "name that needs to be updated"
      schema = string()
    }
    requestBody {
      description = "Update an existent user in the store"
      content "application/xml" {
        schema = #.
      }
      content "application/x-www-form-urlencoded" {
        schema = #.
      }
      content "application/json" {
        schema = #.
      }
    }
    response "default" {
      description = "successful operation"
    }
  }
  pathItem "/user/{username}" "delete" {
    description = "This can only be done by the logged in user."
    tags = ["user"]
    operationId = "deleteUser"
    summary = "Delete user"
    parameter "username" {
      required = true
      in = "path"
      description = "The name that needs to be deleted"
      schema = string()
    }
    response "400" {
      description = "Invalid username supplied"
    }
    response "404" {
      description = "User not found"
    }
  }
  pathItem "/user/{username}" "get" {
    operationId = "getUserByName"
    summary = "Get user by user name"
    tags = ["user"]
    parameter "username" {
      required = true
      in = "path"
      description = "The name that needs to be fetched. Use user1 for testing. "
      schema = string()
    }
    response "200" {
      description = "successful operation"
      content "application/xml" {
        schema = #.
      }
      content "application/json" {
        schema = #.
      }
    }
    response "400" {
      description = "Invalid username supplied"
    }
    response "404" {
      description = "User not found"
    }
  }
  pathItem "/pet/findByTags" "get" {
    summary = "Finds Pets by tags"
    description = "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."
    operationId = "findPetsByTags"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameter "tags" {
      explode = true
      in = "query"
      description = "Tags to filter by"
      schema = array([string()])
    }
    response "400" {
      description = "Invalid tag value"
    }
    response "200" {
      description = "successful operation"
      content "application/xml" {
        schema = array([#.])
      }
      content "application/json" {
        schema = array([#.])
      }
    }
  }
  pathItem "/pet/{petId}/uploadImage" "post" {
    summary = "uploads an image"
    operationId = "uploadFile"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameter "petId" {
      schema = integer("int64")
      required = true
      in = "path"
      description = "ID of pet to update"
    }
    parameter "additionalMetadata" {
      schema = string()
      in = "query"
      description = "Additional Metadata"
    }
    requestBody {
      content "application/octet-stream" {
        schema = string("binary")
      }
    }
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = #.
      }
    }
  }
  pathItem "/store/order" "post" {
    tags = ["store"]
    summary = "Place an order for a pet"
    description = "Place a new order in the store"
    operationId = "placeOrder"
    requestBody {
      content "application/json" {
        schema = #.
      }
      content "application/xml" {
        schema = #.
      }
      content "application/x-www-form-urlencoded" {
        schema = #.
      }
    }
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = #.
      }
    }
    response "405" {
      description = "Invalid input"
    }
  }
  pathItem "/user/logout" "get" {
    operationId = "logoutUser"
    summary = "Logs out current logged in user session"
    tags = ["user"]
    response "default" {
      description = "successful operation"
    }
  }
  pathItem "/pet" "put" {
    description = "Update an existing pet by Id"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    operationId = "updatePet"
    summary = "Update an existing pet"
    requestBody {
      description = "Update an existent pet in the store"
      required = true
      content "application/json" {
        schema = #.
      }
      content "application/xml" {
        schema = #.
      }
      content "application/x-www-form-urlencoded" {
        schema = #.
      }
    }
    response "404" {
      description = "Pet not found"
    }
    response "405" {
      description = "Validation exception"
    }
    response "200" {
      description = "Successful operation"
      content "application/xml" {
        schema = #.
      }
      content "application/json" {
        schema = #.
      }
    }
    response "400" {
      description = "Invalid ID supplied"
    }
  }
  pathItem "/pet" "post" {
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Add a new pet to the store"
    description = "Add a new pet to the store"
    operationId = "addPet"
    tags = ["pet"]
    requestBody {
      description = "Create a new pet in the store"
      required = true
      content "application/json" {
        schema = #.
      }
      content "application/xml" {
        schema = #.
      }
      content "application/x-www-form-urlencoded" {
        schema = #.
      }
    }
    response "200" {
      description = "Successful operation"
      content "application/xml" {
        schema = #.
      }
      content "application/json" {
        schema = #.
      }
    }
    response "405" {
      description = "Invalid input"
    }
  }
  pathItem "/pet/findByStatus" "get" {
    summary = "Finds Pets by status"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    description = "Multiple status values can be provided with comma separated strings"
    operationId = "findPetsByStatus"
    parameter "status" {
      description = "Status values that need to be considered for filter"
      schema = string(, "available", ["available", "pending", "sold"])
      explode = true
      in = "query"
    }
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = array([#.])
      }
      content "application/xml" {
        schema = array([#.])
      }
    }
    response "400" {
      description = "Invalid status value"
    }
  }
  pathItem "/pet/{petId}" "get" {
    tags = ["pet"]
    security = [{
      api_key = []
    }, {
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Find pet by ID"
    description = "Returns a single pet"
    operationId = "getPetById"
    parameter "petId" {
      required = true
      in = "path"
      description = "ID of pet to return"
      schema = integer("int64")
    }
    response "400" {
      description = "Invalid ID supplied"
    }
    response "404" {
      description = "Pet not found"
    }
    response "200" {
      description = "successful operation"
      content "application/xml" {
        schema = #.
      }
      content "application/json" {
        schema = #.
      }
    }
  }
  pathItem "/pet/{petId}" "post" {
    summary = "Updates a pet in the store with form data"
    operationId = "updatePetWithForm"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameter "petId" {
      required = true
      in = "path"
      description = "ID of pet that needs to be updated"
      schema = integer("int64")
    }
    parameter "name" {
      in = "query"
      description = "Name of pet that needs to be updated"
      schema = string()
    }
    parameter "status" {
      in = "query"
      description = "Status of pet that needs to be updated"
      schema = string()
    }
    response "405" {
      description = "Invalid input"
    }
  }
  pathItem "/pet/{petId}" "delete" {
    summary = "Deletes a pet"
    operationId = "deletePet"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameter "petId" {
      schema = integer("int64")
      required = true
      in = "path"
      description = "Pet id to delete"
    }
    parameter "api_key" {
      in = "header"
      schema = string()
    }
    response "400" {
      description = "Invalid pet value"
    }
  }
  pathItem "/user" "post" {
    summary = "Create user"
    description = "This can only be done by the logged in user."
    operationId = "createUser"
    tags = ["user"]
    requestBody {
      description = "Created user object"
      content "application/json" {
        schema = #.
      }
      content "application/xml" {
        schema = #.
      }
      content "application/x-www-form-urlencoded" {
        schema = #.
      }
    }
    response "default" {
      description = "successful operation"
      content "application/json" {
        schema = #.
      }
      content "application/xml" {
        schema = #.
      }
    }
  }
  pathItem "/user/createWithList" "post" {
    tags = ["user"]
    summary = "Creates list of users with given input array"
    description = "Creates list of users with given input array"
    operationId = "createUsersWithListInput"
    requestBody {
      content "application/json" {
        schema = array([#.])
      }
    }
    response "200" {
      description = "Successful operation"
      content "application/xml" {
        schema = #.
      }
      content "application/json" {
        schema = #.
      }
    }
    response "default" {
      description = "successful operation"
    }
  }
  components {
    schema "User" {
      type = "object"
      xml {
        name = "user"
      }
      properties {
        email = string()
        password = string()
        phone = string()
        id = integer("int64")
        username = string()
        firstName = string()
        lastName = string()
        userStatus {
          format = "int32"
          type = "integer"
          example = any()
        }
      }
    }
    schema "Tag" {
      type = "object"
      xml {
        name = "tag"
      }
      properties {
        name = string()
        id = integer("int64")
      }
    }
    schema "Pet" {
      type = "object"
      xml {
        name = "pet"
      }
      properties {
        id = integer("int64")
        name = string()
        category = #.
        photoUrls {
          items = [{
            type = "string",
            xml = {
              name = "photoUrl"
            }
          }]
          type = "array"
          xml {
            wrapped = true
          }
        }
        tags {
          type = "array"
          items = [#.]
          xml {
            wrapped = true
          }
        }
        status {
          type = "string"
          enum = [, , ]
        }
      }
    }
    schema "ApiResponse" {
      type = "object"
      xml {
        name = "##default"
      }
      properties {
        code = integer("int32")
        type = string()
        message = string()
      }
    }
    schema "Order" {
      type = "object"
      xml {
        name = "order"
      }
      properties {
        id = integer("int64")
        petId = integer("int64")
        quantity = integer("int32")
        shipDate = string("date-time")
        complete = boolean()
        status {
          type = "string"
          enum = [, , ]
          example = any()
        }
      }
    }
    schema "Customer" {
      type = "object"
      xml {
        name = "customer"
      }
      properties {
        id = integer("int64")
        username = string()
        address {
          type = "array"
          items = [#.]
          xml {
            name = "addresses"
            wrapped = true
          }
        }
      }
    }
    schema "Address" {
      type = "object"
      xml {
        name = "address"
      }
      properties {
        city = string()
        state = string()
        zip = string()
        street = string()
      }
    }
    schema "Category" {
      type = "object"
      xml {
        name = "category"
      }
      properties {
        id = integer("int64")
        name = string()
      }
    }
    requestBody "Pet" {
      description = "Pet object that needs to be added to the store"
      content "application/json" {
        schema = #.
      }
      content "application/xml" {
        schema = #.
      }
    }
    requestBody "UserArray" {
      description = "List of user object"
      content "application/json" {
        schema = array([#.])
      }
    }
    securityScheme "api_key" {
      in = "header"
      type = "apiKey"
      name = "api_key"
    }
    securityScheme "petstore_auth" {
      type = "oauth2"
      flows {
        implicit {
          authorizationUrl = "https://petstore3.swagger.io/oauth/authorize"
          scopes {
            write:pets = "modify pets in your account"
            read:pets = "read your pets"
          }
        }
      }
    }
  }
