data "terraform_remote_state" "network" {
  backend = "s3"

  config {
    bucket = "fargate-common-sample"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}
