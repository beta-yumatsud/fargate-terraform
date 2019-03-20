## log: cloud watch logs
resource "aws_cloudwatch_log_group" "app" {
  name = "tf-ecs-group/app"
}
