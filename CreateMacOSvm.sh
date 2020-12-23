#!/usr/bin/bash

NAME=$2
MEM=$3
RAM=$4
ACTPATH=$PWD

print_usage() {
    echo
    echo "USAGE :"
    echo
    echo "first parameter"
    echo "-f if you dont have a vm created by this script"
    echo "-c if you want to create a vm"
    echo "-d if you want to delete a vm"
    echo
    echo "second parameter:"
    echo "name of virtual machine. Ex: MacOSvm"
    echo
    echo "third & fourth parameters (if you want to change Memory & RAM):"
    echo
    echo "third parameter:"
    echo "size of VM memory. Ex: 100"
    echo
    echo "fourth parameter:"
    echo "size of VM RAM. Ex: 5"
    echo
    echo "Output expected:"
    echo "sudo ./CreateMacOSvm.sh -c MacOSvm 100 5"
    echo "OR"
    echo "sudo ./CreateMacOSvm.sh -c MacOSvm"
    echo
    echo "Default Memory: 120G"
    echo "Default RAM: 4G"
    exit=1
}

arg="$1"
case $arg in
  -c)
	if [ ! -z "$2" ] && [ -z "$3" ] && [ -z "$4" ]
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
	elif [ ! -z "$3" ] && [ ! -z "$4" ]
	then
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
	else
	  print_usage
	fi
	;;
  -d)
	if [ ! -z "$2" ]
	then
	  if [ ! -e "$2" ]
	  then
  	    echo "VM $NAME deleted"
	  else
	    echo "VM $NAME not found"
	  fi
	else
	  print_usage
	fi
	;;
  -f)
	let RAM=5*1048576
	cd /opt
	sudo mkdir MacOSvm
	cd MacOSvm
	sudo git clone https://github.com/foxlet/macOS-Simple-KVM.git
	cd macOS-Simple-KVM
	sudo ./jumpstart.sh
	sudo qemu-img create -f qcow2 macOS.qcow2 50G
	sudo cd $ACTPATH
	sudo chmod ugo+rx basic.sh
	sudo chmod ugo+rx make.sh
	sudo cp basic.sh /opt/MacOSvm/macOS-Simple-KVM
	sudo cp make.sh /opt/MacOSvm/macOS-Simple-KVM
	sudo cp template.xml.in /opt/MacOSvm/macOS-Simple-KVM/tools
	cd /opt/MacOSvm/macOS-Simple-KVM
	sudo ./make.sh --add macOS-Simple-KVM $RAM
	sudo git checkout -- firmware/OVMF_VARS-1024x768.fd
	;;
  *)
	print_usage
	;;
esac
