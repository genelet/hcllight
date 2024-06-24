// Copyright (c) Greetingland LLC
// MIT License

package spider

import (
	"net/url"

	"github.com/genelet/hcllight/spider"
	"github.com/genelet/kinet/micro"
)

type Selection struct {
	Data     *spider.Collection `hcl:"data,block"`
	Resource *spider.Collection `hcl:"resource,block"`
	Cleanup  *spider.Collection `hcl:"cleanup,block"`
}

func (self *Selection) GetLocation(caller *url.URL, _ string, _ string, _ interface{}) (*url.URL, error) {
	return caller, nil
}

func (self *Selection) makeSpec() (*micro.Struct, error) {
	return micro.NewStruct("Selection", map[string]interface{}{
		"Data": [2]interface{}{"Collection", map[string]interface{}{
			"Response": []string{"Response", "dataService"},
		}},
		"Resource": [2]interface{}{"Collection", map[string]interface{}{
			"Response": []string{"Response", "resourceService"},
		}},
		"Cleanup": [2]interface{}{"Collection", map[string]interface{}{
			"Response": []string{"Response", "cleanupService"},
		}},
	})
}
