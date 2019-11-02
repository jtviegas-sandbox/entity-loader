# --- users ---
resource "aws_iam_user" "iam-user-maintainer-1" {
  name = "${var.maintainer-1}"
  tags = {
    env = "${var.environment}"
  }
}
resource "aws_iam_user" "iam-user-maintainer-2" {
  name = "${var.maintainer-2}"
  tags = {
    env = "${var.environment}"
  }
}
resource "aws_iam_user_login_profile" "iam-user-profile-maintainer-1" {
  user    = "${aws_iam_user.iam-user-maintainer-1.name}"
  pgp_key = "${var.maintainer-public-key}"
}

resource "aws_iam_user_login_profile" "iam-user-profile-maintainer-2" {
  user    = "${aws_iam_user.iam-user-maintainer-2.name}"
  pgp_key = "${var.maintainer-public-key}"
}

# --- groups ---
resource "aws_iam_group" "iam-group-maintainers" {
  name = "${var.prefix}-group-maintainers"
}

# --- users <-> groups ---
resource "aws_iam_user_group_membership" "iam-user-groups-maintainer-1" {
  user    = "${aws_iam_user.iam-user-maintainer-1.name}"
  groups = [
    "${aws_iam_group.iam-group-maintainers.name}",
  ]
}
resource "aws_iam_user_group_membership" "iam-user-groups-maintainer-2" {
  user    = "${aws_iam_user.iam-user-maintainer-2.name}"
  groups = [
    "${aws_iam_group.iam-group-maintainers.name}",
  ]
}
# --- policies ---
resource "aws_iam_policy" "iam-policy-users-all" {
  name        = "${var.prefix}-policy-users-all"
  description = "general policy on all users"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": ["s3:ListAllMyBuckets","s3:HeadBucket","iam:ChangePassword"]
    }
  ]
}
EOF
}
resource "aws_iam_policy" "iam-policy-logging" {
  name        = "${var.prefix}-policy-logging"
  description = "policy allowing logs rw access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*",
      "Action": "logs:*"
    }
  ]
}
EOF
}
resource "aws_iam_policy" "iam-policy-maintainers" {
  name        = "${var.prefix}-policy-maintainers"
  description = "maintainers policy allowing buckets rw and logging"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.s3-bucket-entities.id}","arn:aws:s3:::${aws_s3_bucket.s3-bucket-entities.id}/*"],
      "Action": ["s3:ListAllMyBuckets","s3:HeadBucket","s3:ListBucketByTags","s3:GetBucketTagging","s3:ListBucketVersions","s3:GetBucketLogging","s3:CreateBucket","s3:ListBucket","s3:GetBucketPolicy","s3:PutEncryptionConfiguration","s3:GetObjectAcl","s3:PutBucketTagging","s3:DeleteObject","s3:DeleteBucket","s3:PutBucketVersioning","s3:PutObjectAcl","s3:ListBucketMultipartUploads","s3:PutObjectVersionTagging","s3:GetBucketVersioning","s3:PutBucketCORS","s3:GetBucketAcl","s3:GetBucketNotification","s3:PutInventoryConfiguration","s3:PutObject","s3:PutBucketNotification","s3:PutBucketWebsite","s3:PutBucketRequestPayment","s3:PutBucketLogging","s3:GetBucketCORS","s3:GetBucketLocation"]
    }
    , {
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*",
      "Action": "logs:*"
    }
    , {
      "Effect": "Allow",
      "Resource": "*",
      "Action": ["iam:ChangePassword"]
    }
  ]
}
EOF
}
resource "aws_iam_policy" "iam-policy-buckets-event-function" {
  name        = "${var.prefix}-policy-buckets-event-function"
  description = "policy for the buckets event function allowing logging, buckets rw and rw on the dynamodb tables"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.s3-bucket-entities.id}","arn:aws:s3:::${aws_s3_bucket.s3-bucket-entities.id}/*"],
      "Action": "s3:*"
    }
    , {
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*",
      "Action": "logs:*"
    }
    , {
      "Effect": "Allow",
      "Resource": "arn:aws:dynamodb:::table/*",
      "Action": "dynamodb:*"
    }
  ]
}
EOF
}
# --- policies <-> groups ---
resource "aws_iam_group_policy_attachment" "iam-group-policy-attach-maintainers" {
  group      = "${aws_iam_group.iam-group-maintainers.name}"
  policy_arn = "${aws_iam_policy.iam-policy-maintainers.arn}"
}
# --- roles ---
resource "aws_iam_role" "iam-role-maintainer" {
  name = "${var.prefix}-role-maintainer"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "AWS": "arn:aws:iam::692391178777:root" },
    "Action": "sts:AssumeRole"
  }
  ,
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
  ]
}
EOF
  tags = {
    env = "${var.environment}"
  }
}
# --- policies <-> roles ---
resource "aws_iam_role_policy_attachment" "iam-role-policy-attach-event-function" {
  role       = "${aws_iam_role.iam-role-maintainer.name}"
  policy_arn = "${aws_iam_policy.iam-policy-buckets-event-function.arn}"
}














