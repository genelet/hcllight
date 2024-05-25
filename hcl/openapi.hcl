
  openapi = "3.0.2"
  servers = [{
    url = "/api/v3"
  }]
  tags = [{
    name = "pet",
    description = "Everything about your Pets",
    externalDocs = {
      url = "http://swagger.io",
      description = "Find out more"
    }
  }, {
    name = "store",
    description = "Access to Petstore orders",
    externalDocs = {
      url = "http://swagger.io",
      description = "Find out more about our store"
    }
  }, {
    name = "user",
    description = "Operations about user"
  }]
  info {
    description = "This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about\\nSwagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!\\nYou can now help us improve the API whether it's by making changes to the definition itself or to the code.\\nThat way, with time, we can improve the API in general, and expose some of the new features in OAS3.\\n\\nSome useful links:\\n- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)\\n- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)"
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
  externalDocs {
    url = "http://swagger.io"
    description = "Find out more about Swagger"
  }
  paths "/pet/findByTags" "get" {
    operationId = "findPetsByTags"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Finds Pets by tags"
    description = "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."
    parameters "tags" {
      explode = true
      in = "query"
      description = "Tags to filter by"
      schema = array([string()])
    }
    responses "200" {
      description = "successful operation"
      content "application/xml" {
        schema = array([components.schemas.Pet])
      }
      content "application/json" {
        schema = array([components.schemas.Pet])
      }
    }
    responses "400" {
      description = "Invalid tag value"
    }
  }
  paths "/store/order" "post" {
    description = "Place a new order in the store"
    operationId = "placeOrder"
    summary = "Place an order for a pet"
    tags = ["store"]
    requestBody {
      content "application/xml" {
        schema = components.schemas.Order
      }
      content "application/x-www-form-urlencoded" {
        schema = components.schemas.Order
      }
      content "application/json" {
        schema = components.schemas.Order
      }
    }
    responses "405" {
      description = "Invalid input"
    }
    responses "200" {
      description = "successful operation"
      content "application/json" {
        schema = components.schemas.Order
      }
    }
  }
  paths "/user/logout" "get" {
    summary = "Logs out current logged in user session"
    operationId = "logoutUser"
    tags = ["user"]
    responses "default" {
      description = "successful operation"
    }
  }
  paths "/user/createWithList" "post" {
    description = "Creates list of users with given input array"
    operationId = "createUsersWithListInput"
    summary = "Creates list of users with given input array"
    tags = ["user"]
    requestBody {
      content "application/json" {
        schema = array([components.schemas.User])
      }
    }
    responses "200" {
      description = "Successful operation"
      content "application/json" {
        schema = components.schemas.User
      }
      content "application/xml" {
        schema = components.schemas.User
      }
    }
    responses "default" {
      description = "successful operation"
    }
  }
  paths "/user/login" "get" {
    summary = "Logs user into the system"
    operationId = "loginUser"
    tags = ["user"]
    parameters "username" {
      in = "query"
      description = "The user name for login"
      schema = string()
    }
    parameters "password" {
      in = "query"
      description = "The password for login in clear text"
      schema = string()
    }
    responses "200" {
      description = "successful operation"
      content "application/xml" {
        schema = string()
      }
      content "application/json" {
        schema = string()
      }
      headers "X-Rate-Limit" {
        description = "calls per hour allowed by the user"
        schema = integer(format("int32"))
      }
      headers "X-Expires-After" {
        description = "date in UTC when token expires"
        schema = string(format("date-time"))
      }
    }
    responses "400" {
      description = "Invalid username/password supplied"
    }
  }
  paths "/user/{username}" "get" {
    summary = "Get user by user name"
    operationId = "getUserByName"
    tags = ["user"]
    parameters "username" {
      in = "path"
      description = "The name that needs to be fetched. Use user1 for testing. "
      schema = string()
      required = true
    }
    responses "200" {
      description = "successful operation"
      content "application/xml" {
        schema = components.schemas.User
      }
      content "application/json" {
        schema = components.schemas.User
      }
    }
    responses "400" {
      description = "Invalid username supplied"
    }
    responses "404" {
      description = "User not found"
    }
  }
  paths "/user/{username}" "put" {
    operationId = "updateUser"
    tags = ["user"]
    summary = "Update user"
    description = "This can only be done by the logged in user."
    parameters "username" {
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
    responses "default" {
      description = "successful operation"
    }
  }
  paths "/user/{username}" "delete" {
    summary = "Delete user"
    description = "This can only be done by the logged in user."
    operationId = "deleteUser"
    tags = ["user"]
    parameters "username" {
      in = "path"
      schema = string()
      required = true
      description = "The name that needs to be deleted"
    }
    responses "400" {
      description = "Invalid username supplied"
    }
    responses "404" {
      description = "User not found"
    }
  }
  paths "/pet/{petId}" "post" {
    operationId = "updatePetWithForm"
    summary = "Updates a pet in the store with form data"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "petId" {
      schema = integer(format("int64"))
      required = true
      in = "path"
      description = "ID of pet that needs to be updated"
    }
    parameters "name" {
      description = "Name of pet that needs to be updated"
      schema = string()
      in = "query"
    }
    parameters "status" {
      in = "query"
      description = "Status of pet that needs to be updated"
      schema = string()
    }
    responses "405" {
      description = "Invalid input"
    }
  }
  paths "/pet/{petId}" "delete" {
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Deletes a pet"
    operationId = "deletePet"
    parameters "api_key" {
      in = "header"
      schema = string()
    }
    parameters "petId" {
      required = true
      in = "path"
      description = "Pet id to delete"
      schema = integer(format("int64"))
    }
    responses "400" {
      description = "Invalid pet value"
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
      in = "path"
      description = "ID of pet to return"
      schema = integer(format("int64"))
      required = true
    }
    responses "200" {
      description = "successful operation"
      content "application/xml" {
        schema = components.schemas.Pet
      }
      content "application/json" {
        schema = components.schemas.Pet
      }
    }
    responses "400" {
      description = "Invalid ID supplied"
    }
    responses "404" {
      description = "Pet not found"
    }
  }
  paths "/user" "post" {
    operationId = "createUser"
    summary = "Create user"
    tags = ["user"]
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
    responses "default" {
      description = "successful operation"
      content "application/xml" {
        schema = components.schemas.User
      }
      content "application/json" {
        schema = components.schemas.User
      }
    }
  }
  paths "/pet" "put" {
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
    responses "200" {
      description = "Successful operation"
      content "application/xml" {
        schema = components.schemas.Pet
      }
      content "application/json" {
        schema = components.schemas.Pet
      }
    }
    responses "400" {
      description = "Invalid ID supplied"
    }
    responses "404" {
      description = "Pet not found"
    }
    responses "405" {
      description = "Validation exception"
    }
  }
  paths "/pet" "post" {
    operationId = "addPet"
    summary = "Add a new pet to the store"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    description = "Add a new pet to the store"
    requestBody {
      description = "Create a new pet in the store"
      required = true
      content "application/x-www-form-urlencoded" {
        schema = components.schemas.Pet
      }
      content "application/json" {
        schema = components.schemas.Pet
      }
      content "application/xml" {
        schema = components.schemas.Pet
      }
    }
    responses "200" {
      description = "Successful operation"
      content "application/xml" {
        schema = components.schemas.Pet
      }
      content "application/json" {
        schema = components.schemas.Pet
      }
    }
    responses "405" {
      description = "Invalid input"
    }
  }
  paths "/pet/findByStatus" "get" {
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Finds Pets by status"
    description = "Multiple status values can be provided with comma separated strings"
    operationId = "findPetsByStatus"
    parameters "status" {
      explode = true
      description = "Status values that need to be considered for filter"
      in = "query"
      schema = string(default("available"), enum("available", "pending", "sold"))
    }
    responses "200" {
      description = "successful operation"
      content "application/xml" {
        schema = array([components.schemas.Pet])
      }
      content "application/json" {
        schema = array([components.schemas.Pet])
      }
    }
    responses "400" {
      description = "Invalid status value"
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
      in = "path"
      schema = integer(format("int64"))
      required = true
      description = "ID of pet to update"
    }
    parameters "additionalMetadata" {
      in = "query"
      description = "Additional Metadata"
      schema = string()
    }
    requestBody {
      content "application/octet-stream" {
        schema = string(format("binary"))
      }
    }
    responses "200" {
      description = "successful operation"
      content "application/json" {
        schema = components.schemas.ApiResponse
      }
    }
  }
  paths "/store/inventory" "get" {
    operationId = "getInventory"
    summary = "Returns pet inventories by status"
    description = "Returns a map of status codes to quantities"
    tags = ["store"]
    security = [{
      api_key = []
    }]
    responses "200" {
      description = "successful operation"
      content "application/json" {
        schema = map(integer(format("int32")))
      }
    }
  }
  paths "/store/order/{orderId}" "get" {
    tags = ["store"]
    description = "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions."
    operationId = "getOrderById"
    summary = "Find purchase order by ID"
    parameters "orderId" {
      required = true
      description = "ID of order that needs to be fetched"
      in = "path"
      schema = integer(format("int64"))
    }
    responses "200" {
      description = "successful operation"
      content "application/xml" {
        schema = components.schemas.Order
      }
      content "application/json" {
        schema = components.schemas.Order
      }
    }
    responses "400" {
      description = "Invalid ID supplied"
    }
    responses "404" {
      description = "Order not found"
    }
  }
  paths "/store/order/{orderId}" "delete" {
    operationId = "deleteOrder"
    summary = "Delete purchase order by ID"
    description = "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
    tags = ["store"]
    parameters "orderId" {
      required = true
      in = "path"
      description = "ID of the order that needs to be deleted"
      schema = integer(format("int64"))
    }
    responses "400" {
      description = "Invalid ID supplied"
    }
    responses "404" {
      description = "Order not found"
    }
  }
  components "schemas" "Category" {
    type = "object"
    xml {
      name = "category"
    }
    properties {
      name = string(example("Dogs"))
      id = integer(format("int64"), example(1))
    }
  }
  components "schemas" "User" {
    type = "object"
    xml {
      name = "user"
    }
    properties {
      firstName = string(example("John"))
      lastName = string(example("James"))
      email = string(example("john@email.com"))
      password = string(example("12345"))
      phone = string(example("12345"))
      userStatus = integer(format("int32"), description("User Status"), example(1))
      id = integer(format("int64"), example(10))
      username = string(example("theUser"))
    }
  }
  components "schemas" "Tag" {
    type = "object"
    xml {
      name = "tag"
    }
    properties {
      id = integer(format("int64"))
      name = string()
    }
  }
  components "schemas" "Pet" {
    type = "object"
    required = ["name", "photoUrls"]
    xml {
      name = "pet"
    }
    properties {
      photoUrls = {
        type = "array",
        items = [{
          type = "string",
          xml = {
            name = "photoUrl"
          }
        }],
        xml = {
          wrapped = true
        }
      }
      tags = {
        type = "array",
        items = [components.schemas.Tag],
        xml = {
          wrapped = true
        }
      }
      status = string(description("pet status in the store"), enum("available", "pending", "sold"))
      id = integer(format("int64"), example(10))
      name = string(example("doggie"))
      category = components.schemas.Category
    }
  }
  components "schemas" "ApiResponse" {
    type = "object"
    xml {
      name = "##default"
    }
    properties {
      type = string()
      message = string()
      code = integer(format("int32"))
    }
  }
  components "schemas" "Order" {
    type = "object"
    xml {
      name = "order"
    }
    properties {
      quantity = integer(format("int32"), example(7))
      shipDate = string(format("date-time"))
      status = string(description("Order Status"), example("approved"), enum("placed", "approved", "delivered"))
      complete = boolean()
      id = integer(format("int64"), example(10))
      petId = integer(format("int64"), example(198772))
    }
  }
  components "schemas" "Customer" {
    type = "object"
    xml {
      name = "customer"
    }
    properties {
      id = integer(format("int64"), example(100000))
      username = string(example("fehguy"))
      address = {
        type = "array",
        items = [components.schemas.Address],
        xml = {
          name = "addresses",
          wrapped = true
        }
      }
    }
  }
  components "schemas" "Address" {
    type = "object"
    xml {
      name = "address"
    }
    properties {
      zip = string(example("94301"))
      street = string(example("437 Lytton"))
      city = string(example("Palo Alto"))
      state = string(example("CA"))
    }
  }
  components "requestBodies" "Pet" {
    description = "Pet object that needs to be added to the store"
    content "application/xml" {
      schema = components.schemas.Pet
    }
    content "application/json" {
      schema = components.schemas.Pet
    }
  }
  components "requestBodies" "UserArray" {
    description = "List of user object"
    content "application/json" {
      schema = array([components.schemas.User])
    }
  }
  components "securitySchemes" "petstore_auth" {
    type = "oauth2"
    flows {
      implicit {
        authorizationUrl = "https://petstore3.swagger.io/oauth/authorize"
        scopes {
          write_pets = "modify pets in your account"
          read_pets = "read your pets"
        }
      }
    }
  }
  components "securitySchemes" "api_key" {
    name = "api_key"
    in = "header"
    type = "apiKey"
  }
