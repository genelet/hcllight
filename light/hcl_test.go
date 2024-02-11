package light

import (
	"testing"

	"google.golang.org/protobuf/proto"
)

func TestHclExpression(t *testing.T) {
	var tests = []struct {
		name   string
		input  string
		expect string
	}{
		{"check function", `
EXECUTION_ID = random(6)
`, `EXECUTION_ID = random(6)`},
		{"check function", `
EXECUTION_ID = random(6, 2)
`, `EXECUTION_ID = random(6, 2)`},
		{"check function", `
EXECUTION_ID = random(6, 2, 3)
`, `EXECUTION_ID = random(6, 2, 3)`},
		{"check function", `
EXECUTION_ID = random(6, 2, 3, "a")
`, `EXECUTION_ID = random(6, 2, 3, "a")`},
		{"check function", `
EXECUTION_ID = random(6, 2, 3, "a", "b")
`, `EXECUTION_ID = random(6, 2, 3, "a", "b")`},
		{"check function", `
type = list(string)
`, `type = list(string)`},
		{"check traversal", `
region = var.aws_region
`, `region = var.aws_region`},
		{"check traversal", `
cidr_block = var.base_cidr_block
`, `cidr_block = var.base_cidr_block`},
		{"check traversal", `
vpc_id = aws_vpc.main.id
`, `vpc_id = aws_vpc.main.id`},
		{"check traverser index", `
availability_zone = var.availability_zones[count.index]
`, `availability_zone = var.availability_zones[count.index]`},
		{"check traverser index", `
count = length(var.availability_zones)
`, `count = length(var.availability_zones)`},
		{"check traverser index", `
cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index+1)
`, `cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + 1)`},
		{"check key value", `aws = {
source  = "hashicorp/aws"
version = "~> 1.0.4"
}`, `aws = {source = "hashicorp/aws", version = "~> 1.0.4"}`},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			bdy, err := Parse([]byte(test.input))
			if err != nil {
				t.Fatal(err)
			}
			for k, v := range bdy.Attributes {
				str, err := hclExpression(v.Expr)
				if err != nil {
					t.Fatal(err)
				}
				str = k + " = " + str
				if str != test.expect {
					t.Errorf("expected %s, got %s", test.expect, str)
				}
				break
			}
		})
	}
}

func TestParseHcl(t *testing.T) {
	for _, fn := range []string{"sample1.hcl", "sample3.hcl", "sample4.hcl"} {
		bdy, err := parseFile(fn)
		if err != nil {
			t.Fatal(err)
		}

		str, err := Hcl(bdy)
		if err != nil {
			t.Fatal(err)
		}

		bdy1, err := Parse(str)
		if err != nil {
			t.Fatal(err)
		}

		if proto.Equal(bdy, bdy1) == false {
			t.Errorf("expected %s, got %v", str, bdy1.String())
		}
	}
}

func TestParseHclEqual(t *testing.T) {
	fn := "sample2.hcl"
	bdy, err := parseFile(fn)
	if err != nil {
		t.Fatal(err)
	}

	str, err := Hcl(bdy)
	if err != nil {
		t.Fatal(err)
	}

	bdy1, err := Parse(str)
	if err != nil {
		t.Fatal(err)
	}

	for k, v := range bdy.Attributes {
		u := bdy1.Attributes[k]
		if proto.Equal(v, u) == false {
			t.Errorf("expected %s, got %v", v.String(), u.String())
		}
	}

	for k, v := range bdy.Blocks {
		u := bdy1.Blocks[k]
		if proto.Equal(u, v) == false {
			t.Errorf("expected %s\ngot %v", v.String(), u.String())
		}
	}
}
