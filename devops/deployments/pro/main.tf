
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

module "table-parts" {
  source = "./modules/simple-table"
  name = "${var.app}-${var.env}-parts"
}

terraform {
  backend "s3" {
    bucket         = "store-loader-pro-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "store-loader-pro-terraform-state-lock"
    encrypt        = true
  }
}