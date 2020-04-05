# AWS WorkSpaces Directory Service Configuration

Create an AWS Simple AD directory, and get it registered with AWS WorkSpaces.  This is done automatically for you by AWS if you set up AWS WorkSpaces for the first time, so this is really just a mental exercise that is probably useless for most.

## Usage

```
make init
make create
```

## TODOs

1. [Add users to Simple AD](https://devopslife.io/managing-aws-simplead-from-linux/)
1. Create workspaces with the AWS CLI (since Terraform doesn't support it).
