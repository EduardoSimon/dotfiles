# Installation Guide

## On a new MacOS (migrating from another)
* Log in iCloud and Sync all Keychain passwords
* Update Mac
* Backup `~/.ssh` and `~/.gnupg` from the previous computer to the new one
    - `chmod -R 700 ~/.ssh`
    - `chmod -R 700 ~/.gnupg`
* Execute the dotfiles installer
* Open Karabiner-Elements
* Open Zoho Vault and login
* Login in Google Chrome
* Install Rectangle
  
* Go to `Preferences/Keyboard/Shortcuts` and disable everything. Except Cmd + Option + Shift + 4 for screen capturing.
 
  ![img.png](img.png)
  
* Go to `Preferences/Security` and activate `Firewall`
  
* Install Alfred
  
* Open JetBrains Toolbox and login
    - Login
    - Enable "generate shell scripts in ~/bin"
    - Install PHPStorm and Webstorm
* Open PHPStorm and Webstorm
    - Import from JetBrains account
    - Sync plugins
    - Execute `dot intellij add_code_templates`
* Open Spotify
    - Set streaming quality to very high
    - Disable automatic startup
* Download iTerm nightly
    - Install brew cask install iterm to see options
    - Select load preferences from URL and use ~/.dotfiles/mac/iTerm. On the next prompt select "NOT copy"
* Download and install IBM Plex Mono
* Extra:
    - Prevent other volumes to be mounted on the startup
        - `sudo vim /etc/fstab`
        - Add at the bottom `UUID=6F34F6C2-1E7D-4A94-A765-1CEDB127E04D none ntfs rw,noauto`
        - The UUID is obtained from `diskutil info /Volumes/{Disk Name} | grep 'Volume UUID'`
    
* Execute `dot shell zsh optimize`