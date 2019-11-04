variable "environment" {
  description = "the deployment environment"
  # dev | pro
  type        = string
  # default     = "dev"
}

variable "app" {
  description = "the app"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  # default     = "store"
}

variable "maintainer-1" {
  description = "a maintainer user"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  # default     = "rocha"
}

variable "maintainer-2" {
  description = "a maintainer user"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  # default     = "tiago"
}

variable "maintainer-public-key" {
  description = "maintainers public key to encrypt password, using keybase one"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  # default     = "keybase:jtviegas"
}

variable "s3-bucket-entities_id" {
  description = "id of the entitties bucket"
  type        = string
}
