[TOC]

Red Hat Services Management and Automation
===

> 本课程基于
>
> - 红帽 Ansible 引擎 2.9
>
> - 红帽企业 Linux 8.1
>
> - 培训环境RH358
>
> - 

**[kiosk@foundation]**

```bash
$ ls /content/courses/rh358/rhel8.1/grading-scripts/
```



## 1 管理网络服务

> - Systemd回顾
> - NetworkManager回顾
> - 自动化配置服务和网络接口

#### 第一节 控制网络服务

```bash
1.systemd简介
2.systemctl和systemd unit
3.服务状态
4.查看和管理服务、查看unit依赖、屏蔽服务、开机自启或停止
[root@servera ~]# systemctl start chronyd
[root@servera ~]# systemctl stop chronyd
[root@servera ~]# systemctl status chronyd 
[root@servera ~]# systemctl restart chronyd
[root@servera ~]# systemctl reload chronyd

[root@servera ~]# systemctl enable chronyd
[root@servera ~]# systemctl disable chronyd

[root@servera ~]# systemctl is-active chronyd 
[root@servera ~]# systemctl is-enabled chronyd 
注销
[root@servera ~]# systemctl mask chronyd 
[root@servera ~]# systemctl unmask chronyd 
列出服务依赖
[root@servera ~]# systemctl list-dependencies graphical.target 
```

```bash
练习 P9
练习对服务的管理
【workstation】
[student@workstation ~]$ lab  servicemgmt-netservice start
 Terminating chronyd.service on servera........................  SUCCESS

[student@workstation ~]$ sudo systemctl status chronyd
[sudo] password for student: 
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2023-03-26 10:29:00 CST; 15min ago


[student@workstation ~]$ sudo systemctl restart chronyd
[student@workstation ~]$ sudo systemctl status chronyd
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)


[student@workstation ~]$ ssh servera
[student@servera ~]$ sudo -i
[sudo] password for student: student
[root@servera ~]# systemctl status chronyd
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: `inactive (dead) since Sun 2023-03-26 10:42:49 CST; 3min 11s ago
   
[root@servera ~]# systemctl start chronyd
[root@servera ~]# systemctl status chronyd
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: `active (running) since Sun 2023-03-26 10:46:23 CST; 4s ago
     Docs: man:chronyd(8)
           man:chrony.conf(5)

[root@servera ~]# systemctl is-enabled chronyd
enabled
[root@servera ~]# reboot
Connection to servera closed by remote host.
Connection to servera closed.
[student@workstation ~]$ ping servera
PING servera.lab.example.com (172.25.250.10) 56(84) bytes of data.
64 bytes from servera.lab.example.com (172.25.250.10): icmp_seq=7 ttl=64 time=2.90 ms

[student@workstation ~]$ ssh servera
[student@servera ~]$ sudo -i
[sudo] password for student: 
[root@servera ~]# 
[root@servera ~]# systemctl status chronyd
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2023-03-26 10:49:26 CST; 1min 15s left

[root@servera ~]# systemctl disable chronyd  #建议reboot操作系统测试一下是否开启不启动
Removed /etc/systemd/system/multi-user.target.wants/chronyd.service.
[root@servera ~]# systemctl status chronyd
● chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; disabled; vendor preset: enabled)
   
[root@servera ~]# logout
[student@servera ~]$ logout
[student@workstation ~]$ lab servicemgmt-netservice finish 

Finishing lab.

 Cleaning up servera...........................................  SUCCESS

[student@workstation ~]$ 
```

#### 第二节 配置网络接口

```bash
1.NetworkManager简介
2.nmcli命令管理
	添加静态IP、及dhcpIP
```

```bash
练习P18 
创建链接并修改IP地址
【foundation】
[root@foundation0 ~]# rht-vmctl start servera
[root@foundation0 ~]# rht-vmctl start serverd
【workstation】
[student@workstation ~]$ lab servicemgmt-netreview start

 · Configuring serverd as an IPv4 gateway......................  SUCCESS
 · Backing up /etc/hosts.......................................  SUCCESS

[student@workstation ~]$ ssh servera

【servera】
[student@servera ~]$ sudo -i
[sudo] password for student: 
[root@servera ~]# ip link
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
[root@servera ~]# nmcli connection show
NAME                UUID                                  TYPE      DEVICE 
Wired connection 2  c0e6d328-fcb8-3715-8d82-f8c37cb42152  ethernet  eth1   
Wired connection 3  9b5ac87b-572c-3632-b8a2-ca242f22733d  ethernet  eth2   
Wired connection 1  4ae4bb9e-8f2d-3774-95f8-868d74edcc3c  ethernet  eth0   
[root@servera ~]# nmcli connection add con-name eth1 type ethernet ifname eth1
Connection 'eth1' (2f211fba-a4d8-438c-964d-5e769fae0b62) successfully added.
[root@servera ~]# nmcli connection show 
NAME                UUID                                  TYPE      DEVICE 
eth1                2f211fba-a4d8-438c-964d-5e769fae0b62  ethernet  --     
[root@servera ~]# nmcli connection show eth1 | grep ipv4
[root@servera ~]# nmcli connection modify eth1 ipv4.addresses 192.168.0.1/24 ipv4.method manual
[root@servera ~]# nmcli connection up eth1
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/27)
[root@servera ~]# ip a s dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:01:fa:0a brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.1/24 brd 192.168.0.255 scope global noprefixroute eth1
    
[root@servera ~]# ping -c 2 192.168.0.1
PING 192.168.0.1 (192.168.0.1) 56(84) bytes of data.
64 bytes from 192.168.0.1: icmp_seq=1 ttl=64 time=0.371 ms

[root@servera ~]# ping -c 2 192.168.0.254
PING 192.168.0.254 (192.168.0.254) 56(84) bytes of data.
64 bytes from 192.168.0.254: icmp_seq=1 ttl=64 time=3.59 ms

[root@servera ~]# ip route
default via 172.25.250.254 dev eth0 proto static metric 100 
172.25.250.0/24 dev eth0 proto kernel scope link src 172.25.250.10 metric 100 
192.168.0.0/24 dev eth1 proto kernel scope link src 192.168.0.1 metric 101 
[root@servera ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth1 
BOOTPROTO=none
NAME=eth1
DEVICE=eth1
ONBOOT=yes
IPADDR=192.168.0.1
PREFIX=24
[root@servera ~]# logout
[student@servera ~]$ logout
Connection to servera closed.
[student@workstation ~]$ lab servicemgmt-netreview finish 
```

#### 第三节 自动化执行服务和网络接口配置

```
1.ansible使用方法
2.ansible提供的三个模块：service、systemd、service_facts
3.网络角色自动配置接口
```

```bash
练习p30、P39
【workstation】
[student@workstation ~]$ lab servicemgmt-automation start
 · Create exercise directory...................................  SUCCESS
 · Download Ansible configuration..............................  SUCCESS
 · Download Ansible inventory..................................  SUCCESS
 · Configuring serverd as an IPv4 gateway......................  SUCCESS
 
[student@workstation ~]$ cd ~/servicemgmt-automation/
[student@workstation servicemgmt-automation]$ ls
ansible.cfg  inventory
[student@workstation servicemgmt-automation]$ cat inventory 
[servers]
servera.lab.example.com
[student@workstation servicemgmt-automation]$ vim playbook.yml
---
- name: haha
  hosts: servers
  become: true
  tasks:
  - name: Start NetworkManager
    service:
      name: NetworkManager
      state: started
      enabled: yes
      
[student@workstation servicemgmt-automation]$ ansible-playbook playbook.yml #因为NetworkManager网络服务已经运行，所以不会有何改变
[student@workstation servicemgmt-automation]$ vim playbook.yml  #通过mac地址查看指定的接口
---
- name: haha
  hosts: servers
  become: true

  vars:
  - target_mac: "52:54:00:01:fa:0a"

  tasks:
  - name: Start NetworkManager
    service:
      name: NetworkManager
      state: started
      enabled: yes

  - name: find the_interface for target_mac
    set_fact:
       the_interface: "{{ item }}"
    when:
    - ansible_facts[item]['macaddress'] is defined
    - ansible_facts[item]['macaddress'] == target_mac
    loop: "{{ ansible_facts['interfaces'] }}"

  - name: Display the_interface
    debug:
      var: the_interface

[student@workstation servicemgmt-automation]$ ansible-playbook playbook.yml 

使用网络系统角色设置IP地址
[student@workstation servicemgmt-automation]$ ansible-galaxy list
[student@workstation servicemgmt-automation]$ yum search roles
[student@workstation servicemgmt-automation]$ sudo yum install -y rhel-system-roles.noarch
[student@workstation servicemgmt-automation]$ ansible-galaxy list
[student@workstation servicemgmt-automation]$ rpm -ql rhel-system-roles-1.0-9.el8.noarch |grep network
[student@workstation servicemgmt-automation]$ cp /usr/share/doc/rhel-system-roles/network/example-eth-simple-auto-playbook.yml confignet.yml
[student@workstation servicemgmt-automation]$ vim confignet.yml  #查看例子
---
- hosts: servers
  become: true
  vars:
    target_mac: "52:54:00:01:fa:0a"
    network_connections:
      - name: static_net
        type: ethernet
        mac: "{{ target_mac }}"
        state: up
        ip:
          dhcp4: no
          address:
          - 192.168.0.1/24


  roles:
    - rhel-system-roles.network

[student@workstation servicemgmt-automation]$ ansible-playbook confignet.yml 
[student@workstation servicemgmt-automation]$ ssh servera

【servera】
[student@servera ~]$ nmcli connection show
...
NAME                UUID                                  TYPE      DEVICE 
static_net          7bc1e222-2fe4-423e-af75-1cb18ad62b1d  ethernet  eth1  
...
[student@servera ~]$ nmcli connection show static_net | grep ipv4
[student@servera ~]$  ping -c2 192.168.0.254
PING 192.168.0.254 (192.168.0.254) 56(84) bytes of data.
64 bytes from 192.168.0.254: icmp_seq=1 ttl=64 time=3.96 ms

```

## 2 配置网络聚合 配置网络Team

> - 管理网络Team
> - 自动化网络Team

> VIP - [ eth0 + eth1 ]
>
> RHEL<=6 `bond`, RHEL>=7 `team`

#### 1 管理网络Team

```bash
1.网络team概念
2.配置网络team
创建team接口
分配team 接口IP
创建port 接口
启动或关闭team接口和port接口

-RHEL=7
# nmcli con add \
type team \
con-name Team1 \
ifname Team1 \
config '"runner": {"name": "activebackup"}'

-RHEL=8
# nmcli con add type team con-name Team1 ifname Team1 team.runner activebackup
# nmcli con modify Team1 ipv4.address 172.25.250.100/24 autoconnect yes ipv4.method manual
# nmcli con add type ethernet con-name Team1-slave1 ifname eth1 master Team1
# nmcli con add type ethernet con-name Team1-slave2 ifname eth2 master Team1
# nmcli con up/down team1
# nmcli con up/down eth1
# teamdctl Team1 state
```

