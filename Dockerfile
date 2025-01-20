# Use an official lightweight Linux image
FROM ubuntu:20.04

# Set non-interactive mode for apt commands
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt update && apt install -y \
    openssh-server \
    inotify-tools \
    curl \
    && apt clean

# Create SFTP root directory
RUN mkdir -p /sftp && chmod 755 /sftp

# Add SSH configuration for SFTP
RUN echo "Match Group sftpusers\n\
    ChrootDirectory /sftp/%u\n\
    ForceCommand internal-sftp\n\
    AllowTcpForwarding no\n\
    X11Forwarding no" >> /etc/ssh/sshd_config

# Create SFTP user group
RUN groupadd sftpusers

# Add the webhook monitoring script
COPY sftp-webhook.sh /usr/local/bin/sftp-webhook.sh
RUN chmod +x /usr/local/bin/sftp-webhook.sh

# Add the script for dynamically adding users
COPY add-sftp-user.sh /usr/local/bin/add-sftp-user.sh
RUN chmod +x /usr/local/bin/add-sftp-user.sh

# Expose the SSH port
EXPOSE 22

# Start SSH service and the webhook script, then keep the container running
CMD /bin/bash -c "service ssh start && /usr/local/bin/sftp-webhook.sh & tail -f /dev/null"
