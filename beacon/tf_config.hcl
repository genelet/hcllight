
  provider {
    name = "petstore"
  }
  resource "pet" {
    create {
      name = string(example("doggie"))
      category = object({
        name = string(example("Dogs")),
        id = integer(format("int64"), example(1))
      })
      photoUrls = array([string()])
      tags = array([object({
        name = string(),
        id = integer(format("int64"))
      })])
      status = string(description("pet status in the store"), enum("available", "pending", "sold"))
      id = integer(format("int64"), example(10))
    }
    read {
      category = object({
        name = string(example("Dogs")),
        id = integer(format("int64"), example(1))
      })
      photoUrls = array([string()])
      tags = array([object({
        name = string(),
        id = integer(format("int64"))
      })])
      status = string(description("pet status in the store"), enum("available", "pending", "sold"))
      id = integer(format("int64"), example(10))
      name = string(example("doggie"))
    }
    schema {
      attributes {
        aliases = {
          petId = "id"
        }
      }
    }
  }
