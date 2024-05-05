package hcl

import (
	"fmt"

	"github.com/genelet/hcllight/light"
)

func (self *Reference) MarshalHCL() ([]byte, error) {
	return self.toBody().Hcl()
}

func (self *Reference) toBody() *light.Body {
	body := &light.Body{
		Attributes: map[string]*light.Attribute{
			"XRef": {
				Name: "XRef",
				Expr: stringToLiteralValueExpr(self.XRef),
			},
		},
	}
	if self.Summary != "" {
		body.Attributes["summary"] = &light.Attribute{
			Name: "summary",
			Expr: stringToLiteralValueExpr(self.Summary),
		}
	}
	if self.Description != "" {
		body.Attributes["description"] = &light.Attribute{
			Name: "description",
			Expr: stringToLiteralValueExpr(self.Description),
		}
	}
	return body
}

func (self *Reference) toExpression() *light.Expression {
	var args []*light.Expression
	if self.Summary != "" {
		args = append(args, stringToLiteralValueExpr(self.Summary))
	}
	if self.Description != "" {
		args = append(args, stringToLiteralValueExpr(self.Description))
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

func (self *DefaultType) toExpression() *light.Expression {
	switch self.Oneof.(type) {
	case *DefaultType_Boolean:
		t := self.GetBoolean()
		return booleanToLiteralValueExpr(t)
	case *DefaultType_Number:
		t := self.GetNumber()
		return doubleToLiteralValueExpr(t)
	case *DefaultType_String_:
		t := self.GetString_()
		return stringToLiteralValueExpr(t)
	default:
	}
	return nil
}

func (self *Components) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Components) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Schemas != nil {
		bdy := schemaOrReferenceMapToBody(self.Schemas)
		blocks = append(blocks, &light.Block{
			Type: "schemas",
			Bdy:  bdy,
		})
	}
	if self.Responses != nil {
		blks, err := responseOrReferenceMapToBlocks(self.Responses)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Parameters != nil {
		blks, err := parameterOrReferenceMapToBlocks(self.Parameters)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Examples != nil {
		blks, err := exampleOrReferenceMapToBlocks(self.Examples)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.RequestBodies != nil {
		blks, err := requestBodyOrReferenceMapToBlocks(self.RequestBodies)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Headers != nil {
		blks, err := headerOrReferenceMapToBlocks(self.Headers)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.SecuritySchemes != nil {
		blk, err := toBlock(self.SecuritySchemes, "securitySchemes")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk)
	}
	if self.Links != nil {
		blks, err := linkOrReferenceMapToBlocks(self.Links)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Callbacks != nil {
		blk, err := toBlock(self.Callbacks, "callbacks")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk)
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func (self *Document) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Document) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Openapi != "" {
		attrs["openapi"] = &light.Attribute{
			Name: "openapi",
			Expr: stringToLiteralValueExpr(self.Openapi),
		}
	}
	if self.Info != nil {
		block, err := toBlock(self.Info, "info")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, block)
	}
	if self.Servers != nil {
		blk, err := toBlock(self.Servers, "servers")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk)
	}
	if self.Paths != nil {
		blks, err := pathItemMapToBlocks(self.Paths)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Components != nil {
		bdy, err := self.Components.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "components",
			Bdy:  bdy,
		})
	}
	if self.Security != nil {
		blk, err := toBlock(self.Security, "security")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk)
	}
	if self.Tags != nil {
		blk, err := toBlock(self.Tags, "tags")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk)
	}
	if self.ExternalDocs != nil {
		block, err := toBlock(self.ExternalDocs, "externalDocs")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, block)
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func (self *ParameterOrReference) MarshalHCL() ([]byte, error) {
	switch self.Oneof.(type) {
	case *ParameterOrReference_Reference:
		return self.GetReference().MarshalHCL()
	case *ParameterOrReference_Parameter:
		return self.GetParameter().MarshalHCL()
	default:
	}
	return nil, nil
}

func (self *ParameterOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *ParameterOrReference_Parameter:
		return self.GetParameter().toHCL()
	case *ParameterOrReference_Reference:
		body := self.GetReference().toBody()
		return body, nil
	default:
	}
	return nil, nil
}

