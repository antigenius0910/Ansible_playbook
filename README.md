# Ansible_playbook

---


**Login XXXXX-ansible with your AD account**

1. ssh $USERNAME@XXXXX-ansible
2. sudo -s 
3. cd /remote.bin/ansible/  

**All ansible playbook are listed with extension .yml**

 [root@XXXXX-ansible ansible]# ls -al *.yml  
 -rw-r--r--. 1 root root  792 Jun 14 13:25 cuda.yml  
 -rw-r--r--. 1 root root 2172 Jun 14 13:25 docker.yml  
 -rw-r--r--. 1 root root  638 Jun 14 13:25 k80.yml  
 -rw-r--r--. 1 root root 1039 Jun 14 13:25 shared_home.yml  
 -rw-r--r--. 1 root root 2276 Jun 14 13:58 sssd.yml  
 -rw-r--r--. 1 root root  487 Jun 14 13:25 tmux.yml  

**Before you deploy any playbook make sure the hosts file has your "target group" and all "group members"**

$cat hosts  
[server] # Group Name  
zalewski.XXXXX.com ansible_ssh_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa # Group member  

**and the $PLAYBOOK.yml has the correct group name on the very frist line**

$cat sssd.yml  
hosts: server #Group Name need to match with host file  

**You can test sssd.yml playbook if you would like to do a test run**

$ansible-playbook -vv sssd.yml  

---

# inject_rsa

inject RSA keys to local servers

----------------------
Command Line Arguments
----------------------
```
Example:  ./inject_rsa.sh TARGET_MACHINE_SUDO_USER TARGET_MACHINE_IP PASSWORD
```
----------------------
Distributed mode
----------------------
```
cat AssetsExport-3.csv | grep Ubuntu | awk '{print $1}' | sed s'/,.*//' > ./list.txt

```

---
# OSSEC_agent_install

Automate OSSEC agent installation  

---

**For security concern this script can only be use on *****-ansible.*****.com, please make sure target machine already have *****-ansible's RSA key before running this script. target machine will need to have gcc installed**  

1. ssh $USERNAME@*****-ansible
2. sudo -s 
3. cd /remote.bin/ansible/
4. ./OSSEC.sh $TARGET_MACHINE_NAME 

**Check if agent has been suceefully deployed**  

*****security@*****-SecurityOnion:~$ sudo /var/ossec/bin/agent_control -l  
  
   ID: 1182, Name: zalewski, IP: 192.168.5.222, Active  
   ID: 1192, Name: shannon, IP: 192.168.5.80, Active  
   ID: 1194, Name: targowski, IP: 192.168.5.135, Active  
   ID: 1195, Name: oracle12server, IP: 192.168.5.59, Active  

**Troubleshooting steps**  

If agent shows "Never connected" on OSSEC server.  
  
e.g. ID: 1041, Name: wirth, IP: 192.168.5.72, Never connected  
  
Check logs and see what server and agent complain  
  
1. root@wirth# tail -f  /var/ossec/logs/ossec.log &   
2. *****security@*****-SecurityOnion:~$ sudo tail -f  /var/ossec/logs/ossec.log &  
3. *****security@*****-SecurityOnion:~$ sudo /etc/init.d/ossec-hids-server restart  
4. [root@scsftp ~]# systemctl restart ossec
  
If still can't find the issue, delete the agent on target machine, make change of the script and re-run the script.  
  
1. [root@wirth]# systemctl stop ossec -l && /var/ossec/bin/ossec-control stop && rm -rf /var/ossec && rm /etc/init.d/\*ossec\* && rm /etc/ossec-init.conf && rm -rf /etc/rc.d/rc\*.d/\*ossec  
2. [root@*****-ansible ansible]# vim OSSEC.sh  
3. change script code sleep 45 to sleep 60 or longer  
4. [root@*****-ansible ansible]# ./OSSEC.sh wirth

If problem remove agent. go to /var/ossec/etc/client.keys and take it away directly.

---
