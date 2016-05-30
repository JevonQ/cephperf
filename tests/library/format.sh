#!/bin/sh
# This script is used to control the format of output log
#
function print_pound()
{
    local filename=$1
    echo "#####################################################" >> $filename
}
#export -f print_pound
