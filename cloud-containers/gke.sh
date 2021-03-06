#!/bin/bash
set -exo pipefail

CLUSTER_NAME=k-1
# gcloud compute regions list
REGION=us-central1
ZONE=${REGION}-a
# gcloud compute machine-types list --filter=zone:${ZONE}
MACHINE_TYPE=e2-standard-2
# gcloud container get-server-config --zone ${ZONE}
K8S_CHANNEL=regular
ENABLE_METERING=false
RESOURCE_MEETING_TABLE=$(echo "gke_${CLUSTER_NAME}_metering" | tr "-" "_")

function create_metering_table()
{
  if [[ "${ENABLE_METERING}" == "true" ]]; then
    bq mk \
      --dataset \
      --description "GKE ${name} cluster metering" \
      "${RESOURCE_MEETING_TABLE}"
  fi
}

function delete_metering_table()
{
  if [[ "${ENABLE_METERING}" == "true" ]]; then
    bq rm \
      --recursive \
      --force \
      "${RESOURCE_MEETING_TABLE}" || true
  fi
}

function create()
{
  local name=$1
  local machine_type="${MACHINE_TYPE}"
  local count=1
  local max_nodes=5
  local maintenance_window="06:00"
  local metering_params=""
  if [[ "${ENABLE_METERING}" == "true" ]]; then
    metering_params="--enable-network-egress-metering --enable-resource-consumption-metering --resource-usage-bigquery-dataset ${RESOURCE_MEETING_TABLE}"
  fi
  create_metering_table
  gcloud beta container clusters create \
    ${name} \
    --machine-type "${machine_type}" \
    --release-channel="${K8S_CHANNEL}" \
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
  delete_metering_table
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
