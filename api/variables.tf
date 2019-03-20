# workspaceごとに名前が替えれるならそうしたい
variable "name" {
  default = "api"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-northeast-1"
}

variable "service_desired" {
  description = "Desired numbers of instances in the ecs service"
  default     = "2"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "account_id" {}