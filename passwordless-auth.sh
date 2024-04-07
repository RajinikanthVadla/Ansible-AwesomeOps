#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Create the ansible user
useradd -m ansible

# Set password for ansible user
echo "ansible:ansible" | chpasswd

# Modify SSH server configuration to allow root login and password authentication
sed -i 's/^PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Allow ansible user passwordless sudo
echo "ansible     ALL=(ALL)     NOPASSWD: ALL" | tee -a /etc/sudoers.d/ansible

# Restart SSH service
systemctl restart sshd

# Switch to ansible user
su - ansible <<EOF

# Generate SSH keys without passphrase
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa

# Restart SSH service again
sudo service sshd restart

EOF

echo "Passwordless authentication has been configured for the ansible user."
