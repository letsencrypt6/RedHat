[toc]



# [Introduction]()

**ORIENTATION TO THE CLASSROOM ENVIRONMENT**

![cl210-classroom-architecture]([https://github.com/letsencrypt6/RedHat/main/RH/images/courseintro/cl210-classroom-architecture.svg)

https://github.com/letsencrypt6/RedHat/blob/main/RH/images/0.jpg

# [1. 了解红帽 OpenStack 平台架构]()

> - 描述课堂环境、支持系统和服务
> - 描述云下组件和管理架构的功能
> - 描述容器化服务和管理命令
> - 描述云上组件和管理架构的功能

<img src='[https://github.com/letsencrypt6/RedHat/blob/main/RH/images/architecture/architecture-deployment.png'>

**[kiosk@foundation0 ~]**

```bash
$ rht-vmctl start classroom
$ rht-vmctl status classroom

$ rht-vmctl start all
$ rht-vmctl status all
workstation RUNNING
power RUNNING
utility RUNNING
director RUNNING
controller0 DEFINED
compute0 DEFINED
compute1 DEFINED
computehci0 DEFINED
ceph0 DEFINED

$ ssh stack@director
```

**(undercloud)  [stack@director ~]**

```bash
$ tail -n 2 ~/.bashrc
source stackrc
# END ANSIBLE MANAGED BLOCK

$ grep ^OS stackrc
OS_PASSWORD=redhat
OS_AUTH_TYPE=password
OS_AUTH_URL=https://172.25.249.201:13000/
OS_USERNAME=admin
OS_PROJECT_NAME=admin
OS_BAREMETAL_API_VERSION=$IRONIC_API_VERSION
OS_NO_CACHE=True
OS_CLOUDNAME=undercloud
OS_IDENTITY_API_VERSION='3'
OS_PROJECT_DOMAIN_NAME='Default'
OS_USER_DOMAIN_NAME='Default'

$ rht-overcloud.sh start

$ openstack baremetal node list
$ openstack server list

$ openstack server start compute1
$ openstack server set --state active compute1

$ openstack server reboot --hard compute1

$ ipmitool -I lanplus -U admin -P password -H 172.25.249.112 power status
```

**[student@utility]**

> foundation/firefox http://utility
> 	Username: `admin`
> 	Password: `RedHat123^`
>
> ```bash
> # grep RewriteRule /etc/httpd/conf.d/ipa-rewrite.conf
> RewriteRule ^/$ https://utility.lab.example.com/ipa/ui
> ```

```bash
kinit - obtain and cache Kerberos ticket-granting ticket

$ kinit admin
Password for admin@LAB.EXAMPLE.NET: `RedHat123^`

$ ipa user-find | grep User
  User login: admin
  User login: architect1
  User login: developer1
  User login: svc-ldap
```

**[student@power ~]**

```bash
$ ss -antup | grep -w 623
$ systemctl status bmc -l
```



![cl210-classroom-topology](https://k8s.ruitong.cn:8080/Redhat/CL210-RHOSP13.0-en-1-20200501/images/architecture/undercloud-classroom.svg)

## NAVIGATING THE RED HAT OPENSTACK PLATFORM INFRASTRUCTURE

**[student@workstation]**

```bash
$ chronyc sources -v

$ systemctl status dnsmasq
$ cat /etc/hosts

$ ssh utility
```

**[student@utility]**

```bash
$ kinit admin
Password for admin@LAB.EXAMPLE.NET: `RedHatl23^`

$ ipa user-find | grep User
$ ipa group-find | grep Group
```

**[root@power]**

```bash
# ps-ef | grep virshbmc
```

**[stack@director]**

```bash
$ ipmitool -I lanplus -U admin -P password \
 -H 172.25.249.112 power status
 
$ curl -ksL 172.25.249.200:8787/v2/_catalog | jq .
```

## VIEWING THE UNDERCLOUD ARCHITECTURE

**[stack@director]**

```bash
$ grep "^dhcp" undercloud.conf

$ grep "^undercloud_.*vip" undercloud.conf

$ grep "^undercloud_.*password" undercloud.conf
```

```bash
$ openstack endpointlist \
-c 'Service Type' -c 'Interface' -c 'URL'

$ env | grep OS_
```

```bash
$ openstack subnet list \
-c 'Name' -c 'Subnet'

$ openstack subnet show ctlplane-subnet
```

```bash
$ openstack baremetal node list \
-c 'Name' -c 'Power State'

$ openstack baremetal node show \
-c 'driver' -c 'driver—info' computel
```



## VIEWING CONTAINERIZED SERVICE STRUCTURES

**[heat-admin@compute0]**

```bash
$ sudo -i
# docker ps
```

**[heat-admin@controller0]**

```bash
$ sudo -i

# docker ps

# docker images

# docker inspect cinder_api

# docker logs keystone
# less /var/log/containers/swift/swift.log

# docker exec -t keystone /openstack/healthcheck

# docker stop nova_api
# docker ps -a --format="{{.Names}}\t{{.Status}}" | grep nova_api
# docker start nova_api
# docker ps -a --format="{{.Names}}\t{{.Status}}" | grep nova_api
```



## VIEWING THE OVERCLOUD ARCHITECTURE

**[stack@director]**

```bash
$ env | grep OS_

$ openstack server list -c Name -c Status -c Networks
```

**[root@controller0]**

```bash
# nmcli dev status
# ip a | egrep 'eth0|vlan|br-ex'

# ovs-vsctl list-br
# ovs-vsctl list-ifaces br-trunk
# ovs-vsctl list-ifaces br-ex

# docker ps --format="table {{.Names}}\t{{.Status}}"
```

**[heat-admin@compute0]**

```bash
$ ip addr 丨 egrep'eth0|vlan|eth2'

$ sudo ovs-vsctl list-br

$ sudo ovs-vsctl list-ifaces br-trunk
$ sudo docker ps --format="table {{.Names}}\t{{.Status}}"
```

**[heat-admin@computehci0]**

```bash
$ ip addr 丨 egrep 'eth0|vlan|eth2'

$ sudo ovs-vsctl list-br
$ sudo ovs-vsctl list-ifaces br-trunk
$ sudo docker ps --format="table {{.Names}}\t{{.Status}}"

$ lsblk -fs
```

**[heat-admin@ceph0]**

```bash
$ ip addr | egrep 'eth0|vlan|eth2'

$ sudo ovs-vsctl list-br
$ sudo docker ps --format="table {{.Names}}\t{{.Status}}"

$ lsblk -fs
```

**[heat-admin@controller0]**

```bash
$ ceph status

$ ceph osd lspools

$ ceph osd ls
```

**[stack@director]**

```bash
$ source overcloudrc

$ openstack role list -c Name
```

## 总结

> - 如今的企业云是使用多个互连的云结构构建的。 undercloud 是一个配置和管理云，用于构建和管理生产云。 Red Hat OpenStack Platform Director 是 Red Hat OpenStack Platform 中的 undercloud
> - 企业生产云称为 overcloud。 Underclouds 和 overclouds 使用相同的技术，但管理不同的工作负载。 Underclouds 管理云基础设施，overclouds 管理生产和租户工作负载
> - 常见的开放技术用于物理云和虚拟云。智能平台管理接口（IPMI）是用于控制节点的电源管理技术。虚拟网络计算 (VNC) 是用于访问已部署实例控制台的远程访问技术
> - 自省过程发现要部署的节点的技术特征。利用这些特性，overcloud 部署可以自动将部署角色分配给特定节点
> - 编排过程定义了每个节点的硬件和软件的具体配置。提供的默认模板涵盖了大多数常见用例和设计
> - 最新版本的 Red Hat OpenStack Platform 使用容器来运行服务。 systemd 命令已弃用，并已替换为 docker 命令。日志文件现在位于 /var/log/service 中。配置文件现在位于 /var/lib/config-data/puppet- generated/service/etc/service 中。只有在容器配置文件中所做的更改在服务重新启动后才会保留



# [2. 描述 OPENSTACK 控制平面]()

> - 描述服务端点配置和安全性。描述消息代理模式和实现。识别在控制器节点上运行的共享服务

## DESCRIBING SERVICE COMMUNICATION BY MESSAGE BROKER

## VIEWING OVERCLOUD CONTROL PLANE SERVICES

**[root@controller0]**

```bash
# docker exec -t \
galera-bundle-docker-0 mysql -u root -e "show databases;"

# grep ^password \
/var/lib/config-data/puppet-generated/mysql/root/.my.cnf
3T8pj6Nu9F

# ss -tnlp | grep 3306
LISTEN     0      128    172.24.1.50:3306                     *:*                   users:(("haproxy",pid=14225,fd=26))

# mysql -u root -p3T8pj6Nu9F -h l72.24.1.50 -e "show databases;"
```

```bash
# docker exec -t redis-bundle-docker-0 \
grep ^requirepass /etc/redis.conf

# ss -tnlp | grep redis
# redis-cli -h 172.24.1.1
172.24.1.1:6379> AUTH q3W8WR4GbJaBhy64t9f2kckHD
172.24.1.1:6379> KEYS *
172.24.1.1:6379> TYPE gnocchi-config
172.24.1.1:6379> HGETALL gnocchi-config
172.24.1.1:6379> exit
```

```bash
# ss -tnlp | grep memcached

# docker exec -t memcached memcached-tool 172.24.1.1
# docker exec -t memcached memcached-tool 172.24.1.1 stats
```

```bash
# pcs resource show

# pcs resource disable openstack-manila-share
# pcs resource show

# pcs resource enable openstack-manila-share
# pcs resource show openstack-manila-share
```

**[student@workstation]**

```bash
$ source -/developerl-finance-rc

$ openstack console url show -c url -f value finance-server3

$ firefox http://172.25.250.50:6080/vnc_auto.html?token=99635dd0-f87b-4blb-b8c8-48blc06a4afc &
```



# [3. 集成身份管理]()

> - 描述 OpenStack 身份服务的红帽身份管理后端的安装和架构。管理实现用户授权访问 OpenStack 服务的用户令牌。管理项目配额、域、层次结构和组

## VERIFYING AN IDM BACK-END CONFIGURATION

## MANAGING IDENTITY SERVICE TOKENS

## MANAGING PROJECT ORGANIZATION



## 总结

> - 可以将身份服务配置为从外部 IdM 环境对用户进行身份验证
> - 要使用红帽 IdM 后端执行用户凭证认证，身份服务需要在 IdM 服务器上使用 LDAP 查找帐户 有四种类型的令牌提供者：UUID，PKI，PKIZ和Fernet。Fernet 代币自红帽 OpenStack Platform 12 起默认启用 
> - Fernet 代币的最大限制为 250 字节，这使得它们足够小，非常适合 API 调用并最大限度地减少磁盘上保存的数据。每个Fernet令牌实际上由两个较小的密钥组成：128位AES加密密钥和128位SHA256 HMAC签名密钥
> - 域在授权模型中提供粒度。对于域，资源映射可以总结为：域由用户和项目组成，其中用户可以在项目和域级别具有角色



# [4. 执行 Image 操作]()

> - 描述常见的 IMAGE 格式、功能和用例
> - 使用 diskimage-builder 构建映像
> - 使用 `guestfish` 和 `virt-customize` 使用附加软件和配置修改现有映像
> - 使用 `cloud-init` 在部署期间自定义实例

**Image Format Overview**

| FORMAT | DESCRIPTION                                                  |
| :----: | ------------------------------------------------------------ |
|  RAW   | 非结构化磁盘图像格式，是原始磁盘的精确副本磁盘<br>如 **.img**, **.raw**, **.bin** |
| QCOW2  | Copy On Write v2<br>此格式由 QEMU 模拟器支持，可以动态扩展空间<br>KVM 中最常见的格式 |
|  ISO   | CD or DVD                                                    |
|  AKI   | An Amazon kernel image                                       |
|  AMI   | An Amazon machine image                                      |
|  ARI   | An Amazon ramdisk image                                      |
|  VDI   | VirtualBox                                                   |
|  VHD   | Microsoft's Hyper-V and Windows Virtual PC<br>supported by VMware，Xen， Virtualbox |
|  VMDK  | VMware                                                       |

## BUILDING AN IMAGE

> Disk Image Builder
>
> - disk-image-create
> - virt-builder

[root@foundation]

```bash
KVM虚拟机通过foundation上网
# sshpass -p Asimov ssh root@classroom rht-config-nat
```

[stack@director]

```bash
$ sudo sed -i '1inameserver 172.25.250.254' /etc/resolv.conf

$ cat /etc/resolv.conf
nameserver 172.25.250.254
nameserver 169.254.2.3

$ ping -c 1 www.163.com

$ sudo timedatectl set-time '2022-07-23'
```

- ubuntu

```bash
# https://docs.openstack.org/diskimage-builder/latest/elements/ubuntu/README.html

# VAR
# 版本
export DIB_RELEASE=bionic
# 镜像
export DIB_DISTRIBUTION_MIRROR=http://mirror.nju.edu.cn/ubuntu

# BASE IMAGE
IMG_URL=http://cloud-images.ubuntu.com/$DIB_RELEASE/current
IMG_DIR=~/.cache/image-create
IMG_FILE=${DIB_RELEASE}-server-cloudimg-amd64.squashfs
[ ! -f $IMG_DIR/$IMG_FILE ] && \
    wget $IMG_URL/$IMG_FILE -P $IMG_DIR

# REQUIRE
PI=/usr/share/diskimage-builder/elements/ubuntu
cat > $PI/post-install.d/00-enable-apache2-service <<EOF
#!/bin/bash
echo Klaatu barada nikto > /var/www/html/index.html
systemctl enable apache2.service
useradd sheila
EOF
chmod +x $PI/post-install.d/00-enable-apache2-service

# CREATE
disk-image-create ubuntu vm \
  -a amd64 \
  -p apache2 \
  -t qcow2 \
  --offline \
  -o ubuntu-$DIB_RELEASE.qcow2

# CONFIRM
qemu-img info ubuntu-$DIB_RELEASE.qcow2
```

- Centos7

```bash
# /usr/share/diskimage-builder/elements/rhel/README.rst

# VARS
export DIB_RELEASE=7
export DIB_LOCAL_IMAGE=CentOS-7-x86_64-GenericCloud.qcow2

# BASE IMAGE
IMG_URL=http://mirror.nju.edu.cn/centos-cloud/centos
[ ! -f $DIB_LOCAL_IMAGE ] && \
    wget $IMG_URL/$DIB_RELEASE/images/$DIB_LOCAL_IMAGE

# REQUIRE
PI=/usr/share/diskimage-builder/elements/centos
mkdir $PI/post-install.d
cat > $PI/post-install.d/00-enable-httpd-service <<EOF
#!/bin/bash
yum -y install httpd
echo Klaatu barada nikto > /var/www/html/index.html
systemctl enable httpd.service
useradd sheila
EOF
chmod +x $PI/post-install.d/00-enable-httpd-service

# CREATE
disk-image-create centos vm \
  -a amd64 \
  -t qcow2 \
  --offline \
  -o centos-$DIB_RELEASE.qcow2

# CONFIRM
qemu-img info centos-$DIB_RELEASE.qcow2
```



## CUSTOMIZING AN IMAGE

- guestfish

  ​	https://libguestfs.org/

  ​	https://docs.openstack.org/image-guide/modify-images.html

## INITIALIZING AN INSTANCE DURING DEPLOYMENT

## 总结

> - 与自定义现有映像相比，构建映像的优点和缺点，例如满足组织安全标准（包括第三方代理）和添加操作员帐户
> - 何时使用 **guestfish** 和 **virt-customize** 工具。当您需要执行低级任务（例如分区磁盘）时，请使用 **guestfish**。对所有常见的自定义任务（例如设置密码和安装软件包）使用 **virt-custome**
> - 使用这些工具对映像进行更改会影响 SELinux 文件上下文，因为在 chroot 环境中不直接支持 SELinux
> - 为避免映像蔓延，请使用较小的映像集，并根据需要使用 cloud-init 或配置管理系统执行每个实例的自定义



# [5. 管理存储]()

> - 解释在 OpenStack 中使用的持久存储选项，重点介绍默认 Ceph 存储的扩展功能。讨论 Swift 和 Ceph 对象存储，比较架构注意事项。描述配置新共享文件系统组件的方法。解释临时存储配置选择的行为



# [6. 管理 OpenStack 网络]()

> - 解释 OpenStack 网络服务可用的不同网络类型。通过开放式虚拟网络提高网络性能。比较自助服务和提供商网络的配置选项，并比较集中式网络和分布式网络



# [7. 管理计算资源]()

> - 解释服务器实例的端到端启动过程，包括调度程序和指挥器任务。描述超融合计算节点体系结构并管理计算节点集的调度方法。执行常见的计算节点管理任务，包括实时迁移、撤出以及启用和禁用计算节点

## 总结

> - 实例启动过程
> - 调度程序进程接收来自指挥员的资源请求。然后将请求发送到放置服务，该服务运行查询以查找可满足资源要求的可用计算节点。然后将列表发送回调度程序服务。计划程序使用筛选器来优化搜索，并创建计算节点的排名列表。然后，调度程序从列表中选择第一个，调度程序尝试构建实例
> - 红帽 OpenStack 平台在版本 13 中包含放置服务。实施新的 RESTful API 来解决共享存储的问题。通用资源池解决了容量和使用情况信息不正确的问题
> - 配置资源约束以确保 Ceph 和计算服务不会相互干扰
> - 迁移是将服务器实例从一个计算节点移动到另一个计算节点的过程。撤离通常在计算节点进入故障或关闭模式时发生。在这种情况下，计算节点上的所有实例都将移动到另一个实例。可以在运行时使用共享存储或块存储迁移实例
> - 超融合节点在同一节点上组合计算和存储。Ceph 始终用作超融合节点中的存储组件。超融合存储比标准存储节点更便宜、更灵活



# [8. 自动化云应用]()

> - 说明部署应用程序堆栈所需的编排体系结构。使用热编排模板 （HOT） 语言编写模板以部署应用程序堆栈



# [9. OPENSTACK 操作疑难解答]()

> - 讨论建议的诊断和故障排除工具和技术。讨论所选核心组件的常见问题方案



# 附录

## A1. 系统和应用帐号

|           SYSTEM CREDENTIALS           |   USERNAME   |     PASSWORD     |
| :------------------------------------: | :----------: | :--------------: |
| Unprivileged shell login (as directed) |   student    |     student      |
|  Privileged shell login (as directed)  |     root     |      redhat      |
|       Undercloud - unprivileged        |   `stack`    |      redhat      |
|        Undercloud - privileged         |     root     |      redhat      |
|        Overcloud - unprivileged        | `heat-admin` | passwordless SSH |
|         Overcloud - privileged         |     root     |    Use sudo-i    |

|          APPLICATION CREDENTIALS           |  USERNAME   |   PASSWORD   |
| :----------------------------------------: | :---------: | :----------: |
|       Red Hat Identity Manager admin       |   `admin`   | `RedHat123^` |
| Red Hat OpenStack Platform dashboard admin |   `admin`   |   `redhat`   |
| Red Hat OpenStack Platform dashboard user  | as directed |    redhat    |
|    Red Hat OpenStack Platform director     |    admin    |    redhat    |

## A2. 关闭

 **[student@workstation]**

```bash
$ source admin-rc
$ for i in $(openstack server list --all-projects -c ID); do
openstack server stop $i 
done

$ ssh director
```

**[stack@director]**

```bash
$ rht-overcloud.sh stop
```

**[kiosk@foundation]**

```bash
$ rht-vmctl stop all
```



## A3. 做第一遍准备

**[root@founadtionX]**

```bash
sshpass -p Asimov ssh root@foudation0 'ls /content/manifests/'
:<<EOF
CL210-RHOSP13.0-1.r2018112917-ILT+VT+ROLE+RAV-7-en_US.icmf
EOF

# 不是最新的环境，需要改一下时间
systemctl disable --now chronyd
timedatectl set-time "2018-11-29"
date
```

**[kiosk@foundation0]**: teacher

```bash
$ rht-pushcourse all
$ rht-vmctl start classroom
```

**[kiosk@foundation1-20]**: student

```bash
$ cat /etc/rht

$ rht-vmctl start all
Starting workstation.
Starting power.
Starting utility.
Starting `director`.
Not starting controller0.
Not starting compute0.
Not starting compute1.
Not starting computehci0.
Not starting ceph0.

$ ssh stack@director
```

**(undercloud) [stack@director]**

```bash
$ rht-overcloud.sh start
[*] power is up
[*] ironic-conductor is up
[*] node: controller0, state: power off, powering on
[*] node: ceph0, state: power on, not powering on
[*] node: computehci0, state: power on, not powering on
[*] node: compute0, state: power on, not powering on
[*] node: compute1, state: power on, not powering on
```

**[kiosk@foundationX]**

```bash
# 如果 KVM 启动失败
foundation$ rht-vmctl start overcloud
```

**[stack@director]**

```bash
$ openstack server list -c Name -c Status
+-------------+--------+
| Name        | Status |
+-------------+--------+
| compute1    |`ACTIVE`|
| compute0    |`ACTIVE`|
| computehci0 |`ACTIVE`|
| controller0 |`ACTIVE`|
| ceph0       |`ACTIVE`|
+-------------+--------+
```

```bash
# 如果 Status 不是 ACTIVE，需执行下面的命令
$ for i in compute0 compute1 computehci0 controller0 ceph0 ; do
	openstack server set --state active $i
	done
```



## A4. 做第二遍准备

**[kiosk@foundationX]**

```bash
$ rht-vmctl -y reset overcloud
```

**[stack@director]**

```bash
$ rht-overcloud.sh start
```

**[kisok@foundationX]**

```bash
$ rht-vmctl status all
```

**[kiosk@foundationX]**

```bash
$ ping -c 4 controller0 || rht-vmctl start controller0
$ rht-vmctl status all

$ ssh stack@director \
	"openstack server set --state active controller0"
```



## A5. 培训环境2练习环境

director.sh

## A6. rescouce

|  ID  |        NAME         | `overcloudrc/admin` | Robertrc/user |
| :--: | :-----------------: | :-----------------: | :-----------: |
|  1   |      `flavor`       |         YES         |      NO       |
|  2   | `network(external)` |         YES         |      NO       |
|  2   |     floading ip     |         YES         |      YES      |
|  2   |  network(internal)  |         YES         |      YES      |
|  3   |        image        |         YES         |      YES      |
|  4   |   security group    |         YES         |      YES      |
|  5   |       keypair       |         YES         |      YES      |

## A7. virt-manager

1. 运行 `virt-manager`，添加连接`Add Connectino...`

![image-20211015160527537](https://gitee.com/suzhen99/redhat/raw/master/images/image-20211015160527537.png)

2. Hypervisor: `Custom URI...`
   Custom URI: `qemu+ssh://kiosk@210.12.42.221/system?socket=/var/run/libvirt/libvirt-sock`
   <kbd>Connect</kbd>

![image-20211015160730328](https://gitee.com/suzhen99/redhat/raw/master/images/image-20211015160730328.png)

3. 连接成功后，双击`workstation`

![image-20211015160958915](https://gitee.com/suzhen99/redhat/raw/master/images/image-20211015160958915.png)

4. 选择 student 用户后，输入密码 `student`, <kbd>Sign in</kbd>登陆

![workstation_student_login](https://gitee.com/suzhen99/redhat/raw/master/images/workstation_student_login.png)

5. 确认 horizen 地址 `172.25.250.50`

![image-20211015161430751](https://gitee.com/suzhen99/redhat/raw/master/images/image-20211015161430751.png)

6. Domain \* `EX210`, User Name \* `Robert`, Password \* `redhat`, <kbd>Connect</kbd>

![image-20211015161610561](https://gitee.com/suzhen99/redhat/raw/master/images/image-20211015161610561.png)

7. 登陆成功

![image-20211015161713849](https://gitee.com/suzhen99/redhat/raw/master/images/image-20211015161713849.png)

## A8. hardware

**[kiosk@foundation]**

```bash
$ lscpu | egrep 'vmx|Model'
$ free -h
$ lspci -vvv
$ lsblk
$ hdparm -I /dev/sda | grep Rotation
```

## A9. ssh tunnel

> -f      Requests ssh to go to background
> -N     Do Not execute a remote command

本地物理机-Windows / cmd

```bash
S_IP=210.12.42.221
S_PORT=22
S_USER=root

ssh -fND 8080:172.25.250.50:80 -p ${S_PORT} ${S_USER}@${S_IP}
```

本地物理机-MacOS

```bash
S_IP=210.12.42.221
S_PORT=22
S_USER=root
S_PASS=$RP

sshpass -p ${S_PASS} \
  ssh -fND 8080:172.25.250.50:80 \
      -p ${S_PORT} \
      ${S_USER}@${S_IP}
```

本地物理机

| STEP |                      |                   |
| :--: | -------------------- | ----------------- |
|  1   | 127.0.0.1:8080       | 配置 socket5 代理 |
|  2   | http://172.25.250.50 | 浏览器访问        |



## A10. USB

> - 优盘
>   - SIZE: >=128Gi
>   - INT: >=usb 3.0

| STEP |                                                          |                      |
| :--: | :------------------------------------------------------: | :------------------: |
|  1   | https://pan.baidu.com/s/19zZjxOAUuv555_GbzxjL9g?pwd=jdav |         下载         |
|  2   |                    解压缩『安装优盘』                    |        *.vmdk        |
|  3   |             新建VMware虚拟机，使用*.vmdk启动             |                      |
|  4   |                       <kbd>e</kbd>                       | 按提示：编辑grub菜单 |
|  5   |                  <kbd>space</kbd> cl210                  |                      |
|  6   |               <kbd>Ctrl</kbd>-<kbd>x</kbd>               |       启动系统       |
|  7   |        时区：上海 + 目标：插入 128Gi usb 3.0 优盘        |                      |
|  8   |                  物理32GB内存+优盘启动                   |                      |

## A11. 学习

1. 4天了解+EXAM
2. 教材实验
3. 多用
