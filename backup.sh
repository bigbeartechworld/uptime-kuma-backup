#!/bin/bash

# File prefix
file_prefix="uptime_kuma_backup_"

# Directory to store the backups
backup_directory="./backups"

# File name
file_name="$file_prefix$(date +%Y%m%d_%H%M%S).zip"

# File to store the SSH IP address
ip_file="ssh_ip.txt"

# File to store the SSH password
password_file="ssh_password.txt"

# Check if the ssh ip file exists
if [ -f "$ip_file" ]; then
    # Read the password from the file
    ip_address=$(cat "$ip_file")
else
    # Prompt for SSH ip
    read -s -p "Enter SSH IP: " ip_address
    echo

    # Save the ip to the file
    echo "$ip_address" > "$ip_file"
fi

# SSH server details
ssh_server="root@$ip_address"

# Check if the password file exists
if [ -f "$password_file" ]; then
    # Read the password from the file
    ssh_password=$(cat "$password_file")
else
    # Prompt for SSH password
    read -s -p "Enter SSH password: " ssh_password
    echo

    # Save the password to the file
    echo "$ssh_password" > "$password_file"
fi

# Sync the data directory from the SSH server
sshpass -p "$ssh_password" rsync -avz "$ssh_server:/opt/uptime-kuma/data" ./

# Zip up the data directory
zip -r "$file_name" ./data

# Check if the directory exists
if [ -d "$backup_directory" ]; then
    echo "Destination directory exists. Moving file..."
else
    echo "Destination directory does not exist. Creating..."
    mkdir -p "$backup_directory"
fi

# Maximum time to wait in seconds
timeout_duration=300

# Move the file
# Start the timeout countdown
timeout $timeout_duration bash -c "
    # Loop until the file exists or timeout occurs
    while [ ! -f '$file_name' ]; do
        sleep 1
    done

    # File exists! Move it to the destination directory
    mv '$file_name' '$backup_directory'
"

# Remove the data directory
rm -rf ./data
