# Installation

This dotfiles uses chezmoi as a manager, as such, chezmoi needs to be installed in the host, to install please refer to the official [installation guide](https://www.chezmoi.io/install/#one-line-package-install)

## Install chezmoi and initialize the dotfiles

As a general rule of thumb, open your terminal and run to install the binary:
```
sh -c "$(curl -fsLS https://chezmoi.io/get)" -- init --apply EduardoSimon
```

# Specific Docs per OS

## WSL 2 + windows

Follow [this guide](https://github.com/lackovic/notes/tree/master/Windows/Windows%20Subsystem%20for%20Linux#run-linux-gui-applications) to set up gui apps when running in wsl2.

## Modify the chezmoi.toml file by adding the specific system values

```
nvim ~/.config/chezmoi/chezmoi.toml
```

## Apply again the dotfiles config

```
chezmoi apply
```
