#!/bin/bash

function init() {
    easyrsa init-pki
    echo "ww-vpn-ca" | easyrsa build-ca nopass
    easyrsa build-server-full server nopass
    for i in {1..5}; do easyrsa build-client-full ww-vpn-${i} nopass; done
    easyrsa gen-dh
    openvpn --genkey --secret /pki/private/pfs.key
    rm /pki/private/ca.key

    # Generate server config file
    sed -e '/%PFS_KEY%/{r /pki/private/pfs.key' \
        -e 'd}' \
        -e '/%DH_PEM%/{r /pki/dh.pem' \
        -e 'd}' \
        -e '/%CA_CRT%/{r /pki/ca.crt' \
        -e 'd}' \
        -e '/%CRT%/{r /pki/issued/server.crt' \
        -e 'd}' \
        -e '/%KEY%/{r /pki/private/server.key' \
        -e 'd}' /init/openvpn-server.conf >/clients/ww-vpn-server.conf
    cp /clients/ww-vpn-server.conf /etc/openvpn/server.conf

    # Generate client config files
    for i in {1..5}; do
        mv /pki/issued/ww-vpn-${i}.crt /pki/issued/current.crt
        mv /pki/private/ww-vpn-${i}.key /pki/private/current.key
        sed -e "s/%SERVER_NAME%/vpn.dubyatoo.com/g" \
            -e "s/%CLIENT%/ww-vpn-${i}/g" \
            -e '/%PFS_KEY%/{r /pki/private/pfs.key' \
            -e 'd}' \
            -e '/%DH_PEM%/{r /pki/dh.pem' \
            -e 'd}' \
            -e '/%CA_CRT%/{r /pki/ca.crt' \
            -e 'd}' \
            -e '/%CRT%/{r /pki/issued/current.crt' \
            -e 'd}' \
            -e '/%KEY%/{r /pki/private/current.key' \
            -e 'd}' /init/openvpn-client.conf >/clients/ww-vpn-${i}.conf
        rm /pki/issued/current.crt /pki/private/current.key
    done
}

# Create config if not provided
if [ ! -e /etc/openvpn/server.conf ]; then
    init
fi

iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.17.0.2/16 -o eth0 -j MASQUERADE

echo "Starting openvpn server..."
openvpn --config /etc/openvpn/server.conf