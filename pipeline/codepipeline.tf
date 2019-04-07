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

## Code Pipeline
# https://www.terraform.io/docs/providers/aws/r/codepipeline.html
# develop, staging env
resource "aws_codepipeline" "test_deploy" {
  name     = "${var.name}-deploy-pipeline"
  role_arn = "${aws_iam_role.code_pipeline.arn}"

  "artifact_store" {
    // TODO S3の設定は別途設定したほうが良さそう
    location = "codepipeline-${var.aws_region}-140638950365"
    type     = "S3"
  }

  // Source Step
  "stage" {
    name = "Source"

    "action" {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration {
        Owner                = "darma2anderson"      // My GitHub Account Name
        Repo                 = "aws-pipeline-sample" // repository name
        PollForSourceChanges = false
        Branch               = "master"              // TODO ここが環境によって変わる
        OAuthToken           = "${var.token}"
      }
    }
  }

  // Build Step
  stage {
    name = "Build"

    "action" {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration {
        ProjectName = "${aws_codebuild_project.build_pull_container_image.name}"
      }
    }
  }

  // Deploy Step
  stage {
    name = "Deploy"

    "action" {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["BuildArtifact"]

      configuration {
        ClusterName = "${var.name}"           // TODO ここが環境によって変わる
        ServiceName = "${var.name}"           // TODO ここが環境によって変わる
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

# Code Pipeline - Webhook
resource "aws_codepipeline_webhook" "test_deploy" {
  name            = "test_deploy_webhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = "${aws_codepipeline.test_deploy.name}"

  "filter" {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }

  authentication_configuration {
    secret_token = "${var.secret_token}"
  }
}

# Github - Webhook
resource "github_repository_webhook" "test_deploy" {
  name       = "web"                    // これで固定でOK
  repository = "${var.repository_name}"
  events     = ["push"]

  configuration {
    url          = "${aws_codepipeline_webhook.test_deploy.url}"
    secret       = "${var.secret_token}"
    insecure_ssl = true
    content_type = "json"
  }
}

# prod env
resource "aws_codepipeline" "prod_deploy" {
  name     = "${var.name}-prod-deploy-pipeline"
  role_arn = "${aws_iam_role.code_pipeline.arn}"

  "artifact_store" {
    // TODO S3の設定は別途設定したほうが良さそう
    location = "codepipeline-${var.aws_region}-140638950365"
    type     = "S3"
  }

  // Source Step
  "stage" {
    name = "Source"

    "action" {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration {
        Owner                = "darma2anderson"      // My GitHub Account Name
        Repo                 = "aws-pipeline-sample" // repository name
        PollForSourceChanges = false
        Branch               = "master"              // TODO ここが環境によって変わる
        OAuthToken           = "${var.token}"
      }
    }
  }

  // Build Step
  stage {
    name = "Build"

    "action" {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration {
        ProjectName = "${aws_codebuild_project.create_task_definition.name}"
      }
    }
  }

  // Deploy Step
  stage {
    name = "Deploy"

    "action" {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["BuildArtifact"]

      configuration {
        ClusterName = "${var.name}"           // TODO ここが環境によって変わる
        ServiceName = "${var.name}"           // TODO ここが環境によって変わる
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

# Code Pipeline - Webhook
resource "aws_codepipeline_webhook" "prod_deploy" {
  name            = "prod_deploy_webhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = "${aws_codepipeline.prod_deploy.name}"

  "filter" {
    json_path    = "$.action"
    match_equals = "published"
  }

  authentication_configuration {
    secret_token = "${var.secret_token}"
  }
}

# Github - Webhook
# https://developer.github.com/v3/activity/events/types/#releaseevent
# https://developer.github.com/v3/repos/hooks/#create-a-hook
resource "github_repository_webhook" "prod_deploy" {
  name       = "web"                    // これで固定でOK
  repository = "${var.repository_name}"
  events     = ["release"]

  configuration {
    url          = "${aws_codepipeline_webhook.prod_deploy.url}"
    secret       = "${var.secret_token}"
    insecure_ssl = true
    content_type = "json"
  }
}
