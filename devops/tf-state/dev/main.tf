
provider "aws" {
  version = "~> 2.33"
  region = "${var.region}"
}

module "tf-remote-state" {
  source = "./modules/tf-remote-state"
  environment = "${var.env}"
  application = "${var.app}"
}

output "bucket-arn" {
  value       = module.tf-remote-state.bucket-arn
}

output "bucket-id" {
  value       = module.tf-remote-state.bucket-id
}

output "table-arn" {
  value       = module.tf-remote-state.table-arn
}

output "table-id" {
  value       = module.tf-remote-state.table-id
}

