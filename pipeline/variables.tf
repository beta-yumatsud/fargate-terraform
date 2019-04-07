## Github
variable "token" {}

variable "secret_token" {}

variable "organization" {
  default = "darma2anderson"
}

variable "repository_name" {
  default = "aws-pipeline-sample"
}

## AWS
variable "aws_access_key" {}

variable "aws_secret_key" {}
variable "account_id" {}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-northeast-1"
}

variable "image_tag" {
  default = "latest"
}

variable "name" {
  default = "api-stg"
}

variable "component_name" {
  default = "api"
}
