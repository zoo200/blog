terraform {
  required_version = "~> 1.3"
  backend "local" {}
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}
