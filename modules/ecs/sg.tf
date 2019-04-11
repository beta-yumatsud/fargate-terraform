## Security Group
variable "vpc_id" {}

variable "sg_name_prefix" {}

variable "alb_sg_id" {}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "this" {
  description = "controls direct access to the ECS"
  vpc_id      = "${var.vpc_id}"
  name        = "${var.sg_name_prefix}_ecs_sg"

  tags {
    Name = "${var.tag_name}"
  }
}

# https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
resource "aws_security_group_rule" "request_ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
}

resource "aws_security_group_rule" "alb_ingress" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 1
  to_port                  = 65535
  security_group_id        = "${aws_security_group.this.id}"
  source_security_group_id = "${var.alb_sg_id}"
}

resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
}
