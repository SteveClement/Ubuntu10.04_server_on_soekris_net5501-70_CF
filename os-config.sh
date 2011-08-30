#!/bin/bash

# Title        : os-config.sh
# Author       : sambaTux <sambatux@web.de>
# Start date   : 09.08.2011
# OS tested    : Ubuntu10.04
# BASH version : 4.1.5(1)-release
# Requires     : cp, sed, update-grub, tune2fs, apt-get update, mkdir
# Version      : 0.1
# Task(s)      : configure OS to run on Compact Flash


# Define vars
grub_conf='/etc/default/grub'     
rd='ramdisk_size=170000'          #~170MB. Size for /dev/ram? devices.
con='console=ttyS0,19200'         #serial console settings needed for soekris net5501
el='elevator=noop'                #best for flash memory
ply='noplymouth'                  #turn of plymouth boot splash

# Set kernel parameter 
if [[ -f "$grub_conf" ]]; then
   cp -p "$grub_conf" ${grub_conf}.bak
   sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="'$rd' '$con' '$el' '$ply'"/' "$grub_conf" \
   && update-grub
fi

# Turn off counter based fsck for root dev
rootdev=`rdev | cut -d ' ' -f 1`
tune2fs -c -1 "$rootdev"

# Deactivate  "multiverse" and "universe" repos in order to save ~60MB in /var/lib/apt/lists/
sources="/etc/apt/sources.list"
if [[ -f "$sources" ]]; then
   cp -p "$sources" ${sources}.bak
   sed -i 's/^deb.*\(universe\|multiverse\)$/#&/' "$sources" \
   && apt-get update
fi

# Set swappiness to 0 (def. = 60). 0 means that the kernel should preferably not use the swapp partition.
sysctl="/etc/sysctl.conf"
if [[ -f "$sysctl" ]]; then
   echo "" >>"$sysctl"
   echo "# Set swappiness to 0, meaning that the swapp partition should preferably not be used by the kernel" >>"$sysctl"
   echo "vm.swappiness=0" >>"$sysctl"
fi

exit 0