```bash
练习P56
【workstation】
[student@workstation /]$ lab netlink-teaming start
 · Configuring eth1 network interface on serverd...............  SUCCESS
 
[student@workstation /]$ ssh servera
【servera】
[student@servera ~]$ sudo -i
[sudo] password for student: 
[root@servera ~]# mandb 
[root@servera ~]# man -k team
[root@servera ~]# man 8 nmcli-examples | grep team
[root@servera ~]# man teamd.conf
[root@servera ~]# nmcli connection add type team con-name team0 ifname team0 team.runner activebackup 
[root@servera ~]# nmcli connection modify team0 ipv4.addresses 192.168.0.100/24 ipv4.method manual
[root@servera ~]# nmcli connection add type ethernet slave-type team con-name team0-port1 ifname eth1 master team0
[root@servera ~]# nmcli connection add type ethernet slave-type team con-name team0-port2 ifname eth2 master team0
[root@servera ~]# nmcli con up team0
[root@servera ~]# nmcli con up team0-port1
[root@servera ~]# nmcli con up team0-port2
[root@servera ~]# teamdctl team0 state
setup:
  runner: activebackup
ports:
  eth1
    link watches:
      link summary: up
      instance[link_watch_0]:
        name: ethtool
        link: up
        down count: 0
  eth2
    link watches:
      link summary: up
      instance[link_watch_0]:
        name: ethtool
        link: up
        down count: 0
runner:
  active port: eth1
[root@servera ~]# ping -I team0 -c 4 192.168.0.254
PING 192.168.0.254 (192.168.0.254) from 192.168.0.100 team0: 56(84) bytes of data.
64 bytes from 192.168.0.254: icmp_seq=1 ttl=64 time=2.59 ms

[root@servera ~]# ping 192.168.0.254
PING 192.168.0.254 (192.168.0.254) 56(84) bytes of data.
64 bytes from 192.168.0.254: icmp_seq=1 ttl=64 time=2.01 ms

[root@servera ~]# tcpdump -i eth1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
00:08:50.897967 STP 802.1d, Config, Flags [none], bridge-id 8000.52:54:00:0e:0b:cf.8002, length 35
00:08:51.191366 IP6 fe80::7249:fff8:71dd:6473 > ff02::16: HBH ICMP6, multicast listener report v2, 1 group record(s), length 28
10 packets captured
10 packets received by filter
0 packets dropped by kernel
[root@servera ~]# tcpdump -i eth2

```

#### 2 管理网络team

```bash
1.team的配置文件/etc/sysconfig/network-scripts/
2.设置和修改team配置
#nmcli con mod Team1 team.runner activebackup（常用）
3.网络team故障排除
#teamnl Team1 ports   #显示team端口
#teamnl Team1 getoption activeport #显示活动端口
#teamdctl Team1 state item set runner.active_port eth1 #更改Team1活动的端口
#teamdctl Team1 state #显示当前状态(常用)
#teamdctl Team1  config dump  #json配置显示

```

```bash
练习P66
[student@workstation /]$ lab netlink-teammgmt start
 · Creating team interface on servera..........................  SUCCESS
 · Activating team interface on servera........................  SUCCESS
 · Configuring eth1 network interface on serverd...............  SUCCESS

[student@workstation /]$ ssh servera
[student@servera ~]$ sudo -i
[sudo] password for student: 
[root@servera ~]# 
[root@servera ~]# teamdctl team0 state
setup:
  runner: activebackup
ports:
  eth1
    link watches:
      link summary: up
      instance[link_watch_0]:
        name: ethtool
        link: up
        down count: 0
  eth2
    link watches:
      link summary: up
      instance[link_watch_0]:
        name: ethtool
        link: up
        down count: 0
runner:
  active port: eth1
[root@servera ~]# nmcli connection modify team0 team.runner roundrobin
[root@servera ~]# nmcli connection down team0
[root@servera ~]# nmcli connection up team0
[root@servera ~]# ping 192.168.0.254  #另一个终端ping
[root@servera ~]# tcpdump -i eth1 icmp and src 192.168.0.254 #本终端测试两个接口是否有报文通过
[root@servera ~]# tcpdump -i eth2 icmp and src 192.168.0.254

```

#### 3 自动化管理Team

```bash
练习P75
总练习P82
[student@workstation ~]$ lab netlink-automation start
 · Create Ansible project directory............................  SUCCESS
 · Download Ansible configuration..............................  SUCCESS
 · Download Ansible inventory..................................  SUCCESS
 · Configuring eth1 network interface on serverd...............  SUCCESS

[student@workstation ~]$ cd ~/netlink-automation/
[student@workstation netlink-automation]$ ls
ansible.cfg  inventory
[student@workstation netlink-automation]$ ansible-galaxy list
# /usr/share/ansible/roles
...
- rhel-system-roles.network, (unknown version)
- rhel-system-roles.postfix, (unknown version)
- rhel-system-roles.selinux, (unknown version)
- rhel-system-roles.storage, (unknown version)
- rhel-system-roles.timesync, (unknown version)

[student@workstation netlink-automation]$ cp /usr/share/doc/rhel-system-roles/network/example-eth-simple-auto-playbook.yml playbook.yml
[student@workstation netlink-automation]$ vim playbook.yml 
---
- hosts: servers
  become: true
  vars:
    network_connections:
      - name: team0
        state: up
        type: team
        interface_name: team0
        ip:
          dhcp4: no
          auto6: no
          address:
          - 192.168.0.100/24

      - name: team0-port1
        state: up
        type: ethernet
        interface_name: eth1
        master: team0

      - name: team0-port2
        state: up
        type: ethernet
        interface_name: eth2
        master: team0

  roles:
    - rhel-system-roles.network

[student@workstation netlink-automation]$ ansible-playbook playbook.yml 
[WARNING]: [007] <info>  #0, state:up persistent_state:present, 'team0': add connection
team0, 68bbfbb2-35b3-4e8b-90dd-63aed13fc049
[WARNING]: [008] <info>  #0, state:up persistent_state:present, 'team0': up connection
team0, 68bbfbb2-35b3-4e8b-90dd-63aed13fc049 (not-active)
[WARNING]: [009] <info>  #1, state:up persistent_state:present, 'team0-port1': add
connection team0-port1, 878cd42f-3cb0-4ea5-a444-5aabb5d5e5de
[WARNING]: [010] <info>  #1, state:up persistent_state:present, 'team0-port1': up
connection team0-port1, 878cd42f-3cb0-4ea5-a444-5aabb5d5e5de (not-active)
[WARNING]: [011] <info>  #2, state:up persistent_state:present, 'team0-port2': add
connection team0-port2, 13383b3c-a175-4b6d-818c-7bc1bf5eeba0
[WARNING]: [012] <info>  #2, state:up persistent_state:present, 'team0-port2': up
connection team0-port2, 13383b3c-a175-4b6d-818c-7bc1bf5eeba0 (not-active)

【servera】
[student@workstation netlink-automation]$ ssh servera

[student@servera ~]$ sudo -i
[sudo] password for student: 
[root@servera ~]# teamdctl team0 state
setup:
  runner: roundrobin
ports:
  eth1
    link watches:
      link summary: up
      instance[link_watch_0]:
        name: ethtool
        link: up
        down count: 0
  eth2
    link watches:
      link summary: up
      instance[link_watch_0]:
        name: ethtool
        link: up
        down count: 0
[root@servera ~]# ping -c2 192.168.0.254
PING 192.168.0.254 (192.168.0.254) 56(84) bytes of data.
64 bytes from 192.168.0.254: icmp_seq=2 ttl=64 time=4.13 ms

[root@servera ~]# logout
[student@servera ~]$ logout
Connection to servera closed.
[student@workstation netlink-automation]$ ls
ansible.cfg  inventory  playbook.yml

[student@workstation netlink-automation]$ vim teamtune.yml
---
- name:
  hosts: servers
  become: true

  tasks:
  - name:
    command: nmcli con mod team0 team.runner activebackup

  - name:
    command: nmcli dev dis team0

  - name:
    command: nmcli con up team0

[student@workstation netlink-automation]$ ansible-playbook teamtune.yml

PLAY [servers] *****************************************************************************

TASK [Gathering Facts] *********************************************************************
ok: [servera.lab.example.com]

TASK [command] *****************************************************************************
changed: [servera.lab.example.com]

TASK [command] *****************************************************************************
changed: [servera.lab.example.com]

TASK [command] *****************************************************************************
changed: [servera.lab.example.com]

PLAY RECAP *********************************************************************************
servera.lab.example.com    : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


```



## 3 管理DNS和DNS服务器

> - 

> - 描述DNS服务
> - 使用Unbound配置缓存名称服务器
> - 排故DNS问题
>   - **host** www.mi.com, 
>     host 172.25.254.250 172.25.254.254
>   - nslookup www.mi.com, 
>     nslookup 172.25.254.250  172.25.254.254
>   - dig www.mi.com , 
>     dig -x 172.25.254.250  @172.25.254.254
> - :triangular_flag_on_post: 使用BIND 9配置权威名称服务器
> - 自动化配置DNS

|  ID  |    TYPE    | 主配置文件\*2 | 区域文件（正向\|反向）\*2 | operation |   PKG   |
| :--: | :--------: | :-----------: | :-----------------------: | :-------: | :-----: |
|  1   | **Master** |       Y       |             Y             |   edit    |  bind   |
|  2   |   Slave    |       Y       |             N             |   copy    |  bind   |
|  3   |   Cache    |       Y       |             N             |     -     | unbound |
|  4   |  Forward   |       Y       |             N             |     -     |  bind   |

> ip, 8.8.8.8, 114.114.114.114
>
> FQDN	www.mi.com.
>
> \$ hostname -s<kbd>Enter</kbd>	www
>
> 

> ```bash
> 
> ```
> 
> - hosts
>   - Linux, MacOS - /etc/hosts
>   - Windows - C:\windows\system32\drivers\etc\hosts
>- dns
>   - permanent 
>     - \$ nmcli con mod CN ipv4.dns 8.8.8.8
>   - active 
>     - \$ cat /etc/resolve.conf

> :one: domain/conf_file***1**	permission*2, file "example.com.localhost";  ,file "25.172.loopback"; 
>
> ​		:two: zone/zone_file***2**	正向`lab.example.com.` ； 反向`25.172.in-addr.arpa.`
>
> ​				:three: recorder 
> ​							hostname	`A	` ip	                    主机名解析成IP地址；
> ​							rever<!--se hid `PTR` hostna-->me    IP 地址解析成主机名
>
> ​											`SOA` = `NS` = servera.lab.example.com`.`

