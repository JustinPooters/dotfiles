
if [ ! -f "$HOME/.bashrc" ]; then
  ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc
fi;

if [[ $OSTYPE == 'darwin'* ]]; then
 echo "You are currently on MacOS (DARWIN)"
 brew install git
 brew install vim
 brew install tmux
 brew install node@16
 brew install nvim
 brew install docker
 brew install docker-compose
else
 echo "You are currently on Linux (LINUX)"
 apt install git
 apt install vim
 apt install tmux
 apt install node
 apt install nvim
 apt install docker
 apt install docker-compose
fi;

