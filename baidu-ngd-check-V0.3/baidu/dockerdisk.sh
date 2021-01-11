#!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking docker&&kubelet disk \033[0m"
echo -e "#################################disk docker&&kubelet###############################" >> $logdir/baidu.log

DIR1=$(cat /etc/systemd/system/docker.service.d/docker-options.conf |grep data-root|awk -F= '{print $4}' |awk -F "--" '{print $1}')
DIR2=$(cat /etc/systemd/system/docker.service |grep data-root|awk -F= '{print $4}' |awk -F "--" '{print $1}')
if [[ $type == rhost ]]; then
for host in ${HostGroup[@]}
do
    ifdockerup=$(sudo ssh $user@$host "docker version >> /dev/null && echo $?")
    if [[ $ifdockerup == 0 ]]; then 

    dockerdirif1=$(sudo ssh $user@$host df -Ph $DIR1 |  grep -v -E  '文件系统|docker|kubelet|Filesystem'  | awk '{print $5,$6}' |awk -F "%" '{if($1>='$str'){print $2,$1"%"}}')
    if [[ $dockerdirif1 = ""  ]]; then
    echo $host "'docker存储，使用率未超过'$str'%。'$time' '">> $logdir/baidu-info.log
    else
    echo $host ""  >> $logdir/baidu.log
    echo  -e $host "\033[31m'docker存储使用率超过'$str'%的目录及使用率为:'$dockerdirif1'%,请释放一些空间 '$time'  ' \033[0m"

    fi
    else
      echo "您的机器上未安装docker" >> /dev/null
    fi
done

else

    ifdockeruplocal=$(docker version >> /dev/null && echo $?)
    if [[ $ifdockeruplocal == 0 ]]; then 

    dockerdirif1local=$(df -Ph $DIR1 |  grep -v -E  '文件系统|docker|kubelet|Filesystem'  | awk '{print $5,$6}' |awk -F "%" '{if($1>='$str'){print $2,$1"%"}}')
    if [[ $dockerdirif1local = ""  ]]; then
    echo "'docker存储，使用率未超过'$str'%。'$time' '" >> $logdir/baidu-info.log
    else
    echo  -e "\033[31m'docker存储使用率超过'$str'%的目录及使用率为:'$dockerdirif1local'%,请释放一些空间 '$time'  ' \033[0m"
    fi
    else
      echo "您的机器上未安装docker" >> /dev/null
    fi

fi


