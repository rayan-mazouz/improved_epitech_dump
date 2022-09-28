#!/bin/sh

### Authors : rayan.mazouz@epitech.eu , louis.dupraz@epitech.eu

# Check if running as root.
if [ $UID -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

# Download dump script.
curl -O https://gitlab.com/EpitechContent/dump/-/raw/master/install_packages_dump.sh

# Run dump script.
chmod +x install_packages_dump.sh
./install_packages_dump.sh

# Import Microsoft gpg keys.
rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Add flathub remote.
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Change maximum parrallel downloads to 10.
echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf

# Enable cutefish-desktop copr repo.
dnf copr enable rmnscnce/cutefish-desktop -y

# Refresh the repos, update the system.
dnf update --refresh -y

# Install tlp (reduces battery usage).
dnf install tlp tlp-rdw -y
systemctl enable tlp

# Install fastfetch and its dependencies.
dnf install glibc libpci libvulkan https://github.com/LinusDierheimer/fastfetch/releases/download/1.7.2/fastfetch-1.7.2-Linux.rpm  -y

# Check if kde plasma flag is set
if [ "$2" == "kde" || "$2" == "plasma" ]; then
  # Install KDE Plasma desktop environnement
  dnf groupinstall -y "KDE Plasma Workspaces"
else
  # Install cutefish-desktop.
  dnf install cutefish-desktop  -y
fi

# Add fastfetch to bashrc.
echo "fastfetch" >> /home/*/.bashrc

# Check if xanmod flag is set.
if [ "$1" == "xanmod" ]; then
  # Enable XanMod kernel copr repo.
  dnf copr enable rmnscnce/kernel-xanmod -y
  
  # Install XanMod kernel.
  dnf install kernel-xanmod-edge -y
fi

# Check if an nvidia card is present.
if [ "$(lspci | grep NVIDIA)" != "" ]
  then
  # Add the fusionrpm repo which contains the nvidia akmods.
  dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm  -y

  # Install the nvidia akmods and its requirements.
  dnf install gcc kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686 xorg-x11-drv-nvidia-cuda  -y
  echo "Waiting for drivers to initialize (About 90s) ..."
  sleep 90

  # Force kmod compilation.
  akmods --force && dracut --force
fi

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
