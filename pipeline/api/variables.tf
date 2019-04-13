# AWS
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "account_id" {}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-northeast-1"
}

# Github
variable "token" {}

variable "secret_token" {}

variable "organization" {
  default = "darma2anderson"
}

# service
variable "component_name" {
  default = "api"
}

# Githubのブランチなどを使う場合は不要
variable "image_tag" {
  default = "latest"
}
