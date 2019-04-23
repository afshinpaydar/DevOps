Master(x2):
 8 Core CPU
 16G RAM
 No swap 
 OS LVM Disk 25GB
 Docker disk 20GB

Nodes(x3):
 8 Core CPU
 16G RAM
 No swap 
 OS LVM 25GB
 Docker disk 20GB
 Heketi disk 100GB

***********************************************************************************************
#copy ssh key to All servers
#change root password 
passwd <>
#install requirement packages
yum install -y tmux
tmux
yum install -y tmux vim net-tools ntp policycoreutils-python centos-release-openshift-origin311 epel-release docker git pyOpenSSL && yum upgrade -y 

useradd origin 
passwd origin 
echo -e 'Defaults:origin !requiretty\norigin ALL = (root) NOPASSWD:ALL' | tee /etc/sudoers.d/openshift 
chmod 440 /etc/sudoers.d/openshift 
# if Firewalld is running, allow SSH
firewall-cmd --add-service=ssh --permanent 
firewall-cmd --reload 

#config NTP client
ntp server <192.168.10.88>  tincker panic 0 
systemctl enable ntpd
systemctl restart ntpd
#check ntp server
ntpq -np
hostnamectl set-hostname master.soshyant.local
edit /etc/motd
http://patorjk.com/software/taag/#p=display&f=Big%20Money-nw&t=Openshift-Node3

#change dns
cat /etc/resolv.conf 
search cluster.local soshyant.local
nameserver 192.168.110.134
nameserver 178.22.122.100



#On Master Node, login with a user created above and set SSH keypair with no pass-phrase.
ssh-keygen -q -N ""
vim ~/.ssh/config

Host master1.soshyant.local
    Hostname master1.soshyant.local
    Port 22
    User origin
Host master2.soshyant.local
    Hostname master2.soshyant.local
    Port 22
    User origin
Host node1.soshyant.local
    Hostname node1.soshyant.local
    Port 22
    User origin
Host node2.soshyant.local
    Hostname node2.soshyant.local
    Port 22
    User origin
Host node3.soshyant.local
    Hostname node3.soshyant.local
    Port 22
    User origin

vim /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.110.134         node1.soshyant.local
192.168.110.135         node2.soshyant.local
192.168.110.136         node3.soshyant.local
192.168.110.137         master1.soshyant.local
192.168.110.138         master2.soshyant.local

chmod 600 ~/.ssh/config
ssh-copy-id master1.soshyant.local
ssh-copy-id master2.soshyant.local
ssh-copy-id master2.soshyant.local
ssh-copy-id node1.soshyant.local
ssh-copy-id node2.soshyant.local
ssh-copy-id node3.soshyant.local

#create lvm and VG
cfdisk /dev/sdb
 > type 8e
pvcreate /dev/sdb1
vgcreate docker /dev/sdb1


lvmconf --disable-cluster
systemctl stop docker

vim   /etc/sysconfig/docker-storage-setup
VG=docker
DATA_SIZE=100%VG
STORAGE_DRIVER=overlay2
CONTAINER_ROOT_LV_NAME=dockerlv
CONTAINER_ROOT_LV_MOUNT_PATH=/var/lib/docker
CONTAINER_ROOT_LV_SIZE=100%FREE

#if nedded to redo docker-storage section
#rm -f /etc/sysconfig/docker-storage
docker-storage-setup
  Logical volume "dockerlv" created.
systemctl start docker && systemctl enable  docker
#zero reserved block on docker storage
dxfs_io -x -c "resblks 0" /var/lib/docker

#set google docker proxy:
vim /etc/docker/daemon.json 
{
	"registry-mirrors": ["https://mirror.gcr.io"]
}

systemctl daemon-reload && systemctl restart docker



#pull docker images for openshift:


chmod +x docker_pull.sh



tmux
./docker_pull.sh
rm -f docker_pull.sh
#On Master1

yum -y install openshift-ansible

ssh origin@soshya-openshift-master1
tmux
sudo vim /etc/ansible/hosts # FIRST TRY WITH SINGLE MASTER, AFTER ADD SECOND ONE!!!
####{{ hostvars[host]['ansible_hostname'] }}={{ etcd_peer_url_scheme }}://{{ hostvars[host].ansible_default_ipv4.address }}:{{ etcd_peer_port }} ###
###https://github.com/kubernetes-retired/contrib/pull/711/commits/44ce92698e75dd9e9011207c02d250ba75e4ea17
----------------------------------------------------------------------------------------------------------------------------------------
[OSEv3:children]
masters
nodes
etcd
glusterfs

[OSEv3:vars]
ansible_ssh_user=origin
ansible_become=true
openshift_deployment_type=origin
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
openshift_master_default_subdomain=apps.soshyant.local
openshift_docker_insecure_registries=172.30.0.0/16
openshift_check_min_host_memory_gb=6
openshift_check_min_host_disk_gb=10
openshift_storage_glusterfs_namespace=glusterfs
openshift_storage_glusterfs_name=storage
openshift_storage_glusterfs_storageclass=true
openshift_storage_glusterfs_storageclass_default=false
openshift_storage_glusterfs_block_deploy=true
openshift_storage_glusterfs_block_host_vol_size=44
openshift_storage_glusterfs_block_storageclass=true
openshift_storage_glusterfs_block_storageclass_default=false
openshift_metrics_server_install=true

