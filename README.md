<h1 align="center">
  .dotfiles created using <a href="https://github.com/CodelyTV/dotly">🌚 dotly</a>
</h1>

## Restore your Dotfiles

* Install git
* Clone your dotfiles repository `git clone https://github.com/EduardoSimon/dotfiles.git $HOME/.dotfiles`
* Go to your dotfiles folder `cd $HOME/.dotfiles`
* Install git submodules `git submodule update --init --recursive`
* Install your dotfiles `$HOME/.dotfiles/modules/dotly/bin/dot self install`


## Updating Dotly

`cd $DOTLY_PATH && git pull origin master --rebase`

### ToDo List on personal dotfiles

- [ ] Improve git global config on WSL and review other platform
- [ ] Review unsynced IntelliJ settings and apply them with scripts
- [ ] Add commit flags to gc dot command
- [ ] Research how to unbind system keys on Linux/Windows/Mac
- [ ] Karabiner
- [ ] Improve SQL support
