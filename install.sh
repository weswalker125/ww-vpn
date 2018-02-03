#!/bin/bash
### Expected env variable: ConfigBucket

ConfigBucket="$1"

yum -y update
yum -y install openvpn easy-rsa --enablerepo=epel
modprobe iptable_nat
echo 1 | tee /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s 10.4.0.1/2 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
cd /usr/share/easy-rsa/3
./easyrsa init-pki
# Create CA at ./pki/ca.crt
echo "ww-vpn-ca" | ./easyrsa build-ca nopass
# Create diffie-hellman parameters at ./pki/dh.pem
./easyrsa gen-dh
# Create server cert at ./pki/issued/ww-vpn.crt, server key at ./pki/private/ww-vpn.key
./easyrsa build-server-full ww-vpn nopass
# Create client certs at ./pki/issued/*.crt, server key at ./pki/private/*.key
CLIENTS=(device-laptop device-tablet device-phone)
for client in "${CLIENTS[@]}"; do
  ./easyrsa build-client-full $client nopass
done
openvpn --genkey --secret ./pki/private/pfs.key
mkdir -p /etc/openvpn/keys
rm ./pki/private/ca.key
find . -type f -name "*.crt" -exec cp {} /etc/openvpn/keys/ \;
find . -type f -name "*.key" -exec cp {} /etc/openvpn/keys/ \;

aws s3 cp s3://${ConfigBucket}/ww-vpn/openvpn-server.conf /etc/openvpn/server.conf
# Replace placeholders with content
sed -i -e '/%PFS_KEY%/{r ./pki/private/pfs.key' -e 'd}' /etc/openvpn/server.conf
sed -i -e '/%DH_PEM%/{r ./pki/dh.pem' -e 'd}' /etc/openvpn/server.conf
sed -i -e '/%CA_CRT%/{r ./pki/ca.crt' -e 'd}' /etc/openvpn/server.conf
sed -i -e '/%CRT%/{r ./pki/issued/ww-vpn.crt' -e 'd}' /etc/openvpn/server.conf
sed -i -e '/%KEY%/{r ./pki/private/ww-vpn.key' -e 'd}' /etc/openvpn/server.conf

# Create client configs
mkdir -p /home/ec2-user/ww-vpn
for client in "${CLIENTS[@]}"; do
  FILE=/home/ec2-user/ww-vpn/openvpn-${client}.conf
  aws s3 cp s3://${ConfigBucket}/ww-vpn/openvpn-client.conf $FILE

  sed -i -e "s/%CLIENT%/${client}/g" $FILE
  sed -i -e '/%PFS_KEY%/{r ./pki/private/pfs.key' -e 'd}' $FILE
  sed -i -e '/%DH_PEM%/{r ./pki/dh.pem' -e 'd}' $FILE
  sed -i -e '/%CA_CRT%/{r ./pki/ca.crt' -e 'd}' $FILE
  #didn't work:
  mv ./pki/issued/${client}.crt ./pki/issued/current.crt
  mv ./pki/private/${client}.key ./pki/private/current.key
  sed -i -e '/%CRT%/{r ./pki/issued/current.crt' -e 'd}' $FILE
  sed -i -e '/%KEY%/{r ./pki/private/current.key' -e 'd}' $FILE
done

# Start OpenVPN
service openvpn start

echo "Copy files under the home directory and delete them." > /home/ec2-user/README
chown -R ec2-user:ec2-user /home/ec2-user/
zip -j /home/ec2-user/ww-vpn.zip /home/ec2-user/ww-vpn/*
rm -rf /home/ec2-user/ww-vpn/
chown -R ec2-user:ec2-user /home/ec2-user/