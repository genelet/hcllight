
  provider {
    name = "petstore"
  }
  resource "pet" {
    status = string(description("pet status in the store"), enum("available", "pending", "sold"))
    id = integer(format("int64"))
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
  }
  data "order" {
    quantity = integer(format("int32"), example(7))
    shipDate = string(format("date-time"))
    status = string(description("Order Status"), example("approved"), enum("placed", "approved", "delivered"))
    complete = boolean()
    petId = integer(format("int64"), example(198772))
    id = integer(format("int64"), example(10))
  }
