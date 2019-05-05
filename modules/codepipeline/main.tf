## Code Pipeline

variable "github_org" {}
variable "github_repo" {}
variable "github_token" {}
variable "secret_token" {}

variable "test_env_name" {}
variable "staging_env_name" {}
variable "prod_env_name" {}

variable "test_env_branch" {}
variable "staging_env_branch" {}
variable "prod_env_branch" {}

variable "develop_build_project_name" {}
variable "master_build_project_name" {}
variable "deploy_project_name" {}

variable "cluster_name" {}
variable "service_name" {}

variable "cd_name" {}
variable "tag_name" {}


# https://www.terraform.io/docs/providers/aws/r/codepipeline.html
# test env
resource "aws_codepipeline" "test_deploy" {
  name     = "${var.cd_name}_${var.test_env_name}_env_deploy_pipeline"
  role_arn = "${aws_iam_role.code_pipeline.arn}"

  "artifact_store" {
    location = "codepipeline-${var.cd_name}-${var.test_env_name}"
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
        Owner                = "${var.github_org}"
        Repo                 = "${var.github_repo}"
        PollForSourceChanges = false
        Branch               = "${var.test_env_branch}"
        OAuthToken           = "${var.github_token}"
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
        ProjectName = "${var.develop_build_project_name}"
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
        ClusterName = "${var.cluster_name}-${var.test_env_name}"
        ServiceName = "${var.service_name}-${var.test_env_name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

# Code Pipeline - Webhook
resource "aws_codepipeline_webhook" "test_deploy" {
  name            = "${var.cd_name}_${var.test_env_name}_deploy_webhook"
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
  repository = "${var.github_repo}"
  events     = ["push"]

  configuration {
    url          = "${aws_codepipeline_webhook.test_deploy.url}"
    secret       = "${var.secret_token}"
    insecure_ssl = true
    content_type = "json"
  }
}

# staging env
resource "aws_codepipeline" "staging_deploy" {
  name     = "${var.cd_name}_${var.staging_env_name}_env_deploy_pipeline"
  role_arn = "${aws_iam_role.code_pipeline.arn}"

  "artifact_store" {
    location = "codepipeline-${var.cd_name}-${var.staging_env_name}"
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
        Owner                = "${var.github_org}"
        Repo                 = "${var.github_repo}"
        PollForSourceChanges = false
        Branch               = "${var.staging_env_branch}"
        OAuthToken           = "${var.github_token}"
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
        ProjectName = "${var.master_build_project_name}"
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
        ClusterName = "${var.cluster_name}-${var.staging_env_name}"
        ServiceName = "${var.service_name}-${var.staging_env_name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

# Code Pipeline - Webhook
resource "aws_codepipeline_webhook" "staging_deploy" {
  name            = "${var.cd_name}_${var.staging_env_name}_deploy_webhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = "${aws_codepipeline.staging_deploy.name}"

  "filter" {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }

  authentication_configuration {
    secret_token = "${var.secret_token}"
  }
}

# Github - Webhook
resource "github_repository_webhook" "staging_deploy" {
  name       = "web"                    // これで固定でOK
  repository = "${var.github_repo}"
  events     = ["push"]

  configuration {
    url          = "${aws_codepipeline_webhook.staging_deploy.url}"
    secret       = "${var.secret_token}"
    insecure_ssl = true
    content_type = "json"
  }
}

# prod env
resource "aws_codepipeline" "prod_deploy" {
  name     = "${var.cd_name}_${var.prod_env_name}_deploy_pipeline"
  role_arn = "${aws_iam_role.code_pipeline.arn}"

  "artifact_store" {
    location = "codepipeline-${var.cd_name}-${var.prod_env_name}"
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
        Owner                = "${var.github_org}"
        Repo                 = "${var.github_repo}"
        PollForSourceChanges = false
        Branch               = "${var.prod_env_branch}"
        OAuthToken           = "${var.github_token}"
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
        ProjectName = "${var.deploy_project_name}"
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
        ClusterName = "${var.cluster_name}-${var.prod_env_name}"
        ServiceName = "${var.service_name}-${var.prod_env_name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

# Code Pipeline - Webhook
resource "aws_codepipeline_webhook" "prod_deploy" {
  name            = "${var.cd_name}_${var.prod_env_name}_deploy_webhook"
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
  repository = "${var.github_repo}"
  events     = ["release"]

  configuration {
    url          = "${aws_codepipeline_webhook.prod_deploy.url}"
    secret       = "${var.secret_token}"
    insecure_ssl = true
    content_type = "json"
  }
}
