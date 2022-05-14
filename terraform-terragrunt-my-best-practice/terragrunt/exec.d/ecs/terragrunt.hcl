include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "ssm" {
  config_path = "../ssm"
}

inputs = {
  ## vpc
  vpc-demo-id = dependency.vpc.outputs.vpc-demo-id
  subnet-demo-ids = dependency.vpc.outputs.subnet-demo-ids
  sg-public-http-id = dependency.vpc.outputs.sg-public-http-id
  sg-container-http-id = dependency.vpc.outputs.sg-container-http-id
  ## ssm
  ssm-parameter-secrets-demo-db-user-name = dependency.ssm.outputs.ssm-parameter-secrets-demo-db-user-name
  ssm-parameter-secrets-demo-db-pass-name = dependency.ssm.outputs.ssm-parameter-secrets-demo-db-pass-name
  ssm-parameter-secrets-demo-token-value = dependency.ssm.outputs.ssm-parameter-secrets-demo-token-value
}


