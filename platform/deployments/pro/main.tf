
provider "aws" {
  version = "~> 2.33"
  region = "eu-west-1"
}

module "services" {
  source = "../../modules/services"

  iam-role-maintainer_arn = module.security.iam-role-maintainer_arn
  environment = "pro"
  app = "store"
  entity-1 = "parts"
  store-bucket-event-function-artifact = "../../../src/store-loader.zip"

}

module "security" {
  source = "../../modules/security"

  s3-bucket-entities_id = module.services.s3-bucket-entities_id
  environment = "pro"
  app = "store"
  maintainer-1    = "rocha"
  maintainer-2    = "tiago"
  maintainer-public-key = "keybase:jtviegas"

}