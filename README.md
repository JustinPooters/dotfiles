# 🧰 Justin’s Dev Configs

[![Windows](https://img.shields.io/badge/Windows-0078D6?logo=windows&logoColor=white)](#-windows-setup)
[![macOS](https://img.shields.io/badge/macOS-000000?logo=apple&logoColor=white)](#-macos-setup)
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](#-linux-setup)
[![Shell](https://img.shields.io/badge/Shell-PowerShell%20%7C%20Bash%20%7C%20Zsh-5391FE)](#)
[![Prompt](https://img.shields.io/badge/Prompt-Oh%20My%20Posh%20%7C%20Starship-4782B4)](#)

Cross-platform developer setup for **Windows**, **macOS**, and **Linux**.  
Includes prompt themes, VS Code settings, Git config, and automation scripts to get your environment ready in minutes.

> 💬 *“Ship it. If it breaks, we’ll learn something new.”*

---

## 📦 What’s Inside

| Platform | Shell | Prompt | Theme file | Setup script |
|-----------|--------|---------|-------------|---------------|
| 🪟 Windows | PowerShell 7 | Oh My Posh | `terminal/oh-my-posh/theme.json` | `scripts/setup.ps1` |
| 🐧 Linux | Bash | Starship | `terminal/starship.toml` | `scripts/setup-linux.sh` |
| 🍎 macOS | Zsh | Starship | `terminal/starship.toml` | `scripts/setup-mac.sh` |

Also includes:
- Shared `.NET version` detection (PowerShell & Bash/Zsh)
- VS Code settings, keybindings, and extensions
- Git global config and ignore file
- `.editorconfig` for consistent code style

---

## 🚀 Quick Start

### 🪟 Windows Setup
```powershell
git clone https://github.com/justinpooters/dotfiles
cd dotfiles
pwsh -ExecutionPolicy Bypass -File .\scripts\setup.ps1 -All
```
Then reopen PowerShell — your Oh My Posh prompt and profile are live.  

---

### 🍎 macOS Setup
```bash
git clone https://github.com/justinpooters/dotfiles
cd dotfiles
chmod +x scripts/setup-mac.sh
./scripts/setup-mac.sh
exec zsh
```

This will:
- Install Homebrew (if needed)
- Install `git`, `starship`, `jq`, and `wget`
- Link your Starship theme and enable it in `.zshrc`
- Apply VS Code and Git settings  

---

### 🐧 Linux Setup
```bash
git clone https://github.com/justinpooters/dotfiles
cd dotfiles
chmod +x scripts/setup-linux.sh
./scripts/setup-linux.sh
source ~/.bashrc
```

Installs packages via **apt** or **Linuxbrew**, sets up Starship, and applies configs.

---

## 🧩 PowerShell Functions
*(Windows only — inside `terminal/powershell-profile.ps1`)*

| Command | Description |
|----------|-------------|
| `dev` | Jump to `~/Development`, auto-creates if missing |
| `whereami` | Print current directory |
| `..` | Navigate one level up |
| `l` | Shortcut for `ls` |
| `touch file.txt` | Create a new file |
| `notepad file.txt` | Open in Notepad++ |
| Auto .NET Version | Detects nearest `.csproj` → sets `$env:DOTNET_VERSION` |

---

## ⚙️ Updating VS Code

After changing extensions:
```bash
code --list-extensions > vscode/extensions.txt
```

Commit & push to sync across machines.

---

## ❤️ Proud to be part of <span style="color:#E8003D;">ilionx</span>

Maintained by **[Justin Pooters](https://github.com/justinpooters)**  

---

### 📝 License
MIT — fork, adapt, and improve 🚀
