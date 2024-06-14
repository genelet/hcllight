
  provider {
    name = "petstore"
  }
  resource "pet" "required" {
    petId = integer(format("int64"))
  }
  resource "pet" {
    tags = array([object({
      id = integer(format("int64")),
      name = string()
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
  data "order" "required" {
    orderId = integer(format("int64"))
  }
  data "order" {
    petId = integer(format("int64"), example(198772))
    quantity = integer(format("int32"), example(7))
    shipDate = string(format("date-time"))
    status = string(description("Order Status"), example("approved"), enum("placed", "approved", "delivered"))
    complete = boolean()
    id = integer(format("int64"), example(10))
  }
