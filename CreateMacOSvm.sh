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
	if ( [ ! -e "/run/media/nishikawa/Nishikawa/MacOSvm" ] || [ ! -e "/run/media/nishikawa/Nishikawa/MacOSvm/macOS-Simple-KVM" ] ) && [ ! -z "$2" ]
	then
		sudo chmod ugo+rx basic.sh
		sudo chmod ugo+rx make.sh
		cd /run/media/nishikawa/Nishikawa
		let RAM=4*1048576
		sudo mkdir MacOSvm
		cd MacOSvm
		sudo git clone https://github.com/foxlet/macOS-Simple-KVM.git
		cd macOS-Simple-KVM
		sudo ./jumpstart.sh
		sudo qemu-img create -f qcow2 macOS.qcow2 120G
		sudo rm -rf basic.sh
		sudo rm -rf make.sh
		cd tools
		sudo rm -rf template.xml.in
		cd $ACTPATH
		sudo cp basic.sh /run/media/nishikawa/Nishikawa/MacOSvm/macOS-Simple-KVM
		sudo cp make.sh /run/media/nishikawa/Nishikawa/MacOSvm/macOS-Simple-KVM
		sudo cp template.xml.in /run/media/nishikawa/Nishikawa/MacOSvm/macOS-Simple-KVM/tools
		cd /run/media/nishikawa/Nishikawa/MacOSvm/macOS-Simple-KVM
		sudo ./make.sh --add $NAME $RAM
		sudo git checkout -- firmware/OVMF_VARS-1024x768.fd
		echo "VM created"
	elif [ ! -z "$2" ] && [ -z "$3" ] && [ -z "$4" ]
	then
	  let RAM=4*1048576
	  if [ ! -e "/run/media/nishikawa/Nishikawa/MacOSvm/$NAME" ]
	  then
	    sudo cp -r /run/media/nishikawa/Nishikawa/MacOSvm/macOS-Simple-KVM /run/media/nishikawa/Nishikawa/MacOSvm/$NAME
	  fi
	  cd /run/media/nishikawa/Nishikawa/MacOSvm/$NAME
	  sudo git checkout -- firmware/OVMF_VARS-1024x768.fd
	  sudo ./make.sh --add $NAME $RAM
	  echo "Default VM Created!"
	elif [ ! -z "$3" ] && [ ! -z "$4" ]
	then
	  let RAM=$3*1048576
	  if [ ! -e "/run/media/nishikawa/Nishikawa/MacOSvm/$NAME" ]
	  then
	    sudo cp -r /run/media/nishikawa/Nishikawa/MacOSvm/macOS-Simple-KVM /run/media/nishikawa/Nishikawa/MacOSvm/$NAME
	  fi
	  cd /run/media/nishikawa/Nishikawa/MacOSvm/$NAME
	  sudo git checkout -- firmware/OVMF_VARS-1024x768.fd
	  sudo rm -rf macOS.qcow2
	  qemu-img create -f qcow2 macOS.qcow2 ${MEM}G
	  sudo ./make.sh --add $NAME $RAM
	  echo "New VM Created!"
	else
	  print_usage
	fi
	;;
  -d)
	cd /run/media/nishikawa/Nishikawa/MacOSvm
	if [ ! -z "$2" ]
	then
	  if [ -e "$2" ]
	  then
		sudo rm -rf $NAME
  	    echo "VM $NAME deleted"
	  else
	    echo "VM $NAME not found"
	  fi
	else
	  print_usage
	fi
	;;
  *)
	print_usage
	;;
esac
