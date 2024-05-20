package hcl

import (
	"fmt"
	"strings"

	"github.com/genelet/hcllight/light"
	"google.golang.org/protobuf/types/known/anypb"
)

func (self *Components) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Schemas != nil {
		blks, err := schemaOrReferenceMapToBlocks(self.Schemas)
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, blks...)
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
		blks, err := securitySchemeOrReferenceMapToBlocks(self.SecuritySchemes)
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
	if self.Callbacks != nil && len(self.Callbacks) > 0 {
		for k, v := range self.Callbacks {
			bdy, err := v.toHCL()
			if err != nil {
				return nil, err
			}
			blocks = append(blocks, &light.Block{
				Type:   "callbacks",
				Labels: []string{k},
				Bdy:    bdy,
			})
		}
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

/*
	func (self *DefaultType) toExpression() *light.Expression {
		return defaultTypeToExpression(self)
	}
*/
func (self *SecuritySchemeOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *SecuritySchemeOrReference_SecurityScheme:
		return self.GetSecurityScheme().toHCL()
	case *SecuritySchemeOrReference_Reference:
		body := self.GetReference().toBody()
		return body, nil
	default:
	}
	return nil, nil
}

func (self *SecurityScheme) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"type":             self.Type,
		"description":      self.Description,
		"name":             self.Name,
		"in":               self.In,
		"scheme":           self.Scheme,
		"bearerFormat":     self.BearerFormat,
		"openIdConnectUrl": self.OpenIdConnectUrl,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
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
	if self.Flows != nil {
		blk, err := self.Flows.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "flows",
			Bdy:  blk,
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

func (self *OauthFlows) toHCL() (*light.Body, error) {
	body := new(light.Body)
	blocks := make([]*light.Block, 0)
	if self.Implicit != nil {
		blk, err := self.Implicit.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "implicit",
			Bdy:  blk,
		})
	}
	if self.Password != nil {
		blk, err := self.Password.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "password",
			Bdy:  blk,
		})
	}
	if self.ClientCredentials != nil {
		blk, err := self.ClientCredentials.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "clientCredentials",
			Bdy:  blk,
		})
	}
	if self.AuthorizationCode != nil {
		blk, err := self.AuthorizationCode.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "authorizationCode",
			Bdy:  blk,
		})
	}
	if self.SpecificationExtension != nil && len(self.SpecificationExtension) > 0 {
		expr := anyMapToBody(self.SpecificationExtension)
		blocks = append(blocks, &light.Block{
			Type: "specificationExtension",
			Bdy:  expr,
		})
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func (self *OauthFlow) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	mapStrings := map[string]string{
		"authorizationUrl": self.AuthorizationUrl,
		"tokenUrl":         self.TokenUrl,
		"refreshUrl":       self.RefreshUrl,
	}
	for k, v := range mapStrings {
		if v != "" {
			attrs[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Scopes != nil {
		bdy := &light.Body{
			Attributes: map[string]*light.Attribute{},
		}
		for k, v := range self.Scopes {
			bdy.Attributes[k] = &light.Attribute{
				Name: k,
				Expr: stringToTextValueExpr(v),
			}
		}
		blocks = append(blocks, &light.Block{
			Type: "scopes",
			Bdy:  bdy,
		})
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

func (self *RequestBody) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Description != "" {
		attrs["description"] = &light.Attribute{
			Name: "description",
			Expr: stringToTextValueExpr(self.Description),
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

func (self *Response) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Description != "" {
		body.Attributes = map[string]*light.Attribute{
			"description": {
				Name: "description",
				Expr: stringToTextValueExpr(self.Description),
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
				Expr: stringToTextValueExpr(v),
			}
		}
	}
	if self.Server != nil {
		bdy, err := self.Server.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "server",
			Bdy:  bdy,
		})
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
				Expr: stringToTextValueExpr(v),
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
				Expr: stringToTextValueExpr(v),
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
				Expr: stringToTextValueExpr(v),
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

func (self *CallbackOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *CallbackOrReference_Callback:
		return self.GetCallback().toHCL()
	case *CallbackOrReference_Reference:
		return self.GetReference().toBody(), nil
	default:
	}
	return nil, nil
}

func (self *Callback) toHCL() (*light.Body, error) {
	body := new(light.Body)
	blocks, err := pathItemMapToBlocks(self.Path)
	if err != nil {
		return nil, err
	}
	body.Blocks = blocks

	return body, nil
}

func (self *Any) toExpression(how ...bool) *light.Expression {
	if how != nil && len(how) > 0 {
		x := self.Yaml
		if x == "" && self.Value != nil {
			x = fmt.Sprintf("%v", self.Value.GetValue())
		}
		return stringToTextValueExpr(strings.TrimSpace(x))
	}

	var args []*light.Expression

	if self.Yaml != "" {
		args = append(args, stringToTextValueExpr(strings.TrimSpace(self.Yaml)))
	} else if self.Value != nil {
		args = append(args, stringToLiteralValueExpr(fmt.Sprintf("%v", self.Value)))
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

func anyFromHCL(expr *light.Expression) *Any {
	if expr == nil {
		return nil
	}
	switch expr.ExpressionClause.(type) {
	case *light.Expression_Texpr:
		return &Any{
			Yaml: expr.GetTexpr().Parts[0].GetLvexpr().GetVal().GetStringValue(),
		}
	case *light.Expression_Lvexpr:
		return &Any{
			Value: &anypb.Any{
				Value: []byte(fmt.Sprintf("%v", expr.GetLvexpr().Val)),
			},
		}
	default:
	}
	return nil
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
