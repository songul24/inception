#!/bin/bash



# Create the socket/runtime directory MariaDB needs before it can start
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Only initialize the data directory if it hasn't been done before
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

fi

# Run SQL commands in bootstrap mode to create DB and users
mysqld --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF

exec mariadbd --user=mysql




# GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';


# #!/bin/bash
# set -e

# # Runtime directory MariaDB needs / give ownership to mysql
# mkdir -p /run/mysqld
# chown -R mysql:mysql /run/mysqld



# # Initialize MariaDB only once
# # if [ ! -d "/var/lib/mysql/mysql" ]; then
    
#     mysql_install_db --user=mysql --datadir=/var/lib/mysql

#     # Start MariaDB temporarily in the background
#     mysqld --user=mysql &
#     MYSQL_PID=$!

#     # Wait until MariaDB is ready
#     until mysqladmin ping --silent; do
#         sleep 1
#     done

#     # Configure MariaDB
#     # mysql -u root <<EOF
#     mariadb -uroot --protocol=SOCKET <<EOF
# ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
# CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
# CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
# GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
# FLUSH PRIVILEGES;
# EOF

#     # Stop the temporary MariaDB server
#     mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

#     # Wait until it has completely exited
#     wait $MYSQL_PID
# # fi

# # Start the real MariaDB server as PID 1
# exec mysqld --user=mysql