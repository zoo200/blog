generate "base" {
  path      = "base.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

terraform {
  required_version = "1.0.6"
  backend "local" {}
}
EOF
}

remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/tfstate.d/${path_relative_to_include()}/terraform.tfstate"
  }
}


locals {
  varables = read_terragrunt_config("${get_parent_terragrunt_dir()}/variables.hcl")
}

inputs = merge(
  local.varables.inputs,
)
