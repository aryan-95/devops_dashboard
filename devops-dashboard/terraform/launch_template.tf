# =========================================================
# Launch Template (Tier 2 - Immutable Infrastructure)
#
# Each Terraform apply that changes app_version/user_data creates a NEW
# launch template version. The ASG then performs an Instance Refresh
# (rolling replacement) rather than mutating running instances.
# =========================================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    aws_region       = var.aws_region
    project_name     = var.project_name
    environment      = var.environment
    app_version      = var.app_version
    app_port         = var.app_port
    db_name          = var.db_name
    github_repo_url  = var.github_repo_url
    github_branch    = var.github_branch
  }))

  metadata_options {
    http_tokens   = "required" # enforce IMDSv2
    http_endpoint = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name       = "${local.name_prefix}-app"
      AppVersion = var.app_version
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}
