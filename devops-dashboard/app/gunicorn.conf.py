"""Gunicorn configuration used to run the Flask app in production on EC2."""
import multiprocessing
import os

bind = f"0.0.0.0:{os.environ.get('PORT', '8080')}"
workers = max(2, multiprocessing.cpu_count())
worker_class = "sync"
timeout = 30
accesslog = "-"       # stdout -> picked up by CloudWatch Logs agent
errorlog = "-"
loglevel = "info"
