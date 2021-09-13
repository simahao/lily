#!/bin/bash
#########################################################
# Note:
# 1.utility of devementment and maintenance
# 2.compatible with [Redhat7.x || CentOS7.x,)
# @author:zhanghao
# @groupId:dev2
#########################################################

# ---------------------------------------------------------------------------------------------
# version |  date    | comments                                                                |
# ---------------------------------------------------------------------------------------------
# 1.0.0   | 20190731 | init                                                                    |
# 1.1.0   | 20200710 | [feat]  add install_other_tools                                         |
#         |          | [style] rename function name                                            |
# 1.2.0   | 20200714 | [fix]   fix sudo permission issue                                       |
#         |          | [feat]  add update function                                             |
# 1.3.0   | 20200716 | [feat]  add group when adduser                                          |
# 1.4.0   | 20200720 | [fix]   put centos7.sh to /root path when update                        |
# 1.5.0   | 20200730 | [feat]  ulimit support account config(nofile=512k,nproc=128k)           |
#         |          | [feat]  sysctl.conf refer to requirements of GP                         |
#         |          | [feat]  add help support                                                |
# 1.6.0   | 20200811 | [fix]   fix REPLY variable issue                                        |
#         |          | [feat]  add ansible tool                                                |
#         |          | [feat]  version supports major.minor.patch                              |
# 1.6.1   | 20200815 | [fix]   fix menu                                                        |
# 1.7.0   | 20200824 | [feat]  authorize cluster wth one-way for ansible                       |
#         |          | [feat]  add sudoer for special users                                    |
#         |          | [fix]   fix virtual ip address issue                                    |
#         |          | [refactor] refactor menu order                                          |
# 1.7.1   | 20200916 | [fix]   fix install vscode-server with root user                        |
# 1.8.0   | 20200916 | [feat]  add install git(v2.28.0) for meeting requirement of vscode      |
# 1.9.0   | 20200922 | [feat]  add install nodejs(v14.11.0)                                    |
# 1.10.0  | 20200923 | [feat]  add neovim for vscode(v0.4.3)                                   |
#----------------------------------------------------------------------------------------------|

