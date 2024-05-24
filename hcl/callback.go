package hcl

import (
	"github.com/genelet/hcllight/light"
)

func (self *CallbackOrReference) getAble() ableHCL {
	return self.GetCallback()
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

func callbackOrReferenceMapToBlocks(callbacks map[string]*CallbackOrReference, names ...string) ([]*light.Block, error) {
	if callbacks == nil {
		return nil, nil
	}

	hash := make(map[string]orHCL)
	for k, v := range callbacks {
		hash[k] = v
	}
	return orMapToBlocks(hash, names...)
}

func blocksToCallbackOrReferenceMap(blocks []*light.Block, names ...string) (map[string]*CallbackOrReference, error) {
	if blocks == nil {
		return nil, nil
	}

	orMap, err := blocksToOrMap(blocks, func(reference *Reference) orHCL {
		return &CallbackOrReference{
			Oneof: &CallbackOrReference_Reference{
				Reference: reference,
			},
		}
	}, func(body *light.Body) (orHCL, error) {
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
	}, names...)
	if err != nil {
		return nil, err
	}

	if orMap == nil {
		return nil, nil
	}

	hash := make(map[string]*CallbackOrReference)
	for k, v := range orMap {
		hash[k] = v.(*CallbackOrReference)
	}

	return hash, nil
}
