import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as iam from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';
import * as nodeGroup from './docker-swarm-node-group';

export class AwsDockerSwarmStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const ssmPrefix = `/x9d72b8537afa/docker-swarm/${id}/join`;
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

    const seedManager = new nodeGroup.DockerSwarmNodeGroup(this, 'seed-manager', {
      vpc: vpc,
      sg: sg,
      desiredCapacity: 1,
      initCommands: [
        '#!/bin/bash',
        'set -e',
        '/usr/bin/docker swarm init',
        '/usr/bin/docker swarm join-token manager',
        '/usr/bin/docker swarm join-token worker',
      ],
      role: role,
      ssmPrefix: ssmPrefix,
    });

    const otherManagers = new nodeGroup.DockerSwarmNodeGroup(this, 'other-managers', {
      vpc: vpc,
      sg: sg,
      desiredCapacity: 2,
      initCommands: [
        '#!/bin/bash',
        'set -e',
        'docker swarm join --token SWMTKN-1-31i5rxvsy14it3j48lxayhvnmb66gn4rswok33roypuqw0wl3q-8jkagkewwrj8i239m6qpyyq85 172.31.48.138:2377',
      ],
      role: role,
      ssmPrefix: ssmPrefix,
    });

    const workers = new nodeGroup.DockerSwarmNodeGroup(this, 'workers', {
      vpc: vpc,
      sg: sg,
      desiredCapacity: 5,
      initCommands: [
        '#!/bin/bash',
        'set -e',
        'docker swarm join --token SWMTKN-1-31i5rxvsy14it3j48lxayhvnmb66gn4rswok33roypuqw0wl3q-bo7rdjkmlucpebwte9o85gh32 172.31.48.138:2377',
      ],
      role: role,
      ssmPrefix: ssmPrefix,
    });
  }
}
