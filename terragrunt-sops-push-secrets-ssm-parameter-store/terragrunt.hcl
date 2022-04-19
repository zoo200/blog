## terraformの基本的な設定
generate "base" {
  path      = "base.tf"
  if_exists = "overwrite_terragrunt"

  contents  = <<EOF
provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

terraform {
  backend "local" {}
}
EOF
}

## 状態ファイルの出力先
remote_state {
  backend = "local"
  config = {
    path = "./tfstate.d/kms/terraform.tfstate"
  }
}

## terraformのファイル読み込み
terraform {
  source          = "./modules/kms"
}

## 機密情報をterraformへ渡す
inputs = merge(
  {
    secrets = try(yamldecode(sops_decrypt_file("demo_secrets.yml")),{})
  },
)
