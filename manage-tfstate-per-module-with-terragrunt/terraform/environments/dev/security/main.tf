module "security" {
  source = "../../../modules/security"
  my-ip  = var.my-ip
  vpc-id = data.terraform_remote_state.network.outputs.vpc-id
}

data "terraform_remote_state" "network" {
    backend = "local"

    config = {
        path = "../tfstate.d/network/terraform.tfstate"
    }
}
