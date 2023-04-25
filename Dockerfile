FROM debian:11.6-slim

ARG USERNAME=thomas

# Install SSH server and net-tools
RUN apt update && apt install -y \
    openssh-server \
    net-tools \
    sudo

# Create the privilege separation directory for sshd
RUN mkdir -p /run/sshd && \
    chmod 0755 /run/sshd

# Create user with home directory, bash shell, and add to sudoers
RUN useradd -m -d /home/$USERNAME -s /bin/bash -G sudo $USERNAME

# Set password for the user
RUN echo "$USERNAME:$USERNAME" | chpasswd

# Configure sshd to disallow root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Expose the SSH port
EXPOSE 22

# Start the SSH server
CMD ["/usr/sbin/sshd", "-D"]
