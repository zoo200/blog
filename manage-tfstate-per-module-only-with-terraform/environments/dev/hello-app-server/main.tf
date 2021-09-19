module "hello-app-server" {
  source            = "../../../modules/hello-app-server"
  ec2-config        = var.ec2-config
  vpc-id            = data.terraform_remote_state.network.outputs.vpc-id
  subnet-east-id    = data.terraform_remote_state.network.outputs.subnet-east-id
  subnet-west-id    = data.terraform_remote_state.network.outputs.subnet-west-id
  sg-test-lb-id     = data.terraform_remote_state.security.outputs.sg-test-lb-id
  sg-test-server-id = data.terraform_remote_state.security.outputs.sg-test-server-id
}


data "terraform_remote_state" "network" {
    backend = "local"

    config = {
        path = "../tfstate.d/network/terraform.tfstate"
    }
}

data "terraform_remote_state" "security" {
    backend = "local"

    config = {
        path = "../tfstate.d/security/terraform.tfstate"
    }
}