![dns-lookups](https://gitee.com/suzhen99/redhat/raw/master/images/dns-lookups.svg)

```cmd
x:\> ipconfig /flushdns
```

| CLASS |                 |    NID    |  HID  |          zone           |  PTR  |
| :---: | :-------------: | :-------: | :---: | :---------------------: | :---: |
|   A   |   10.1.2.3/8    |    10     | 1.2.3 |    10.in-addr.arpa.     | 3.2.1 |
|   B   | 172.25.254.9/16 |  172.25   | 254.9 |  25.172.in-addr.arpa.   | 9.254 |
|   C   | 192.168.9.10/24 | 192.168.9 |  10   | 9.168.192.in-addr.arpa. |  10   |

#### 第一节 描述DNS服务

```bash
1 DNS查询1 命名空间、域、子域、区域
. 根域
com. 顶级域
mi.com.	二级域名
mail.mi.com. 三级域名

域分类：
组织：.com .edu .net等
国家：.us .jp .cn等
https://www.iana.org/domains/root/db

2 正向解析与反向解析
正向解析：域名解析IP地址
反向解析：IP解析域名

3 DNS查询
查询方式两种：
递归查询：一级一级
迭代：并行

4 资源记录（RR Resource Record）
A		域名和ipv4地址的对应关系
AAAA	域名和ipv6地址的对应关系
CNAME   别名
PRT		反向指针记录、反解
NS		名称服务，权威服务器
SOA		起始授权机构
MX 		邮件交换记录
SRV		帮助客户端查找支持域的服务器
```

#### 第二节 使用BIND 9配置权威名称服务器

2.1 DNS服务器类型

|  ID  |    TYPE    | 主配置文件*2 | 区域文件（正向\|反向）*2 | operation |   PKG   |
| :--: | :--------: | :----------: | :----------------------: | :-------: | :-----: |
|  1   | **Master** |      Y       |            Y             |   edit    |  bind   |
|  2   |   Slave    |      Y       |            N             |   copy    |  bind   |
|  3   |   Cache    |      Y       |            N             |     -     | unbound |
|  4   |  Forward   |      Y       |            N             |     -     |  bind   |

2.2 DNS服务器的设计架构

```
三张架构图
```

2.3 安装bind

```
yum search bind
yum install bind -y
```

2.4 配置bind（配置文件，正向解析、反向解析、主从dns）

```bash
配置文件一览
/etc/named.conf ：主配置文件（1 定义地址匹配列表 2 监听端口 3 限制访问 ）
/etc/named.rfc1912.zones 辅助配置文件
/var/named/named.localhost		：正解zone配置文件
/var/named/named.loopback  		：反解zone配置文件
/var/named/named.ca				：13台根域配置文件
/var/named/slaves/				：从服务器配置文件存储目录
/etc/hosts						：IP和主机、域名的映射
/etc/resolv.conf				：定义本地DNS服务器地址及域名
$ grep ^hosts /etc/nsswitch.conf ：定义优先解析hosts文件或dns服务
- files = hosts
- dns = resolve.conf
```

正解反解

```bash
1.主配置文件
[root@servera ~]# vim /etc/named.conf
options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { any; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        allow-query     { any; };
        recursion no;

include "/etc/named.rfc1912.zones";
区域配置文件（辅助配置文件）
[root@servera ~]# vim /etc/named.rfc1912.zones
zone "lab.example.com" IN {
        type master;
        file "lab.example.com.zone";
        allow-update { none; };
};

zone "250.25.172.in-addr.arpa" IN {
        type master;
        file "172.25.250.zone";
        allow-update { none; };
};

2. 正向解析	
[root@servera ~]# cp -a /var/named/named.localhost /var/named/lab.example.com.zone
[root@dns1 ~]# vim /var/named/lab.example.com.zone
$TTL 1D
@       IN SOA  servera.lab.example.com. rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      servera.lab.example.com.
servera A       172.25.250.10
serverb A       172.25.250.11
serverc A       172.25.250.12
serverd A       172.25.250.13

正解文件
$TTL 1D    这里定义的是DNS接收到一个信息后的缓存时间，这个位置和下面的minimum数值保持一致
区域名称        记录类型        SOA         主域名服务器的FQDN        管理员邮箱    邮箱格式中会有@，在这个文件中@代表本域，所以我们的域应该是root@localhost，简化后直接写root
                                                                  序列号        比如说序列号可以以日期方式表示比如20180101，如果更新了就是20180102，默认是0
                                                                  刷新       默认是以秒计算的，多久之后找一次主要服务器
                                                                  重试          如果刷新时间失败，过重试时间再连接服务器
                                                                  过期        以秒来计算的，如果这个时间还没有连接到服务器的话，就过期了
                                                                  TTL时间，设置和上面的TTL 1D为一致
#NS 语法：
#区域名称     IN   NS   本机 完全合格域名


3. 反向解析
反解文件
[root@servera ~]# cp -a /var/named/named.loopback /var/named/172.25.250.zone #注意要加-a保留源文件权限
[root@servera ~]# vim /var/named/172.25.250.zone
$TTL 1D
@       IN SOA  servera.lab.example.com. rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      servera.lab.example.com.
10      PTR     servera.lab.example.com.
11      PTR     serverb.lab.example.com.
12      PTR     serverc.lab.example.com.
13      PTR     serverd.lab.example.com.

[root@servera ~]# named-checkconf 
[root@servera ~]# named-checkzone lab.exmaple.com /var/name/servera.lab.example.com.zone
[root@servera ~]# systemctl restart named
[root@servera ~]# firewall-cmd --permanent  --add-service=dns
[root@servera ~]# firewall-cmd --reload
[root@servera ~]# nslookup servera.lab.example.com.zone
[root@servera ~]# nslookup  172.25.250.10
```

主从

```bash
主从dns
思路：
1 准备主dns服务器 
servera.lab.example.com   172.25.250.10
可以延续上面的实验
2. 准备一台服务器，为从dns
serverb.lab.example.com   172.25.250.11

[kiosk@foundation0 ~]$ ssh root@serverb
[root@serverb ~]# hostname
serverb.lab.example.com

3.安装dns服务
[root@serverb ~]# yum install -y bind

4.配置主配置文件
[root@dns2 ~]# vim /etc/named.conf
options {
        listen-on port 53 { any; };
        ...

        allow-query     { any; };
5.配置区域文件指定主服务器地址等信息
[root@serverb ~]# vim /etc/named.rfc1912.zones
zone "lab.example.com" IN {
        type slave;
        file "slaves/lab.example.com.zone";
        masters { 172.25.250.10; };
};

zone "250.25.172.in-addr.arpa" IN {
        type slave;
        file "slaves/172.25.250.zone";
        masters { 172.25.250.10; };
};


6.重启服务
[root@dns2 named]# systemctl restart named
[root@dns2 named]# ls /var/named/slaves/
192.168.58.zone  kylinos.cn.zone

7.设置dns为本机iP地址
[root@serverb slaves]# vim /etc/resolv.conf
# Generated by NetworkManager
search lab.example.com example.com
nameserver 172.25.250.11
nameserver 172.25.250.254


8.测试
[root@serverb slaves]# nslookup servera
;; Got recursion not available from 172.25.250.11, trying next server
Server:         172.25.250.254
Address:        172.25.250.254#53

Name:   servera.lab.example.com
Address: 172.25.250.10
;; Got recursion not available from 172.25.250.11, trying next server

[root@serverb slaves]# nslookup 172.25.250.10
;; Got recursion not available from 172.25.250.11, trying next server
10.250.25.172.in-addr.arpa      name = servera.lab.example.com.



```

子域委派

防火墙

#### 第三节 Unbound

```
1. 安装unbound
2. 修改配置文件
3. 启动服务
4. 允许防火墙
5. 客户端测试
```

配置unbound

```bash
练习：P106
lab dns-unbound start

[root@servera ~]# yum install -y unbound  #安装Unbound
$vim /etc/unbound/unbound.conf
interface: 172.25.250.10   #响应查询接口，监听IP
access-control: 172.25.0.0/24 allow   #接收哪个网段的请求
domain-insecure: "example.com"  #设置为非安全域
forward-zone:			#允许域名，从哪里缓存
	name: "."
	forward-addr: 172.25.254.254
	
# 如果名称服务器没有开启DNSSEC验证（）	
domain-insecure: example.com  #DNSSEC通过对数据进行数字“签名”来抵御此类攻击

生成unbound服务的私钥和证书
$ unbound-control-setup

检查语法错误
$ unbound-checkconf

启动缓存名称服务器
firewall-cmd  --permanent --add-service=dns
firewall-cmd  --reload
systemctl enable --now unbound 第一次启动约需要1分钟
```

#### 第四节 故障排除

```bash
#vim /etc/nsswitch.conf
host:  files dns myhostname
1 /etc/hosts
2 dns
3 失败将解析自身hostname


host  www.baidu.com
nslookup  www.baidu.com
dig www.baidu.com	 #正解
dig -x www.baidu.com #反解
dig A www.baidu.com  #指定解析A记录 也可以指定MX等
dig @8.8.8.8 A www.baidu.com #@指定解析的服务器
dig +tcp @8.8.8.8 A www.baidu.com  #使用tcp方式查询

```

#### 第五节 自动化配置DNS服务

```bash
部署BIND主或从服务器的基本步骤：
1 安装bind软件
2 为"主"或"从"创建配置后，并重启
3 如果是"主"服务器，保证重启named时可以重新加载它们
4 启动named服务
5 允许防火墙

该命令确保在servera、serverb和serverc上额外配置一个静态ip地址的接口。此外，这个命令配置bastion, labexample .com的权威DNS服务器，将backend.lab.example .com子域委托给serverb。
```

```yaml
---
- name: dns
  hosts: servera
  tasks:
  - name: install the latest version of Apache
    yum:
      name: bind
      state: latest
  - name: named.conf
    copy:
      src: /home/studentnamed.conf
      dest: /etc/named.conf
      owner: root
      group: named
      mode: '0640'
      setype: named_conf_t
    notify:
    - restart named
  - name: zone
    copy:
      src: /var/named/baidu.com.zone
      dest: /var/named/baidu.com.zone
      owner: root
      group: named
      mode: '0640'
      setype: named_zone_t
    notify:
    - reload named
  - name: Start service httpd, if not started
    service:
      name: named
      state: started
      enabled: yes
  - firewalld:
      service: dns
      permanent: yes
      state: enabled
      immediate: yes

  handlers:
  - name: restart named
    service:
      name: named
      state: restarted
  - name: reload named
    service:
      name: named
      state: reload

```

## 4 管理DHCP和IP地址分配

> - :triangular_flag_on_post: 使用DHCP配置IPv4地址分配
> - 配置IPv6地址分配
> - 自动化配置DHCP

#### 第一节 使用DHCP配置IPv4地址分配

```bash
目标：
学习完本节后，学员应能够: 描述 DHCP 协议，并配置 DHCP服务器提供 IPV4 地址池，同时为特定客户端提供保留的地址

1. 描述DHCP
  在大型网络上，为系统分配静态IP 地址比较麻烦。必须仔细跟踪每个地址，以确保不会同时在多个系统上使用它，并且部署新系统时通常需要执行手动分配其IP地址。在云环境中，当用户可以按需部署多个实例时，必须自动化执行网络配置动态主机配置协议 Dynamic Host Configuration Protocol(DHCP) 可为系统自动配置网络参数如：
IP 地址、子网掩码、默认网关、DNS 和域或 NTP ，  DHCP 也可以为特定客户端分配保留的 IP 地址DHCP 
  有两种类似的协议: IPv4 网络的 DHCPV4和 DHCPv6。本节重点个绍 DHCPV4
2. DHCPv4的四次握手
DISCOVER
OFFER
REQUEST
ACK 
3. 部署DHCP服务器
4. 配置DHCP服务
5. 根据MAC地址保留IP地址
6. 验证配置
7. 配置DHCP客户端
```

```bash
练习P185
配置DHCPv4服务
【f0】
[root@foundation0 ~]# ssh workstation
【workstation】
[student@workstation ~]$ lab dhcp-ipv4config start
[student@workstation ~]$ ssh servera
【servera】 
sudo[student@servera ~]$ sudo -i
[sudo] password for student: student
1.设置DHCP服务器固定ip
[root@servera ~]# nmcli connection add con-name ge-conn type ethernet ifname eth1 ipv4.addresses 192.168.0.10/24 ipv4.method manual 	#为eth1创建连接ge-conn
[root@servera ~]# nmcli connection up  ge-conn 	 #启用连接ge-conn
[root@servera ~]# ip a s dev eth1  #查看ip
    inet 192.168.0.10/24 brd 192.168.0.255 scope global noprefixroute eth1
    
2.安装DHCP服务  
[root@servera ~]# yum install -y dhcp-server   
3.部署DHCP服务
[root@servera ~]# cp /usr/share/doc/dhcp-server/dhcpd.conf.example /etc/dhcp/dhcpd.conf #通过模板生成配置文件
cp: overwrite '/etc/dhcp/dhcpd.conf'? y         
[root@servera ~]# vim /etc/dhcp/dhcpd.conf
authoritative;
subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.200 192.168.0.254;
  option domain-name-servers 192.168.254.254;
  option domain-name "example.net";
  option broadcast-address 192.168.0.255;
  default-lease-time 600;
  max-lease-time 7200;
}

4.排查配置错误
[root@servera ~]# dhcpd -t
[root@servera ~]# echo $?  #返回值为0证明配置正确
0
[root@servera ~]#  systemctl enable --now dhcpd
[root@servera ~]# systemctl  status dhcpd
● dhcpd.service - DHCPv4 Server Daemon
   Loaded: loaded (/usr/lib/systemd/system/dhcpd.service; enabled; vendor preset: dis>  #保证开机自启
   Active: active (running) since Mon 2023-03-27 23:56:12 CST; 6s ago #保证服务运行active状态
   
5.防火墙放行dhcp
[root@servera ~]# firewall-cmd --permanent --add-service=dhcp
[root@servera ~]# firewall-cmd --reload

6.客户端测试
[root@servera ~]# ssh serverb
【serverb】
Please type 'yes', 'no' or the fingerprint: yes
root@serverb's password: redhat
[root@serverb ~]# nmcli connection add con-name dhcp-conn type ethernet ifname eth1 ipv4.method auto #获取I
[root@serverb ~]# nmcli connection up dhcp-conn
[root@serverb ~]# ip a s eth1
    inet 192.168.0.200/24 brd 192.168.0.255 scope global dynamic noprefixroute eth1

[root@serverb ~]# cat /etc/resolv.conf 
# Generated by NetworkManager
search lab.example.com example.com example.net
nameserver 172.25.250.254
nameserver 192.168.254.254
[root@serverb ~]# logout


配置mac地址绑定
【servera】
1.配置服务
[root@servera ~]# vim /etc/dhcp/dhcpd.conf 
authoritative;
subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.200 192.168.0.254;
  option domain-name-servers 192.168.254.254;
  option domain-name "example.net";
  option broadcast-address 192.168.0.255;
  default-lease-time 600;
  max-lease-time 7200;
}

host serverc {
  hardware ethernet 52:54:00:01:fa:0c;   #设置serverc的mac地址
  fixed-address 192.168.0.100;           #设置对应IP
}
2.检测配置错误
[root@servera ~]# dhcpd -t
[root@servera ~]# echo $?
0
[root@servera ~]# systemctl  restart dhcpd
[root@servera ~]# ssh serverc
root@serverc's password: redhat
【serverc】
1.测试
[root@serverc ~]# nmcli connection add con-name dhcp-conn type ethernet ifname eth1 ipv4.method auto
[root@serverc ~]# nmcli connection up dhcp-conn
[root@serverc ~]# ip a s eth1
    link/ether 52:54:00:01:fa:0c brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.100/24 brd 192.168.0.255 scope global dynamic noprefixroute eth1  #成功分配
   
```

#### 第二节： 配置IPv6地址分配

```
1.IPv6地址自动配置概述
2.回顾IPv6本地链路（link-local）地址分配：
3.IPv6无状态地址自动配置（SLAAC）：
	监控路由器公告消息RA
4.实施DHCPv6
	部署DHCPv6服务器
	配置DHCPv6服务器
	保留IPv6地址
	手动生成DUID
	配置DHCP服务器
	验证配置后启动服务
5.客户端配置自动地址分配方法
```

```bash
练习P201：
[student@workstation ~]$ lab dhcp-ipv6config start
[student@workstation ~]$ ssh server
[student@servera ~]$ sudo -i
[sudo] password for student: 
[root@servera ~]# nmcli connection add con-name ge-conn type ethernet ifname eth1 ipv6.addresses fde2:6494:1e09:2::a/64 ipv6.method manual
[root@servera ~]# nmcli connection up ge-conn
[root@servera ~]# ip -6 add show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
    inet6 fe80::2ebc:4982:967a:a04c/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
       
       
[root@servera ~]# yum install radvd
[root@servera ~]# radvdump
# based on Router Advertisement from fe80::7f7:e9d4:a5ca:f6b `1 该IPv6地址是IPv6路由器的链路本地地址。在本练习中，serverd充当网络的路由器。
interface eth1
{
	AdvSendAdvert on;  `2 IPv6路由器在网络上定期发送RA。
	# Note: {Min,Max}RtrAdvInterval cannot be obtained with radvdump
	AdvManagedFlag on;  `3 IPv6路由器指示客户端查询DHCPv6服务器以获取接口IPv6地址ID，而不是自己计算。
	AdvOtherConfigFlag on;  `4 IPv6路由器指示客户端查询DHCPv6服务器以检索剩余的网络配置，例如DNS参数。
	

在接下来的步骤中，部署DHCPv6服务器提供IPv6地址的接口ID和DNS参数。`

[root@servera ~]# vim /etc/dhcp/dhcpd
dhcpd6.conf  dhcpd.conf   
[root@servera ~]# vim /etc/dhcp/dhcpd6.conf 
[root@servera ~]# cp /usr/share/doc/dhcp-server/dhcpd6.conf.example /etc/dhcp/dhcpd6.conf
cp: overwrite '/etc/dhcp/dhcpd6.conf'? y
[root@servera ~]# vim /etc/dhcp/dhcpd6.conf
authoritative;
subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.200 192.168.0.254;
  option domain-name-servers 192.168.254.254;
  option domain-name "example.net";
  option broadcast-address 192.168.0.255;
  default-lease-time 600;
  max-lease-time 7200;
}
[root@servera ~]# dhcpd -t  6 -cf /etc/dhcp/dhcpd6.conf 
[root@servera ~]# nmcli connection delete ge-conn 
[root@servera ~]# nmcli connection up  ge-conn 
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/5)
[root@servera ~]# ip -6 a s eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
    inet6 fde2:6494:1e09:2::a/64 scope global noprefixroute 
       valid_lft forever preferred_lft forever
    inet6 fe80::d3a0:9511:487a:696/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
