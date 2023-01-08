terraform {
  required_version = "~> 1.3"
  backend "local" {}
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}

module "vpc" {
  source = "./modules/vpc"
}

## リファクタリングのタイミングでコメントアウト解除
# module "subnet" {
#   source = "./modules/subnet"
#   vpc-id = module.vpc.vpc-id
# }

# moved {
#   from = module.vpc.aws_subnet.demo
#   to   = module.subnet.aws_subnet.demo
# }
