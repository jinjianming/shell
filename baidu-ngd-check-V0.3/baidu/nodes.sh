#!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking nodes \033[0m"
echo -e "#################################node###############################" >> $logdir/baidu-base-server.log
NODESTATUS=$(kubectl get nodes |awk '{print $1,$2}' |grep -v -i -E "NAME|STATUS" |grep -i "NotReady" |awk '{print $1}')
if [[ $NODESTATUS == '' ]]; then
	echo -e "All nodes are ready '$time'" >> $logdir/baidu-base-server.log
else
    echo -e "Node $NODESTATUS NotReady '$time'"	 >> $logdir/baidu-base-server.log
fi

kubectl get po --all-namespaces > $logdir/pods.log