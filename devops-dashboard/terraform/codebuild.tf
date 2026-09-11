# =========================================================
# AWS CodeBuild - test, build, package the application
# =========================================================

resource "aws_codebuild_project" "app_build" {
  name         = "${local.name_prefix}-build"
  description  = "Installs deps, runs tests, packages the Flask app for deployment"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL" # cheapest CodeBuild tier
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "APP_VERSION"
      value = var.app_version
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
    }
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/${var.project_name}/codebuild"
  retention_in_days = 7
  tags              = local.common_tags
}
