## network: VPC
# https://www.terraform.io/docs/providers/aws/r/vpc.html
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"     # ここは不要そう
  enable_dns_support   = true          # defaultはtrueなので不要かも
  enable_dns_hostnames = true          # ECS作成時に作成されるVPCはtrueだが不要かも

  tags {
    Name = "${var.name}"
  }
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}
