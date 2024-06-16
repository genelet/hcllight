
  provider {
    name = "petstore"
  }
  resource "pet" "required" {
    petId = integer(format("int64"))
  }
  resource "pet" {
    photoUrls = array([string()])
    tags = array([object({
      name = string(),
      id = integer(format("int64"))
    })])
    status = string(description("pet status in the store"), enum("available", "pending", "sold"))
    id = integer(format("int64"), example(10))
    name = string(example("doggie"))
    category = object({
      name = string(example("Dogs")),
      id = integer(format("int64"), example(1))
    })
  }
  data "order" "required" {
    orderId = integer(format("int64"))
  }
  data "order" {
    id = integer(format("int64"), example(10))
    petId = integer(format("int64"), example(198772))
    quantity = integer(format("int32"), example(7))
    shipDate = string(format("date-time"))
    status = string(description("Order Status"), example("approved"), enum("placed", "approved", "delivered"))
    complete = boolean()
  }
