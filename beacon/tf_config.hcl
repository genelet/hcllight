
  provider {
    name = "petstore"
  }
  resource "pet" {
    create {
      tags = array([object({
        name = string(),
        id = integer(format("int64"))
      })])
      status = string(description("pet status in the store"), enum("available", "pending", "sold"))
      id = integer(format("int64"), example(10))
      name = string(example("doggie"))
      category = object({
        id = integer(format("int64"), example(1)),
        name = string(example("Dogs"))
      })
      photoUrls = array([string()])
    }
    read {
      name = string(example("doggie"))
      category = object({
        id = integer(format("int64"), example(1)),
        name = string(example("Dogs"))
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
