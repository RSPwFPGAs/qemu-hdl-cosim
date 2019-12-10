#! /bin/bash

echo -e "\t Compiling the driver \n"
make clean
make
echo -e "\t Before loading. \n"
sudo rmmod pcie
lsmod | grep pcie
echo -e "\n\t **** Loading the pcie module \n"
sudo insmod pcie.ko
lsmod | grep pcie
dmesg | tail -30

