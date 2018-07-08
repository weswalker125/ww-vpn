FROM centos:7
LABEL maintainer="Wes W."

EXPOSE 1194/udp
VOLUME /clients
ADD ./conf/ /init
ADD ./setup.sh /init/setup.sh

RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install openssl openvpn easy-rsa --enablerepo=epel

ENV PATH=/usr/share/easy-rsa/3:$PATH

ENTRYPOINT [ "/init/setup.sh" ]