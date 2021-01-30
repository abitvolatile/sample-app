# Walkthough: Configuring Vault Database Secret Engine for PostgreSQL


### Walkthough Notes:
The `user` database must exist before the account credentials can be created, which means the website must be loaded for the database to initialize.

<br>


## Configure Vault Database Secret Engine (Exec into the Postgres `vault-0` Pod's Shell)
```
# Set Vault Auth Token Variable
export VAULT_TOKEN='<VAULT_TOKEN_HERE>'

# Enables the Vault Database Secret Engine
vault secrets enable -path=postgres database

# Configures Vault for PostgreSQL Database Connection
vault write postgres/config/postgres-db \
  plugin_name=postgresql-database-plugin \
  allowed_roles='*' \
  connection_url="postgresql://{{username}}:{{password}}@db.sample-app.svc.cluster.local:5432/user?sslmode=disable" \
  username="user" \
  password="R3alLySt0nGPaS5w0rD"

# Creates Vault Role for `readonly` Temporary Access
vault write postgres/roles/temp-read-psql-access \
    db_name=postgres-db \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

# Creates Vault Role for `admin` Temporary Access
vault write postgres/roles/temp-admin-psql-access \
    db_name=postgres-db \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
```

<br>

## Create Vault Policy (Vault Web UI)
```
# Common Vault Policy Permissions
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
path "auth/token/create" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "sys/internal/ui/mounts/*" {
  capabilities = ["read"]
}
path "sys/mounts" {
  capabilities = ["read"]
}


# Vault Policy for Generating PostgreSQL Credentials via the Database Secret Engine
path "postgres/creds/*" {
  capabilities = ["read", "list"]
}
```

<br>

## Provision Temporary Credentials for Respective Role (Execute from Vault Web UI Command Console)
```
vault read postgres/creds/temp-read-psql-access
vault read postgres/creds/temp-admin-psql-access
```

<br>

## PostreSQL Query to Display User Permissions (Exec into the Postgres `db` Pod's Shell)
```
su - postgres
echo $POSTGRES_PASSWORD
psql -h localhost -p 5432 -d user -U user -W

SELECT grantee, string_agg(privilege_type, ', ') AS privileges
FROM information_schema.role_table_grants 
WHERE table_name='advertisement'   
GROUP BY grantee;
```
