
resource "aws_dynamodb_table" "store-entity-1" {
  name           = "${var.app}-${var.environment}-${var.entity-1}"
  billing_mode = "PAY_PER_REQUEST"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"
  attribute {
    name = "id"
    type = "N"
  }
  tags = {
    app = "${var.app}"
    env = "${var.environment}"
  }
}
