output "alb_dns_name" {
  description = "Public URL of the DevOps Dashboard (open this in a browser)"
  value       = "http://${aws_lb.main.dns_name}"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.app.name
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "rds_endpoint" {
  description = "RDS endpoint (private - reachable only from the app subnets)"
  value       = aws_db_instance.main.address
  sensitive   = false
}

output "codepipeline_name" {
  value = aws_codepipeline.app_pipeline.name
}

output "codebuild_project_name" {
  value = aws_codebuild_project.app_build.name
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.app.name
}

output "s3_artifact_bucket" {
  value = aws_s3_bucket.pipeline_artifacts.bucket
}
