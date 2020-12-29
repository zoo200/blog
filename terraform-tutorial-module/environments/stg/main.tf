terraform {
  required_version = "0.13.5"
  backend "local" {}
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "staging"
}

module "network" {
  source = "../../modules/network"
}

module "security" {
  source = "../../modules/security"
  my-ip  = var.my-ip
  vpc-id = module.network.vpc-id
}

module "hello-app-server" {
  source            = "../../modules/hello-app-server"
  ec2-config        = var.ec2-config
  vpc-id            = module.network.vpc-id
  subnet-east-id    = module.network.subnet-east-id
  subnet-west-id    = module.network.subnet-west-id
  sg-test-lb-id     = module.security.sg-test-lb-id
  sg-test-server-id = module.security.sg-test-server-id
}

output "alb-domain" {
  value = module.hello-app-server.alb-domain
}
output "ec2-east-ip" {
  value = module.hello-app-server.ec2-east-ip
}
output "ec2-west-ip" {
  value = module.hello-app-server.ec2-west-ip
}

