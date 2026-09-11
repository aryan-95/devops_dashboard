# =========================================================
# RDS MySQL (Tier 3 - Database) - private only, never public
# =========================================================

resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.db[*].id
  tags       = local.common_tags
}

# Auto-generated strong password - never hardcoded, never checked into Git.
resource "random_password" "db" {
  length  = 20
  special = false # avoids MySQL-incompatible characters in connection strings
}

resource "aws_db_instance" "main" {
  identifier     = "${local.name_prefix}-db"
  engine         = "mysql"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  storage_type          = "gp3"
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = false
  multi_az             = var.db_multi_az

  backup_retention_period = 1
  skip_final_snapshot     = true # OK for a student project; disable in real production

  tags = local.common_tags
}

# ---------------- SSM Parameter Store: DB connection info for EC2 to read at boot ----------------

resource "aws_ssm_parameter" "db_host" {
  name  = "/${var.project_name}/db_host"
  type  = "String"
  value = aws_db_instance.main.address
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.project_name}/db_username"
  type  = "String"
  value = var.db_username
  tags  = local.common_tags
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/db_password"
  type  = "SecureString"
  value = random_password.db.result
  tags  = local.common_tags
}
