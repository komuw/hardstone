FROM ubuntu:21.04

WORKDIR /usr/src/app

COPY . /usr/src/app

CMD bash linux/hardstone.sh mySshKeyPassphrase