
  provider  {
    name = "petstore"
  }
  resources = [
    {
      name = "pet"
      schema = {
        attributes = [
          {
            name = "category"
            single_nested = {
              computed_optional_required = "computed_optional"
              attributes = [
                {
                  name = "id"
                  int64 = {
                    computed_optional_required = "computed_optional"
                  }
                },
                {
                  name = "name"
                  string = {
                    computed_optional_required = "computed_optional"
                  }
                }
              ]
            }
          },
          {
            name = "id"
            int64 = {
              computed_optional_required = "computed_optional"
            }
          },
          {
            name = "name"
            string = {
              computed_optional_required = "required"
            }
          },
          {
            name = "photo_urls"
            list = {
              computed_optional_required = "required"
              element_type "string"  {
                
              }
            }
          },
          {
            name = "status"
            string = {
              computed_optional_required = "computed_optional"
              description = "pet status in the store"
              validators = [
                {
                  custom = {
                    schema_definition = "stringvalidator.OneOf(
"available",
"pending",
"sold",
)"
                    imports = [
                      {
                        path = "github.com/hashicorp/terraform-plugin-framework-validators/stringvalidator"
                      }
                    ]
                  }
                }
              ]
            }
          },
          {
            name = "tags"
            list_nested = {
              computed_optional_required = "computed_optional"
              nested_object = {
                attributes = [
                  {
                    name = "id"
                    int64 = {
                      computed_optional_required = "computed_optional"
                    }
                  },
                  {
                    name = "name"
                    string = {
                      computed_optional_required = "computed_optional"
                    }
                  }
                ]
              }
            }
          },
          {
            name = "pet_id"
            int64 = {
              computed_optional_required = "computed_optional"
              description = "ID of pet to return"
            }
          }
        ]
      }
    }
  ]

