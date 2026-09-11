# =========================================================
# Deploy stage: a small CodeBuild project that triggers an ASG
# "Instance Refresh" (rolling replacement). Since user_data.sh always
# clones the latest commit on the target branch at boot, refreshing
# the instances is enough to roll out the new code - no AMI rebuild
# needed for this simplified/low-cost setup.
# =========================================================

resource "aws_codebuild_project" "deploy_trigger" {
  name         = "${local.name_prefix}-deploy"
  description  = "Triggers a rolling Auto Scaling Group instance refresh to deploy the latest build"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ASG_NAME"
      value = aws_autoscaling_group.app.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-BUILDSPEC
      version: 0.2
      phases:
        build:
          commands:
            - echo "Starting rolling instance refresh on $ASG_NAME"
            - >
              aws autoscaling start-instance-refresh
              --auto-scaling-group-name "$ASG_NAME"
              --preferences '{"MinHealthyPercentage":50,"InstanceWarmup":90}'
      artifacts:
        files:
          - '**/*'
    BUILDSPEC
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
    }
  }

  tags = local.common_tags
}