func (self *Parameter) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Parameter) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"required":        self.Required,
		"deprecated":      self.Deprecated,
		"allowEmptyValue": self.AllowEmptyValue,
		"explode":         self.Explode,
		"allowReserved":   self.AllowReserved,
	}
	mapStrings := map[string]string{
		"name":        self.Name,
		"in":          self.In,
		"description": self.Description,
		"style":       self.Style,
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
	if self.Example != nil {
		expr := self.Example.toExpression()
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: expr,
		}
	}
	if self.Examples != nil {
		blk, err := exampleOrReferenceMapToBlocks(self.Examples)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk...)
	}

	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}

	if self.Schema != nil {
		attrs["schema"] = &light.Attribute{
			Name: "schema",
			Expr: self.Schema.toExpression(),
		}
	}
	if self.Content != nil {
		blks, err := mediaTypeMapToBlocks(self.Content)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func (self *RequestBodyOrReference) MarshalHCL() ([]byte, error) {
	switch self.Oneof.(type) {
	case *RequestBodyOrReference_Reference:
		return self.GetReference().MarshalHCL()
	case *RequestBodyOrReference_RequestBody:
		return self.GetRequestBody().MarshalHCL()
	default:
	}
	return nil, nil
}

func (self *RequestBodyOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *RequestBodyOrReference_RequestBody:
		return self.GetRequestBody().toHCL()
	case *RequestBodyOrReference_Reference:
		body := self.GetReference().toBody()
		return body, nil
	default:
	}
	return nil, nil
}

func (self *RequestBody) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *RequestBody) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Description != "" {
		attrs["description"] = &light.Attribute{
			Name: "description",
			Expr: stringToLiteralValueExpr(self.Description),
		}
	}
	if self.Required {
		attrs["required"] = &light.Attribute{
			Name: "required",
			Expr: booleanToLiteralValueExpr(self.Required),
		}
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}

	if self.Content != nil {
		blks, err := mediaTypeMapToBlocks(self.Content)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}

	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}

	return body, nil
}

func (self *ResponseOrReference) MarshalHCL() ([]byte, error) {
	switch self.Oneof.(type) {
	case *ResponseOrReference_Reference:
		return self.GetReference().MarshalHCL()
	case *ResponseOrReference_Response:
		return self.GetResponse().MarshalHCL()
	default:
	}
	return nil, nil
}

func (self *ResponseOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *ResponseOrReference_Response:
		return self.GetResponse().toHCL()
	case *ResponseOrReference_Reference:
		body := self.GetReference().toBody()
		return body, nil
	default:
	}
	return nil, nil
}

