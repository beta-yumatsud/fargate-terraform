## IAM
# ECS role
data "aws_iam_policy_document" "ecs_task_exec_role_doc" {
  version = "2008-10-17"

  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_task_exec_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_exec_role_doc.json}"
}

# ECS policy
data "aws_iam_policy_document" "ecs_task_exec_role_policy_doc" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_exec_role_policy" {
  policy = "${data.aws_iam_policy_document.ecs_task_exec_role_policy_doc.json}"
  role   = "${aws_iam_role.ecs_task_exec_role.id}"
}
