
  provider {
    name = "petstore"
  }
  resource "pet" {
    category = {
		id = 1,
		name = "Animal"
    }
    photoUrls = ["http://localhost/1", "http://localhost/2"]
	tags = [{
		id = 12,
        name = "cat"
	},{
		id = 12,
        name = "cat"
	}]	
    status = "available"
    id = 123
	petId = 1
    name = "doggie"
  }
  data "order" {
	orderId = 2
    petId = 198772
    quantity = 7
    shipDate = "2024-05-01"
    status = "placed"
    complete = true
    id = 1234
  }
