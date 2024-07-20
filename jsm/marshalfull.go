package jsm

import (
	"github.com/genelet/hcllight/light"
	"github.com/google/gnostic/jsonschema"
	"gopkg.in/yaml.v3"
)

func commonToAttributes(self *Common, attrs map[string]*light.Attribute) error {
	if self.Type != nil {
		attrs["type"] = &light.Attribute{
			Name: "type",
			Expr: stringOrStringArrayToExpression(self.Type),
		}

	}
	if self.Format != nil {
		attrs["format"] = &light.Attribute{
			Name: "format",
			Expr: light.StringToTextValueExpr(*self.Format),
		}
	}
	if self.Default != nil {
		attrs["default"] = &light.Attribute{
			Name: "default",
			Expr: light.StringToLiteralValueExpr(self.Default.Value),
		}
	}
	if self.Enumeration != nil {
		expr, err := enumToTupleConsExpr(self.Enumeration)
		if err != nil {
			return err
		}
		attrs["enum"] = &light.Attribute{
			Name: "enum",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: expr,
				},
			},
		}
	}
	return nil
}

func attributesToCommon(attrs map[string]*light.Attribute) (*Common, error) {
	common := &Common{}

	var err error
	var found bool

	for _, attr := range attrs {
		switch attr.Name {
		case "type":
			common.Type = expressionToStringOrStringArray(attr.Expr)
			found = true
		case "format":
			common.Format = light.TextValueExprToString(attr.Expr)
			found = true
		case "default":
			common.Default = &yaml.Node{
				Kind: yaml.ScalarNode,
				//Value: *light.LiteralValueExprToString(attr.Expr),
				Value: attr.Expr.String(),
			}
			found = true
		case "enum":
			common.Enumeration, err = tupleConsExprToEnum(attr.Expr.GetTcexpr())
		default:
		}
	}

	if found {
		return common, err
	}
	return nil, nil
}

func numberToAttributes(self *SchemaNumber, attrs map[string]*light.Attribute) error {
	if self.Minimum != nil {
		if self.Minimum.Float != nil {
			attrs["minimum"] = &light.Attribute{
				Name: "minimum",
				Expr: light.Float64ToLiteralValueExpr(*self.Minimum.Float),
			}
		} else {
			attrs["minimum"] = &light.Attribute{
				Name: "minimum",
				Expr: light.Int64ToLiteralValueExpr(*self.Minimum.Integer),
			}
		}
	}
	if self.Maximum != nil {
		if self.Maximum.Float != nil {
			attrs["maximum"] = &light.Attribute{
				Name: "maximum",
				Expr: light.Float64ToLiteralValueExpr(*self.Maximum.Float),
			}
		} else {
			attrs["maximum"] = &light.Attribute{
				Name: "maximum",
				Expr: light.Int64ToLiteralValueExpr(*self.Maximum.Integer),
			}
		}
	}
	if self.ExclusiveMinimum != nil {
		attrs["exclusiveMinimum"] = &light.Attribute{
			Name: "exclusiveMinimum",
			Expr: light.BooleanToLiteralValueExpr(*self.ExclusiveMinimum),
		}
	}
	if self.ExclusiveMaximum != nil {
		attrs["exclusiveMaximum"] = &light.Attribute{
			Name: "exclusiveMaximum",
			Expr: light.BooleanToLiteralValueExpr(*self.ExclusiveMaximum),
		}
	}
	if self.MultipleOf != nil {
		if self.MultipleOf.Float != nil {
			attrs["multipleOf"] = &light.Attribute{
				Name: "multipleOf",
				Expr: light.Float64ToLiteralValueExpr(*self.MultipleOf.Float),
			}
		} else {
			attrs["multipleOf"] = &light.Attribute{
				Name: "multipleOf",
				Expr: light.Int64ToLiteralValueExpr(*self.MultipleOf.Integer),
			}
		}
	}
	return nil
}

