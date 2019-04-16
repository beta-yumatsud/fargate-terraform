## Provider
provider "github" {
  organization = "${var.organization}"
  token        = "${var.token}"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

## Continuous Integration
module "ci" {
  source = "../../modules/codebuild"

  ci_name         = "${var.component_name}"
  account_id      = "${var.account_id}"
  source_location = "https://github.com/darma2anderson/aws-pipeline-sample.git"

  tag_name        = "${var.component_name}"
}

## Continuous Delivery
module "cd" {
  source = "../../modules/codepipeline"

  cd_name             = "${var.component_name}"
  github_org          = "${var.organization}"
  github_repo         = "aws-pipeline-sample"
  github_token        = "${var.token}"

  test_env_name       = "test"
  staging_env_name    = "staging"
  prod_env_name       = "prod"

  test_env_branch     = "develop"
  staging_env_branch  = "master"
  prod_env_branch     = "master"

  build_project_name  = "${module.ci.build_pull_container_image_project}"
  deploy_project_name = "${module.ci.create_task_definition_project}"

  cluster_name = "${var.component_name}"
  service_name = "${var.component_name}"

  secret_token = "${var.secret_token}"

  tag_name     = "${var.component_name}"
}