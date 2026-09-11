"""
Application status, server info, and version endpoints.
"""
import socket
from datetime import datetime, timezone

from flask import Blueprint, jsonify
from config.config import Config

status_bp = Blueprint("status", __name__)


@status_bp.route("/api/status", methods=["GET"])
def api_status():
    return jsonify({
        "application": "DevOps Dashboard",
        "status": "HEALTHY",
        "environment": Config.ENVIRONMENT,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }), 200


@status_bp.route("/api/server", methods=["GET"])
def api_server():
    return jsonify({
        "instance_id": Config.INSTANCE_ID,
        "availability_zone": Config.AVAILABILITY_ZONE,
        "hostname": socket.gethostname(),
    }), 200


@status_bp.route("/api/version", methods=["GET"])
def api_version():
    return jsonify({
        "version": Config.APP_VERSION,
        "last_deployed_at": Config.LAST_DEPLOYED_AT,
    }), 200
