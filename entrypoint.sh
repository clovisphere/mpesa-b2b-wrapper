#!/bin/sh
set -e

RUN_MIGRATION="echo running (flask db) migrations...;flask db upgrade"

if [ "$1" = "production" ]
then
    # Assumes the PROD database engine is MySQL 🤭
    eval ${RUN_MIGRATION}
    
    gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:9999
else
    echo "waiting for postgres connection"
    while ! nc -z db 5432; do
        sleep 0.1
    done

    eval ${RUN_MIGRATION}

    echo "starting the web-api"
    gunicorn --bind 0.0.0.0:5000 wsgi:app --workers=4 --timeout=120 --log-level=debug
fi