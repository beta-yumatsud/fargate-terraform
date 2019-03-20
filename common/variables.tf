variable "name" {
  default = "common"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-northeast-1"
}

variable "aws_az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = 2
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

