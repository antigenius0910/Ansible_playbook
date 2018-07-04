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
