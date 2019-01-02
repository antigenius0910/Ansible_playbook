#!/bin/sh
set -x

##Useage ./OSSEC.sh $TARGET_MACHINE_NAME 
##e.g. ./OSSEC.sh targowski

REJECT="Q"
ADD_AGENT="A"
EXTRACT_KEY="E"
QUIT="Q"
REMOTE_HOSTNAME=$1
REMOTE_HOSTNAME_IP=$(nslookup "$REMOTE_HOSTNAME" | grep -A1 Name | grep -v Name | sed s'/Address:.//')

##1. - OSSEC Manager - Add an Agent
EXPECT1=$(expect -c "
spawn ssh -t sparkseconion@192.168.5.58 "'sudo /var/ossec/bin/manage_agents'"
expect \"action:\"
send \"$ADD_AGENT\r\"
expect \"name\"
send \"$REMOTE_HOSTNAME\r\"
expect \"Address\"
send \"$REMOTE_HOSTNAME_IP\r\"
expect \"ID\"
send \"\r\"
set timeout 1
expect \"Confirm\"
send \"y\r\"
set timeout 1
expect \"action:\"
send \"$QUIT\r\"
expect -re \"$USER.*\"
send \"logout\"
")

##Get target machine agent ID
REMOTE_HOSTNAME_ID=$(echo "$EXPECT1" | grep ID: | sed s'/ID://')
echo $REMOTE_HOSTNAME_ID

##3. - Extracting the OSSEC Agent Key on the OSSEC Manager
EXPECT2=$(expect -c "
spawn ssh -t sparkseconion@192.168.5.58 "'sudo /var/ossec/bin/manage_agents'"
expect \"action:\"
send \"$EXTRACT_KEY\r\"
expect \"extract\"
send \"$REMOTE_HOSTNAME_ID\r\"
set timeout 1
expect \"ENTER\"
send \"\r\"
set timeout 1
expect \"action:\"
send \"$QUIT\r\"
expect -re \"$USER.*\"
send \"logout\"
")

##Get OSSEC agent key for target machine
REMOTE_HOSTNAME_KEY=$(echo "$EXPECT2" | grep -A1 information | grep -v information)
echo $REMOTE_HOSTNAME_KEY

ssh -t sparkseconion@192.168.5.58 'sudo /etc/init.d/ossec-hids-server status'

##install compiler
echo 'install compiler'
ssh -t root@$REMOTE_HOSTNAME 'apt-get -y install build-essential inotify-tools wget'
ssh -t root@$REMOTE_HOSTNAME 'yum install -y gcc inotify-tools wget'

##2.A - Installing the OSSEC Agent on Linux
ssh -t root@$REMOTE_HOSTNAME 'wget -U ossec https://github.com/ossec/ossec-hids/archive/3.0.0.tar.gz && tar -zxvf 3.0.0.tar.gz && cd ossec-hids-3.0.0'

##Please note the "sleep 45" is for ./install.sh to finish installation. you can make it longer if the installation could finsh within 45 sec
EXPECT3=$(expect -c "
spawn ssh -t root@$REMOTE_HOSTNAME "'cd ossec-hids-3.0.0 && ./install.sh'"
expect \"en\"
send  \"\r\"
set timeout 1
send  \"\r\"
expect \"installation\"
send \"agent\r\"
expect \"OSSEC\"
send  \"\r\"
expect \"IP\"
send \"192.168.5.58\r\"
expect \"integrity\"
send  \"\r\"
expect \"rootkit\"
send  \"\r\"
expect \"active\"
send  \"n\r\"
expect \"ENTER\"
send \"\r\"
sleep 45
expect \"ENTER\"
send \"\r\"
expect -re \"$USER.*\"
send \"logout\"
")

ssh -t root@$REMOTE_HOSTNAME 'rm -rf  3.0.0.tar.gz ossec-hids-3.0.0'

##4. - Importing the OSSEC Agent Key on Linux
EXPECT4=$(expect -c "
spawn ssh -t root@$REMOTE_HOSTNAME "'/var/ossec/bin/manage_agents'"
expect \"action\"
send  \"I\r\"
expect \"Paste\"
send \"$REMOTE_HOSTNAME_KEY\"
expect \"Confirm\"
send  \"y\r\"
expect \"ENTER\"
send \"\r\"
expect \"action\"
send \"Q\r\"
expect -re \"$USER.*\"
send \"logout\"
")

ssh -t root@$REMOTE_HOSTNAME 'service ossec restart'
