#!/bin/bash

# define function
function pad {
    echo -e " $(date +%H:%M) \e[1;32m${1}\e[0;39m"
}
function LINE {
    STTY_SIZE=$(stty size)
    STTY_COLUMNS=$(echo $STTY_SIZE | cut -f2 -d" ")
    yes = 2>/dev/null | sed $STTY_COLUMNS'q' | tr -d '\n'
    printf "\n"
}
function check_tcp_port {
  # for wait_online
  if [[ ${#1} -gt 0 && ${#2} -gt 0 ]]; then
    # Sending it to the log always returns 0
    ($(echo "sven" >/dev/tcp/$1/$2)) && return 0
  fi
  return 1
}
function wait_online {
  # for available
  local TARGET=$1
  while !  ping -c1 -w1 ${TARGET} &> /dev/null
  do
    sleep 1s
  done
  while ! check_tcp_port ${TARGET} 22 2>/dev/null
  do
    sleep 1s
  done
}
function check_env {
    if [[ "$(id -u)" -ne "1000" ]]; then
        echo -e '. This script must be run as \e[1;36m$(id -un 1000)\e[0;0m'
        exit
    fi
    if [ "$(hostname -s)" != "$HN" ]; then
        echo
        echo -e ". Execute this script on the host \e[1;37m$HN\e[0;0m"
        echo
        exit
    fi
}
function ssh_config {
    # /etc/ssh/ssh_config
    sed -i '/^Host/a\    LogLevel ERROR' ~/.ssh/config
}
function ssh_unconfig {
    # /etc/ssh/ssh_config
    sed -i '/LogLevel ERROR/d' ~/.ssh/config
}
function ssh_hostkeys {
    # client_global_hostkeys_private_confirm: 
    # server gave bad signature for RSA key 0: 
    # error in libcrypto
    if ! grep -q UpdateHostKeys ~/.ssh/config; then
    cat >> ~/.ssh/config <<EOC
    UpdateHostKeys no
EOC
    fi
}

function repo_prepare {
    # 环境中存在 Yum 源缺失，导致软件无法安装
    local FISO=/content/rhcs5.0/x86_64/isos/rhel-8.4-x86_64-additional-202110061700.iso
    local FDIR=/content/rhel8.4/x86_64/rhel8-additional
    if [ ! -d $FDIR ]; then
        ssh root@localhost mkdir $FDIR
    fi
    ssh root@localhost "
    cat >> /etc/fstab <<EOF
$FISO   $FDIR   iso9660   loop,ro   0 0
EOF
    mount -a"
}

function start_VM {
    # return to original state, start VMNAME
    rht-vmctl -y start classroom
    wait_online classroom
    rht-vmctl -y reset all
}

function awscli_clienta {
    # install awscli
    wait_online clienta
    ssh root@clienta "
        cat > /etc/yum.repos.d/aws.repo <<EOF
[epel-8-for-x86_64-rpms]
name = awscli
baseurl = http://content.example.com/rhel8.4/x86_64/rhel8-additional/epel-8-for-x86_64-rpms
enabled = true
gpgcheck = false
EOF
        yum -y install awscli"
}

function kvm_serial {
    # 涉及到对 OSD 磁盘有操作的实验时，部分 lab 脚本执行报错
    # lab 脚本通过 ceph device ls 命令来获取 osd 对应的磁盘信息
    # 由于虚拟机中 osd 磁盘缺少 Serial 信息导致该命令返回空
    # 由此引发后续脚本的失败
    source /etc/rht
    DIR=/content/$RHT_VMTREE/vms
    if grep serial $DIR/${RHT_COURSE}-clienta.xml | wc -l | grep -wq 2; then
        for vm in client{a,b} server{c,d,e,f,g}; do
            NEW=0
            for LN in $(sed -n '/<\/disk/=' ${DIR}/${RHT_COURSE}-${vm}.xml); do
                ssh root@localhost "
                    sed -i '$(expr $LN + $NEW)i\      <serial>$RANDOM</serial>' \
                        ${DIR}/${RHT_COURSE}-${vm}.xml"
                NEW=$(expr $NEW + 1)
            done
        done
    fi
}

function kvm_mem {
    # 节约教学环境内存
    # 32 GiB == foundation
    source /etc/rht
    KDIR=/content/$RHT_VMTREE/vms

    ## xml
    # 2G classroom, bastion
    ssh root@localhost "
        sed -i '/mem/s+[0-9]+2+' \
            /var/lib/libvirt/images/cl260-classroom.xml \
            $KDIR/cl260-bastion.xml"
    # 4G workstation
    ssh root@localhost "
        sed -i '/mem/s+[0-9]+4+' $KDIR/cl260-workstation.xml"
    # 6G utility,clienta,server{c..e}
    # 6G clientb,server{f,g}
    for i in utility client{a,b} server{c..g}; do
        ssh root@localhost "
            sed -i '/mem/s+[0-9]+6+' $KDIR/cl260-$i.xml"
    done
    ## rht
    # server{f,g}, clientb
    ssh root@localhost "
        sed -i '/RHT_VMS/{s+ serverf++; s+ serverg++; s+ clientb++;}' /etc/rht"
}

function ceph_tab {
    ssh root@localhost \
        tee /content/tab <<EOF >/dev/null
#!/bin/bash

# 备份
mv /etc/yum.repos.d/ubi.repo /etc/yum.repos.d/ubi.repo.bk

# 新建
URL=http://content/rhel8.4/x86_64/dvd
cat > /etc/yum.repos.d/dvd.repo <<EOR
[base]
name=base
baseurl=\$URL/BaseOS/
gpgkey=\$URL/RPM-GPG-KEY-redhat-release
[app]
name=app
baseurl=\$URL/AppStream/
gpgkey=\$URL/RPM-GPG-KEY-redhat-release
EOR

# 安装
yum -y install bash-completion

# Tips
echo -e "\nPlease type \e[1;37msource /etc/profile\e[0;0m\n"
EOF
}

# Main Area
export SPATH=$(dirname $0)
LOG_FILE=/tmp/$(basename $0).log
HN=foundation0

check_env

exec 4>${LOG_FILE}
LINE
TM=8
echo -e "
   Please wait a moment, about \e[1;37m$TM\e[0;0m minutes. 
   If you see more details, please open a new terminal, and type

    \e[1;37mtail -f ${LOG_FILE}\e[0;0m"
LINE
echo
ssh_config

MSG='automate removing RHT_COURSE'
pad "$MSG" | tee ${LOG_FILE}
    rht-clearcourse 0 >&4 2>&1

MSG='set Course variable'
pad "$MSG" | tee -a ${LOG_FILE}
    rht-setcourse cl260 >&4 2>&1

MSG='ignore client_global_hostkeys_private_confirm'
pad "$MSG" | tee -a ${LOG_FILE}
    ssh_hostkeys >&4 2>&1

MSG='ceph device ls'
pad "$MSG" | tee -a ${LOG_FILE}
    kvm_serial >&4 2>&1

MSG='foundation 32 GiB ram'
pad "$MSG" | tee -a ${LOG_FILE}
    kvm_mem >&4 2>&1

MSG='return to original state, start VMNAME'
pad "$MSG" | tee -a ${LOG_FILE}
    start_VM >&4 2>&1

MSG='prepare repo for awscli'
pad "$MSG" | tee -a ${LOG_FILE}
    repo_prepare >&4 2>&1

MSG='install awscli'
pad "$MSG" | tee -a ${LOG_FILE}
    awscli_clienta >&4 2>&1

MSG='/content/tab'
pad "$MSG" | tee -a ${LOG_FILE}
    ceph_tab >&4 2>&1

ssh_unconfig
echo