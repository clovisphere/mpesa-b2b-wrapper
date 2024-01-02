#!/bin/sh
set -e

RUN_MIGRATION="echo running migrations...;flask db upgrade"

if [ "$1" = "production" ]
then
    # Assumes the PROD database engine is MySQL 🤭
    eval ${RUN_MIGRATION}
    
    echo "starting the web-api"
    gunicorn --bind=0.0.0.0:9999 --workers=5 --threads=2 --timeout=120 --log-level=info wsgi:app
    echo "Done!"
else
    echo "waiting for postgres connection"
    while ! nc -z db 5432; do
        sleep 0.1
    done

    eval ${RUN_MIGRATION}

    echo "starting the web-api"
    gunicorn --bind=0.0.0.0:9999 --log-level=debug wsgi:app
    echo "Done!"
fi