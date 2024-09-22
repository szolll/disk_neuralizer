# Disk Neuralyzer

The Disk Neuralyzer is a Bash script designed to securely destroy all data on a specified disk by overwriting it with multiple patterns (ones, random data, and zeroes). This process complies with NIST Special Publication 800-88 guidelines for data sanitization.

# Important Notes

Data Loss: This script will permanently erase all data on the specified disk. Use with caution.
Unmount Disk: Ensure that the target disk is unmounted before running the script.
Root Privileges: The script requires root privileges to execute.
Requirements
Operating System: Linux
Dependencies: The script will install the pv utility if it is not already present on the system.

# Usage

## Install
Clone the Repository (if applicable):

git clone [repository-url]
cd [repository-directory]

Make the Script Executable:

chmod +x disk_neuralyzer.sh

## Run

Run the Script as Root:

sudo ./disk_neuralyzer.sh

Follow the Onscreen Instructions to select the disk to wipe.

# License
This script is provided "as is" without any warranty. Redistribution or modification of this script is not permitted without explicit permission from the author. The author is not liable for any damages resulting from the use of this script.

## Author
Daniel Sol
https://github.com/szolll/
Date
2024
