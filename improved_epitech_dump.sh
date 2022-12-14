#!/bin/sh

### Authors : rayan.mazouz@epitech.eu , louis.dupraz@epitech.eu

# Check if running as root.
if [ $UID -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

# Installing git, as some systems may not have it install right after install.
dnf install git -y --skip-broken

# Cloning the project, rendering useless other downloads from our github.
git clone https://github.com/rayan-mazouz/improved_epitech_dump.git

cd improved_epitech_dump/

# Adding new repos.
cp ./Repos/* /etc/yum.repos.d/

# Adding gpg keys.
cp ./rpm-gpg/* /etc/pki/rpm-gpg/

rpm --import https://copr-be.cloud.fedoraproject.org/results/phracek/PyCharm/pubkey.gpg
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-36-*
rpm --import https://dl.google.com/linux/linux_signing_key.pub
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-free-fedora-36
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-nonfree-fedora-36
rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Installing rpm fusion.
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y --skip-broken
dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y --skip-broken
dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-rawhide.noarch.rpm -y --skip-broken
dnf install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-rawhide.noarch.rpm -y --skip-broken

# Integration for KDE and GNOME.
dnf groupupdate core -y --skip-broken

# Add flathub remote.
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Change maximum parrallel downloads to 10.
echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf

# Refresh the repos, update the system.
dnf update --refresh -y --skip-broken

# Run dump script.
chmod +x dump.sh
./dump.sh

# Remove the conflicing packages (see doc :  https://linrunner.de/tlp/installation/fedora.html).
dnf remove power-profiles-daemon -y

# Install tlp (reduces battery usage).
dnf install tlp tlp-rdw -y --skip-broken
systemctl enable tlp

# Mask services to ensure proper operation of tlp-rwd.
systemctl mask systemd-rfkill.service systemd-rfkill.socket

# Refresh the repos, update the system.
dnf update --refresh -y --skip-broken

# Install wifi drivers for 5GHz wifi.
dnf install akmod-wl -y

# Check if an nvidia card is present.
if [ "$(lspci | grep NVIDIA)" != "" ]
  then
  # Add the fusionrpm repo which contains the nvidia akmods.
  dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm  -y --skip-broken

  # Install the nvidia akmods and its requirements.
  dnf install gcc kernel-headers kernel-devel akmod-nvidia nvidia-persistenced xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda  -y --skip-broken
  echo "Waiting for drivers to initialize (About 90s) ..."
  sleep 90

  # Force kmod compilation.
  akmods --force && dracut --force
fi

cd ..
rm -rf improved_epitech_dump

# Create folders for the coding style checkers and download it.
USERNAME=$(id -nu 1000)
sudo runuser -l "$USERNAME" -c 'git clone https://github.com/Epitech/coding-style-checker.git /home/"$USERNAME"/coding-style-checker'

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
