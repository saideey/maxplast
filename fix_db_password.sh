#!/bin/bash

# ===========================================
# Database Password Fix Script
# ===========================================
# Run this script when you get "password authentication failed" error
# Usage: ./fix_db_password.sh
# ===========================================

set -e

echo "🔧 Max Plast - Database Password Fix"
echo "======================================="

# Get password from .env file
if [ -f .env ]; then
    source .env
fi

POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}
POSTGRES_USER=${POSTGRES_USER:-postgres}

echo "📋 Current settings:"
echo "   User: $POSTGRES_USER"
echo "   Password: $POSTGRES_PASSWORD"
echo ""

# Check if db container is running
if ! docker ps | grep -q maxplast_db; then
    echo "❌ Database container is not running!"
    echo "   Starting containers..."
    docker-compose up -d db
    sleep 5
fi

echo "🔄 Updating PostgreSQL password..."

# Update password in PostgreSQL
docker exec -i maxplast_db psql -U postgres -d postgres <<EOF
ALTER USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';
EOF

if [ $? -eq 0 ]; then
    echo "✅ Password updated successfully!"
else
    echo "❌ Failed to update password"
    exit 1
fi

echo ""
echo "🔄 Restarting API container..."
docker restart maxplast_api

echo ""
echo "⏳ Waiting for API to be ready..."
sleep 10

# Check health
echo "🔍 Checking API health..."
HEALTH=$(curl -s http://localhost:${API_PORT:-8917}/health 2>/dev/null || echo "failed")

if echo "$HEALTH" | grep -q "healthy"; then
    echo "✅ API is healthy!"
    echo ""
    echo "🎉 Fix completed successfully!"
else
    echo "⚠️  API health check returned: $HEALTH"
    echo "   Try running: docker logs maxplast_api"
fi
