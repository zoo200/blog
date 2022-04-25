## ローカル変数定義
locals {
  ## Terraform Cloudの組織名を設定
  organization="zootest20220424"

  ## Terraform Cloudのクレデンシャルファイルからjqコマンドで情報を取得
  tmp_token = "${run_cmd("jq", "-r",".credentials[\"app.terraform.io\"].token", "${get_env("HOME")}/.terraform.d/credentials.tfrc.json")}"
  ## 改行コード削除
  token = "${chomp(local.tmp_token)}"

  workspace = "vpc"
  terraform-cloud-api-endpoint = "https://app.terraform.io/api/v2/organizations/${local.organization}/workspaces/${local.workspace}"
}


## Terraformの基本的な設定
generate "base" {
  path      = "base.tf"
  if_exists = "overwrite_terragrunt"

  contents  = <<EOF
provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "${local.organization}"
    workspaces {
      name = "${local.workspace}"
    }
  }
}
EOF
}

## Terraformのファイル読み込み
terraform {
  source          = "./modules/${local.workspace}"

  ## terraform init時にTerraform CloudのAPIを使用してworkspaceを作成する
  after_hook "init" {
    commands = ["init"]
    execute  = ["curl", "-s", "-o", "/dev/null", "-H", "Authorization: Bearer ${local.token}",  "-H", "Content-Type: application/vnd.api+json",  "-X", "PATCH",  "-d", "{\"data\": { \"attributes\": { \"execution-mode\": \"local\"  },\"type\": \"workspaces\" }}" ,"${local.terraform-cloud-api-endpoint}"]
  }
}
