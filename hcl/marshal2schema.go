package hcl

import (
	"github.com/genelet/determined/dethcl"
	"github.com/genelet/hcllight/light"
)

func stringToLiteralValueExpr(s string) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_StringValue{
						StringValue: s,
					},
				},
			},
		},
	}
}

func int64ToLiteralValueExpr(i int64) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_NumberValue{
						NumberValue: float64(i),
					},
				},
			},
		},
	}
}

func doubleToLiteralValueExpr(f float64) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_NumberValue{
						NumberValue: f,
					},
				},
			},
		},
	}
}

func booleanToLiteralValueExpr(b bool) *light.Expression {
	return &light.Expression{
		ExpressionClause: &light.Expression_Lvexpr{
			Lvexpr: &light.LiteralValueExpr{
				Val: &light.CtyValue{
					CtyValueClause: &light.CtyValue_BoolValue{
						BoolValue: b,
					},
				},
			},
		},
	}
}

func stringsToTupleConsExpr(items []string) *light.Expression {
	tcexpr := &light.TupleConsExpr{}
	for _, item := range items {
		tcexpr.Exprs = append(tcexpr.Exprs, stringToLiteralValueExpr(item))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Tcexpr{
			Tcexpr: tcexpr,
		},
	}
}

func itemsToTupleConsExpr(items []*SchemaOrReference) *light.Expression {
	tcexpr := &light.TupleConsExpr{}
	for _, item := range items {
		expr := item.toExpression()
		tcexpr.Exprs = append(tcexpr.Exprs, expr)
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Tcexpr{
			Tcexpr: tcexpr,
		},
	}
}

func enumToTupleConsExpr(enum []*Any) *light.Expression {
	tcexpr := &light.TupleConsExpr{}
	for _, item := range enum {
		expr := item.toExpression()
		tcexpr.Exprs = append(tcexpr.Exprs, expr)
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Tcexpr{
			Tcexpr: tcexpr,
		},
	}
}

func hashToObjectConsExpr(hash map[string]*SchemaOrReference) *light.Expression {
	ocexpr := &light.ObjectConsExpr{}
	var items []*light.ObjectConsItem
	for name, item := range hash {
		expr := item.toExpression()
		items = append(items, &light.ObjectConsItem{
			KeyExpr:   stringToLiteralValueExpr(name),
			ValueExpr: expr,
		})
	}
	ocexpr.Items = items
	return &light.Expression{
		ExpressionClause: &light.Expression_Ocexpr{
			Ocexpr: ocexpr,
		},
	}
}

func anyMapToBody(content map[string]*Any) *light.Body {
	if content == nil {
		return nil
	}
	body := &light.Body{
		Attributes: make(map[string]*light.Attribute),
	}
	for k, v := range content {
		body.Attributes[k] = &light.Attribute{
			Name: k,
			Expr: v.toExpression(),
		}
	}
	return body
}

