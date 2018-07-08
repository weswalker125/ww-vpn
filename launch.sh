#!/bin/bash

BUCKET_NAME=silly.apps.storage
KEYPAIR_NAME=ww-vpn

# aws s3 sync . s3://${BUCKET_NAME}/ww-vpn/ --exclude "*" --include "openvpn-*.conf" --include "install.sh"

aws cloudformation create-stack --stack-name ww-vpn-stack-$(date +%Y%m%d-%H%M) \
	--template-body file://./full-stack.yml \
	--capabilities CAPABILITY_IAM \
	--parameters \
		ParameterKey=ConfigBucket,ParameterValue=${BUCKET_NAME} \
		ParameterKey=KeyName,ParameterValue=${KEYPAIR_NAME}
