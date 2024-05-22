
  servers = [{
    url = "/api/v3"
  }]
  openapi = "3.0.2"
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
    description = "Find out more about Swagger"
    url = "http://swagger.io"
  }
  paths "/store/order/{orderId}" "delete" {
    summary = "Delete purchase order by ID"
    description = "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
    operationId = "deleteOrder"
    tags = ["store"]
    parameters "orderId" {
      required = true
      description = "ID of the order that needs to be deleted"
      in = "path"
      schema = ()
    }
    response "404" {
      description = "Order not found"
    }
    response "400" {
      description = "Invalid ID supplied"
    }
  }
  paths "/store/order/{orderId}" "get" {
    summary = "Find purchase order by ID"
    description = "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions."
    operationId = "getOrderById"
    tags = ["store"]
    parameters "orderId" {
      required = true
      in = "path"
      description = "ID of order that needs to be fetched"
      schema = ()
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
  paths "/user" "post" {
    operationId = "createUser"
    tags = ["user"]
    summary = "Create user"
    description = "This can only be done by the logged in user."
    requestBody {
      description = "Created user object"
      content "application/json" {
        schema = components.schemas.User
      }
      content "application/xml" {
        schema = components.schemas.User
      }
      content "application/x-www-form-urlencoded" {
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
  paths "/pet" "put" {
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
    response "400" {
      description = "Invalid ID supplied"
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
        schema = components.schemas.Pet
      }
      content "application/json" {
        schema = components.schemas.Pet
      }
    }
  }
  paths "/pet" "post" {
    operationId = "addPet"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Add a new pet to the store"
    description = "Add a new pet to the store"
    requestBody {
      description = "Create a new pet in the store"
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
  paths "/pet/findByStatus" "get" {
    summary = "Finds Pets by status"
    description = "Multiple status values can be provided with comma separated strings"
    operationId = "findPetsByStatus"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "status" {
      explode = true
      in = "query"
      description = "Status values that need to be considered for filter"
      schema = ()
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
    response "400" {
      description = "Invalid status value"
    }
  }
  paths "/user/{username}" "get" {
    summary = "Get user by user name"
    operationId = "getUserByName"
    tags = ["user"]
    parameters "username" {
      schema = ()
      required = true
      in = "path"
      description = "The name that needs to be fetched. Use user1 for testing. "
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
  paths "/user/{username}" "put" {
    summary = "Update user"
    description = "This can only be done by the logged in user."
    operationId = "updateUser"
    tags = ["user"]
    parameters "username" {
      description = "name that needs to be updated"
      schema = ()
      required = true
      in = "path"
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
  paths "/user/{username}" "delete" {
    summary = "Delete user"
    description = "This can only be done by the logged in user."
    operationId = "deleteUser"
    tags = ["user"]
    parameters "username" {
      required = true
      description = "The name that needs to be deleted"
      in = "path"
      schema = ()
    }
    response "400" {
      description = "Invalid username supplied"
    }
    response "404" {
      description = "User not found"
    }
  }
  paths "/pet/{petId}" "get" {
    summary = "Find pet by ID"
    description = "Returns a single pet"
    operationId = "getPetById"
    tags = ["pet"]
    security = [{
      api_key = []
    }, {
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "petId" {
      description = "ID of pet to return"
      schema = ()
      required = true
      in = "path"
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
  paths "/pet/{petId}" "post" {
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    operationId = "updatePetWithForm"
    summary = "Updates a pet in the store with form data"
    parameters "petId" {
      schema = ()
      required = true
      in = "path"
      description = "ID of pet that needs to be updated"
    }
    parameters "name" {
      description = "Name of pet that needs to be updated"
      in = "query"
      schema = ()
    }
    parameters "status" {
      in = "query"
      description = "Status of pet that needs to be updated"
      schema = ()
    }
    response "405" {
      description = "Invalid input"
    }
  }
  paths "/pet/{petId}" "delete" {
    summary = "Deletes a pet"
    operationId = "deletePet"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "petId" {
      required = true
      in = "path"
      description = "Pet id to delete"
      schema = ()
    }
    parameters "api_key" {
      in = "header"
      schema = ()
    }
    response "400" {
      description = "Invalid pet value"
    }
  }
  paths "/user/logout" "get" {
    summary = "Logs out current logged in user session"
    operationId = "logoutUser"
    tags = ["user"]
    response "default" {
      description = "successful operation"
    }
  }
  paths "/pet/findByTags" "get" {
    summary = "Finds Pets by tags"
    description = "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."
    operationId = "findPetsByTags"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "tags" {
      explode = true
      in = "query"
      description = "Tags to filter by"
      schema = array([()])
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
    response "400" {
      description = "Invalid tag value"
    }
  }
  paths "/user/login" "get" {
    summary = "Logs user into the system"
    operationId = "loginUser"
    tags = ["user"]
    parameters "username" {
      in = "query"
      schema = ()
      description = "The user name for login"
    }
    parameters "password" {
      description = "The password for login in clear text"
      schema = ()
      in = "query"
    }
    response "200" {
      description = "successful operation"
      content "application/xml" {
        schema = ()
      }
      content "application/json" {
        schema = ()
      }
      header "X-Rate-Limit" {
        description = "calls per hour allowed by the user"
        schema = ()
      }
      header "X-Expires-After" {
        description = "date in UTC when token expires"
        schema = ()
      }
    }
    response "400" {
      description = "Invalid username/password supplied"
    }
  }
  paths "/store/order" "post" {
    description = "Place a new order in the store"
    tags = ["store"]
    operationId = "placeOrder"
    summary = "Place an order for a pet"
    requestBody {
      content "application/json" {
        schema = components.schemas.Order
      }
      content "application/xml" {
        schema = components.schemas.Order
      }
      content "application/x-www-form-urlencoded" {
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
  paths "/user/createWithList" "post" {
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
  paths "/pet/{petId}/uploadImage" "post" {
    operationId = "uploadFile"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "uploads an image"
    parameters "petId" {
      required = true
      in = "path"
      description = "ID of pet to update"
      schema = ()
    }
    parameters "additionalMetadata" {
      in = "query"
      description = "Additional Metadata"
      schema = ()
    }
    requestBody {
      content "application/octet-stream" {
        schema = ()
      }
    }
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = components.schemas.ApiResponse
      }
    }
  }
  paths "/store/inventory" "get" {
    summary = "Returns pet inventories by status"
    description = "Returns a map of status codes to quantities"
    operationId = "getInventory"
    tags = ["store"]
    security = [{
      api_key = []
    }]
    response "200" {
      description = "successful operation"
      content "application/json" {
        schema = ()
      }
    }
  }
  components {
    Tag {
      type = "object"
      xml {
        name = "tag"
      }
      properties {
        id = ()
        name = ()
      }
    }
    Pet {
      type = "object"
      required = ["name", "photoUrls"]
      xml {
        name = "pet"
      }
      properties {
        category = components.schemas.Category
        status {
          description = "pet status in the store"
          type = "string"
          enum = [, , ]
        }
        id {
          example = any()
          type = "integer"
          format = "int64"
        }
        name {
          example = any()
          type = "string"
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
          items = [components.schemas.Tag]
          xml {
            wrapped = true
          }
        }
      }
    }
    ApiResponse {
      type = "object"
      xml {
        name = "##default"
      }
      properties {
        message = ()
        code = ()
        type = ()
      }
    }
    Order {
      type = "object"
      xml {
        name = "order"
      }
      properties {
        shipDate = ()
        complete = boolean()
        status {
          description = "Order Status"
          example = any()
          type = "string"
          enum = [, , ]
        }
        id {
          example = any()
          type = "integer"
          format = "int64"
        }
        petId {
          example = any()
          type = "integer"
          format = "int64"
        }
        quantity {
          example = any()
          type = "integer"
          format = "int32"
        }
      }
    }
    Customer {
      type = "object"
      xml {
        name = "customer"
      }
      properties {
        username {
          example = any()
          type = "string"
        }
        address {
          type = "array"
          items = [components.schemas.Address]
          xml {
            name = "addresses"
            wrapped = true
          }
        }
        id {
          example = any()
          type = "integer"
          format = "int64"
        }
      }
    }
    Address {
      type = "object"
      xml {
        name = "address"
      }
      properties {
        street {
          example = any()
          type = "string"
        }
        city {
          example = any()
          type = "string"
        }
        state {
          type = "string"
          example = any()
        }
        zip {
          example = any()
          type = "string"
        }
      }
    }
    Category {
      type = "object"
      xml {
        name = "category"
      }
      properties {
        id {
          type = "integer"
          format = "int64"
          example = any()
        }
        name {
          example = any()
          type = "string"
        }
      }
    }
    User {
      type = "object"
      xml {
        name = "user"
      }
      properties {
        email {
          example = any()
          type = "string"
        }
        password {
          example = any()
          type = "string"
        }
        phone {
          example = any()
          type = "string"
        }
        userStatus {
          description = "User Status"
          example = any()
          type = "integer"
          format = "int32"
        }
        id {
          example = any()
          type = "integer"
          format = "int64"
        }
        username {
          example = any()
          type = "string"
        }
        firstName {
          type = "string"
          example = any()
        }
        lastName {
          example = any()
          type = "string"
        }
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
    requestBody "UserArray" {
      description = "List of user object"
      content "application/json" {
        schema = array([components.schemas.User])
      }
    }
    securityScheme "petstore_auth" {
      type = "oauth2"
      flows {
        implicit {
          authorizationUrl = "https://petstore3.swagger.io/oauth/authorize"
          scopes {
            read:pets = "read your pets"
            write:pets = "modify pets in your account"
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