func encodingMapToBlocks(encodings map[string]*Encoding) ([]*light.Block, error) {
	if encodings == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range encodings {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "encoding",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}

func exampleOrReferenceMapToBlocks(examples map[string]*ExampleOrReference) ([]*light.Block, error) {
	if examples == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range examples {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "example",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}

func headerOrReferenceMapToBlocks(headers map[string]*HeaderOrReference) ([]*light.Block, error) {
	if headers == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range headers {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "header",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}

func linkOrReferenceMapToBlocks(links map[string]*LinkOrReference) ([]*light.Block, error) {
	if links == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range links {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "link",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}

func mediaTypeMapToBlocks(content map[string]*MediaType) ([]*light.Block, error) {
	if content == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range content {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "content",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}

func parameterOrReferenceMapToBlocks(parameters map[string]*ParameterOrReference) ([]*light.Block, error) {
	if parameters == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range parameters {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "parameter",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}

func requestBodyOrReferenceMapToBlocks(requestBodies map[string]*RequestBodyOrReference) ([]*light.Block, error) {
	if requestBodies == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range requestBodies {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "requestBody",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}

func responseOrReferenceMapToBlocks(responses map[string]*ResponseOrReference) ([]*light.Block, error) {
	if responses == nil {
		return nil, nil
	}
	var blocks []*light.Block
	for k, v := range responses {
		bdy, err := v.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type:   "response",
			Labels: []string{k},
			Bdy:    bdy,
		})
	}
	return blocks, nil
}

func schemaOrReferenceMapToBody(schemas map[string]*SchemaOrReference) *light.Body {
	if schemas == nil {
		return nil
	}
	body := &light.Body{
		Attributes: make(map[string]*light.Attribute),
	}
	for k, v := range schemas {
		expr := v.toExpression()
		body.Attributes[k] = &light.Attribute{
			Name: k,
			Expr: expr,
		}
	}
	return body
}

func toBody(x interface{}) (*light.Body, error) {
	bs, err := dethcl.Marshal(x)
	if err != nil {
		return nil, err
	}
	return light.Parse(bs)
}

func toBlock(x interface{}, t string) (*light.Block, error) {
	body, err := toBody(x)
	if err != nil {
		return nil, err
	}
	return &light.Block{
		Type: t,
		Bdy:  body,
	}, nil
}

func (self *SchemaOrReference) MarshalHCL() ([]byte, error) {
	expr := self.toExpression()
	if expr == nil {
		return nil, nil
	}
	str, err := expr.HclExpression()
	return []byte(str), err
}

func (s *SchemaOrReference) toExpression() *light.Expression {
	if s == nil {
		return nil
	}

	var name string
	var args []*light.Expression

	switch s.Oneof.(type) {
	case *SchemaOrReference_Reference:
		t := s.GetReference()
		return t.toExpression()
	case *SchemaOrReference_Array:
		t := s.GetArray()
		name = t.Type
		items := itemsToTupleConsExpr(t.Items)
		args = []*light.Expression{items}
		if name != "array" {
			break
		}
		if t.MinItems != 0 || t.MaxItems != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MinItems))
			args = append(args, int64ToLiteralValueExpr(t.MaxItems))
		}
		if t.UniqueItems {
			args = append(args, booleanToLiteralValueExpr(t.UniqueItems))
		}
	case *SchemaOrReference_Map:
		t := s.GetMap()
		name = "map"
		ap := t.AdditionalProperties
		if ap != nil {
			switch ap.Oneof.(type) {
			case *AdditionalPropertiesItem_SchemaOrReference:
				x := ap.GetSchemaOrReference()
				args = append(args, x.toExpression())
			case *AdditionalPropertiesItem_Boolean:
				x := ap.GetBoolean()
				if x {
					args = append(args, booleanToLiteralValueExpr(x))
				}

			default:
				panic("no a datatype")
			}
		}
	case *SchemaOrReference_Object:
		t := s.GetObject()
		name = t.Type
		properties := hashToObjectConsExpr(t.Properties)
		args = []*light.Expression{properties}
		if t.MinProperties != 0 || t.MaxProperties != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MinProperties))
			args = append(args, int64ToLiteralValueExpr(t.MaxProperties))
		}
		if t.Required != nil {
			required := stringsToTupleConsExpr(t.Required)
			args = append(args, required)
		}
	case *SchemaOrReference_String_:
		t := s.GetString_()
		name = t.Type
		args = append(args, stringToLiteralValueExpr(t.Format))
		if t.MinLength != 0 || t.MaxLength != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MinLength))
			args = append(args, int64ToLiteralValueExpr(t.MaxLength))
		}
		if t.Pattern != "" {
			args = append(args, stringToLiteralValueExpr(t.Pattern))
		}
	case *SchemaOrReference_Number:
		t := s.GetNumber()
		name = t.Type
		args = append(args, stringToLiteralValueExpr(t.Format))
		if t.Minimum != 0 || t.Maximum != 0 || t.ExclusiveMinimum || t.ExclusiveMaximum {
			args = append(args, doubleToLiteralValueExpr(t.Minimum))
			args = append(args, doubleToLiteralValueExpr(t.Maximum))
			args = append(args, booleanToLiteralValueExpr(t.ExclusiveMinimum))
			args = append(args, booleanToLiteralValueExpr(t.ExclusiveMaximum))
		}
		if t.MultipleOf != 0 {
			args = append(args, doubleToLiteralValueExpr(t.MultipleOf))
		}
	case *SchemaOrReference_Integer:
		t := s.GetInteger()
		name = t.Type
		args = append(args, stringToLiteralValueExpr(t.Format))
		if t.Minimum != 0 || t.Maximum != 0 || t.ExclusiveMinimum || t.ExclusiveMaximum {
			args = append(args, int64ToLiteralValueExpr(t.Minimum))
			args = append(args, int64ToLiteralValueExpr(t.Maximum))
			args = append(args, booleanToLiteralValueExpr(t.ExclusiveMinimum))
			args = append(args, booleanToLiteralValueExpr(t.ExclusiveMaximum))
		}
		if t.MultipleOf != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MultipleOf))
		}
	case *SchemaOrReference_Boolean:
		t := s.GetBoolean()
		name = t.Type
		if t.Default {
			args = append(args, booleanToLiteralValueExpr(t.Default))
		}
	case *SchemaOrReference_Schema:
		body, err := s.GetSchema().toHCL()
		if err != nil {
			panic(err)
		}
		return &light.Expression{
			ExpressionClause: &light.Expression_Ocexpr{
				Ocexpr: body.ToObjectConsExpr(),
			},
		}
	default:
	}

	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: name,
				Args: args,
			},
		},
	}
}

