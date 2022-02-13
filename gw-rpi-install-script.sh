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
# The last thing this script does is to run the game-and-watch-backup sanity check script, after that  you will have to follow
# the guides on https://github.com/ghidraninja/game-and-watch-backup
#
# This script is based on a guide made by Test232 found at https://drive.google.com/file/d/1kGac4ohnkP8rjvv0B2MbsQpdZBbfyIty/view
#
# Thanks to kbeckmann, cyanic, DNA64 and the other people on the stacksmashing Discord for helping me to understand how the 
# excellent software made by them and stacksmashing works.

# Store the architecture 
arch=$(uname -m)

# Step number
step=1

# Directories
opt_dir="$HOME/opt/"

gnw_backup_dir="game-and-watch-backup"
gnw_backup_path=$opt_dir$gnw_backup_dir

ubuntu_openocd_git_builder_dir="ubuntu-openocd-git-builder"
openocd_builder_dir=$opt_dir$ubuntu_openocd_git_builder_dir

# 64/32 bit options
if [ "$arch" == 'aarch64' ]
then
   arm_gcc="xpack-arm-none-eabi-gcc-10.3.1-2.3"
   arm_gcc_file=$arm_gcc"-linux-arm64.tar.gz"
else
   arm_gcc="xpack-arm-none-eabi-gcc-10.2.1-1.1"
   arm_gcc_file=$arm_gcc"-linux-arm.tar.gz"
fi


gcc_path="GCC_PATH="$opt_dir"/"$arm_gcc"/bin/"
adapter_caps="ADAPTER=rpi"
adapter_lower="adapter=rpi"
# xpack installed OPENOCD
#openocd_path="OPENOCD="$HOME"/.local/xPacks/@xpack-dev-tools/openocd/0.11.0-1.1/.content/bin/openocd"
# kbeckman custom OPENOCD (to access 256K internal memory)
openocd_path_file="/opt/openocd-git/bin/openocd" 
openocd_path="OPENOCD="$openocd_path_file

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
  exit 1

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
  exit 1

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
  exit 1

fi

step=$((step+1))

########################################################################################################################
# 4: sudo npm install -y -global xpm@latest
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Installing xpm$(tput sgr 0)" ; echo
sudo npm install -y -global xpm@latest

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)xpm installed ok!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  exit 1

fi

step=$((step+1))

########################################################################################################################
# 5: xpm install --global @xpack-dev-tools/openocd@latest
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Installing openocd from xpack$(tput sgr 0)" ; echo
xpm install --global @xpack-dev-tools/openocd@latest

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)Openocd from xpack installed ok!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  exit 1

fi

########################################################################################################################
# 6: Download arm-gcc
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
  wget https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/download/v10.3.1-2.3/$arm_gcc_file

  if [ $? -eq 0 ]
  then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<xpack-none-eabiarm-gcc> downloaded ok!$(tput sgr 0)" ; echo

  else

  echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
    exit 1

  fi
fi

step=$((step+1))

########################################################################################################################
# 7: tar xvf xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-arm.tar.gz xpack-arm-none-eabi-gcc-10.2.1-1.1 
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
    exit 1
  fi
fi

step=$((step+1))

########################################################################################################################
# 8: rm xpack-arm-none-eabi-gcc-10.2.1-1.1-linux-arm.tar.gz
########################################################################################################################

cd $opt_dir
if [ -d $arm_gcc_file ]
then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Cleaning up after extraction$(tput sgr 0)" ; echo
  rm $arm_gcc_file

  if [ $? -eq 0 ]
  then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)Clean up ok!$(tput sgr 0)" ; echo

  else

  echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
    exit 1

  fi

  step=$((step+1))
fi

########################################################################################################################
# 9:
# export GCC_PATH=~/opt/xpack-arm-none-eabi-gcc-10.2.1-1.1/bin/
# export ADAPTER=rpi
# export adapter=rpi
# export OPENOCD=~/.local/xPacks/@xpack-dev-tools/openocd/0.11.0-1.1/.content/bin/openocd
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Setting variables$(tput sgr 0)" ; echo
export $gcc_path
export $adapter_caps
export $adapter_lower
export $openocd_path

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)Variables set ok!$(tput sgr 0)" ; echo

