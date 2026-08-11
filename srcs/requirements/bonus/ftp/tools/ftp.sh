#!/bin/bash

# vsftpd's privilege-separation process needs this directory to exist
mkdir -p /var/run/vsftpd/empty

# Create the FTP user, home dir = same volume WordPress uses
if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd -d /var/www/wordpress -s /bin/bash "$FTP_USER"
fi

# Set the FTP user's password
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# Set ownership of the WordPress directory to the FTP user
chown -R "$FTP_USER":"$FTP_USER" /var/www/wordpress

exec vsftpd /etc/vsftpd.conf