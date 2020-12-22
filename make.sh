#!/bin/bash

# make.sh: Generate customized libvirt XML.

VMDIR=$PWD
MACHINE="$(qemu-system-x86_64 --machine help | grep q35 | cut -d" " -f1 | grep -Eoe ".*-[0-9.]+" | sort -rV | head -1)"
OUT="template.xml"
NAME=$2
RAM=$3

print_usage() {
    echo
    echo "Usage: $0"
    echo
    echo " -a, --add   Add XML to virsh (uses sudo)."
    echo
}

error() {
    local error_message="$*"
    echo "${error_message}" 1>&2;
}

generate(){
    sed -e "s|VMDIR|$VMDIR|g" -e "s|MACHINE|$MACHINE|g" -e "s|NAME|$NAME|g" -e "s|RAM|$RAM|g" tools/template.xml.in > $OUT
    echo "$OUT has been generated in $VMDIR"
}

generate

argument="$1"
case $argument in
    -a|--add)
        sudo virsh define $OUT
	sudo virsh autostart $NAME
        ;;
    -h|--help)
        print_usage
        ;;
esac
