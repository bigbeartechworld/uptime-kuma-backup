#!/bin/bash

# Check for required commands
for cmd in rsync zip sshpass; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: '$cmd' is not installed." >&2
        exit 1
    fi
done

# Local directory where the file is located
local_directory="./backups"

# Remote directory where the file will be copied
remote_directory="/opt/uptime-kuma/data"

# File to store the SSH IP address
ip_file="ssh_ip.txt"

# File to store the SSH password
password_file="ssh_password.txt"

# Check if the ssh ip file exists
if [ -f "$ip_file" ]; then
    # Read the ip from the file
    ip_address=$(cat "$ip_file")
else
    # Prompt for SSH IP
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

export SSHPASS="$ssh_password"

# Check if rsync is installed on the remote server
if ! sshpass -e ssh "$ssh_server" command -v rsync &>/dev/null; then
    echo "Error: 'rsync' is not installed on the remote server ($ssh_server)."

    # Ask the user if they want to install rsync
    read -p "Would you like to install rsync on the remote server? (yes/no) " response
    if [[ "$response" == "yes" ]]; then
        echo "Installing rsync on the remote server..."
        sshpass -e ssh "$ssh_server" 'apt-get update && apt-get install -y rsync'
        if [ $? -ne 0 ]; then
            echo "Failed to install rsync on the remote server."
            exit 1
        fi
        echo "rsync has been successfully installed on the remote server."
    else
        echo "rsync installation aborted. Exiting."
        exit 1
    fi
fi

# Delete .uptime-kuma-restore directory if it exists
rm -rf ./.uptime-kuma-restore

# Prompt user to select a backup file
echo "Available backup files:"
backup_files=($(ls -t "$local_directory"/*.zip))

# Check if any backup files exist
if [ ${#backup_files[@]} -eq 0 ]; then
    echo "No backup files found in the directory."
    exit 1
fi

# Show the list of backup files
PS3="Enter the number of the backup file you want to select: "
select backup_file in "${backup_files[@]}"; do
    if [ -n "$backup_file" ]; then
        echo "You selected: $backup_file"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Get the backup file name
backup_file_name=$(basename "$backup_file")

# Copy file from backups to current directory
cp "$backup_file" ./

# Unzip the file
unzip "$backup_file" -d "./.uptime-kuma-restore"

# Delete data directory if it exists from ssh
sshpass -e ssh "$ssh_server" "rm -rf /opt/uptime-kuma/data"

# Rsync the latest file to the SSH server with password authentication
sshpass -e rsync -avz "./.uptime-kuma-restore/data/" "$ssh_server:$remote_directory"

# Set permissions and restart the service
sshpass -e ssh "$ssh_server" "chown -R root:root $remote_directory && cd $remote_directory && service uptime-kuma restart"

# Remove the .uptime-kuma-restore directory
rm -rf ./.uptime-kuma-restore

# Remove the zip file
rm "$backup_file_name"
