#!/usr/bin/bash

NAME=$1
MEM=$2
RAM=$3

print_usage() {
    echo
    echo "Usage :" | figlet
    echo
    echo "first parameter:"
    echo "name of virtual machine. Ex: MacOSvm"
    echo
    echo "second & third parameters (if you want to change Memory & RAM):"
    echo
    echo "second parameter:"
    echo "size of VM memory. Ex: 100"
    echo
    echo "third parameter:"
    echo "size of VM RAM. Ex: 5"
    echo
    echo "Output expected:"
    echo
    echo "sudo ./CreateVM.sh MacOSvm 100 15"
    echo "OR"
    echo "sudo ./CreateVM.sh MacOSvm"
    echo
    echo "Default Memory: 50"
    echo "Default RAM: 10"
    exit=1
}

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ]
then
  print_usage
elif [ -z "$2" ] && [ -z "$3" ]
then
  echo "Default VM Created!"
  let RAM=5*1048576
  if [ ! -e "/opt/MacOSvm/$NAME" ]
  then
    sudo cp -r /opt/MacOSvm/macOS-Simple-KVM /opt/MacOSvm/$NAME
  fi
  cd /opt/MacOSvm/$NAME
  sudo git checkout -- firmware/OVMF_VARS-1024x768.fd
  sudo ./make.sh --add $NAME $RAM
else
  echo "New VM Created!"
  let RAM=$3*1048579
  if [ ! -e "/opt/MacOSvm/$NAME" ]
  then
    sudo cp -r /opt/MacOSvm/macOS-Simple-KVM /opt/MacOSvm/$NAME
  fi
  cd /opt/MacOSvm/$NAME
  sudo git checkout -- firmware/OVMF_VARS-1024x768.fd
  sudo rm -rf macOS.qcow2
  qemu-img create -f qcow2 macOS.qcow2 ${MEM}G
  sudo ./make.sh --add $NAME $RAM
fi
