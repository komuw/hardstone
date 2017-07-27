## Setup and Provision your ubuntu development environment.

This is my setup, it may not work for you. Feel free to modify appropriately.

## Setup       
      
* git clone this project
* cd into this project's directory
* edit vars/base.yml with the values you want
* run: 
```shell
bash setup.sh
```
* go make a cup of coffee, this may take a while
* your dev environment is ready

## How will this setup f**ck up my computer?      
relax home boy. this setup will install and configure: 
* openssh-client
* openssh-server
* kdiff3
* python-pip
* python-software-properties
* software-properties-common
* terminator
* lsof
* telnet
* curl
* mercurial
* git
* unrar
* transmission
* vlc
* pep8
* libpq-dev 
* python2.7-dev
* build-essential
* python-dev
* python-setuptools
* libxml2-dev 
* libxslt1-dev
* postgresql 
* postgresql-contrib
* network-manager-vpnc
* vpnc
* screen
* iftop
* tcptrack
* wireshark
* nano
* ffmpeg
* git-flow
* ffmpeg
* zip
* lxc 
* lxc-templates 
* cgroup-lite 
* redir
* gdb
* skype
* ubuntu-restricted-extras (media codecs)
* google chrome
* sublime-text3
* vagrant
* virtualbox
* pip 
* virtualenv
* virtualenvwrapper
* youtube-dl
* asciinema
* yapf
* ansible
* httpie
* docker
* nvm
* nodeJS
* Go(golang)
	* github.com/motemen/gore                 #golang repl
	* github.com/nsf/gocode                   #golang auto-completion
	* github.com/k0kubun/pp                   #pretty print
	* golang.org/x/tools/cmd/godoc            #docs
	* github.com/derekparker/delve/cmd/dlv    #golang debugger
	* github.com/mailgun/godebug              #another golang debugger
	* hugo                                    #golang static site generator
* popcorntime io

## NB:      
* This project was tested on a machine running ubuntu 16.04, 64bit.
* However, It should work for most debian machines. 
* Some tasks will fail for 32bit machines.

* You can direct any questions, suggestions etc to:     
komuw05 [At] gmail [dot] com


## TODO:
* make it more generic
* fix as many of the tasks whose errors I'm ignoring as possible.
