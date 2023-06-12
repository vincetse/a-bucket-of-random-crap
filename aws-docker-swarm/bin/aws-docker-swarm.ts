#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { AwsDockerSwarmStack } from '../lib/aws-docker-swarm-stack';

const env = {
  account: process.env.CDK_DEPLOY_ACCOUNT || process.env.CDK_DEFAULT_ACCOUNT,
  region: process.env.CDK_DEPLOY_REGION || process.env.CDK_DEFAULT_REGION,
}
const appname = process.env.APP_NAME || 'AwsDockerSwarmStack';

const app = new cdk.App();
new AwsDockerSwarmStack(app, appname, {
  env: env,
  description: 'Docker Swarm',
});
