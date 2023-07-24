## Hardstone          

[![CircleCI](https://circleci.com/gh/komuw/hardstone.svg?style=svg)](https://circleci.com/gh/komuw/hardstone)


Hardstone, auto creates a development environment and provisions it. The only manual thing you need to do is get a mug of coffee.           
It's name is derived from Kenyan hip hop artiste, Hardstone.                        

This is my setup, it may not work for you. Feel free to modify appropriately.

## Setup       
      
* git clone this project
* cd into this project's directory
* cd to `nixos` directory
* run: 
```shell
bash start.sh
export SSH_KEY_PHRASE=my_ssh_key_pass_phrase
# export USING_TETHERED_INTERNET=YES # this is optional
nix-shell pkgs/
```
* go make a cup of coffee, this may take a while
* your dev environment is ready

## How will this setup mess up my computer?                  
Check the files in `nixos/pkgs`

## NB:      
* This project was tested on a machine running `ubuntu 22.04, 64bit`
* However, It should work for most debian machines. 


## TODO:
* run `shellcheck`;  
```sh
shellcheck --color=always --shell=bash nixos/start.sh
```  


