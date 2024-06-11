
  provider {
    name = "petstore"
  }
  resource "pet" {
    id = integer(format("int64"), example(10))
    status = string(description("pet status in the store"), enum("available", "pending", "sold"))
    name = string(example("doggie"))
    category = object({
      id = integer(format("int64"), example(1)),
      name = string(example("Dogs"))
    })
    photoUrls = array([string()])
    tags = array([object({
      name = string(),
      id = integer(format("int64"))
    })])
  }
  data "order" {
    id = integer(format("int64"), example(10))
    quantity = integer(format("int32"), example(7))
    shipDate = string(format("date-time"))
    status = string(description("Order Status"), example("approved"), enum("placed", "approved", "delivered"))
    complete = boolean()
    petId = integer(format("int64"), example(198772))
  }