step=$((step+1))


########################################################################################################################
# 10:
# echo export GCC_PATH=~/opt/xpack-arm-none-eabi-gcc-10.2.1-1.1/bin/ >>~/.bashrc
# echo export ADAPTER=rpi >>~/.bashrc
# echo export adapter=rpi >>~/.bashrc
# echo export OPENOCD=~/.local/xPacks/@xpack-dev-tools/openocd/0.11.0-1.1/.content/bin/openocd >>~/.bashrc
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Saving variables$(tput sgr 0)" ; echo

# Remove existing entries if found
sed -i "/^export GCC_PATH=/d" $bash_file
sed -i "/^export ADAPTER=/d" $bash_file
sed -i "/^export adapter=/d" $bash_file
sed -i "/^export OPENOCD=/d" $bash_file

# Add entries
echo export $gcc_path >>$bash_file
echo export $adapter_caps >>$bash_file
echo export $adapter_lower >>$bash_file
echo export $openocd_path >>$bash_file

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)Variables saved ok!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  exit 1

fi

step=$((step+1))

########################################################################################################################
# 11: Clone
# cd ~/opt
# git clone https://github.com/kbeckmann/ubuntu-openocd-git-builder.git
########################################################################################################################

if [ -d $openocd_builder_dir ]
then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Dir found skipping Cloning <ubuntu-openocd-git-builder>$(tput sgr 0)" ; echo
else 
  cd $opt_dir
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Cloning <ubuntu-openocd-git-builder>$(tput sgr 0)" ; echo
  git clone https://github.com/kbeckmann/ubuntu-openocd-git-builder.git

  if [ $? -eq 0 ]
  then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<ubuntu-openocd-git-builder> cloned ok!$(tput sgr 0)" ; echo

  else

  echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
    exit 1

  fi
fi 

step=$((step+1))

########################################################################################################################
# 11: Build
# cd ~/opt
# git clone https://github.com/kbeckmann/ubuntu-openocd-git-builder.git
########################################################################################################################

cd $opt_dir
if [ -f $openocd_path_file ]
then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<openocd_path_file> Already built ok!$(tput sgr 0)" ; echo
else 
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Building <openocd_path_file>$(tput sgr 0)" ; echo
  cd $ubuntu_openocd_git_builder_dir
  ./build.sh
  sudo dpkg -i openocd-git_*_arm*.deb
  sudo apt-get -y -f install

  if [ $? -eq 0 ]
  then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<openocd_path_file> Built ok!$(tput sgr 0)" ; echo

  else

  echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
    exit 1

  fi
fi

########################################################################################################################
# 11:
# cd ~/opt
# git clone https://github.com/ghidraninja/game-and-watch-backup.git
########################################################################################################################

if [ -d $gnw_backup_path ]
then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Already cloned <game-and-watch-backup>$(tput sgr 0)" ; echo
else 
  cd ~/opt
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Cloning <game-and-watch-backup>$(tput sgr 0)" ; echo
  git clone https://github.com/ghidraninja/game-and-watch-backup.git

  if [ $? -eq 0 ]
  then
  echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)<game-and-watch-backup> cloned ok!$(tput sgr 0)" ; echo

  else

  echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
    exit 1

  fi
fi 

step=$((step+1))

########################################################################################################################
#15 
# cd ~/opt/game-and-watch-backup
# ./1_sanity_check.sh
########################################################################################################################

echo "$(tput setaf 5)$(tput bold)$(tput smul)$(tput cuf 20)$step: Running <game-and-watch-backup> sanity check$(tput sgr 0)" ; echo
cd $gnw_backup_path
./1_sanity_check.sh rpi mario

if [ $? -eq 0 ]
then
echo "$(tput setaf 5)$(tput bold)$(tput smul)Everything installed and sanity check ok, your seem to be ready to start making a backup of your device!$(tput sgr 0)" ; echo

else

echo "$(tput setab 1)$(tput setaf 3)$(tput bold)$(tput smul)$(tput cuf 20)Something went wrong!$(tput sgr 0)"  >&2
  exit 1

fi
