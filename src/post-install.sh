#!/bin/bash

# Check if psql is installed, if not, install it
if ! command -v psql > /dev/null; then
    sudo apt-get update
    sudo apt-get install -y postgresql-client
fi

pip install -r src/requirements.txt

# Download the PaulGrahamEssayDataset using llamaindex-cli
llamaindex-cli download-llamadataset PaulGrahamEssayDataset --download-dir ./data

# docker compose up
docker-compose up -d

# Set PostgreSQL password
export PGPASSWORD='password@123'

# Wait for PostgreSQL to be ready
until psql -h localhost -U pguser -d mydatabase -c '\q' 2>/dev/null; do
    echo "Waiting for PostgreSQL to be ready..."
    sleep 2
done

# Check if the vector extension is installed, if not, install it
psql -h localhost -U pguser -d mydatabase -tc "SELECT 1 FROM pg_extension WHERE extname = 'vector'" | grep -q 1 || psql -h localhost -U pguser -d mydatabase -c "CREATE EXTENSION vector;"