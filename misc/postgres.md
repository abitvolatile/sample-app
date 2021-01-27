# Enables the Database Secrets Engine
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN='<VAULT_TOKEN_HERE>'

vault secrets enable -path=postgres database


# Configures Vault for PostgreSQL Database Connection
vault write postgres/config/postgres-db \
  plugin_name=postgresql-database-plugin \
  allowed_roles='*' \
  connection_url="postgresql://{{username}}:{{password}}@db.sample-app.svc.cluster.local:5432/user?sslmode=disable" \
  username="user" \
  password="R3alLySt0nGPaS5w0rD"


# Creates Vault Role for `READONLY` Temporary Access
vault write postgres/roles/temp-read-access \
    db_name=postgres-db \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"


# Creates Vault Role for `Admin` Temporary Access
vault write postgres/roles/temp-admin-access \
    db_name=postgres-db \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"


# Provisions the Temporary Access for the Respective Role
vault read postgres/creds/temp-read-access -format=json
vault read postgres/creds/temp-admin-access -format=json


# PostreSQL Query to Display Users/Permissions (Verification)
psql -h localhost -p 5432 -d user -U user -W

SELECT grantee, string_agg(privilege_type, ', ') AS privileges
FROM information_schema.role_table_grants 
WHERE table_name='advertisement'   
GROUP BY grantee;
