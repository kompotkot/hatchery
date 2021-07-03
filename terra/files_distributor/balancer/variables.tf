# Main variables

variable "region" {
  description = "The region that the machine should be created in"
  default     = "us-east-1"
}
variable "tag_resource" {
  description = "Resource common tag"
  default     = "hatchery"
}
