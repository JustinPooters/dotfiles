echo "Copying files..."
if [ ! -f "$HOME/.bashrc" ]; then
 sudo ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc
fi;

if [ ! -f "$HOME/.bash_profile" ]; then 
  sudo ln -s $HOME/dotfiles/.bash_profile $HOME/.bash_profile
fi;

if [ ! -f "$HOME/.vimrc" ]; then
  sudo ln -s $HOME/dotfiles/.vimrc $HOME/.vimrc
fi

if [ ! -f "$HOME/.config/nvim/init.vim" ]; then
  sudo mkdir -p $HOME/.config/nvim
  sudo ln -s $HOME/dotfiles/.init.vim $HOME/.config/nvim/init.vim
fi

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
 sudo apt install git -y
 sudo apt install vim -y 
 sudo apt install tmux -y
 sudo apt install nodejs -y
 sudo apt install npm -y
 sudo apt install neovim -y 
 sudo apt install docker -y
 sudo apt install docker-compose -y
 sudo apt install yarn -y
fi;

echo "Installing completed"
read -p "Press enter to continue"
echo "Installing vim/nvim plugins"

# Install vim plugins
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
  vim +PluginInstall +qall
fi

# Build coc.nvim
cd $HOME/.vim/bundle/coc.nvim/
sudo npm i -g yarn
yarn install
yarn build



echo "After closing your terminal, these changes will be applied"
read -p "Press enter to close your terminal"
exit
