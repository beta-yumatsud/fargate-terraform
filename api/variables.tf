# 下記は環境毎に分けることが可能
# 同ディレクトリに「_tfvars」ディレクトリを置き、そこに「prod.tfvars」「staging.tfvars」などを置いておく
# planやapply実行時に「-var-file="_tfvars/staging.tfvars"」を指定する

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "account_id" {}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-northeast-1"
}

variable "component_name" {
  default = "api"
}

variable "name" {
  default = "api"
}

variable "service_desired" {
  description = "Desired numbers of instances in the ecs service"
  default     = "2"
}

variable "image_tag" {
  default = "latest"
}
