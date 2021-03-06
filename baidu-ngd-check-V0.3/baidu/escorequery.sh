#!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking elasticcorequery \033[0m"
echo -e "#################################elasticcorequery###############################" >> $logdir/baidu-base-server.log
PORT=$( kubectl get svc -n $ns |grep $escorequeryname|awk '{print $5}'|head -1|awk -F':' '{print $1}' |tr -d  '/TCP')
ESIP=$( kubectl get svc -n $ns |grep $escorequeryname|awk '{print $3}'|head -1 )


if [[ $ESIP == "" ]]; then
  echo  -e "\033[31m请检查你的elasticcorequery是否安装成功,或者查看env.sh中escorequeryname参数是否正确. \033[0m"
else
	
HEALTH=$(curl -s -S --connect-timeout $TIMEOUT $ESIP:$PORT/_cat/health|awk '{print $4}')


if [[ $HEALTH == green ]]; then
	echo -e "Clusters are healthy '$time'" >> $logdir/baidu-base-server.log
elif [[ $HEALTH  == yellow ]]; then
	echo -e "The cluster status is yellow '$time'" >> $logdir/baidu-base-server.log
	echo -e "#################################escorequery-nodes###############################" >> $logdir/es.log
	curl -s -S --connect-timeout $TIMEOUT  $ESIP:$PORT/_cat/nodes >> $logdir/es.log
	echo -e "#################################escorequery-indices###############################" >> $logdir/es.log
	curl -s -S --connect-timeout $TIMEOUT  $ESIP:$PORT/_cat/indices?pretty  >> $logdir/es.log
	echo -e "Specific logs of es '$logdir/es.log'"
elif [[ $HEALTH  == red ]]; then
	echo -e "The cluster status is red '$time'" >> $logdir/baidu-base-server.log
	echo -e "#################################escorequery-nodes###############################" >> $logdir/es.log
	curl -s -S --connect-timeout $TIMEOUT $ESIP:$PORT/_cat/nodes >> $logdir/es.log
	echo -e "#################################escorequery-indices###############################" >> $logdir/es.log
	curl -s -S --connect-timeout $TIMEOUT $ESIP:$PORT/_cat/indices?pretty  >> $logdir/es.log
	echo -e "Specific logs of es '$logdir/es.log'"
elif [[ $HEALTH == '' ]]; then
    echo -e "curl elasticcorequery  Unknown error '$time' " >> $logdir/baidu-base-server.log
    echo  -e "\033[31;5m请检查你的elasticcorequery安装成功. \033[0m"
fi 

fi