func attributesToNumber(attrs map[string]*light.Attribute, typ ...*jsonschema.StringOrStringArray) (*SchemaNumber, error) {
	number := &SchemaNumber{}

	var err error
	var found bool

	for _, attr := range attrs {
		switch attr.Name {
		case "minimum":
			if typ != nil && typ[0].String != nil && *typ[0].String == "integer" {
				number.Minimum = &jsonschema.SchemaNumber{
					Integer: light.LiteralValueExprToInt64(attr.Expr),
				}
			} else {
				number.Minimum = &jsonschema.SchemaNumber{
					Float: light.LiteralValueExprToFloat64(attr.Expr),
				}
			}
			found = true
		case "maximum":
			if typ != nil && typ[0].String != nil && *typ[0].String == "integer" {
				number.Maximum = &jsonschema.SchemaNumber{
					Integer: light.LiteralValueExprToInt64(attr.Expr),
				}
			} else {
				number.Maximum = &jsonschema.SchemaNumber{
					Float: light.LiteralValueExprToFloat64(attr.Expr),
				}
			}
			found = true
		case "exclusiveMinimum":
			number.ExclusiveMinimum = light.LiteralValueExprToBoolean(attr.Expr)
			found = true
		case "exclusiveMaximum":
			number.ExclusiveMaximum = light.LiteralValueExprToBoolean(attr.Expr)
			found = true
		case "multipleOf":
			if typ != nil && typ[0].String != nil && *typ[0].String == "integer" {
				number.MultipleOf = &jsonschema.SchemaNumber{
					Integer: light.LiteralValueExprToInt64(attr.Expr),
				}
			} else {
				number.MultipleOf = &jsonschema.SchemaNumber{
					Float: light.LiteralValueExprToFloat64(attr.Expr),
				}
			}
			found = true
		default:
		}
	}

	if found {
		return number, err
	}
	return nil, nil
}

func stringToAttributes(self *SchemaString, attrs map[string]*light.Attribute) error {
	if self.MaxLength != nil {
		attrs["maxLength"] = &light.Attribute{
			Name: "maxLength",
			Expr: light.Int64ToLiteralValueExpr(*self.MaxLength),
		}
	}
	if self.MinLength != nil {
		attrs["minLength"] = &light.Attribute{
			Name: "minLength",
			Expr: light.Int64ToLiteralValueExpr(*self.MinLength),
		}
	}
	if self.Pattern != nil {
		attrs["pattern"] = &light.Attribute{
			Name: "pattern",
			Expr: light.StringToTextValueExpr(*self.Pattern),
		}
	}
	return nil
}

func attributesToString(attrs map[string]*light.Attribute) (*SchemaString, error) {
	str := &SchemaString{}

	var err error
	var found bool

	for _, attr := range attrs {
		switch attr.Name {
		case "maxLength":
			str.MaxLength = light.LiteralValueExprToInt64(attr.Expr)
			found = true
		case "minLength":
			str.MinLength = light.LiteralValueExprToInt64(attr.Expr)
			found = true
		case "pattern":
			str.Pattern = light.TextValueExprToString(attr.Expr)
			found = true
		default:
		}
	}

	if found {
		return str, err
	}
	return nil, nil
}

func arrayToAttributes(self *SchemaArray, attrs map[string]*light.Attribute) error {
	if self.MaxItems != nil {
		attrs["maxItems"] = &light.Attribute{
			Name: "maxItems",
			Expr: light.Int64ToLiteralValueExpr(*self.MaxItems),
		}
	}
	if self.MinItems != nil {
		attrs["minItems"] = &light.Attribute{
			Name: "minItems",
			Expr: light.Int64ToLiteralValueExpr(*self.MinItems),
		}
	}
	if self.UniqueItems != nil {
		attrs["uniqueItems"] = &light.Attribute{
			Name: "uniqueItems",
			Expr: light.BooleanToLiteralValueExpr(*self.UniqueItems),
		}
	}
	if self.Items != nil {
		expr, err := schemaOrSchemaArrayToExpression(self.Items)
		if err != nil {
			return err
		}
		attrs["items"] = &light.Attribute{
			Name: "items",
			Expr: expr,
		}
	}
	return nil
}

