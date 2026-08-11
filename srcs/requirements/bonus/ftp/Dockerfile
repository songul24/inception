FROM debian:bookworm


#install vsftpd(very secure FTP daemon)
RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp.sh /ftp.sh
RUN chmod +x /ftp.sh



CMD ["/ftp.sh"]