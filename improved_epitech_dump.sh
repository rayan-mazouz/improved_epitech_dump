#!/bin/sh

### Authors : rayan.mazouz@epitech.eu , louis.dupraz@epitech.eu

# Check if running as root.
if [ $UID -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

# Installing git, as some systems may not have it install right after install.
dnf install git -y

# Cloning the project, rendering useless other downloads from our github.
git clone https://github.com/rayan-mazouz/improved_epitech_dump.git

cd improved_epitech_dump/

# Adding new repos.
cp ./Repos/* /etc/yum.repos.d/

# Add flathub remote.
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Change maximum parrallel downloads to 10.
echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf

# Refresh the repos, update the system.
dnf update --refresh -y

# Run dump script.
chmod +x dump.sh
./dump.sh

# Remove the conflicing packages (see doc :  https://linrunner.de/tlp/installation/fedora.html )
dnf remove power-profiles-daemon -y

# Install tlp (reduces battery usage).
dnf install tlp tlp-rdw -y
systemctl enable tlp

# Mask services to ensure proper operation of tlp-rwd
systemctl mask systemd-rfkill.service systemd-rfkill.socket

# Refresh the repos, update the system.
dnf update --refresh -y

# Check if an nvidia card is present.
if [ "$(lspci | grep NVIDIA)" != "" ]
  then
  # Add the fusionrpm repo which contains the nvidia akmods.
  dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm  -y

  # Install the nvidia akmods and its requirements.
  dnf install gcc kernel-headers kernel-devel akmod-nvidia nvidia-persistenced xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda  -y
  echo "Waiting for drivers to initialize (About 90s) ..."
  sleep 90

  # Force kmod compilation.
  akmods --force && dracut --force
fi

cd ..
rm -rf improved_epitech_dump

# Allow the user to chose between restarting now and posponing it.
while [ true ] ; do

  printf "\nPress 'r' to reboot now or 'x' to quit and reboot later\n"
  read -n 1 k

  if [ $k = "x" ]
    then printf "\nPlease reboot later to complete installation\n"
    exit 0
  elif [ $k = "r" ]
    then printf "\nSystem will reboot in 5 seconds\n"
    sleep 5
    reboot
  fi
done
