# 一旦はmain.tfに書いてみて、そこからどんどん分割していく
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

## Network
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default" # ここは不要そう
  enable_dns_support = true # defaultはtrueなので不要かも
  enable_dns_hostnames = true # ECS作成時に作成されるVPCはtrueだが不要かも
  tags {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "main" {
  count = "${var.aws_az_count}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table_association" "main" {
  count = "${var.aws_az_count}"
  route_table_id = "${aws_route_table.main.id}"
  subnet_id = "${element(aws_subnet.main.*.id, count.index)}"
}

## Security
resource "aws_security_group" "lb_sg" {
  description = "controls access to the ALB"
  vpc_id = "${aws_vpc.main.id}"
  name = "alb-sg"

  ingress {
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group" "ecs_sg" {
  description = "controls direct access to the ECS"
  vpc_id = "${aws_vpc.main.id}"
  name = "ecs-sg"

  ingress {
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 1
    to_port = 65535
    security_groups = ["${aws_security_group.lb_sg.id}"]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}"
  }
}

## ALB
# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
resource "aws_alb_target_group" "main" {
  name = "tf-test"

  protocol = "http"
  port = 8080
  vpc_id = "${aws_vpc.main.id}"

  deregistration_delay = 300

  health_check {
    protocol = "http"
    path = "/" # /healthなどのチェックパスがあるならばそれを指定
    port = "traffic-port" # defaultがこれなので記載不要かも
    healthy_threshold = 5
    unhealthy_threshold = 2
    interval = 30 # defaultも30
    matcher = "200"
  }

  tags {
    Name = "${var.name}"
  }
}

# https://www.terraform.io/docs/providers/aws/r/lb.html
resource "aws_alb" "main" {
  name = "tf-test"

  subnets = ["${aws_subnet.main.*.id}"]
  security_groups = ["${aws_security_group.lb_sg.id}"]

  # access logの有効化などはした方が良さげ
  # アイドルタイムアウトなども

  tags {
    Name = "${var.name}"
  }
}

# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
resource "aws_alb_listener" "main" {
  "default_action" {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.main.arn}"
  }
  load_balancer_arn = "${aws_alb.main.arn}"
  port = 8080 # httpsで受けるようにして(443)〜とかも可能
  protocol = "http"
}

## CloudWatch Logs
# 必要に応じて作成するのが良さげ
resource "aws_cloudwatch_log_group" "ecs" {
  name = "tf-ecs-group/ecs-agent"
}

resource "aws_cloudwatch_log_group" "app" {
  name = "tf-ecs-group/app"
}

## ECS fargate
