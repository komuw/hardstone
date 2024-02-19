FROM ubuntu:21.04

WORKDIR /usr/src/app

COPY . /usr/src/app


RUN adduser --disabled-password --gecos "" my_dummy_user && \
    usermod -aG sudo my_dummy_user && \
    passwd -d my_dummy_user

RUN apt -y update;apt -y install sudo

USER my_dummy_user

CMD bash