[root@servera ~]# systemctl restart dhcpd6
[root@servera ~]# systemctl enable dhcpd6
Created symlink /etc/systemd/system/multi-user.target.wants/dhcpd6.service → /usr/lib/systemd/system/dhcpd6.service.
[root@servera ~]# 
[root@servera ~]# systemctl status dhcpd6
[root@servera ~]# firewall-cmd --permanent --add-service=dhcpv6
success
[root@servera ~]# firewall-cmd --reload


【serverb】 获取ip
[root@foundation0 ~]# ssh serverb
[student@serverb ~]$ sudo -i
[sudo] password for student:     
[root@serverb ~]# nmcli connection delete dhcp-conn
[root@serverb ~]# nmcli connection show  
[root@serverb ~]# nmcli connection add con-name dhcp-conn type ethernet ifname eth1 ipv4.method auto
[root@serverb ~]# nmcli connection up dhcp-conn 
[root@serverb ~]# ip -6 a s eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP qlen 1000
    inet6 fde2:6494:1e09:2::60/128 scope global dynamic noprefixroute 
   
[root@serverb ~]# cat /etc/resolv.conf 
nameserver fde2:6494:1e09:2::d

[root@serverb ~]# ip -6 route
::1 dev lo proto kernel metric 256 pref medium
fde2:6494:1e09:2::60 dev eth1 proto kernel metric 101 pref medium
fe80::/64 dev eth0 proto kernel metric 100 pref medium
fe80::/64 dev eth1 proto kernel metric 101 pref medium
default via fe80::7f7:e9d4:a5ca:f6b dev eth1 proto ra metric 101 pref medium

DUID绑定
【servera】
[root@servera ~]# vim /etc/dhcp/dhcpd.conf  #配置文件从/usr/share/doc/dhcp-serer/中复制
authoritative;
subnet 192.168.0.0 netmask 255.255.255.0 {
  range 192.168.0.200 192.168.0.254;
  option domain-name-servers 192.168.254.254;
  option domain-name "example.net";
  option broadcast-address 192.168.0.255;
  default-lease-time 600;
  max-lease-time 7200;
}
host serverc {
        host-identifier option
                dhcp6.client-id 2c:c1:37:81:36:68:48:8f:85:ab:65:b5:77:63:41:4e;
        fixed-address6 fde2:6494:1e09:2::0451;
}
[root@servera ~]# systemctl restart dhcpd6


【serverc】
host serverc {
        host-identifier option
                dhcp6.client-id 2c:c1:37:81:36:68:48:8f:85:ab:65:b5:77:63:41:4e;
        fixed-address6 fde2:6494:1e09:2::0451;
}
```

#### 第三节 自动化执行DHCP配置

```bash
1.安装软件包
2.部署DHCP配置文件
3.启动服务
4.配置防火墙规则
5.使用Ansible配置DHCP客户端
```

```bash
P213
教材中是半成品剧本可以完善内容，并测试

wait_for模块： 用来在规定时间内检测状态是否为期望状态，才会执行后续操作
 - name: the system can connect to servera IPv4 address
      wait_for:
        host: 192.168.0.10  #等待可解析主机名或IP地址
        port: 22   #和path选项互斥，轮询端口
        timeout: 10 #默认300秒，等待最大秒数。

```



## 5 管理打印机和打印文件

> - 配置和管理打印机
> - :triangular_flag_on_post: 自动化配置打印机 

#### 第一节 配置和管理打印机

```bash
1.描述CUPS打印架构
2.使用IPP Everywhere发现网络打印机
3.部署打印机
安装软件
调整防火墙，允许mdns
ippfind发现网络上可用的打印机
创建打印队列
打印文件和管理打印作业
管理打印机队列
lpinfo -v  :要求CUPS给出可以使用的后端列表（设备列表）
lpinfo -m  :要求CUPS给出可以使用的驱动列表
lpadmin -p 打印机名称 -E -v  打印机链接   ：增加打印机并且启动打印机
lpadmin -x 打印机名  ：删除打印机，打印机名先用lpstat  -a 查看，删除后用指令确认一下
lpadmin -d 定义默认打印队列
lpoptions  -d 打印机名称       ：指定默认打印机
lpr -P 打印机名称  文件名称         ：打印文件   增加一个打印作业.
lpq    -a   ：显示出目前所有打印机的工作队列情况
lprm 打印任务id    ：删去一个打印作业
lpstat -a		    查看已有打印机。            
lpstat -d           查看默认打印机
```

```bash
练习P242
[student@workstation ~]$ lab printing-config start
[student@servera ~]$ sudo -i
[sudo] password for student: student
1.安装软件cups avahi
[root@servera ~]# yum provides lpadmin
[root@servera ~]# yum install cups avahi
2.启动服务cups
[root@servera ~]# rpm -ql cups | grep service
/usr/lib/systemd/system/cups.service
[root@servera ~]# systemctl enable --now cups
3.允许防火墙mdns
[root@servera ~]# firewall-cmd --permanent --add-service=mdns
success
[root@servera ~]# firewall-cmd --reload
success
4.创建打印队列
[root@servera ~]# man lpadmin   # 搜索/EX 
[root@servera ~]# lpadmin -p new-printer -E -v ipp://serverc.lab.example.com:631/printers/rht-printer -m everywhere
5.设置默认队列
[root@servera ~]# lpadmin -d new-printer
```

#### 第二节 自动化执行打印机配置

```yaml
P250
1.安装软件
2.启动服务
3.创建打印队列
4.设置默认队列
5.防火墙
vim printer-create.yml
---
- name: Install CUPS and create a print queue
  hosts: servera.lab.example.com
  gather_facts: no
  become: yes
  tasks:
  - name: install the latest version of Apache
    yum:
      name:
      - cups
      - avahi
      state: latest
  - name: Start service httpd, if not started
    service:
      name: cups
      state: started
      enabled: yes
  - name: Start service httpd, if not started
    service:
      name: avahi-daemon
      state: started
  - name: return motd to registered var
    command: lpadmin -p new-printer -E -v ipp://serverc.lab.example.com:631/printers/rht-printer -m everywhere
  - name: return motd to registered var
    command: lpadmin -d new-printer

  - firewalld:
      service: mdns
      permanent: yes
      state: enabled
      immediate: yes

