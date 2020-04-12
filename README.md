## Hardstone          

[![CircleCI](https://circleci.com/gh/komuw/hardstone.svg?style=svg)](https://circleci.com/gh/komuw/hardstone)


Hardstone, auto creates a development environment and provisions it. The only manual thing you need to do is get a mug of coffee.           
It's name is derived from Kenyan hip hop artiste, Hardstone.                        

This is my setup, it may not work for you. Feel free to modify appropriately.

## Setup       
      
* git clone this project
* cd into this project's directory
* run: 
```shell
bash hardstone.sh mySshKeyPassphrase personalWorkSshKeyPhrase personalWorkEmail personalWorkName UserPassword
```
* go make a cup of coffee, this may take a while
* your dev environment is ready

## How will this setup mess up my computer?                  

relax home boy. this setup will install and configure: 
* openssh-client
* meld
* terminator
* telnet
* curl
* mercurial
* git
* transmission
* vlc
* google chrome
* sublime-text3
* vagrant
* virtualbox
* youtube-dl
* asciinema
* docker
* nodeJS
* Go(golang)
* Dart(dartlang)
* among other stuff

## NB:      
* This project was tested on a machine running [ubuntu 18.04, 64bit.](https://circleci.com/gh/komuw/hardstone)
* However, It should work for most debian machines. 
* Some tasks will fail for 32bit machines.

* You can direct any questions, suggestions etc to:     
komuw05 [At] gmail [dot] com


## TODO:
* make it more generic
* run `shellcheck`;  
```sh
shellcheck --color=always --shell=bash golang.sh
```  


