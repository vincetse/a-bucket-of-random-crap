import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as ssm from 'aws-cdk-lib/aws-ssm';
import { Construct } from 'constructs';
import * as nodeGroup from './docker-swarm-node-group';

export class AwsDockerSwarmStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const region = cdk.Stack.of(this).region;
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

    const myIpCidrs: string[] = [
      '24.17.16.148/32',
    ];
    const myPrefixLists = [
      'pl-60b85b09',
    ];
    const vpc = ec2.Vpc.fromLookup(this, 'VPC', {
      isDefault: true,
    });

    const sg = new ec2.SecurityGroup(this, `sg`, {
      vpc: vpc,
      allowAllOutbound: true,
      description: 'Docker Swarm sg',
    });
    sg.addIngressRule(sg, ec2.Port.tcp(2376), 'Docker Swarm', true);
    sg.addIngressRule(sg, ec2.Port.tcp(2377), 'Docker Swarm', true);
    sg.addIngressRule(sg, ec2.Port.tcp(7946), 'Docker Swarm', true);
    sg.addIngressRule(sg, ec2.Port.udp(7946), 'Docker Swarm', true);
    sg.addIngressRule(sg, ec2.Port.udp(4789), 'Docker Swarm', true);
    myIpCidrs.forEach(function(myIpCidr) {
      sg.addIngressRule(ec2.Peer.ipv4(myIpCidr), ec2.Port.tcp(22), 'me');
      sg.addIngressRule(ec2.Peer.ipv4(myIpCidr), ec2.Port.tcp(80), 'me');
      sg.addIngressRule(ec2.Peer.ipv4(myIpCidr), ec2.Port.tcp(443), 'me');
    });
    myPrefixLists.forEach(function(myPrefixList) {
      sg.addIngressRule(ec2.Peer.prefixList(myPrefixList), ec2.Port.tcp(22), 'corp', true);
      sg.addIngressRule(ec2.Peer.prefixList(myPrefixList), ec2.Port.tcp(80), 'corp', true);
      sg.addIngressRule(ec2.Peer.prefixList(myPrefixList), ec2.Port.tcp(443), 'corp', true);
    });

    const seedManager = new nodeGroup.DockerSwarmNodeGroup(this, 'seed-manager', {
      vpc: vpc,
      sg: sg,
      desiredCapacity: 1,
      initCommands: [
        '#!/bin/bash',
        'set -e',
        '/usr/bin/docker swarm init',
        `/opt/bin/publish-join-tokens.sh ${region} ${ssmPrefix}`,
      ],
      role: role,
      ssmPrefix: ssmPrefix,
    });
    seedManager.node.addDependency(joinTokenManagerSsm);
    seedManager.node.addDependency(joinTokenWorkerSsm);
    cdk.Tags.of(seedManager.swarmAsg).add('docker-swarm/role', 'manager');

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
    otherManagers.swarmAsg.node.addDependency(seedManager.swarmAsg);
    cdk.Tags.of(otherManagers.swarmAsg).add('docker-swarm/role', 'manager');

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
    workers.swarmAsg.node.addDependency(seedManager.swarmAsg);
    cdk.Tags.of(workers.swarmAsg).add('docker-swarm/role', 'worker');
  }
}
