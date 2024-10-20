# Installation

This dotfiles uses `chezmoi` as a dotfiles manager.

Open a terminal and run to install the dotfiles:

```
sudo sh -c "$(curl -fsLS https://chezmoi.io/get)" -- init --apply EduardoSimon
```

> [!NOTE]
> The onliner does not install chezmoi, which is required if you want to maintain the dotfiles. If you'd like to install the chezmoi binary, please refer to its [installation guide](https://www.chezmoi.io/install/#one-line-package-install).


## WSL 2 + windows Only

Follow [this guide](https://github.com/lackovic/notes/tree/master/Windows/Windows%20Subsystem%20for%20Linux#run-linux-gui-applications) to set up gui apps when running in wsl2.

## Mac OS Only

- Open Safari settings > Modify behaviour on start up.

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

## Run a script for debugging purposes

### Delete the script execution state

```bash
chezmoi state delete-bucket --bucket=scriptState
```

### Run chezmoi apply

```bash
chezmoi apply
```
