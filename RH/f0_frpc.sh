#!/bin/bash

# define var
SERVER_ADDR=s12.vmcc.xyz
FV=0.42.0
FD=~
FRP_BEGIN=9000
FRP_END=9006
LOG_FILE=/tmp/frp-setup.log
exec 4>${LOG_FILE}

# define function
function pad {
  echo -e "  $(date +%H:%M) [I] ${1}"
}

function nic_name {
  # file for BRIDEGE
  NICF0=$(grep -r BRIDGE /etc/sysconfig/network-scripts | cut -f1 -d:)
  # nic for bridge = ens160
  NICB=$(awk -F= '/DEVICE/ {print $2}' $NICF0)
  # internet of NIC = ens192
  NIC=$(nmcli dev status | awk '/ethernet/ {print $1}' | grep -v $NICB)
}

function nic_carrier {
  if nmcli -g WIRED-PROPERTIES.CARRIER dev show $NIC | grep -qw off; then
    echo -e "Please \e[5;43m check \e[0;39m VMware - 虚拟机 / 网络适配器 / [\e[1;37m网络适配器 2\e[0;29m]"
    exit
  fi
} 

function nic_up {
  # connection name
  if [ ! -z "$NIC" ]; then
    if grep -qwr $NIC /etc/sysconfig/network-scripts; then
      # file for ens192
      NICF1=$(grep -r $NIC /etc/sysconfig/network-scripts/ | cut -f1 -d: | uniq)
      NICN=$(awk -F= '/NAME/ {print $2}' $NICF1)
    fi
  else
    NICN=$(nmcli -g GENERAL.CONNECTION device show $NIC)
  fi
  # connection up
  nmcli con up $NICN
}

function frp_download {
  # download
  #wget https://github.com/fatedier/frp/releases/download/v${FV}/frp_${FV}_linux_amd64.tar.gz -O frp_${FV}_linux_amd64.tar.gz
  wget https://gitee.com/suzhen99/redhat/attach_files/1055184/download/frp_${FV}_linux_amd64.tar.gz -O frp_${FV}_linux_amd64.tar.gz
  #wget https://gitee.com/suzhen99/redhat/attach_files/1055229/download/frp_${FV}_linux_amd64.tar.gz -O frp_${FV}_linux_amd64.tar.gz
  # exists
  if [ -d ${FD}/frp_${FV}_linux_amd64 ]; then
    rm -r ${FD}/frp_${FV}_linux_amd64
  fi
  # extract
  tar -xf frp_${FV}_linux_amd64.tar.gz -C ${FD}
}

function frpc_port {
  FRP=$FRP_BEGIN
  while nc -w 1 $SERVER_ADDR $FRP &>/dev/null; do
    if [ $FRP == $FRP_END ]; then
      exit
    else
      FRP=$(expr $FRP + 1)
    fi
  done
}

function frpc_config {
  # frpc.ini
  sed -i -e "/server_addr/s/=.*/= $SERVER_ADDR/" \
    -e "/common/atoken = 4006906115" \
    -e "/remote_port/s/=.*/= $FRP/" ${FD}/frp_${FV}_linux_amd64/frpc.ini
}

function frpc_svc {
  # svc
  ${FD}/frp_${FV}_linux_amd64/frpc -c ${FD}/frp_${FV}_linux_amd64/frpc.ini
}

# Main 
nic_name >&4 2>&1
nic_carrier
pad "1/4: Connecting internet..."
nic_up >&4 2>&1
pad "2/4: Downloading frp_${FV}_linux_amd64.tar.gz..."
frp_download >&4 2>&1
frpc_port
pad "3/4: Modifing remote_port=\e[1;36m$FRP\e[0;39m in file frpc.ini"
frpc_config >&4 2>&1
pad "4/4: Starting frpc... Press \e[1;32mCtrl-C\e[0;39m to finish."
frpc_svc >&4 2>&1
