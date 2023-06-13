import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as ssm from 'aws-cdk-lib/aws-ssm';
import { Construct } from 'constructs';
import * as nodeGroup from './docker-swarm-node-group';

export class AwsDockerSwarmStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const region = 'us-east-1';
    const ssmPrefix = `/x9d72b8537afa/docker-swarm/${id}/join`;

    // create parameters that will be overwritten later
    const joinTokenManagerSsm = new ssm.StringParameter(this, 'joinManager', {
      parameterName: `${ssmPrefix}/manager`,
      stringValue: 'temp-value',
    });

    const joinTokenWorkerSsm = new ssm.StringParameter(this, 'joinWorker', {
      parameterName: `${ssmPrefix}/worker`,
      stringValue: 'temp-value',
    });

    const role = new iam.Role(this, 'instance-role', {
      assumedBy: new iam.ServicePrincipal('ec2.amazonaws.com'),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonSSMFullAccess'),
      ],
    });

    const myIpCidr = '24.17.16.148/32';
    const vpc = ec2.Vpc.fromLookup(this, 'VPC', {
      // This imports the default VPC but you can also
      // specify a 'vpcName' or 'tags'.
      isDefault: true,
    });

    const sg = new ec2.SecurityGroup(this, `sg`, {
      vpc: vpc,
      allowAllOutbound: true,
      description: 'Docker Swarm sg',
    });
    sg.addIngressRule(ec2.Peer.ipv4(myIpCidr), ec2.Port.tcp(22), 'SSH from home');
    sg.addIngressRule(sg, ec2.Port.tcp(2376), 'Docker Swarm', true);
    sg.addIngressRule(sg, ec2.Port.tcp(2377), 'Docker Swarm', true);
    sg.addIngressRule(sg, ec2.Port.tcp(7946), 'Docker Swarm', true);
    sg.addIngressRule(sg, ec2.Port.udp(7946), 'Docker Swarm', true);
    sg.addIngressRule(sg, ec2.Port.udp(4789), 'Docker Swarm', true);

    // join tokens
    // aws --region us-east-1 ssm  put-parameter --value 'docker swarm join --token SWMTKN-1-4tbx2x094w64i1d68xn4ncrpveogaqy1l2h3v7abb5jmucv6la-9w9z313a5biv7wzm22ogllamc 172.31.73.61:2377' --name '/x9d72b8537afa/docker-swarm/AwsDockerSwarmStack/join/manager' --type String
    // aws --region us-east-1 ssm  put-parameter --value 'docker swarm join --token SWMTKN-1-4tbx2x094w64i1d68xn4ncrpveogaqy1l2h3v7abb5jmucv6la-d5nqt1mgpacdsvg9gwtn55zr4 172.31.73.61:2377' --name '/x9d72b8537afa/docker-swarm/AwsDockerSwarmStack/join/worker' --type String

    // eval $(aws --region us-east-1 ssm get-parameter --name '/x9d72b8537afa/docker-swarm/AwsDockerSwarmStack/join/worker' --query 'Parameter.Value'  --output text)
    const seedManager = new nodeGroup.DockerSwarmNodeGroup(this, 'seed-manager', {
      vpc: vpc,
      sg: sg,
      desiredCapacity: 1,
      initCommands: [
        '#!/bin/bash',
        'set -e',
        '/usr/bin/docker swarm init',
        `/opt/bin/publish-join-tokens.sh ${region} ${ssmPrefix}`,
/*
        '/usr/bin/docker swarm init',
        '/bin/echo ####### MANAGER #######',
        '/usr/bin/docker swarm join-token manager',
        '/bin/echo ####### WORKER #######',
        '/usr/bin/docker swarm join-token worker',
*/
      ],
      role: role,
      ssmPrefix: ssmPrefix,
    });
    seedManager.node.addDependency(joinTokenManagerSsm);
    seedManager.node.addDependency(joinTokenWorkerSsm);

    const otherManagers = new nodeGroup.DockerSwarmNodeGroup(this, 'other-managers', {
      vpc: vpc,
      sg: sg,
      desiredCapacity: 2,
      initCommands: [
        '#!/bin/bash',
        'set -e',
        `/opt/bin/join-docker-swarm.sh ${region} ${ssmPrefix} manager`,
      ],
      role: role,
      ssmPrefix: ssmPrefix,
    });
    otherManagers.node.addDependency(seedManager);

    const workers = new nodeGroup.DockerSwarmNodeGroup(this, 'workers', {
      vpc: vpc,
      sg: sg,
      desiredCapacity: 5,
      initCommands: [
        '#!/bin/bash',
        'set -e',
        `/opt/bin/join-docker-swarm.sh ${region} ${ssmPrefix} worker`,
      ],
      role: role,
      ssmPrefix: ssmPrefix,
    });
    workers.node.addDependency(seedManager);
  }
}
