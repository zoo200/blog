resource "aws_kms_key" "demo" {
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "false"
  is_enabled               = "true"
  key_usage                = "ENCRYPT_DECRYPT"
  policy = templatefile("${path.module}/policy/kms.json",
    {
      account-id = data.aws_caller_identity.now.account_id
  })
}

resource "aws_kms_alias" "demo" {
  name          = "alias/demo"
  target_key_id = aws_kms_key.demo.id
}
