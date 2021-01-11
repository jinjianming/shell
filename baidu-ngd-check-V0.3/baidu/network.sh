#!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking network \033[0m"
echo -e "#################################network###############################" >> $logdir/baidu.log
if [[ $type == rhost ]]; then

for host in ${HostGroup[@]};do

  dnsip=$(sudo ssh $user@$host cat /etc/resolv.conf |grep  "nameserver"  |awk '{print $2}')
	for dns in $dnsip; 
	do
    	sudo ssh $user@$host "ping $dns -i $I -c $C " >> /dev/null
    	if [[ $? = 0 ]]; then
        echo $host "上'$dns',dns地址正常'$time" >> $logdir/baidu-info.log
        else
        echo $host "'上'$dns',dns地址ping不通请做处理'$time''" >> $logdir/baidu.log    
    	fi
     done

  gatewayip=$( sudo ssh $user@$host "cat /etc/sysconfig/network-scripts/ifcfg-* |grep "GATEWAY"" |awk -F"=" '{print $2}' |tr -d '"'  )
    for route in $gatewayip; 
    do
       sudo ssh $user@$host "ping $route -i $I -c $C " >> /dev/null 
       if [[ $? = 0 ]]; then
       echo $host "上'$route',网关1地址正常'$time'" >> $logdir/baidu-info.log
       else
       echo $host "上'$route',网关1地址ping不通请做处理'$time'" >> $logdir/baidu.log 
       fi
    done

  gatewayip2=$( sudo ssh $user@$host "cat /etc/sysconfig/network |grep "GATEWAY"" |awk -F"=" '{print $2}' |tr -d '"'  )
    for route2 in $gatewayip2; 
    do
       sudo ssh $user@$host "ping $route2 -i $I -c $C " >> /dev/null 
       if [[ $? = 0 ]]; then
       echo $host "上'$route2',网关2地址正常'$time'">> $logdir/baidu-info.log
       else
       echo $host "上'$route2',网关2地址ping不通请做处理'$time'" >> $logdir/baidu.log 
       fi
    done

done

else
  
  dnsiplocal=$(cat /etc/resolv.conf |grep "nameserver" |awk '{print $2}')
    for dnslocal in $dnsiplocal; 
    do
    	ping $dnslocal -i $I -c $C  >> /dev/null
    	if [[ $? = 0 ]]; then
        echo "'本机上ping, '$dnslocal'此dns地址正常'$time''" >> $logdir/baidu-info.log
        else
        echo "'本机上ping,'$dnslocal'此dns地址ping不通请做处理'$time''" >> $logdir/baidu.log
    	fi
    done

  gatewayiplocal=$( cat /etc/sysconfig/network-scripts/ifcfg-* |grep "GATEWAY"|awk -F'=' '{print $2}'|tr -d '"' )
  gatewayiplocal2=$( cat /etc/sysconfig/network |grep "GATEWAY"|awk -F'=' '{print $2}'|tr -d '"' )
    for routelocal in $gatewayiplocal; 
    do
       ping $routelocal -i $I -c $C  >> /dev/null 
       if [[ $? = 0 ]]; then
       echo  "'本机上ping, '$routelocal'网关1地址正常'$time' ' " >> $logdir/baidu-info.log
       else
       echo  "'本机上ping, '$routelocal'网关1地址ping不通请做处理'$time'' " >> $logdir/baidu.log 
       fi
    done

    for routelocal2 in $gatewayiplocal2; 
    do
       ping $routelocal2 -i $I -c $C  >> /dev/null 
       if [[ $? = 0 ]]; then
       echo  "'本机上ping, '$routelocal2'网关2地址正常'$time' '">> $logdir/baidu-info.log
       else
       echo  "'本机上ping, '$routelocal2'网关2地址ping不通请做处理'$time'' " >> $logdir/baidu.log 
       fi
    done

fi