#Source function library.
. /etc/init.d/functions
. ~/.bash_profile
# functions don't include below path in which some components would install
PATH=$PATH:/usr/local/bin:/usr/local/sbin
export TERM=xterm
VERSION="1.10.0"
RELEASE_NOTES="[feat]   add add neovim for vscode(v0.4.3)"
usage() {
  echo "NAME"
  echo "        centos7.sh - dev2 matainance shell"
  echo "SYNOPSIS"
  echo "        centos7.sh [OPTIONS]"
  echo "DESCRIPTION"
  echo "        -v"
  echo "            output version information and exit"
  echo "        -q"
  echo "            quiet mode, do not check the new version"
  echo "        -h"
  echo "            help display this help and exit"
  exit 0
}
if [[ $# == 1 ]]; then
  if [[ $1 == "-v" || $1 == "-V" ]]; then
    echo "version:${VERSION}"
    exit 0
  elif [[ $1 == "-h" ]]; then
    usage
  else
    if [[ $1 != "-q" ]]; then
      echo "unsupported option:$1"
      usage
    fi
  fi
fi
#date
DATE=$(date +"%Y-%m-%d %H:%M:%S")
#ip
IPADDR=$(ifconfig | grep "inet" | grep -vE  'inet6|127.0.0.1' | grep -vE '0.0.0.0' | awk '{print $2}' | sed -n '1p')
#hostname
HOSTNAME=$(hostname -s)
#user
USER=$(whoami)
#disk_check
DISK_SDA=$(df -h | grep -w "/" | grep -v 'host' | awk '{print $5}')
#cpu_average_check,1min 5min 15min
CPU_AVG=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
#cpu processor
CPU_PROCESSORS=$(cat /proc/cpuinfo | grep -w 'processor' | wc -l)
#cpu cores
#in case of `` awk should like this:awk -F ':\\\\s*' '{print $2}'
CPU_CORES=$(cat /proc/cpuinfo | grep -w 'cpu cores' | awk -F ':\\s*' '{print $2}' | awk '{sum+=$1} END {print sum}')
#cpu_model
CPU_MODEL=$(cat /proc/cpuinfo | grep -w 'model name' | sed -n '1p' | awk -F ':\\s*' '{print $2}')
#memory capcity
MEMORY=$(free -h | sed -n '2p' | awk -F '\\s*' '{print $2}')
#centos version
CENTOS_VERSION=$(cat /etc/redhat-release)
#kernel_verison
KERNEL_VERSION=$(uname -sr)
#java_version
JAVA_VERSION=$(java -version 2>&1 | awk 'NR==1{gsub(/"/,""); print $3}')
#gcc_version
GCC_VERSION=$(gcc --version | grep -w "gcc" | awk '{print $3}')
#dev2 ftp server
# SSH_IP="192.168.128.128"
SSH_IP="172.52.145.172"
#ftp user
SSH_USER="share"
#ftp pass
SSH_PASS="Dev2_ftp"
#ssh path
SSH_PATH="/home/share/ftp/zhanghao"

#set LANG
export LANG=zh_CN.UTF-8

#Require root to run this script.
#uid=`id | awk -F '(' '{print $1}' | awk -F '=' '{print $2}'`
uid=$(id | cut -d\( -f1 | cut -d= -f2)
if [[ $uid != 0 ]]; then
  echo -e "\033[32mPlease run this script as root\033[0m"
  exit 1
fi


#add user and give sudoers
add_user() {
  echo "========================add user========================="
  #add user
  while true
  do
    read -p "user name:" name
    NAME=$(awk -F':' '{print $1}' /etc/passwd | grep -wx "${name}" 2>/dev/null | wc -l)
    if [[ $NAME == "" ]]; then
      echo "user name is null, please input angain"
      continue
    elif [[ $NAME == 1 ]]; then
      echo "user name is used, please choose another"
      continue
    fi
    grep dev2 /etc/group > /dev/null 2>&1
    if [[ $? > 0 ]]; then
      groupadd dev2
    fi
    if [[ "${name}" == "oracle" ]]; then
      groupadd dba > /dev/null 2>&1
      groupadd oinstall > /dev/null 2>&1
      useradd oracle -g oinstall -G dba,dev2
    elif [[ "${name}" == "timesten" ]]; then
      groupadd TimesTen > /dev/null 2>&1
      useradd timesten -g TimesTen
    else
      useradd $name -g dev2
    fi
    break
  done
  #create password
  while true
  do
    read -p "change password for $name:" pass1
    if [[ "${pass1}" == "" ]]; then
      echo "password is null, please input again"
      continue
    fi
    read -p "input password angin:" pass2
    if [[ "${pass1}" != "${pass2}" ]]; then
      echo "two inputs are inconsistent, please input again"
      continue
    fi
    echo "$pass2" | passwd --stdin "$name"
    action "add user $name successfully"  /bin/true
    break
  done
  sleep 1

  while true
  do
    read -p "add $name to sudoer?[y/n]:" option
    if [[ $option == "" ]]; then
      echo "please input y or n"
      continue
    fi
    if [[ $option == "y" || $option == "Y" ]]; then
      #add visudo
      echo -e "\n*****add sudoer******\n"
      cp /etc/sudoers /etc/sudoers.$(date +%F)
      SUDO=$(grep -w "$name" /etc/sudoers | wc -l)
      if [[ $SUDO == 0 ]]; then
        chattr -i /etc/sudoers
        echo "$name  ALL=(ALL)   NOPASSWD: ALL,/usr/bin/passwd [a-zA-Z0-9_-]*,!/usr/bin/passwd,!/usr/bin/passwd root,!/usr/sbin/visudo" >> /etc/sudoers
        echo "run cmd:tail -1 /etc/sudoers"
        tail -1 /etc/sudoers
        chattr +i /etc/sudoers
        # grep -w "$name" /etc/sudoers
        sleep 1
      fi
      action "add sudoer successfully"  /bin/true
    fi
    break
  done
  echo "========================================================="
  echo ""
  sleep 2
}

add_sudoer() {
  echo "========================add sudoer========================="

  read -p "input users list to witch you want to add,e.x. user1,user2,user3:" users
  if [[ "${users}" == "" ]]; then
    echo "please input users list"
    return 1
  fi
  local user_arr=(${users//,/ })
  local added=()
  local to_add=()
  local err=()
  local counts=${#user_arr[@]}
  local err_cnt=0
  local added_cnt=0
  local toadd_cnt=0
  # \d is supported by perl regex, posix and gnu regex doesn't support \d
  find /etc/ -regextype posix-egrep -regex "/etc/sudoers.[0-9]+-[0-9]+-[0-9]+" -exec rm -rf {} \;
  cp /etc/sudoers /etc/sudoers.$(date +%F)
  for ((i=0; i<counts; i++)) do
    id ${user_arr[i]} > /dev/null 2>&1
    if [[ $? != 0 ]]; then
      err[err_cnt]=${user_arr[i]}
      ((err_cnt++))
      continue
    fi
    grep -q "${user_arr[i]}" /etc/sudoers
    if [[ $? == 0 ]]; then
      added[added_cnt]=${user_arr[i]}
      ((added_cnt++))
    else
      chattr -i /etc/sudoers
      echo "${user_arr[i]}  ALL=(ALL)   NOPASSWD: ALL,/usr/bin/passwd [a-zA-Z0-9_-]*,!/usr/bin/passwd,!/usr/bin/passwd root,!/usr/sbin/visudo" >> /etc/sudoers
      to_add[toadd_cnt]=${user_arr[i]}
      ((toadd_cnt++))
      chattr +i /etc/sudoers
    fi
  done
  for ((i=0; i<toadd_cnt; i++)) do
    grep -q "${to_add[i]}" /etc/sudoers
    if [[ $? == 0 ]]; then
      action "add sudoer for ${to_add[i]} successfully"  /bin/true
    else
      action "add sudoer for ${to_add[i]} failed" /bin/false
    fi
  done
  for ((i=0; i<added_cnt; i++)) do
    action "user:${added[i]} has been added in sudoers file before" /bin/true
  done
  for ((i=0; i<err_cnt; i++)) do
    action "user:${err[i]} does not exist" /bin/false
  done
  echo "========================================================="
  echo ""
  sleep 2
}

#config Yum CentOS7-aliyun.repo
config_yum() {
  echo "==============config yum with aliyun repo================"
  for i in /etc/yum.repos.d/*.repo
  do
    mv $i ${i%.repo}.$(date +%F)
  done
  # wget -O /etc/yum.repos.d/CentOS7-aliyun.repo http://mirrors.aliyun.com/repo/Centos-7.repo > /dev/null 2>&1
  curl -o /etc/yum.repos.d/CentOS7-aliyun.repo http://mirrors.aliyun.com/repo/Centos-7.repo > /dev/null 2>&1
  if [[ $? != 0 ]]; then
    action "config aliyun yum repository failed"  /bin/false
  else
    yum clean all;yum makecache;yum repolist
    sleep 2
    action "config aliyun yum repository successfully"  /bin/true
  fi
  echo "========================================================="
  echo ""
  sleep 2
}

#Charset zh_CN.UTF-8
config_charset() {
  echo "==============config LC_CTYPE=zh_CN.UTF-8================"

  #config root
  linenum=$(grep -wn "^LC_CTYPE" ~/.bash_profile | awk -F ':' '{print $1}')
  if [[ $linenum != 0 && $linenum != "" ]]; then
    sed -in "${linenum}c LC_CTYPE=zh_CN.UTF-8" ~/.bash_profile
  else
    echo "LC_CTYPE=zh_CN.UTF-8" >> ~/.bash_profile
  fi
  . ~/.bash_profile
  action "config root with LC_CTYPE=zh_CN.UTF-8 successfully" /bin/true
  #config other users
  read -p "config other users with LC_CTYPE?[y/n]:" option
  if [[ $option == "y" || $option == "Y" ]]; then
    for user in $(ls /home)
    do
      id $user > /dev/null 2>&1
      if [[ $? == 0 ]]; then
        cat /etc/passwd | grep -w "$user" | grep "nologin" > /dev/null
        if [[ $? == 0 ]]; then
          continue
        fi
        echo "config for user:${user}"
        linenum=$(grep -wn "^LC_CTYPE" /home/$user/.bash_profile | awk -F ':' '{print $1}')
        if [[ $linenum != 0 && $linenum != "" ]]; then
          sed -in "${linenum}c LC_CTYPE=zh_CN.UTF-8" /home/$user/.bash_profile
        else
          echo "LC_CTYPE=zh_CN.UTF-8" >> /home/$user/.bash_profile
        fi
        . /home/$user/.bash_profile
      fi
    done
  fi
  action "config other users with LC_CTYPE=zh_CN.UTF-8 successfully" /bin/true
  echo "========================================================="
  echo ""
  sleep 2
}

#Close Selinux and Iptables
config_firewall() {
  echo "==========forbidden selinux and close iptables==========="
  cp /etc/selinux/config /etc/selinux/config.$(date +%F)
  systemctl stop firewalld
  systemctl disable firewalld
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  systemctl status firewalld
  iptables -F
  echo 'run cmd:grep SELINUX=disabled /etc/selinux/config '
  grep SELINUX=disabled /etc/selinux/config
  echo 'run cmd:getenforce '
  getenforce
  echo 'run cmd:iptables -L'
  iptables -L
  action "forbidden selinux and close iptables successfully" /bin/true
  echo "========================================================="
  echo ""
  sleep 2
}

#Change sshd default port to 22
config_default_ssh_port() {
  echo "======confirm ssh port is 22,if not,change to 22========="
  port=$(grep -wE '^Port' /etc/ssh/sshd_config | awk -F '\\s+' '{print $2}')
  if [[ $port != 22 && $port != "" ]]; then
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%F)
    sed -i "s/Port=$port/Port=22/g" /etc/ssh/sshd_config
    systemctl restart sshd.service && action "config ssh port successfully" /bin/true || action "config ssh port failed" /bin/false
  else
    echo "change nothing,ssh port has been set to 22"
  fi
  echo "========================================================="
  echo ""
  sleep 2
}

#setting history
config_history() {
  echo "=============history command size=2000==================="
  linenum=$(grep -wn "^HISTSIZE" /etc/profile | awk -F ':' '{print $1}')
  if [[ $linenum != 0 && $linenum != "" ]]; then
    sed -in "${linenum}c HISTSIZE=2000" /etc/profile
  else
    echo "HISTSIZE=2000" >> /etc/profile
  fi
  linenum=$(grep -wn "^HISTTIMEFORMAT" /etc/profile | awk -F ':' '{print $1}')
  if [[ $linenum != 0 && $linenum != "" ]]; then
    sed -in "${linenum}c HISTTIMEFORMAT='%F %T \`whoami\`=> '" /etc/profile
  else
    echo "HISTTIMEFORMAT='%F %T `whoami`=> '" >> /etc/profile
  fi
  source /etc/profile && action "config history successfully" /bin/true || action "config history failed" /bin/false
  echo "========================================================="
  echo ""
  sleep 2
}

#install tools
install_sys_tools() {
  echo "======install sysstat|dos2unix|openssl|openssh|bash|ftp======"
  ping -c 2 mirrors.aliyun.com
  sleep 1
  yum install sysstat dos2unix openssl openssh bash ftp -y
  sleep 1
  action "install tools successfully" /bin/true
  echo "========================================================="
  echo ""
  sleep 2
}

#Adjust the file descriptor and max process
#values in 20-nproc.conf will override /etc/securty/limits.conf
config_limits() {
  echo "===============config file descriptor===================="
  echo -e "\033[36mwe will use below setting, * means all the users, you should relogin after setting\033[0m"
  echo ""
  echo "************************"
  echo "*    - nofile 512k"
  echo "*    - nproc  128k"
  echo "************************"
  echo ""
  local limit=$(grep -v -e "^#" -e "^$" /etc/security/limits.d/20-nproc.conf)
  if [[ -z "${limit}" ]]; then
    cat >> /etc/security/limits.d/20-nproc.conf<<EOF
*    - nofile 524288
*    - nproc  131072
EOF
  else
    echo "current limit is:"
    echo "${limit}"
    echo ""
    read -p "are you sure to replace current setting with metioned earlier[y/n]:"
    if [[ "${REPLY}" == "y" || "${REPLY}" == "Y" ]]; then
      sed -r -i -e "/.*nproc.*/d" -e "/.*nofile.*/d" /etc/security/limits.d/20-nproc.conf
      cat >> /etc/security/limits.d/20-nproc.conf<<EOF
*    - nofile 524288
*    - nproc  131072
EOF
      echo 'run cmd:tail -4 /etc/security/limits.d/20-nproc.conf'
      tail -4 /etc/security/limits.d/20-nproc.conf
      action "config nofile and nproc successfully" /bin/true
      echo "========================================================="
      echo ""
      sleep 2
    fi
  fi
}


#Optimizing the system kernel
config_sysctl() {
  echo "====================config sysctl========================"
  shmall=$(expr $(getconf _PHYS_PAGES) / 2)
  shmmax=$(expr $(getconf _PHYS_PAGES) / 2 \* $(getconf PAGE_SIZE))
  echo -e "\033[36mwe will use below settings:\033[0m"
  echo "***************************************"
  echo "kernel.shmall = ${shmall}"
  echo "kernel.shmmax = ${shmmax}"
  echo "kernel.shmmni = 4096"
  echo "vm.overcommit_memory = 2"
  echo "vm.overcommit_ratio = 95"
  echo "net.ipv4.ip_local_port_range = 10000 65535"
  echo "kernel.sem = 500 2048000 200 4096"
  echo "kernel.sysrq = 1"
  echo "kernel.core_uses_pid = 1"
  echo "kernel.msgmnb = 65536"
  echo "kernel.msgmax = 65536"
  echo "kernel.msgmni = 2048"
  echo "net.ipv4.tcp_syncookies = 1"
  echo "net.ipv4.conf.default.accept_source_route = 0"
  echo "net.ipv4.tcp_max_syn_backlog = 4096"
  echo "net.ipv4.conf.all.arp_filter = 1"
  echo "net.core.netdev_max_backlog = 10000"
  echo "net.core.rmem_max = 2097152"
  echo "net.core.wmem_max = 2097152"
  echo "vm.swappiness = 10"
  echo "vm.zone_reclaim_mode = 0"
  echo "vm.dirty_expire_centisecs = 500"
  echo "vm.dirty_writeback_centisecs = 100"
  echo "vm.dirty_background_ratio = 0"
  echo "vm.dirty_ratio = 0"
  echo "vm.dirty_background_bytes = 1610612736"
  echo "vm.dirty_bytes = 4294967296"
  echo "***************************************"
  sleep 2
  grep -q "${shmmax}" /etc/sysctl.conf
  if [[ $? != 0 ]]; then
    cp /etc/sysctl.conf /etc/sysctl.conf.$(date +%F)
    cat >> /etc/sysctl.conf<<EOF
kernel.shmall = ${shmall}
kernel.shmmax = ${shmmax}
kernel.shmmni = 4096
vm.overcommit_memory = 2
vm.overcommit_ratio = 95
net.ipv4.ip_local_port_range = 10000 65535
kernel.sem = 500 2048000 200 4096
kernel.sysrq = 1
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.msgmni = 2048
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.conf.all.arp_filter = 1
net.core.netdev_max_backlog = 10000
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
vm.swappiness = 10
vm.zone_reclaim_mode = 0
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100
vm.dirty_background_ratio = 0
vm.dirty_ratio = 0
vm.dirty_background_bytes = 1610612736
vm.dirty_bytes = 4294967296
EOF
    sysctl -p && action "kernel setting successfully" /bin/true || action "kernel setting failed" /bin/false
  else
    local settings=$(grep -E -v -e "^\s*$" -e "^#" /etc/sysctl.conf)
    echo "current settings are:"
    echo "${settings}"
    read -p "are you sure to replace current settings with metioned earlier?[y/n]:"
    if [[ "${REPLY}" == "y" || "${REPLY}" == "Y" ]]; then
      sed -i -r -n '/^#/!d' /etc/sysctl.conf
      cat >> /etc/sysctl.conf<<EOF
kernel.shmall = ${shmall}
kernel.shmmax = ${shmmax}
kernel.shmmni = 4096
vm.overcommit_memory = 2
vm.overcommit_ratio = 95
net.ipv4.ip_local_port_range = 10000 65535
kernel.sem = 500 2048000 200 4096
kernel.sysrq = 1
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.msgmni = 2048
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.conf.all.arp_filter = 1
net.core.netdev_max_backlog = 10000
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
vm.swappiness = 10
vm.zone_reclaim_mode = 0
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 100
vm.dirty_background_ratio = 0
vm.dirty_ratio = 0
vm.dirty_background_bytes = 1610612736
vm.dirty_bytes = 4294967296
EOF
    sysctl -p && action "kernel setting successfully" /bin/true || action "kernel setting failed" /bin/false
    fi
  fi
  echo "========================================================="
  echo ""
  sleep 2
}

#time sync
config_outer_sync_time() {
  echo "================config internet time sync================"
  NTPDATE=$(grep ntpdate /var/spool/cron/root 2>/dev/null | wc -l)
  if [[ $NTPDATE == 0 ]]; then
    yum list installed | grep -w ntpdate > /dev/null 2>&1
    if [[ $? != 0 ]]; then
      yum install ntpdate -y
    fi
    cp /var/spool/cron/root /var/spool/cron/root.$(date +%F) 2>/dev/null
    echo "#times sync by script at $(date +%F)" >> /var/spool/cron/root
    echo "*/5 * * * * /usr/sbin/ntpdate time.windows.com &>/dev/null" >> /var/spool/cron/root
  fi
  echo 'run cmd:crontab -l'
  crontab -l
  action "config time sync successfully" /bin/true
  echo "========================================================="
  echo ""
  sleep 2
}

config_inner_sync_time() {
  echo "================config intranet time sync================"
  sync="ntpd"
  while true
  do
    case $sync in
      "ntpd")
        read -p "input ntp server ip:" ntpserver
        if [[ $ntpserver == "" ]]; then
          continue
        fi
        sync="ntpc"
        ;;
      "ntpc")
        sync=
        read_ip "" "ntp client ip list"
        ;;
      *)
        break
        ;;
    esac
  done
  echo -e "\n*****config ntp server($ntpserver)*****\n"
  ssh -o StrictHostKeyChecking=no root@$ntpserver '\
  rpm -q ntp > /dev/null || yum list installed | grep -w ntp > /dev/null;
  if [[ $? != 0 ]]; then
    echo -e "\n******install ntpd*******\n";
    yum install ntp -y;
  fi
  if [[ $? == 0 ]]; then
    ls /etc/ntp.conf.origin > /dev/null 2>&1;
    if [[ $? != 0 ]]; then
      cp /etc/ntp.conf /etc/ntp.conf.origin> /dev/null 2>&1;
    else
      cp /etc/ntp.conf /etc/ntp.conf.$(date +%F) > /dev/null 2>&1;
    fi
    cat > /etc/ntp.conf <<EOF
driftfile /var/lib/ntp/drift
restrict default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict ::1
server 127.127.1.0
fudge  127.127.1.0 stratum 10
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
disable monitor
EOF
    systemctl enable ntpd;
    systemctl start  ntpd;
  else
    echo -e "\n******install ntpd failed******\n";
  fi
  '
  local counts=${#iplist[@]}
  for ((i=0; i<counts; i++)) do
    if [[ ${iplist[i]} == $ntpserver ]]; then
      echo -e "\nclient ip(${iplist[i]}) is same as ntpserver,skip this ip\n"
      continue
    fi
    echo -e "\n*****config ntp client(${iplist[i]})******\n"
    ssh -o StrictHostKeyChecking=no root@${iplist[i]} "
    rpm -q ntpdate > /dev/null || yum list installed | grep -w ntpdate > /dev/null;
    if [[ \$? != 0 ]]; then
      echo -e \"\n******install ntpdate*******\n\";
      yum install ntpate -y;
    fi
    if [[ \$? == 0 ]]; then
      /usr/sbin/ntpdate $ntpserver
      cp /var/spool/cron/root /var/spool/cron/root.\$(date +%F) 2>/dev/null
      line=\$(grep -nw '/usr/sbin/ntpdate' /var/spool/cron/root | awk -F':' '{print \$1}')
      if [[ \$line == \"\" ]]; then
        echo \"*/30 * * * * /usr/sbin/ntpdate $ntpserver\" >> /var/spool/cron/root
      else
        sed -i \"\${line}c */30 * * * * /usr/sbin/ntpdate $ntpserver\" /var/spool/cron/root
      fi
      echo \"run remote cmd: crontab -l\"
      crontab -l
    else
      echo -e \"\n******install ntpdate failed******\n\"
    fi
    "
  done
  [ $? == 0 ] && action "config intranet time sync completely" /bin/true || action "config intranet time sync failed" /bin/false
  echo
  echo "========================================================="
  echo ""
  sleep 2
}

# $1: next step
read_name() {
  read -p "input authorized user name that you want to:" name
  if [[ $name == "" ]]; then
    read -p "input user name is null, quit?[y/n]:"
    if [[ "${REPLY}" == "y" || "${REPLY}" == "Y" ]]; then
      step="quit"
      return 1;
    else
      read_name $1
    fi
  fi
  step=$1
}

# $1: next step
read_pwd() {
  echo -e "\033[36mnotes:you should confirm there is the same password with the ${name} user for next ip list of your input\033[0m"
  read -p "input password belongs to ${name}:" password
  if [[ "${password}" == "" ]]; then
    read -p "input password is null, quit?[y/n]:"
    if [[ "${REPLY}" == "y" || "${REPLY}" == "Y" ]]; then
      step="quit"
      return 1;
    else
      read_pwd $1
    fi
  fi
  step=$1
}

# $1: next step
# $2: prompt information
read_ip() {
  read -p "input $2, for example ip1,ip2,ip3...:" ips
  if [[ $ips == "" ]]; then
    read -p "input ip address list is null, quit?[y/n]:"
    if [[ "${REPLY}" == "y" || "${REPLY}" == "Y" ]]; then
      step="quit"
      return 1
    else
      read_ip $1 $2
    fi
  fi
  iplist=(${ips//,/ })
  #whether ip format is correct or not
  # for ip in ${iplist[@]}
  local counts=${#iplist[@]}
  for ((i=0; i<counts; i++)) do
    ip=${iplist[i]}
    echo $ip | grep -wP "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" > /dev/null
    if [[ $? != 0 ]]; then
      echo "$ip format is wrong"
      step="ip"
      return 1
    fi
    for ((j=0; j<counts; j++)) do
      if [[ $i != $j ]]; then
        if [[ ${iplist[i]} == ${iplist[j]} ]]; then
          echo "there are two same ip address:${iplist[i]}"
          step="ip"
          return 1
        fi
      fi
    done
  done
  step=$1
}

echo_authorization_info() {
  echo ""
  echo "*************************************************************************************************"
  echo "* 1.input user name that you want to authorise,for example dce or other user"
  echo "* 2.input ip list that you want to authorise"
  echo "* 3.please input [enter] according to the prompt,don't input [y] when prompt Overwrite (y/n)?"
  echo "* 4.if authorization does not work"
  echo "*   a)please confirm permission of ~/.ssh/authorized_keys is 0600(-rw-------)"
  echo "*   b)please confirm permission of /home/xxx is 0700(drwx------)"
  echo "*************************************************************************************************"
  echo ""
}

config_authorization_bothway() {
  echo "==================Authorization=========================="
  echo_authorization_info
  while true
  do
    case $step in
      "ip")
        read_ip "auth" "ip list"
        ;;
      "auth")
        break
        ;;
      "quit")
        break
        ;;
      "name")
        read_name "ip"
        ;;
      *)
        read_name "ip"
        ;;
    esac
  done
  if [[ $step == "quit" ]]; then
    return 1
  fi
  if [[ $step == "auth" ]]; then
    local counts=${#iplist[@]}
    #cat ~/.ssh/id_rsa.pub | ssh user@machine "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"
    for ((i=0; i<counts; i++)) do
      for ((j=0; j<counts; j++)) do
        echo -e "\n\033[36m*****Authorise ip:${iplist[i]}=>ip:${iplist[j]}*****\033[0m"
        echo -e "\033[36m*****login ip:${iplist[i]} as $name******\033[0m\n"
        ssh -tt -o StrictHostKeyChecking=no $name@${iplist[i]} "
        ls ~/.ssh/id_rsa.pub > /dev/null 2>&1
        if [[ \$? != 0 ]]; then
          echo -e \"\n\033[36m*****generate rsa key*****\033[0m\n\";
          ssh-keygen -t rsa;
        fi
        echo -e \"\n\033[36m*****copy id_rsa.pub to ip:${iplist[j]}*****\033[0m\n\";
        ssh-copy-id -o StrictHostKeyChecking=no ${name}@${iplist[j]};
        "
        echo ""
        sleep 1
      done
    done
  fi
  step="name"
  echo "========================================================="
}

config_authorization_oneway() {
  echo "==================Authorization=========================="
  echo_authorization_info
  while true
  do
    case $step in
      "pwd")
        read_pwd "ip"
        ;;
      "ip")
        read_ip "auth" "ip list"
        ;;
      "auth")
        break
        ;;
      "quit")
        break
        ;;
      "name")
        read_name "pwd"
        ;;
      *)
        read_name "pwd"
        ;;
    esac
  done
  if [[ $step == "quit" ]]; then
    return 1
  fi
  if [[ $step == "auth" ]]; then
    local counts=${#iplist[@]}
    #cat ~/.ssh/id_rsa.pub | ssh user@machine "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"
    if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
      echo -e \"\n\033[36m*****generate local machine rsa key*****\033[0m\n\";
      ssh-keygen -t rsa
    fi
    #quiet mode
    install_sshpass -q
    local ret_arr=()
    for ((i=0; i<counts; i++)) do
      echo -e "\n\033[36m*****Authorise ip:${IPADDR}=>ip:${iplist[i]}*****\033[0m"
      sshpass -p ${password} ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.pub ${name}@${iplist[i]}
      ret_arr[i]=$?
    done
  fi
  for ((i=0; i<counts; i++)) do
    if [[ ${ret_arr[i]} == 0 ]]; then
      action "authorized ip:${iplist[i]}" /bin/true
    else
      action "authorized ip:${iplist[i]}" /bin/false
    fi
  done
  step="name"
  echo "========================================================="
  sleep 5
}

