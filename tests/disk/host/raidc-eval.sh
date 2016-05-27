#!/bin/sh
#
# This script could be used to evaluate the performance of raid controller
# by testing all disks connected to the controller.
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
    echo "runtime=300"
    echo "time_based"
    echo "sync=1"
    echo "iodepth=64"
    echo "numjobs=16"
    echo "group_reporting"
    echo "norandommap"
    echo "randrepeat=0"
    echo "rw=randwrite"
    echo ""
}

function echo_disk_section()
{
    for i in $1
    do
	echo "[4krw-$i]"
	echo "bs=4k"
	echo "filename=/dev/$i"
	echo ""
    done
}

function construct_cfg()
{
    echo_global_section
#    echo_disk_section "$osd_disk_list"
    echo_disk_section "sda"
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
    return "0";
}

function eval_raidc()
{
    local hostname=`hostname|cut -d. -f1`
    cfgname="fio-raidc-${hostname}.cfg"
    local ret

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
	generate_cfg
	if [[ $? != 0 ]]; then
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
#export -f eval_raidc

eval_raidc
