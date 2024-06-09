
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
      name = string(),
      id = integer(format("int64"))
    })])
  }
  data "order" {
    shipDate = string(format("date-time"))
    id = integer(format("int64"), example(10))
    status = string(description("Order Status"), example("approved"), enum("placed", "approved", "delivered"))
    complete = boolean()
    petId = integer(format("int64"), example(198772))
    quantity = integer(format("int32"), example(7))
  }
