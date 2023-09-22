#!/bin/bash

# xrdp-0.9.18-3

function LINE {
  STTY_SIZE=$(stty size)
  STTY_COLUMNS=$(echo $STTY_SIZE | cut -f2 -d" ")
  yes = 2>/dev/null | sed $STTY_COLUMNS'q' | tr -d '\n'
}

function pad {
  echo -e " \033[1;32mINFO:\033[0;39m\t[\033[1;36m${1}\033[0;39m] - \033[1;32m${2}\033[0;39m"
}

function rht_usb_locale {
    # Failed to set locale, defaulting to C
    echo "export LC_ALL=en_US.UTF-8" >> /etc/profile
    source /etc/profile
}

function configure_repo {
    pad foundation "Configuring tuna repo"
    if grep -wq 8 /etc/redhat-release; then
        wget https://gitee.com/suzhen99/redhat/raw/master/centos-8-for-x86_64.repo -O /etc/yum.repos.d/centos-8-for-x86_64.repo >&4 2>&1
    fi
}

function install_pkgs {
    # xrdp xorgxrdp xorg-x11-server-Xorg xorg-x11-server-common
    pad foundation "Installing xrdp xorgxrdp"
    yum -y install xrdp xorgxrdp >&4 2>&1
}

function configure_file {
    pad foundation "Configuring default Xorg in xrdp.ini"
    sed -i.bk '/Xorg/,/^\[Xvnc/s|#||' /etc/xrdp/xrdp.ini
}

function configure_service {
    pad foundation "Starting xrdp service"
    systemctl enable --now xrdp &>/dev/null
}

function configure_firewall {
    pad foundation "Setting firewall"
    firewall-cmd --permanent --add-port=3389/tcp >&4 2>&1
    firewall-cmd --reload >&4 2>&1
}

# Main
if ! [ $(id -u) = 0 ]; then
    echo -e "\nPlease use root\n"
fi
LOGFILE=/tmp/xrdp-setup.log
exec 4>${LOGFILE}
echo $(date "+%b %d %T") foundation ================= >&4 2>&1
echo -e "
Please wait a moment, about \033[1;37m3\033[0m minutes. 
If you see more details, please open a new terminal, and type 
    \033[1;32mtail -f ${LOGFILE}\033[0;39m"
LINE
rht_usb_locale
configure_repo
install_pkgs
configure_file
configure_service
configure_firewall
pad WARNING 同一用户，不能"远程"和"本地"同时登陆
echo $(date "+%b %d %T") foundation ================= >&4 2>&1