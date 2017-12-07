# WW-VPN

Cloudformation script to make your own OpenVPN server!

To launch the stack with default parameters run `./launch.sh`. (Assumes there's a Key Pair named ww-vpn and S3 bucket named silly.apps.storage in your AWS account).

## How to use
1. Key pair 
	Configure a key pair of your choice associated with your AWS account, or create one. `aws ec2 create-key-pair --key-name YOUR_KEY_NAME`
2. S3 bucket
	Specify or create an S3 bucket to hold the configuration files. `aws s3 mb s3://YOUR_BUCKET_NAME`
3. Run the script
	`./launch-east.sh`
	After launching the stack, SCP `~/ww-vpn.zip` to your local machine, then proceed to delete it from the server.

Unzip the archive to a directory of your choice.

## Remote resources
This template pull configuration files (also in this repo) from an S3 bucket.

Note: this whole thing should be a playbook... todo