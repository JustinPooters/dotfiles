echo "Welcome to this install script"
echo "Do not delete this folder after installation"
echo "Also make sure this folder is in your user directory (e.g. /home/user/ or /users/user/"
echo "script made by Justin Pooters inspired on the script of Stan Van Rooy"

echo "."
echo "."
echo "Copying files..."
if [ ! -f "$HOME/.bashrc" ]; then
  ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc
fi;

if [ ! -f "$HOME/.bash_profile" ]; then 
  ln -s $HOME/dotfiles/.bash_profile $HOME/.bash_profile
fi;

read -p "Done copying files. Press enter to continue the installation."

if [[ $OSTYPE == 'darwin'* ]]; then
 echo "You are currently on MacOS (DARWIN)"
 echo "Using Homebrew to install"
 brew install git
 brew install vim
 brew install tmux
 brew install node@16
 brew install nvim
 brew install docker
 brew install docker-compose
else
 echo "You are currently on Linux (LINUX)"
 echo "Using apt to install"
 apt install git
 apt install vim
 apt install tmux
 apt install node
 apt install nvim
 apt install docker
 apt install docker-compose
fi;

echo "Installation completed"
echo "After closing your terminal, these changes will be applied"
read -p "Press enter to close your terminal"
exit
