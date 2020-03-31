locals {
	region = "us-east-1"
	az_a   = "${local.region}a"
	az_b   = "${local.region}b"
}

provider "aws" {
  version = "~> 2.0"
  region  = local.region
}

################################################################################
data "aws_vpc" "default" {
	default = true
}

data "aws_subnet" "a" {
	vpc_id = data.aws_vpc.default.id
	availability_zone = local.az_a
}

data "aws_subnet" "b" {
	vpc_id = data.aws_vpc.default.id
	availability_zone = local.az_b
}

resource "random_string" "pwd" {
	length = 32
	min_upper = 1
	min_lower = 1
	min_numeric = 1
	min_special = 1
}

################################################################################
resource "aws_directory_service_directory" "bar" {
  name     = "corp.foobar.com"
  password = random_string.pwd.result
  size     = "Small"
	type     = "SimpleAD"

	vpc_settings {
		vpc_id = data.aws_vpc.default.id
		subnet_ids = [
			data.aws_subnet.a.id,
			data.aws_subnet.b.id,
		]
	}
}
