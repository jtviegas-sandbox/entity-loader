
resource "aws_s3_bucket" "s3-bucket-entities" {
  bucket = "${var.prefix}-parts"
  acl    = "public-read"

  tags = {
    env = "${var.environment}"
  }
}

resource "aws_s3_bucket_notification" "s3-bucket_notification" {
  bucket = "${aws_s3_bucket.s3-bucket-entities.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.lambda-function-store-bucket-event.arn}"
    events              = ["s3:ObjectCreated:Put","s3:ObjectCreated:Post"]
    filter_suffix       = "trigger"
  }
}