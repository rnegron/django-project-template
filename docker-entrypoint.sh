#!/usr/bin/env bash

set -euo pipefail

postgres_ready() {
    python manage.py shell << END
import sys
import psycopg2
from django.db import connections
try:
  connections['default'].cursor()
except psycopg2.OperationalError:
    sys.exit(-1)
sys.exit(0)
END
}

until postgres_ready; do
      >&2 echo "==> Waiting for Postgres..."
      sleep 1
    done

case "$1" in
  "dev_web_start")
    echo "==> Running migrations..."
    python manage.py collectstatic --noinput
    python manage.py makemigrations
    python manage.py migrate

    echo "==> Loading initial data..."
    python manage.py loaddata "{{ project_name }}/users/fixtures/initial.json"

    echo "==> Running web dev server..."
    python manage.py runserver 0.0.0.0:8000
    ;;

  "dev_tailwind_start")
    echo "==> Running Tailwind..."
    python manage.py tailwind start
    ;;

  "dev_worker_start")
    echo "==> Running Celery worker and beat..."
    celery -A {{ project_name }} worker --beat --scheduler django --loglevel=info
    ;;
  *)
    exec "$@"
    ;;
esac
