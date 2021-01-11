#!/bin/bash
# Author: baiyitong
# Configure BondIp

cd $(dirname $(readlink -f  $0))


# set some vars
nic1_name="eno1"
nic2_name="eno2"

bond_ip="10.66.156.1xx"
host_name="s02-01-m72-aicp-01"

bond_gateway="10.66.156.254"
bond_prefix="24"

bond_mode="0"


# set hostname 
hostnamectl set-hostname --static ${host_name}


# begin
systemctl stop network.service


# refresh bond config
cat > /etc/sysconfig/network-scripts/ifcfg-bond0 <<EOF
DEVICE=bond0
NAME=bond0
TYPE=Bond
IPADDR=${bond_ip}
PREFIX=${bond_prefix}
BONDING_MASTER=yes
BONDING_OPTS="mode=${bond_mode} miimon=100"
NM_CONTROLLED=no
BOOTPROTO=none
ONBOOT=yes

EOF

# refresh nic1 config
cat > /etc/sysconfig/network-scripts/ifcfg-${nic1_name} <<EOF
DEVICE=${nic1_name}
NAME=${nic1_name}
TYPE=Eehernet
NM_CONTROLLED=no
ONBOOT=yes
MASTER=bond0
SLAVE=yes

EOF


# refresh nic2 config
cat > /etc/sysconfig/network-scripts/ifcfg-${nic2_name} <<EOF
DEVICE=${nic2_name}
NAME=${nic2_name}
TYPE=Eehernet
NM_CONTROLLED=no
ONBOOT=yes
MASTER=bond0
SLAVE=yes

EOF


# set default gateway

cat > /etc/sysconfig/network <<EOF
NETWORKING=yes
GATEWAY=${bond_gateway}
EOF

# done
systemctl restart network.service

ping -c 4 ${bond_gateway}
