#!/bin/bash

# ANSI color codes
ALERT_YELLOW="\033[0;33m"
ALERT_RED="\033[0;31m"
ALERT_GREEN="\033[0;32m"
COLOR_RESET="\033[0m"

# HELP message
usage() { 
    printf "${ALERT_YELLOW}Usage: Run the script as root, and follow onscreen instructions!\n
    Options:
    -h        Show this message${COLOR_RESET}\n"
}

# Check for flags
case "$1" in
  -h|--help) usage
   exit
   ;;
esac

# Clear screen
clear

# Print welcome message
printf "${ALERT_GREEN}Running the standard issue Disk Neuralyzer!${COLOR_RESET}\n"

# Inform the user of the terrible consequences
printf "${ALERT_YELLOW}Please be aware that this program will destroy data on selected disks! Once data is lost, it's lost. Be careful or be sorry!${COLOR_RESET}\n\n"

# Check for root / Running as root
if [ "$EUID" -ne 0 ]; then 
  printf "${ALERT_RED}Run me as root please!${COLOR_RESET}\n\n"
  exit
fi

# Function to check if a disk is a system disk or in use
is_system_or_used_disk() {
    local disk="$1"
    if mount | grep -q "/dev/$disk"; then
        return 0 # Disk is mounted
    fi
    # Additional checks can be added here (e.g., RAID, LVM)
    return 1 # Not a system or used disk
}

# Function to display progress
wipe_disk() {
    local disk="$1"
    printf "${ALERT_GREEN}Wiping $disk...${COLOR_RESET}\n"
    # Wipe process with progress indication
    pv -tpreb /dev/zero | dd of=/dev/"$disk" status=progress bs=1M
    printf "${ALERT_GREEN}Wipe complete for $disk.${COLOR_RESET}\n"
}

# Function to handle multiple disks
wipe_disks() {
    for disk in "$@"; do
        if is_system_or_used_disk "$disk"; then
            printf "${ALERT_RED}Skipping $disk as it is a system or used disk.${COLOR_RESET}\n"
            continue
        fi
        # Confirmation for each disk
        read -p "Confirm wiping $disk (yes/no): " confirmation
        if [ "$confirmation" = "yes" ]; then
            wipe_disk "$disk"
        else
            printf "${ALERT_YELLOW}Skipped $disk.${COLOR_RESET}\n"
        fi
    done
}

# Display available disks with details
printf "${ALERT_YELLOW}Available Disks:${COLOR_RESET}\n"
lsblk -d -o NAME,SIZE,MODEL | grep -v '^loop'
printf "${ALERT_YELLOW}\nSelect the disks for wiping. Enter disk names separated by space.${COLOR_RESET}\n"

# Read user input for disks
read -r -a disks_to_wipe

# Check if any disk is provided
if [ ${#disks_to_wipe[@]} -eq 0 ]; then
    printf "${ALERT_RED}No disks specified. Exiting.${COLOR_RESET}\n"
    exit 1
fi

# Call the wipe_disks function with all disk arguments
wipe_disks "${disks_to_wipe[@]}"

# End of script
