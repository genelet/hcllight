package light

import (
	"fmt"
	"math/rand"
	"os"
	"strings"
	"testing"

	"github.com/google/go-cmp/cmp"
	"github.com/zclconf/go-cty/cty"
	"github.com/zclconf/go-cty/cty/function"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/testing/protocmp"
)

func TestEval(t *testing.T) {
	var tests = []struct {
		name   string
		input  string
		expect string
	}{
		{`check string`, `x = "hello"`, `x = "hello"`},
		{`check bool`, `x = true`, `x = true`},
		{`check int`, `x = 1`, `x = 1`},
		{`check float`, `x = 1.01`, `x = 1.010000`},
		{`check map`, `x = { a = 1 }`, `x = {` + "\n" + `    a = 1` + "\n" + `  }`},
		{`check list`, `x = [1]`, `x = [` + "\n" + `    1` + "\n" + `  ]`},
		{`check block`, `x "y" {}`, `x "y" {}`},
		{`check block with attributes`, `x "y" {
			a = 1
		}`, `x "y" {
    a = 1
  }`},
		{`check block with attributes and body`, `x "y" {
			a = 1
			b = 2
		}`, `x "y" {
    a = 1
    b = 2
  }`},
		{`check block with attributes and body`, `x "y" {
			a = 1
			b = 2
			c "d" {
				e = 3
			}
		}`, `x "y" {
    a = 1
    b = 2
    c "d" {
      e = 3
    }
  }`},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			bdy, err := ParseBody([]byte(test.input))
			if err != nil {
				t.Fatal(err)
			}
			bs, err := bdy.Evaluate()
			if err != nil {
				t.Fatal(err)
			}
			if test.name == "check block with attributes and body" {
				bdy1, err := ParseBody(bs)
				if err != nil {
					t.Fatal(err)
				}
				bs1, err := bdy1.Evaluate()
				if err != nil {
					t.Fatal(err)
				}
				if proto.Equal(bdy, bdy1) == false {
					t.Errorf("expect %s, got %s", bs, bs1)
				}
			} else {
				expected := "\n" + "  " + test.expect + "\n"
				if string(bs) != expected {
					t.Errorf("expect %s, got %s", expected, bs)
				}
			}
		})
	}
}

// parseFile parses HCL file into Body proto.
func parseFile(filename string) (*Body, error) {
	dat, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}
	return ParseBody(dat)
}

func getRef() map[string]interface{} {
	return map[string]interface{}{
		"functions": map[string]function.Function{
			"random": function.New(&function.Spec{
				VarParam: nil,
				Params: []function.Parameter{
					{Type: cty.Number},
				},
				Type: func(args []cty.Value) (cty.Type, error) {
					return cty.String, nil
				},
				Impl: func(args []cty.Value, retType cty.Type) (cty.Value, error) {
					var letterRunes = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
					n, _ := args[0].AsBigFloat().Int64()
					b := make([]rune, n)
					for i := range b {
						b[i] = letterRunes[rand.Intn(len(letterRunes))]
					}
					return cty.StringVal(string(b)), nil
				},
			}),
			"static": function.New(&function.Spec{
				VarParam: nil,
				Params: []function.Parameter{
					{Type: cty.Number},
				},
				Type: func(args []cty.Value) (cty.Type, error) {
					return cty.String, nil
				},
				Impl: func(args []cty.Value, retType cty.Type) (cty.Value, error) {
					return cty.StringVal("abcdef"), nil
				},
			}),
		},
	}
}

func TestParseFileHcl(t *testing.T) {
	bodyr, err := parseFile("random.hcl")
	if err != nil {
		t.Fatal(err)
	}
	backr, err := hclBack(bodyr)
	if err != nil {
		t.Fatal(err)
	}

	var r DiffReporter
	opt := protocmp.Transform()
	if cmp.Equal(bodyr, backr, opt, cmp.Reporter(&r)) == false {
		t.Errorf("%s", r.String())
	}

	bodys, err := parseFile("static.hcl")
	if err != nil {
		t.Fatal(err)
	}
	if cmp.Equal(bodyr, bodys, opt, cmp.Reporter(&r)) == true {
		t.Errorf("%s", r.String())
	}

	evalr, err := evalBack(bodyr)
	if err != nil {
		t.Fatal(err)
	}

	evals, err := evalBack(bodys)
	if err != nil {
		t.Fatal(err)
	}
	if cmp.Equal(evalr, evals, opt, cmp.Reporter(&r)) == true {
		t.Errorf("%s", r.String())
	}
}

func hclBack(body *Body) (*Body, error) {
	eval, err := body.MarshalHCL()
	if err != nil {
		return nil, err
	}
	return ParseBody(eval)
}

func evalBack(body *Body) (*Body, error) {
	ref := getRef()
	eval, err := body.Evaluate(ref)
	if err != nil {
		return nil, err
	}
	return ParseBody(eval)
}

// DiffReporter is a simple custom reporter that only records differences
// detected during comparison.
type DiffReporter struct {
	path  cmp.Path
	diffs []string
}

func (r *DiffReporter) PushStep(ps cmp.PathStep) {
	r.path = append(r.path, ps)
}

func (r *DiffReporter) Report(rs cmp.Result) {
	if !rs.Equal() {
		vx, vy := r.path.Last().Values()
		r.diffs = append(r.diffs, fmt.Sprintf("%v:\n\t-: %+v\n\t+: %+v\n", r.path.GoString(), vx, vy))
	}
}

func (r *DiffReporter) PopStep() {
	r.path = r.path[:len(r.path)-1]
}

func (r *DiffReporter) String() string {
	return strings.Join(r.diffs, "\n")
}