```



## 6 配置邮件传输

> - 配置一个仅发送邮件服务器
> - :triangular_flag_on_post: 自动配置Postfix

|                             |               Windows               |                         Linux                          |        |
| :-------------------------: | :---------------------------------: | :----------------------------------------------------: | :----: |
| MTA<br>Mail Transport Agent | Microssoft/Exchange, <br>IBM/Domino |     RHEL8 **postfix**<br>RHEL<=7 sendmail<br>qmail     |  邮局  |
| MDA<br>mail delivery agents |                                     |                                                        | 邮递员 |
|   MUA<br>mail user agent    |        outlook, <br>foxmail         | GUI: evolution, thunderbird<br>CLI: **mail**, **mutt** |  客户  |

| PROTOCOL |      |          | Package | PORT |
| :------: | :--: | :------: | :-----: | :--: |
|   smtp   | 发送 |          | postfix |  25  |
|   imap   | 接收 | 同步sync | dovecot | 143  |
|   pop3   | 接收 | 拷贝copy | dovecot | 110  |

#### **第一节**：**配置仅发送电子邮件服务**

```

```



#### **第**二节：自动化执行Postfix配置

```
练习P278
```



## 7 配置MariaDB SQL数据库

> - :triangular_flag_on_post: 安装MariaDB数据库  
> - :triangular_flag_on_post: MariaDB中SQL管理
> - :triangular_flag_on_post: MariaDB用户和访问权限
> - 备份和:triangular_flag_on_post: 恢复MariaDB
> - 自动化部署MariaDB

> mysql -=> mariadb

| SQL  |                 CMD（help CMD;）                 |       COMMENT        |
| :--: | :----------------------------------------------: | :------------------: |
| DDL  | **create**, alter, drop, **show**, use, DESCRIBE | 数据定义语言（结构） |
| DML  |        **select**, insert, update, delete        | 数据操纵语言（内容） |
| DCL  |                **grant**, revoke                 | 数据控制语言（权限） |

#### **第一节：**安装 **MariaDB** **数据库**

```bash
 数据库简介
数据库的概念诞生于60年前，随着信息技术和市场的快速发展，数据库技术层出不穷。
数据库的发展大致划分为几个阶段：人工管理阶段、文件系统阶段、数据库系统阶段、高级数据库阶段。
类型大概3中：层次式数据库、网络式数据库、关系式数据库。
数据库的概念没有完全固定的定义，数据库（DataBase，DB）是一个长期存储在计算机内的、有组织的、有共享的、统一管理数据集合。它按数据结构来存储和管理数据的计算机软件系统，即数据库包含两层涵义：保管数据的仓库、以及数据管理的方法和技术。
数据库的特点：实现数据共享，减少数据冗余；采用特定的数据类型；具有较高的数据独立性；具有统一的数据控制功能。

出于数据量、规范性的问题：
	RDBMS ---->  Relation Database Management System  关系型数据库管理系统
	
1.2.表
关系数据库中，数据库表 是一系列二维数组的集合。（二维表）用来存储数据和操作数据的逻辑结构。由纵向的列和横向的行组成，行被称为记录，是组织数据的单位；列被称为字段。	每列表示记录的一个属性，都有相应的描述信息，如数据类型、数据宽度等。
数据存储结构：
	数据库 
		表
			（列）字段	column
		 	（行）记录	record

1.3.数据类型
数据类型决定了数据在计算机中存储格式，代表不同的信息类型。常用的类型有：整数、浮点数、精确小数、二进制、日期/时间、字符串。表中每个字段就是某种数据类型，如“编号”字段为整数，如：性别，字段为字符型数据。

关系型数据库管理软件
按开源分类：
开源：MySQL、MongoDB、PostgreSQL、Redis，DB2
闭源：Oracle、SQL Server
其中常见关系型数据库： MySQL、Oracle、PostgreSQL


SQL(Structure Query Language)语句
DDL（Data Definition Languages）语句：即数据库定义语句，用来创建数据库中的表、索引、视图、存储过程、触发器等，常用的语句关键字有：CREATE,ALTER,DROP,TRUNCATE,COMMENT,RENAME。

DML（Data Manipulation Language）语句：即数据操纵语句，用来查询、添加、更新、删除等，常用的语句关键字有：SELECT,INSERT,UPDATE,DELETE,MERGE,CALL,EXPLAIN PLAN,LOCK TABLE,包括通用性的增删改查。

DCL（Data Control Language）语句：即数据控制语句，用于授权/撤销数据库及其字段的权限（DCL is short name of Data Control Language which includes commands such as GRANT and mostly concerned with rights, permissions and other controls of the database system.）。常用的语句关键字有：GRANT,REVOKE。

TCL（Transaction Control Language）语句：事务控制语句，用于控制事务，常用的语句关键字有：COMMIT,ROLLBACK,SAVEPOINT,SET TRANSACTION。


场景
1、用户通过网站或app注册信息或写入信息
2、开发负责编写网站与数据库的接口
3、运维的工作：搭建、备份、优化
```

![clipboard](C:\Users\guoyu\Desktop\clipboard.png)

![1622605182(1)](C:\Users\guoyu\Desktop\1622605182(1).png)

```bash
1.安装数据库
# yum install -y mariadb-server
2.设置网络控制
[mysqld]
skip-networking=1  #关闭远程监听，只可以本地登录服务器
3.设置数据库初始化安全
mysql_secure_installation
```

```bash
练习P294
[student@workstation ~]$ lab database-intro start
[root@servera ~]# yum install -y mariadb-server
[root@servera ~]# systemctl enable --now mariadb
[root@servera ~]# ss -tulpn | grep mysqld
[root@servera ~]#  vim /etc/my.cf.d/mariadb-server.cnf
[mysqld]
skip-networking=1
[root@servera ~]# systemctl  restart mariadb
[root@servera ~]# ss -tulpn | grep mysqld
[root@servera ~]#  mysql_secure_installation
Enter current password for root (enter for none): 回车   
Set root password? [Y/n]  Y
New password: redhat
Re-enter new password: redhat
Remove anonymous users? [Y/n] Y 
Disallow root login remotely? [Y/n] Y
Remove test database and access to it? [Y/n] Y
Reload privilege tables now? [Y/n] Y
 ... Success!
[root@servera ~]# mysql -u root
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
[root@servera ~]# mysql -u root -predhat
MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.005 sec)

MariaDB [(none)]> exit
Bye
[root@servera ~]# logout
[student@servera ~]$ logout
Connection to servera closed.
[student@workstation ~]$ lab database-intro finish 
```



#### **第二节：在MariaDB中使用**SQL

```bash
1.登录数据库
mysql -u root -predhat   #xxx
2.库-管理
SHOW DATABASES;
CREATE DATABASE HAHA;
USE HAHA;
DROP DATABASE HAHA;
3.表-管理
SHOW TABLES;
DESCRIBE user； #or  DESC user；
DROP TABLE tbl_name;
-----
SHOW CREATE TABLE product\G;

4.表数据-管理
SELECT * FROM user;
SELECT * FROM user\G;
SELECT Host,User,Password From user;
UPDATE tbl_name SET col_name=expr WHERE col_name=expr;
INSERT INTO tbl_name col_name VALUES  expr
DELETE FROM category WHERE name LIKE 'Memory';

5.表查询
SELECT * FROM product;  #单表查询，列出product表所有列
SELECT name FROM product;  #指定表中某列查询，只列出name列；
SELECT id,name,price FROM product; #指定多列查询，列出id,name,price三列；
SELECT 字段 FROM 表名 WHERE 查询条件  #查询时使用WHERE子句对数据进行过滤；
SELECT name,price FROM product WHERE id=2;  #只列出name，price列，条件为id=2；那一行数据
SELECT name,price FROM product WHERE id<2;
SELECT name,price FROM product WHERE id<=2;
SELECT name,price FROM product WHERE id>2;
SELECT name,price FROM product WHERE id>=2;
SELECT name,price FROM product WHERE id!=2;
SELECT * FROM product WHERE id BETWEEN 2 AND 4;  #WHERE是设置条件，BETWEEN 设置范围
SELECT name,price FROM product WHERE name LIKE 'T%'; #只列出name，price列，T开头的。%匹配任意长度的字符，包含零字符
SELECT id,name,price FROM product WHERE stock=20 AND price=539.88; #带AND多条件查询
SELECT manufacturer.name FROM manufacturer,product WHERE product.name = 'RT-AC68U' AND id_manufacturer=manufacturer.id; 
SELECT count(*) 
	FROM category, manufacturer, product
	WHERE category.id=product.id_category
 		AND manufacturer.id=product.id_manufacturer
 		AND category.name="Servers"
 		AND manufacturer.name="Lenovo";
SELECT sum(product.stock) FROM category,manufacturer,product WHERE product.id_category=category.id AND product.id_manufacturer=manufacturer.id AND category.name='Servers' AND manufacturer.name='Lenovo';
```

```sql
P305
【workstation】
[student@workstation ~]$ lab database-working start
[student@workstation ~]$ ssh servera
[student@servera ~]$ mysql -u root -p
Enter password:redhat
MariaDB [(none)]> SHOW DATABASES;  #查询有哪些库
MariaDB [(none)]> USE mysql;  #进入库
MariaDB [mysql]> SHOW TABLES;  #进库后查表
MariaDB [mysql]> DESCRIBE user;  #查看表结构
MariaDB [mysql]> SELECT Host,User,Password FROM user;   #根据特定字段查看表数据
MariaDB [mysql]> USE inventory;
MariaDB [inventory]> SHOW TABLES;
MariaDB [inventory]> DESCRIBE category;
MariaDB [inventory]> DESCRIBE manufacturer;
MariaDB [inventory]> DESCRIBE product;
MariaDB [inventory]> SELECT * FROM category;
MariaDB [inventory]> SELECT * FROM manufacturer;
MariaDB [inventory]> SELECT * FROM product;
MariaDB [inventory]> HELP UPDATE
MariaDB [inventory]> SELECT * FROM product;
MariaDB [inventory]> UPDATE product SET price='2179.14',stock='10' WHERE id=2; #更改表数据
MariaDB [inventory]> SELECT * FROM product;
+----+-------------------+---------+-------+-------------+-----------------+
| id | name              | price   | stock | id_category | id_manufacturer |
+----+-------------------+---------+-------+-------------+-----------------+
|  2 | ThinkServer RD630 | 2179.14 |    10 |           2 |               4 |
MariaDB [inventory]> HELP INSERT INTO
MariaDB [inventory]> HELP INSERT
MariaDB [inventory]> INSERT INTO product ( name,price,stock,id_category,id_manufacturer) VALUES ('ThinkStation S20','1799.24','15',2,4);  #添加新数据
MariaDB [inventory]> SELECT * FROM product;
+----+-------------------+---------+-------+-------------+-----------------+
| id | name              | price   | stock | id_category | id_manufacturer |
+----+-------------------+---------+-------+-------------+-----------------+
|  5 | ThinkStation S20  | 1799.24 |    15 |           2 |               4 |
+----+-------------------+---------+-------+-------------+-----------------+
MariaDB [inventory]> exit
Bye
[student@servera ~]$ logout
Connection to servera closed.
```

```bash
忘记密码怎么办？
[root@servera ~]# vim /etc/my.cnf.d/mariadb-server.cnf 
[mysqld]
skip-grant-tables   #添加这个，跳过密码
[root@servera ~]# systemctl restart mariadb
[root@servera ~]# mysql -u root -p
Enter password: #直接回车
MariaDB [(none)]> USE mysql;
MariaDB [mysql]> UPDATE user SET password=password("flectrag") WHERE user='root';
MariaDB [mysql]> FLUSH PRIVILEGES;  #刷新缓存
Query OK, 0 rows affected (0.001 sec)
MariaDB [mysql]> QUIT
Bye   
[root@servera ~]# vim /etc/my.cnf.d/mariadb-server.cnf 
[mysqld]
#skip-grant-tables   #注释这个，跳过密码
[root@servera ~]# systemctl restart mariadb
[root@servera ~]# mysql -u root -pflectrag
MariaDB [(none)]> 

