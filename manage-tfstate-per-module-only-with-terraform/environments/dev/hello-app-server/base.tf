terraform {
  required_version = "1.0.6"
  backend "local" {
    path = "../tfstate.d/hello-app-server/terraform.tfstate"
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "default"
}
