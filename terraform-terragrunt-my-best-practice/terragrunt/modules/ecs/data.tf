data "aws_caller_identity" "now" {}
data "aws_region" "now" {}
data "aws_kms_key" "ssm" {
  key_id = "alias/aws/ssm"
}
