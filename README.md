# WW-VPN

Docker container for OpenVPN server.
Deploy to EC2 with Ansible playbook.

```ansible-playbook main.yml```

## How to use
After launching the instance, the client configurations will be uploaded to S3.  Download the conf files and add to OpenVPN client.