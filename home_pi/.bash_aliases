# ~/.bash_aliases


## User specific aliases and functions

alias less='less -NM'

alias ll='ls $LS_OPTIONS -l'
alias lc='ls $LS_OPTIONS -lc'
alias la='ls $LS_OPTIONS -la'
alias lA='ls $LS_OPTIONS -lA'

alias rsyncauvd='rsync -auv --info=progress2 --delete-after --stats'
alias rsyncaHAX='rsync -auHAXv --info=progress2 --delete-after --stats'

alias mountfs='mount | grep "type btrfs\|type ext4\|type vfat"'

## Make sudo use aliases
## https://chatgpt.com/share/674970fa-58e8-8005-8595-12f281d046f6
alias sudo='sudo '

## Backup software
alias rsnapshot.sh='/home/pi/bin/rsnapshot.sh'
alias restic='/home/pi/bin/restic '
alias resticrepo='sudo restic --repo /mnt/esata/restic-repo -v --password-file=/mnt/data/.restic_secret '
alias rustic='/home/pi/.cargo/bin/rustic'
alias cargo-binstall='/home/pi/.cargo/bin/cargo-binstall'

## Some more to avoid making mistakes
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
