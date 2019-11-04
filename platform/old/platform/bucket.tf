
resource "aws_s3_bucket" "store-entities" {
  bucket = "${var.app}-${var.environment}-entities"
  acl    = "public-read"

  tags = {
    app = "${var.app}"
    env = "${var.environment}"
  }
}

resource "aws_s3_bucket_notification" "store-entities-notification" {
  bucket = "${aws_s3_bucket.store-entities.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.store_entities_event.arn}"
    events              = ["s3:ObjectCreated:Put","s3:ObjectCreated:Post"]
    filter_suffix       = "trigger"
  }
}

