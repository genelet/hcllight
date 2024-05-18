package hcl

import (
	"github.com/genelet/hcllight/light"
)

func defaultTypeToExpression(d *DefaultType) *light.Expression {
	if d == nil {
		return nil
	}
	switch d.Oneof.(type) {
	case *DefaultType_Boolean:
		t := d.GetBoolean()
		return booleanToLiteralValueExpr(t)
	case *DefaultType_Number:
		t := d.GetNumber()
		return float64ToLiteralValueExpr(t)
	case *DefaultType_String_:
		t := d.GetString_()
		return stringToTextValueExpr(t)
	default:
	}
	return nil
}

func expressionToDefaultType(e *light.Expression) *DefaultType {
	if e == nil {
		return nil
	}
	switch e.ExpressionClause.(type) {
	case *light.Expression_Lvexpr:
		t := e.GetLvexpr().GetVal()
		switch t.CtyValueClause.(type) {
		case *light.CtyValue_BooleanValue:
			return &DefaultType{
				Oneof: &DefaultType_Boolean{
					Boolean: t.GetBooleanValue(),
				},
			}
		case *light.CtyValue_NumberValue:
			return &DefaultType{
				Oneof: &DefaultType_Number{
					Number: t.GetNumberValue(),
				},
			}
		case *light.CtyValue_StringValue:
			return &DefaultType{
				Oneof: &DefaultType_String_{
					String_: t.GetStringValue(),
				},
			}
		default:
		}
	default:
	}
	return nil
}

func enumToTupleConsExpr(enumeration []*Any) (*light.TupleConsExpr, error) {
	if len(enumeration) == 0 {
		return nil, nil
	}

	var enums []*light.Expression
	for _, e := range enumeration {
		enums = append(enums, stringToTextValueExpr(e.GetYaml()))
	}

	if len(enums) == 0 {
		return nil, nil
	}

	return &light.TupleConsExpr{
		Exprs: enums,
	}, nil
}

func tupleConsExprToEnum(t *light.TupleConsExpr) ([]*Any, error) {
	if t == nil {
		return nil, nil
	}

	var enums []*Any
	for _, e := range t.Exprs {
		enums = append(enums, &Any{Yaml: *textValueExprToString(e)})
	}

	if len(enums) == 0 {
		return nil, nil
	}

	return enums, nil
}

func commonToAttributes(self *SchemaCommon, attrs map[string]*light.Attribute) error {
	if self.Type != "" {
		attrs["type"] = &light.Attribute{
			Name: "type",
			Expr: stringToTextValueExpr(self.Type),
		}
	}
	if self.Format != "" {
		attrs["format"] = &light.Attribute{
			Name: "format",
			Expr: stringToTextValueExpr(self.Format),
		}
	}
	if self.Default != nil {
		attrs["default"] = &light.Attribute{
			Name: "default",
			Expr: stringToLiteralValueExpr(self.Default.String()),
		}
	}
	if self.Enum != nil {
		expr, err := enumToTupleConsExpr(self.Enum)
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

func attributesToCommon(attrs map[string]*light.Attribute) (*SchemaCommon, error) {
	common := &SchemaCommon{}
	if v, ok := attrs["type"]; ok {
		common.Type = *textValueExprToString(v.Expr)
	}
	if v, ok := attrs["format"]; ok {
		common.Format = *textValueExprToString(v.Expr)
	}
	if v, ok := attrs["default"]; ok {
		common.Default = &DefaultType{
			Oneof: &DefaultType_Yaml{
				Yaml: *literalValueToString(v.Expr),
			},
		}
	}
	if v, ok := attrs["enum"]; ok {
		enums, err := tupleConsExprToEnum(v.Expr.GetTcexpr())
		if err != nil {
			return nil, err
		}
		common.Enum = enums
	}
	return common, nil
}

func (self *Reference) toBody() *light.Body {
	body := &light.Body{
		Attributes: map[string]*light.Attribute{
			"XRef": {
				Name: "XRef",
				Expr: stringToTextValueExpr(self.XRef),
			},
		},
	}
	if self.Summary != "" {
		body.Attributes["summary"] = &light.Attribute{
			Name: "summary",
			Expr: stringToTextValueExpr(self.Summary),
		}
	}
	if self.Description != "" {
		body.Attributes["description"] = &light.Attribute{
			Name: "description",
			Expr: stringToTextValueExpr(self.Description),
		}
	}
	return body
}

func (self *Reference) toExpression() *light.Expression {
	if self.Summary == "" && self.Description == "" && (self.XRef)[:2] == "#/" {
		return stringToTraversal((self.XRef)[:2])
	}

	args := []*light.Expression{
		stringToLiteralValueExpr(self.XRef),
	}
	if self.Summary != "" {
		args = append(args, stringToTextValueExpr(self.Summary))
	}
	if self.Description != "" {
		args = append(args, stringToTextValueExpr(self.Description))
	}
	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: "reference",
				Args: args,
			},
		},
	}
}

