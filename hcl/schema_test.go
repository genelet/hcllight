// Copyright (c) Greetingland LLC
// MIT License

package hcl

import (
	"encoding/json"
	"testing"

	"github.com/genelet/hcllight/light"
)

func TestSchemaSimpleString(t *testing.T) {
	schema1 := &SchemaOrReference{
		Oneof: &SchemaOrReference_String_{
			String_: &OASString{
				Common: &SchemaCommon{
					Type: "string",
				},
				String_: &SchemaString{
					MinLength: 1,
				},
			},
		},
	}
	schema2 := &SchemaOrReference{
		Oneof: &SchemaOrReference_String_{
			String_: &OASString{
				Common: &SchemaCommon{
					Type: "string",
				},
				String_: &SchemaString{
					MaxLength: 1,
					Pattern:   "^[a-z]+$",
				},
			},
		},
	}
	hash := map[string]*SchemaOrReference{
		"schema1": schema1,
		"schema2": schema2,
	}
	body, err := schemaOrReferenceMapToBody(hash)
	if err != nil {
		t.Fatal(err)
	}
	bs, err := body.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	if string(bs) != `
  schema1 = string(minLength(1))
  schema2 = string(maxLength(1), pattern("^[a-z]+$"))
` && string(bs) != `
  schema2 = string(maxLength(1), pattern("^[a-z]+$"))
  schema1 = string(minLength(1))
` {
		t.Errorf("%s", bs)
	}
}

func TestSchemaSimpleNumber(t *testing.T) {
	schema1 := &SchemaOrReference{
		Oneof: &SchemaOrReference_Number{
			Number: &OASNumber{
				Common: &SchemaCommon{
					Type: "number",
				},
				Number: &SchemaNumber{
					Minimum: 1,
				},
			},
		},
	}
	schema2 := &SchemaOrReference{
		Oneof: &SchemaOrReference_Number{
			Number: &OASNumber{
				Common: &SchemaCommon{
					Type: "number",
				},
				Number: &SchemaNumber{
					Maximum: 1,
				},
			},
		},
	}
	hash := map[string]*SchemaOrReference{
		"schema1": schema1,
		"schema2": schema2,
	}
	body, err := schemaOrReferenceMapToBody(hash)
	if err != nil {
		t.Fatal(err)
	}
	bs, err := body.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	if string(bs) != `
  schema1 = number(minimum(1))
  schema2 = number(maximum(1))
` && string(bs) != `
  schema2 = number(maximum(1))
  schema1 = number(minimum(1))
` {
		t.Errorf("%s", bs)
	}
}

func TestSchemaSimpleArray(t *testing.T) {
	schema1 := &SchemaOrReference{
		Oneof: &SchemaOrReference_Array{
			Array: &OASArray{
				Common: &SchemaCommon{
					Type: "array",
				},
				Array: &SchemaArray{
					Items: []*SchemaOrReference{
						{
							Oneof: &SchemaOrReference_String_{
								String_: &OASString{
									Common: &SchemaCommon{
										Type: "string",
									},
									String_: &SchemaString{
										MinLength: 1,
									},
								},
							},
						},
					},
				},
			},
		},
	}
	hash := map[string]*SchemaOrReference{
		"schema1": schema1,
	}
	body, err := schemaOrReferenceMapToBody(hash)
	if err != nil {
		t.Fatal(err)
	}
	bs, err := body.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	if string(bs) != `
  schema1 = array([string(minLength(1))])
` {
		t.Errorf("%s", bs)
	}
}

func TestSchemaSimpleObject(t *testing.T) {
	schema1 := &SchemaOrReference{
		Oneof: &SchemaOrReference_Object{
			Object: &OASObject{
				Common: &SchemaCommon{
					Type: "object",
				},
				Object: &SchemaObject{
					Properties: map[string]*SchemaOrReference{
						"key1": {
							Oneof: &SchemaOrReference_String_{
								String_: &OASString{
									Common: &SchemaCommon{
										Type: "string",
									},
									String_: &SchemaString{
										MinLength: 1,
									},
								},
							},
						},
					},
				},
			},
		},
	}
	hash := map[string]*SchemaOrReference{
		"schema1": schema1,
	}
	body, err := schemaOrReferenceMapToBody(hash)
	if err != nil {
		t.Fatal(err)
	}
	bs, err := body.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	if string(bs) != `
  schema1 = object({
    key1 = string(minLength(1))
  })
` {
		t.Errorf("%s", bs)
	}
}

func TestSchemaSimpleAllOf(t *testing.T) {
	schema1 := &SchemaOrReference{
		Oneof: &SchemaOrReference_AllOf{
			AllOf: &SchemaAllOf{
				Items: []*SchemaOrReference{
					{
						Oneof: &SchemaOrReference_String_{
							String_: &OASString{
								Common: &SchemaCommon{
									Type: "string",
								},
								String_: &SchemaString{
									MinLength: 1,
								},
							},
						},
					},
				},
			},
		},
	}
	hash := map[string]*SchemaOrReference{
		"schema1": schema1,
	}
	body, err := schemaOrReferenceMapToBody(hash)
	if err != nil {
		t.Fatal(err)
	}
	bs, err := body.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	if string(bs) != `
  schema1 = allOf(string(minLength(1)))
` {
		t.Errorf("%s", bs)
	}
}

