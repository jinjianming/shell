#!/bin/bash
logdir="/var/log/baidu" #日志路径
time=$(date "+%Y-%m-%d %H:%M:%S") #时间戳

#采集信息的时候看是本地还是远程多台机器、如果是多台将机器ip写入即可。

HostGroup=(127.0.0.1)

#写入主控机器一台即可

Master=(127.0.0.1)

#除去主控机器其他机器ip写入

Nodes=(127.0.0.1)

HTTP_REPO_PORT=(8877)

#type = [rhost or local] 

#类型分为rhost和local如果是rhost将获取HostGroup中的主机清单进行所有主机信息的采集，如果是local只采集运行脚本的机器上的信息。

type=(rhost)
#Environmental = [Front or after]
#环境分为部署前Front和部署后after
Environmental=(Front)



HTTPURL=`hostname -i|awk '{print $1}'`:$HTTP_REPO_PORT
#################################all-env##############################
#如果type为rhost使用ssh远程的用户、如果使用普通用户要有sudo权限，sudo时候需要无需密码。
user=(root)
ns=(default)
TIMEOUT=(5)
#################################os-env###############################

#################################disk-env#############################
#磁盘判断是否大于此数值单位%
str=(80)
#############################network-env##############################
#网络ping的次数
C=(1)
#网络ping的间隔
I=(0.1)
#############################mem-env##################################
free=(10)
available=(10)
#############################redis-env################################
redisname=(rediscluster)
redissvc=(redis-cluster)
RDB=(0)
K=(baidu2)
V=(test)
redispasswd=()
#############################kafka-env################################
kafkaexporterEnable=(yes)
kafkaexportername=(kafka-exporter)
kafkabrokers=(3)
kafkaclientname=(kafka-client)
zksvcname=(ngd-kafka-zookeeper)
topic=(test-op)
partitions=(1)
replication=(1)
#############################es-env###################################
esname=(es5-elasticsearch)
#############################es-corequery-env#########################
escorequeryname=(es5-corequery-elasticsearch)
#############################mysql-env################################
mysqlpasswd=(123456a?)
mysqlname=(mysql)

