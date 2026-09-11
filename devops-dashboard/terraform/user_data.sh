#!/bin/bash
# =========================================================
# EC2 bootstrap (user-data) script.
#
# This is the "immutable infrastructure" mechanism for this project:
# every new/replaced instance runs this script ONCE at boot to pull
# the application from GitHub and configure itself automatically.
# Nobody ever SSHes in and manually edits a running server.
# =========================================================
set -euo pipefail
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== DevOps Dashboard bootstrap starting: $(date) ==="

# ---- Base packages ----
dnf install -y python3.11 python3.11-pip git amazon-cloudwatch-agent jq || \
  yum install -y python3.11 python3.11-pip git amazon-cloudwatch-agent jq

# ---- Instance metadata (IMDSv2) ----
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION="${aws_region}"

# ---- Pull database credentials from SSM Parameter Store (never hardcoded) ----
DB_HOST=$(aws ssm get-parameter --name "/${project_name}/db_host" --region "$REGION" --query Parameter.Value --output text)
DB_USER=$(aws ssm get-parameter --name "/${project_name}/db_username" --region "$REGION" --query Parameter.Value --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/${project_name}/db_password" --with-decryption --region "$REGION" --query Parameter.Value --output text)
DB_NAME="${db_name}"

# ---- Fetch application source from GitHub (immutable artifact = git ref) ----
APP_DIR=/opt/devops-dashboard
rm -rf "$APP_DIR"
git clone --branch "${github_branch}" --depth 1 "${github_repo_url}" "$APP_DIR"

cd "$APP_DIR/app"
python3.11 -m pip install --upgrade pip
python3.11 -m pip install -r requirements.txt

# ---- Environment file consumed by the systemd service ----
cat > /etc/devops-dashboard.env <<EOF
ENVIRONMENT=${environment}
APP_VERSION=${app_version}
INSTANCE_ID=$INSTANCE_ID
AVAILABILITY_ZONE=$AVAILABILITY_ZONE
LAST_DEPLOYED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
DB_HOST=$DB_HOST
DB_PORT=3306
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
PORT=${app_port}
EOF
chmod 600 /etc/devops-dashboard.env

# ---- systemd service running Gunicorn ----
cat > /etc/systemd/system/devops-dashboard.service <<EOF
[Unit]
Description=DevOps Dashboard Flask App (Gunicorn)
After=network.target

[Service]
Type=simple
WorkingDirectory=$APP_DIR/app
EnvironmentFile=/etc/devops-dashboard.env
ExecStart=/usr/local/bin/gunicorn -c gunicorn.conf.py app:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable devops-dashboard
systemctl restart devops-dashboard

# ---- CloudWatch Agent: ship app + system logs/metrics ----
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "metrics": {
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "disk": { "measurement": ["used_percent"], "resources": ["/"] }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/${project_name}/user-data",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json || true

echo "=== DevOps Dashboard bootstrap finished: $(date) ==="
