#!/bin/bash
set -exo pipefail

CLUSTER_NAME=k-1
# gcloud compute regions list
REGION=us-central1
ZONE=${REGION}-a
# gcloud compute machine-types list --filter=zone:${ZONE}
MACHINE_TYPE=e2-standard-2
# gcloud container get-server-config --zone ${ZONE}
K8S_VERSION=1.15.11-gke.5
#K8S_CHANNEL=
ENABLE_METERING=false
RESOURCE_MEETING_TABLE=$(echo "gke_${CLUSTER_NAME}_metering" | tr "-" "_")

function create()
{
  local name=$1
  local machine_type="${MACHINE_TYPE}"
  local count=1
  local max_nodes=3
  local maintenance_window="06:00"
  local metering_params="--enable-network-egress-metering --enable-resource-consumption-metering --resource-usage-bigquery-dataset ${RESOURCE_MEETING_TABLE}"
  if [[ "${ENABLE_METERING}" -eq "true" ]]; then
    bq mk \
      --dataset \
      --description "GKE ${name} cluster metering" \
      "${RESOURCE_MEETING_TABLE}"
  fi
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
    ${metering_params} \
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
    --quiet || true
  if [[ "${ENABLE_METERING}" -eq "true" ]]; then
    bq rm \
      --recursive \
      --force \
      "${RESOURCE_MEETING_TABLE}" || true
  fi
}

function status()
{
  gcloud beta container clusters list \
    --zone "${ZONE}"
}

for cmd in $*; do
  ${cmd} "${CLUSTER_NAME}"
done
status
