terraform {
  backend "s3" {
    bucket = "terraform-sample-pipeline"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}
