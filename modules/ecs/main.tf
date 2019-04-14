## ECS
# 下記の宣言は variables.tf として別ファイルに定義でも可能
# 個人的にはこのくらいの数なら同ファイルの方が読みやすそう
variable "cluster_name" {}

variable "family_name" {}
variable "container_definitions" {}
variable "cpu" {}
variable "memory" {}
variable "service_name" {}
variable "desired_count" {}
variable "target_group_arn" {
  description = "The Amazon Resource Name (ARN) of the ALB that this ECS Service will use as its load balancer."
}
variable "target_alb_id" {}
variable "container_name" {}
variable "container_port" {}

variable "subnets" {
  type = "list"
}

# ECR: 必要であれば下記を参照
# https://www.terraform.io/docs/providers/aws/r/ecr_repository.html

## ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.cluster_name}"

  tags {
    Name = "${var.tag_name}"
  }
}

## ECS task definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.family_name}"
  container_definitions    = "${var.container_definitions}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"

  // ecs(タスク)実行や停止するためのrole、ECRからのアクセスなどにも権限が必要
  execution_role_arn = "${aws_iam_role.ecs_task_exec_role.arn}"

  // コンテナ毎(実行時)のrole。アプリケーション等で利用するための権限設定はこっち
  //task_role_arn = ""
  tags {
    Name = "${var.tag_name}"
  }
}

# service
# https://www.terraform.io/docs/providers/aws/r/ecs_service.html
resource "aws_ecs_service" "this" {
  // 色々と設定できるので、詳細は上記のリンクを確認してみる
  name            = "${var.service_name}"
  cluster         = "${aws_ecs_cluster.this.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.this.arn}"
  desired_count   = "${var.desired_count}"

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }

  network_configuration {
    subnets          = ["${var.subnets}"]
    security_groups  = ["${aws_security_group.this.id}"]
    assign_public_ip = true
  }

  tags {
    Name = "${var.tag_name}"
  }

  // albeをmoduleで分けた時に、albが出来上がる前にecsが立ち上がろうとして失敗してしまう対応
  // https://github.com/hashicorp/terraform/issues/12634#issuecomment-321633155
  depends_on = [
    "null_resource.alb_exists"
  ]
}

resource "null_resource" "alb_exists" {
  // ALBで依存しているものを記載しておく ( 特にALBの立ち上がりには時間がかかるので )
  triggers {
    alb_id = "${var.target_alb_id}"
    alb_name = "${var.target_group_arn}"
  }
}
