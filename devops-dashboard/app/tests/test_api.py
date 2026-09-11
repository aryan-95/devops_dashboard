import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app import create_app


def make_client():
    app = create_app()
    return app.test_client()


def test_status_endpoint():
    client = make_client()
    resp = client.get("/api/status")
    assert resp.status_code == 200
    body = resp.get_json()
    assert body["status"] == "HEALTHY"


def test_server_endpoint():
    client = make_client()
    resp = client.get("/api/server")
    assert resp.status_code == 200
    body = resp.get_json()
    assert "instance_id" in body
    assert "availability_zone" in body


def test_version_endpoint():
    client = make_client()
    resp = client.get("/api/version")
    assert resp.status_code == 200
    body = resp.get_json()
    assert "version" in body


def test_dashboard_page_loads():
    client = make_client()
    resp = client.get("/")
    assert resp.status_code == 200
    assert b"DevOps Dashboard" in resp.data
