
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
  paths "/pet/findByTags" "get" {
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Finds Pets by tags"
    description = "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing."
    operationId = "findPetsByTags"
    tags = ["pet"]
    parameters "tags" {
      explode = true
      in = "query"
      description = "Tags to filter by"
      schema = array([string()])
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
      description = "Invalid tag value"
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
      required = true
      in = "path"
      description = "ID of pet to return"
      schema = integer(format("int64"))
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
    responses "400" {
      description = "Invalid ID supplied"
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
      required = true
      in = "path"
      description = "Pet id to delete"
      schema = integer(format("int64"))
    }
    responses "400" {
      description = "Invalid pet value"
    }
  }
  paths "/user/logout" "get" {
    operationId = "logoutUser"
    summary = "Logs out current logged in user session"
    tags = ["user"]
    responses "default" {
      description = "successful operation"
    }
  }
  paths "/user/{username}" "get" {
    summary = "Get user by user name"
    operationId = "getUserByName"
    tags = ["user"]
    parameters "username" {
      description = "The name that needs to be fetched. Use user1 for testing. "
      in = "path"
      schema = string()
      required = true
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
    responses "400" {
      description = "Invalid username supplied"
    }
  }
  paths "/user/{username}" "put" {
    tags = ["user"]
    summary = "Update user"
    description = "This can only be done by the logged in user."
    operationId = "updateUser"
    parameters "username" {
      required = true
      in = "path"
      description = "name that needs to be updated"
      schema = string()
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
    tags = ["user"]
    summary = "Delete user"
    description = "This can only be done by the logged in user."
    operationId = "deleteUser"
    parameters "username" {
      schema = string()
      required = true
      in = "path"
      description = "The name that needs to be deleted"
    }
    responses "400" {
      description = "Invalid username supplied"
    }
    responses "404" {
      description = "User not found"
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
      in = "query"
      description = "Status values that need to be considered for filter"
      schema = string(default("available"), enum("available", "pending", "sold"))
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
  paths "/store/order" "post" {
    operationId = "placeOrder"
    tags = ["store"]
    summary = "Place an order for a pet"
    description = "Place a new order in the store"
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
  paths "/user" "post" {
    summary = "Create user"
    description = "This can only be done by the logged in user."
    operationId = "createUser"
    tags = ["user"]
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
    responses "200" {
      description = "Successful operation"
      content "application/xml" {
        schema = components.schemas.User
      }
      content "application/json" {
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
      description = "The user name for login"
      schema = string()
      in = "query"
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
  paths "/pet" "put" {
    description = "Update an existing pet by Id"
    operationId = "updatePet"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    summary = "Update an existing pet"
    requestBody {
      description = "Update an existent pet in the store"
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
    responses "405" {
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
        schema = map(integer(format("int32")))
      }
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
      schema = integer(format("int64"))
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
  paths "/store/order/{orderId}" "get" {
    summary = "Find purchase order by ID"
    description = "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions."
    operationId = "getOrderById"
    tags = ["store"]
    parameters "orderId" {
      required = true
      in = "path"
      description = "ID of order that needs to be fetched"
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
    tags = ["store"]
    summary = "Delete purchase order by ID"
    description = "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
    parameters "orderId" {
      required = true
      description = "ID of the order that needs to be deleted"
      in = "path"
      schema = integer(format("int64"))
    }
    responses "400" {
      description = "Invalid ID supplied"
    }
    responses "404" {
      description = "Order not found"
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
        items = [components.schemas.Address]
        type = "array"
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
      street = string(example("437 Lytton"))
      city = string(example("Palo Alto"))
      state = string(example("CA"))
      zip = string(example("94301"))
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
      lastName = string(example("James"))
      email = string(example("john@email.com"))
      password = string(example("12345"))
      phone = string(example("12345"))
      userStatus = integer(format("int32"), description("User Status"), example(1))
      id = integer(format("int64"), example(10))
      username = string(example("theUser"))
      firstName = string(example("John"))
    }
  }
  components "schemas" "Tag" {
    type = "object"
    xml {
      name = "tag"
    }
    properties {
      name = string()
      id = integer(format("int64"))
    }
  }
  components "schemas" "Pet" {
    type = "object"
    required = ["name", "photoUrls"]
    xml {
      name = "pet"
    }
    properties {
      status = string(description("pet status in the store"), enum("available", "pending", "sold"))
      id = integer(format("int64"), example(10))
      name = string(example("doggie"))
      category = components.schemas.Category
      tags {
        type = "array"
        items = [components.schemas.Tag]
        xml {
          wrapped = true
        }
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
    }
  }
  components "schemas" "ApiResponse" {
    type = "object"
    xml {
      name = "##default"
    }
    properties {
      code = integer(format("int32"))
      type = string()
      message = string()
    }
  }
  components "schemas" "Order" {
    type = "object"
    xml {
      name = "order"
    }
    properties {
      id = integer(format("int64"), example(10))
      petId = integer(format("int64"), example(198772))
      quantity = integer(format("int32"), example(7))
      shipDate = string(format("date-time"))
      status = string(description("Order Status"), example("approved"), enum("placed", "approved", "delivered"))
      complete = boolean()
    }
  }
  components "requestBodys" "Pet" {
    description = "Pet object that needs to be added to the store"
    content "application/xml" {
      schema = components.schemas.Pet
    }
    content "application/json" {
      schema = components.schemas.Pet
    }
  }
  components "requestBodys" "UserArray" {
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
          write:pets = "modify pets in your account"
          read:pets = "read your pets"
        }
      }
    }
  }
  components "securityScheme" "api_key" {
    type = "apiKey"
    name = "api_key"
    in = "header"
  }
