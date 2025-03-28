# dotfiles

Welcome to my **dotfiles** repo.  
This repository contains configurations for multiple shells to quickly set up my preferred terminal environment.  
Feel free to use it for your own setup as well.

## Supported Shells
Currently available:
- Bash
- PowerShell

Coming soon:
- Zsh
- Fish

## Functions
- Color terminal themes
- Essential package installation
- Tmux configuration
- Vim customization

## How to Install
To install, simply clone the repository and run the installation script:

##### BASH
```
git clone https://github.com/justinpooters/dotfiles
cd dotfiles/bash
chmod +x install.sh
./install.sh
```

##### Powershell
```
git clone https://github.com/justinpooters/dotfiles
cd dotfiles/powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
./install.ps1
```

The installation script will detect your shell and apply the appropriate configurations.

# Features

## Color Terminal
Here's a preview of how your terminal will look after installation:

###### BASH
![Terminal](https://i.ibb.co/55VbHNZ/image.png)

###### Powershell
![Terminal](https://i.ibb.co/mFMsTZNW/image.png)


**Note:** Terminal username, hostname, folder location, and git repository information will be customized based on your system configuration.

## More Features Coming Soon
Stay tuned for additional shell support and features!