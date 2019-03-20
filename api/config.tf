terraform {
  backend "s3" {
    bucket = "terraform-sample-api"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}
