# --- functions ---
resource "aws_lambda_function" "lambda-function-store-bucket-event" {
  filename      = "${var.store-bucket-event-function-artifact}"
  function_name = "${var.prefix}-store-bucket-event"
  role          = "${aws_iam_role.iam-role-maintainer.arn}"
  handler       = "index.handler"

  runtime = "nodejs8.10"
  memory_size = 1024
  timeout = 60
  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_permission" "lambda-function-permission-store-bucket-event" {
  statement_id  = "${var.prefix}_001"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-function-store-bucket-event.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.s3-bucket-entities.arn}"
}