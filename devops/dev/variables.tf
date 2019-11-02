
variable "environment" {
  description = "the deployment environment"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  default     = "development"
}

variable "app" {
  description = "the app"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  default     = "store"
}

variable "prefix" {
  description = "the resources common prefix"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  default     = "store-development"
}

variable "maintainer-1" {
  description = "a maintainer user"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  default     = "rocha"
}

variable "maintainer-2" {
  description = "a maintainer user"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  default     = "tiago"
}

variable "maintainer-public-key" {
  description = "maintainers public key to encrypt password, using keybase one"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  default     = "keybase:jtviegas"
}

variable "store-bucket-event-function-artifact" {
  description = "store bucket update function artifact location"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  default     = "../../src/store-loader.zip"
}