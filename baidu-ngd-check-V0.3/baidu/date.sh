#!/bin/bash
source ./env.sh
echo  -e "\033[32mchecking date \033[0m"
echo -e "#################################date###############################" >> $logdir/baidu.log
if [[ $type == rhost ]]; then
  echo -e "\033[33m帮助: 如果有上游NTP Server IP则选择使用ntp方式，如果没有上游NTP Server IP则选择chrony。\033[0m"
    read -p "正在尝试修改机器上的时钟同步、请选择使用ntp或者chrony或者no: " TimeType
    
###################################################################################################

    case $TimeType in
        ntp | n |NTP | N)
read -p  "您选择了ntp类型来同步时间，请输入Ntp Server ip: " NTPIP
sed -i '/^server/d' packages/conf/ntp-server.conf && sed -i '1i server '$NTPIP' iburst' packages/conf/ntp-server.conf 


for host in ${HostGroup[@]}
do

INSTALLSHELL ()
{
  scp /etc/yum.repos.d/local.repo root@$host:/etc/yum.repos.d/
  sudo ssh $user@$host "yum clean all && yum makecache && yum install -y ntp ntpdate >> /dev/null  && wget -q $HTTPURL/conf/ntp-server.conf -O /etc/ntp.conf >> /dev/null "
}
GETCONF ()
{
     sudo ssh $user@$host  "wget -q $HTTPURL/conf/ntp-server.conf -O /etc/ntp.conf >> /dev/null "
}
SHELLNTP ()
{
    sudo ssh $user@$host "echo -e $host 正在启动重启ntpd && systemctl enable ntpd && systemctl restart ntpd"
}
ShellAll ()
{
      if [[ $? == 0 ]]; then
        sudo ssh $user@$host ntpdate -u $NTPIP && hwclock -w  
       if [ $? == 0 ] ;then
          echo -e "\033[32m$host 同步ntp服务器$NTPIP成功\033[0m"
          SHELLNTP
          if [[ $? -eq 0 ]]; then
          echo -e "\033[32m$host 重启ntpd服务成功\033[0m" >> $logdir/baidu-info.log
          else
          echo -e "\033[31m$host 重启ntpd服务失败\033[0m"
          fi
       else
          echo -e  $host "同步ntp服务器$NTPIP失败"
       fi
    fi
}
sudo ssh $user@$host  rpm -qa |grep ntp- >> /dev/null 
if [[ $? -eq 0 ]]; then
    echo $host "已安装ntpd无需处理" >> $logdir/baidu.log
    GETCONF
    ShellAll
else
    INSTALLSHELL
  if [[ $? -eq 0 ]]; then
  ShellAll
  else
        echo -e  "\033[31m$host Ntpd安装失败无法开启同步操作\033[0m"
  fi

fi
done

###################################################################################################

;;
        chrony | c )


DATE=$(date "+%Y-%m-%d %H:%M:%S")
read -p "您选择了chrony类型来同步时间，当前服务器时间为'$DATE',请确认是否正确输入yes or no: " Chrony 
#read -p  "您选择了chrony类型来同步时间，请输入主控机器ip: " ChronyIp 
SHELLChronyOne ()
{
  ssh root@$Master "yum install chrony -y >> /dev/null && systemctl enable chronyd && systemctl restart chronyd && hwclock -w " 
  ssh root@$node "yum install chrony -y >> /dev/null && systemctl enable chronyd && systemctl restart chronyd && hwclock -w " 
}

SHELLChronyTow ()
{
  ssh root@$node "systemctl enable chronyd && systemctl restart chronyd && hwclock -w " 
}


SedChronyMaster ()
{
  ssh root@$Master "yum install chrony -y >> /dev/null && systemctl enable chronyd && systemctl restart chronyd && hwclock -w " 
  ssh root@$Master   "mv /etc/chrony.conf /etc/chrony-`date "+%Y-%m-%d%H:%M:%S"`.conf && wget -q $HTTPURL/conf/chrony-server-tmp.conf -O /etc/chrony.conf"   
  sed -i '/^server/d' packages/conf/chrony-client-tmp.conf  && sed -i '1i server '$Master' iburst' packages/conf/chrony-client-tmp.conf
  sudo ssh root@$Master  chronyd --version >> /dev/null 
 
}

