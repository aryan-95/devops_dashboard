"""
Health check endpoint.

This is the endpoint the ALB Target Group polls to decide whether an EC2
instance is healthy. If this returns anything other than HTTP 200, the ALB
marks the instance unhealthy and the Auto Scaling Group replaces it.
"""
from flask import Blueprint, jsonify

health_bp = Blueprint("health", __name__)


@health_bp.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200
