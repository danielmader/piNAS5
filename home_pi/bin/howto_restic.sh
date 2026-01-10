#!/bin/bash

cat << EOF

## https://restic.net/#quickstart
## https://restic.readthedocs.io/en/stable/

>>>> Create repository:
sudo restic -r /mnt/esata/restic-repo  init
sudo restic -r /mnt/esata/restic-repo  --password-file=/mnt/data/.secret  init

>>>> Open and check repository:
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  snapshots
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  check
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  stats

>>>> Create new snapshots:
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  backup ./path1 ./path2 ./path3
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  backup /mnt/data/homes --exclude-caches
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  backup /home/pi --skip-if-unchanged --dry-run

>>>> Compare snapshots:
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  diff <id1> <id2>
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  diff <id1>:/foo <id2>:/foo

>>>> List files in a snapshot:
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  ls <id>
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  ls latest
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  ls latest /home --recursive

>>>> Mount a snapshot:
sudo mkdir -p /tmp/restic-repo
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  mount /tmp/restic-repo &

>>>> Remove a snapshot and delete its data:
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  forget <id1> <id1> --keep-last 1 --prune --dry-run

>>>> Restore a snapshot:
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  restore <id> --target /tmp/restore-restic-repo
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  restore latest --target /tmp/restore-restic-repo

>>>> Restore a subset of a snapshot:
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  find bar
sudo restic -r /mnt/esata/restic-repo/ --password-file=/mnt/data/.secret  restore latest --include /foo --exclude /foo/bar --target /tmp/restore-restic-repo

>>>> Shortcuts (.bash_aliases):
resticrepo=$(restic -r /mnt/esata/restic-repo/ -v --password-file=/mnt/data/.secret)
rusticrepo=$(rustic -r /mnt/esata/restic-repo/    --password-file=/mnt/data/.secret)

EOF
