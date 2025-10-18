#!/usr/bin/env bash
set -euo pipefail

declare -a DBS=("keycloak" "quartz" "storage" "meta" "tenant" "ml" "reporting")

# Helper: Name der ENV-Variable für das Passwort der DB (z.B. QUARTZ_PASSWORD)
get_pw_var_name() {
  local db="$1"
  echo "$(echo "${db}_DB_PASSWORD" | tr '[:lower:]' '[:upper:]')"
}

echo "==> Creating roles (owners) ..."
for db in "${DBS[@]}"; do
  user="$db"
  pw_var="$(get_pw_var_name "$db")"
  pw="${!pw_var:-}"
  if [[ -z "$pw" ]]; then
    echo "ERROR: Missing password env var for DB '${db}' (expected ${pw_var})."
    exit 1
  fi

  # Rolle (Owner) idempotent anlegen/aktualisieren (das geht in einer Transaktion)
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO \$\$
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '${user}') THEN
        CREATE ROLE "${user}" LOGIN PASSWORD '${pw}';
      ELSE
        ALTER ROLE "${user}" LOGIN PASSWORD '${pw}';
      END IF;
    END
    \$\$;
EOSQL
done

echo "==> Creating databases (outside of DO/transaction) ..."
for db in "${DBS[@]}"; do
  user="$db"

  # Existiert die DB bereits?
  if psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -tc \
      "SELECT 1 FROM pg_database WHERE datname='${db}';" | grep -q 1; then
    echo "DB '${db}' already exists. Ensuring owner is '${user}' ..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c \
      "ALTER DATABASE \"${db}\" OWNER TO \"${user}\";"
  else
    echo "Creating DB '${db}' owned by '${user}' ..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c \
      "CREATE DATABASE \"${db}\" OWNER \"${user}\";"
  fi

  # PUBLIC-Privilegien minimieren
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c \
    "REVOKE ALL ON DATABASE \"${db}\" FROM PUBLIC;"
done

echo "==> All databases and owners ensured."