func (s *SchemaOrReference) toHCL() (*light.Body, error) {
	if s == nil {
		return nil, nil
	}
	switch s.Oneof.(type) {
	case *SchemaOrReference_Reference:
		t := s.GetReference()
		return t.toBody(), nil
	case *SchemaOrReference_Schema:
		return s.GetSchema().toHCL()
	default: // we ignore all other types, meaning we have to assign type Schema when parsing Components.Schemas
	}
	return nil, nil
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
			}
		}
	case *SchemaOrReference_Object:
		t := s.GetObject()
		name = t.Type
		properties := schemaOrReferenceToObjectConsExpr(t.Properties)
		args = []*light.Expression{properties}
		if t.MinProperties != 0 || t.MaxProperties != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MinProperties))
			args = append(args, int64ToLiteralValueExpr(t.MaxProperties))
		}
		if t.Required != nil {
			required := stringArrayToTupleConsEpr(t.Required)
			args = append(args, required)
		}
	case *SchemaOrReference_String_:
		t := s.GetString_()
		name = t.Type
		args = append(args, stringToTextValueExpr(t.Format))
		if t.MinLength != 0 || t.MaxLength != 0 {
			args = append(args, int64ToLiteralValueExpr(t.MinLength))
			args = append(args, int64ToLiteralValueExpr(t.MaxLength))
		}
		if t.Pattern != "" {
			args = append(args, stringToTextValueExpr(t.Pattern))
		}
		if t.Default != "" {
			args = append(args, stringToTextValueExpr(t.Default))
		}
		if t.Enum != nil {
			args = append(args, enumToTupleConsExpr(t.Enum))
		}
	case *SchemaOrReference_Number:
		t := s.GetNumber()
		name = t.Type
		args = append(args, stringToTextValueExpr(t.Format))
		if t.Minimum != 0 || t.Maximum != 0 || t.ExclusiveMinimum || t.ExclusiveMaximum {
			args = append(args, float64ToLiteralValueExpr(t.Minimum))
			args = append(args, float64ToLiteralValueExpr(t.Maximum))
			args = append(args, booleanToLiteralValueExpr(t.ExclusiveMinimum))
			args = append(args, booleanToLiteralValueExpr(t.ExclusiveMaximum))
		}
		if t.MultipleOf != 0 {
			args = append(args, float64ToLiteralValueExpr(t.MultipleOf))
		}
	case *SchemaOrReference_Integer:
		t := s.GetInteger()
		name = t.Type
		args = append(args, stringToTextValueExpr(t.Format))
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
				Expr: stringToTextValueExpr(v),
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
				Expr: float64ToLiteralValueExpr(v),
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
		bdy, err := self.Discriminator.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "discriminator",
			Bdy:  bdy,
		})
	}
	if self.ExternalDocs != nil {
		bdy, err := self.ExternalDocs.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "externalDocs",
			Bdy:  bdy,
		})
	}
	if self.Xml != nil {
		bdy, err := self.Xml.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "xml",
			Bdy:  bdy,
		})
	}

	if self.Not != nil {
		expr := self.Not.toExpression()
		attrs["not"] = &light.Attribute{
			Name: "not",
			Expr: expr,
		}
	}

	if self.Properties != nil {
		expr := schemaOrReferenceToObjectConsExpr(self.Properties)
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
