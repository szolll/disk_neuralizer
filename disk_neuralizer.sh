#!/bin/bash
# 
# Simple script that will destroy all data on the specified disk. Use with caution!
#
# Version: 2.3

# HELP message
usage() { 
  cat << EOF
Usage: Run the script as root and follow the onscreen instructions!
Options:
  -h, --help    Show this help message
EOF
}

# Check for flags
case "$1" in
  -h|--help) 
    usage
    exit
    ;;
esac

# Set output colors
ALERT_YELLOW="\033[0;33m%s\033[0m"
ALERT_RED="\033[0;31m%s\033[0m"
ALERT_GREEN="\033[0;32m%s\033[0m"

# Clear screen
clear

# Welcome message
printf "${ALERT_GREEN}Running the Disk Neuralyzer!\n"

# Warning about data destruction
printf "${ALERT_YELLOW}This program will destroy data on selected disks! Once data is lost, it cannot be recovered. Proceed with caution!\n\n"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
  printf "${ALERT_RED}Please run this script as root!\n"
  exit 1
fi

# Check if pv is installed; install if not
if ! dpkg -s pv &> /dev/null; then
  printf "\nPV not found. Installing...\n"
  apt update && apt install -y pv
fi

# List available disks, ignoring loop devices
printf "\nAvailable disks:\n"
lsblk | grep -v '^loop'

# Prompt user for the disk to wipe
printf "${ALERT_YELLOW}\nSelect the drive to wipe (no full path needed): "
read -r DISK2KILL

# Validate user input
if [[ -z "$DISK2KILL" ]]; then
  printf "${ALERT_RED}Error! Please provide the disk you want to wipe.\n"
  exit 1
fi

printf "\nPreparing to wipe disk: $DISK2KILL\n"

# Check if the disk is mounted
if grep -q "$DISK2KILL " /proc/mounts; then
  printf "${ALERT_RED}This disk is mounted. Please unmount it before running this script.\n"
  exit 1
fi

# Run badblocks check
if ! badblocks -e 1 -wsv /dev/"$DISK2KILL"; then
  printf "${ALERT_RED}Badblocks failed. Sensitive data may remain in badblocks!\n"
  exit 1
fi

# Wipe the disk with zeroes
printf "${ALERT_YELLOW}Wiping data...\n"
wipe -qrfc -F -Q 1 /dev/"$DISK2KILL"

# Data types to write
declare -a DATA_TYPES=("ones" "random data" "zeroes")
declare -A WRITE_COMMANDS=(
  ["ones"]="tr '\0' '\377' < /dev/zero | pv -prtb | dd of=/dev/$DISK2KILL status=progress bs=1M conv=noerror"
  ["random data"]="pv -tpreb /dev/urandom | dd of=/dev/$DISK2KILL status=progress bs=1M conv=noerror"
  ["zeroes"]="pv -tpreb /dev/zero | dd of=/dev/$DISK2KILL status=progress bs=1M conv=noerror"
)

# Loop through each data type and write to disk
for DATA_TYPE in "${DATA_TYPES[@]}"; do
  printf "${ALERT_YELLOW}Filling the disk with $DATA_TYPE until it's full...\n"
  
  if eval "${WRITE_COMMANDS[$DATA_TYPE]}"; then
    printf "${ALERT_GREEN}Successfully filled the disk with $DATA_TYPE.\n"
  else
    printf "${ALERT_RED}Failed to fill the disk with $DATA_TYPE. Please wipe it manually.\n"
  fi
done

printf "${ALERT_YELLOW}\nPlease verify the output of this script for any errors.\n"
