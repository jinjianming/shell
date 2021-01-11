#!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking redis \033[0m"
echo -e "#################################redis###############################" >> $logdir/baidu-base-server.log
PORT=$(kubectl get svc -n $ns |grep $redissvc|awk '{print $5}'|awk -F':' '{print $1}'|head -1 |tr -d '"/TCP"'|tr -d '"/UDP"')
PODS=$(kubectl get po -n $ns |grep $redisname)

if [[ $PODS == "" ]]; then
   echo  -e "\033[31m请检查你的redis是否安装成功,或者查看env.sh中redisname参数是否正确. \033[0m"


else


if [[ $redispasswd == '' ]]; then
   kubectl exec  -n $ns `kubectl get po -n $ns |grep $redisname|awk '{print $1}'|head -1` -it --  redis-cli -p $PORT -n $RDB  CLUSTER info > $logdir/redis.log
   KEY=$(kubectl exec  -n $ns `kubectl get po -n $ns |grep "$redisname" |grep -i "running" |awk '{print $1}'|head -1` -it --  redis-cli -p $PORT -n $RDB  -c set $K $V|tr -d "\r")
   delkey=$(kubectl exec  -n $ns `kubectl get po -n $ns |grep "$redisname" |grep -i "running" |awk '{print $1}'|head -1` -it --  redis-cli -p $PORT -n $RDB  -c del $K |tr -d "\r")

else
   kubectl exec  -n $ns `kubectl get po -n $ns |grep $redisname|awk '{print $1}'|head -1` -it --  redis-cli -p $PORT -n $RDB -a $redispasswd CLUSTER info > $logdir/redis.log
   KEY=$(kubectl exec  -n $ns `kubectl get po -n $ns |grep "$redisname" |grep -i "running" |awk '{print $1}'|head -1` -it --  redis-cli -p $PORT -n $RDB -a $redispasswd -c set $K $V|tr -d "\r")
   delkey=$(kubectl exec  -n $ns `kubectl get po -n $ns |grep "$redisname" |grep -i "running" |awk '{print $1}'|head -1` -it --  redis-cli -p $PORT -n $RDB -a $redispasswd -c del $K |tr -d "\r")
fi

if [[ $KEY == ok || $KEY == OK ]]; then
	echo -e "redis inset ok '$time'" >> $logdir/baidu-base-server.log
else
	echo -e "redis inset fail '$time'" >> $logdir/baidu-base-server.log
fi

if [[ $delkey == "(integer) 1"  ]]; then
        echo -e "redis delkey ok '$time'"  >> $logdir/baidu-base-server.log
else
        echo -e "redis delkey fail '$time'" >> $logdir/baidu-base-server.log
fi

cluster_state=$(cat $logdir/redis.log|grep cluster_state|awk -F ':' '{print $2}'|tr -d "\r" )
if [[ $cluster_state == ok || $cluster_state == OK ]]; then
	echo -e "redis cluster-state ok '$time' " >> $logdir/baidu-base-server.log
else
	echo -e "redis cluster-state fail '$time'" >> $logdir/baidu-base-server.log
fi

cluster_size=$(cat $logdir/redis.log |grep cluster_size|awk -F':' '{print $2}' |tr -d "\r" )
if [[ $cluster_size == 3  ]]; then
	echo -e "redis cluster-size ok '$time'" >> $logdir/baidu-base-server.log
else
	echo -e "redis cluster-size fail '$time'" >> $logdir/baidu-base-server.log
fi
cluster_known_nodes=$(cat $logdir/redis.log |grep cluster_known_nodes|awk -F':' '{print $2}'|tr -d "\r")
if [[ $cluster_known_nodes == 6  ]]; then
	echo -e "redis cluster_known_nodes ok '$time' " >> $logdir/baidu-base-server.log
else
	echo -e "redis cluster_known_nodes fail '$time'" >> $logdir/baidu-base-server.log
	kubectl exec  -n $ns `kubectl get po -n $ns|grep rediscluster|awk '{print $1}'|head -1` -it --  redis-cli -p $PORT -n $RDB  -a '$redispasswd' CLUSTER nodes >> $logdir/baidu-base-server.log
echo -e "Specific logs of redis $logdir/redis.log" 
fi


fi



