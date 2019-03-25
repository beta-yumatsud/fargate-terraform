## ECS: fargate

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

# ECR: 必要であれば下記を参照
# https://www.terraform.io/docs/providers/aws/r/ecr_repository.html

# cluster
# https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html
resource "aws_ecs_cluster" "main" {
  name = "${var.name}"

  tags {
    Name = "${var.name}"
  }
}

# task
# https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html
data "template_file" "task_definition" {
  # https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task_definition_parameters.html
  template = "${file("${path.module}/task-definition.json")}"

  // CPU, Memoryは環境毎に分けてあげた方が良さげ
  vars {
    // templateのjsonで指定したplacefolderへの代入
    image_url        = "${var.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.component_name}:${var.image_tag}"
    container_name   = "${var.component_name}"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.app.name}"
    log_group_prefix = "${var.name}"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.name}"
  container_definitions    = "${data.template_file.task_definition.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  // ecs(タスク)実行や停止するためのrole、ECRからのアクセスなどにも権限が必要
  execution_role_arn = "${aws_iam_role.ecs_task_exec_role.arn}"

  // コンテナ毎(実行時)のrole。アプリケーション等で利用するための権限設定はこっち
  //task_role_arn = ""
  tags {
    Name = "${var.name}"
  }
}

# service
# https://www.terraform.io/docs/providers/aws/r/ecs_service.html
resource "aws_ecs_service" "main" {
  // 色々と設定できるので、詳細は上記のリンクを確認してみる
  name            = "${var.name}"
  cluster         = "${aws_ecs_cluster.main.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.main.arn}"
  desired_count   = "${var.service_desired}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.main.id}"
    container_name   = "${var.component_name}"
    container_port   = 3000
  }

  network_configuration {
    subnets          = ["${data.terraform_remote_state.network.subnets}"]
    security_groups  = ["${aws_security_group.ecs_sg.id}"]
    assign_public_ip = true
  }

  depends_on = [
    "aws_alb_listener.main",
  ]

  tags {
    Name = "${var.name}"
  }
}
