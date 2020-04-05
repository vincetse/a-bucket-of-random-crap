locals {
  region = "us-east-1"
  azs = [
    "${local.region}a",
    "${local.region}b",
  ]
  directory_name = "ws.hello.com"
  directory_password = "!Secret0001"
  directory_size = "Small"
}

locals {
  bundle_id = "wsb-362t3gdrt"
  users = [
    {
      username = "vtse"
      first_name = "Vince"
      last_name = "Tse"
      email = "thelazyenginerd@gmail.com"
    }
  ]
}

provider "aws" {
  version = "~> 2.8"
  region = local.region
}

################################################################################
# default VPC stuff
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default_1" {
  vpc_id = data.aws_vpc.default.id
  availability_zone = local.azs[0]
  default_for_az = true
}

data "aws_subnet" "default_2" {
  vpc_id = data.aws_vpc.default.id
  availability_zone = local.azs[1]
  default_for_az = true
}

################################################################################
# WorkSpaces stuff
resource "aws_directory_service_directory" "main" {
  name     = local.directory_name
  password = local.directory_password
  size     = local.directory_size
  vpc_settings {
    vpc_id     = data.aws_vpc.default.id
    subnet_ids = [
      data.aws_subnet.default_1.id,
      data.aws_subnet.default_2.id,
    ]
  }
}

#resource "aws_workspaces_directory" "main" {
#  directory_id = aws_directory_service_directory.main.id
#
#  self_service_permissions {
#    change_compute_type  = false
#    increase_volume_size = false
#    rebuild_workspace    = true
#    restart_workspace    = true
#    switch_running_mode  = false
#  }
#}

################################################################################
# Individual workspaces.
#resource "null_resource" "workspaces" {
#  provisioner "local-exec" {
#  }
#}
