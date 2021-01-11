#!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking memory \033[0m"
echo -e "#################################Mem###############################" >> $logdir/baidu.log
if [[ $type == rhost ]]; then
for host in ${HostGroup[@]}
do
	FREE=$(sudo ssh $user@$host free -g |grep -i Mem |awk '{print $4}')
	AVAILABLE=$(sudo ssh $user@$host free -g |grep -i Mem |awk '{print $7}')
	if [[ $FREE -le $free ]]; then
	  echo -e "$host 此机器free内存小于 '$free'g '$time'" >> $logdir/baidu.log
	else
	  echo -e "$host 此机器free内存大于  '$free'g '$time'" >> $logdir/baidu-info.log
	fi

	if [[ $AVAILABLE -le $available ]]; then
	  echo -e "$host 此机器available内存小于  '$available'g '$time'" >> $logdir/baidu.log
    else 
      echo -e "$host 此机器available内存大于  '$available'g '$time'" >> $logdir/baidu-info.log
	fi
done
else
 	FREElocal=$( free -g |grep -i Mem |awk '{print $4}')
	AVAILABLElocal=$(free -g |grep -i Mem |awk '{print $7}')
	if [[ $FREElocal -le $free ]]; then
	  echo -e "此机器free内存小于 '$free'g '$time'" >> $logdir/baidu.log
	else
	  echo -e "此机器free内存大于  '$free'g '$time'">> $logdir/baidu-info.log
	fi
	if [[ $AVAILABLElocal -le $available ]]; then
	  echo -e "此机器available内存小于 '$available'g '$time'" >> $logdir/baidu.log
    else 
      echo -e "此机器available内存大于  '$available'g '$time'" >> $logdir/baidu-info.log
    fi
fi