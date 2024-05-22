
  openapi = "3.0.2"
  servers = [{
    url = "/api/v3"
  }]
  info {
    version = "1.0.19"
    title = "Swagger Petstore - OpenAPI 3.0"
    description = "This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about
Swagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!
You can now help us improve the API whether it's by making changes to the definition itself or to the code.
That way, with time, we can improve the API in general, and expose some of the new features in OAS3.

Some useful links:
- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)
- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)"
    termsOfService = "http://swagger.io/terms/"
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
      description = "Find out more"
      url = "http://swagger.io"
    }
  }
  tags "store" {
    description = "Access to Petstore orders"
    externalDocs {
      description = "Find out more about our store"
      url = "http://swagger.io"
    }
  }
  tags "user" {
    description = "Operations about user"
  }
  externalDocs {
    description = "Find out more about Swagger"
    url = "http://swagger.io"
  }
  pathItem "/store/inventory" "get" {
    operationId = "getInventory"
    summary = "Returns pet inventories by status"
    description = "Returns a map of status codes to quantities"
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
  pathItem "/store/order" "post" {
    summary = "Place an order for a pet"
    description = "Place a new order in the store"
    operationId = "placeOrder"
    tags = ["store"]
    requestBody {
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
    response "405" {
      description = "Invalid input"
    }
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = #.
      }
    }
  }
  pathItem "/store/order/{orderId}" "get" {
    tags = ["store"]
    description = "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions."
    operationId = "getOrderById"
    summary = "Find purchase order by ID"
    parameter "orderId" {
      in = "path"
      description = "ID of order that needs to be fetched"
      schema = integer("int64")
      required = true
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
      required = true
      in = "path"
      description = "ID of the order that needs to be deleted"
      schema = integer("int64")
    }
    response "400" {
      description = "Invalid ID supplied"
    }
    response "404" {
      description = "Order not found"
    }
  }
  pathItem "/user/createWithList" "post" {
    summary = "Creates list of users with given input array"
    description = "Creates list of users with given input array"
    operationId = "createUsersWithListInput"
    tags = ["user"]
    requestBody {
      content "application/json" {
        schema = array([#.])
      }
    }
    response "200" {
      description = "Successful operation"
      content "application/json" {
        schema = #.
      }
      content "application/xml" {
        schema = #.
      }
    }
    response "default" {
      description = "successful operation"
    }
  }
  pathItem "/user/login" "get" {
    operationId = "loginUser"
    tags = ["user"]
    summary = "Logs user into the system"
    parameter "username" {
      in = "query"
      description = "The user name for login"
      schema = string()
    }
    parameter "password" {
      in = "query"
      description = "The password for login in clear text"
      schema = string()
    }
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = string()
      }
      content "application/xml" {
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
    response "200" {
      description = "successful operation"
      content "application/xml" {
        schema = array([#.])
      }
      content "application/json" {
        schema = array([#.])
      }
    }
    response "400" {
      description = "Invalid tag value"
    }
  }
  pathItem "/pet/{petId}" "get" {
    summary = "Find pet by ID"
    description = "Returns a single pet"
    operationId = "getPetById"
    tags = ["pet"]
    security = [{
      api_key = []
    }, {
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameter "petId" {
      required = true
      description = "ID of pet to return"
      in = "path"
      schema = integer("int64")
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
    response "404" {
      description = "Pet not found"
    }
  }
  pathItem "/pet/{petId}" "post" {
    operationId = "updatePetWithForm"
    summary = "Updates a pet in the store with form data"
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
      schema = string()
      in = "query"
      description = "Name of pet that needs to be updated"
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
    parameter "api_key" {
      in = "header"
      schema = string()
    }
    parameter "petId" {
      required = true
      in = "path"
      description = "Pet id to delete"
      schema = integer("int64")
    }
    response "400" {
      description = "Invalid pet value"
    }
  }
  pathItem "/pet/{petId}/uploadImage" "post" {
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    operationId = "uploadFile"
    summary = "uploads an image"
    tags = ["pet"]
    parameter "additionalMetadata" {
      in = "query"
      description = "Additional Metadata"
      schema = string()
    }
    parameter "petId" {
      in = "path"
      description = "ID of pet to update"
      schema = integer("int64")
      required = true
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
  pathItem "/user" "post" {
    summary = "Create user"
    description = "This can only be done by the logged in user."
    operationId = "createUser"
    tags = ["user"]
    requestBody {
      description = "Created user object"
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
      content "application/xml" {
        schema = #.
      }
      content "application/json" {
        schema = #.
      }
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
  pathItem "/user/{username}" "delete" {
    description = "This can only be done by the logged in user."
    operationId = "deleteUser"
    tags = ["user"]
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
    tags = ["user"]
    summary = "Get user by user name"
    operationId = "getUserByName"
    parameter "username" {
      schema = string()
      required = true
      description = "The name that needs to be fetched. Use user1 for testing. "
      in = "path"
    }
    response "400" {
      description = "Invalid username supplied"
    }
    response "404" {
      description = "User not found"
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
  pathItem "/user/{username}" "put" {
    summary = "Update user"
    description = "This can only be done by the logged in user."
    operationId = "updateUser"
    tags = ["user"]
    parameter "username" {
      schema = string()
      required = true
      description = "name that needs to be updated"
      in = "path"
    }
    requestBody {
      description = "Update an existent user in the store"
      content "application/x-www-form-urlencoded" {
        schema = #.
      }
      content "application/json" {
        schema = #.
      }
      content "application/xml" {
        schema = #.
      }
    }
    response "default" {
      description = "successful operation"
    }
  }
  pathItem "/pet" "put" {
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Update an existing pet"
    description = "Update an existing pet by Id"
    operationId = "updatePet"
    tags = ["pet"]
    requestBody {
      description = "Update an existent pet in the store"
      required = true
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
    response "404" {
      description = "Pet not found"
    }
  }
  pathItem "/pet" "post" {
    summary = "Add a new pet to the store"
    description = "Add a new pet to the store"
    operationId = "addPet"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    requestBody {
      required = true
      description = "Create a new pet in the store"
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
    description = "Multiple status values can be provided with comma separated strings"
    operationId = "findPetsByStatus"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameter "status" {
      explode = true
      in = "query"
      description = "Status values that need to be considered for filter"
      schema = string(, "available", ["available", "pending", "sold"])
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
    response "400" {
      description = "Invalid status value"
    }
  }
  components {
    schema "Tag" {
      type = "object"
      xml {
        name = "tag"
      }
      properties {
        id = integer("int64")
        name = string()
      }
    }
    schema "Pet" {
      type = "object"
      xml {
        name = "pet"
      }
      properties {
        name = string()
        category = #.
        id = integer("int64")
        photoUrls {
          type = "array"
          items = [{
            type = "string",
            xml = {
              name = "photoUrl"
            }
          }]
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
        shipDate = string("date-time")
        complete = boolean()
        id = integer("int64")
        petId = integer("int64")
        quantity = integer("int32")
        status {
          enum = [, , ]
          example = any()
          type = "string"
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
            wrapped = true
            name = "addresses"
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
          example = any()
          type = "integer"
        }
      }
    }
    requestBody "UserArray" {
      description = "List of user object"
      content "application/json" {
        schema = array([#.])
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
    securityScheme "api_key" {
      in = "header"
      type = "apiKey"
      name = "api_key"
    }
  }
