locals {
  region = "us-east-1"
  azs = [
    "${local.region}a",
    "${local.region}b",
  ]
  directory = {
    name  = var.directory_name
    size  = var.directory_size
    alias = var.directory_alias
  }
}

provider "aws" {
  version = "~> 2.8"
  region  = local.region
}

################################################################################
# generate a directory password cos we probably shouldn't care what it is
# for the purpose of using it as a directory for WorkSpaces.  We'll see.
resource "random_string" "directory_password" {
  length      = 64
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}


################################################################################
# default VPC stuff
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default_1" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = local.azs[0]
  default_for_az    = true
}

data "aws_subnet" "default_2" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = local.azs[1]
  default_for_az    = true
}

################################################################################
# IAM pre-req
# https://docs.aws.amazon.com/workspaces/latest/adminguide/workspaces-access-control.html#create-default-role
resource "aws_iam_role" "ws_default" {
  name               = "workspaces_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.ws_assume_role.json
}

data "aws_iam_policy_document" "ws_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "workspaces.amazonaws.com",
      ]
    }
  }
}

locals {
  ws_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonWorkSpacesServiceAccess",
    "arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess"
  ]
}

resource "aws_iam_role_policy_attachment" "ws_default" {
  count      = length(local.ws_role_policy_arns)
  role       = aws_iam_role.ws_default.name
  policy_arn = local.ws_role_policy_arns[count.index]
}

################################################################################
# WorkSpaces stuff
resource "aws_directory_service_directory" "main" {
  name     = local.directory.name
  password = random_string.directory_password.result
  size     = local.directory.size
  alias    = local.directory.alias
  vpc_settings {
    vpc_id = data.aws_vpc.default.id
    subnet_ids = [
      data.aws_subnet.default_1.id,
      data.aws_subnet.default_2.id,
    ]
  }
}

resource "aws_workspaces_directory" "main" {
  directory_id = aws_directory_service_directory.main.id

  self_service_permissions {
    change_compute_type  = false
    increase_volume_size = false
    rebuild_workspace    = true
    restart_workspace    = true
    switch_running_mode  = false
  }
  depends_on = [
    aws_iam_role.ws_default
  ]
}
