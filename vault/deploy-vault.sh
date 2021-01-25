#!/bin/bash

HELM_CHART_VERSION='0.6.0'
NAMESPACE='vault'


# Download Helm (If its Not Already Installed)
if ! command -v helm &> /dev/null
then
  echo "Helm could not be found..."
  export HELM_INSTALL_DIR='/usr/bin' 
  curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -s -- --version v3.2.4
  unset HELM_INSTALL_DIR
fi



######### Deploy HashiCorp Vault #########


# Add/Configure HashiCorp Helm Repository
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update


echo
echo "Creating Namespace..."
kubectl create ns $NAMESPACE

echo
echo "Deploying Helm Chart..."
helm -n $NAMESPACE install vault hashicorp/vault --version $HELM_CHART_VERSION -f values.yaml --wait

echo
echo "Creating Service Account and ClusterRoleBinding Resources..."
kubectl -n $NAMESPACE create serviceaccount vault-auth
kubectl -n $NAMESPACE create clusterrolebinding role-tokenreview-binding --clusterrole=system:auth-delegator --serviceaccount=vault:vault-auth

# Give it time to spin up pods
sleep 60



echo
echo "Initializing Vault Storage..."
VAULT_INIT=$(kubectl -n $NAMESPACE exec -i vault-0 -c vault -- sh <<EOM
  vault operator init -format=json
EOM
)

# Pause
sleep 5


echo
echo "Vault Token and Unseal Keys..."
# Create Vault Secrets File if it Doesn't Exist
if [ ! -f ./.vault_secrets ]
then
  echo "$VAULT_INIT" | jq '.' > ./.vault_secrets
fi

# Set Variable from Contents of Vault Secrets File
VAULT_INIT=$(cat ./.vault_secrets | jq '.')

# Print Vault Secrets Variable
echo "$VAULT_INIT" | jq '.'



# Load Vault Script Functions
source vault-functions.sh vault # Specified the Namespace



echo "Unsealing Vault's Primary Node..."
vault_unseal vault-0 # Specified the Pod Name

# Pause
sleep 10


echo "Unsealing Vault's Secondary Node..."
vault_join vault-1 http://vault-active.vault.svc.cluster.local:8200  
# Specified the Pod Name and Service Endpoint for Join

# Pause
sleep 3


echo
echo "Unsealing Vault's Tertiary Node..."
vault_join vault-2 http://vault-active.vault.svc.cluster.local:8200
# Specified the Pod Name and Service Endpoint for Join

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
echo "Creating Example Database Credentials in KV-v2 for Sample-App..."
kubectl -n $NAMESPACE exec -i vault-0 -c vault -- sh <<EOM
  export VAULT_ADDR="http://127.0.0.1:8200"
  export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
  vault kv put kv/sample-app/db/creds password="R3alLySt0nGPaS5w0rD"
EOM


echo
echo "Finished...!"