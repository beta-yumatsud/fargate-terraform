## log: cloud watch logs
resource "aws_cloudwatch_log_group" "app" {
  name = "${var.name}/app"

  tags {
    Name = "${var.name}"
  }
}
