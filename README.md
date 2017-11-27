# WW-VPN

Cloudformation script to make your own OpenVPN server!

To launch the stack with default parameters run `./launch.sh`. (Assumes there's a Key Pair named ww-vpn and S3 bucket named silly.apps.storage in your AWS account).

## How to use
After launching the stack, copy `~/ww-vpn.zip` to your local machine, then proceed to delete it from the server.

Unzip the archive to a directory of your choice.

## Remote resources
This template pull configuration files (also in this repo) from an S3 bucket.