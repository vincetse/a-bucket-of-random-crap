#!/bin/bash
set -exo pipefail

# doctl compute region list
REGION=nyc1
# doctl compute size list
#SIZE=s-2vcpu-4gb
SIZE=s-4vcpu-8gb
# doctl kubernetes options versions
K8S_VERSION=1.15.9-do.2

function create()
{
  local name=$1
  local size="s-2vcpu-4gb"
  local count=1
  local max_nodes=3
  #local size="s-4vcpu-8gb"
  local node_pool="name=default-pool;size=${size};count=${count};auto-scale=true;min-nodes=${count};max-nodes=${max_nodes}"
  doctl kubernetes cluster create \
    ${name} \
    --version "${K8S_VERSION}" \
    --set-current-context \
    --update-kubeconfig \
    --wait \
    --auto-upgrade \
    --maintenance-window "any=06:00" \
    --region ${REGION} \
    --node-pool "${node_pool}"
}

function delete()
{
  local name=$1
  doctl kubernetes cluster delete \
    ${name} \
    --force
}

function status()
{
  local name=$1
  doctl kubernetes cluster list
}

CLUSTER_NAME=k-1
for cmd in $*; do
  ${cmd} ${CLUSTER_NAME}
done
status
