include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules//${path_relative_to_include()}"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  vpc-id = dependency.network.outputs.vpc-id
}