```

#### 第三节：管理 **MariaDB** **用户和访问权限**

```mysql
1.为数据库创建用户
CREATE USER 'john'@'localhost' IDENTIFIED BY 'john_password';
2.给用户授权
GRANT INSERT,UPDATE,DELETE,SELECT ON inventory.* TO 'john'@'localhost';
```

```mysql
练习P317
[student@workstation ~]$ lab database-users start
[student@workstation ~]$ ssh servera
[student@servera ~]$ sudo -i
[sudo] password for student:
[root@servera ~]# mysql -u root -predhat
MariaDB [(none)]> HELP GRANT
GRANT SELECT ON db2.invoice TO 'jeffrey'@'localhost';

MariaDB [(none)]> CREATE USER 'john'@'localhost' IDENTIFIED BY 'john_password';
MariaDB [(none)]> CREATE USER 'steve'@'%' IDENTIFIED BY 'steve_password';
MariaDB [(none)]> HELP GRANT
CREATE USER 'jeffrey'@'localhost' IDENTIFIED BY 'mypass';

MariaDB [(none)]> GRANT INSERT,UPDATE,DELETE,SELECT ON inventory.* TO 'john'@'localhost';
MariaDB [(none)]> GRANT SELECT ON inventory.* TO 'steve'@'%';                         
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> QUIT
Bye

[root@servera ~]# mysql -u john -pjohn_password
MariaDB [inventory]> SHOW TABLES;
MariaDB [inventory]> SELECT * FROM category;
MariaDB [inventory]> INSERT INTO category(name) VALUES('Memory');
MariaDB [inventory]> UPDATE category SET name='haha' WHERE id=3;
MariaDB [inventory]> HELP DELETE
DELETE [LOW_PRIORITY] [QUICK] [IGNORE] FROM tbl_name
    [WHERE where_condition]
    [ORDER BY ...]
    [LIMIT row_count]
MariaDB [inventory]> DELETE FROM category WHERE name LIKE 'Memory';
MariaDB [inventory]> quit
Bye

[root@servera ~]# mysql -u steve -psteve_password
MariaDB [inventory]> SELECT * FROM category;
MariaDB [inventory]> INSERT INTO category(name) VALUES('Memory');
ERROR 1142 (42000): INSERT command denied to user 'steve'@'localhost' for table 'category'
MariaDB [inventory]> exit
Bye
[root@servera ~]# logout
[student@servera ~]$ logout
Connection to servera closed.
[student@workstation ~]$ lab database-users finish
```

#### 第四节：创建和恢复Maria DB备份

```
逻辑备份：以文本文件的形式导出信息，其中包含重新创建数据库所需的 SQL 命令
物理备份：复制包含数据库内容的原始数据库目录和文件
```

```mysql
练习P326 逻辑备份和恢复
[student@workstation ~]$ lab database-backups start
[student@workstation ~]$ ssh servera
[student@servera ~]$ mysql -u root -predhat
MariaDB [(none)]> USE inventory;
MariaDB [inventory]> SELECT * FROM product;
+----+-------------------+---------+-------+-------------+-----------------+
| id | name              | price   | stock | id_category | id_manufacturer |
+----+-------------------+---------+-------+-------------+-----------------+
|  1 | ThinkServer TS140 |  539.88 |    20 |           2 |               4 |
|  2 | ThinkServer RD630 | 2379.14 |    20 |           2 |               4 |
|  3 | RT-AC68U          |  219.99 |    10 |           1 |               3 |
|  4 | X110 64GB         |   73.84 |   100 |           3 |               1 |
+----+-------------------+---------+-------+-------------+-----------------+
MariaDB [inventory]> exit
Bye

[student@servera ~]$ mysqldump -u root -p inventory > inventory-backup.sql
Enter password: redhat
[student@servera ~]$ mysql -u root -predhat
MariaDB [(none)]> USE inventory;
MariaDB [inventory]> DELETE FROM product WHERE id=1;
MariaDB [inventory]> SELECT * FROM product;
+----+-------------------+---------+-------+-------------+-----------------+
| id | name              | price   | stock | id_category | id_manufacturer |
+----+-------------------+---------+-------+-------------+-----------------+
|  2 | ThinkServer RD630 | 2379.14 |    20 |           2 |               4 |
|  3 | RT-AC68U          |  219.99 |    10 |           1 |               3 |
|  4 | X110 64GB         |   73.84 |   100 |           3 |               1 |
+----+-------------------+---------+-------+-------------+-----------------+
MariaDB [inventory]> exit
Bye

[student@servera ~]$ mysql -u root -p inventory < inventory-backup.sql
Enter password: redhat
[student@servera ~]$ mysql -u root -p
Enter password: redhat
MariaDB [(none)]> USE inventory;
MariaDB [inventory]> SELECT  * FROM product;
+----+-------------------+---------+-------+-------------+-----------------+
| id | name              | price   | stock | id_category | id_manufacturer |
+----+-------------------+---------+-------+-------------+-----------------+
|  1 | ThinkServer TS140 |  539.88 |    20 |           2 |               4 |
|  2 | ThinkServer RD630 | 2379.14 |    20 |           2 |               4 |
|  3 | RT-AC68U          |  219.99 |    10 |           1 |               3 |
|  4 | X110 64GB         |   73.84 |   100 |           3 |               1 |
+----+-------------------+---------+-------+-------------+-----------------+
4 rows in set (0.001 sec)

MariaDB [inventory]> exit
Bye
[student@servera ~]$ logout
[student@workstation ~]$ lab database-backups finish
```

#### 第五节 自动部署Maria DB

```
1.使用Ansible部署MariaDB
2.使用Ansible管理MariaDB用户
3.使用Ansible创建备份文件并从中恢复
```

```bash
练习：P337
[student@workstation ~]$ lab database-automation start
[student@workstation ~]$ cd ~/database-auto/
[student@workstation database-auto]$ tree -F
.
├── ansible.cfg
├── configure_mariadb_security.yml
├── configure_users.yml
├── dump_inventory_db.yml
├── files/
│   ├── inventory-database.sql
│   └── my.cnf
├── import_inventory_db.yml
├── install_mariadb_client.yml
├── install_mariadb_server.yml
├── inventory
├── restore_inventory_db.yml
 #安装mariadb服务端
[student@workstation database-auto]$ vim install_mariadb_server.yml 
---
- name: Install MariaDB server
  hosts: db_servers
  become: yes

  tasks:
  - name: Install mariadb-server package
    yum:
      name: mariadb-server   #软件安装
      state: present

  - name: Enable and start mariadb
    service:
      name: mariadb   #启动服务
      state: started
      enabled: yes

  - name: Firewall permits mysql service
    firewalld:
      service: mysql   #允许防火墙
      permanent: true
      state: enabled
      immediate: yes
[student@workstation database-auto]$ ansible-playbook install_mariadb_server.yml
 #安装mariadb客户端
[student@workstation database-auto]$ vim install_mariadb_client.yml
---
- name: Install MariaDB client
  hosts: db_clients
  become: yes

  tasks:
    - name: Install mariadb client package
      yum:
        name: mariadb  #客户端软件
        state: present

[student@workstation database-auto]$ ansible-playbook install_mariadb_client.yml

[student@workstation database-auto]$ ansible-vault  create group_vars/db_servers/vault.yml
New Vault password:fedora
Confirm New Vault password:fedora
pw： redhat

#配置数据库安全
[student@workstation database-auto]$ vim configure_mariadb_security.yml
---
- name: Securing MariaDB
  hosts: db_servers
  become: yes

  tasks:
    - name: Assign password to MariaDB root user
      mysql_user:
        name: root
        host_all: yes
        update_password: always   #重置root密码
        password: "{{ pw }}"

    - name: Authentication credentials copied to root home directory
      copy:
        src: files/my.cnf
        dest: /root/.my.cnf    #验证信息复制到/root/.my.cnf，内容是client的账号密码

    - name: Remove anonymous user accounts
      mysql_user:
        name: ''  #删除匿名用户
        host_all: yes
        state: absent

    - name: Remove test database
      mysql_db:      #使用mysql_db模块删除test库
        name: test  
        state: absent
[student@workstation database-auto]$ ansible-playbook --vault-id @prompt configure_mariadb_security.yml
Vault password (default):fedora

#恢复inventory数据库

#先创建数据库
[student@workstation database-auto]$ vim restore_inventory_db.yml
---
- name: Restore inventory database if not present
  hosts: db_servers
  become: yes

  tasks:
    - name: Make sure inventory database exists
      mysql_db:
        name: inventory   #创建库
        state: present
      register: inventory_present

    - name: Is inventory database backup present?
      stat:
        path: /srv/inventory-database.sql   #检查是否存在
      register: inventory_bkup

    - name: Copy database backup file to host if not present
      copy:
        src: files/inventory-database.sql   #拷贝库文件至主机/srv
        dest: /srv
      when:
        - inventory_present['changed'] == true
        - inventory_bkup['stat']['exists'] == false    #判断是否存在

    - name: Restore inventory backup data
      mysql_db:
        name: inventory   
        state: import   #将数据文件导入数据库
        target: /srv/inventory-database.sql
      when: inventory_present['changed'] == true
[student@workstation database-auto]$ ansible-playbook restore_inventory_db.yml --vault-id @prompt
Vault password (default):fedora

#备份数据库
[student@workstation database-auto]$ vim dump_inventory_db.yml
---
- name: Database backup
  hosts: db_servers
  become: yes

  tasks:
    - name: Backup inventory database
      mysql_db:
        state: dump
        name: inventory
        target: /home/student/inventory.dump
[student@workstation database-auto]$ ansible-playbook --vault-id @prompt dump_inventory_db.yml
Vault password (default):fedora
#结束

#关于用户授权部分，可以参考教材练习
```



## 8 配置Web服务器

> - :triangular_flag_on_post: 使用Apache HTTPD配置一个基本Web服务器
> - :triangular_flag_on_post:使用Apache HTTPD配置和排故虚拟主机
> - :triangular_flag_on_post:配置Apache HTTPD HTTPS
> - :triangular_flag_on_post:使用Nginx配置一个Web服务器
> - 自动化配置Web服务器

> `当存在虚拟主机时，第一个虚拟主机会覆盖默认的web站点`

|    TYPE    |     PKG     |                URL                 |                      |      |
| :--------: | :---------: | :--------------------------------: | :------------------: | :--: |
|    http    |    httpd    |    http://www0.lab.example.com     | 基于`名称`的虚拟主机 |  80  |
|   vhost    |    httpd    |   http://webapp0.lab.example.com   | 基于`名称`的虚拟主机 |  80  |
|   https    |   mod_ssl   |    https://www0.lab.example.com    | 基于`端口`的虚拟主机 | 443  |
| permission | http_manual | http://www0.lab.example.com/manual |         权限         |      |

| 密文  |    明文    |        公钥         |        私钥         |
| :---: | :--------: | :-----------------: | :-----------------: |
| https | http + ssl | *.crt public / Lock | *.key private / Key |
|  ssh  |   telnet   |                     |                     |

|        |      优点      |     缺点     |      |
| :----: | :------------: | :----------: | ---- |
| apache |      稳定      | 组件多，重量 |      |
| nginx  | 反向代理，轻量 |              |      |

#### 第一节： **配置基本** **Web** **服务器**

```bash
1.安装httpd
# yum install -y httpd httpd-manual
2.httpd的配置文件
#/etc/httpd/conf/httpd.conf
/etc/httpd/conf.d/   #辅助配置文件
3.允许防火墙，开启自启动
# firewall-cmd --permanent --add-service=http
```

```bash
练习P373
[student@workstation ~]$ lab web-basic start
[student@servera ~]$ sudo -i
[sudo] password for student: student
[root@servera ~]# yum install -y httpd httpd-manual
[root@servera ~]# vim /etc/httpd/conf/httpd.conf 
ServerAdmin webmaster@localhost  #设置管理员邮箱
[root@servera ~]# echo 'hello Class!' > /var/www/html/index.html #制作index索引页面
[root@servera ~]# systemctl enable --now httpd
[root@servera ~]# firewall-cmd --permanent --add-service=http
[root@servera ~]# firewall-cmd --reload
[root@servera ~]# curl servera
hello Class!
[root@servera ~]# logout
[student@servera ~]$ logout
[student@workstation ~]$ lab web-basic finish
```

#### 第二节**虚拟主机进行配置和故障排除**

```bash
1.配置虚拟主机
[root@servera ~]# cp /usr/share/doc/httpd/httpd-vhosts.conf /etc/httpd/conf.d/00-default-vhost.conf
[root@servera ~]# vim /etc/httpd/conf.d/01-www-x.lab.example.com-vhost.conf
<VirtualHost *:80>
    ServerName www-x.lab.exmaple.com    #网站名称
    ServerAlias www-x #网站别名
    DocumentRoot "/srv/www-x.lab.example.com/www"  #发布目录
    CustomLog "logs/www-x.lab.exampole.com.log" combined  #访问日志文件位置
    <Directory /srv/www-x.lab.example.com/www>
        Require all granted   #授权所有人访问
    </Directory>
