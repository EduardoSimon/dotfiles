# Installation

This dotfiles uses `chezmoi` as a dotfiles manager.

Open a terminal and run to install the dotfiles:

```
sh -c "$(curl -fsLS https://chezmoi.io/get)" -- init --apply EduardoSimon
```

> [!NOTE]
> The onliner does not install chezmoi, which is required if you want to maintain the dotfiles. If you'd like to install the chezmoi binary, please refer to its [installation guide](https://www.chezmoi.io/install/#one-line-package-install).


## Mac OS Only

- Import Rectangle config file from ~/.config/Rectangle/RectangleConfig.json: Settings > Import

## WSL 2 + windows Only

Follow [this guide](https://github.com/lackovic/notes/tree/master/Windows/Windows%20Subsystem%20for%20Linux#run-linux-gui-applications) to set up gui apps when running in wsl2.

## Mac OS Only

- Open Safari settings > Modify behaviour on start up.
- [Configure fish](https://gist.github.com/gagarine/cf3f65f9be6aa0e105b184376f765262)

# Development

## Adding a new file to chezmoi

```bash
chezmoi add --follow <file/folder>
```

## Edit an already tracked file

```bash
chezmoi edit <file/folder>
```

## Apply the changes to your local copy of the dotfiles repo

```bash
chezmoi apply
```

## Update Homebrew package list

To update the brew package list in `.chezmoidata/brew_packages.yaml` with your currently installed packages:

```bash
./create_brewfile.fish
```

This script will:
1. Generate a Brewfile from your current Homebrew installations
2. Convert it to the brew_packages.yaml format
3. Clean up the temporary Brewfile

After updating the package list, apply the changes:

```bash
chezmoi apply
```

## Run a script for debugging purposes

### Delete the script execution state

```bash
chezmoi state delete-bucket --bucket=scriptState
```

### Run chezmoi apply

```bash
chezmoi apply
```
