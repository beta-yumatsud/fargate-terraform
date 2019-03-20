## Security Group
# https://www.terraform.io/docs/providers/aws/r/security_group.html

resource "aws_security_group" "lb_sg" {
  description = "controls access to the ALB"
  vpc_id      = "${data.terraform_remote_state.network.vpc_id}"
  name        = "alb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group" "ecs_sg" {
  description = "controls direct access to the ECS"
  vpc_id      = "${data.terraform_remote_state.network.vpc_id}"
  name        = "ecs-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 1
    to_port         = 65535
    security_groups = ["${aws_security_group.lb_sg.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}"
  }
}
