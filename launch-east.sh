#!/bin/bash

BUCKET_NAME=silly.apps.storage
REGION=us-east-1
KEYPAIR_NAME=ww-vpn
AMI_ID=ami-55ef662f

# TODO Check if KeyPair exists
# if [ CONDITION? ]; then
# 	aws ec2 create-key-pair --key-name $KEYPAIR_NAME
# fi

# TODO Check if bucket exists

# Sync configuration files from repository.
aws s3 sync . s3://${BUCKET_NAME}/ww-vpn/ --exclude "*" --include "openvpn-*.conf"

aws cloudformation --region $REGION \
	create-stack --stack-name ww-vpn-stack-test \
	--template-body file:///home/wes/working/ww-vpn/full-stack.yml \
	--capabilities CAPABILITY_IAM \
	--parameters \
		ParameterKey=AmiId,ParameterValue=${AMI_ID} \
		ParameterKey=ConfigBucket,ParameterValue=${BUCKET_NAME} \
		ParameterKey=KeyName,ParameterValue=${KEYPAIR_NAME}