</VirtualHost>
2.选择虚拟主机
```

```bash
练习：P378
#建立两个虚拟主机，一个为默认站点，一个为www-a.lab.example.com站点
[student@workstation ~]$ lab web-basic start
[student@servera ~]$ sudo -i
[sudo] password for student: student
[root@servera ~]# yum install -y httpd
[root@servera ~]# mkdir -p /srv/{default,www-x.lab.exmample.com}/www
[root@servera ~]# echo "comin soon!" > /srv/default/www/index.html
[root@servera ~]# echo "www-x" > /srv/www-x.lab.exmample.com/www/index.html
[root@servera ~]# restorecon -Rv /srv
[root@servera ~]# cp /usr/share/doc/httpd/httpd-vhosts.conf /etc/httpd/conf.d/00-default-vhost.conf
[root@servera ~]# vim /etc/httpd/conf.d/00-default-vhost.conf
<VirtualHost _default_:80>
    DocumentRoot "/srv/default/www"
    CustomLog "logs/default-vhost.log" combined
    <Directory /srv/default/www>
    Require all granted
    </Directory>
</VirtualHost>

[root@servera ~]# cp /usr/share/doc/httpd/httpd-vhosts.conf [root@servera ~]# vim /etc/httpd/conf.d/01-www-x.lab.example.com-vhost.conf
[root@servera ~]# vim /etc/httpd/conf.d/01-www-x.lab.example.com-vhost.conf
<VirtualHost *:80>
    DocumentRoot "/srv/www-x.lab.example.com/www/"
    ServerName www-x.lab.example.com
    ServerAlias www-x
    CustomLog "logs/www-x.lab.example.com.log"  combined
    <Directory /srv/www-x.lab.example.com/www/>
        Require all granted
    </Directory>
</VirtualHost>


[root@servera ~]# systemctl  enable --now httpd
[root@servera ~]# logout
[student@workstation ~]$ curl http://www-x/www
www-x
[student@workstation ~]$ curl http://servera
Coming soon!
[student@workstation ~]$ curl http://172.25.250.10
Coming soon!
```

访问控制

```html
允许所有人访问请求
<RequireAll>
    Require all granted
</RequireAll>
拒绝所有人访问
<RequireAll>
    Require all denied
</RequireAll>
允许特定主机，或IP、网段
<RequireAll>
    Require host example.com
    Require ip 172.25.250.1  172.25.250.2
    Require ip 172.25.250.0/24
</RequireAll>
拒绝某台主机
<RequireAll>
    Require  ip 172.25.250.1
    Require  not ip 172.25.250.2
    Require  host lab.example.com
    Require  not host lab.example.org
    Require all granted
</RequireAll>
```



#### **第三节 **使用 **Apache HTTPD**配置 **HTTPS**目标

```
1.描述TLS协议
2.配置基于TLS虚拟主机
3.将HTTP客户端重定向到HTTPS站点
```

```bash
练习P386
[student@workstation ~]$ lab web-https start

[student@workstation ~]$ ssh servera
[student@servera ~]$ sudo -i
[sudo] password for student:
[root@servera ~]# yum install -y httpd mod_ssl
[root@servera ~]# mkdir -p /srv/{www-a,servera}/www
[root@servera ~]# echo 'www-a' > /srv/www-a/www/index.html
[root@servera ~]# echo 'servera' > /srv/servera/www/index.html
[root@servera ~]# restorecon -Rv /srv
[root@servera ~]# cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/www-a.conf
[root@servera ~]# vim /etc/httpd/conf.d/www-a.conf  #如果以ssl.conf文件为模板，要删除virtaul意外的所有内容。ssl.conf源文件，不必做任何操作。
<VirtualHost *:443>
DocumentRoot "/srv/www-a/www"
ServerName www-a.lab.example.com
#SSLEngine on
#SSLProtocol all -SSLv2 -SSLv3
#SSLHonorCipherOrder on
#SSLCipherSuite PROFILE=SYSTEM
SSLCertificateFile /etc/pki/tls/certs/www-a.lab.example.com.crt
SSLCertificateKeyFile /etc/pki/tls/private/www-a.lab.example.com.key
SSLCertificateChainFile /etc/pki/tls/certs/cacert.crt
</VirtualHost>

<Directory "/srv/www-a/www">
    Require all granted
</Directory>


<VirtualHost *:80>
  ServerName www-a.lab.example.com
  Redirect "/" "https://www-a.lab.example.com"
</VirtualHost>

[root@servera ~]# cd /etc/pki/tls/certs/
[root@servera ~]# scp workstation:/home/student/www-a.lab.example.com.crt ./
[root@servera ~]# scp workstation:/home/student/cacert.
[root@servera ~]# scp workstation:/home/student/cacert.crt ./
[root@servera ~]# cd /etc/pki/tls/private/
[root@servera ~]# scp workstation:/home/student/www-a.lab.example.com.key ./
[root@servera ~]# systemctl restart httpd
[root@servera ~]# firewall-cmd --permanent --add-service=http --add-service=https
[root@servera ~]# firewall-cmd --reload
[root@servera ~]# firewall-cmd --list-all

##测试
【workstaton】
firefox file:///home/student/cacert.pem #浏览器默认不允许任何ca证书，手动允许，后再访问
https://www-a.lab.example.com
www-a

```

#### 第四节: 使用 Nginx 配置 Web 服务器目标:

```

```

```bash
练习：P394
[student@workstation ~]$ lab web-nginx start
[student@workstation ~]$ ssh servera
[student@servera ~]$ sudo -i
[sudo] password for student: student
[root@servera ~]# yum module list *nginx*
[root@servera ~]# yum module install nginx:1.16
[root@servera ~]# mkdir -p /srv/nginx/{www-a,servera}/www
[root@servera ~]# echo "This is the www-a page" > /srv/nginx/www-a/www/index.html
[root@servera ~]# echo 'This is the servera page' > /srv/nginx/servera/www/index.html
[root@servera ~]# semanage fcontext -a -t httpd_sys_content_t '/srv/nginx(/.*)?'
[root@servera ~]# restorecon -RFv /srv/nginx/
[root@servera ~]# scp workstation:/home/student/*.conf /etc/nginx/conf.d/
root@workstation's password: redhat
[root@servera ~]# ls /etc/nginx/conf.d/
www-a.lab.example.com.conf
[root@servera ~]# vim /etc/nginx/conf.d/www-a.lab.example.com.conf 
server {
    listen 80 ;
    server_name www-a.lab.example.com;
    return 301 https://$host$request_uri; #该指令一般用于对请求的客户端直接返回响应状态码.在该作用域内return后面的所有nginx配置都是无效的

}
server {
    listen 443 ssl;
    server_name www-a.lab.example.com;

    ssl_certificate /etc/pki/tls/certs/www-a.lab.example.com.crt;
    ssl_certificate_key /etc/pki/tls/private/www-a.lab.example.com.key;

    location / {
        root /srv/nginx/www-a/www;
        index index.html index.htm;
    }
}

[root@servera ~]# cp /etc/nginx/conf.d/www-a.lab.example.com.conf /etc/nginx/conf.d/servera.lab.example.com.conf
[root@servera ~]# sed -i 's/www-a/servera/g' /etc/nginx/conf.d/servera.lab.example.com.conf
[root@servera ~]# cd /etc/pki/tls/certs/
[root@servera certs]# scp workstation:/home/student/*.crt ./
root@workstation's password: redhat
[root@servera certs]# ls
cacert.crt  servera.lab.example.com.crt  www-a.lab.example.com.crt
[root@servera certs]# cd /etc/pki/tls/private/
[root@servera private]# scp workstation:/home/student/*.key ./
root@workstation's password:  
[root@servera private]# ls
servera.lab.example.com.key  www-a.lab.example.com.key
[root@servera private]# 
[root@servera private]# systemctl enable --now nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[root@servera private]# firewall-cmd --permanent --add-service=http
success
[root@servera private]# firewall-cmd --reload
success
[root@servera private]# logout
[student@workstation ~]$ lab web-nginx finish
```

#### 第五节:自动化执行 Web 服务器配置目标

```bash
练习 P403
#参考教材练习。
```



## 9 调整Web服务器流量

> - 使用Varnish缓存静态内容
> - 使用HAProxy终止HTTPS流量和配置负载均衡
> - 自动化调整Web服务

```

```



## 10 提前基于文件的网络存储

> - 导出NFS文件系统
> - 提供SMB文件共享
> - 自动化提供文件存储

|      |                          |              |    Windows     | Linux | TYPE  |
| :--: | :----------------------: | :----------: | :------------: | :---: | :---: |
| NAS  | Network Attached Storage | 网络附加存储 |   samba(SMB)   |  nfs  |  dir  |
| SAN  |   Storage Area Network   | 存储区域网络 | target / iSCSI |       | block |

|    SERVICE     |                                                              |                                                             |
| :------------: | :----------------------------------------------------------: | :---------------------------------------------------------: |
| NAS/ directory |                            samba                             |                             nfs                             |
|       OS       |                           windows                            |                          Like Unix                          |
|   Permission   |                             user                             |                ip, network, hostname, domain                |
|      conf      |                      /etc/samba/smb.cfg                      |                        /etc/exports                         |
|   sharename    |                           [custom]                           |                            /path                            |
|      Pkg       | samba / DAEMON,<br> samba-common / conf, <br>samba-client / smbclient |                          nfs-utils                          |
|     DAEMON     |                  smb/SERVICE, <br>nmb/NAME                   |           nfs-server / RHEL>=7, <br>nfs / RHEL<7            |
|    firewall    |                            samba                             | nfs -=> # mount,<br>[ port-mapper, mountd ] -=> $ showmount |
|   Client-cmd   |               smbclient - like ftp interactive               |                              -                              |
|   filesystem   |                      cifs (cifs-utils)                       |                             nfs                             |
|     autofs     |                             Yes                              |                             Yes                             |

|        | Windows |   Linux   | QUOTA |
| :----: | :-----: | :-------: | :---: |
| Local  |  ntfs   | ext4, xfs |   Y   |
| Remote |  cifs   |    nfs    |   N   |

NFS

```
1.安装
2.共享目录
3.配置文件
4.启动服务并开机自启
5.防火墙

