"""
Application configuration.

All values are supplied via environment variables so nothing is hardcoded.
In AWS, these are injected by the EC2 user-data script (see terraform/user_data.sh),
which itself reads database credentials from AWS Systems Manager (SSM) Parameter Store.
"""
import os


class Config:
    # --- Application metadata ---
    APP_VERSION = os.environ.get("APP_VERSION", "v1.0.0")
    ENVIRONMENT = os.environ.get("ENVIRONMENT", "production")

    # --- Instance / deployment metadata (populated by user_data.sh at boot) ---
    INSTANCE_ID = os.environ.get("INSTANCE_ID", "unknown")
    AVAILABILITY_ZONE = os.environ.get("AVAILABILITY_ZONE", "unknown")
    LAST_DEPLOYED_AT = os.environ.get("LAST_DEPLOYED_AT", "unknown")

    # --- Database configuration (never hardcode credentials) ---
    DB_HOST = os.environ.get("DB_HOST", "")
    DB_PORT = int(os.environ.get("DB_PORT", "3306"))
    DB_NAME = os.environ.get("DB_NAME", "devops_dashboard")
    DB_USER = os.environ.get("DB_USER", "")
    DB_PASSWORD = os.environ.get("DB_PASSWORD", "")  # pulled from SSM at instance boot

    # --- Flask ---
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-only-not-for-production")
