
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
    description = "Access to Petstore orders",
    name = "store",
    externalDocs = {
      url = "http://swagger.io",
      description = "Find out more about our store"
    }
  }, {
    name = "user",
    description = "Operations about user"
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
  externalDocs {
    url = "http://swagger.io"
    description = "Find out more about Swagger"
  }
  paths "/user/logout" "get" {
    summary = "Logs out current logged in user session"
    operationId = "logoutUser"
    tags = ["user"]
    responses "default" {
      description = "successful operation"
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
    responses "400" {
      description = "Invalid ID supplied"
    }
    responses "404" {
      description = "Pet not found"
    }
    responses "405" {
      description = "Validation exception"
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
      in = "query"
      description = "Status values that need to be considered for filter"
      schema = string(default("available"), enum("available", "pending", "sold"))
      explode = true
    }
    responses "200" {
      description = "successful operation"
      content "application/json" {
        schema = array([components.schemas.Pet])
      }
      content "application/xml" {
        schema = array([components.schemas.Pet])
      }
    }
    responses "400" {
      description = "Invalid status value"
    }
  }
  paths "/pet/{petId}" "get" {
    tags = ["pet"]
    security = [{
      api_key = []
    }, {
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Find pet by ID"
    description = "Returns a single pet"
    operationId = "getPetById"
    parameters "petId" {
      required = true
      in = "path"
      description = "ID of pet to return"
      schema = integer(format("int64"))
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
    responses "400" {
      description = "Invalid ID supplied"
    }
    responses "404" {
      description = "Pet not found"
    }
  }
  paths "/pet/{petId}" "post" {
    summary = "Updates a pet in the store with form data"
    operationId = "updatePetWithForm"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "petId" {
      required = true
      in = "path"
      description = "ID of pet that needs to be updated"
      schema = integer(format("int64"))
    }
    parameters "name" {
      in = "query"
      description = "Name of pet that needs to be updated"
      schema = string()
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
    summary = "Deletes a pet"
    operationId = "deletePet"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "api_key" {
      in = "header"
      schema = string()
    }
    parameters "petId" {
      in = "path"
      description = "Pet id to delete"
      schema = integer(format("int64"))
      required = true
    }
    responses "400" {
      description = "Invalid pet value"
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
      schema = integer(format("int64"))
    }
    parameters "additionalMetadata" {
      description = "Additional Metadata"
      in = "query"
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
  paths "/user" "post" {
    description = "This can only be done by the logged in user."
    operationId = "createUser"
    tags = ["user"]
    summary = "Create user"
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
      content "application/json" {
        schema = components.schemas.User
      }
      content "application/xml" {
        schema = components.schemas.User
      }
    }
  }
  paths "/user/login" "get" {
    operationId = "loginUser"
    summary = "Logs user into the system"
    tags = ["user"]
    parameters "username" {
      description = "The user name for login"
      in = "query"
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
      headers "X-Expires-After" {
        description = "date in UTC when token expires"
        schema = string(format("date-time"))
      }
      headers "X-Rate-Limit" {
        description = "calls per hour allowed by the user"
        schema = integer(format("int32"))
      }
    }
    responses "400" {
      description = "Invalid username/password supplied"
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
        schema = map(integer(format("int32")))
      }
    }
  }
  paths "/user/{username}" "get" {
    summary = "Get user by user name"
    operationId = "getUserByName"
    tags = ["user"]
    parameters "username" {
      required = true
      description = "The name that needs to be fetched. Use user1 for testing. "
      in = "path"
      schema = string()
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
    tags = ["user"]
    summary = "Update user"
    description = "This can only be done by the logged in user."
    operationId = "updateUser"
    parameters "username" {
      in = "path"
      description = "name that needs to be updated"
      schema = string()
      required = true
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
      schema = array([string()])
      explode = true
      in = "query"
      description = "Tags to filter by"
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
    operationId = "placeOrder"
    summary = "Place an order for a pet"
    tags = ["store"]
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
  paths "/store/order/{orderId}" "get" {
    operationId = "getOrderById"
    summary = "Find purchase order by ID"
    description = "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions."
    tags = ["store"]
    parameters "orderId" {
      required = true
      in = "path"
      description = "ID of order that needs to be fetched"
      schema = integer(format("int64"))
    }
    responses "404" {
      description = "Order not found"
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
  }
  paths "/store/order/{orderId}" "delete" {
    summary = "Delete purchase order by ID"
    description = "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
    operationId = "deleteOrder"
    tags = ["store"]
    parameters "orderId" {
      in = "path"
      description = "ID of the order that needs to be deleted"
      schema = integer(format("int64"))
      required = true
    }
    responses "404" {
      description = "Order not found"
    }
    responses "400" {
      description = "Invalid ID supplied"
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
  components "schemas" "User" {
    type = "object"
    xml {
      name = "user"
    }
    properties {
      password = string(example("12345"))
      phone = string(example("12345"))
      userStatus = integer(format("int32"), description("User Status"), example(1))
      id = integer(format("int64"), example(10))
      username = string(example("theUser"))
      firstName = string(example("John"))
      lastName = string(example("James"))
      email = string(example("john@email.com"))
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
      category = components.schemas.Category
      status = string(description("pet status in the store"), enum("available", "pending", "sold"))
      id = integer(format("int64"), example(10))
      name = string(example("doggie"))
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
  components "schemas" "ApiResponse" {
    type = "object"
    xml {
      name = "##default"
    }
    properties {
      message = string()
      code = integer(format("int32"))
      type = string()
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
  components "schemas" "Address" {
    type = "object"
    xml {
      name = "address"
    }
    properties {
      state = string(example("CA"))
      zip = string(example("94301"))
      street = string(example("437 Lytton"))
      city = string(example("Palo Alto"))
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
        authorizationUrl = "https://petstore3.swagger.io/oauth/authorize"
        scopes {
          write:pets = "modify pets in your account"
          read:pets = "read your pets"
        }
      }
    }
  }
  components "securitySchemes" "api_key" {
    type = "apiKey"
    name = "api_key"
    in = "header"
  }
