#!/bin/bash

OSK="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
VMDIR=$PWD
OVMF=$VMDIR/firmware
#export QEMU_AUDIO_DRV=pa
#QEMU_AUDIO_DRV=pa
br=mcbridge
tp=mctap
nw=mcnet
cleanup(){
          nmcli connection del $br $tp $nw
          killall dhclient
}
trap cleanup EXIT


#BRIDGED NETWORKING
nmcli connection add type bridge ifname br1 con-name $br
nmcli connection add type bridge-slave ifname eno1 con-name $nw master br1
nmcli connection add type tun ifname tap0 con-name $tp mode tap owner $(id -u)
nmcli connection mod $tp connection.slave-type bridge connection.master br1
nmcli con up $nw
nmcli con up $br
nmcli con up $tp
dhclient br1
nmcli connection show
NET="-netdev tap,id=net0,ifname=tap0,script=no,downscript=no"
#NET="-netdev user,id=mynet0 -device rtl8139,netdev=mynet0"
#NET="-netdev tap,id=net0,ifname=tap0,netdev=net0"

NDV="-device vmxnet3,netdev=net0,id=net0,mac=52:54:00:c9:18:27"
#NDV="-device rtl8139,netdev=net0,id=net0,mac=52:54:00:c9:18:27"
#NDV= ""

qemu-system-x86_64 \
    -enable-kvm \
    -m 5G \
    -machine q35,accel=kvm \
    -smp 4,cores=2 \
    -cpu Penryn,vendor=GenuineIntel,kvm=on,+sse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc \
    -device isa-applesmc,osk="$OSK" \
    -smbios type=2 \
    -drive if=pflash,format=raw,readonly,file="$OVMF/OVMF_CODE.fd" \
    -drive if=pflash,format=raw,file="$OVMF/OVMF_VARS-1024x768.fd" \
    -vga qxl \
    -device ich9-intel-hda -device hda-output \
    -usb -device usb-kbd -device usb-mouse \
    $NET \
    $NDV \
    -netdev user,id=net0 \
    -device e1000e,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
    -device ich9-ahci,id=sata \
    -drive id=ESP,if=none,format=qcow2,file=ESP.qcow2 \
    -device ide-hd,bus=sata.2,drive=ESP \
    -drive id=InstallMedia,format=raw,if=none,file=BaseSystem.img \
    -device ide-hd,bus=sata.3,drive=InstallMedia \
    -drive id=SystemDisk,if=none,file=macOS.qcow2 \
    -device ide-hd,bus=sata.4,drive=SystemDisk \
