#!/bin/bash

aws cloudformation create-stack --stack-name ww-vpn-stack-5 --template-body file:///home/wes/working/ww-vpn/full-stack.yml --capabilities CAPABILITY_IAM