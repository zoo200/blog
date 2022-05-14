variable "env" {
    type    = string
}

variable "ecs-config" {
    type    = map(number)
}

variable "vpc-demo-id" {
    type    = string
}

variable "subnet-demo-ids" {
    type    = list(string)
}

variable "sg-public-http-id" {
    type    = string
}

variable "sg-container-http-id" {
    type    = string
}

variable "ssm-parameter-secrets-demo-db-user-name" {
    type    = string
}

variable "ssm-parameter-secrets-demo-db-pass-name" {
    type    = string
}

variable "ssm-parameter-secrets-demo-token-value" {
    type    = string
}
