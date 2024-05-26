
  tags = [{
    description = "Everything about your Pets",
    name = "pet",
    externalDocs = {
      url = "http://swagger.io",
      description = "Find out more"
    }
  }, {
    name = "store",
    description = "Access to Petstore orders",
    externalDocs = {
      description = "Find out more about our store",
      url = "http://swagger.io"
    }
  }, {
    name = "user",
    description = "Operations about user"
  }]
  openapi = "3.0.2"
  servers = [{
    url = "/api/v3"
  }]
  info {
    title = "Swagger Petstore - OpenAPI 3.0"
    description = "This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about\nSwagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!\nYou can now help us improve the API whether it's by making changes to the definition itself or to the code.\nThat way, with time, we can improve the API in general, and expose some of the new features in OAS3.\n\nSome useful links:\n- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)\n- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)"
    termsOfService = "http://swagger.io/terms/"
    version = "1.0.19"
    license {
      name = "Apache 2.0"
      url = "http://www.apache.org/licenses/LICENSE-2.0.html"
    }
  }
  externalDocs {
    url = "http://swagger.io"
    description = "Find out more about Swagger"
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
      in = "query"
      description = "Status values that need to be considered for filter"
      schema = string(enum("available", "pending", "sold"))
    }
    responses "400" {
      description = "Invalid status value"
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
    }
    responses "400" {
      description = "Invalid ID supplied"
    }
    responses "404" {
      description = "Order not found"
    }
    responses "200" {
      description = "successful operation"
      content "application/json" {
        schema = components.schemas.Order
      }
      content "application/xml" {
        schema = components.schemas.Order
      }
    }
  }
  paths "/store/order/{orderId}" "delete" {
    summary = "Delete purchase order by ID"
    description = "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
    operationId = "deleteOrder"
    tags = ["store"]
    parameters "orderId" {
      description = "ID of the order that needs to be deleted"
      required = true
      in = "path"
    }
    responses "400" {
      description = "Invalid ID supplied"
    }
    responses "404" {
      description = "Order not found"
    }
  }
  paths "/user/createWithList" "post" {
    description = "Creates list of users with given input array"
    operationId = "createUsersWithListInput"
    tags = ["user"]
    summary = "Creates list of users with given input array"
    requestBody {
      content "application/json" {
        schema = array([components.schemas.User])
      }
    }
    responses "default" {
      description = "successful operation"
    }
    responses "200" {
      description = "Successful operation"
      content "application/xml" {
        schema = components.schemas.User
      }
      content "application/json" {
        schema = components.schemas.User
      }
    }
  }
  paths "/pet/{petId}" "get" {
    operationId = "getPetById"
    tags = ["pet"]
    security = [{
      api_key = []
    }, {
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Find pet by ID"
    description = "Returns a single pet"
    parameters "petId" {
      required = true
      in = "path"
      description = "ID of pet to return"
    }
    responses "400" {
      description = "Invalid ID supplied"
    }
    responses "404" {
      description = "Pet not found"
    }
    responses "200" {
      description = "successful operation"
      content "application/json" {
        schema = components.schemas.Pet
      }
      content "application/xml" {
        schema = components.schemas.Pet
      }
    }
  }
  paths "/pet/{petId}" "post" {
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Updates a pet in the store with form data"
    operationId = "updatePetWithForm"
    parameters "petId" {
      description = "ID of pet that needs to be updated"
      required = true
      in = "path"
    }
    parameters "name" {
      description = "Name of pet that needs to be updated"
      schema = string()
      in = "query"
    }
    parameters "status" {
      description = "Status of pet that needs to be updated"
      in = "query"
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
      description = "Pet id to delete"
      in = "path"
    }
    responses "400" {
      description = "Invalid pet value"
    }
  }
  paths "/user/{username}" "get" {
    summary = "Get user by user name"
    operationId = "getUserByName"
    tags = ["user"]
    parameters "username" {
      required = true
      in = "path"
      description = "The name that needs to be fetched. Use user1 for testing."
      schema = string()
    }
    responses "400" {
      description = "Invalid username supplied"
    }
    responses "404" {
      description = "User not found"
    }
    responses "200" {
      description = "successful operation"
      content "application/json" {
        schema = components.schemas.User
      }
      content "application/xml" {
        schema = components.schemas.User
      }
    }
  }
  paths "/user/{username}" "put" {
    summary = "Update user"
    description = "This can only be done by the logged in user."
    operationId = "updateUser"
    tags = ["user"]
    parameters "username" {
      description = "name that needs to be updated"
      schema = string()
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
    responses "default" {
      description = "successful operation"
    }
  }
  paths "/user/{username}" "delete" {
    description = "This can only be done by the logged in user."
    operationId = "deleteUser"
    tags = ["user"]
    summary = "Delete user"
    parameters "username" {
      required = true
      in = "path"
      description = "The name that needs to be deleted"
      schema = string()
    }
    responses "400" {
      description = "Invalid username supplied"
    }
    responses "404" {
      description = "User not found"
    }
  }
  paths "/pet/findByTags" "get" {
    operationId = "findPetsByTags"
    summary = "Finds Pets by tags"
    description = "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "tags" {
      explode = true
      in = "query"
      description = "Tags to filter by"
      schema = array([string()])
    }
    responses "400" {
      description = "Invalid tag value"
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
  }
  paths "/user" "post" {
    tags = ["user"]
    summary = "Create user"
    description = "This can only be done by the logged in user."
    operationId = "createUser"
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
    responses "default" {
      description = "successful operation"
      content "application/json" {
        schema = components.schemas.User
      }
      content "application/xml" {
        schema = components.schemas.User
      }
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
      content "application/json" {
        schema = string()
      }
      content "application/xml" {
        schema = string()
      }
      headers "X-Rate-Limit" {
        description = "calls per hour allowed by the user"
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
  paths "/pet/{petId}/uploadImage" "post" {
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    operationId = "uploadFile"
    summary = "uploads an image"
    tags = ["pet"]
    parameters "petId" {
      in = "path"
      description = "ID of pet to update"
      required = true
    }
    parameters "additionalMetadata" {
      description = "Additional Metadata"
      schema = string()
      in = "query"
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
  paths "/store/order" "post" {
    summary = "Place an order for a pet"
    description = "Place a new order in the store"
    operationId = "placeOrder"
    tags = ["store"]
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
    responses "200" {
      description = "successful operation"
      content "application/json" {
        schema = components.schemas.Order
      }
    }
    responses "405" {
      description = "Invalid input"
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
  paths "/pet" "put" {
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Update an existing pet"
    description = "Update an existing pet by Id"
    operationId = "updatePet"
    requestBody {
      description = "Update an existent pet in the store"
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
    responses "404" {
      description = "Pet not found"
    }
    responses "405" {
      description = "Validation exception"
    }
    responses "200" {
      description = "Successful operation"
      content "application/json" {
        schema = components.schemas.Pet
      }
      content "application/xml" {
        schema = components.schemas.Pet
      }
    }
    responses "400" {
      description = "Invalid ID supplied"
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
    responses "405" {
      description = "Invalid input"
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
    responses "200" {
      description = "successful operation"
      content "application/json" {
        schema = map(false)
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
  components "schemas" "Category" {
    type = "object"
    xml {
      name = "category"
    }
    properties {
      id = ""
      name = string(example("Dogs"))
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
      userStatus = ""
      id = ""
      username = string(example("theUser"))
    }
  }
  components "schemas" "Tag" {
    type = "object"
    xml {
      name = "tag"
    }
    properties {
      name = string()
      id = ""
    }
  }
  components "schemas" "Pet" {
    type = "object"
    required = ["name", "photoUrls"]
    xml {
      name = "pet"
    }
    properties {
      name = string(example("doggie"))
      category = components.schemas.Category
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
      id = ""
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
      code = ""
    }
  }
  components "schemas" "Order" {
    type = "object"
    xml {
      name = "order"
    }
    properties {
      complete = boolean()
      id = ""
      petId = ""
      quantity = ""
      shipDate = string(format("date-time"))
      status = string(description("Order Status"), example("approved"), enum("placed", "approved", "delivered"))
    }
  }
  components "schemas" "Customer" {
    type = "object"
    xml {
      name = "customer"
    }
    properties {
      address = {
        type = "array",
        items = [components.schemas.Address],
        xml = {
          name = "addresses",
          wrapped = true
        }
      }
      id = ""
      username = string(example("fehguy"))
    }
  }
  components "requestBodies" "Pet" {
    description = "Pet object that needs to be added to the store"
    content "application/json" {
      schema = components.schemas.Pet
    }
    content "application/xml" {
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
        scopes = {
          "write:pets" = "modify pets in your account",
          "read:pets" = "read your pets"
        }
      }
    }
  }
  components "securitySchemes" "api_key" {
    type = "apiKey"
    name = "api_key"
    in = "header"
  }