serverd服务器  servera 客户端 rw   serverb 客户端 ro
```

SAMBA

```bash
$smbclient
smbclient(samba client)可让Linux系统存取Windows系统所分享的资源。
语法格式
smbclient [参数]
常用参数：
-L	显示服务器端所分享出来的所有资源
-U	指定用户名称
-s	指定smb.conf所在的目录
-O	设置用户端TCP连接槽的选项
-N	不用询问密码
# smbclient -L 198.168.0.1 -N 
# smbclient -L 198.168.0.1 -U username%password
# smbclient -L 198.168.0.1/tmp -U username%password

$smbpasswd
smbpasswd命令属于samba套件，用户添加及删除samba用户和为用户修改密码。
因为samba用户是基于Linux的系统用户的，所以在添加samba用户前需要先创建Linux系统用户，否则添加samba用户将失败。
语法格式: smbpasswd [参数]
常用参数：
-a	向smbpasswd文件中添加用户
-c<配置文件>	指定samba的配置文件
-x	从smbpasswd文件中删除用户
-d	在smbpasswd文件中禁用指定的用户
-e	在smbpasswd文件中激活指定的用户
-n	将指定用户的密码置空
#useradd -s /sbin/nologin tom
#smbpassword -a  tom
输入密码

$pdbedit
相关命令：smbpasswd
pdbedit是samba的用户管理命令
常用参数：
pdbedit -a username：新建Samba账户。
pdbedit -r username：修改Samba账户。
pdbedit -x username：删除Samba账户。
pdbedit -L：列出Samba用户列表，读取passdb.tdb数据库文件。
#pdbedit -L 

#从Samba 4开始，这两个命令之间没有区别。smbpasswd是较旧的。pdbedit在Samba 3开发周期中提出来替代smbpasswd。
```

```
serverd服务器端
1 安装软件
2.共享目录
实际共享目录/smbshare---》2775 ——--》  marketing用户组--selinux

3.smb账号
用户组：marketing--developer1
developer1，operator1，smbmount

4.配置文件
工作组MYCOMPANY
共享名字data



servera客户端
挂载
1. 挂载点 
2. vim /etc/samba/cred.txt    #man mount.cifs
username
passwored
 chmod 600  /etc/samba/cred.txt
3. /etc/fstab 
4. su - 
5. cifscreds add 服务器fqdn #测试读写权限
```



## 11 访问基于块的网络存储

> - 提供iSCSI存储
> - 访问iSCSI存储
> - 自动化配置iSCSI Initiator

|             |      Client       |     Server     |
| :---------: | :---------------: | :------------: |
| SAN / block |       iscsi       |     target     |
|     CMD     |     iscsiadm      | targetcli / ls |
|             |     iscsiadm      |     block      |
|             |       lsblk       | iscsi - block  |
|             | fstab / `_netdev` |  iscsi - port  |
|     acl     | /etc/iscsi/init*  |  iscsi - acl   |
|    True     |      iscsid       |     target     |
|    False    |       iscsi       |    targetd     |

```bash
# iscsiadm --mode session -P 3
```

```shell
练习： P544
$ lab  iscsi-target start

1 serverd服务器端target
2 准备物理块设备
3 配置target
	磁盘名称 serverd.disk1  /dev/vdb
	iqn ：iqn.2014-06.com.example:serverd
		lun :  serverd.disk1
		acl : iqn.2014-06.com.example:servera
		portals : 172.25.250.13 3260

```



## 附录

### A0. step

|      |                |      |
| :--: | :------------: | :--: |
|  1   |      word      |      |
|  2   | <kbd>Tab</kbd> |      |
|  3   |      man       |      |
|  4   |    echo \$?    | == 0 |

### A1. 红帽

|  ID   |                             URL                              |   说明   |
| :---: | :----------------------------------------------------------: | :------: |
| RH358 | [红帽服务管理与自动化](https://www.redhat.com/zh/services/training/rh358-red-hat-services-management-automation) | 课程代码 |
| EX358 | [红帽认证服务管理和自动化专家考试](https://www.redhat.com/zh/services/training/ex358-red-hat-certified-specialist-services-management-automation-exam) | 考试代码 |

### A2. 软件

|      |                              |          |
| :--: | :--------------------------: | -------- |
|  1   |            VMware            | 虚拟机   |
|  2   | [Typora](https://typora.io/) | Markdown |
|  3   |            Xmind             | 思维导图 |
|  4   |           Snipaste           | 截图     |
|      |                              |          |
|      |                              |          |

### A3. 培训环境

```bash
$ cat /etc/rht
RHT_COURSE=rh358
RHT_TITLE="Management and Automation of Linux Network Services (RH358)"
RHT_VMS="bastion workstation servera serverb serverc serverd "
RHT_VM0="classroom "
```

| 虚拟机 |    主机名    |    功能    | 必须 |  root  |       User        |
| :----: | :----------: | :--------: | :--: | :----: | :---------------: |
| VMware |  foundation  |    平台    |  1   | Asimov |   kiosk%redhat    |
|  KVM   |  classroom   | 功能服务器 |  1   | Asimov | instructor%Asimov |
|  KVM   |   bastion    |   router   |  1   | redhat |  student%student  |
|  KVM   | workstation  |    GUI     |  0   | redhat |  student%student  |
|  KVM   | server{a..d} |    CLI     |  0   | redhat |  student%student  |

**[kiosk@foundation]**

```bash
$ rht-vmctl start classroom
$ rht-vmctl start bastion
$ rht-vmctl start workstation
$ rht-vmctl start servera
```

```bash
$ ping -c 4 workstation
$ ssh root@workstation
```

```bash
$ ls /content/slides/
```

### A4. yaml

```bash
$ ansible-doc -l | grep keyword
$ ansible-doc module-name
/EX

$ ansible-playbook x.yml
```

> - `---`第一行
> - 使用`缩进`表示层级关系，`:`上一级以冒号结尾
> - 只允许`空格`，缩进不允许使用tab
> - 缩进的空格数不重要，只要相同层级的元素左对齐即可
> - `#`表示注释
> - `key`:空格`value`

```bash
# tail -n 1 /etc/bashrc
# vim
:set all
:help tabstop

# ls /etc/vimrc ~/.vimrc

$ cat > ~/.vimrc <<EOF
set number ts=2 sw=2 et
EOF
```

### A5. service

| STEP | CMD                                                          | COMMENT            |                 |
| :--: | ------------------------------------------------------------ | ------------------ | --------------- |
|  1   | nmcli \| nmtui                                               | 网络               |                 |
|  2   | hostnamectl                                                  | 主机名             |                 |
|  3   | yum search KEYWORD                                           | 查安装包名         | dns             |
|  4   | yum -y install PKG                                           | 安装软件           | bind            |
|  5   | rpm -qc PKG \| man -k nfs                                    | 查配置文件         | bind            |
|  6   | vim /etc/..cfg(sec_service)                                  | 编辑(安全1/4)      | /etc/named.conf |
|  7   | rpm -ql PKG \| grep service<br>systemctl list-unit-files \| grep KEYWORD | 查守护进程         | bind            |
|  8   | systemctl enable --now DAEMON<br>systemctl restart DAEMON    | 开机自启，立即启动 | named           |
|  9   | firewall-cmd --permanent ..., <br>--reload(sec_port)         | 防火墙(安全1/4)    |                 |
|  10  |                                                              | 文件系统(安全1/4)  |                 |
|  11  |                                                              | SELinux(安全1/4)   |                 |

### A6. OBJECTIVE: SCORE

> ```
>  	Manage Network Services: 87%
>  	Manage Firewall Services: 100%
>  	Manage SELinux: 100%
>  	Manage DNS: 0%
>  	Manage DHCP: 100%
>  	Manage printers: 33%
>  	Manage Email services: 100%
>  	Manage a MariaDB database server: 100%
>  	Manage HTTPD web access: 100%
>  	Manage iSCSI: 50%
>  	Manage NFS: 100%
>  	Manage SMB: 75%
>  	Use Ansible to Configure Standard Services: 80%
> ```

### A7. 学习技巧

> - word
>
> - <kbd>Tab</kbd> 补全,<kbd>Tab</kbd><kbd>Tab</kbd> 列出 
>
> - ```bash
>   # man command
>   ```
>
> -  ```bash
>   # echo $?
>   ```

### A8. VMware+software

```bash
# yum -y install \
open-vm-tools-desktop.x86_64 \
xorg-x11-drv-vmware.x86_64
```

### A9. ansible

**[student@workstation]**

```bash
$ yum search ansible
$ yum list ansible

$ rpm -qc ansible
/etc/ansible/ansible.cfg
/etc/ansible/hosts

$ head /etc/ansible/ansible.cfg
$ mkdir playbook
$ cp /etc/ansible/ansible.cfg playbook/ansible.cfg
$ cd playbook/
$ ansible --version

$ vim /home/student/playbook/ansible.cfg
...
inventory      = /home/student/playbook/inventory
$ cp /etc/ansible/hosts inventory
$ ansible-inventory --graph
```

> **module**
>
> - stat(when)
> - debug(echo)
> - setup(facts)
> - shell(\*,\|)
> - command(id, hostname)

### A10. vim

|  ID  |                                      |                           |
| :--: | ------------------------------------ | ------------------------- |
|  1   | <kbd>u</kbd>                         | Undo                      |
|  2   | <kbd>5</kbd><kbd>g</kbd><kbd>g</kbd> | Go                        |
|  3   | <kbd>Ctrl</kbd>-<kbd>V</kbd>         | Virtual block             |
|  4   | <kbd>j</kbd>\* n                     | :arrow_down:              |
|  5   | <kbd>I</kbd>                         | III12iii<u>3</u>aaa456AAA |
|  6   | <kbd>Esc</kbd>                       |                           |
|  7   | <kbd>o</kbd>                         | Open                      |
|  8   | <kbd>x</kbd>                         |                           |
|      |                                      |                           |

### A11. 培训环境 2 练习环境

> VMware
>
> - [CPU](https://ark.intel.com/) \* 8
> - MEM \* 8G

| STEP |                                                       |                               |
| :--: | :---------------------------------------------------: | :---------------------------: |
|  1   |                  VMware 第一次运行时                  |         选择`已移动`          |
|  2   |                     物理机 vmnet1                     |       172.25.254.`1`/24       |
|  3   |              X:\\> `ping 172.25.254.250`              | 物理机：确认和 foundation连网 |
|  4   | X:\\> `scp YOURPATH/ex358.rar kiosk@172.25.254.250:~` |       物理机：拷贝文件        |
|  5   |                 \$ `unzip ex358.zip`                  |            解压缩             |
|  6   |             \$ `bash ex358/exam-setup.sh`             |       开始布署，约6分钟       |
|  7   |                 # `systemctl shudown`                 |             关机              |
|  8   |                                                       |      做快照，名称`EX358`      |
|  9   |                                                       |             开机              |

```bash
$ rht-vmctl status classroom
classroom RUNNING
$ rht-vmctl status all
bastion DEFINED
workstation DEFINED
servera DEFINED
serverb DEFINED
serverc DEFINED
serverd DEFINED
$ rht-vmctl start bastion

-CMD
$ rht-vmctl start servera
$ rht-vmctl start serverb

-ANSIBLE
$ rht-vmctl start workstation
$ rht-vmctl start serverc
$ rht-vmctl start serverd
```

#### A12. PC+VMware

|   OS   |                                |                                            |
| :----: | ------------------------------ | ------------------------------------------ |
|  win7  | VMware-workstation-full-15.5.7 | 1、删除快照<br>2、改兼容性<br>3、改CPU+MEM |
| win>=8 | VMware-workstation-full-16.1.2 |                                            |

> CPU: AMD
>
> foundation 8.0 +RH358
> foundation 8.2
