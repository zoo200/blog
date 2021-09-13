output "alb-domain" {
  value = module.hello-app-server.alb-domain
}
output "ec2-east-ip" {
  value = module.hello-app-server.ec2-east-ip
}
output "ec2-west-ip" {
  value = module.hello-app-server.ec2-west-ip
}

