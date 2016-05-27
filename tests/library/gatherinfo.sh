#!/bin/sh
#
# This script includes the helper functions
#

function installtools()
{
    which facter > /dev/null || yum install -y facter
    which fio > /dev/null || yum install -y fio
}
#export -f installtools

function getdiskinfo()
{
    local blockdevices=`facter blockdevices`
    local all_disk_list=${blockdevices//,/ }
    local osdisk=`mount | grep boot | awk '{print $1}' | cut -d/ -f3 | cut -c 1-3`
    echo $all_disk_list | sed "s/sr0//g" | sed "s/$osdisk//g"
}
#export -f getdiskinfo
