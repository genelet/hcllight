
  openapi = 3.0.2
  servers = [{
    url = /api/v3
  }]
  info {
    termsOfService = http://swagger.io/terms/
    version = 1.0.19
    title = Swagger Petstore - OpenAPI 3.0
    description = This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about
Swagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!
You can now help us improve the API whether it's by making changes to the definition itself or to the code.
That way, with time, we can improve the API in general, and expose some of the new features in OAS3.

Some useful links:
- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)
- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)
    contact {
      email = apiteam@swagger.io
    }
    license {
      name = Apache 2.0
      url = http://www.apache.org/licenses/LICENSE-2.0.html
    }
  }
  pathItem "/store/order/{orderId}" "delete" {
    summary = Delete purchase order by ID
    description = For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors
    operationId = deleteOrder
    tags = [store]
    parameter "orderId" {
      required = true
      description = ID of the order that needs to be deleted
      in = path
      schema = integer(int64)
    }
    response "400" {
      description = Invalid ID supplied
    }
    response "404" {
      description = Order not found
    }
  }
  pathItem "/store/order/{orderId}" "get" {
    summary = Find purchase order by ID
    description = For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions.
    operationId = getOrderById
    tags = [store]
    parameter "orderId" {
      in = path
      description = ID of order that needs to be fetched
      schema = integer(int64)
      required = true
    }
    response "404" {
      description = Order not found
    }
    response "200" {
      description = successful operation
      content "application/xml" {
        schema = reference()
      }
      content "application/json" {
        schema = reference()
      }
    }
    response "400" {
      description = Invalid ID supplied
    }
  }
  pathItem "/user" "post" {
    operationId = createUser
    tags = [user]
    summary = Create user
    description = This can only be done by the logged in user.
    requestBody {
      description = Created user object
      content "application/json" {
        schema = reference()
      }
      content "application/xml" {
        schema = reference()
      }
      content "application/x-www-form-urlencoded" {
        schema = reference()
      }
    }
    response "default" {
      description = successful operation
      content "application/json" {
        schema = reference()
      }
      content "application/xml" {
        schema = reference()
      }
    }
  }
  pathItem "/store/inventory" "get" {
    operationId = getInventory
    tags = [store]
    security = [{
      api_key = []
    }]
    summary = Returns pet inventories by status
    description = Returns a map of status codes to quantities
    response "200" {
      description = successful operation
      content "application/json" {
        schema = map(integer(int32))
      }
    }
  }
  pathItem "/pet/{petId}/uploadImage" "post" {
    summary = uploads an image
    operationId = uploadFile
    tags = [pet]
    security = [{
      petstore_auth = [write:pets, read:pets]
    }]
    parameter "petId" {
      required = true
      in = path
      description = ID of pet to update
      schema = integer(int64)
    }
    parameter "additionalMetadata" {
      in = query
      description = Additional Metadata
      schema = string()
    }
    requestBody {
      content "application/octet-stream" {
        schema = string(binary)
      }
    }
    response "200" {
      description = successful operation
      content "application/json" {
        schema = reference()
      }
    }
  }
  pathItem "/store/order" "post" {
    operationId = placeOrder
    summary = Place an order for a pet
    description = Place a new order in the store
    tags = [store]
    requestBody {
      content "application/json" {
        schema = reference()
      }
      content "application/xml" {
        schema = reference()
      }
      content "application/x-www-form-urlencoded" {
        schema = reference()
      }
    }
    response "200" {
      description = successful operation
      content "application/json" {
        schema = reference()
      }
    }
    response "405" {
      description = Invalid input
    }
  }
  pathItem "/user/{username}" "get" {
    summary = Get user by user name
    operationId = getUserByName
    tags = [user]
    parameter "username" {
      description = The name that needs to be fetched. Use user1 for testing. 
      in = path
      schema = string()
      required = true
    }
    response "400" {
      description = Invalid username supplied
    }
    response "404" {
      description = User not found
    }
    response "200" {
      description = successful operation
      content "application/xml" {
        schema = reference()
      }
      content "application/json" {
        schema = reference()
      }
    }
  }
  pathItem "/user/{username}" "put" {
    summary = Update user
    description = This can only be done by the logged in user.
    operationId = updateUser
    tags = [user]
    parameter "username" {
      required = true
      in = path
      description = name that needs to be updated
      schema = string()
    }
    requestBody {
      description = Update an existent user in the store
      content "application/x-www-form-urlencoded" {
        schema = reference()
      }
      content "application/json" {
        schema = reference()
      }
      content "application/xml" {
        schema = reference()
      }
    }
    response "default" {
      description = successful operation
    }
  }
  pathItem "/user/{username}" "delete" {
    summary = Delete user
    description = This can only be done by the logged in user.
    operationId = deleteUser
    tags = [user]
    parameter "username" {
      schema = string()
      required = true
      in = path
      description = The name that needs to be deleted
    }
    response "400" {
      description = Invalid username supplied
    }
    response "404" {
      description = User not found
    }
  }
  pathItem "/pet/{petId}" "get" {
    tags = [pet]
    security = [{
      api_key = []
    }, {
      petstore_auth = [write:pets, read:pets]
    }]
    description = Returns a single pet
    operationId = getPetById
    summary = Find pet by ID
    parameter "petId" {
      required = true
      in = path
      description = ID of pet to return
      schema = integer(int64)
    }
    response "200" {
      description = successful operation
      content "application/xml" {
        schema = reference()
      }
      content "application/json" {
        schema = reference()
      }
    }
    response "400" {
      description = Invalid ID supplied
    }
    response "404" {
      description = Pet not found
    }
  }
  pathItem "/pet/{petId}" "post" {
    security = [{
      petstore_auth = [write:pets, read:pets]
    }]
    summary = Updates a pet in the store with form data
    operationId = updatePetWithForm
    tags = [pet]
    parameter "status" {
      description = Status of pet that needs to be updated
      schema = string()
      in = query
    }
    parameter "petId" {
      required = true
      description = ID of pet that needs to be updated
      in = path
      schema = integer(int64)
    }
    parameter "name" {
      description = Name of pet that needs to be updated
      in = query
      schema = string()
    }
    response "405" {
      description = Invalid input
    }
  }
  pathItem "/pet/{petId}" "delete" {
    operationId = deletePet
    summary = Deletes a pet
    tags = [pet]
    security = [{
      petstore_auth = [write:pets, read:pets]
    }]
    parameter "api_key" {
      in = header
      schema = string()
    }
    parameter "petId" {
      required = true
      in = path
      description = Pet id to delete
      schema = integer(int64)
    }
    response "400" {
      description = Invalid pet value
    }
  }
  pathItem "/pet/findByStatus" "get" {
    summary = Finds Pets by status
    description = Multiple status values can be provided with comma separated strings
    operationId = findPetsByStatus
    tags = [pet]
    security = [{
      petstore_auth = [write:pets, read:pets]
    }]
    parameter "status" {
      explode = true
      in = query
      description = Status values that need to be considered for filter
      schema = string()
    }
    response "200" {
      description = successful operation
      content "application/xml" {
        schema = array([reference()])
      }
      content "application/json" {
        schema = array([reference()])
      }
    }
    response "400" {
      description = Invalid status value
    }
  }
  pathItem "/pet/findByTags" "get" {
    description = Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.
    operationId = findPetsByTags
    tags = [pet]
    security = [{
      petstore_auth = [write:pets, read:pets]
    }]
    summary = Finds Pets by tags
    parameter "tags" {
      explode = true
      in = query
      description = Tags to filter by
      schema = array([string()])
    }
    response "400" {
      description = Invalid tag value
    }
    response "200" {
      description = successful operation
      content "application/xml" {
        schema = array([reference()])
      }
      content "application/json" {
        schema = array([reference()])
      }
    }
  }
  pathItem "/user/createWithList" "post" {
    summary = Creates list of users with given input array
    description = Creates list of users with given input array
    operationId = createUsersWithListInput
    tags = [user]
    requestBody {
      content "application/json" {
        schema = array([reference()])
      }
    }
    response "default" {
      description = successful operation
    }
    response "200" {
      description = Successful operation
      content "application/xml" {
        schema = reference()
      }
      content "application/json" {
        schema = reference()
      }
    }
  }
  pathItem "/user/login" "get" {
    summary = Logs user into the system
    operationId = loginUser
    tags = [user]
    parameter "username" {
      description = The user name for login
      schema = string()
      in = query
    }
    parameter "password" {
      in = query
      description = The password for login in clear text
      schema = string()
    }
    response "200" {
      description = successful operation
      content "application/json" {
        schema = string()
      }
      content "application/xml" {
        schema = string()
      }
      header "X-Rate-Limit" {
        description = calls per hour allowed by the user
        schema = integer(int32)
      }
      header "X-Expires-After" {
        description = date in UTC when token expires
        schema = string(date-time)
      }
    }
    response "400" {
      description = Invalid username/password supplied
    }
  }
  pathItem "/user/logout" "get" {
    operationId = logoutUser
    summary = Logs out current logged in user session
    tags = [user]
    response "default" {
      description = successful operation
    }
  }
  pathItem "/pet" "put" {
    description = Update an existing pet by Id
    operationId = updatePet
    tags = [pet]
    security = [{
      petstore_auth = [write:pets, read:pets]
    }]
    summary = Update an existing pet
    requestBody {
      description = Update an existent pet in the store
      required = true
      content "application/json" {
        schema = reference()
      }
      content "application/xml" {
        schema = reference()
      }
      content "application/x-www-form-urlencoded" {
        schema = reference()
      }
    }
    response "200" {
      description = Successful operation
      content "application/xml" {
        schema = reference()
      }
      content "application/json" {
        schema = reference()
      }
    }
    response "400" {
      description = Invalid ID supplied
    }
    response "404" {
      description = Pet not found
    }
    response "405" {
      description = Validation exception
    }
  }
  pathItem "/pet" "post" {
    security = [{
      petstore_auth = [write:pets, read:pets]
    }]
    operationId = addPet
    summary = Add a new pet to the store
    description = Add a new pet to the store
    tags = [pet]
    requestBody {
      description = Create a new pet in the store
      required = true
      content "application/json" {
        schema = reference()
      }
      content "application/xml" {
        schema = reference()
      }
      content "application/x-www-form-urlencoded" {
        schema = reference()
      }
    }
    response "200" {
      description = Successful operation
      content "application/xml" {
        schema = reference()
      }
      content "application/json" {
        schema = reference()
      }
    }
    response "405" {
      description = Invalid input
    }
  }
  components {
    schema "Tag" {
      type = object
      xml {
        name = tag
      }
      properties {
        id = integer(int64)
        name = string()
      }
    }
    schema "Pet" {
      type = object
      xml {
        name = pet
      }
      properties {
        id = integer(int64)
        name = string()
        category = reference()
        photoUrls {
          type = array
          items = [{
            type = string,
            xml = {
              name = photoUrl
            }
          }]
          xml {
            wrapped = true
          }
        }
        tags {
          type = array
          items = [reference()]
          xml {
            wrapped = true
          }
        }
        status {
          type = string
          enum = [any(<nil>), any(<nil>), any(<nil>)]
        }
      }
    }
    schema "ApiResponse" {
      type = object
      xml {
        name = ##default
      }
      properties {
        code = integer(int32)
        type = string()
        message = string()
      }
    }
    schema "Order" {
      type = object
      xml {
        name = order
      }
      properties {
        petId = integer(int64)
        quantity = integer(int32)
        shipDate = string(date-time)
        complete = boolean()
        id = integer(int64)
        status {
          type = string
          enum = [any(<nil>), any(<nil>), any(<nil>)]
          example = any(<nil>)
        }
      }
    }
    schema "Customer" {
      type = object
      xml {
        name = customer
      }
      properties {
        id = integer(int64)
        username = string()
        address {
          type = array
          items = [reference()]
          xml {
            name = addresses
            wrapped = true
          }
        }
      }
    }
    schema "Address" {
      type = object
      xml {
        name = address
      }
      properties {
        street = string()
        city = string()
        state = string()
        zip = string()
      }
    }
    schema "Category" {
      type = object
      xml {
        name = category
      }
      properties {
        id = integer(int64)
        name = string()
      }
    }
    schema "User" {
      type = object
      xml {
        name = user
      }
      properties {
        password = string()
        phone = string()
        id = integer(int64)
        username = string()
        firstName = string()
        lastName = string()
        email = string()
        userStatus {
          type = integer
          format = int32
          example = any(<nil>)
        }
      }
    }
    requestBody "Pet" {
      description = Pet object that needs to be added to the store
      content "application/xml" {
        schema = reference()
      }
      content "application/json" {
        schema = reference()
      }
    }
    requestBody "UserArray" {
      description = List of user object
      content "application/json" {
        schema = array([reference()])
      }
    }
    securityScheme "petstore_auth" {
      type = oauth2
      flows {
        implicit {
          authorizationUrl = https://petstore3.swagger.io/oauth/authorize
          scopes {
            read:pets = read your pets
            write:pets = modify pets in your account
          }
        }
      }
    }
    securityScheme "api_key" {
      name = api_key
      in = header
      type = apiKey
    }
  }
  tags "pet" {
    description = Everything about your Pets
    externalDocs {
      url = http://swagger.io
      description = Find out more
    }
  }
  tags "store" {
    description = Access to Petstore orders
    externalDocs {
      url = http://swagger.io
      description = Find out more about our store
    }
  }
  tags "user" {
    description = Operations about user
  }
  externalDocs {
    url = http://swagger.io
    description = Find out more about Swagger
  }
