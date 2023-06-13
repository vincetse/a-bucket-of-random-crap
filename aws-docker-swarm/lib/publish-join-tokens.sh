#!/bin/bash
set -e

REGION=$1
SSM_PREFIX=$2

# join tokens
# aws --region us-east-1 ssm  put-parameter --value 'docker swarm join --token SWMTKN-1-4tbx2x094w64i1d68xn4ncrpveogaqy1l2h3v7abb5jmucv6la-9w9z313a5biv7wzm22ogllamc 172.31.73.61:2377' --name '/x9d72b8537afa/docker-swarm/AwsDockerSwarmStack/join/manager' --type String
# aws --region us-east-1 ssm  put-parameter --value 'docker swarm join --token SWMTKN-1-4tbx2x094w64i1d68xn4ncrpveogaqy1l2h3v7abb5jmucv6la-d5nqt1mgpacdsvg9gwtn55zr4 172.31.73.61:2377' --name '/x9d72b8537afa/docker-swarm/AwsDockerSwarmStack/join/worker' --type String

# eval $(aws --region us-east-1 ssm get-parameter --name '/x9d72b8537afa/docker-swarm/AwsDockerSwarmStack/join/worker' --query 'Parameter.Value'  --output text)

function store_join_token()
{
  local region=$1
  local ssmPrefix=$2
  local role=$3
  local value=$(docker swarm join-token ${role} | grep docker)

  aws --region ${region} ssm put-parameter \
    --name "${ssmPrefix}/${role}" --type String \
    --value "${value}" \
    --overwrite
}

set -x
store_join_token ${REGION} ${SSM_PREFIX} manager
store_join_token ${REGION} ${SSM_PREFIX} worker
