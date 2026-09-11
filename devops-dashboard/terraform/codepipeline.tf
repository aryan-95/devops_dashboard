# =========================================================
# AWS CodePipeline - orchestrates: GitHub -> CodeBuild -> Deploy
#
# NOTE: The GitHub source action requires a one-time manual step:
# create + authorize an AWS CodeStar Connection to GitHub (console or CLI),
# then set its ARN as var.codestar_connection_arn. This cannot be fully
# automated by Terraform because the GitHub OAuth authorization step
# requires a human to click "Authorize" in the browser.
# =========================================================

resource "aws_codepipeline" "app_pipeline" {
  name     = "${local.name_prefix}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo_name}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Test_And_Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Rolling_Deploy"
      category         = "Build" # CodeBuild used as the deploy mechanism (starts ASG instance refresh)
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy_trigger.name
      }
    }
  }

  tags = local.common_tags
}
