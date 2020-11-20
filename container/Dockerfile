FROM bitnami/minideb:latest
LABEL maintainer="Wes W."

EXPOSE 1194/udp
VOLUME /clients
ADD ./conf/ /init
ADD ./setup.sh /init/setup.sh

RUN apt-get -y update && \
    apt-get -y install openssl openvpn easy-rsa && \
    apt-get -y clean

ENV PATH=/usr/share/easy-rsa:$PATH

ENTRYPOINT [ "/init/setup.sh" ]