func attributesToArray(attrs map[string]*light.Attribute) (*SchemaArray, error) {
	array := &SchemaArray{}

	var err error
	var found bool

	for _, attr := range attrs {
		switch attr.Name {
		case "maxItems":
			array.MaxItems = light.LiteralValueExprToInt64(attr.Expr)
			found = true
		case "minItems":
			array.MinItems = light.LiteralValueExprToInt64(attr.Expr)
			found = true
		case "uniqueItems":
			array.UniqueItems = light.LiteralValueExprToBoolean(attr.Expr)
			found = true
		case "items":
			array.Items, err = expressionToSchemaOrSchemaArray(attr.Expr)
			found = true
		default:
		}
	}

	if found {
		return array, err
	}
	return nil, nil
}

func objectToAttributesBlocks(self *SchemaObject, attrs map[string]*light.Attribute) error {
	if self.MaxProperties != nil {
		attrs["maxProperties"] = &light.Attribute{
			Name: "maxProperties",
			Expr: light.Int64ToLiteralValueExpr(*self.MaxProperties),
		}
	}
	if self.MinProperties != nil {
		attrs["minProperties"] = &light.Attribute{
			Name: "minProperties",
			Expr: light.Int64ToLiteralValueExpr(*self.MinProperties),
		}
	}
	if self.Required != nil {
		attrs["required"] = &light.Attribute{
			Name: "required",
			Expr: light.StringArrayToTupleConsEpr(self.Required),
		}
	}
	if self.Properties != nil {
		bdy, err := mapSchemaToBody(self.Properties)
		if err != nil {
			return err
		}
		attrs["properties"] = &light.Attribute{
			Name: "properties",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Ocexpr{
					Ocexpr: bdy.ToObjectConsExpr(),
				},
			},
		}
	}

	return nil
}

func attributesBlocksToObject(attrs map[string]*light.Attribute) (*SchemaObject, error) {
	object := &SchemaObject{}

	var err error
	var found bool

	for _, attr := range attrs {
		switch attr.Name {
		case "maxProperties":
			object.MaxProperties = light.LiteralValueExprToInt64(attr.Expr)
			found = true
		case "minProperties":
			object.MinProperties = light.LiteralValueExprToInt64(attr.Expr)
			found = true
		case "required":
			object.Required = light.TupleConsExprToStringArray(attr.Expr)
			found = true
		case "properties":
			object.Properties, err = bodyToMapSchema(attr.Expr.GetOcexpr().ToBody())
			found = true
		default:
		}
	}

	if found {
		return object, err
	}
	return nil, nil
}

func mapToAttributes(self *SchemaMap, attrs map[string]*light.Attribute) error {
	if self.AdditionalProperties.Schema != nil {
		expr, err := schemaToExpression(self.AdditionalProperties.Schema)
		if err != nil {
			return err
		}
		attrs["additionalProperties"] = &light.Attribute{
			Name: "additionalProperties",
			Expr: expr,
		}
	} else {
		attrs["additionalProperties"] = &light.Attribute{
			Name: "additionalProperties",
			Expr: light.BooleanToLiteralValueExpr(*self.AdditionalProperties.Boolean),
		}
	}

	return nil
}

func attributesToMap(attrs map[string]*light.Attribute) (*SchemaMap, error) {
	mmap := &SchemaMap{
		AdditionalProperties: &SchemaOrBoolean{},
	}

	var err error
	var found bool

	for _, attr := range attrs {
		switch attr.Name {
		case "additionalProperties":
			switch attr.Expr.ExpressionClause.(type) {
			case *light.Expression_Ocexpr, *light.Expression_Stexpr:
				mmap.AdditionalProperties.Schema, err = expressionToSchema(attr.Expr)
			default:
				mmap.AdditionalProperties.Boolean = light.LiteralValueExprToBoolean(attr.Expr)
			}
			found = true
		default:
		}
	}

	if found {
		return mmap, err
	}
	return nil, nil
}

