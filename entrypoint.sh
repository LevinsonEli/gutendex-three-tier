#!/bin/bash

# Script variables
DB_CONTAINER_NAME="ps-db"
MAX_ATTEMPTS=6
INTERVAL_SEC=3

# DB HEALTHCHECK
echo "Waiting for PostgreSQL to start..."

# Checking the status of the db container 
while ! nc -z $DB_CONTAINER_NAME $POSTGRESQL_PORT && [ $MAX_ATTEMPTS -gt 0 ]; do   
  sleep $INTERVAL_SEC
  ((MAX_ATTEMPTS -= 1))
done

# Final check
if ! nc -z $DB_CONTAINER_NAME $POSTGRESQL_PORT; then
  echo "PostgreSQL has not started after $(( MAX_ATTEMPTS * INTERVAL_SEC )) seconds. Exiting..."
  exit 1
fi

echo "PostgreSQL started successfully!"

# APP PREPARING COMMANDS
echo "Migrating the Database..."
./manage.py migrate
echo "Migrated the Database successfuly"

echo "Populating the Database..."
./manage.py updatecatalog
echo "Populated the Database successfuly"

echo "Collecting static files..."
./manage.py collectstatic
echo "Collected static files successfuly"

# APP ENTRYPOINT COMMANDS
./manage.py runserver ${BIND_HOST}:${BIND_PORT}