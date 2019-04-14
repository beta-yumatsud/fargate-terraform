## ALB
# TODO portとかはvariableに指定しても良いかも
variable "alb_name" {}

variable "alb_subnets" {
  type = "list"
}

# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
resource "aws_alb_target_group" "main" {
  name = "${var.alb_name}"

  protocol    = "HTTP"
  port        = 3000
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  deregistration_delay = 300

  health_check {
    protocol            = "HTTP"
    path                = "/"            # /healthなどのチェックパスがあるならばそれを指定
    port                = "traffic-port" # defaultがこれなので記載不要かも
    healthy_threshold   = 5
    unhealthy_threshold = 2
    interval            = 30             # defaultも30
    matcher             = "200"
  }

  tags {
    Name = "${var.tag_name}"
  }
}

# https://www.terraform.io/docs/providers/aws/r/lb.html
resource "aws_alb" "main" {
  name = "${var.alb_name}"

  subnets         = ["${var.alb_subnets}"]
  security_groups = ["${aws_security_group.this.id}"]

  # access logの有効化などはした方が良さげ
  # アイドルタイムアウトなども

  tags {
    Name = "${var.tag_name}"
  }
}

# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
resource "aws_alb_listener" "main" {
  "default_action" {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.main.arn}"
  }

  load_balancer_arn = "${aws_alb.main.arn}"
  port              = 3000                  # httpsで受けるようにして(443)〜とかも可能
  protocol          = "HTTP"
}

output "alb_target_group_id" {
  value = "${aws_alb_target_group.main.id}"
}

// 実際には使わないが、ecsがこの後に作成して欲しく、依存を作るため。
output "alb_id" {
  value = "${aws_alb.main.id}"
}