func shortsToBody(
	reference *Reference,
	common *Common,
	number *SchemaNumber,
	str *SchemaString,
	array *SchemaArray,
	object *SchemaObject,
	mmap *SchemaMap,
) (*light.Body, error) {
	var body *light.Body
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)

	if reference != nil {
		if ex, err := referenceToExpression(*reference.Ref); err != nil {
			attrs["$ref"] = &light.Attribute{
				Name: "$ref",
				Expr: ex,
			}
		}
	}
	if common != nil {
		if err := commonToAttributes(common, attrs); err != nil {
			return nil, err
		}
	}
	if number != nil {
		if err := numberToAttributes(number, attrs); err != nil {
			return nil, err
		}
	}
	if str != nil {
		if err := stringToAttributes(str, attrs); err != nil {
			return nil, err
		}
	}
	if array != nil {
		if err := arrayToAttributes(array, attrs); err != nil {
			return nil, err
		}
	}
	if object != nil {
		if err := objectToAttributesBlocks(object, attrs); err != nil {
			return nil, err
		}
	}
	if mmap != nil {
		if err := mapToAttributes(mmap, attrs); err != nil {
			return nil, err
		}
	}
	if len(attrs) > 0 {
		body = &light.Body{
			Attributes: attrs,
		}
	}
	if len(blocks) > 0 {
		if body == nil {
			body = &light.Body{}
		}
		body.Blocks = blocks
	}
	return body, nil
}

func bodyToShorts(body *light.Body) (*Reference, *Common, *SchemaNumber, *SchemaString, *SchemaArray, *SchemaObject, *SchemaMap, error) {
	seven := func(err error) (*Reference, *Common, *SchemaNumber, *SchemaString, *SchemaArray, *SchemaObject, *SchemaMap, error) {
		return nil, nil, nil, nil, nil, nil, nil, err
	}
	var reference *Reference
	common, err := attributesToCommon(body.Attributes)
	if err != nil {
		return seven(err)
	}
	schemaNumber, err := attributesToNumber(body.Attributes)
	if err != nil {
		return seven(err)
	}
	schemaString, err := attributesToString(body.Attributes)
	if err != nil {
		return seven(err)
	}
	schemaArray, err := attributesToArray(body.Attributes)
	if err != nil {
		return seven(err)
	}
	schemaObject, err := attributesBlocksToObject(body.Attributes)
	if err != nil {
		return seven(err)
	}
	schemaMap, err := attributesToMap(body.Attributes)
	if err != nil {
		return seven(err)
	}

	for name, attr := range body.Attributes {
		if name == "ref" {
			ref, err := expressionToReference(attr.Expr)
			if err != nil {
				return seven(err)
			}
			reference = &Reference{Ref: &ref}
			continue
		}

		if fcexp := attr.Expr.GetFcexpr(); fcexp != nil {
			schema, err := fcexprToSchema(fcexp)
			if err != nil {
				return seven(err)
			}
			if schema.Common != nil {
				common = schema.Common
			}
			if schema.SchemaNumber != nil {
				schemaNumber = schema.SchemaNumber
			}
			if schema.SchemaString != nil {
				schemaString = schema.SchemaString
			}
			if schema.SchemaArray != nil {
				schemaArray = schema.SchemaArray
			}
			if schema.SchemaObject != nil {
				schemaObject = schema.SchemaObject
			}
			if schema.SchemaMap != nil {
				schemaMap = schema.SchemaMap
			}
			continue
		}
	}

	return reference, common, schemaNumber, schemaString, schemaArray, schemaObject, schemaMap, nil
}

