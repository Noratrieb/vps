resource "aws_s3_bucket" "state" {
    bucket = "nilstrieb-states"
}

resource "aws_s3_bucket_versioning" "state" {
    bucket = aws_s3_bucket.state.bucket
    versioning_configuration {
      status = "Enabled"
    }
}
