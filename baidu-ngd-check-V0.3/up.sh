#!/bin/bash
#dos2unix * baidu/*
source ./env.sh
rm -rf $logdir/*.log
#echo  ' ' > $logdir/*.log
if [[ -d $logdir ]]; then
	echo yes $logdir >> /dev/null
else
	mkdir -p $logdir
fi
if [[ $type == rhost ]]; then
for host in ${HostGroup[@]}
do
sudo ssh-copy-id  $user@$host >> /dev/null
#echo -e "输入密码后将配置sshd免密信任配置。"
if [[ $? -eq 0 ]]; then
     echo  -e "\033[32mcheck-ssh'$host'ok \033[0m"   
else
        exit 1
fi
done
else
   echo -e "local-nosshd" >> /dev/null
fi

SHELL1=$()
if [[ $Environmental == Front ]]; then
    sh ./baidu/localbaidu.sh
    if [[ $? -eq 0 ]]; then
    sh ./baidu/localbaidu.sh
    sh ./baidu/date.sh
    sh ./baidu/network.sh
    sh ./baidu/os.sh
    sh ./baidu/memory.sh
    sh ./baidu/disk.sh
    else
      exit 4
      echo "\033[31m无法启动http_server已退出脚本请检查\033[0m"
    fi
 else
    
    sh ./baidu/localbaidu.sh
    if [[ $? -eq 0 ]]; then
    sh ./baidu/localbaidu.sh
    sh ./baidu/date.sh
    sh ./baidu/network.sh
    sh ./baidu/os.sh
    sh ./baidu/memory.sh
    sh ./baidu/disk.sh
    else
      exit 4
      echo "\033[31m无法启动http_server已退出脚本请检查\033[0m"
    fi
    sh ./baidu/nodes.sh
    sh ./baidu/dockerdisk.sh 
    sh ./baidu/redis.sh
    sh ./baidu/kafka.sh
    sh ./baidu/elastic.sh
    sh ./baidu/escorequery.sh
    sh ./baidu/mysql.sh
fi
echo -e "任务已经完成请到$logdir查看结果."
