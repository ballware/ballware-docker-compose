#!/bin/bash
set -e

echo "==> Starting SQL Server initialization..."

# Warte kurz, um sicherzustellen, dass SQL Server bereit ist
sleep 5

echo "==> Executing tenant database initialization script..."

# Führe das SQL-Skript aus
/opt/mssql-tools/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" \
    -v TENANT_PASSWORD="$TENANT_PASSWORD" \
    -i /scripts/01-create-tenant-database.sql

echo "==> SQL Server initialization completed successfully."