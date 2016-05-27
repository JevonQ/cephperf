#!/bin/sh
#
# This script could be used to warmup all disks of one Ceph OSD nodes.
# During the excution of this script you are needed to guarentee the
# correctness of fio configuation file. Please pay more attention to
# the disks being tested.
#

source ./library/gatherinfo.sh

function echo_global_section()
{
    echo "#!/bin/sh"
    echo "# "
    echo "# This script is used to warmup all the disks in one host"
    echo "# before evaluating their real performance"
    echo "# Generated at `date --rfc-3339=seconds`"
    echo ""
    echo "[global]"
    echo "ioengine=libaio"
    echo "direct=1"
    echo "thread"
    echo "runtime=131072000"
    echo "time_based"
    echo "sync=1"
    echo "iodepth=64"
    echo "numjobs=16"
    echo "group_reporting"
    echo ""
}

function echo_disk_section()
{
    for i in $1
    do
        echo "[4krw-warmup-$i]"
        echo "bs=4k"
        echo "rw=randwrite"
        echo "filename=/dev/$i"
        echo "norandommap"
        echo "randrepeat=0"
        echo ""
    done
}

function construct_cfg()
{
    echo_global_section
    echo_disk_section "$osd_disk_list"
}

function generate_cfg()
{
    installtools
    osd_disk_list=`getdiskinfo`
    construct_cfg &> $cfgname
    if [[ $? != 0 ]]; then
        echo "construct_cfg error"
        return 1
    fi
    return 0;
}

function warmup_disks()
{
    local hostname=`hostname|cut -d. -f1`
    local cfgname="fio-warmup-${hostname}.cfg"
    local ret;

    # Need to regenerate config file
    if [[ -e $cfgname ]]; then
        echo "Config file already exists, type yes to recreate it:"
        read recreate

        case $recreate in
        [Yy][Ee][Ss])
            # Generate fio config file
            generate_cfg
            ;;
        *)
            ;;
        esac
    else
        ret=`generate_cfg`
        if [[ $ret != 0 ]]; then
            echo "Can not create $cfgname"
            exit 1
        fi
    fi

    # Make sure fio config file is correct
    echo "Please check fio script and type yes if you think it is correct:"
    read confirm

    # Warm up the disks
    case $confirm in
    [Yy][Ee][Ss])
        if [[ -e $cfgname ]];then
            fio $cfgname
        fi
        ;;
    *)
        echo "Input error, you do not confirm the test"
        ;;
    esac
}

warmup_disks
