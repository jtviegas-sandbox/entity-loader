
provider "aws" {
  version = "~> 2.33"
  region = "${var.region}"
}

module "bucket-event-handling" {
  source = "./modules/bucket-event-handling"

  bucket-name = "${var.app}-${var.env}-entities"
  function-role-name = "${var.app}-${var.env}-function-role"
  function-artifact = "../../artifacts/${var.app}.zip"
  function-name = "${var.app}-${var.env}-function"
  notification-name = "${var.app}-${var.env}-statement"
}

terraform {
  backend "s3" {
    bucket         = "store-loader-dev-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "store-loader-dev-terraform-state-lock"
    encrypt        = true
  }
}