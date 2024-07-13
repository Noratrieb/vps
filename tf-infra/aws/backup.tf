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

resource "aws_iam_user" "backup_uploader" {
  name = "backup-uploader"
}

resource "aws_iam_access_key" "backup_uploader" {
  user = aws_iam_user.backup_uploader.name
}


resource "aws_iam_group" "backup_uploaders" {
  name = "backup-uploaders"
}

resource "aws_iam_user_group_membership" "backup_uploader" {
  user =  aws_iam_user.backup_uploader.name
  groups = [ aws_iam_group.backup_uploaders.name ]
}

resource "aws_iam_group_policy" "upload_backup" {
  name = "nilstrieb-backups-upload"
  group = aws_iam_group.backup_uploaders.name
  policy = jsonencode({
    "Version":"2012-10-17",
    "Statement":[
        {
          "Effect":"Allow",
          "Action":"s3:PutObject",
          "Resource":"arn:aws:s3:::${aws_s3_bucket.backups.bucket}/1/*"
        },
        {
          "Effect":"Deny",
          "Action":"s3:*",
          "NotResource":"arn:aws:s3:::${aws_s3_bucket.backups.bucket}/1/*"
        }
    ]
  })
}


output "backup_access_key_id" {
  value = aws_iam_access_key.backup_uploader.id
}
output "backup_access_key_secret" {
  value = aws_iam_access_key.backup_uploader.secret
  sensitive = true
}
