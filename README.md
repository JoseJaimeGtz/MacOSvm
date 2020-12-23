# MacOSvm Usage:
## first parameter
`-c` if you want to create a vm

`-d` if you want to delete a vm

## second parameter:

name of virtual machine. Ex: `myMacOSvm`

### third & fourth parameters (if you want to change Memory & RAM):

## third parameter:
Size of VM Memory. Ex: `100`
    
## fourth parameter:
Size of VM RAM. Ex: `5`
    
#### Output expected:
`sudo ./CreateMacOSvm.sh -c myMacOSvm 100 5`

OR

`sudo ./CreateMacOSvm.sh -c myMacOSvm`

Default VM spects:

Memory: 120G

RAM: 4G