# set backspace as erase for root and all login users(/home/*)
config_backspace() {
  echo "================config backspace as erase================"
  echo "config for user:root"
  erase=$(grep -wx "stty erase ^H" /root/.bash_profile | wc -l)
  if [[ $erase < 1 ]]; then
    cp /root/.bash_profile  /root/.bash_profile.$(date +%F)
    echo "stty erase ^H" >> /root/.bash_profile
    source /root/.bash_profile
  fi
  for user in $(ls /home)
  do
    id $user > /dev/null 2>&1
    if [[ $? == 0 ]]; then
      cat /etc/passwd | grep -w "$user" | grep "nologin" > /dev/null
      if [[ $? == 0 ]]; then
        continue
      fi
      echo "config for user:${user}"
      erase=$(grep -wx "stty erase ^H" /home/$user/.bash_profile | wc -l)
      if [[ $erase < 1 ]]; then
        cp /home/$user/.bash_profile /home/$user/.bash_profile.$(date +%F)
        echo "stty erase ^H" >> /home/$user/.bash_profile
        # source /home/$user/.bash_profile
      fi
    fi
  done

  action "config backspace to erase successfully" /bin/true
  echo "========================================================="
  echo ""
  sleep 2
}

ftp_check() {
  which ftp > /dev/null 2>&1
  if [[ $? != 0 ]]; then
    yum install ftp
  fi
}