SHELLChronyAll ()
{
 for node in ${Nodes[@]}
 do
sudo ssh $user@$node  chronyd --version >> /dev/null 
if [[ $? -eq 0 ]]; then
 ssh root@$node "mv /etc/chrony.conf /etc/chrony-`date "+%Y-%m-%d%H:%M:%S"`.conf | wget -q $HTTPURL/conf/chrony-client-tmp.conf  -O /etc/chrony.conf"
 SHELLChronyTow
    if [[ $? -eq 0 ]]; then
    echo -e "\033[32m$node 重启Chrony服务成功\033[0m" >> $logdir/baidu-info.log
    else
    echo -e "\033[31m$node 重启Chrony服务失败\033[0m"
    fi
else
 ssh root@$node "mv /etc/chrony.conf /etc/chrony-`date "+%Y-%m-%d%H:%M:%S"`.conf | wget -q $HTTPURL/conf/chrony-client-tmp.conf  -O /etc/chrony.conf"
 SHELLChronyOne
    if [[ $? -eq 0 ]]; then
    echo -e "\033[32m$node 重启Chrony服务成功\033[0m" >> $logdir/baidu-info.log
    else
    echo -e "\033[31m$node 重启Chrony服务失败\033[0m"
    fi
fi


done
}
case $Chrony in
  yes | y | YES | Y)

SedChronyMaster
if [[ $? -eq 0 ]]; then

SHELLChronyAll

else
exit 4
fi


###################################################################################################

    ;;
  no | n | NO | N)
SedChronyMaster
if [[ $? -eq 0 ]]; then
read -p "正在尝试修改服务器时间,请按照此格式输入正确时间输入完成回车即可 例如: '2021-01-5 00:00:00' " TIMEDATE
date -s "$TIMEDATE"
read -p "正在二次确认修改时间是否正确 '$DATE' 请确认是否正确输入yes or no: " TOW
if [[ $TOW == yes || y || Y || YES ]]; then
SHELLChronyAll
else
  exit 4
fi
else
exit 4
fi


    ;;
esac

;;
        no | n | NO | N)
exit 1
;;
        *  ) echo "$0 {ntp|chrony|no}"
             exit 4
      
            ;;
    esac
else



###################################################################################################
    read -p "正在尝试修改机器上的时钟同步、请选择使用ntp或者date手动或者no退出: " TimeType

    case $TimeType in
        ntp | n |NTP | N)

read -p  "您选择了ntp类型来同步时间，请输入Ntp Server ip: " NTPIP
sed -i '/^server/d' packages/conf/ntp-server.conf && sed -i '1i server '$NTPIP' iburst' packages/conf/ntp-server.conf 

INSTALLSHELL ()
{
  # scp /etc/yum.repos.d/local.repo root@$host:/etc/yum.repos.d/
  yum clean all && yum makecache && yum install -y ntp ntpdate >> /dev/null  && wget -q $HTTPURL/conf/ntp-server.conf -O /etc/ntp.conf >> /dev/null 
}
GETCONF ()
{
       "wget -q $HTTPURL/conf/ntp-server.conf -O /etc/ntp.conf >> /dev/null "
}
SHELLNTP ()
{
     "echo -e $host 正在启动重启ntpd && systemctl enable ntpd && systemctl restart ntpd"
}
ShellAll ()
{
    if [[ $? == 0 ]]; then
          ntpdate -u $NTPIP && hwclock -w  
       if [ $? == 0 ] ;then
          echo -e "\033[32m$host 同步ntp服务器$NTPIP成功\033[0m" >> $logdir/baidu-info.log
          SHELLNTP
          if [[ $? -eq 0 ]]; then
          echo -e "\033[32m$host 重启ntpd服务成功\033[0m" >> $logdir/baidu-info.log
          else
          echo -e "\033[31m$host 重启ntpd服务失败\033[0m"
          fi
       else
          echo -e  $host "同步ntp服务器$NTPIP失败"
       fi
    fi
}
 

rpm -qa |grep ntp- >> /dev/null 
if [[ $? -eq 0 ]]; then
    echo $host "已安装ntpd无需处理" >> /dev/null
    GETCONF
    ShellAll
else
    INSTALLSHELL
  if [[ $? -eq 0 ]]; then
    ShellAll
  else
        echo -e  "\033[31m$host Ntpd安装失败无法开启同步操作\033[0m"
  fi

fi

;;
        date | d)
DATE=$(date "+%Y-%m-%d %H:%M:%S")
read -p "您选择了date类型来同步时间，当前服务器时间为'$DATE',请确认是否正确输入yes or no: " DateTow
if [[ $DateTow == yes || y || Y || YES ]]; then
  
  exit 0

else
read -p "正在尝试修改服务器时间,请按照此格式输入正确时间输入完成回车即可 例如: '2021-01-5 00:00:00' " TIMEDATE
date -s "$TIMEDATE"
hwclock -w 
fi

;;
  no | n)
  exit 1
  ;;
        *  ) echo "$0 {ntp|date|no}"
             exit 1
      ;;
    esac

fi
