#!/bin/bash

function check_env {
  # env
  if [[ "$(id -u)" -ne "1001" ]]; then
    echo -e '\033[1;31mError:\033[0;39m this script must be run as \033[1;36mstack\033[0;39m!'
    exit
  fi
  if [[ "$(hostname -s)" -ne "director" ]]; then
    echo -e '\033[1;31mError:\033[0;39m this script must be run on \033[1;33mdirector\033[0;39m!'
    exit
  fi
}

function disable_horizon {
  ssh root@controller0 "
    sed -i '/domain_specific_drivers_enabled/s/=.*/=False/' /var/lib/config-data/puppet-generated/keystone/etc/keystone/keystone.conf
    docker restart keystone
    sed -i '/^OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT/s/=.*/= False/' /var/lib/config-data/puppet-generated/horizon/etc/openstack-dashboard/local_settings
    docker restart horizon
    "
}
function overcloud_start {
  # START for 7 openstack
  rht-overcloud.sh start
  for i in controller0 compute0 compute1 computehci0 ceph0; do
    openstack server set $i --state active; done
  until curl -s https://172.25.249.201:13000; do sleep 2s; done
}

function config_network {
  #7. Configure networking
  source overcloudrc
  for i in $(openstack network list -f yaml | awk '/Subnets/ {print $2}' | grep -v e0db6f1e-70be-4360-8210-0435a47e3a88); do
    openstack subnet delete $i
  done
  openstack network delete production-network1 finance-network1 \
    provider-datacentre provider-storage
}

function cloud_init {
  #8. Launch an instance using cloud-init
  cat > cloud-init.sh <<EOF
#!/bin/bash
HOSTNAME=\$(hostname -s)
yum -y install httpd
yum -y install python2-openstackclient
echo Hello OpenStack >/var/www/html/index.html
systemctl enable --now httpd
EOF
}

function heat_stack {
  #12. Create a Heat stack
  sshpass -p redhat ssh root@localhost "
    mkdir /home/stack/materials/
    wget http://materials/heat/production-app1.yaml -O /home/stack/materials/web_server.yaml
    sed -i -e '13s/key_name/key_nam/' -e '19,20s/ d/d/' /home/stack/materials/web_server.yaml
    "
}

function manila-data {
  #18. Access a shared file system
  cat > manila-data.sh <<EOF
#!/bin/bash
cat > /etc/sysconfig/network-scripts/ifcfg-eth1 <<EOT
DEVICE=eth1
ONBOOT=yes
BOOTPROTO=dhcp
EOT
ifup eth1
curl http://materials/ceph.repo -o /etc/yum.repos.d/ceph.repo
yum -y install ceph-fuse
EOF
}

# Main area
check_env
disable_horizon
#overcloud_start
config_network
cloud_init
heat_stack
manila-data