#Mertics Parameters
openshift_metrics_duration=1
openshift_metrics_start_cluster=True
openshift_metrics_hawkular_hostname=hawkular-metrics.soshyant.local
openshift_metrics_cassandra_storage_type=pv

openshift_metrics_cassandra_limits_memory=2Gi
openshift_metrics_cassandra_requests_memory=2Gi
openshift_metrics_hawkular_limits_memory=2Gi
openshift_metrics_hawkular_requests_memory=2Gi
openshift_metrics_heapster_limits_memory=2Gi

openshift_metrics_cassandra_limits_cpu=4000m
openshift_metrics_heapster_limits_cpu=4000m
openshift_metrics_hawkular_limits_cpu=4000m

openshift_metrics_hawkular_nodeselector={"region":"infra"}
openshift_metrics_heapster_nodeselector={"region":"infra"}
openshift_metrics_cassandra_nodeselector={"region":"infra"}


[masters]
master1.soshyant.local containerized=false

[etcd]
master1.soshyant.local

[nodes]
master1.soshyant.local openshift_node_group_name='node-config-master-infra' 
node1.soshyant.local openshift_node_group_name='node-config-compute' openshift_schedulable=True
node2.soshyant.local openshift_node_group_name='node-config-compute' openshift_schedulable=True
node3.soshyant.local openshift_node_group_name='node-config-compute' openshift_schedulable=True



[glusterfs] 
node1.soshyant.local glusterfs_ip=192.168.110.134  glusterfs_devices='[ "/dev/sdc" ]'
node2.soshyant.local glusterfs_ip=192.168.110.135  glusterfs_devices='[ "/dev/sdc" ]'
node3.soshyant.local glusterfs_ip=192.168.110.136  glusterfs_devices='[ "/dev/sdc" ]'



---------------------------------------------------------------------------


ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml

#https://github.com/openshift/openshift-ansible/issues/10412
#Check DNS records and regenerate certs:
#ansible-playbook -i hosts ./playbooks/redeploy-certificates.yml

#on All masters
vim  /etc/dnsmasq.conf 
address=/apps.soshyant.local/192.168.110.137
vim /etc/dnsmasq.d/origin-upstream-dns.conf
server=94.232.174.194

vim /etc/dnsmasq.d/origin-dns.conf 
------------------
except-interface=lo
strict-order
domain-needed
local=/soshyant.local/
bind-dynamic
log-queries
-----------------

systemctl restart dnsmasq
iptables -I INPUT 1 -p TCP --dport 53 -j ACCEPT
iptables -I INPUT 1 -p UDP --dport 53 -j ACCEPT

service iptables save

ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml

cat   /etc/origin/node/resolv.conf 
nameserver 94.232.174.194

#increase open file limit on all servers
vim /etc/security/limits.conf
*         hard    nofile      500000
*         soft    nofile      500000
root      hard    nofile      500000
root      soft    nofile      500000

vim /etc/pam.d/common-session
session required pam_limits.so

vim /etc/sysctl.conf
fs.file-max = 2097152

sysctl -p
#logout & login
ulimit -a
cat /proc/{process_id}/limits

#origin user tmux
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml 

#client setup
open port 8443 to masters
go to https://www.okd.io/download.html
download oc client tool:
cd /tmp && wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar -xzvf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
cd openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/ && cp oc kubectl /usr/bin
scp -r   soshya-openshift-master1:/root/.kube .
oc login -u system:admin

#change ssh port from default <22> to 8822 on All Servers
semanage port -a -t ssh_port_t -p tcp 8822
service iptables save
vim /etc/sysconfig/iptables
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8822 -j ACCEPT


systemctl reload iptables
iptables -nvL | grep 8822
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:8822

vim /etc/ssh/sshd_config
Port 8822

systemctl reload sshd
netstat -tulpn  | grep 8822
tcp        0      0 0.0.0.0:8822            0.0.0.0:*               LISTEN      28472/sshd          
tcp6       0      0 :::8822                 :::*                    LISTEN      28472/sshd

#On Masters
yum install httpd-tools
htpasswd -c /etc/origin/master/htpasswd admin







################################## GlusterFS Config ###############################################


setsebool -P virt_sandbox_use_fusefs on
setsebool -P virt_use_fusefs on

mkfs.xfs -i size=512 /dev/docker/glusterfs
mkdir -p /gluster/data
#echo '/dev/docker/glusterfs /gluster/data  xfs defaults 1 2' >> /etc/fstab




iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 24007:24008 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 49152:49156 -j ACCEPT

service iptables save

#device for glusterfs ( I use lvm)
wipefs -a /dev/docker/glusterfs











-------------------------------------------------------






--------------------------------------------------------------------------------------------------------------------------
cd /usr/share/ansible/openshift-ansible

ansible-playbook -i /etc/ansible/hosts  playbooks/openshift-glusterfs/config.yml


################################## Enable Metrics #################################################


ansible-playbook -i /etc/ansible/hosts  playbooks/openshift-metrics/config.yml -e openshift_metrics_install_metrics=True -e openshift_metrics_start_cluster=True -e openshift_metrics_duration=1 -e openshift_metrics_hawkular_hostname=hawkular-metrics.apps.soshyant.local



#################################
Add storage to heketi:
just extend LVM nodes


fdisk -l | grep sdc
cfdisk /dev/sdc
pvcreate /dev/sdc1
vgextend docker  /dev/sdc1
lvextend --size +44G /dev/mapper/docker-glusterfs
lvdisplay 

#Test
gluster storage nodes show extend by lvdisplay
