
  openapi = "3.0.2"
  servers = [{
    url = "/api/v3"
  }]
  tags = [{
    description = "Everything about your Pets",
    externalDocs = {
      description = "Find out more",
      url = "http://swagger.io"
    }
  }, {
    description = "Access to Petstore orders",
    externalDocs = {
      description = "Find out more about our store",
      url = "http://swagger.io"
    }
  }, {
    description = "Operations about user"
  }]
  info {
    description = "This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about\nSwagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!\nYou can now help us improve the API whether it's by making changes to the definition itself or to the code.\nThat way, with time, we can improve the API in general, and expose some of the new features in OAS3.\n\nSome useful links:\n- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)\n- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)"
    termsOfService = "http://swagger.io/terms/"
    version = "1.0.19"
    title = "Swagger Petstore - OpenAPI 3.0"
    license {
      name = "Apache 2.0"
      url = "http://www.apache.org/licenses/LICENSE-2.0.html"
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
    }
    responses "200" {
      description = "Successful operation"
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
    }
    responses "405" {
      description = "Invalid input"
    }
    responses "200" {
      description = "Successful operation"
    }
  }
  paths "/user/{username}" "put" {
    summary = "Update user"
    description = "This can only be done by the logged in user."
    operationId = "updateUser"
    tags = ["user"]
    parameters "username" {
      in = "path"
      description = "name that needs to be updated"
      schema = string()
      required = true
    }
    requestBody {
      description = "Update an existent user in the store"
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
  paths "/user/{username}" "get" {
    tags = ["user"]
    summary = "Get user by user name"
    operationId = "getUserByName"
    parameters "username" {
      in = "path"
      description = "The name that needs to be fetched. Use user1 for testing. "
      schema = string()
      required = true
    }
    responses "404" {
      description = "User not found"
    }
    responses "200" {
      description = "successful operation"
    }
    responses "400" {
      description = "Invalid username supplied"
    }
  }
  paths "/pet/findByStatus" "get" {
    description = "Multiple status values can be provided with comma separated strings"
    operationId = "findPetsByStatus"
    summary = "Finds Pets by status"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "status" {
      description = "Status values that need to be considered for filter"
      schema = string(enum("available", "pending", "sold"))
      explode = true
      in = "query"
    }
    responses "200" {
      description = "successful operation"
    }
    responses "400" {
      description = "Invalid status value"
    }
  }
  paths "/pet/{petId}/uploadImage" "post" {
    operationId = "uploadFile"
    summary = "uploads an image"
    tags = ["pet"]
    security = [{
      petstore_auth = ["write:pets", "read:pets"]
    }]
    parameters "petId" {
      description = "ID of pet to update"
      in = "path"
      required = true
    }
    parameters "additionalMetadata" {
      in = "query"
      description = "Additional Metadata"
      schema = string()
    }
    responses "200" {
      description = "successful operation"
    }
  }
  paths "/store/order" "post" {
    operationId = "placeOrder"
    summary = "Place an order for a pet"
    description = "Place a new order in the store"
    tags = ["store"]
    responses "405" {
      description = "Invalid input"
    }
    responses "200" {
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
    }
    responses "400" {
      description = "Invalid username/password supplied"
    }
  }
  paths "/store/inventory" "get" {
    operationId = "getInventory"
    tags = ["store"]
    security = [{
      api_key = []
    }]
    summary = "Returns pet inventories by status"
    description = "Returns a map of status codes to quantities"
    responses "200" {
      description = "successful operation"
    }
  }
  paths "/store/order/{orderId}" "get" {
    operationId = "getOrderById"
    tags = ["store"]
    summary = "Find purchase order by ID"
    description = "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions."
    parameters "orderId" {
      in = "path"
      description = "ID of order that needs to be fetched"
      required = true
    }
    responses "404" {
      description = "Order not found"
    }
    responses "200" {
      description = "successful operation"
    }
    responses "400" {
      description = "Invalid ID supplied"
    }
  }
  paths "/store/order/{orderId}" "delete" {
    operationId = "deleteOrder"
    summary = "Delete purchase order by ID"
    description = "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
    tags = ["store"]
    parameters "orderId" {
      description = "ID of the order that needs to be deleted"
      required = true
      in = "path"
    }
    responses "404" {
      description = "Order not found"
    }
    responses "400" {
      description = "Invalid ID supplied"
    }
  }
  paths "/user/createWithList" "post" {
    operationId = "createUsersWithListInput"
    summary = "Creates list of users with given input array"
    description = "Creates list of users with given input array"
    tags = ["user"]
    responses "200" {
      description = "Successful operation"
    }
    responses "default" {
      description = "successful operation"
    }
  }
  paths "/user" "post" {
    operationId = "createUser"
    summary = "Create user"
    description = "This can only be done by the logged in user."
    tags = ["user"]
    requestBody {
      description = "Created user object"
    }
    responses "default" {
      description = "successful operation"
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
    }
    responses "200" {
      description = "successful operation"
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
    }
    responses "400" {
      description = "Invalid pet value"
    }
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
    responses "400" {
      description = "Invalid tag value"
    }
    responses "200" {
      description = "successful operation"
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
      id = ""
    }
  }
  components "schemas" "User" {
    type = "object"
    xml {
      name = "user"
    }
    properties {
      userStatus = ""
      id = ""
      username = string(example("theUser"))
      firstName = string(example("John"))
      lastName = string(example("James"))
      email = string(example("john@email.com"))
      password = string(example("12345"))
      phone = string(example("12345"))
    }
  }
  components "schemas" "Tag" {
    type = "object"
    xml {
      name = "tag"
    }
    properties {
      id = ""
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
      id = ""
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
    }
  }
  components "schemas" "ApiResponse" {
    type = "object"
    xml {
      name = "##default"
    }
    properties {
      code = ""
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
      status = string(description("Order Status"), example("approved"), enum("placed", "approved", "delivered"))
      complete = boolean()
      id = ""
      petId = ""
      quantity = ""
      shipDate = string(format("date-time"))
    }
  }
  components "requestBodies" "Pet" {
    description = "Pet object that needs to be added to the store"
  }
  components "requestBodies" "UserArray" {
    description = "List of user object"
  }
  components "securitySchemes" "petstore_auth" {
    type = "oauth2"
    flows {
      implicit {
        scopes {
          read_pets = "read your pets"
          write_pets = "modify pets in your account"
        }
      }
    }
  }
  components "securitySchemes" "api_key" {
    type = "apiKey"
    name = "api_key"
    in = "header"
  }
