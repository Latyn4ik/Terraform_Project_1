resource "random_id" "tf_bucket_id" {
  byte_length = 3
}

resource "aws_s3_bucket" "openserch_package" {
  bucket = "${var.environment}-openserchpackagebucket-${random_id.tf_bucket_id.dec}"
}

resource "aws_s3_bucket_acl" "openserch_package_acl" {
  bucket = aws_s3_bucket.openserch_package.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "openserch_package_bucket_access" {
  bucket                  = aws_s3_bucket.openserch_package.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
