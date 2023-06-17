import * as os from 'os';
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as ssm from 'aws-cdk-lib/aws-ssm';
import * as autoscaling from 'aws-cdk-lib/aws-autoscaling';
import { Construct } from 'constructs';

export interface DockerSwarmNodeGroupProps {
  vpc: ec2.IVpc;
  sg: ec2.ISecurityGroup;
  instanceType: ec2.InstanceType;
  desiredCapacity: number;
  initCommands: string[];
  role: iam.IRole;
  ssmPrefix: string;
}

export class DockerSwarmNodeGroup extends Construct {
  swarmAsg: autoscaling.AutoScalingGroup;

  constructor(scope: Construct, id: string, props: DockerSwarmNodeGroupProps) {
    super(scope, id);

    const linuxUser = 'ec2-user';
    const linuxImage = ec2.MachineImage.latestAmazonLinux2();
    const region = 'us-east-1';
    const vpc = props.vpc;
    const sg = props.sg;

    const init = ec2.CloudFormationInit.fromConfigSets({
      configSets: {
        default: [
          'packages',
          'setup_docker',
          'deploy_ssh_key',
        ],
      },
      configs: {
        packages: new ec2.InitConfig([
          ec2.InitPackage.yum('docker'),
          ec2.InitPackage.yum('ec2-instance-connect'),
        ]),
        setup_docker: new ec2.InitConfig([
          ec2.InitCommand.shellCommand(`/usr/sbin/usermod -G docker -a ${linuxUser}`),
          ec2.InitCommand.shellCommand('/usr/bin/systemctl enable docker.service'),
          ec2.InitCommand.shellCommand('/usr/bin/systemctl start docker.service'),
          ec2.InitCommand.shellCommand('/usr/bin/docker version'),
          ec2.InitFile.fromFileInline('/opt/bin/publish-join-tokens.sh', './lib/publish-join-tokens.sh', {
            mode: '0755',
          }),
          ec2.InitFile.fromFileInline('/opt/bin/join-docker-swarm.sh', './lib/join-docker-swarm.sh', {
            mode: '0755',
          }),
          ec2.InitFile.fromString('/tmp/setup.sh', props.initCommands.join('\n'), {
            mode: '0755',
          }),
          ec2.InitCommand.shellCommand('/tmp/setup.sh'),
        ]),
        deploy_ssh_key: new ec2.InitConfig([
          ec2.InitCommand.shellCommand(`/bin/sudo -u ${linuxUser} -- /bin/mkdir --parents --mode=0700 ~${linuxUser}/.ssh`),
          ec2.InitFile.fromFileInline(`/home/${linuxUser}/.ssh/authorized_keys`, os.homedir() + '/.ssh/id_ed25519.pub', {
            mode: '0700',
            owner: linuxUser,
            group: linuxUser,
          }),
        ]),
      },
    });

    const asg = new autoscaling.AutoScalingGroup(scope, `${id}-asg`, {
      vpc,
      //instanceType: ec2.InstanceType.of(ec2.InstanceClass.BURSTABLE2, ec2.InstanceSize.MICRO),
      instanceType: props.instanceType,
      machineImage: linuxImage,
      desiredCapacity: props.desiredCapacity,
      minCapacity: props.desiredCapacity,
      maxCapacity: props.desiredCapacity,
      securityGroup: sg,
      associatePublicIpAddress: true,
      vpcSubnets: {
        subnetType: ec2.SubnetType.PUBLIC,
      },
      init: init,
      signals: autoscaling.Signals.waitForAll({
        timeout: cdk.Duration.minutes(30),
      }),
      role: props.role,
      cooldown: cdk.Duration.seconds(15),
    });

    this.swarmAsg = asg;
  }
}
