## ECS (fargate)
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

module "ecs" {
  source = "../modules/ecs"

  // SG
  vpc_id         = "${data.terraform_remote_state.network.vpc_id}"
  sg_name_prefix = "${var.component_name}"
  alb_sg_id      = "${module.alb.alb_sg_id}"

  // ECS cluster
  cluster_name = "${var.name}"

  // ECS task definition
  family_name           = "${var.component_name}"
  container_definitions = "${data.template_file.task_definition.rendered}"
  cpu                   = "512"
  memory                = "1024"

  // ECS service
  service_name     = "${var.name}"
  desired_count    = "${var.service_desired}"
  container_name   = "${var.component_name}"
  container_port   = 3000
  target_group_arn = "${module.alb.alb_target_group_id}"                // arnと書いてるけど、IDの指定が正
  target_alb_id    = "${module.alb.alb_id}"
  subnets          = ["${data.terraform_remote_state.network.subnets}"]

  // Adding common tag
  tag_name = "${var.component_name}"
}
