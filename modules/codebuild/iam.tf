## IAM
# Code Build role
data "aws_iam_policy_document" "code_build_role_doc" {
  version = "2012-10-17"

  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "code_build" {
  name               = "build_push_container_image"
  assume_role_policy = "${data.aws_iam_policy_document.code_build_role_doc.json}"
}

# Code Build policy
data "aws_iam_policy_document" "code_build_policy_doc" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    // TODO actions、resources共に必要なものの精査は必要
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "code_build_policy" {
  policy = "${data.aws_iam_policy_document.code_build_policy_doc.json}"
  role   = "${aws_iam_role.code_build.id}"
}
