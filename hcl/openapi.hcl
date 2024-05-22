
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
  paths "/pet" "put" {
    summary = "Update an existing pet"
    description = "Update an existing pet by Id"
    operationId = "updatePet"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
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
    response "405" {
      description = "Validation exception"
    }
  }
  paths "/pet" "post" {
    summary = "Add a new pet to the store"
    description = "Add a new pet to the store"
    operationId = "addPet"
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
  paths "/pet/findByStatus" "get" {
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    operationId = "findPetsByStatus"
    summary = "Finds Pets by status"
    description = "Multiple status values can be provided with comma separated strings"
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
  paths "/pet/findByTags" "get" {
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Finds Pets by tags"
    description = "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."
    operationId = "findPetsByTags"
    parameters "tags" {
      schema = array([()])
      explode = true
      in = "query"
      description = "Tags to filter by"
    }
    response "400" {
      description = "Invalid tag value"
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
  paths "/store/order/{orderId}" "get" {
    operationId = "getOrderById"
    summary = "Find purchase order by ID"
    description = "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions."
    tags = ["store"]
    parameters "orderId" {
      required = true
      in = "path"
      description = "ID of order that needs to be fetched"
      schema = ()
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
    response "404" {
      description = "Order not found"
    }
  }
  paths "/store/order/{orderId}" "delete" {
    description = "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
    operationId = "deleteOrder"
    summary = "Delete purchase order by ID"
    tags = ["store"]
    parameters "orderId" {
      required = true
      in = "path"
      description = "ID of the order that needs to be deleted"
      schema = ()
    }
    response "404" {
      description = "Order not found"
    }
    response "400" {
      description = "Invalid ID supplied"
    }
  }
  paths "/user/createWithList" "post" {
    summary = "Creates list of users with given input array"
    tags = ["user"]
    description = "Creates list of users with given input array"
    operationId = "createUsersWithListInput"
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
  paths "/user/logout" "get" {
    operationId = "logoutUser"
    tags = ["user"]
    summary = "Logs out current logged in user session"
    response "default" {
      description = "successful operation"
    }
  }
  paths "/pet/{petId}" "get" {
    operationId = "getPetById"
    summary = "Find pet by ID"
    description = "Returns a single pet"
    tags = ["pet"]
    security = [{
      api_key = []
    }, {
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "petId" {
      required = true
      in = "path"
      description = "ID of pet to return"
      schema = ()
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
    operationId = "updatePetWithForm"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Updates a pet in the store with form data"
    parameters "petId" {
      in = "path"
      description = "ID of pet that needs to be updated"
      schema = ()
      required = true
    }
    parameters "name" {
      in = "query"
      schema = ()
      description = "Name of pet that needs to be updated"
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
      in = "path"
      schema = ()
      required = true
      description = "Pet id to delete"
    }
    parameters "api_key" {
      schema = ()
      in = "header"
    }
    response "400" {
      description = "Invalid pet value"
    }
  }
  paths "/user" "post" {
    tags = ["user"]
    summary = "Create user"
    description = "This can only be done by the logged in user."
    operationId = "createUser"
    requestBody {
      description = "Created user object"
      content "application/xml" {
        schema = components.schemas.User
      }
      content "application/x-www-form-urlencoded" {
        schema = components.schemas.User
      }
      content "application/json" {
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
  paths "/pet/{petId}/uploadImage" "post" {
    summary = "uploads an image"
    operationId = "uploadFile"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "petId" {
      required = true
      in = "path"
      description = "ID of pet to update"
      schema = ()
    }
    parameters "additionalMetadata" {
      schema = ()
      in = "query"
      description = "Additional Metadata"
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
  paths "/store/order" "post" {
    summary = "Place an order for a pet"
    description = "Place a new order in the store"
    operationId = "placeOrder"
    tags = ["store"]
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
  paths "/user/login" "get" {
    operationId = "loginUser"
    summary = "Logs user into the system"
    tags = ["user"]
    parameters "username" {
      in = "query"
      description = "The user name for login"
      schema = ()
    }
    parameters "password" {
      in = "query"
      description = "The password for login in clear text"
      schema = ()
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
        schema = ()
        description = "date in UTC when token expires"
      }
    }
    response "400" {
      description = "Invalid username/password supplied"
    }
  }
  paths "/user/{username}" "get" {
    operationId = "getUserByName"
    tags = ["user"]
    summary = "Get user by user name"
    parameters "username" {
      required = true
      in = "path"
      description = "The name that needs to be fetched. Use user1 for testing. "
      schema = ()
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
        schema = components.schemas.User
      }
      content "application/json" {
        schema = components.schemas.User
      }
    }
  }
  paths "/user/{username}" "put" {
    tags = ["user"]
    summary = "Update user"
    description = "This can only be done by the logged in user."
    operationId = "updateUser"
    parameters "username" {
      schema = ()
      required = true
      in = "path"
      description = "name that needs to be updated"
    }
    requestBody {
      description = "Update an existent user in the store"
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
    }
  }
  paths "/user/{username}" "delete" {
    summary = "Delete user"
    description = "This can only be done by the logged in user."
    operationId = "deleteUser"
    tags = ["user"]
    parameters "username" {
      schema = ()
      required = true
      in = "path"
      description = "The name that needs to be deleted"
    }
    response "400" {
      description = "Invalid username supplied"
    }
    response "404" {
      description = "User not found"
    }
  }
  components "schemas" "Order" {
    type = "object"
    xml {
      name = "order"
    }
    properties {
      shipDate = ()
      complete = boolean()
      status {
        enum = [, , ]
        description = "Order Status"
        example = any()
        type = "string"
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
  components "schemas" "Customer" {
    type = "object"
    xml {
      name = "customer"
    }
    properties {
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
      username {
        example = any()
        type = "string"
      }
    }
  }
  components "schemas" "Address" {
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
        example = any()
        type = "string"
      }
      zip {
        example = any()
        type = "string"
      }
    }
  }
  components "schemas" "Category" {
    type = "object"
    xml {
      name = "category"
    }
    properties {
      id {
        example = any()
        type = "integer"
        format = "int64"
      }
      name {
        example = any()
        type = "string"
      }
    }
  }
  components "schemas" "User" {
    type = "object"
    xml {
      name = "user"
    }
    properties {
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
        example = any()
        type = "string"
      }
      lastName {
        example = any()
        type = "string"
      }
      email {
        example = any()
        type = "string"
      }
      password {
        example = any()
        type = "string"
      }
      phone {
        type = "string"
        example = any()
      }
    }
  }
  components "schemas" "Tag" {
    type = "object"
    xml {
      name = "tag"
    }
    properties {
      id = ()
      name = ()
    }
  }
  components "schemas" "Pet" {
    type = "object"
    required = ["name", "photoUrls"]
    xml {
      name = "pet"
    }
    properties {
      category = components.schemas.Category
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
      status {
        description = "pet status in the store"
        type = "string"
        enum = [, , ]
      }
    }
  }
  components "schemas" "ApiResponse" {
    type = "object"
    xml {
      name = "##default"
    }
    properties {
      code = ()
      type = ()
      message = ()
    }
  }
  components "requestBody" "Pet" {
    description = "Pet object that needs to be added to the store"
    content "application/json" {
      schema = components.schemas.Pet
    }
    content "application/xml" {
      schema = components.schemas.Pet
    }
  }
  components "requestBody" "UserArray" {
    description = "List of user object"
    content "application/json" {
      schema = array([components.schemas.User])
    }
  }
  components "securityScheme" "petstore_auth" {
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
  components "securityScheme" "api_key" {
    type = "apiKey"
    name = "api_key"
    in = "header"
  }
