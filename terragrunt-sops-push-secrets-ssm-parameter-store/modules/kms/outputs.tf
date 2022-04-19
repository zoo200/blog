## outputとして別の処理へ渡す
output "ssm-parameter-name-secrets-demo-db-user" {
  value = aws_ssm_parameter.secrets["demo-db/user"].name
}

output "ssm-parameter-value-secrets-demo-db-user" {
  sensitive = true 
  value = aws_ssm_parameter.secrets["demo-db/user"].value
}

output "ssm-parameter-name-secrets-demo-db-pass" {
  value = aws_ssm_parameter.secrets["demo-db/pass"].name
}

output "ssm-parameter-value-secrets-demo-db-pass" {
  sensitive = true
  value = aws_ssm_parameter.secrets["demo-db/pass"].value
}
