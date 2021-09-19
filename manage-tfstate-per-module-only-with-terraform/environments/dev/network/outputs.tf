output "vpc-id" {
  value = module.network.vpc-id
  # これではNG
  #value = module.network.aws_vpc.test-vpc.id
}

output "subnet-east-id" {
  value = module.network.subnet-east-id
}

output "subnet-west-id" {
  value = module.network.subnet-west-id
}