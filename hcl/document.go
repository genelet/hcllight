package hcl

import (
	"strings"

	"github.com/genelet/hcllight/light"
	openapiv3 "github.com/google/gnostic-models/openapiv3"
)

func (self *Document) MarshalHCL() ([]byte, error) {
	body, err := self.toHCL()
	if err != nil {
		return nil, err
	}
	return body.Hcl()
}

func (self *Document) UnmarshalHCL(data []byte) error {
	var err error
	self, err = ParseDocument(data)
	return err
}

func ParseDocument(data []byte, extension ...string) (*Document, error) {
	var typ string
	if extension != nil {
		typ = strings.ToLower(extension[0])
	}
	if typ == "json" || typ == "jsn" || typ == "yaml" || typ == "yml" {
		doc, err := openapiv3.ParseDocument(data)
		if err != nil {
			return nil, err
		}
		return DocumentFromApi(doc), nil
	}

	body, err := light.Parse(data)
	if err != nil {
		return nil, err
	}

	return documentFromHCL(body)
}

func (self *Document) toHCL() (*light.Body, error) {
	body := new(light.Body)
	attrs := make(map[string]*light.Attribute)
	blocks := make([]*light.Block, 0)
	if self.Openapi != "" {
		attrs["openapi"] = &light.Attribute{
			Name: "openapi",
			Expr: stringToTextValueExpr(self.Openapi),
		}
	}
	if self.Info != nil {
		bdy, err := self.Info.toHCL()
		if err != nil {
			return nil, err
		}
		blocks = append(blocks, &light.Block{
			Type: "info",
			Bdy:  bdy,
		})
	}
	if self.Servers != nil && len(self.Servers) > 0 {
		expr, err := serversToTupleConsExpr(self.Servers)
		if err != nil {
			return nil, err
		}
		attrs["servers"] = &light.Attribute{
			Name: "servers",
			Expr: expr,
		}
	}
	if self.Tags != nil && len(self.Tags) > 0 {
		expr, err := tagsToTupleConsExpr(self.Tags)
		if err != nil {
			return nil, err
		}
		attrs["tags"] = &light.Attribute{
			Name: "tags",
			Expr: expr,
		}
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
	if self.Paths != nil {
		blks, err := pathItemOrReferenceMapToBlocks(self.Paths)
		if err != nil {
			return nil, err
		}
		for _, block := range blks {
			blocks = append(blocks, &light.Block{
				Type: "paths",
				Labels: []string{
					block.Type,
					block.Labels[0],
				},
				Bdy: block.Bdy,
			})
		}
	}
	if self.Components != nil {
		bdy, err := self.Components.toHCL()
		if err != nil {
			return nil, err
		}
		for _, block := range bdy.Blocks {
			labels := []string{block.Type}
			labels = append(labels, block.Labels...)
			blocks = append(blocks, &light.Block{
				Type:   "components",
				Labels: labels,
				Bdy:    block.Bdy,
			})
		}
	}
	if self.Security != nil {
		expr, err := securityRequirementToTupleConsExpr(self.Security)
		if err != nil {
			return nil, err
		}
		attrs["security"] = &light.Attribute{
			Name: "security",
			Expr: expr,
		}
	}
	if err := addSpecification(self.SpecificationExtension, &blocks); err != nil {
		return nil, err
	}
	if len(attrs) > 0 {
		body.Attributes = attrs
	}
	if len(blocks) > 0 {
		body.Blocks = blocks
	}
	return body, nil
}

func documentFromHCL(body *light.Body) (*Document, error) {
	if body == nil {
		return nil, nil
	}

	doc := new(Document)
	var blks_paths, blks_comments []*light.Block
	for key, attr := range body.Attributes {
		switch key {
		case "openapi":
			doc.Openapi = *textValueExprToString(attr.Expr)
		case "servers":
			servers, err := expressionToServers(attr.Expr)
			if err != nil {
				return nil, err
			}
			if servers == nil || servers[0] == nil {
				panic(servers)
			}
			doc.Servers = servers
		case "tags":
			tags, err := expressionToTags(attr.Expr)
			if err != nil {
				return nil, err
			}
			doc.Tags = tags
		case "security":
			security, err := expressionToSecurityRequirement(attr.Expr)
			if err != nil {
				return nil, err
			}
			doc.Security = security
		}
	}
	for _, block := range body.Blocks {
		switch block.Type {
		case "info":
			info, err := infoFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			doc.Info = info
		case "externalDocs":
			externalDocs, err := externalDocsFromHCL(block.Bdy)
			if err != nil {
				return nil, err
			}
			doc.ExternalDocs = externalDocs
		case "paths":
			blks_paths = append(blks_paths, &light.Block{
				Type:   block.Labels[0],
				Labels: block.Labels[1:],
				Bdy:    block.Bdy,
			})
		case "components":
			blks_comments = append(blks_comments, &light.Block{
				Type:   block.Labels[0],
				Labels: block.Labels[1:],
				Bdy:    block.Bdy,
			})
		default:
		}
	}

	if blks_paths != nil {
		paths, err := blocksToPathItemOrReferenceMap(blks_paths)
		if err != nil {
			return nil, err
		}
		doc.Paths = paths
	}
	if blks_comments != nil {
		components, err := componentsFromHCL(&light.Body{Blocks: blks_comments})
		if err != nil {
			return nil, err
		}
		doc.Components = components
	}
	var err error
	doc.SpecificationExtension, err = getSpecification(body)
	if err != nil {
		return nil, err
	}

	return doc, nil
}
