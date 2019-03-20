terraform {
  backend "s3" {
    bucket = "fargate-common-sample"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}
