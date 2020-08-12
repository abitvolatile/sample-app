#!/bin/bash

NAMESPACE=${1:-vault}
VAULT_INIT=$(cat .vault_secrets | jq -r '.')

function vault_unseal() {
  kubectl -n $NAMESPACE exec -i $1 -c vault -- sh <<EOM
    export VAULT_ADDR="http://127.0.0.1:8200"
    export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
    vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[0]')
    vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[1]')
    vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[2]')
EOM
}


function vault_join() {
  kubectl -n $NAMESPACE exec -i $1 -c vault -- sh <<EOM
    export VAULT_ADDR="http://127.0.0.1:8200"
    export VAULT_TOKEN=$(echo $VAULT_INIT | jq -r '.root_token')
    vault operator raft join $2
    vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[0]')
    vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[1]')
    vault operator unseal $(echo $VAULT_INIT | jq -r '.unseal_keys_b64[2]')
    sleep 2
    vault operator raft list-peers
EOM
}
