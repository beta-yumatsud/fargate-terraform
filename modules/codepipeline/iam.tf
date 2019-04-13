## IAM
# Code Pipeline role
data "aws_iam_policy_document" "code_pipeline_role_doc" {
  version = "2012-10-17"

  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["codepipeline.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "code_pipeline" {
  name               = "ci_cd_code_pipeline_role"
  assume_role_policy = "${data.aws_iam_policy_document.code_pipeline_role_doc.json}"
}

# Code Pipeline policy
data "aws_iam_policy_document" "code_pipeline_policy_doc" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    // TODO actions、resources共に必要なものの精査は必要
    // ECRはCodeBuildが権限あればOKそうなので不要かも
    // ECS、CodeBuild、logsとかだけかな
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "codebuild:StartBuild",
      "codebuild:StopBuild",
      "codebuild:BatchGet*",
      "codebuild:Get*",
      "codebuild:List*",
      "cloudwatch:GetMetricStatistics",
      "logs:GetLogEvents",
      "events:DescribeRule",
      "events:ListTargetsByRule",
      "events:ListRuleNamesByTarget",
      "ecs:*",
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "iam:PassRole",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "code_pipeline_policy" {
  policy = "${data.aws_iam_policy_document.code_pipeline_policy_doc.json}"
  role   = "${aws_iam_role.code_pipeline.id}"
}
