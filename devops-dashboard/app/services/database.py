"""
Database service layer.

Connects to AWS RDS MySQL over private networking (app subnet -> db subnet).
Credentials come from environment variables that are populated at instance
boot time from AWS SSM Parameter Store (see terraform/user_data.sh).
"""
from config.config import Config

try:
    import pymysql
except ImportError:  # pymysql is only needed when actually talking to RDS
    pymysql = None


def get_connection(timeout=3):
    if pymysql is None:
        raise RuntimeError("PyMySQL is not installed. Run: pip install -r requirements.txt")
    return pymysql.connect(
        host=Config.DB_HOST,
        port=Config.DB_PORT,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        database=Config.DB_NAME,
        connect_timeout=timeout,
        cursorclass=pymysql.cursors.DictCursor,
    )


def get_db_status():
    """Returns (is_connected: bool, detail: str)."""
    if not Config.DB_HOST:
        return False, "DB_HOST not configured"
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            cur.fetchone()
        conn.close()
        return True, "Connected to RDS MySQL"
    except Exception as exc:  # noqa: BLE001 - surface any DB error to the API
        return False, str(exc)


def init_schema():
    """Creates tables if they do not exist. Safe to run repeatedly."""
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS deployments (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    version VARCHAR(50) NOT NULL,
                    environment VARCHAR(50) NOT NULL,
                    status VARCHAR(50) NOT NULL,
                    deployed_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)
            cur.execute("""
                CREATE TABLE IF NOT EXISTS health_checks (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    instance_id VARCHAR(50) NOT NULL,
                    status VARCHAR(50) NOT NULL,
                    checked_at DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)
        conn.commit()
    finally:
        conn.close()


def record_deployment(version, environment, status):
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO deployments (version, environment, status) VALUES (%s, %s, %s)",
                (version, environment, status),
            )
        conn.commit()
    finally:
        conn.close()


def get_recent_deployments(limit=5):
    try:
        conn = get_connection()
        with conn.cursor() as cur:
            cur.execute(
                "SELECT version, environment, status, deployed_at "
                "FROM deployments ORDER BY deployed_at DESC LIMIT %s",
                (limit,),
            )
            rows = cur.fetchall()
        conn.close()
        for r in rows:
            r["deployed_at"] = str(r["deployed_at"])
        return rows
    except Exception:
        return []
