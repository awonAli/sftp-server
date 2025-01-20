#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: $0 <username> [password]"
  exit 1
fi

USERNAME=$1
PASSWORD=${2:-$(openssl rand -base64 12)}  # Generate random password if not provided
USER_DIR="/sftp/$USERNAME/uploads"

# Add the user and set their password
useradd -m -G sftpusers -s /sbin/nologin "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

# Create the user's directory
mkdir -p "$USER_DIR"
chown "$USERNAME":sftpusers "$USER_DIR"
chmod 700 "$USER_DIR"

echo "User $USERNAME added successfully with password: $PASSWORD"
echo "Upload directory: $USER_DIR"
