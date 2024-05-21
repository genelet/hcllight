package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *CallbackOrReference) toHCL() (*light.Body, error) {
	switch self.Oneof.(type) {
	case *CallbackOrReference_Callback:
		return self.GetCallback().toHCL()
	case *CallbackOrReference_Reference:
		return self.GetReference().toHCL()
	default:
	}
	return nil, nil
}

func callbackOrReferenceFromHCL(body *light.Body) (*CallbackOrReference, error) {
	if body == nil {
		return nil, nil
	}

	reference, err := referenceFromHCL(body)
	if err != nil {
		return nil, err
	}

	if reference != nil {
		return &CallbackOrReference{
			Oneof: &CallbackOrReference_Reference{
				Reference: reference,
			},
		}, nil
	}

	callback, err := callbackFromHCL(body)
	if err != nil {
		return nil, err
	}
	if callback != nil {
		return &CallbackOrReference{
			Oneof: &CallbackOrReference_Callback{
				Callback: callback,
			},
		}, nil
	}

	return nil, nil
}

func (self *Callback) toHCL() (*light.Body, error) {
	body := new(light.Body)
	blocks, err := pathItemOrReferenceMapToBlocks(self.Path)
	if err != nil {
		return nil, err
	}
	body.Blocks = blocks

	return body, nil
}

func callbackFromHCL(body *light.Body) (*Callback, error) {
	if body == nil {
		return nil, nil
	}

	self := &Callback{}
	paths, err := blocksToPathItemOrReferenceMap(body.Blocks)
	if err != nil {
		return nil, err
	}
	self.Path = paths

	return self, nil
}

func callbackOrReferenceMapToBlocks(callbacks map[string]*CallbackOrReference) ([]*light.Block, error) {
	if callbacks == nil {
		return nil, nil
	}
	hash := make(map[string]AbleHCL)
	for k, v := range callbacks {
		hash[k] = v
	}
	return ableMapToBlocks(hash, "callback")
}

func blocksToCallbackOrReferenceMap(blocks []*light.Block) (map[string]*CallbackOrReference, error) {
	if blocks == nil {
		return nil, nil
	}
	hash := make(map[string]*CallbackOrReference)
	for _, block := range blocks {
		able, err := callbackOrReferenceFromHCL(block.Bdy)
		if err != nil {
			return nil, err
		}
		hash[block.Type] = able
	}

	return hash, nil
}