func (self *Response) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Response) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Description != "" {
		body.Attributes = map[string]*light.Attribute{
			"description": {
				Name: "description",
				Expr: stringToLiteralValueExpr(self.Description),
			},
		}
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}

	if self.Content != nil {
		blks, err := mediaTypeMapToBlocks(self.Content)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Headers != nil {
		blks, err := headerOrReferenceMapToBlocks(self.Headers)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if self.Links != nil {
		blks, err := linkOrReferenceMapToBlocks(self.Links)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}

	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func (self *LinkOrReference) MarshalHCL() ([]byte, error) {
	switch self.Oneof.(type) {
	case *LinkOrReference_Reference:
		return self.GetReference().MarshalHCL()
	case *LinkOrReference_Link:
		return self.GetLink().MarshalHCL()
	default:
	}
	return nil, nil
}

func (self *LinkOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *LinkOrReference_Link:
		return self.GetLink().toHCL()
	case *LinkOrReference_Reference:
		body := self.GetReference().toBody()
		return body, nil
	default:
	}
	return nil, nil
}

func (self *Link) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Link) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"operationRef": self.OperationRef,
		"operationId":  self.OperationId,
		"description":  self.Description,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToLiteralValueExpr(v),
			}
		}
	}
	if self.Server != nil {
		block, err := toBlock(self.Server, "server")
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, block)
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}

	if self.Parameters != nil {
		attrs["parameters"] = &light.Attribute{
			Name: "parameters",
			Expr: self.Parameters.toExpression(),
		}
	}
	if self.RequestBody != nil {
		attrs["requestBody"] = &light.Attribute{
			Name: "requestBody",
			Expr: self.RequestBody.toExpression(),
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

func (self *Any) toExpression() *light.Expression {
	args := []*light.Expression{
		{
			ExpressionClause: &light.Expression_Lvexpr{
				Lvexpr: &light.LiteralValueExpr{
					Val: &light.CtyValue{
						CtyValueClause: &light.CtyValue_StringValue{
							StringValue: fmt.Sprintf("%s", self.Value),
						},
					},
				},
			},
		},
	}
	if self.Yaml != "" {
		args = append(args, stringToLiteralValueExpr(self.Yaml))
	}

	return &light.Expression{
		ExpressionClause: &light.Expression_Fcexpr{
			Fcexpr: &light.FunctionCallExpr{
				Name: "any",
				Args: args,
			},
		},
	}
}

func (self *Expression) toExpression() *light.Expression {
	if self.AdditionalProperties == nil {
		return nil
	}
	body := anyMapToBody(self.AdditionalProperties)
	return &light.Expression{
		ExpressionClause: &light.Expression_Ocexpr{
			Ocexpr: body.ToObjectConsExpr(),
		},
	}
}

func (self *AnyOrExpression) toExpression() *light.Expression {
	switch self.Oneof.(type) {
	case *AnyOrExpression_Expression:
		t := self.GetExpression()
		return t.toExpression()
	case *AnyOrExpression_Any:
		t := self.GetAny()
		return t.toExpression()
	default:
	}
	return nil
}

func (self *ExampleOrReference) MarshalHCL() ([]byte, error) {
	switch self.Oneof.(type) {
	case *ExampleOrReference_Reference:
		return self.GetReference().MarshalHCL()
	case *ExampleOrReference_Example:
		return self.GetExample().MarshalHCL()
	default:
	}
	return nil, nil
}

func (self *ExampleOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *ExampleOrReference_Example:
		return self.GetExample().toHCL()
	case *ExampleOrReference_Reference:
		body := self.GetReference().toBody()
		return body, nil
	default:
	}
	return nil, nil
}

func (self *Example) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Example) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"summary":       self.Summary,
		"description":   self.Description,
		"externalValue": self.ExternalValue,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToLiteralValueExpr(v),
			}
		}
	}
	if self.Value != nil {
		attrs["value"] = &light.Attribute{
			Name: "value",
			Expr: self.Value.toExpression(),
		}
	}
	if self.SpecificationExtension != nil {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func (self *HeaderOrReference) MarshalHcl() ([]byte, error) {
	switch self.Oneof.(type) {
	case *HeaderOrReference_Reference:
		return self.GetReference().MarshalHCL()
	case *HeaderOrReference_Header:
		return self.GetHeader().MarshalHCL()
	default:
	}
	return nil, nil
}

func (self *HeaderOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *HeaderOrReference_Header:
		return self.GetHeader().toHCL()
	case *HeaderOrReference_Reference:
		return self.GetReference().toBody(), nil
	default:
	}
	return nil, nil
}

func (self *Header) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Header) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"required":        self.Required,
		"deprecated":      self.Deprecated,
		"allowEmptyValue": self.AllowEmptyValue,
		"explode":         self.Explode,
		"allowReserved":   self.AllowReserved,
	}
	mapStrings := map[string]string{
		"description": self.Description,
		"style":       self.Style,
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
	if self.Example != nil {
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: self.Example.toExpression(),
		}
	}
	if self.Examples != nil {
		blk, err := exampleOrReferenceMapToBlocks(self.Examples)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk...)
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if self.Schema != nil {
		attrs["schema"] = &light.Attribute{
			Name: "schema",
			Expr: self.Schema.toExpression(),
		}
	}
	if self.Content != nil {
		blks, err := mediaTypeMapToBlocks(self.Content)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func (self *Encoding) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Encoding) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapBools := map[string]bool{
		"explode":       self.Explode,
		"allowReserved": self.AllowReserved,
	}
	mapStrings := map[string]string{
		"contentType": self.ContentType,
		"style":       self.Style,
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
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}

	if self.Headers != nil {
		blks, err := headerOrReferenceMapToBlocks(self.Headers)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func (self *MediaType) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *MediaType) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Example != nil {
		attrs["example"] = &light.Attribute{
			Name: "example",
			Expr: self.Example.toExpression(),
		}
	}
	if self.Examples != nil {
		blk, err := exampleOrReferenceMapToBlocks(self.Examples)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blk...)
	}

	if self.Schema != nil {
		attrs["schema"] = &light.Attribute{
			Name: "schema",
			Expr: self.Schema.toExpression(),
		}
	}
	if self.Encoding != nil {
		blks, err := encodingMapToBlocks(self.Encoding)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}
