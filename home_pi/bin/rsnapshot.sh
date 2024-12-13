#!/bin/bash

## This script calls `rsnapshot -c <configfile> -t <interval>`.
## Before, it checks it the target volume is mounted.
## The free space before and after the snapshot is logged.

source_dir=/srv/dev-disk-by-uuid-db25f167-dffc-47de-98ff-cab6a0e272c8

target_dir=/mnt/esata/rsnapshots
target_fs=/dev/mapper/esata

## TESTING:
#target_dir=/mnt/data/_esata/rsnapshots
#target_fs=/dev/mapper/data1

interval=manual

conffile=/home/pi/rsnapshot.conf
disklog=/home/pi/diskfree.log

## 1) Check if target device is mounted before proceeding
## v1:
if mount | grep $target_fs > /dev/null
then
    echo -e "\n** Target mounted, proceeding!"
else
    echo -e "\n** Target not mounted, nothing to do!"
    exit
fi
## v2:
#mount | grep $target_fs > /dev/null
#if [ $? -eq 0 ]
#then
#  ...
#else
#  ...
#fi


## 2) Dry-run testing
echo -e "\n## Checking config ..."
rsnapshot  -c $conffile  configtest
echo -e "\n## Dry-run ..."
rsnapshot  -c $conffile  -t $interval
echo
df -h $source_dir
df -h $target_fs

while true; do
    echo
    read -p ">>>> Proceed with actual backup? [y|Y|j|J, *] " yn
    case $yn in
        y|Y|j|J)
            echo; break;;
        *)
            echo; exit;;
    esac
done

## 3) Log disk usage *before* snapshot
echo >> $disklog
date >> $disklog
df -h $source_dir >> $disklog
df -h $target_fs >> $disklog

## 4) Create new snapshot
rsnapshot  -c $conffile  $interval
sync

## 5) Log disk usage *after* snapshot
date >> $disklog
df -h $target_fs >> $disklog
echo -e "\n<<<< Backup done!"

## 6) Check snapshot
rsnapshot-diff  $target_dir/$interval.0  $target_dir/$interval.1
du -csh $target_dir/$interval.0
du -csh $target_dir/$interval.1
echo

## 7) Umount target device
while true; do
    echo
    read -p ">>>> Umount target? [y|Y|j|J, *] " yn
    case $yn in
        y|Y|j|J)
            echo -e "\n#### Umounting target ...";umount $target_fs;break;;
        *)
            echo -e "\n#### Skipping.";break;;
    esac
done

echo -e "\n#### All done."
