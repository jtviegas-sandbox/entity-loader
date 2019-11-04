
variable "environment" {
  description = "the deployment environment"
  # dev | pro
  type        = string
#  default     = "dev"
}

variable "entity-1" {
  description = "one entity"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
#  default     = "part"
}

variable "app" {
  description = "the app"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
#  default     = "store"
}

variable "store-bucket-event-function-artifact" {
  description = "store bucket update function artifact location"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
#  default     = "../../src/store-loader.zip"
}

variable "iam-role-maintainer_arn" {
  description = "role arn for store maintainenance"
  # string, number, bool, list, map, set, object, tuple, and any
  type        = string
  #  default     = "../../src/store-loader.zip"
}