install_sshpass() {
  which sshpass > /dev/null 2>&1
  if [[ $? > 0 ]]; then
    ftp_check
    ftp -inv <<EOF
open ${SSH_IP}
user ${SSH_USER} ${SSH_PASS}
bin
cd zhanghao
mget sshpass-1.05.tar.gz
quit
EOF
    tar zxf sshpass-1.05.tar.gz && cd sshpass-1.05
    ./configure && make && sudo make install
    sshpass -V > /dev/null 2>&1 && action "install sshpass successfully" /bin/true || action "install sshpass successfully" /bin/false
    cd .. && rm -rf sshpass-1.05
  else
    if [[ $# == 0 ]]; then
      echo "sshpass has already been installed in your environment"
    fi
  fi
}

scp_get() {
  if [[ $1 == "ftp" ]]; then
    local FILE=$2
    sshpass -p ${SSH_PASS} scp -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_IP}:${SSH_PATH}/${FILE} $3
  elif [[ $1 == "cmd" ]]; then
    local CMD=$2
    sshpass -p ${SSH_PASS} ssh -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_IP} "${CMD}"
  else
    echo "unsupport parameter:$1 for scp_get"
  fi
}

install_arthas() {
  install_sshpass
  scp_get ftp 'arthas*.zip' '.'
  if [[ $? == 0 ]]; then
    unzip -d tmp arthas*.zip
    rm -rf arthas*.zip > /dev/null 2>&1
    chmod 755 tmp/*.sh && chmod 755 tmp/*.jar && sudo cp -r tmp/* /usr/bin && rm -rf tmp
    [ $? == 0 ] && action "install arthas successfully" /bin/true || action "install arthas failed" /bin/false
  fi
}

install_nvim() {
  scp_get "nvim-0.4.3.appimage" '.'
  chmod u+x nvim-0.4.3.appimage && ./nvim-0.4.3.appimage --appimage-extract && sudo cp -r squashfs-root/usr/* /usr
  [ $? == 0 ] && action "install nvim successfully" /bin/true || action "install nvim failed" /bin/false
  rm -rf squashfs-root
}

install_vscodeserver() {
  VERSION_INFO="$(scp_get cmd "cd ${SSH_PATH};ls vscode-server*.gz")"
  VERSION_INFO=(${VERSION_INFO})
  VERSION_ARR=($(echo "${VERSION_INFO[@]}" | tr " +" '\n' | sort -n))
  while true
  do
    echo ""
    local COUNT=${#VERSION_ARR[@]}
    local NUM=1
    local VERSION=
    for i in "${VERSION_ARR[@]}"; do
      VERSION=${i//vscode-server-linux-x64-/}
      VERSION=${VERSION//.tar.gz/}
      echo -e "\033[36m(${NUM}) install ${VERSION}"
      ((NUM=NUM+1))
    done
    echo -e "\033[36m(0) exit\033[0m"
    read -p "Please enter your choice[0-${COUNT}]: " input1
    case "$input1" in
      0)
        clear
        return
        ;;
      1|2|3|4|5)
        break
        ;;
      *)
        echo "----------------------------------"
        echo "|   Please enter right choice!   |"
        echo "----------------------------------"
        sleep 1
        clear
        ;;
    esac
  done
  ((IDX=$input1-1))
  scp_get ftp "${VERSION_ARR[${IDX}]}" '.'
  ls vscode*.gz > /dev/null 2>&1 || action "install vscode-server failed" /bin/false || return

  VERSION="${VERSION_ARR[${IDX}]}"
  VERSION=${VERSION//vscode-server-linux-x64-/}
  VERSION=${VERSION//.tar.gz/}
  COMMITID=$(scp_get cmd "cd ${SSH_PATH};grep ${VERSION} commitid")
  COMMITID=$(echo ${COMMITID} | awk '{print $2}')
  [ ! -z ${COMMITID} ] || action "install vscode-server failed" /bin/false || return

  read -p "Please enter the account list under which you want to install,e.x. dce,root,mt: " input1
  local USER_LIST=(${input1//,/ })
  local ERR_FALG=0
  local USER=
  for USER in "${USER_LIST[@]}"; do
    id ${USER} > /dev/null 2>&1
    if [[ $? > 0 ]]; then
      echo "user:${USER} is not exist, install vscode-server under ${USER} failed"
      ((ERR_FALG=${ERR_FALG}+1))
      continue
    fi
    local base=''
    if [[ ${USER} == "root" ]]; then
      base="/root"
    else
      base="/home/${USER}"
    fi
    rm -rf ${base}/.vscode-server/bin/${COMMITID}
    mkdir -p ${base}/.vscode-server/bin/${COMMITID} && \
    tar zxf "${VERSION_ARR[${IDX}]}" -C ${base}/.vscode-server/bin/${COMMITID} --strip-components=1 && \
    chown -R ${USER}:${USER} ${base}/.vscode-server
    [ $? -gt 0 ] && ((ERR_FALG=${ERR_FALG}+1)) || echo "install vscode-server under ${USER} successfully"
  done
  [ ${ERR_FALG} -eq 0 ] && action "install vscode-server task successfully" /bin/true || action "install vscode-server task failed" /bin/false
  rm -rf "${VERSION_ARR[${IDX}]}"
}

install_ansible() {
  install_sshpass
  scp_get ftp 'ansible*.zip' '.'
  if [[ $? == 0 ]]; then
    unzip -d tmp ansible*.zip
    rm -rf ansible*.zip > /dev/null 2>&1
    cd tmp && sudo yum -y install *.rpm && cd .. && rm -rf tmp
    [ $? == 0 ] && action "install ansible successfully" /bin/true || action "install ansible failed" /bin/false
  fi
}

install_git() {
  which git >/dev/null 2>&1
  if [[ $? == 0 ]]; then
    local major=$(git --version | awk '{print $3}' | awk -F '.' '{print $1}')
    if [[ ${major} -eq 2 ]]; then
      read -p "git version is >= 2, it meets requirement of vscode, do you still want to install version-2.28.0?[y/n]"
      if [[ ${REPLY} == 'n' ]]; then
        return
      fi
    fi
  fi
  scp_get ftp "git*.gz" '.'
  local rt=0
  if [[ $? == 0 ]]; then
    tar -zxf git*.gz
    yum remove git
    yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel asciidoc xmlto perl-devel perl-CPAN autoconf*
    cd git*
    make configure
    ./configure --prefix=/usr/local/git --with-iconv=/usr/local/libiconv
    make all doc
    make install
    rt=$?
    grep -q "/usr/local/git/bin" /etc/bashrc
    if [[ $? != 0 ]]; then
      echo 'export PATH=/usr/local/git/bin:$PATH' >> /etc/bashrc
    fi
    cd ..
    rm -rf git*
  fi
  [ ${rt} -eq 0 ] && action "install git successfully" /bin/true || action "install git failed" /bin/false
}

install_nodejs() {
  local ver=14
  which node >/dev/null 2>&1
  if [[ $? == 0 ]]; then
    local major=$(node -v | awk -F '.' '{print $1}')
    if [[ ${major} -eq ${ver} ]]; then
      read -p "node major version is ${ver}, it is ok, do you still want to install version-14.11.0?[y/n]"
      if [[ ${REPLY} == 'n' ]]; then
        return
      fi
    fi
  fi
  scp_get ftp "node*.gz" '.'
  if [[ $? == 0 ]]; then
    mkdir -p /usr/local/node${ver}
    tar -zxf node*.gz --strip-components=1 -C /usr/local/node${ver}
    grep -q "/usr/local/node${ver}/bin" /etc/bashrc
    if [[ $? != 0 ]]; then
      echo "export PATH=/usr/local/node${ver}/bin:\$PATH" >> /etc/bashrc
    fi
  fi
  [ $? -eq 0 ] && action "install node successfully" /bin/true || action "install node failed" /bin/false
}

install_neovim() {
  local ver="0.4.3"
  scp_get ftp "nvim*.gz" '.'
  if [[ $? == 0 ]]; then
    mkdir -p /usr/local/nvim-${ver}
    tar -zxf nvim*.gz --strip-components=1 -C /usr/local/nvim-${ver}
    grep -q "/usr/local/nvim-${ver}/bin" /etc/bashrc
    if [[ $? != 0 ]]; then
      echo "export PATH=/usr/local/nvim-${ver}/bin:\$PATH" >> /etc/bashrc
    fi
  fi
  [ $? -eq 0 ] && action "install neovim successfully" /bin/true || action "install neovim failed" /bin/false
}

install_other_tools() {
  while true
  do
    echo ""
    echo -e "\033[36m(1) install sshpass"
    echo -e "\033[36m(2) install arthas"
    echo -e "\033[36m(3) install vscode-server"
    echo -e "\033[36m(4) install ansible"
    echo -e "\033[36m(5) install git(v2.28.0)"
    echo -e "\033[36m(6) install nodejs(v14.11.0)"
    echo -e "\033[36m(7) install neovim(v0.4.3)"
    echo -e "\033[36m(0) exit\033[0m"
    read -p "Please enter your choice[0-7]: "
    case "${REPLY}" in
      0)
        clear
        break
        ;;
      1)
        install_sshpass
        ;;
      2)
        install_arthas
        ;;
      3)
        install_vscodeserver
        ;;
      4)
        install_ansible
        ;;
      5)
        install_git
        ;;
      6)
        install_nodejs
        ;;
      7)
        install_neovim
        ;;
      *)
        echo "----------------------------------"
        echo "|   Please enter right choice!   |"
        echo "----------------------------------"
        sleep 1
        clear
        ;;
    esac
  done
}

update() {
  install_sshpass -q
  which sshpass > /dev/null 2>&1
  if [[ $? == 0 ]]; then
    NEW_VERSION=$(scp_get cmd "/home/share/ftp/zhanghao/centos7.sh -v")
    NEW_VERSION=$(echo ${NEW_VERSION} | awk -F ':' '{print $2}')
    MAJOR=$(echo ${VERSION} | awk -F '.' '{print $1}')
    MINOR=$(echo ${VERSION} | awk -F '.' '{print $2}')
    PATCH=$(echo ${VERSION} | awk -F '.' '{print $3}')
    PATCH=$([ -z ${PATCH} ] && echo 0 || echo ${PATCH})
    NEW_MAJOR=$(echo ${NEW_VERSION} | awk -F '.' '{print $1}')
    NEW_MINOR=$(echo ${NEW_VERSION} | awk -F '.' '{print $2}')
    NEW_PATCH=$(echo ${NEW_VERSION} | awk -F '.' '{print $3}')
    if [[ ${NEW_MAJOR} -gt ${MAJOR} || ${NEW_MINOR} -gt ${MINOR} || ${NEW_PATCH} -gt ${PATCH} ]]; then
      echo -e "\033[36mthere is a new version, upgrading...\033[0m"
      echo -e "\033[36mRELEASE NOTES:\033[0m"
      REMOTE_NOTES=$(scp_get cmd "grep -w ^RELEASE_NOTES= /home/share/ftp/zhanghao/centos7.sh")
      echo ${REMOTE_NOTES} | sed -e 's/RELEASE_NOTES=//' -e 's/"//g'
      read -p "upgrade or not?[y/n]"
      if [[ "${REPLY}" == "" || "${REPLY}" == "y" ]]; then
        scp_get ftp "centos7.sh" "/root"
        echo -e "\033[36mupgrade finished, shell will exit in 3 seconds\033[0m"
        sleep 3
        exit 0
      fi
    fi
  fi
}

main() {
  if [[ $1 != "-q" ]]; then
    update
  fi
  clear
  echo ""
  echo -e "\033[36m|--------------------System Infomation----------------------"
  echo -e "\033[36m| DATE           :$DATE"
  echo -e "\033[36m| HOSTNAME       :$HOSTNAME"
  echo -e "\033[36m| USER           :$USER"
  echo -e "\033[36m| IP             :$IPADDR"
  echo -e "\033[36m| DISK_USED      :$DISK_SDA"
  echo -e "\033[36m| CPU_PROCESSORS :$CPU_PROCESSORS"
  echo -e "\033[36m| CPU_CORES      :$CPU_CORES"
  echo -e "\033[36m| CPU_MODEL      :$CPU_MODEL"
  echo -e "\033[36m| TOTAL MEMORY   :$MEMORY"
  echo -e "\033[36m| CNETOS         :$CENTOS_VERSION"
  echo -e "\033[36m| KERNEL         :$KERNEL_VERSION"
  echo -e "\033[36m| JAVA           :$JAVA_VERSION"
  echo -e "\033[36m| GCC            :$GCC_VERSION"
  echo -e "\033[36m|-----------------------------------------------------------\033[0m"

  local ver=$(printf "%-59s*" "* version:${VERSION}")
  while true
  do
    echo ""
    echo -e "\033[36m*==========================================================*"
    echo -e "\033[36m*                    Dev2 Linux Utility                    *"
    echo -e "\033[36m*                                                          *"
    echo -e "\033[36m* Color Support:                                           *"
    echo -e "\033[36m* secureCRT->Terminal->Emulation->(Xterm+ANSI Color)       *"
    echo -e "\033[36m${ver}"
    echo -e "\033[36m*==========================================================*"
    echo -e "\033[36m(1)  config aliyun yum for internet environment, ***forbid run this function under the intranet environment***"
    echo -e "\033[36m(2)  create new user and config whether add sudoer or not"
    echo -e "\033[36m(3)  add special user to sudoer"
    echo -e "\033[36m(4)  config chinese encoding(LC_CTYPE=zh_CN.UTF-8)"
    echo -e "\033[36m(5)  forbid SElinux and stop firewall"
    echo -e "\033[36m(6)  config ssh default port to 22"
    echo -e "\033[36m(7)  config default history(command history=2000)"
    echo -e "\033[36m(8)  config backspace as delete"
    echo -e "\033[36m(9)  config nofile and nproc ulimit(nproc=128k;nofile=512k refer to requirements of GreenPlum)"
    echo -e "\033[36m(10) config linux kernel(refer to requirements of GreenPlum)"
    echo -e "\033[36m(11) install system tools(dos2unix|sysstat|openssl|openssh|bash|ftp)"
    echo -e "\033[36m(12) install other  tools(sshpass|arthas|vscode-server|ansible|git|nodejs|neovim)"
    echo -e "\033[36m(13) config NTP(sync time) under the internet environment"
    echo -e "\033[36m(14) config NTP(sync time) under the intranet environment"
    echo -e "\033[36m(15) config authorization cluster:bothway(A<=>B)"
    echo -e "\033[36m(16) config authorization cluster:one-way(A==>B) for ansible control mathine"
    echo -e "\033[36m(0)  exit\033[0m"
    read -p "Please enter your choice[0-16]: "
    case "${REPLY}" in
      0)
        clear
        break
        ;;
      1)
        config_yum
        ;;
      2)
        add_user
        ;;
      3)
        add_sudoer
        ;;
      4)
        config_charset
        ;;
      5)
        config_firewall
        ;;
      6)
        config_default_ssh_port
        ;;
      7)
        config_history
        ;;
      8)
        config_backspace
        ;;
      9)
        config_limits
        ;;
      10)
        config_sysctl
        ;;
      11)
        install_sys_tools
        ;;
      12)
        install_other_tools
        ;;
      13)
        config_outer_sync_time
        ;;
      14)
        config_inner_sync_time
        ;;
      15)
        config_authorization_bothway
        ;;
      16)
        config_authorization_oneway
        ;;
      *)
        echo "----------------------------------"
        echo "|   Please enter right choice!   |"
        echo "----------------------------------"
        sleep 1
        clear
        ;;
    esac
  done
}
main "$@"