func schemaFullToBody(self *SchemaFull) (*light.Body, error) {
	body, err := shortsToBody(
		self.Reference,
		self.Common,
		self.SchemaNumber,
		self.SchemaString,
		self.SchemaArray,
		self.SchemaObject,
		self.SchemaMap,
	)
	if err != nil {
		return nil, err
	}

	if body == nil {
		body = &light.Body{}
	}
	attrs := body.Attributes
	blocks := body.Blocks
	if attrs == nil {
		attrs = make(map[string]*light.Attribute)
	}
	if blocks == nil {
		blocks = make([]*light.Block, 0)
	}

	if self.Schema != nil {
		attrs["schema"] = &light.Attribute{
			Name: "schema",
			Expr: light.StringToTextValueExpr(*self.Schema),
		}
	}
	if self.ID != nil {
		attrs["id"] = &light.Attribute{
			Name: "id",
			Expr: light.StringToTextValueExpr(*self.ID),
		}
	}
	if self.ReadOnly != nil {
		attrs["readOnly"] = &light.Attribute{
			Name: "readOnly",
			Expr: light.BooleanToLiteralValueExpr(*self.ReadOnly),
		}
	}
	if self.WriteOnly != nil {
		attrs["writeOnly"] = &light.Attribute{
			Name: "writeOnly",
			Expr: light.BooleanToLiteralValueExpr(*self.WriteOnly),
		}
	}
	if self.AdditionalItems != nil {
		ex, err := schemaOrBooleanToExpression(self.AdditionalItems)
		if err != nil {
			return nil, err
		}
		attrs["additionalItems"] = &light.Attribute{
			Name: "additionalItems",
			Expr: ex,
		}
	}
	if self.PatternProperties != nil {
		bdy, err := mapSchemaToBody(self.PatternProperties)
		if err != nil {
			return nil, err
		}
		attrs["patternProperties"] = &light.Attribute{
			Name: "patternProperties",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Ocexpr{
					Ocexpr: bdy.ToObjectConsExpr(true),
				},
			},
		}
	}
	if self.Definitions != nil {
		bdy, err := mapSchemaToBody(self.Definitions)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "definitions",
			Bdy:  bdy,
		})
	}
	if self.Dependencies != nil {
		bdy, err := mapSchemaOrStringArrayToBody(self.Dependencies)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "dependencies",
			Bdy:  bdy,
		})
	}
	if self.AllOf != nil {
		expr, err := sliceToTupleConsExpr(self.AllOf)
		if err != nil {
			return nil, err
		}
		attrs["allOf"] = &light.Attribute{
			Name: "allOf",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: expr,
				},
			},
		}
	}
	if self.OneOf != nil {
		expr, err := sliceToTupleConsExpr(self.OneOf)
		if err != nil {
			return nil, err
		}
		attrs["oneOf"] = &light.Attribute{
			Name: "oneOf",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: expr,
				},
			},
		}
	}
	if self.AnyOf != nil {
		expr, err := sliceToTupleConsExpr(self.AnyOf)
		if err != nil {
			return nil, err
		}
		attrs["anyOf"] = &light.Attribute{
			Name: "anyOf",
			Expr: &light.Expression{
				ExpressionClause: &light.Expression_Tcexpr{
					Tcexpr: expr,
				},
			},
		}
	}
	if self.Not != nil {
		expr, err := schemaToExpression(self.Not)
		if err != nil {
			return nil, err
		}
		attrs["not"] = &light.Attribute{
			Name: "not",
			Expr: expr,
		}
	}
	if self.Title != nil {
		attrs["title"] = &light.Attribute{
			Name: "title",
			Expr: light.StringToTextValueExpr(*self.Title),
		}
	}
	if self.Description != nil {
		attrs["description"] = &light.Attribute{
			Name: "description",
			Expr: light.StringToTextValueExpr(*self.Description),
		}
	}

	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func bodyToSchemaFull(body *light.Body) (*SchemaFull, error) {
	reference, common, number, str, array, object, mmap, err := bodyToShorts(body)
	if err != nil {
		return nil, err
	}

	full := &SchemaFull{
		Reference:    reference,
		Common:       common,
		SchemaNumber: number,
		SchemaString: str,
		SchemaArray:  array,
		SchemaObject: object,
		SchemaMap:    mmap,
	}

	if body.Attributes != nil {
		for name, attr := range body.Attributes {
			switch name {
			case "schema":
				full.Schema = light.LiteralValueExprToString(attr.Expr)
			case "id":
				full.ID = light.LiteralValueExprToString(attr.Expr)
			case "readOnly":
				full.ReadOnly = light.LiteralValueExprToBoolean(attr.Expr)
			case "writeOnly":
				full.WriteOnly = light.LiteralValueExprToBoolean(attr.Expr)
			case "additionalItems":
				full.AdditionalItems, err = expressionToSchemaOrBoolean(attr.Expr)
			case "patternProperties":
				full.PatternProperties, err = bodyToMapSchema(attr.Expr.GetOcexpr().ToBody())
			default:
			}
		}
	}

	if body.Blocks != nil {
		for _, block := range body.Blocks {
			switch block.Type {
			case "definitions":
				full.Definitions, err = bodyToMapSchema(block.Bdy)
			case "dependencies":
				full.Dependencies, err = bodyToMapSchemaOrStringArray(block.Bdy)
			}
		}
	}

	return full, err
}
