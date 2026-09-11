"""
DevOps Dashboard - Flask Application Entry Point
Three-tier web application demonstration for AWS DevOps project.
"""
import os
from flask import Flask, render_template

from config.config import Config
from routes.health import health_bp
from routes.status import status_bp
from routes.database import database_bp


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # Register blueprints (each blueprint = one microservice-style route group)
    app.register_blueprint(health_bp)
    app.register_blueprint(status_bp)
    app.register_blueprint(database_bp)

    @app.route("/")
    def dashboard():
        """Main DevOps dashboard UI."""
        return render_template(
            "index.html",
            environment=Config.ENVIRONMENT,
            version=Config.APP_VERSION,
        )

    return app


app = create_app()

if __name__ == "__main__":
    # Local dev server only. In production, Gunicorn runs `app:app`.
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
