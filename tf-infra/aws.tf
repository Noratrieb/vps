resource "aws_s3_bucket" "backups" {
    bucket = "nilstrieb-backups"
}

resource "aws_s3_bucket_lifecycle_configuration" "backups_lifecycle" {
    bucket = aws_s3_bucket.backups.bucket
    rule {
      id = "1-cold"

      filter {
        prefix = "1/"
      }

      transition {
        days = 30
        storage_class = "GLACIER_IR"
      }

      status = "Enabled"
    }
}
