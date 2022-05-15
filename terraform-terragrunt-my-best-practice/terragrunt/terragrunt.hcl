locals {
  organization="zoo200"
  region = "ap-northeast-1"

  env = get_env("TF_ENV")

  module-name = "${trimprefix(path_relative_to_include(),"exec.d/")}"
  
  # Terraform Cloudをバックエンドに利用するときは [環境-モジュール] をワークスペース名に設定すると重複を回避できます。
  # https://zoo200.net/terragrunt-create-terraform-cloud-workspace/
  # https://github.com/zoo200/blog/blob/main/terragrunt-create-terraform-cloud-workspace/terragrunt.hcl#L11
  workspace = "${local.env}-${local.module-name}"

  tfbe = "${local.organization}-${local.env}-terraform-backend"

  common-vars = read_terragrunt_config(find_in_parent_folders("conf.d/common.hcl"))
  env-vars = read_terragrunt_config(find_in_parent_folders("conf.d/${local.env}.hcl"))
  secrets =  try(yamldecode(sops_decrypt_file(find_in_parent_folders("conf.d/${local.env}_secrets.yml"))),{})

}

## terraformの基本的な設定
generate "base" {
  path      = "base.tf"
  if_exists = "overwrite_terragrunt"

  contents  = <<EOF
provider "aws" {
  region  = "${local.region}"
  default_tags {
    tags = {
      "my:createdBy" = "Terraform"
    }
  }
}
terraform {
  backend "s3" {}
}
EOF
}

## 状態ファイルの出力先
remote_state {
  backend = "s3"
  config = {
    bucket = "${local.tfbe}"
    region = "${local.region}"
    key = "${local.module-name}/terraform.tfstate"
    encrypt = true
    dynamodb_table = "${local.tfbe}"
  }
}

# 削除しやすいようにキャッシュは一箇所にまとめておく
download_dir = "${get_terragrunt_dir()}/../.terragrunt-cache/${local.module-name}"


## terraformのファイル読み込み
terraform {
  source = "${path_relative_from_include()}/modules/${local.module-name}"
}

## 変数をterraformへ渡す
inputs = merge(
  {
    env = local.env,
    secrets = local.secrets,
  },
  local.common-vars.inputs,
  local.env-vars.inputs,
)
