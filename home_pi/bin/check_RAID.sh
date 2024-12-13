#!/bin/bash

## FS-Informationen darstellen (analog zu mdadm --detail <device>)
echo -e "\n$(sudo btrfs filesystem show)"
echo -e "\n$(sudo btrfs filesystem df /srv/dev-disk-by-uuid-db25f167-dffc-47de-98ff-cab6a0e272c8)"
echo -e "\n$(sudo btrfs filesystem usage /srv/dev-disk-by-uuid-db25f167-dffc-47de-98ff-cab6a0e272c8)"
