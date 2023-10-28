#!/bin/bash

# This script will install everything needed for flashing a 2020 Super Mario or 2021 Zelda Game & Watch on a Raspberry Pi.

# All that is needed is a clean Raspberry Pi OS (previously Rasbian) install on your Raspberry Pi.
 
# You can run the script directly on the Raspberry Pi or via SSH if you have a headless setup.

# If you plan on running the Raspberry Pi without a monitor and keyboard you can simply add a file called "ssh" to the root
# of the SD-card after you are done flashing the Raspberry Pi OS image to it with your computer, this will make the
# Raspberry Pi to activate ssh on the first boot.

# Make the script executable with "chmod +x gw-rpi-install-script.sh" and start it with ". gw-rpi-install-script.sh"
# Do NOT start it with "./" since that will make some of the variables not saved in the current session!
# 
# This script will install 'gnwmanager', which is the easiest way to flash images to your Game & Watch
# Information about gnwmanager can be found here: https://github.com/BrianPugh/gnwmanager 
#
# The last thing this script does is to run 'gnwmanager debug' as a sanity check. If your Game & Watch device is connected 
# it will check that the connection is working.
#
# This script is based on a script found here: https://github.com/TuKo1982/game-and-watch
# That script is based on a guide made by Test232 found at https://drive.google.com/file/d/1kGac4ohnkP8rjvv0B2MbsQpdZBbfyIty/view
#
# Thanks to kbeckmann, cyanic, DNA64 and the other people on the stacksmashing Discord for helping me to understand how the 
# excellent software made by them and stacksmashing works.

# Store the architecture 
arch=$(uname -m)

# Step number
step=1

# Directories
opt_dir="$HOME/opt/"

arm_gcc_version="12.3.1-1.2"
arm_gcc="xpack-arm-none-eabi-gcc-"$arm_gcc_version

# 64/32 bit options
if [ "$arch" == 'aarch64' ]
then
   arm_gcc_file=$arm_gcc"-linux-arm64.tar.gz"
else
   arm_gcc_file=$arm_gcc"-linux-arm.tar.gz"
fi

gcc_path="GCC_PATH="$opt_dir$arm_gcc"/bin/"
bash_file=$HOME"/.bashrc"

########################################################################################################################
# 1: sudo apt update
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Running <apt update>$(tput sgr 0)" ; echo
sudo apt update

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<apt update> ok!$(tput sgr 0)"  ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)" >&2
  return 1

fi

step=$((step+1))

########################################################################################################################
# 2: sudo apt upgrade -y
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Running <apt upgrade>$(tput sgr 0)" ; echo
sudo apt upgrade -y

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<apt upgrade> ok!$(tput sgr 0)" ; echo
else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  return 1

fi

step=$((step+1))

########################################################################################################################
# 3: sudo apt install -y binutils-arm-none-eabi python3 libftdi1 lz4 git npm
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Installing neccecary utilities$(tput sgr 0)" ; echo
sudo apt install -y binutils-arm-none-eabi python3 libftdi1 lz4 git npm

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)Utilities installed ok!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  return 1

fi

step=$((step+1))

########################################################################################################################
# 4: Install pipx
# sudo apt install -y pipx
# pipx ensurepath
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Installing pipx$(tput sgr 0)" ; echo
sudo apt install -y pipx
pipx ensurepath

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)Pipx installed ok!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  return 1

fi

step=$((step+1))

########################################################################################################################
# 5: Download arm-gcc
# mkdir -p ~/opt
# cd ~/opt
# wget https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v10.2.1-1.1/xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-arm.tar.gz
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Downloading <xpack-none-eabiarm-gcc>$(tput sgr 0)" ; echo
mkdir -p $opt_dir
cd $opt_dir
if [[ -f $arm_gcc_file || -d $opt_dir$arm_gcc ]]
then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<xpack-none-eabiarm-gcc> skipping, already downloaded ok!$(tput sgr 0)" ; echo
else
  wget https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v$arm_gcc_version/$arm_gcc_file

  if [ $? -eq 0 ]
  then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<xpack-none-eabiarm-gcc> downloaded ok!$(tput sgr 0)" ; echo

  else

  echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
    return 1

  fi
fi

step=$((step+1))

########################################################################################################################
# 6: tar xvf xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-arm.tar.gz xpack-arm-none-eabi-gcc-10.2.1-1.1 
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Extracting <xpack-none-eabiarm-gcc>$(tput sgr 0)" ; echo
cd $opt_dir
if [ -d $arm_gcc ]
then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<xpack-none-eabiarm-gcc> already extracted ok!$(tput sgr 0)" ; echo
else
  tar xvf $arm_gcc_file $arm_gcc 

  if [ $? -eq 0 ]
  then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<xpack-none-eabiarm-gcc> extracted ok!$(tput sgr 0)" ; echo

  else

  echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
    return 1
  fi
fi

step=$((step+1))

########################################################################################################################
# 7: rm xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-arm.tar.gz
########################################################################################################################

cd $opt_dir
if [ -e $arm_gcc_file ]
then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Cleaning up after extraction$(tput sgr 0)" ; echo
  rm $arm_gcc_file

  if [ $? -eq 0 ]
  then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)Clean up ok!$(tput sgr 0)" ; echo

  else

  echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
    return 1

  fi

  step=$((step+1))
fi

########################################################################################################################
# 8:
# export GCC_PATH=~/opt/xpack-arm-none-eabi-gcc-10.2.1-1.1/bin/
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Setting variables$(tput sgr 0)" ; echo
export $gcc_path

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)Variables set ok!$(tput sgr 0)" ; echo

step=$((step+1))

########################################################################################################################
# 9:
# echo export GCC_PATH=~/opt/xpack-arm-none-eabi-gcc-10.2.1-1.1/bin/ >>~/.bashrc
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Saving variables$(tput sgr 0)" ; echo

# Remove existing entries if found
sed -i "/^export GCC_PATH=/d" $bash_file

# Add entries
echo export $gcc_path >>$bash_file

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)Variables saved ok!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  return 1

fi

step=$((step+1))

########################################################################################################################
# 10: pipx install gnwmanager
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Installing gnwmanager$(tput sgr 0)" ; echo
pipx install gnwmanager

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)gnwmanager installed ok!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  return 1

fi

step=$((step+1))

########################################################################################################################
# 11: gnwmanager install openocd
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Installing openocd with gnwmanager$(tput sgr 0)" ; echo
gnwmanager install openocd

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)openocd installed ok!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  return 1

fi

step=$((step+1))

########################################################################################################################
# 12: sudo apt install -y imagemagick
# Used to build the Game & Watch rom files
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Installing Imagemagik$(tput sgr 0)" ; echo
sudo apt install -y imagemagick

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)Imagemagik installed ok!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  return 1

fi

step=$((step+1))

########################################################################################################################
# 13: gnwmanager debug
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Running <gnwmanager debug> check$(tput sgr 0)" ; echo
gnwmanager debug

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)Everything installed and check ok, you seem to be ready to start making a backup of your device!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  return 1

fi
