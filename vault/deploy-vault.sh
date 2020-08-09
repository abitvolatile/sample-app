#!/bin/bash

HELM_CHART_VERSION='0.6.0'
NAMESPACE='vault'


######### Deploy HashiCorp Vault #########

echo
echo "Creating Namespace..."
kubectl create ns vault

echo
echo "Deploying Helm Chart..."
helm -n $NAMESPACE install vault hashicorp/vault --version $HELM_CHART_VERSION -f values.yaml --wait

echo
echo "Creating Service Account and ClusterRoleBinding Resources..."
kubectl -n $NAMESPACE apply -f ./k8s-manifest/

# Give it time to spin up pods
sleep 10



echo
echo "Initializing Vault Storage..."
VAULT_INIT=$(kubectl -n $NAMESPACE exec -i vault-0 -c vault -- sh <<EOM
  vault operator init -format=json
EOM)

# Prints the Vault Root Token and Unseal Keys to File
echo "Vault Token and Unseal Keys..."
echo "$VAULT_INIT" | jq '.'
echo "$VAULT_INIT" | jq '.' > ./.vault_secrets

# Pause
sleep 5



echo "Unsealing Vault's Primary Node..."
kubectl -n $NAMESPACE exec -i vault-0 -c vault -- sh <<EOM
  export VAULT_ADDR="http://127.0.0.1:8200"
  export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
  vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[0]')
  vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[1]')
  vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[2]')
EOM

# Pause
sleep 10


echo
echo "Unsealing Vault's Secondary Node..."
kubectl -n $NAMESPACE exec -i vault-1 -c vault -- sh <<EOM
  export VAULT_ADDR="http://127.0.0.1:8200"
  export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
  vault operator raft join "http://vault-active.vault.svc.cluster.local:8200"
  vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[0]')
  vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[1]')
  vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[2]')
  sleep 2
  vault operator raft list-peers
EOM

# Pause
sleep 3


echo
echo "Unsealing Vault's Tertiary Node..."
kubectl -n $NAMESPACE exec -i vault-2 -c vault -- sh <<EOM
  export VAULT_ADDR="http://127.0.0.1:8200"
  export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
  vault operator raft join "http://vault-active.vault.svc.cluster.local:8200"
  vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[0]')
  vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[1]')
  vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[2]')
  sleep 2
  vault operator raft list-peers
EOM

# Pause
sleep 3


echo
echo "Creating Vault Policy..."
kubectl -n $NAMESPACE exec -i vault-0 -c vault -- sh <<EOM
  export VAULT_ADDR="http://127.0.0.1:8200"
  export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
  
  vault policy write sample-app_db - <<'EOP'
  path "auth/token/lookup-self" {
  capabilities = ["read"]
  }
  path "auth/token/create" {
    capabilities = ["create", "read", "update", "delete", "list"]
  }

  ###

  path "sys/internal/ui/mounts/*" {
    capabilities = ["read"]
  }
  path "sys/mounts" {
    capabilities = ["read"]
  }

  ### Global READ access on KV-v2 (Key/Value) Secret Engine

  path "kv/metadata/*" {
    capabilities = ["read", "list"]
  }
  path "kv/data/*" {
    capabilities = ["read", "list"]
  }

  ###

  path "kv/metadata/sample-app/db/*" {
    capabilities = ["create", "update", "delete", "read", "list"]
  }
  path "kv/data/sample-app/db/*" {
    capabilities = ["create", "update", "delete", "read", "list"]
  }
EOP
EOM


echo
echo "Enabling KV-v2 Secret Engine..."
kubectl -n $NAMESPACE exec -i vault-0 -c vault -- sh <<EOM
   export VAULT_ADDR="http://127.0.0.1:8200"
   export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
   vault secrets enable -path=kv kv-v2
   vault kv put kv/sample-app/db/creds password="password"
EOM

echo
echo "Enabling Kubernetes Auth Method..."
kubectl -n $NAMESPACE exec -i vault-0 -c vault -- sh <<EOM
   export VAULT_ADDR="http://127.0.0.1:8200"
   export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
   vault auth enable -path=kubernetes kubernetes
EOM


# Get Hostname, CA Cert, Service Account's Secret Name, and Bearer Token
k8s_host="$(kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " ")"
k8s_cacert="$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 --decode)"
secret_name="$(kubectl get serviceaccount vault-auth -n $NAMESPACE -o go-template='{{ (index .secrets 0).name }}')"
tr_account_token="$(kubectl get secret ${secret_name} -n $NAMESPACE -o go-template='{{ .data.token }}' | base64 --decode)"


echo
echo "Configuring the Kubernetes Auth Method..."
kubectl -n $NAMESPACE exec -i vault-0 -c vault -- sh <<EOM
   export VAULT_ADDR="http://127.0.0.1:8200"
   export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
   vault write auth/kubernetes/config token_reviewer_jwt="${tr_account_token}" kubernetes_host="${k8s_host}" kubernetes_ca_cert="${k8s_cacert}"
EOM


echo
echo "Binding Auth-Role to Vault Policy..."
kubectl -n $NAMESPACE exec -i vault-0 -c vault -- sh <<EOM
   export VAULT_ADDR="http://127.0.0.1:8200"
   export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
   vault write auth/kubernetes/role/sample-app_db \
    bound_service_account_names="*" \
    bound_service_account_namespaces=default \
    policies=sample-app_db \
    ttl=24h
EOM


echo
echo "Finished...!"