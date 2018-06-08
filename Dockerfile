FROM ubuntu:18.04

WORKDIR /usr/src/app

COPY . /usr/src/app

CMD bash hardstone.sh mySshKeyPassphrase