## ALB
module "alb" {
  source = "../modules/alb"

  // SG
  vpc_id         = "${data.terraform_remote_state.network.vpc_id}"
  sg_name_prefix = "${var.component_name}"

  // ALB
  alb_name    = "${var.component_name}"
  alb_subnets = ["${data.terraform_remote_state.network.subnets}"]

  // Adding common tag
  tag_name = "${var.component_name}"
}
