gitmv()
{
  if git rev-parse --show-toplevel > /dev/null 2>&1; 
  then
    # This is a git repo
    { # try
        git mv "$@"
    } || { # catch
        echo "trying fall-back cmd"
        mv "$@"  
    }
  else
    # This is NOT a git repo
    mv "$@"
  fi
}

gitrm()
{
  if git rev-parse --show-toplevel > /dev/null 2>&1; 
  then
    # This is a git repo
    { # try
        git rm "$@"
    } || { # catch
        echo "trying fall-back cmd"
        rm "$@"  
    }
  else
    # This is NOT a git repo
    rm "$@"
  fi
}

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias cat="bat -p"
alias curl="curlie"
alias diff="delta"
alias pip="pip3"

alias mv=gitmv
alias rm=gitrm