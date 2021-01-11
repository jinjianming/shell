 #!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking the OS environment \033[0m"
echo -e "#################################os###############################" >> $logdir/baidu.log
if [[ $type == rhost ]]; then
for host in ${HostGroup[@]}
do
 sudo ssh $user@$host  "systemctl status firewalld.service >> /dev/null"
if [[ $? = 0 ]]; then
	echo -e $host " 上的firewalld已开启看是否需要关闭关闭命令,systemctl stop firewalld.service" >> $logdir/baidu.log
	sudo ssh $user@$host "systemctl stop firewalld && systemctl disable firewalld"
else
	echo -e $host "上的firewalld已关闭"  >> $logdir/baidu-info.log
fi
SL=$(sudo ssh $user@$host  "getenforce")
if [[ $SL == permissive || $SL == disable || $SL == Permissive || $SL == Disabled ]]; then
 	echo -e $host "上的selinux已关闭" >> $logdir/baidu-info.log
else
	echo -e $host "上的selinux已开启,如需关闭使用: setenforce 0 临时关闭. " >> $logdir/baidu.log
	sudo ssh $user@$host "setenforce 0 && wget -q $HTTPURL/conf/selinux.config -O  /etc/selinux/config  >> /dev/null"

fi 
done
else
sudo systemctl status firewalld.service >> /dev/null
if [[ $? = 0 ]]; then
	echo -e  "本机上的firewalld已开启看是否需要关闭关闭命令,systemctl stop firewalld.service" >> $logdir/baidu.log
	systemctl stop firewalld && systemctl disable firewalld
else
	echo -e "本机上的firewalld已关闭" >> $logdir/baidu-info.log
fi
SLLOCAL=$("getenforce")
if [[ $SLLOCAL == permissive || $SLLOCAL == disable || $SLLOCAL == Permissive || $SLLOCAL == Disabled ]]; then
 	echo -e "本机上的selinux已关闭">> $logdir/baidu-info.log
else
	echo -e "本机上的selinux已开启,如需关闭使用: setenforce 0 临时关闭" >> $logdir/baidu.log
	setenforce 0 && wget -q $HTTPURL/conf/selinux.config -O  /etc/selinux/config  >> /dev/null
fi 	
fi
