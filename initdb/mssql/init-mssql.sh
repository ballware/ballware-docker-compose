#!/bin/bash
set -euo pipefail

echo "==> Starting SQL Server initialization..."

# Wait for SQL Server to accept connections
for i in {1..30}; do
    if /opt/mssql-tools/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -b -Q "SELECT 1" >/dev/null 2>&1; then
        break
    fi
        if /opt/mssql-tools18/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -C -b -Q "SELECT 1" >/dev/null 2>&1; then
        break
    fi
    echo "Waiting for SQL Server to be ready ($i/30)..."
    sleep 2
done

echo "==> Executing tenant database initialization script..."

# Run the SQL scripts using whichever sqlcmd exists
if command -v /opt/mssql-tools/bin/sqlcmd >/dev/null 2>&1; then
    /opt/mssql-tools/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -b \
        -v TENANT_PASSWORD="$TENANT_PASSWORD" \
        -i /scripts/01-create-tenant-database.sql
    /opt/mssql-tools/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -b \
        -v TENANT_PASSWORD="$TENANT_PASSWORD" \
        -i /scripts/02-setup-tenant-login-and-user.sql
elif command -v /opt/mssql-tools18/bin/sqlcmd >/dev/null 2>&1; then
    /opt/mssql-tools18/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -C -b \
        -v TENANT_PASSWORD="$TENANT_PASSWORD" \
        -i /scripts/01-create-tenant-database.sql
    /opt/mssql-tools18/bin/sqlcmd -S mssql -U sa -P "$SA_PASSWORD" -C -b \
        -v TENANT_PASSWORD="$TENANT_PASSWORD" \
        -i /scripts/02-setup-tenant-login-and-user.sql
else
    echo "sqlcmd not found in expected paths" >&2
    exit 1
fi

echo "==> SQL Server initialization completed successfully."