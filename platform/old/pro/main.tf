
provider "aws" {
  version = "~> 2.33"
  region = "eu-west-1"
}

module "security" {
  source = "../modules/security"

  environment = "pro"
  app = "store"
  maintainer-1    = "rocha"
  maintainer-2    = "tiago"
  maintainer-public-key = "keybase:jtviegas"

}

module "services" {
  source = "../modules/services"

  environment = "pro"
  app = "store"
  entity-1 = "rocha"
  store-bucket-event-function-artifact = "../../src/store-loader.zip"

}