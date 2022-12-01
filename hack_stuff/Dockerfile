FROM ubuntu:22.04

# Docker file to build an image that can be used for debuging purposes.

# docker build -t komuw/debug .
#
# docker \
#     run \
#     -it \
#     --entrypoint \
#     /bin/bash \
#     komuw/debug:latest

WORKDIR /app

RUN apt -y update && \
    apt -y install \
    lsof \
    screen \
    telnet \
    curl \
    iputils-ping \
    dnsutils \
    psmisc \
    net-tools \
    tree \
    strace \
    wireshark && \
    apt -y autoremove && \
    apt -y clean && \
    apt -y autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

CMD [ "/bin/bash" ]
