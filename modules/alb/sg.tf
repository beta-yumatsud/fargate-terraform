## Security Group

variable "sg_name_prefix" {}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "this" {
  description = "controls access to the ALB"
  vpc_id      = "${var.vpc_id}"
  name        = "${var.sg_name_prefix}_alb_sg"

  tags {
    Name = "${var.tag_name}"
  }
}

# https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3000
  to_port           = 3000
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.this.id}"
}

output "alb_sg_id" {
  value = "${aws_security_group.this.id}"
}
