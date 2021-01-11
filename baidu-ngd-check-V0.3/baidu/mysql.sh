#!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking mysql \033[0m"
echo -e "#################################MySQL###############################" >> $logdir/baidu-base-server.log

PODS=$(kubectl get po -n $ns |grep $mysqlname)

if [[ $PODS == "" ]]; then
	echo  -e "\033[31m请检查你的mysql是否安装成功. \033[0m"
else
	
PING=$(kubectl exec -n $ns `kubectl get po -n $ns |grep $mysqlname |grep -v "init"|awk '{print $1}'|head -1`  -it --  mysqladmin ping  -u root -p$mysqlpasswd   |grep "mysqld is alive" |awk '{print $NF}' |tr -d "\r")
slave_status=$(kubectl exec -n $ns `kubectl get po -n $ns |grep mysql |grep -v "init"|awk '{print $1}'|head -1`  -it --  mysql -uroot -p$mysqlpasswd  -h127.0.0.1 -e "show slave status\G;"|grep -E -i "Slave_IO_Running: Yes|Slave_SQL_Running: Yes"|wc -l)

if [[ $PING == "alive" ]]; then
    echo -e "mysql ping alive'$time'" >> $logdir/baidu-base-server.log
else
	echo -e "mysql ping faild '$time'" >> $logdir/baidu-base-server.log

fi


if [[ $slave_status -eq 2 ]]; then
     echo -e "mysql slave_status healthy '$time'" >> $logdir/baidu-base-server.log
else
	echo -e "mysql slave_status fail '$time'" >> $logdir/baidu-base-server.log
fi

Slow_queries=$(kubectl exec -n $ns `kubectl get po -n $ns |grep mysql |grep -v "init"|awk '{print $1}'|head -1`  -it --  mysql -uroot -p$mysqlpasswd -h127.0.0.1 -e "show status like 'slow_queries';"|grep Slow_queries |tr -d '|'|awk '{print $2}' )
Slow_launch_threads=$(kubectl exec -n $ns `kubectl get po -n $ns |grep mysql |grep -v "init"|awk '{print $1}'|head -1`  -it --  mysql -uroot -p$mysqlpasswd -h127.0.0.1 -e "show status like 'slow_launch_threads';" |grep Slow_launch_threads|tr -d '|' |awk '{print $2}')
echo -e "查看查询时间超过long_query_time秒的查询的个数 mysql Slow_queries='$Slow_queries'" >> $logdir/baidu-base-server.log
echo -e "查看创建时间超过slow_launch_time秒的线程数 mysql Slow_launch_threads='$Slow_launch_threads''$time'">> $logdir/baidu-base-server.log

fi


