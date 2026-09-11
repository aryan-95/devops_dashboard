"""
Database status endpoint - demonstrates RDS connectivity from the app tier.
"""
from flask import Blueprint, jsonify
from services.database import get_db_status, get_recent_deployments

database_bp = Blueprint("database", __name__)


@database_bp.route("/api/database", methods=["GET"])
def api_database():
    status, detail = get_db_status()
    return jsonify({
        "database": "CONNECTED" if status else "DISCONNECTED",
        "detail": detail,
    }), (200 if status else 503)


@database_bp.route("/api/deployments", methods=["GET"])
def api_deployments():
    rows = get_recent_deployments()
    return jsonify({"deployments": rows}), 200
