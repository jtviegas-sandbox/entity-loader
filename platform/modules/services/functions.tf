
# --- functions ---
resource "aws_lambda_function" "store_entities_event" {
  filename      = "${var.store-bucket-event-function-artifact}"
  function_name = "${var.app}_${var.environment}_bucket_entities"
  role          = "${var.iam-role-maintainer_arn}"
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

resource "aws_lambda_permission" "store_entities_event" {
  statement_id  = "${var.app}_${var.environment}_001"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.store_entities_event.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.store-entities.arn}"
}

