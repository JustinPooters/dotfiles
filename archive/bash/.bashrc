if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi;
export BASH_SILENCE_DEPRECATION_WARNING=1
source $HOME/dotfiles/.bash_aliases
source $HOME/dotfiles/.setterminal
