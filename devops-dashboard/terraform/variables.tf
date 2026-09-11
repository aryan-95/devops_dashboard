variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used to prefix/tag all resources"
  type        = string
  default     = "devops-dashboard"
}

variable "environment" {
  description = "Deployment environment name shown on the dashboard"
  type        = string
  default     = "production"
}

# ---------------- Networking ----------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Two AZs used to spread resources for high availability"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "app_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "db_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway (costs money/hour). Needed so app instances can pull packages/AMI updates from the internet. Set false to save cost if using a fully self-contained AMI."
  type        = bool
  default     = true
}

# ---------------- Compute / ASG ----------------

variable "instance_type" {
  description = "EC2 instance type - kept small for student/low-cost use"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  type    = number
  default = 2
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 4
}

variable "asg_target_cpu_utilization" {
  description = "Target CPU % for target-tracking auto scaling policy"
  type        = number
  default     = 60
}

variable "app_port" {
  description = "Port the Flask/Gunicorn app listens on inside EC2"
  type        = number
  default     = 8080
}

variable "app_version" {
  description = "Application version tag shown on the dashboard; also used as a Launch Template trigger for rolling replacement"
  type        = string
  default     = "v1.0.0"
}

variable "github_repo_url" {
  description = "Public HTTPS URL of the GitHub repo the EC2 user-data script pulls the app from"
  type        = string
  default     = "https://github.com/YOUR_USERNAME/devops-dashboard.git"
}

variable "github_branch" {
  description = "Branch the instances deploy from"
  type        = string
  default     = "main"
}

# ---------------- Database ----------------

variable "db_instance_class" {
  description = "RDS instance class - db.t3.micro is free-tier eligible"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine_version" {
  type    = string
  default = "8.0"
}

variable "db_name" {
  type    = string
  default = "devops_dashboard"
}

variable "db_username" {
  description = "Master username for RDS. Password is auto-generated and stored in SSM Parameter Store, never in Terraform state as plaintext output."
  type        = string
  default     = "dbadmin"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_multi_az" {
  description = "Multi-AZ RDS costs more; keep false for a low-cost student project unless demonstrating DB failover specifically"
  type        = bool
  default     = false
}

# ---------------- CI/CD ----------------

variable "github_owner" {
  description = "GitHub username/org that owns the repo"
  type        = string
  default     = "YOUR_USERNAME"
}

variable "github_repo_name" {
  description = "GitHub repository name (without owner)"
  type        = string
  default     = "devops-dashboard"
}

variable "codestar_connection_arn" {
  description = "ARN of an AWS CodeStar Connections GitHub connection (create manually once in the AWS Console/CLI and authorize it, then paste the ARN here). Required for CodePipeline's GitHub v2 source action."
  type        = string
  default     = ""
}

# ---------------- Monitoring ----------------

variable "alarm_email" {
  description = "Optional email to notify on CloudWatch alarms (SNS subscription). Leave blank to skip email notifications."
  type        = string
  default     = ""
}

variable "cpu_alarm_threshold" {
  type    = number
  default = 70
}
