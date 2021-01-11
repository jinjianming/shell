#!/bin/bash
source ./env.sh
echo  -e "\033[32minstall http_server.py \033[0m"
echo -e "#################################install http_server.py###############################" >> $logdir/baidu.log
#start httpserver

function LOCAL_REPO()
{
    if [ ! -d /etc/yum.repos.d/bak  ];then
      mkdir /etc/yum.repos.d/bak
    else
      echo "repos bak exist"
    fi
    ls /etc/yum.repos.d | grep -i "centos" | xargs -I{} mv /etc/yum.repos.d/{} /etc/yum.repos.d/bak

    cat << EOT > /etc/yum.repos.d/local.repo
[local]
name=local
baseurl=http://$HTTPURL/repos/local/Packages
gpgcheck=0
enable=1
EOT
    yum clean all && yum makecache
}
function HTTP_REPO_INSTALL()
{
    systemctl stop firewalld
    systemctl disable firewalld
    if [ `sestatus | grep "SELinux status" | awk '{print $3}'` = "disabled"  ];then
      echo "selinux check ok"
    else
      setenforce 0
    fi

    HttpCode=$(curl -s -S  $HTTPURL/indix.html ) 
    KEY=BAIDU-OP
    netstat -utpln |grep $HTTP_REPO_PORT
if [[ $? -eq 0 ]]; then
  if [[ $HttpCode == "$KEY" ]]; then
    echo -e "\033[32mhttp_server Start successfully\033[0m"
  else
    echo  -e "\033[31m端口$HTTP_REPO_POR已被占用\033[0m"
    exit 3
  fi
else

    cd packages && nohup python http_server.py $HTTP_REPO_PORT > /tmp/httpd.log 2>&1  & echo $! > /tmp/http_server.pid 
    sleep 1  
     if [[ $HttpCode == "$KEY" ]]; then
        echo -e "\033[32mhttp_server Start successfully\033[0m"
     else
        echo  -e "\033[31mhttp_server Start fail\033[0m"
        exit 3
     fi

fi

    
    #check http


}
function main()
{
echo "install httpd repo.........................."
      HTTP_REPO_INSTALL
echo "configure local repo............................."
      LOCAL_REPO


}
main "$@"

