## Code Build

variable "tag_name" {}
variable "account_id" {}
variable "ci_name" {}
variable "source_location" {}

# https://www.terraform.io/docs/providers/aws/r/codebuild_project.html
# イメージのBuildとECRへのPush
resource "aws_codebuild_project" "build_and_push_container_image" {
  name         = "${var.ci_name}_build_and_push_container_image"
  description  = "build container image and push it"
  service_role = "${aws_iam_role.code_build.arn}"

  "artifacts" {
    type = "NO_ARTIFACTS"
  }

  "environment" {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:18.09.0-1.7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "ACCOUNT_ID"
      value = "${var.account_id}"
      type  = "PLAINTEXT"
    }

  }

  "source" {
    type            = "GITHUB"
    location        = "${var.source_location}"
    git_clone_depth = 1
  }

  tags {
    Name = "${var.tag_name}"
  }
}

# PRでテスト実行するbuild
# 下記ではおそらく足りないかも？やってみてダメな場合、当面は手動管理で良いかも
# https://github.com/terraform-providers/terraform-provider-aws/pull/8110
# 現在のバージョンだと、CodeBuildのコンソール上でできる、
# Primary source webhook eventsの設定は不可＞＜
resource "aws_codebuild_project" "do_test_pull_request" {
  name         = "${var.ci_name}_do_test_pull_request"
  service_role = "${aws_iam_role.code_build.arn}"
  description  = "Do unit test when creating or updating pull request"

  "artifacts" {
    type = "NO_ARTIFACTS"
  }

  "environment" {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:10.14.1-1.7.0"
    type         = "LINUX_CONTAINER"
  }

  "source" {
    type                = "GITHUB"
    location            = "${var.source_location}"
    git_clone_depth     = 1
    buildspec           = "testspec.yml"
    report_build_status = true
  }

  badge_enabled = true

  tags {
    Name = "${var.tag_name}"
  }
}

# Webhook
# https://www.terraform.io/docs/providers/github/r/repository_webhook.html
# https://developer.github.com/v3/activity/events/types/#pullrequestevent
resource "aws_codebuild_webhook" "pull_request" {
  project_name = "${aws_codebuild_project.do_test_pull_request.name}"
}

/*
// 下記は不要。ただし、上記のaws_codebuild_webhookでは、pull_requestとpushで作成されるので要注意
resource "github_repository_webhook" "pr" {
  name       = "web"                    // これで固定でOK
  repository = "${var.repository_name}"
  events     = ["pull_request"]

  configuration {
    url          = "${aws_codebuild_webhook.pull_request.payload_url}"
    secret       = "${var.secret_token}"                               //"${aws_codebuild_webhook.pull_request.secret}"
    content_type = "json"
    insecure_ssl = true
  }
}
*/

# task definitionのjsonを吐くだけ
resource "aws_codebuild_project" "create_task_definition" {
  name         = "${var.ci_name}_create_task_definition"
  description  = "Create image definition in prod env deployment."
  service_role = "${aws_iam_role.code_build.arn}"

  "artifacts" {
    type = "NO_ARTIFACTS"
  }

  "environment" {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/docker:18.09.0-1.7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ACCOUNT_ID"
      value = "${var.account_id}"
      type  = "PLAINTEXT"
    }

  }

  "source" {
    type            = "GITHUB"
    location        = "${var.source_location}"
    git_clone_depth = 1
    buildspec       = "deployspec.yml"
  }

  tags {
    Name = "${var.tag_name}"
  }
}

# output
output "build_pull_container_image_project" {
  value = "${aws_codebuild_project.build_and_push_container_image.name}"
}

output "create_task_definition_project" {
  value = "${aws_codebuild_project.create_task_definition.name}"
}