FROM ubuntu:22.04

WORKDIR /usr/src/app

COPY . /usr/src/app

CMD cd nixos/ && \
    bash start.sh
