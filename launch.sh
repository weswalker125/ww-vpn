#!/bin/bash

aws cloudformation create-stack --stack-name ww-vpn-stack-1 --template-body file:///home/wes/working/ww-vpn/full-stack.yml --capabilities CAPABILITY_IAM