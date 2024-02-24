resource "aws_s3_bucket" "personal_backups" {
    bucket = "nilstrieb-personal-backup"
}

resource "aws_s3_bucket_lifecycle_configuration" "personal_backups_lifecycle" {
    bucket = aws_s3_bucket.personal_backups.bucket
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

resource "aws_iam_user" "personal_backup_uploader" {
  name = "personal-backup-uploader"
}

resource "aws_iam_access_key" "personal_backup_uploader" {
  user = aws_iam_user.personal_backup_uploader.name
}


resource "aws_iam_group" "personal_backup_uploaders" {
  name = "personal-backup-uploaders"
}

resource "aws_iam_user_group_membership" "personal_backup_uploader" {
  user =  aws_iam_user.personal_backup_uploader.name
  groups = [ aws_iam_group.personal_backup_uploaders.name ]
}

resource "aws_iam_group_policy" "upload_personal_backup" {
  name = "nilstrieb-personal-backups-upload"
  group = aws_iam_group.personal_backup_uploaders.name
  policy = jsonencode({
    "Version":"2012-10-17",
    "Statement":[
        {
          "Effect":"Allow",
          "Action":"s3:*",
          "Resource":"arn:aws:s3:::${aws_s3_bucket.personal_backups.bucket}*"
        },
    ]
  })
}


output "personal_backup_access_key_id" {
  value = aws_iam_access_key.personal_backup_uploader.id
}
output "personal_backup_access_key_secret" {
  value = aws_iam_access_key.personal_backup_uploader.secret
  sensitive = true
}
