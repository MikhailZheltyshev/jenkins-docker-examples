#!/bin/sh

#make sure you have the AWS CLI installed and configured
#http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

#update as needed
export AWS_DEFAULT_REGION=eu-north-1

KeyName='my_key'
StackName='jenkins-ecs-stack'
VPCIPRange='10.0.0.0/16'
AllowedIPRange='0.0.0.0/0'
DockerImage='mihalichzh/my_jenkins'
InstanceType='t3.micro'

echo "Looking for key '$KeyName'..."
aws ec2 describe-key-pairs --key-name $KeyName
if [ $? -ne 0 ]; then
        echo "Key $KeyName not found, creating it."
        aws ec2 create-key-pair --key-name $KeyName --query 'KeyMaterial' --output text > ${KeyName}.pem
        chmod 400 ${KeyName}.pem
else
        echo "Key $KeyName found, it will be used to configure ECS instances."
fi

echo "Running cloudformation to create the stack '$StackName'..."
aws cloudformation create-stack --stack-name $StackName \
 --template-body file://cloudformation/jenkins-ecs-stack.json \
 --parameters ParameterKey=KeyName,ParameterValue=$KeyName \
ParameterKey=VPCIPRange,ParameterValue=$VPCIPRange \
ParameterKey=AllowedIPRange,ParameterValue=$AllowedIPRange \
ParameterKey=DockerImage,ParameterValue=$DockerImage \
ParameterKey=InstanceType,ParameterValue=$InstanceType \
--capabilities CAPABILITY_NAMED_IAM