func TestSchemaSimpleAnyOf(t *testing.T) {
	schema1 := &SchemaOrReference{
		Oneof: &SchemaOrReference_AnyOf{
			AnyOf: &SchemaAnyOf{
				Items: []*SchemaOrReference{
					{
						Oneof: &SchemaOrReference_String_{
							String_: &OASString{
								Common: &SchemaCommon{
									Type: "string",
								},
								String_: &SchemaString{
									MinLength: 1,
								},
							},
						},
					},
				},
			},
		},
	}
	hash := map[string]*SchemaOrReference{
		"schema1": schema1,
	}
	body, err := schemaOrReferenceMapToBody(hash)
	if err != nil {
		t.Fatal(err)
	}
	bs, err := body.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	if string(bs) != `
  schema1 = anyOf(string(minLength(1)))
` {
		t.Errorf("%s", bs)
	}
}

func TestSchemaSimpleOneOf(t *testing.T) {
	schema1 := &SchemaOrReference{
		Oneof: &SchemaOrReference_OneOf{
			OneOf: &SchemaOneOf{
				Items: []*SchemaOrReference{
					{
						Oneof: &SchemaOrReference_String_{
							String_: &OASString{
								Common: &SchemaCommon{
									Type: "string",
								},
								String_: &SchemaString{
									MinLength: 1,
								},
							},
						},
					},
				},
			},
		},
	}
	hash := map[string]*SchemaOrReference{
		"schema1": schema1,
	}
	body, err := schemaOrReferenceMapToBody(hash)
	if err != nil {
		t.Fatal(err)
	}
	bs, err := body.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	if string(bs) != `
  schema1 = oneOf(string(minLength(1)))
` {
		t.Errorf("%s", bs)
	}
}

func TestSchemaSimpleMap(t *testing.T) {
	schema1 := &SchemaOrReference{
		Oneof: &SchemaOrReference_Map{
			Map: &OASMap{
				Common: &SchemaCommon{
					Type: "map",
				},
				Map: &SchemaMap{
					AdditionalProperties: &AdditionalPropertiesItem{
						Oneof: &AdditionalPropertiesItem_SchemaOrReference{
							SchemaOrReference: &SchemaOrReference{
								Oneof: &SchemaOrReference_String_{
									String_: &OASString{
										Common: &SchemaCommon{
											Type: "string",
										},
										String_: &SchemaString{
											MinLength: 1,
										},
									},
								},
							},
						},
					},
				},
			},
		},
	}
	schema2 := &SchemaOrReference{
		Oneof: &SchemaOrReference_Map{
			Map: &OASMap{
				Common: &SchemaCommon{
					Type: "map",
				},
				Map: &SchemaMap{
					AdditionalProperties: &AdditionalPropertiesItem{
						Oneof: &AdditionalPropertiesItem_Boolean{
							Boolean: true,
						},
					},
				},
			},
		},
	}

	hash := map[string]*SchemaOrReference{
		"schema1": schema1,
		"schema2": schema2,
	}
	body, err := SchemaOrReferenceMapToBody(hash)
	if err != nil {
		t.Fatal(err)
	}
	bs, err := body.MarshalHCL()
	if err != nil {
		t.Fatal(err)
	}
	if string(bs) != `
  schema1 = map(string(minLength(1)))
  schema2 = map(true)
` && string(bs) != `
  schema2 = map(true)
  schema1 = map(string(minLength(1)))
` {
		t.Errorf("%s", bs)
	}

	body1, err := light.ParseBody(bs)
	if err != nil {
		t.Fatal(err)
	}
	hash1, err := BodyToSchemaOrReferenceMap(body1)
	if err != nil {
		t.Fatal(err)
	}
	if hash1["schema1"].GetMap().Common.Type != "map" {
		t.Errorf("%+v", hash1["schema1"].GetMap().Common)
	}
	if hash1["schema1"].GetMap().Map.AdditionalProperties.GetSchemaOrReference().GetString_().Common.Type != "string" {
		t.Errorf("%+v", hash1["schema1"].GetMap().Map.AdditionalProperties)
	}
	if hash1["schema2"].GetMap().Common.Type != "map" {
		t.Errorf("%+v", hash1["schema2"].GetMap().Common)
	}
	if hash1["schema2"].GetMap().Map.AdditionalProperties.GetBoolean() != true {
		t.Errorf("%+v", hash1["schema2"].GetMap().Map.AdditionalProperties)
	}

	apiSchema1 := schemaOrReferenceToAPI(hash1["schema1"]).GetSchema().ToRawInfo()
	apiSchema2 := schemaOrReferenceToAPI(hash1["schema2"]).GetSchema().ToRawInfo()
	var sr1 map[string]interface{}
	var sr2 bool
	apiSchema1.Decode(&sr1)
	apiSchema2.Decode(&sr2)
	bs, err = json.Marshal(sr1)
	if err != nil {
		t.Fatal(err)
	}
	if string(bs) != `{"type":"object","additionalProperties":{"type":"string","minLength":1}}` && string(bs) != `{"additionalProperties":{"type":"string","minLength":1},"type":"object"}` &&
		string(bs) != `{"additionalProperties":{"minLength":1,"type":"string"},"type":"object"}` && string(bs) != `{"type":"object","additionalProperties":{"minLength":1,"type":"string"}}` {
		t.Errorf("%s", bs)
	}
	if sr2 {
		t.Errorf("%#v", sr2)
	}
}
