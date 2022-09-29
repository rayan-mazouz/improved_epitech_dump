#!/bin/sh

### Author : rayan.mazouz@epitech.eu , louis.dupraz@epitech.eu

### This script sole purpose is to install nvidia drivers. If you need a full install of the Epitech dump, please use the improved_epitech_dump.sh script.

# Check if running as root
if [ $UID -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

# Check if an nvidia card is present
if [ "$(lspci | grep NVIDIA)" == "" ]
  then echo "No Nvidia card detected"
  exit 1
fi

# Solve microsoft teams gpg key problem for fedora, Epitech build
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
# Add the fusionrpm repo which contains the nvidia akmods
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# Refresh the repos, update the packets and the kernel
sudo dnf update -y
# Install the nvidia akmods and its requirements
sudo dnf install gcc kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda
echo "Waiting for drivers to initialize (About 90s) ..."
sleep 90
# Force kmod compilation
sudo akmods --force && sudo dracut --force

# Allow the user to chose between restarting now and posponing it
while [ true ] ; do
  printf "\nPress R to reboot now or X to quit and reboot later\n"
  read -n 1 k
  if [ $k = "x" ] ; then
    printf "\nPlease reboot later to complete installation\n"
    exit 0
  elif [ $k = "r" ] ; then
    printf "\nSystem will reboot in 5 seconds\n"
    sleep 5
    sudo reboot
  fi
done
