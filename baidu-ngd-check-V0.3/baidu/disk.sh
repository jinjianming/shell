#!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking disk \033[0m"
echo -e "#################################disk###############################" >> $logdir/baidu.log
if [[ $type == rhost ]]; then
for host in ${HostGroup[@]}
do
    result=$( sudo ssh $user@$host df -Ph  |  grep -v -E  '文件系统|docker|kubelet|Filesystem'  | awk '{print $5,$6}' |awk -F "%" '{if($1>='$str'){print $2,$1"%"}}')
    if [ "$result" =  "" ]
    then
        echo $host "'各文件系统磁盘空间正常，使用率都未超过'$str'%。'$time' '">> $logdir/baidu-info.log
    else
  
        echo $host "'磁盘空间使用率超过'$str'%的目录及使用率为:'$result',请释放一些空间 '$time'  '"  >> $logdir/baidu.log
fi
done
else
	localresult=$(df -Ph |grep -v -E  '文件系统|docker|kubelet|Filesystem'| awk '{print $5,$6}' |awk -F "%" '{if($1>='$str'){print $2,$1"%"}}')
	if [ "$localresult" =  "" ]
    then
        echo  "'本机各文件系统磁盘空间正常，使用率都未超过'$str'%。'$time' '" >> $logdir/baidu-info.log
    else
        echo  "'磁盘空间使用率超过'$str'%的目录及使用率为:'$localresult',请释放一些空间 '$time' ' "  >> $logdir/baidu.log
fi
fi
