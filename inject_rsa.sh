#!/bin/bash
set -x

# Required parameters for running this script
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "Usage : $0 <TARGET_MACHINE_SUDO_USER> <TARGET_MACHINE_SUDO_USER> <PASSWORD>"
        exit 1
fi


REMOTE_HOSTNAME_SUDO_USER=$1
REMOTE_HOSTNAME=$2
PASSWORD=$3

EXPECT1=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'sudo mkdir -p /root/.ssh/'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 1

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 1
interact
")

EXPECT2=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'sudo chmod 700 /root/.ssh'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 2

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 2
interact
")

sleep 2

EXPECT3=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'sudo touch /root/.ssh/authorized_keys'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 1

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 1
interact
")

EXPECT4=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'echo "ssh-rsa XXXXXXXXXXXXXXXX" | sudo tee --append /root/.ssh/authorized_keys'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 1

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 1
interact
")

EXPECT5=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'echo "ssh-rsa XXXXXXXXXXXXXXXXX" | sudo tee --append  /root/.ssh/authorized_keys'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 1

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 1
interact
")

EXPECT6=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'sudo chmod 600 /root/.ssh/authorized_keys'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 1

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 1
interact
")

ssh root@$2 'hostname'
if [ $? == 0 ] ; then
        echo "RSA key injection sucessful!!"
else
        echo "RSA key injection fail!!"
fi

exit 0
