
  provider {
    name = "petstore"
  }
  resource "pet" {
    create {
      id = integer(format("int64"), example(10))
      name = string(example("doggie"))
      category = object({
        name = string(example("Dogs")),
        id = integer(format("int64"), example(1))
      })
      photoUrls = array([string()])
      tags = array([object({
        id = integer(format("int64")),
        name = string()
      })])
      status = string(description("pet status in the store"), enum("available", "pending", "sold"))
    }
    read {
      name = string(example("doggie"))
      category = object({
        name = string(example("Dogs")),
        id = integer(format("int64"), example(1))
      })
      photoUrls = array([string()])
      tags = array([object({
        id = integer(format("int64")),
        name = string()
      })])
      status = string(description("pet status in the store"), enum("available", "pending", "sold"))
      id = integer(format("int64"), example(10))
    }
    schema {
      attributes {
        aliases = {
          petId = "id"
        }
      }
    }
  }
