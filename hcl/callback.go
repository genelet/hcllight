package hcl

import (
	"github.com/genelet/hcllight/light"
)


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

