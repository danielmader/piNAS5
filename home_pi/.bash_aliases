# ~/.bash_aliases


## User specific aliases and functions

alias less='less -NM'

alias ll='ls $LS_OPTIONS -l'
alias lc='ls $LS_OPTIONS -lc'
alias la='ls $LS_OPTIONS -la'
alias lA='ls $LS_OPTIONS -lA'

## Some more to avoid making mistakes
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

## Shortcuts for rsync
alias rsyncauvd='rsync -auv --info=progress2 --delete-after --stats'
alias rsyncaHAX='rsync -auHAXv --info=progress2 --delete-after --stats'

## Show only real filesystems
alias mountfs='mount | grep "type btrfs\|type ext4\|type vfat\|type fuse"'

## Make sudo use aliases
## https://chatgpt.com/share/674970fa-58e8-8005-8595-12f281d046f6
alias sudo='sudo '

## Backup software
alias rsnapshot.sh='/home/pi/bin/rsnapshot.sh'
alias restic='/home/pi/bin/restic '
alias rustic='/home/pi/.cargo/bin/rustic '
alias resticrepo='/home/pi/bin/restic        -r /mnt/esata/restic-repo -v -p /mnt/data/secret_resticrustic '
alias rusticrepo='/home/pi/.cargo/bin/rustic -r /mnt/esata/restic-repo    -p /mnt/data/secret_resticrustic '
alias cargo-binstall='/home/pi/.cargo/bin/cargo-binstall '
