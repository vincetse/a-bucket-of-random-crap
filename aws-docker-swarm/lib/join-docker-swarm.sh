#!/bin/bash
set -e

# AWS region
REGION=$1
SSM_PREFIX=$2
# manager or worker
ROLE=$3

# join tokens
# aws --region us-east-1 ssm  put-parameter --value 'docker swarm join --token SWMTKN-1-4tbx2x094w64i1d68xn4ncrpveogaqy1l2h3v7abb5jmucv6la-9w9z313a5biv7wzm22ogllamc 172.31.73.61:2377' --name '/x9d72b8537afa/docker-swarm/AwsDockerSwarmStack/join/manager' --type String
# aws --region us-east-1 ssm  put-parameter --value 'docker swarm join --token SWMTKN-1-4tbx2x094w64i1d68xn4ncrpveogaqy1l2h3v7abb5jmucv6la-d5nqt1mgpacdsvg9gwtn55zr4 172.31.73.61:2377' --name '/x9d72b8537afa/docker-swarm/AwsDockerSwarmStack/join/worker' --type String

# eval $(aws --region us-east-1 ssm get-parameter --name '/x9d72b8537afa/docker-swarm/AwsDockerSwarmStack/join/worker' --query 'Parameter.Value'  --output text)

function get_join_token_and_join()
{
  local region=$1
  local ssmPrefix=$2
  local role=$3

  while :; do
    local cmd=$(aws --region ${region} ssm get-parameter --name "${ssmPrefix}/${role}" --query 'Parameter.Value' --output text)
    if [[ "${cmd}" == "temp-value" ]]; then
      sleep 10
    else
      eval ${cmd}
      break
    fi
  done
}

get_join_token_and_join ${REGION} ${SSM_PREFIX} ${ROLE}