func (self *Schema) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Schema) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"nullable":         self.Nullable,
		"readOnly":         self.ReadOnly,
		"writeOnly":        self.WriteOnly,
		"deprecated":       self.Deprecated,
		"exclusiveMaximum": self.ExclusiveMaximum,
		"exclusiveMinimum": self.ExclusiveMinimum,
		"uniqueItems":      self.UniqueItems,
	}
	mapStrings := map[string]string{
		"title":       self.Title,
		"type":        self.Type,
		"description": self.Description,
		"format":      self.Format,
		"pattern":     self.Pattern,
	}
	mapInts := map[string]int64{
		"maxLength":     self.MaxLength,
		"minLength":     self.MinLength,
		"maxItems":      self.MaxItems,
		"minItems":      self.MinItems,
		"maxProperties": self.MaxProperties,
		"minProperties": self.MinProperties,
	}
	mapFloats := map[string]float64{
		"multipleOf": self.MultipleOf,
		"maximum":    self.Maximum,
		"minimum":    self.Minimum,
	}
	mapArrays := map[string][]*SchemaOrReference{
		"allOf": self.AllOf,
		"anyOf": self.AnyOf,
		"oneOf": self.OneOf,
		"items": self.Items,
	}
	for k, v := range mapBools {
		if v {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: booleanToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapInts {
		if v != 0 {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: int64ToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapFloats {
		if v != 0 {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: doubleToLiteralValueExpr(v),
			}
		}
	}
	for k, v := range mapArrays {
		if v != nil {
			expr := itemsToTupleConsExpr(v)
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: expr,
			}
		}
	}
	if self.Enum != nil {
		expr := enumToTupleConsExpr(self.Enum)
		attrs["enum"] = &light.Attribute{
			Name: "enum",
			Expr: expr,
		}
	}
	if self.Default != nil {
		expr := self.Default.toExpression()
		attrs["default"] = &light.Attribute{
			Name: "default",
			Expr: expr,
		}
	}
	if self.Example != nil {
		expr := self.Example.toExpression()
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: expr,
		}
	}
	if self.Discriminator != nil {
		block, err := toBlock(self.Discriminator, "discriminator")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, block)
	}
	if self.ExternalDocs != nil {
		block, err := toBlock(self.ExternalDocs, "externalDocs")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, block)
	}
	if self.Xml != nil {
		block, err := toBlock(self.Xml, "xml")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, block)
	}

	if self.Not != nil {
		expr := self.Not.toExpression()
		attrs["not"] = &light.Attribute{
			Name: "not",
			Expr: expr,
		}
	}

	if self.Properties != nil {
		expr := hashToObjectConsExpr(self.Properties)
		blocks = append(blocks, &light.Block{
			Type: "properties",
			Bdy:  expr.GetOcexpr().ToBody(),
		})
	}
	if self.AdditionalProperties != nil {
		switch self.AdditionalProperties.Oneof.(type) {
		case *AdditionalPropertiesItem_SchemaOrReference:
			t := self.AdditionalProperties.GetSchemaOrReference()
			expr := t.toExpression()
			attrs["additionalProperties"] = &light.Attribute{
				Name: "additionalProperties",
				Expr: expr,
			}
		case *AdditionalPropertiesItem_Boolean:
			t := self.AdditionalProperties.GetBoolean()
			expr := booleanToLiteralValueExpr(t)
			attrs["additionalProperties"] = &light.Attribute{
				Name: "additionalProperties",
				Expr: expr,
			}
		default:
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
