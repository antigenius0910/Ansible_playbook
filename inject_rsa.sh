#!/bin/sh 
set -x

REMOTE_HOSTNAME_SUDO_USER=$1
REMOTE_HOSTNAME=$2
PASSWORD=$3

EXPECT0=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'hostname'"

expect \"(yes/no)\"
send \"yes\r\"
set timeout 1
expect \"password:\"
send \"$PASSWORD\r\"
set timeout 1
")

EXPECT1=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'sudo mkdir -p /root/.ssh/'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 1

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 1
send \"logout\"
")

EXPECT2=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'sudo chmod 700 /root/.ssh'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 2

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 2
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
")

EXPECT4=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFyWFt1Ul7QsmZtw9MQcoRdajbQssv0izv9AboIOLeEmm0xAWpV7aHI0a0zT3k8AY5WsKd1Kl+uRNGfhcOaZysqZhHnlmwwkXh0jeFO5HcXIDnyOBECy5jSsdeZTWr6CcnOOuUaYkwdckk03iyzUp0GgootaFPxOGo1K/yGGpKeaj01nv5+ebkn9h6F2u2JV/c7c6o2J/47KNKLaX8GHo44r0Gp+qc57dVUY3DTDokkjcunR12+Tb+sV8zVS0SipwQumZjck4bntT+Q1XQ+9aXEFGiPLCK5I/yh74Gn8640zcIemEylL7LsjAYVsl6bFA29tfLhf9aeWzMe/e0vwpJ root@SPARK-ansible.sparkcognition.com" | sudo tee --append /root/.ssh/authorized_keys'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 1

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 1
")

EXPECT5=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2Ug5PKiiPBwB9d4u9ZByk9nlt7T94JlaE0xEI26DnxHr5SNgn4rczWchj9hSM4RDiZIFaVMi8tYkOpOr0/PZ/vsnVQj+uDekj2rRrmBA3EyGrVb/MSoup049eOuks9EseDR3RSS0QY/WycwHWHNM+CdipVsBmaqk2FIbxog3FibHgBOTjRvEpv0jCA3oSAFrzpc8g4GDwHk4voYLP6qKz6a3rHZfrehfgRC23RB9M09XtE2Q0vQQRV4OsapYTJG7tcNy1U3xoMEYadELdad8bRnvZBJ5MvJIkf03ANKvlToUYd1yxh7RlYydZh7xGRD1OrwGhVMIQ9Z5Y3C4+hkNb ychuang@Yens-MacBook-Pro.local" | sudo tee --append  /root/.ssh/authorized_keys'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 1

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 1
")

EXPECT6=$(expect -c "
spawn ssh -t $REMOTE_HOSTNAME_SUDO_USER@$REMOTE_HOSTNAME "'sudo chmod 600 /root/.ssh/authorized_keys'"

expect \"password:\"
send \"$PASSWORD\r\"
set timeout 1

expect \"$REMOTE_HOSTNAME_SUDO_USER:\"
send \"$PASSWORD\r\"
set timeout 1
")

ssh root@$2 'hostname'
if [ $? == 0 ] ; then
        echo "RSA key injection sucessful!!"
else
        echo "RSA key injection fail!!"
fi
