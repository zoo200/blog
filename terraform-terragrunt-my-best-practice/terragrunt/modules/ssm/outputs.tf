output "ssm-parameter-secrets-demo-db-user-name" {
  value = aws_ssm_parameter.secrets["demo-db/user"].name
}

output "ssm-parameter-secrets-demo-db-pass-name" {
  value = aws_ssm_parameter.secrets["demo-db/pass"].name
}

output "ssm-parameter-secrets-demo-token-value" {
  value = aws_ssm_parameter.demo-token.value
  sensitive = true
}