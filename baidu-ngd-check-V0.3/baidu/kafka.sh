#!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking kafka \033[0m"
echo -e "#################################kafka###############################" >> $logdir/baidu-base-server.log
PORT=$( kubectl get svc -n $ns |grep $zksvcname|awk '{print $5}'|head -1|awk -F':' '{print $1}'|tr -d "/TCP")
checkpods=$( kubectl get po -n $ns|grep $kafkaclientname |awk '{print $3}'|grep -i "Running")
if [[ $checkpods = '' ]]; then
	kubectl apply -f  ./baidu/kafka-client.yaml >> /dev/null
 echo  -e "\033[31m请检查你的kafka-client端是否安装成功,如果没有通过kubectl apply -f  ./baidu/kafka-client.yaml安装之后重新执行 sh up.sh\033[0m"  
else
kubectl exec  -n $ns `kubectl get po -n $ns |grep $kafkaclientname|awk '{print $1}'|head -1` -it --  ./bin/kafka-topics.sh --zookeeper $zksvcname:$PORT --list >> /dev/null  
if [[ $? == 0  ]]; then
	echo -e "View topic successfully '$time'" >> $logdir/baidu-base-server.log
else
 	echo -e "Failed to view topic '$time' " >> $logdir/baidu-base-server.log
fi

createtopic=$(kubectl exec  -n $ns `kubectl get po -n $ns |grep $kafkaclientname|awk '{print $1}'|head -1` -it --  ./bin/kafka-topics.sh --create --zookeeper $zksvcname:$PORT --replication-factor $replication  --partitions $partitions --topic $topic) > /dev/null
if [[ $? == 0  ]]; then
	echo -e "Topic created successfully '$time'" >> $logdir/baidu-base-server.log
	 kubectl exec  -n $ns `kubectl get po -n $ns |grep $kafkaclientname|awk '{print $1}'|head -1` -it --  ./bin/kafka-topics.sh --delete --zookeeper $zksvcname:$PORT --topic $topic > /dev/null
else
	echo -e "Failed to create topic '$time' " >> $logdir/baidu-base-server.log
	echo -e "Probably the reason for the failure: $createtopic '$time'" >> $logdir/baidu-base-server.log
fi

if [[ $kafkaexporterEnable == yes ]]; then
  exporterip=$( kubectl get svc -n $ns |grep $kafkaexportername |awk '{print $3}'|head -1)
  exporterport=$( kubectl get svc |grep $kafkaexportername |awk '{print $5}'|head -1|tr -d "/TCP")
  curl -s -S --connect-timeout $TIMEOUT $exporterip:$exporterport/metrics > $logdir/kafka.log

#start Check Kafka_ brokers
brokers=$(cat $logdir/kafka.log |grep kafka_brokers|grep -v "#" |awk '{print $2}' )
if [[ $kafkabrokers == $brokers ]]; then
	echo -e "Kafka is healthy'$time'" >>  $logdir/baidu-base-server.log
	echo -e "Specific logs of kafka $logdir/kafka.log" 
else
	echo -e "Kafka is unhealthy'$brokers''$time'" >> $logdir/baidu-base-server.log
fi

else
echo -e "Detailed indicators cannot be obtained because your exporter is not enabled '$time'" >> $logdir/baidu-base-server.log
fi
fi