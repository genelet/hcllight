
  openapi = "3.0.2"
  servers = [{
    url = "/api/v3"
  }]
  info {
    title = "Swagger Petstore - OpenAPI 3.0"
    description = "This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about
Swagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!
You can now help us improve the API whether it's by making changes to the definition itself or to the code.
That way, with time, we can improve the API in general, and expose some of the new features in OAS3.

Some useful links:
- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)
- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)"
    termsOfService = "http://swagger.io/terms/"
    version = "1.0.19"
    contact {
      email = "apiteam@swagger.io"
    }
    license {
      url = "http://www.apache.org/licenses/LICENSE-2.0.html"
      name = "Apache 2.0"
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
  pathItem "/pet" "put" {
    operationId = "updatePet"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Update an existing pet"
    description = "Update an existing pet by Id"
    requestBody {
      description = "Update an existent pet in the store"
      required = true
      content "application/json" {
        schema = components.schemas.Pet
      }
      content "application/xml" {
        schema = components.schemas.Pet
      }
      content "application/x-www-form-urlencoded" {
        schema = components.schemas.Pet
      }
    }
    response "405" {
      description = "Validation exception"
    }
    response "200" {
      description = "Successful operation"
      content "application/xml" {
        schema = components.schemas.Pet
      }
      content "application/json" {
        schema = components.schemas.Pet
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
    description = "Add a new pet to the store"
    operationId = "addPet"
    summary = "Add a new pet to the store"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    requestBody {
      description = "Create a new pet in the store"
      required = true
      content "application/xml" {
        schema = components.schemas.Pet
      }
      content "application/x-www-form-urlencoded" {
        schema = components.schemas.Pet
      }
      content "application/json" {
        schema = components.schemas.Pet
      }
    }
    response "200" {
      description = "Successful operation"
      content "application/json" {
        schema = components.schemas.Pet
      }
      content "application/xml" {
        schema = components.schemas.Pet
      }
    }
    response "405" {
      description = "Invalid input"
    }
  }
  pathItem "/store/order" "post" {
    operationId = "placeOrder"
    tags = ["store"]
    summary = "Place an order for a pet"
    description = "Place a new order in the store"
    requestBody {
      content "application/x-www-form-urlencoded" {
        schema = components.schemas.Order
      }
      content "application/json" {
        schema = components.schemas.Order
      }
      content "application/xml" {
        schema = components.schemas.Order
      }
    }
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = components.schemas.Order
      }
    }
    response "405" {
      description = "Invalid input"
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
        schema = components.schemas.User
      }
      content "application/json" {
        schema = components.schemas.User
      }
      content "application/xml" {
        schema = components.schemas.User
      }
    }
    response "default" {
      description = "successful operation"
      content "application/json" {
        schema = components.schemas.User
      }
      content "application/xml" {
        schema = components.schemas.User
      }
    }
  }
  pathItem "/user/{username}" "get" {
    summary = "Get user by user name"
    operationId = "getUserByName"
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
        schema = components.schemas.User
      }
      content "application/json" {
        schema = components.schemas.User
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
    operationId = "updateUser"
    tags = ["user"]
    summary = "Update user"
    description = "This can only be done by the logged in user."
    parameter "username" {
      required = true
      in = "path"
      description = "name that needs to be updated"
      schema = string()
    }
    requestBody {
      description = "Update an existent user in the store"
      content "application/x-www-form-urlencoded" {
        schema = components.schemas.User
      }
      content "application/json" {
        schema = components.schemas.User
      }
      content "application/xml" {
        schema = components.schemas.User
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
      in = "path"
      description = "The name that needs to be deleted"
      schema = string()
      required = true
    }
    response "400" {
      description = "Invalid username supplied"
    }
    response "404" {
      description = "User not found"
    }
  }
  pathItem "/store/inventory" "get" {
    description = "Returns a map of status codes to quantities"
    operationId = "getInventory"
    tags = ["store"]
    security = [{
      api_key = []
    }]
    summary = "Returns pet inventories by status"
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = map(integer("int32"))
      }
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
      description = "Status values that need to be considered for filter"
      schema = string(, "available", ["available", "pending", "sold"])
      explode = true
      in = "query"
    }
    response "400" {
      description = "Invalid status value"
    }
    response "200" {
      description = "successful operation"
      content "application/xml" {
        schema = array([components.schemas.Pet])
      }
      content "application/json" {
        schema = array([components.schemas.Pet])
      }
    }
  }
  pathItem "/pet/{petId}" "get" {
    description = "Returns a single pet"
    operationId = "getPetById"
    tags = ["pet"]
    security = [{
      api_key = []
    }, {
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Find pet by ID"
    parameter "petId" {
      required = true
      description = "ID of pet to return"
      in = "path"
      schema = integer("int64")
    }
    response "200" {
      description = "successful operation"
      content "application/xml" {
        schema = components.schemas.Pet
      }
      content "application/json" {
        schema = components.schemas.Pet
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
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Updates a pet in the store with form data"
    operationId = "updatePetWithForm"
    tags = ["pet"]
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
      schema = string()
      description = "Status of pet that needs to be updated"
      in = "query"
    }
    response "405" {
      description = "Invalid input"
    }
  }
  pathItem "/pet/{petId}" "delete" {
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Deletes a pet"
    operationId = "deletePet"
    tags = ["pet"]
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
  pathItem "/pet/findByTags" "get" {
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    description = "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."
    operationId = "findPetsByTags"
    summary = "Finds Pets by tags"
    tags = ["pet"]
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
      content "application/json" {
        schema = array([components.schemas.Pet])
      }
      content "application/xml" {
        schema = array([components.schemas.Pet])
      }
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
      required = true
      in = "path"
      description = "ID of pet to update"
      schema = integer("int64")
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
        schema = components.schemas.ApiResponse
      }
    }
  }
  pathItem "/store/order/{orderId}" "get" {
    description = "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions."
    operationId = "getOrderById"
    tags = ["store"]
    summary = "Find purchase order by ID"
    parameter "orderId" {
      required = true
      in = "path"
      description = "ID of order that needs to be fetched"
      schema = integer("int64")
    }
    response "404" {
      description = "Order not found"
    }
    response "200" {
      description = "successful operation"
      content "application/xml" {
        schema = components.schemas.Order
      }
      content "application/json" {
        schema = components.schemas.Order
      }
    }
    response "400" {
      description = "Invalid ID supplied"
    }
  }
  pathItem "/store/order/{orderId}" "delete" {
    operationId = "deleteOrder"
    summary = "Delete purchase order by ID"
    description = "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
    tags = ["store"]
    parameter "orderId" {
      required = true
      description = "ID of the order that needs to be deleted"
      in = "path"
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
        schema = array([components.schemas.User])
      }
    }
    response "200" {
      description = "Successful operation"
      content "application/xml" {
        schema = components.schemas.User
      }
      content "application/json" {
        schema = components.schemas.User
      }
    }
    response "default" {
      description = "successful operation"
    }
  }
  pathItem "/user/login" "get" {
    tags = ["user"]
    summary = "Logs user into the system"
    operationId = "loginUser"
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
  pathItem "/user/logout" "get" {
    summary = "Logs out current logged in user session"
    operationId = "logoutUser"
    tags = ["user"]
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
          example = any()
          type = "integer"
          format = "int32"
        }
      }
    }
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
        category = components.schemas.Category
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
          items = [components.schemas.Tag]
          xml {
            wrapped = true
          }
        }
        status {
          enum = [, , ]
          type = "string"
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
        complete = boolean()
        id = integer("int64")
        petId = integer("int64")
        quantity = integer("int32")
        shipDate = string("date-time")
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
          items = [components.schemas.Address]
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
        state = string()
        zip = string()
        street = string()
        city = string()
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
    requestBody "UserArray" {
      description = "List of user object"
      content "application/json" {
        schema = array([components.schemas.User])
      }
    }
    requestBody "Pet" {
      description = "Pet object that needs to be added to the store"
      content "application/json" {
        schema = components.schemas.Pet
      }
      content "application/xml" {
        schema = components.schemas.Pet
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
      name = "api_key"
      in = "header"
      type = "apiKey"
    }
  }
