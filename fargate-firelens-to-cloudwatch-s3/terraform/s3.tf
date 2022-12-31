resource "aws_s3_bucket" "demo-fluent-bit" {
  bucket = "zoo200-demo-fluent-bit"

}

resource "aws_s3_bucket_public_access_block" "demo-fluent-bit" {
  bucket = aws_s3_bucket.demo-fluent-bit.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
