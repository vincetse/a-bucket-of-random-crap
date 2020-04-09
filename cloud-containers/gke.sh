#!/bin/bash
set -exo pipefail

# gcloud compute regions list
#REGION=us-central1
ZONE=${REGION}-a
# gcloud compute machine-types list --filter=zone:${ZONE}
MACHINE_TYPE=e2-standard-2
# gcloud container get-server-config --zone ${ZONE}
K8S_VERSION=1.15.11-gke.5
#K8S_CHANNEL=

function create()
{
  local name=$1
  local machine_type="${MACHINE_TYPE}"
  local count=1
  local max_nodes=3
  local maintenance_window="06:00"
  gcloud beta container clusters create \
    ${name} \
    --machine-type "${machine_type}" \
    --cluster-version "${K8S_VERSION}" \
    --node-version "${K8S_VERSION}" \
    --enable-autoupgrade \
    --preemptible \
    --num-nodes "${count}" \
    --enable-autoscaling --max-nodes "${max_nodes}" --min-nodes "${count}" \
    --maintenance-window "${maintenance_window}" \
    --enable-ip-alias \
    --zone "${ZONE}"
  gcloud beta container clusters get-credentials \
    ${name} \
    --zone "${ZONE}"
}

function delete()
{
  local name=$1
  gcloud beta container clusters delete \
    ${name} \
    --zone "${ZONE}" \
    --quiet
}

function status()
{
  local name=$1
  gcloud beta container clusters list \
    ${name} \
    --zone "${ZONE}"
}

CLUSTER_NAME=k-1
for cmd in $*; do
  ${cmd} ${CLUSTER_NAME}
done
status
