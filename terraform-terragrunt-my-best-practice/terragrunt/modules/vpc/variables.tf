variable "vpc-cidr" {
    type = string
}
variable "subnets" {
    type = list(map(string))
}