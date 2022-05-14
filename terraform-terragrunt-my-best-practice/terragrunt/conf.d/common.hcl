inputs = {
    vpc-cidr      = "10.1.0.0/16"

    subnets = [
        { cidr = "10.1.0.0/24", az = "ap-northeast-1a" },
        { cidr = "10.1.2.0/24", az = "ap-northeast-1c" },
    ]
}
