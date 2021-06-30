{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz") {} }:

{
  inputs = [
      pkgs.mpv
      pkgs.openssh-client
      pkgs.kdiff3
      pkgs.meld
      pkgs.terminator
      pkgs.lsof
      pkgs.telnet
      pkgs.htop
      pkgs.unrar
      pkgs.transmission
      pkgs.vlc
      pkgs.screen
      pkgs.iftop
      pkgs.tcptrack
      pkgs.wireshark
      pkgs.nano
      pkgs.zip
      pkgs.redir
      pkgs.gdb
      pkgs.hexchat
      pkgs.mosh
      pkgs.vnstat
      pkgs.psmisc
      pkgs.traceroute
      pkgs.graphviz
      pkgs.ffmpeg
      pkgs.x264
      pkgs.x265
      pkgs.nettools
      pkgs.aria
      pkgs.shellcheck
      pkgs.rlwrap
      pkgs.tree
      pkgs.streamlink

       # FOUND BUT NOT SURE WE NEED THESE:
       # lxc 

        # WE HAVENT FOUND THESE:
        # postgresql-client
        # lxc-templates 
        # cgroup-lite 
        # gdebi
        # wireguard

      ];
  hooks = ''
    echo "hello from provision.nix"
    
    MY_NAME=$(whoami)

    create_dirs(){
        printf "\n\n create my stuff dir\n"
        mkdir -p /home/$MY_NAME/mystuff
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/mystuff

        printf "\n\n create personalWork dir\n"
        mkdir -p /home/$MY_NAME/personalWork
        chown -R $MY_NAME:$MY_NAME /home/$MY_NAME/personalWork
    }
    create_dirs

    setup_terminator_conf(){
        printf "\n\n create terminator conf dir\n"
        mkdir -p /home/$MY_NAME/.config && mkdir -p /home/$MY_NAME/.config/terminator
        TERMINATOR_CONFIG_FILE_CONTENTS='[global_config]
        enabled_plugins = LaunchpadCodeURLHandler, APTURLHandler, LaunchpadBugURLHandler
        [keybindings]
        copy = <Primary>c
        paste = <Primary>v
        [profiles]
        [[default]]
            use_system_font = False
            background_darkness = 0.94
            background_type = transparent
            background_image = None
            foreground_color = "#00ff00"
            font = Monospace 13
        [[{{ USER }}]]
            use_system_font = False
            background_darkness = 0.8
            background_type = transparent
            background_image = None
            foreground_color = "#00ff00"
            font = Monospace 14
        [layouts]
        [[default]]
            [[[child1]]]
            profile = New Profile
            type = Terminal
            parent = window0
            [[[window0]]]
            type = Window
            parent = ""
        [plugins]'
        TERMINATOR_CONFIG_FILE=/home/$MY_NAME/.config/terminator/config
        touch "$TERMINATOR_CONFIG_FILE"
        echo "$TERMINATOR_CONFIG_FILE_CONTENTS" >> "$TERMINATOR_CONFIG_FILE"
    }
    setup_terminator_conf

    setup_bashrc(){
        printf "\n\n configure .bashrc\n"
        # there ought to be NO newlines in the content
        BASHRC_FILE_FILE_CONTENTS='#solve passphrase error in ssh
        #enable auto ssh-agent forwading
        #see: http://rabexc.org/posts/pitfalls-of-ssh-agents
        ssh-add -l &>/dev/null
        if [ "$?" == 2 ]; then
        test -r /home/$MY_NAME/.ssh-agent && \
            eval "$(</home/$MY_NAME/.ssh-agent)" >/dev/null
        ssh-add -l &>/dev/null
        if [ "$?" == 2 ]; then
            (umask 066; ssh-agent > /home/$MY_NAME/.ssh-agent)
            eval "$(</home/$MY_NAME/.ssh-agent)" >/dev/null
            ssh-add
        fi
        fi
        export HISTTIMEFORMAT="%d/%m/%Y %T "'
        BASHRC_FILE=/home/$MY_NAME/.bashrc
        grep -qF -- "$BASHRC_FILE_FILE_CONTENTS" "$BASHRC_FILE" || echo "$BASHRC_FILE_FILE_CONTENTS" >> "$BASHRC_FILE"
    }
    setup_bashrc

    perform_security_updates(){
        printf "\n\n  update\n"
        sudo apt-get -y update

        printf "\n\n add security updates\n"
        sudo apt-get -y dist-upgrade
    }
    perform_security_updates
  '';
}
