include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/${path_relative_to_include()}"
}

dependency "network" {
  config_path = "../network"
}

dependency "security" {
  config_path = "../security"
}

inputs = {
  vpc-id            = dependency.network.outputs.vpc-id
  subnet-east-id    = dependency.network.outputs.subnet-east-id
  subnet-west-id    = dependency.network.outputs.subnet-west-id
  sg-test-lb-id     = dependency.security.outputs.sg-test-lb-id
  sg-test-server-id = dependency.security.outputs.sg-test-server-id
}
