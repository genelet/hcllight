
  openapi = "3.0.2"
  servers = [{
    url = "/api/v3"
  }]
  info {
    description = "This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about
Swagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!
You can now help us improve the API whether it's by making changes to the definition itself or to the code.
That way, with time, we can improve the API in general, and expose some of the new features in OAS3.

Some useful links:
- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)
- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)"
    termsOfService = "http://swagger.io/terms/"
    version = "1.0.19"
    title = "Swagger Petstore - OpenAPI 3.0"
    contact {
      email = "apiteam@swagger.io"
    }
    license {
      name = "Apache 2.0"
      url = "http://www.apache.org/licenses/LICENSE-2.0.html"
    }
  }
  tags "user" {
    description = "Operations about user"
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
      url = "http://swagger.io"
      description = "Find out more about our store"
    }
  }
  externalDocs {
    url = "http://swagger.io"
    description = "Find out more about Swagger"
  }
  pathItem "/pet/findByTags" "get" {
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Finds Pets by tags"
    description = "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."
    operationId = "findPetsByTags"
    tags = ["pet"]
    parameter "tags" {
      in = "query"
      description = "Tags to filter by"
      schema = array([string()])
      explode = true
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
  pathItem "/pet/{petId}" "post" {
    summary = "Updates a pet in the store with form data"
    operationId = "updatePetWithForm"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameter "status" {
      in = "query"
      description = "Status of pet that needs to be updated"
      schema = string()
    }
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
    response "405" {
      description = "Invalid input"
    }
  }
  pathItem "/pet/{petId}" "delete" {
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Deletes a pet"
    operationId = "deletePet"
    parameter "api_key" {
      schema = string()
      in = "header"
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
  pathItem "/pet/{petId}" "get" {
    operationId = "getPetById"
    tags = ["pet"]
    security = [{
      api_key = []
    }, {
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Find pet by ID"
    description = "Returns a single pet"
    parameter "petId" {
      in = "path"
      description = "ID of pet to return"
      schema = integer("int64")
      required = true
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
  pathItem "/pet/{petId}/uploadImage" "post" {
    operationId = "uploadFile"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "uploads an image"
    parameter "petId" {
      in = "path"
      description = "ID of pet to update"
      schema = integer("int64")
      required = true
    }
    parameter "additionalMetadata" {
      in = "query"
      description = "Additional Metadata"
      schema = string()
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
  pathItem "/user/login" "get" {
    operationId = "loginUser"
    summary = "Logs user into the system"
    tags = ["user"]
    parameter "password" {
      in = "query"
      description = "The password for login in clear text"
      schema = string()
    }
    parameter "username" {
      in = "query"
      description = "The user name for login"
      schema = string()
    }
    response "400" {
      description = "Invalid username/password supplied"
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
  }
  pathItem "/user/logout" "get" {
    summary = "Logs out current logged in user session"
    tags = ["user"]
    operationId = "logoutUser"
    response "default" {
      description = "successful operation"
    }
  }
  pathItem "/pet" "put" {
    operationId = "updatePet"
    summary = "Update an existing pet"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    description = "Update an existing pet by Id"
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
    response "405" {
      description = "Validation exception"
    }
  }
  pathItem "/pet" "post" {
    summary = "Add a new pet to the store"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    description = "Add a new pet to the store"
    operationId = "addPet"
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
  pathItem "/store/order/{orderId}" "get" {
    operationId = "getOrderById"
    summary = "Find purchase order by ID"
    description = "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions."
    tags = ["store"]
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
    operationId = "deleteOrder"
    tags = ["store"]
    summary = "Delete purchase order by ID"
    description = "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
    parameter "orderId" {
      required = true
      in = "path"
      description = "ID of the order that needs to be deleted"
      schema = integer("int64")
    }
    response "404" {
      description = "Order not found"
    }
    response "400" {
      description = "Invalid ID supplied"
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
  pathItem "/pet/findByStatus" "get" {
    summary = "Finds Pets by status"
    description = "Multiple status values can be provided with comma separated strings"
    operationId = "findPetsByStatus"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameter "status" {
      in = "query"
      description = "Status values that need to be considered for filter"
      schema = string(, "available", ["available", "pending", "sold"])
      explode = true
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
  pathItem "/store/order" "post" {
    operationId = "placeOrder"
    summary = "Place an order for a pet"
    description = "Place a new order in the store"
    tags = ["store"]
    requestBody {
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
  pathItem "/user/{username}" "get" {
    tags = ["user"]
    operationId = "getUserByName"
    summary = "Get user by user name"
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
  pathItem "/user/{username}" "put" {
    summary = "Update user"
    description = "This can only be done by the logged in user."
    operationId = "updateUser"
    tags = ["user"]
    parameter "username" {
      schema = string()
      required = true
      in = "path"
      description = "name that needs to be updated"
    }
    requestBody {
      description = "Update an existent user in the store"
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
    }
  }
  pathItem "/user/{username}" "delete" {
    summary = "Delete user"
    description = "This can only be done by the logged in user."
    operationId = "deleteUser"
    tags = ["user"]
    parameter "username" {
      description = "The name that needs to be deleted"
      schema = string()
      required = true
      in = "path"
    }
    response "400" {
      description = "Invalid username supplied"
    }
    response "404" {
      description = "User not found"
    }
  }
  pathItem "/store/inventory" "get" {
    operationId = "getInventory"
    tags = ["store"]
    security = [{
      api_key = []
    }]
    summary = "Returns pet inventories by status"
    description = "Returns a map of status codes to quantities"
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = map(integer("int32"))
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
      content "application/json" {
        schema = #.
      }
      content "application/xml" {
        schema = #.
      }
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
        category = #.
        id = integer("int64")
        name = string()
        status {
          type = "string"
          enum = [, , ]
        }
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
      }
    }
    schema "ApiResponse" {
      type = "object"
      xml {
        name = "##default"
      }
      properties {
        message = string()
        code = integer("int32")
        type = string()
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
          items = [#.]
          type = "array"
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
        zip = string()
        street = string()
        city = string()
        state = string()
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
          example = any()
          format = "int32"
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
    securityScheme "api_key" {
      type = "apiKey"
      name = "api_key"
      in = "header"
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
