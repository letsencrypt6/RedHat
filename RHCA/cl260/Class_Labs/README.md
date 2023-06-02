<img height='36' src='https://img.shields.io/badge/ceph-5.0-EF5C55?style=for-the-badge&logo=ceph&logoColor=F5F5F5'>

[TOC]

### 课堂环境介绍

![Classroom-Architecture](https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/classroom/Classroom-Architecture.svg)

- 系统和应用凭据

  |          计算机名称           |  特权用户   |     普通用户      |
  | :---------------------------: | :---------: | :---------------: |
  |          foundation           | root%Asimov |   kiosk%redhat    |
  |           classroom           | root%Asimov | instructor%redhat |
  | workstation, clientX, serverY | root%redhat |  student%student  |


- 实验练习配置和判分
  **[workstation]**

  ```bash
  $ lab start SCRIPT
  
  $ lab grade SCRIPT
  
  $ lab finish SCRIPT
  ```

  

- 控制您的系统

  ```bash
  启动 KVM 虚拟机
  $ rht-vmctl start classroom
  $ rht-vmctl start all
  
  确认 KVM 虚拟机状态
  $ rht-vmctl status classroom
  $ rht-vmctl status all
  
  查看 KVM 虚拟机 物理控制台
  $ rht-vmctl view workstation
  
  重置 KVM 虚拟机
  $ rht-vmctl reset servera
  ```

  

### 国际化

```bash
# localectl status
# echo $LANG

# localectl list-locales | grep CN
# localectl set-locale LANG=zh_CN.utf8
# LANG=zh_CN.utf8 date
```



### [1. 介绍红帽 Ceph 存储架构]()

#### 1.1 <strong style='color:#3B0083'>小测验: </strong>描述存储⽤户⻆⾊

|                     责任                     |                人物角色                |
| :------------------------------------------: | :------------------------------------: |
|          设计分布式云部署容量和配置          |  <font title="blue">基础架构师</font>  |
|               管理最终⽤⼾服务               |  <font title="blue">服务管理员</font>  |
|           在基础架构级别配置云服务           |   <font title="blue">云操作员</font>   |
|        安装、配置和维护 Ceph 存储集群        |        <font>存储管理员</font>         |
| 基于对现代云协议和配置的理解来设计云应用程序 |  <font title="blue">软件架构师</font>  |
| 实施设计为轻松部署和扩展的应用程序的解决方案 | <font title="blue">自动化工程师</font> |
|   使用 Ceph Dashboard GUI 执行存储管理任务   |        <font>存储操作员</font>         |

#### 1.2 <strong style='color: #1A97D5'>指导练习: </strong>描述红帽 Ceph 存储架构

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab start intro-arch
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell -- ceph orch ls

# cephadm shell
[ceph: root@clienta /]# ceph orch ps
[ceph: root@clienta /]# ceph health
[ceph: root@clienta /]# ceph status
[ceph: root@clienta /]# ceph mon dump
[ceph: root@clienta /]# ceph mgr stat
[ceph: root@clienta /]# ceph osd pool ls
[ceph: root@clienta /]# ceph pg stat
[ceph: root@clienta /]# ceph osd status
[ceph: root@clienta /]# ceph osd crush tree
[ceph: root@clienta /]# <Ctrl-D>

# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish intro-arch
```



#### 1.3 <strong style='color: #1A97D5'>指导练习: </strong>描述红帽 Ceph 存储管理接口

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start intro-interface
```

<img align='left' height='36' src='https://img.shields.io/badge/firefox-https://serverc.lab.example.com:8443/-FF7139?style=flat-square&logo=firefox'>

​		<kbd>Advanced...</kbd> / <kbd>Accept the Risk and Continue</kbd>

​				User name: ==admin==
​				Password: ==redhat== / <kbd>Log in</kbd>

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish intro-interface
```





### [2. 部署红帽 Ceph 存储集群]()

#### 2.1 <strong style='color: #1A97D5'>指导练习: </strong>部署红帽 Ceph 存储

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start deploy-deploy
```

<blockquote alt="warn"><p>此练习启动脚本会立即删除预构建的 Ceph 集群，并花费几分钟完成。等待命令完成，然后再继续</p></blockquote>

<span alt="modern">[root@serverc ~]#</span>

```bash
# yum -y install cephadm-ansible

# cd /usr/share/cephadm-ansible

# cat > hosts <<EOF
clienta.lab.example.com
serverc.lab.example.com
serverd.lab.example.com
servere.lab.example.com
EOF

# ansible-playbook -i hosts cephadm-preflight.yml -e ceph_origin=

# vim /root/ceph/initial-config-primary-cluster.yaml

# cephadm bootstrap \
--mon-ip=172.25.250.12 \
--apply-spec=/root/ceph/initial-config-primary-cluster.yaml \
--initial-dashboard-password=redhat \
--dashboard-password-noupdate \
--allow-fqdn-hostname \
--registry-url=registry.lab.example.com \
--registry-username=registry \
--registry-password=redhat
:<<MESSAGE
...输出省略...
Ceph Dashboard is now available at:
	     URL: https://serverc.lab.example.com:8443/
	    User: admin
	Password: redhat
...输出省略...
You can access the Ceph CLI with:
	sudo /usr/sbin/cephadm shell --fsid 28ca9696-c792-11ed-968f-52540000fa0c -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring

Please consider enabling telemetry to help improve Ceph:

	ceph telemetry on
<<MESSAGE

# cephadm shell
[ceph: root@serverc /]# ceph status
[ceph: root@serverc /]# ceph orch \
host label add clienta.lab.example.com _admin
[ceph: root@serverc /]# ceph orch \
host ls
[ceph: root@serverc /]# <Ctrl-D>

# scp \
/etc/ceph/ceph.{client.admin.keyring,conf} \
root@clienta:/etc/ceph

# <Ctrl-D>
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell -- ceph health

# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish deploy-deploy
```



#### 2.2 <strong style='color: #1A97D5'>指导练习: </strong>扩展红帽 Ceph 存储集群容量

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start deploy-expand
```

<span alt="modern">[root@clienta ~]#</span>

```bash
# cephadm shell
[ceph: root@clienta /]# ceph orch device ls
[ceph: root@clienta /]# <Ctrl-D>

# cephadm shell --mount /root/expand-osd/osd_spec.yml
[ceph: root@clienta /]# cp /mnt/osd_spec.yml /var/lib/ceph/osd/
[ceph: root@clienta /]# cat /var/lib/ceph/osd/osd_spec.yml
[ceph: root@clienta /]# ceph orch \
apply -i /var/lib/ceph/osd/osd_spec.yml
[ceph: root@clienta /]# ceph orch \
device ls --hostname=servere.lab.example.com

[ceph: root@clienta /]# ceph orch \
daemon add osd servere.lab.example.com:/dev/vde
[ceph: root@clienta /]# ceph orch \
daemon add osd servere.lab.example.com:/dev/vdf

[ceph: root@clienta /]# ceph status
[ceph: root@clienta /]# ceph osd tree
[ceph: root@clienta /]# ceph osd df

[ceph: root@clienta /]# <Ctrl-D>
[root@clienta ~]# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish deploy-expand
```





###  [3. 配置红帽 Ceph 存储集群]()

#### 3.1 <strong style='color: #1A97D5'>指导练习: </strong>管理集群配置设置

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start configure-settings
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
[ceph: root@clienta /]# ceph config dump
[ceph: root@clienta /]# ceph config show osd.1

[ceph: root@clienta /]# ceph config \
show osd.1 debug_ms
[ceph: root@clienta /]# ceph config \
get osd.1 debug_ms

[ceph: root@clienta /]# ceph config \
set osd.1 debug_ms 10

[ceph: root@clienta /]# ceph config \
show osd.1 debug_ms
[ceph: root@clienta /]# ceph config \
get osd.1 debug_ms

[ceph: root@clienta /]# ceph orch \
daemon restart osd.1

[ceph: root@clienta /]# ceph config \
show osd.1 debug_ms
10/10
[ceph: root@clienta /]# ceph config \
get osd.1 debug_ms

[ceph: root@clienta /]# ceph tell \
osd.1 config get debug_ms
[ceph: root@clienta /]# ceph tell \
osd.1 config set debug_ms 5
[ceph: root@clienta /]# ceph tell \
osd.1 config get debug_ms

[ceph: root@clienta /]# ceph orch \
daemon restart osd.1
[ceph: root@clienta /]# ceph tell \
osd.1 config get debug_ms

[ceph: root@clienta /]# <Ctrl-D>

[root@clienta ~]# <Ctrl-D>
```

<img align='left' height='36' src='https://img.shields.io/badge/firefox-https%3A%2F%2Fserverc%3A8443-FF7139?style=flat-square&logo=firefox'>

​		<kbd>Advanced...</kbd> / <kbd>Accept the Risk and Continue</kbd>

​				User name: ==admin==
​				Password: ==redhat== / <kbd>Log in</kbd>

<div alt="timeline">
    <div alt="timenode">
        <div alt="meta">Cluster <a href="#">configuration</a></div>
        <div alt="body">
          <b>advanced</b> <=- basic<br>
          mon_allow_pool_delete<br>
          <kbd>Edit</kbd>
        </div>
    </div>
    <div alt="timenode">
        <div alt="meta">Cluster <a href="#">configuration</a></div>
        <div alt="body">
          global <b>true</b><br>
          <kbd>Update</kbd>
        </div>
    </div>
</div>

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish configure-settings
```



#### 3.2 <strong style='color: #1A97D5'>指导练习: </strong>配置集群 Monitors

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start configure-monitor
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
[ceph: root@clienta /]# ceph status
[ceph: root@clienta /]# ceph mon dump
[ceph: root@clienta /]# ceph mon stat
[ceph: root@clienta /]# ceph config \
show mon.serverc.lab.example.com mon_host
[ceph: root@clienta /]# ceph auth ls

[ceph: root@clienta /]# ceph auth \
get client.admin -o /tmp/adminkey
[ceph: root@clienta /]# cat /tmp/adminkey
[ceph: root@clienta /]# <Ctrl-D>

# yum -y install sshpass
# sshpass -p redhat \
  ssh serverc \
    ls /var/lib/ceph/2ae6d05a-229a-11ec-925e-52540000fa0c/mon.serverc.lab.example.com/store.db
# sshpass -p redhat \
  ssh serverc \
    sudo du -sch /var/lib/ceph/2ae6d05a-229a-11ec-925e-52540000fa0c/mon.serverc.lab.example.com/store.db

# cephadm shell
[ceph: root@clienta /]# ceph config \
set mon mon_compact_on_start true
[ceph: root@clienta /]# ceph orch restart mon
[ceph: root@clienta /]# ceph health
[ceph: root@clienta /]# <Ctrl-D>

# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish configure-monitor
```



#### 3.3 <strong style='color: #1A97D5'>指导练习: </strong>配置集群⽹络

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start configure-network
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
[ceph: root@clienta /]# ceph health
[ceph: root@clienta /]# ceph config \
get osd public_network
[ceph: root@clienta /]# ceph config \
get mon public_network
[ceph: root@clienta /]# <Ctrl-D>

# cat > osd-cluster-network.conf <<EON
[osd]
cluster network = 172.25.249.0/24
EON

# cephadm shell \
--mount osd-cluster-network.conf
[ceph: root@clienta /]# cat /mnt/osd-cluster-network.conf

[ceph: root@clienta /]# ceph config \
assimilate-conf \
-i /mnt/osd-cluster-network.conf
[ceph: root@clienta /]# ceph config \
get osd cluster_network

[ceph: root@clienta /]# ceph config \
set mon public_network 172.25.250.0/24
[ceph: root@clienta /]# ceph config \
get mon public_network
[ceph: root@clienta /]# <Ctrl-D>

# [ceph: root@clienta /]# 
```

<span alt="modern">[root@serverc ~]# </span>

```bash
# firewall-cmd --get-default-zone
# firewall-cmd --list-all

# firewall-cmd --permanent \
	--add-service=ceph-mon
# firewall-cmd --reload

# firewall-cmd --permanent \
	--add-service=ceph
# firewall-cmd --reload
```

```bash
# nmcli con mod 'Wired connection 2' \
	802-3-ethernet.mtu 9000

# nmcli con up 'Wired connection 2'

# ip link show eth1

# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish configure-network
```





###  [4. 创建对象存储集群组件]()

#### 4.1 <strong style='color: #1A97D5'>指导练习: </strong>使用逻辑卷创建 BlueStore OSDs

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start component-osd
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
```

```bash
[ceph: root@clienta /]# ceph health

[ceph: root@clienta /]# ceph df

[ceph: root@clienta /]# ceph osd tree
```

```bash
[ceph: root@clienta /]# ceph device ls

[ceph: root@clienta /]# ceph orch device \
	ls | grep server | grep Yes
```

```bash
[ceph: root@clienta /]# ceph orch daemon \
	add osd serverc.lab.example.com:/dev/vde

[ceph: root@clienta /]# ceph orch daemon \
	add osd serverc.lab.example.com:/dev/vdf

[ceph: root@clienta /]# ceph orch ps \
	| egrep 'osd.9|osd.10'

[ceph: root@clienta /]# ceph df

[ceph: root@clienta /]# ceph osd tree
```

```bash
[ceph: root@clienta /]# ceph orch apply \
	osd --all-available-devices

[ceph: root@clienta /]# ceph orch ls \
	| grep osd.all-available-devices

[ceph: root@clienta /]# ceph osd tree
```

```bash
[ceph: root@clienta /]# ceph device ls \
	| grep servere.*vde

[ceph: root@clienta /]# ceph orch daemon \
	stop osd.11
[ceph: root@clienta /]# ceph orch daemon \
	rm osd.11 --force

[ceph: root@clienta /]# ceph osd rm osd.11

[ceph: root@clienta /]# ceph orch osd \
	rm status
[ceph: root@clienta /]# ceph orch device \
	zap servere.lab.example.com /dev/vde --force

[ceph: root@clienta /]# ceph orch device ls 、
	| grep servere.*vde | grep No
[ceph: root@clienta /]# ceph device ls \
	| grep servere.*vde
[ceph: root@clienta /]# ceph orch ps \
	| grep osd.11
```

```bash
[ceph: root@clienta /]# ceph orch ls \
	--service-type osd --format yaml \
	| head -n 10 > all-available-devices.yaml
[ceph: root@clienta /]# echo \
	unmanaged: true \
	>> all-available-devices.yaml

[ceph: root@clienta /]# ceph orch apply \
	-i all-available-devices.yaml

[ceph: root@clienta /]# ceph orch ls \
	| grep available | grep unmanaged
```

```bash
[ceph: root@clienta /]# ceph device ls \
	| grep serverd.*vdf

[ceph: root@clienta /]# ceph orch daemon \
	stop osd.15
[ceph: root@clienta /]# ceph orch daemon \
	rm osd.15 --force

[ceph: root@clienta /]# ceph orch osd \
	rm status
[ceph: root@clienta /]# ceph osd rm osd.15

[ceph: root@clienta /]# ceph orch device \
	zap serverd.lab.example.com /dev/vdf --force

[ceph: root@clienta /]# sleep 60
[ceph: root@clienta /]# ceph orch device \
	ls | grep serverd.*vdf | grep Yes
```

```bash
[ceph: root@clienta /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish component-osd
```



#### 4.2 <strong style='color: #1A97D5'>指导练习: </strong>创建和配置池

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start component-pool
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
```

```bash
[ceph: root@clienta /]# ceph osd pool \
	create replpool1 64 64
```

```bash
[ceph: root@clienta /]# ceph osd pool \
	get replpool1 pg_autoscale_mode

[ceph: root@clienta /]# ceph config get \
	mon osd_pool_default_pg_autoscale_mode
```

```bash
[ceph: root@clienta /]# ceph osd lspools

[ceph: root@clienta /]# ceph osd pool \
	autoscale-status
```

```bash
[ceph: root@clienta /]# ceph osd pool \
	set replpool1 size 4
[ceph: root@clienta /]# ceph osd pool \
	set replpool1 min_size 2

[ceph: root@clienta /]# ceph osd pool \
	application enable replpool1 rbd

[ceph: root@clienta /]# ceph osd pool \
	ls detail | grep replpool1
[ceph: root@clienta /]# ceph osd pool \
	get replpool1 size
```

```bash
[ceph: root@clienta /]# ceph osd pool \
	rename replpool1 newpool

[ceph: root@clienta /]# ceph osd pool \
	delete newpool newpool \
	--yes-i-really-really-mean-it \
	|| echo ERROR

[ceph: root@clienta /]# ceph tell mon.* \
	config set mon_allow_pool_delete true

[ceph: root@clienta /]# ceph osd pool \
	delete newpool newpool \
	--yes-i-really-really-mean-it
```

```bash
[ceph: root@clienta /]# ceph osd \
	erasure-code-profile ls

[ceph: root@clienta /]# ceph osd \
	erasure-code-profile get default

[ceph: root@clienta /]# ceph osd \
	erasure-code-profile \
	set ecprofile-k4-m2 k=4 m=2
```

```bash
[ceph: root@clienta /]# ceph osd pool \
	create ecpool1 64 64 \
	erasure ecprofile-k4-m2
[ceph: root@clienta /]# ceph osd pool \
	application enable ecpool1 rgw

[ceph: root@clienta /]# ceph osd pool \
	ls detail | grep ecpool1

[ceph: root@clienta /]# ceph osd pool \
	set ecpool1 allow_ec_overwrites true

[ceph: root@clienta /]# ceph osd pool \
	delete ecpool1 ecpool1 \
	--yes-i-really-really-mean-it
```

```bash
[ceph: root@clienta /]# <Ctrl-D>
# <Ctrl-D>
```

<img align='left' height='36' src='https://img.shields.io/badge/firefox-https%3A%2F%2Fserverc%3A8443-FF7139?style=flat-square&logo=firefox'>

​		<kbd>Advanced...</kbd> / <kbd>Accept the Risk and Continue</kbd>

​				User name: ==admin==
​				Password: ==redhat== / <kbd>Log in</kbd>

<div alt="timeline">
    <div alt="timenode">
        <div alt="meta">Pools</div>
        <div alt="body">
          <kbd>Create</kbd>
        </div>
    </div>
    <div alt="timenode">
        <div alt="meta">Pools</div>
        <div alt="body">
          Name * <b>replpool1</b><br>
          Pool type * <b>replicated</b><br>
          Replicated size * <b>3</b><br>
          <kbd>Create Pool</kbd>
        </div>
    </div>
    <div alt="timenode">
          <div alt="meta">Pools</div>
          <div alt="body">
            <kbd>Create</kbd>
          </div>
      </div>
      <div alt="timenode">
          <div alt="meta">Pools</div>
          <div alt="body">
            Name * <b>ecpool1</b><br>
            Pool type * <b>erasure</b><br>
            PG Autoscale <b>off</b><br>
            Placement groups * <b>3</b><br>
            Erasure code profile<b>ecprofile-k4-m2</b><br>
            <kbd>Create Pool</kbd>
          </div>
      </div>
</div>

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish component-pool
```



#### 4.3 <strong style='color: #1A97D5'>指导练习: </strong>管理 Ceph 认证

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start component-auth
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell \
	-- ceph auth get-or-create client.docedit \
	mon 'allow r' \
	osd 'allow rw pool=replpool1 namespace=docs' | tee /etc/ceph/ceph.client.docedit.keyring

# cephadm shell \
	-- ceph auth get-or-create client.docget \
	mon 'allow r' \
	osd 'allow r pool=replpool1 namespace=docs' | tee /etc/ceph/ceph.client.docget.keyring

# cephadm shell \
	-- ceph auth ls | egrep -A3 'docedit|docget'
```

```bash
# rsync -v \
	/etc/ceph/ceph.client.doc*.keyring \
	serverd:/etc/ceph/
```

<span alt="modern">[root@serverd ~]# </span>

```bash
# cephadm shell --mount /etc/ceph:/etc/ceph

[ceph: root@serverd /]# rados --id docedit \
	-p replpool1 -N docs \
	put adoc /etc/hosts

[ceph: root@serverd /]# rados --id docget \
	-p replpool1 -N docs \
	get adoc /tmp/test

[ceph: root@serverd /]# diff \
	/etc/hosts /tmp/test
```

```bash
[ceph: root@serverd /]# rados --id docget \
	-p replpool1 -N docs \
	put mywritetest /etc/hosts \
	|| echo ERROR
```

```bash
[ceph: root@serverd /]# ceph auth caps \
	client.docget \
	mon 'allow r' \
	osd 'allow rw pool=replpool1 namespace=docs, allow rw pool=docarchive'

[ceph: root@serverd /]# rados --id docget \
	-p replpool1 -N docs \
	put mywritetest /etc/hosts

[ceph: root@serverd /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# rm /etc/ceph/ceph.client.doc*.keyring

# ssh serverd \
	rm /etc/ceph/ceph.client.doc*.keyring

# cephadm shell \
	-- ceph auth del client.docedit
# cephadm shell \
	-- ceph auth del client.docget
```

```bash
[ceph: root@clienta /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish component-auth
```





###  [5. 创建和管理自定义 CRUSH map]()

#### 5.1 <strong style='color: #1A97D5'>指导练习: </strong>管理和自定义 CRUSH map

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start map-crush
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
[ceph: root@clienta /]# ceph health
```

```bash
[ceph: root@clienta /]# ceph osd crush class ls

[ceph: root@clienta /]# ceph osd crush tree

[ceph: root@clienta /]# ceph osd crush rule \
	create-replicated onssd default host ssd

[ceph: root@clienta /]# ceph osd crush rule ls

[ceph: root@clienta /]# ceph osd pool create \
	myfast 32 32 onssd

[ceph: root@clienta /]# ceph osd lspools

[ceph: root@clienta /]# ceph pg dump pgs_brief
```

```bash
[ceph: root@clienta /]# ceph osd crush \
	add-bucket default-cl260 root

[ceph: root@clienta /]# ceph osd crush \
	add-bucket rack1 rack
[ceph: root@clienta /]# ceph osd crush \
	add-bucket hostc host

[ceph: root@clienta /]# ceph osd crush \
	add-bucket rack2 rack
[ceph: root@clienta /]# ceph osd crush \
	add-bucket hostd host

[ceph: root@clienta /]# ceph osd crush \
	add-bucket rack3 rack
[ceph: root@clienta /]# ceph osd crush \
	add-bucket hoste host

[ceph: root@clienta /]# ceph osd crush move \
	rack1 root=default-cl260
[ceph: root@clienta /]# ceph osd crush move \
	hostc rack=rack1
[ceph: root@clienta /]# ceph osd crush move \
	rack2 root=default-cl260
[ceph: root@clienta /]# ceph osd crush move \
	hostd rack=rack2
[ceph: root@clienta /]# ceph osd crush move \
	rack3 root=default-cl260
[ceph: root@clienta /]# ceph osd crush move \
	hoste rack=rack3

[ceph: root@clienta /]# ceph osd crush tree

[ceph: root@clienta /]# ceph osd crush set \
	osd.1 1.0 \
	root=default-cl260 rack=rack1 host=hostc
[ceph: root@clienta /]# ceph osd crush set \
	osd.5 1.0 \
	root=default-cl260 rack=rack1 host=hostc
[ceph: root@clienta /]# ceph osd crush set \
	osd.2 1.0 \
	root=default-cl260 rack=rack1 host=hostc

[ceph: root@clienta /]# ceph osd crush set \
	osd.0 1.0 \
	root=default-cl260 rack=rack2 host=hostd
[ceph: root@clienta /]# ceph osd crush set \
	osd.3 1.0 \
	root=default-cl260 rack=rack2 host=hostd
[ceph: root@clienta /]# ceph osd crush set \
	osd.4 1.0 \
	root=default-cl260 rack=rack2 host=hostd

[ceph: root@clienta /]# ceph osd crush set \
	osd.6 1.0 \
	root=default-cl260 rack=rack3 host=hoste
[ceph: root@clienta /]# ceph osd crush set \
	osd.7 1.0 \
	root=default-cl260 rack=rack3 host=hoste
[ceph: root@clienta /]# ceph osd crush set \
	osd.8 1.0 \
	root=default-cl260 rack=rack3 host=hoste

[ceph: root@clienta /]# ceph osd crush tree
```

```bash
[ceph: root@clienta /]# ceph osd getcrushmap \
	-o ~/cm-org.bin

[ceph: root@clienta /]# crushtool \
	-d ~/cm-org.bin -o ~/cm-org.txt
[ceph: root@clienta /]# echo $?

[ceph: root@clienta /]# cp \
	~/cm-org.txt ~/cm-new.txt

[ceph: root@clienta /]# cat > newline <<EOR
rule ssd-first {
	id 5
	type replicated
	min_size 1
	max_size 10
	step take rack1
	step chooseleaf firstn 1 type host
	step emit
	step take default-cl260 class hdd
	step chooseleaf firstn -1 type rack
	step emit
}
EOR
[ceph: root@clienta /]# sed -i "/end/i$(cat newline)" ~/cm-new.txt

[ceph: root@clienta /]# crushtool -c ~/cm-new.txt -o ~/cm-new.bin 

[ceph: root@clienta /]# crushtool \
	-i ~/cm-new.bin --test \
	--show-mappings --rule=5 --num-rep 3

[ceph: root@clienta /]# ceph osd setcrushmap \
	-i ~/cm-new.bin

[ceph: root@clienta /]# ceph osd crush rule ls

[ceph: root@clienta /]# ceph osd pool create \
	testcrush 32 32 ssd-first

[ceph: root@clienta /]# ceph osd lspools \
	| grep testcrush

[ceph: root@clienta /]# ceph pg dump \
	pgs_brief | grep ^12
```

```bash
[ceph: root@clienta /]# ceph osd \
	pg-upmap-items 12.3 3 0

[ceph: root@clienta /]# ceph pg map 12.3
```

```bash
[ceph: root@clienta /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish map-crush
```



#### 5.2 <strong style='color: #1A97D5'>指导练习: </strong>管理 OSD Map

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start map-osd
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
[ceph: root@clienta /]# ceph health
```

```bash
[ceph: root@clienta /]# ceph osd dump \
	| grep ratio
```

```bash
[ceph: root@clienta /]# ceph osd \
	set-full-ratio 0.97
[ceph: root@clienta /]# ceph osd \
	set-nearfull-ratio 0.9
[ceph: root@clienta /]# ceph osd dump \
	| grep ratio
```

```bash
[ceph: root@clienta /]# ceph osd \
	getmap -o map.bin

[ceph: root@clienta /]# osdmaptool \
	--print map.bin
```

```bash
[ceph: root@clienta /]# osdmaptool \
	--export-crush crush.bin map.bin

[ceph: root@clienta /]# crushtool \
	-d crush.bin -o crush.txt

[ceph: root@clienta /]# crushtool \
	-c crush.txt -o crushnew.bin

[ceph: root@clienta /]# cp map.bin mapnew.bin
[ceph: root@clienta /]# osdmaptool \
	--import-crush crushnew.bin mapnew.bin
```

```bash
[ceph: root@clienta /]# osdmaptool \
	--test-map-pgs-dump mapnew.bin
```

```bash
[ceph: root@clienta /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish map-osd
```





### [6. 使用 RADOS 块设备提供块存储]()

#### 6.1 <strong style='color: #1A97D5'>指导练习: </strong>管理 RADOS 块设备

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start block-devices
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell --mount /etc/ceph:/etc/ceph

[ceph: root@clienta /]# ceph health
```

```bash
[ceph: root@clienta /]# ceph osd pool create \
	test_pool 32 32

[ceph: root@clienta /]# rbd pool init test_pool

[ceph: root@clienta /]# ceph df \
	| grep test_pool
```

```bash
[ceph: root@clienta /]# ceph auth \
	get-or-create client.test_pool.clientb \
	mon 'profile rbd' \
	osd 'profile rbd' \
	-o /etc/ceph/ceph.client.test_pool.clientb.keyring

[ceph: root@clienta /]# cat /etc/ceph/ceph.client.test_pool.clientb.keyring

[ceph: root@clienta /]# ceph auth get client.test_pool.clientb

[ceph: root@clienta /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[root@clientb ~]# </span>

```bash
# yum -y install ceph-common
```

```bash
# scp root@clienta:/etc/ceph/ceph.c{lient.t*,onf} /etc/ceph

# export CEPH_ARGS='--id=test_pool.clientb'
# rbd ls test_pool
```

```bash
# rbd create test_pool/test --size=128M
# rbd ls test_pool

# rbd info test_pool/test

# rbd map test_pool/test

# rbd showmapped
```

```bash
# mkfs.xfs /dev/rbd0

# mkdir /mnt/rbd

# mount /dev/rbd0 /mnt/rbd

# chown admin:admin /mnt/rbd

# df  /mnt/rbd

# dd if=/dev/zero of=/mnt/rbd/test1 bs=10M count=1
# ls /mnt/rbd

# df /mnt/rbd

# ceph df | grep test_pool

# umount /mnt/rbd
# rbd unmap /dev/rbd0
# rbd showmapped
```

```bash
# cat >> /etc/ceph/rbdmap <<EOM
test_pool/test id=test_pool.clientb,keyring=/etc/ceph/ceph.client.test_pool.clientb.keyring
EOM

# cat >> /etc/fstab <<EOF
/dev/rbd/test_pool/test /mnt/rbd xfs noauto 0 0
EOF

# rbdmap map
# rbd showmapped
# rbdmap unmap
# rbd showmapped

# systemctl enable rbdmap
# reboot

# df /mnt/rbd
```

```bash
# rbdmap unmap
# df | grep rbd
# rbd showmapped

# sed -i '/rbd/d' /etc/fstab

# sed -i '/test/d' /etc/ceph/rbdmap

# rbd rm test_pool/test --id test_pool.clientb

# rados -p test_pool ls --id test_pool.clientb

# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish block-devices
```



#### 6.2 <strong style='color: #1A97D5'>指导练习: </strong>管理 RADOS 块设备快照

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start block-snapshot
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell -- ceph health
```

```bash
# rbd map --pool rbd image1

# mkfs.xfs /dev/rbd0

# blockdev --getro /dev/rbd0
```

```bash
# cephadm shell

[ceph: root@clienta /]# rbd snap create \
	rbd/image1@firstsnap

[ceph: root@clienta /]# rbd disk-usage --pool rbd image1

[ceph: root@clienta /]# <Ctrl-D>
```

<span alt="modern">[root@clientb ~]# </span>

```bash
# export CEPH_ARGS='--id=rbd.clientb'

# rbd map --pool rbd image1@firstsnap
# rbd showmapped

# blockdev --getro /dev/rbd0
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# mount /dev/rbd0 /mnt/image
# mount | grep rbd

# cp /etc/ceph/ceph.conf /mnt/image/file0
# ls /mnt/image

# df /mnt/image
```

<span alt="modern">[root@clientb ~]# </span>

```bash
# mount /dev/rbd0 /mnt/snapshot
# df /mnt/snapshot/
# ls -l /mnt/snapshot/

# umount /mnt/snapshot
# rbd unmap --pool rbd image1@firstsnap
# rbd showmapped
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
[ceph: root@clienta /]# rbd snap protect \
	rbd/image1@firstsnap

[ceph: root@clienta /]# rbd clone \
	rbd/image1@firstsnap rbd/clone1

[ceph: root@clienta /]# rbd children rbd/image1@firstsnap
[ceph: root@clienta /]# <Ctrl-D>
```

<span alt="modern">[root@clientb ~]# </span>

```bash
# rbd map --pool rbd clone1

# mount /dev/rbd0 /mnt/clone
# ls -l /mnt/clone

# dd if=/dev/zero of=/mnt/clone/file1 bs=1M count=10
# ls -l /mnt/clone/
```

```bash
# umount /mnt/clone
# rbd unmap --pool rbd clone1
# rbd showmapped
# unset CEPH_ARGS
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# umount /mnt/image
# rbd unmap --pool rbd image1
# rbd showmapped
```

```bash
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish block-snapshot
```



#### 6.3 <strong style='color: #1A97D5'>指导练习: </strong>导入和导出 RBD Images

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start block-import
```

<span alt="modern">[root@clienta|serverf ~]# </span>

```bash
# cephadm shell
[ceph: root@\h /]# ceph health

[ceph: root@\h /]# ceph osd pool create \
	rbd 32
[ceph: root@\h /]# ceph osd pool \
	application enable rbd rbd
[ceph: root@x\h /]# rbd pool init -p rbd
```

<span alt="modern">[root@clienta ~]# </span>

```bash
[ceph: root@clienta /]# rbd create test \
	--size 128 --pool rbd
[ceph: root@clienta /]# <Ctrl-D>
# rbd map --pool rbd test
# mkfs.xfs /dev/rbd0

# mount /dev/rbd0 /mnt/rbd/
# mount | grep rbd
# cp /etc/ceph/ceph.conf /mnt/rbd
# ls /mnt/rbd

# umount /mnt/rbd
```

```bash
# cephadm shell --mount /home/admin/rbd-export/

[ceph: root@clienta /]# rbd export rbd/test \
	/mnt/export.dat
[ceph: root@clienta /]# <Ctrl-D>

# rsync -avP \
	/home/admin/rbd-export/export.dat \
	serverf:/home/admin/rbd-import/
```

<span alt="modern">[root@serverf ~]# </span>

```bash
[ceph: root@serverf /]# <Ctrl-D>
# cephadm shell --mount /home/admin/rbd-import/

[ceph: root@serverf /]# rbd --pool rbd ls
[ceph: root@serverf /]# rbd import \
	/mnt/export.dat rbd/test

[ceph: root@serverf /]# rbd du --pool rbd test
[ceph: root@serverf /]# <Ctrl-D>

# rbd map --pool rbd test
# mount /dev/rbd0 /mnt/rbd
# mount | grep rbd
# df -h /mnt/rbd
# ls -l /mnt/rbd
# cat /mnt/rbd/file0

# umount /mnt/rbd
# rbd unmap /dev/rbd0
```

<span alt="modern">[root@clienta|serverf ~]# </span>

```bash
# cephadm shell
[ceph: root@\h /]# rbd snap create \
	rbd/test@firstsnap
[ceph: root@\h /]# rbd du --pool rbd test
[ceph: root@\h /]# <Ctrl-D>
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# mount /dev/rbd0 /mnt/rbd
# dd if=/dev/zero of=/mnt/rbd/file1 \
	bs=1M count=5
# ls -l /mnt/rbd/
# umount /mnt/rbd

# cephadm shell
[ceph: root@clienta /]# rbd du --pool rbd test
[ceph: root@clienta /]# rbd snap create \
	rbd/test@secondsnap
[ceph: root@clienta /]# rbd du --pool rbd test
[ceph: root@clienta /]# <Ctrl-D>
# cephadm shell --mount /home/admin/rbd-export/

[ceph: root@clienta /]# rbd export-diff --from-snap firstsnap rbd/test@secondsnap /mnt/export-diff.dat
[ceph: root@clienta /]# <Ctrl-D>
# rsync -avP \
	/home/admin/rbd-export/export-diff.dat \
	serverf:/home/admin/rbd-import
```

<span alt="modern">[root@serverf ~]# </span>

```bash
# cephadm shell --mount /home/admin/rbd-import/
[ceph: root@serverf /]# rbd du --pool rbd test
[ceph: root@serverf /]# rbd import-diff \
	/mnt/export-diff.dat rbd/test
[ceph: root@serverf /]# rbd du --pool rbd test
[ceph: root@serverf /]# <Ctrl-D>

# rbd map --pool rbd test
# mount /dev/rbd0 /mnt/rbd
# df /mnt/rbd
# ls -l /mnt/rbd
# umount /mnt/rbd
```

<span alt="modern">[root@clienta|serverf ~]# </span>

```bash
# rbd unmap /dev/rbd0
[root@\h ~]# cephadm shell
[ceph: root@\h /]# rbd --pool rbd \
	snap purge test
[ceph: root@\h /]# rbd rm test --pool rbd
[ceph: root@\h /]# <Ctrl-D>

# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish block-import
```





### [7. 扩展块存储操作]()

#### 7.1 <strong style='color: #1A97D5'>指导练习: </strong>配置 RBD Mirrors

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start mirror-mirrors
```

<span alt="modern">[root@clienta|serverf ~]# </span>

```bash
# cephadm shell
[ceph: root@\h /]# ceph health

[ceph: root@\h /]# ceph osd pool create \
	rbd 32 32
[ceph: root@\h /]# ceph osd pool application \
	enable rbd rbd
[ceph: root@clienta /]# rbd pool init -p rbd
```

<span alt="modern">[root@clienta ~]# </span>

```bash
[ceph: root@clienta /]# rbd create image1 \
	--size 1024 \
	--pool rbd \
	--image-feature=exclusive-lock,journaling

[ceph: root@clienta /]# rbd -p rbd ls
[ceph: root@clienta /]# rbd --image image1 info
[ceph: root@clienta /]# rbd mirror pool \
	enable rbd pool
[ceph: root@clienta /]# rbd --image image1 info
[ceph: root@clienta /]# <Ctrl-D>
```

```bash
# mkdir /root/mirror
# cephadm shell --mount /root/mirror

[ceph: root@clienta /]# rbd mirror pool peer \
	bootstrap create \
	--site-name prod rbd \
	> /mnt/mirror/bootstrap_token_prod
[ceph: root@clienta /]# <Ctrl-D>

# rsync -avP \
	/root/mirror/bootstrap_token_prod \
	serverf:/root/bootstrap_token_prod
```

<span alt="modern">[root@serverf ~]# </span>

```bash
[ceph: root@serverf /]# <Ctrl-D>

# cephadm shell \
	--mount /root/bootstrap_token_prod

[ceph: root@serverf /]# ceph orch apply \
rbd-mirror --placement=serverf.lab.example.com

[ceph: root@serverf /]# ceph orch ls \
	| grep rbd

[ceph: root@serverf /]# rbd mirror pool peer \
	bootstrap import \
	--site-name bup --direction rx-only \
	rbd /mnt/bootstrap_token_prod \
	&& echo "Ignore the known error"

[ceph: root@serverf /]# rbd -p rbd ls
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
[ceph: root@clienta /]# rbd mirror pool info rbd
[ceph: root@clienta /]# rbd mirror pool status
```

<span alt="modern">[root@serverf ~]# </span>

```bash
[ceph: root@serverf /]# rbd mirror pool info rbd
[ceph: root@serverf /]# rbd mirror pool status
```

<span alt="modern">[root@clienta ~]# </span>

```bash
[ceph: root@clienta /]# rbd rm image1 -p rbd
```

<span alt="modern">[root@clienta|serverf ~]# </span>

```bash
[ceph: root@\h /]# rbd -p rbd ls
[ceph: root@\h /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish mirror-mirrors
```



#### 7.2 <strong style='color:#3B0083'>小测验: </strong>提供 iSCSI 块存储

1. **以下哪个描述最能说明 iSCSI？** 
   a. iSCSI 目标通过光纤通道向客户端（发起者）提供POSIX 文件系统 
   **b.** iSCSI 允许发起者通过 TCP/IP 网络向存储设备（目标）发送 SCSI 命令 
   c. iSCSI 协议仅被 Linux 使用 
   d. 需要一个专用的专有硬件阵列，其中包含 SCSI 驱动器，以提供 iSCSI 存储设备 
2. **部署 Ceph iSCSI 网关的要求有哪两个？(选择两个)** 
   **a.** Red Hat Enterprise Linux 8.3 或更高版本 
   b. 至少两个节点用于部署 Ceph iSCSI 网关 
   **c.** 每个 RBD 映像暴露为目标的 90 MiB RAM 
   d. 专用网络连接发起者和 iSCSI 网关 
   e. iSCSI 网关和 Red Hat Ceph 存储集群节点之间的 10 GbE 网络 
3. **以下哪两种方法用于将 RBD 映像公开为 iSCSI 目标？(选择两个)** 
   a. 使用来自 targetcli 包的 targetcli 命令 
   b. 使用 RHEL Web 控制台中的存储页面 
   **c.** 在 Ceph 仪表板中使用块➔ iSCSI 页面 
   d. 使用 mpathconf 包中的 mpathconf 命令 
   **e.** 使用 ceph-iscsi 包中的 gwcli 命令 
4. **连接到由 Ceph iSCSI 网关提供的目标的 iSCSI initiator 系统必须存在哪个软件包？** 
   a. ceph-iscsi 
   **b.** iscsi-initiator-utils 
   c. ceph-common 
   d. storaged-iscsi

#### 7.3 <strong style='color: #1A97D5'>指导练习: </strong>ceph-iscsi

> https://access.redhat.com/documentation/zh-cn/red_hat_ceph_storage/5/html/block_device_guide/installing-the-iscsi-gateway

<span alt="modern">[root@serverc ~]$</span>

```bash
for i in server{c,d}; do
	ssh root@$i \
		"firewall-cmd --permanent --add-port=5000/tcp \
		&& firewall-cmd --permanent --add-service=iscsi-target \
		&& firewall-cmd --reload"
done

ceph config set osd osd_heartbeat_interval 5
ceph config set osd osd_heartbeat_grace 20
ceph config set osd osd_client_watch_timeout 15

```

```bash
# 10.3.2. 使用命令行界面安装 Ceph iSCSI 网关
## 4. 使用以下命令创建池：
POOL_NAME=pool1
ceph osd pool create $POOL_NAME 100
ceph osd pool application enable $POOL_NAME rbd
rbd pool init -p $POOL_NAME

rbd create --size 512 $POOL_NAME/image_1
rbd -p $POOL_NAME ls

## 5. 在 Ceph iSCSI 网关节点上创建配置文件
HOST1=serverc.lab.example.com
HOST2=serverd.lab.example.com
HOST1_IP=$(awk '/'$HOST1'/ {print $1}' /etc/hosts | grep -v ^127)
HOST2_IP=$(awk '/'$HOST2'/ {print $1}' /etc/hosts | grep -v ^127)

cat > /etc/ceph/iscsi-gateway.yaml <<EOF
service_type: iscsi
service_id: iscsi
placement:
  hosts:
    - $HOST1
    - $HOST2
spec:
  pool: $POOL_NAME
  trusted_ip_list: "$HOST1_IP,$HOST2_IP"
  api_port: 5000
  api_secure: false
  api_user: admin
  api_password: redhat
EOF

## 6. 使用以下命令应用规格
# ceph orch rm iscsi.iscsi
ceph orch apply -i /etc/ceph/iscsi-gateway.yaml

CMD="ceph dashboard iscsi-gateway-list"
until $CMD | grep redhat; do
	sleep 1
done

```

```bash
# 10.4.2. 使用命令行界面配置 iSCSI 目标
## 1. 检索主机上运行的 iSCSI 容器的信息
POD_NAME=$(podman ps --format "{{.Names}}" | grep iscsi | grep -v tcmu)
podman exec -it $POD_NAME bash

```

```bash
POOL_NAME=pool1
HOST1=serverc.lab.example.com
HOST2=serverd.lab.example.com
HOST1_IP=$(awk '/'$HOST1'/ {print $1}' /etc/hosts | grep -v ^127)
HOST2_IP=$(awk '/'$HOST2'/ {print $1}' /etc/hosts | grep -v ^127)

## 2. 启动 iSCSI 网关命令行界面
gwcli ls

## 4. 使用 IPv4 或 IPv6 地址创建 iSCSI 网关
IQN1=iqn.2023-04.com.example:c1
gwcli /iscsi-targets create $IQN1
gwcli /iscsi-targets/$IQN1/gateways create $HOST1 $HOST1_IP
gwcli /iscsi-targets/$IQN1/gateways create $HOST2 $HOST2_IP

## 5. 添加 Ceph 块设备
# 使用rbd命令添加 (不要用 gwcli 这个命令)
# gwcli /disks create pool1 image=disk_1 size=500m

## 6. 创建客户端
## f0$ cut -d= -f2 /etc/iscsi/initiatorname.iscsi
IQN2=iqn.1994-05.com.redhat:3335c84e19
gwcli /iscsi-targets/$IQN1/hosts create $IQN2
gwcli /iscsi-targets/$IQN1/hosts/$IQN2 auth username=iscsiuser1 password=temp12345678

## 7. 向客户端添加磁盘
gwcli /disks attach $POOL_NAME/image_1
gwcli /iscsi-targets/$IQN1/disks add $POOL_NAME/image_1
gwcli /iscsi-targets/$IQN1/hosts/$IQN2/disk add $POOL_NAME/image_1

## 验证 Ceph ISCSI 网关是否正常工作
gwcli /iscsi-targets/$IQN1/gateways ls
```

```bash
iscsiadm --mode node --targetname iqn.2001-07.com.ceph:t2 --portal serverc --logout
```



### [8. 使用 RADOS 网关提供对象存储]()

#### 8.1 <strong style='color: #1A97D5'>指导练习: </strong>部署对象存储网关

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start object-radosgw
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
[ceph: root@clienta /]# ceph health
```

```bash
[ceph: root@clienta /]# ceph orch ls
[ceph: root@clienta /]# ceph orch ls \
	--service-type rgw
```

```bash
[ceph: root@clienta /]# cat > rgw_service.yaml <<EOR
service_type: rgw
service_id: myrealm.myzone
service_name: rgw.myrealm.myzone
placement:
  count: 4
  hosts:
  - serverd.lab.example.com
  - servere.lab.example.com
spec:
  rgw_frontend_port: 8080
EOR
```

```bash
[ceph: root@clienta /]# ceph orch apply \
	-i rgw_service.yaml

[ceph: root@clienta /]# ceph status | grep rgw

[ceph: root@clienta /]# ceph orch ps \
	--daemon-type rgw

[ceph: root@clienta /]# <Ctrl-D>
[root@clienta ~]# <Ctrl-D>
```

<span alt="modern">[root@serverd ~]# </span>

```bash
# podman ps -a \
	--format "{{.ID}} {{.Names}}" | grep rgw

# curl serverd:8080
# curl serverd:8081

# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish object-radosgw
```



#### 8.2 <strong style='color: #1A97D5'>指导练习: </strong>配置多站点对象存储部署

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start object-multisite
```

<span alt="modern">[root@serverc|serverf ~]# </span>

```bash
# cephadm shell
[ceph: root@serverc /]# ceph health
```

<span alt="modern">[root@serverc ~]# </span>

```bash
[ceph: root@serverc /]# radosgw-admin realm \
	create --rgw-realm=cl260 --default

[ceph: root@serverc /]# radosgw-admin \
	zonegroup create \
	--rgw-zonegroup=classroom \
	--endpoints=http://serverc:80 \
	--master \
	--default

[ceph: root@serverc /]# radosgw-admin \
	zone create \
	--rgw-zonegroup=classroom \
	--rgw-zone=us-east-1 \
	--endpoints=http://serverc:80 \
	--master \
	--default \
	--access-key=replication \
	--secret=secret

[ceph: root@serverc /]# radosgw-admin \
	user create --uid="repl.user" \
	--system \
	--display-name="Replication User" \
	--secret=secret \
	--access-key=replication

[ceph: root@serverc /]# radosgw-admin \
	period update --commit
```

```bash
[ceph: root@serverc /]# ceph orch apply \
	rgw cl260-1 \
	--realm=cl260 \
	--zone=us-east-1 \
	--placement="1 serverc.lab.example.com"

[ceph: root@serverc /]# ceph config set \
	client.rgw rgw_zone us-east-1

[ceph: root@serverc /]# <Ctrl-D>
[root@serverc ~]# <Ctrl-D>
```

<span alt="modern">[root@serverf ~]# </span>

```bash
[ceph: root@serverf /]# radosgw-admin realm \
	pull \
	--url=http://serverc:80 \
	--access-key=replication \
	--secret-key=secret

[ceph: root@serverf /]# radosgw-admin \
	period pull \
	--url=http://serverc:80 \
	--access-key=replication \
	--secret-key=secret

[ceph: root@serverf /]# radosgw-admin \
	period get-current
```

```bash
[ceph: root@serverf /]# radosgw-admin \
	realm default --rgw-realm=cl260
[ceph: root@serverf /]# radosgw-admin \
	zonegroup default --rgw-zonegroup=classroom

[ceph: root@serverf /]# radosgw-admin \
	zone create \
	--rgw-zonegroup=classroom \
	--rgw-zone=us-east-2 \
	--endpoints=http://serverf:80 \
	--access-key=replication \
	--secret-key=secret \
	--default

[ceph: root@serverf /]# radosgw-admin \
	period update \
	--commit \
	--rgw-zone=us-east-2

[ceph: root@serverf /]# ceph config \
	set client.rgw rgw_zone us-east-2
```

```bash
[ceph: root@serverf /]# ceph orch apply \
	rgw cl260-2 \
	--realm=cl260 \
	--zone=us-east-2 \
	--placement="1 serverf.lab.example.com"

[ceph: root@serverf /]# radosgw-admin \
	period get-current

[ceph: root@serverf /]# radosgw-admin \
	period get-current

[ceph: root@serverf /]# <Ctrl-D>
[root@serverf ~]# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish object-multisite
```





### [9. 使用 REST API 访问对象存储]()

#### 9.1 <strong style='color: #1A97D5'>指导练习: </strong>使用 Amazon S3 API 提供对象存储

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start api-s3
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell -- \
	radosgw-admin user create \
	--uid="operator" \
	--display-name="S3 Operator" \
	--email="operator@example.com" \
	--access_key="12345" \
	--secret="67890"
```

```bash
# aws configure --profile=ceph
AWS Access Key ID [None]: `12345`
AWS Secret Access Key [None]: `67890`
Default region name [None]: `<Enter>`
Default output format [None]: `<Enter>`
```

```bash
# aws \
	--profile=ceph \
	--endpoint=http://serverc:80 \
	s3 mb s3://testbucket

# aws \
	--profile=ceph \
	--endpoint=http://serverc:80 \
	s3 ls
```

```bash
# dd if=/dev/zero of=/tmp/10MB.bin \
	bs=1024K count=10

# aws \
	--profile=ceph \
	--endpoint=http://serverc:80 \
	--acl=public-read-write \
	s3 cp /tmp/10MB.bin s3://testbucket/10MB.bin
```

```bash
# wget -O /dev/null \
	http://serverc:80/testbucket/10MB.bin
```

```bash
# cephadm shell -- \
	radosgw-admin bucket list

# cephadm shell -- \
	radosgw-admin metadata get bucket:testbucket
```

```bash
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish api-s3
```



#### 9.2 <strong style='color: #1A97D5'>指导练习: </strong>使用 Swift API 提供对象存储

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start api-swift

if host www.easthome.com &>/dev/null; then
	ssh root@classroom rht-config-nat
	# 更换软件源
	PURL=https://mirror.nju.edu.cn/pypi/web/simple
	ssh root@clienta \
		tee /etc/pip.conf <<EOP
[global]
index-url=$PURL
EOP
else
	echo -e "\e[1;27m
 1. foundation0 must have two NIC
 2. There is a link to the Internet\e[0;0m\n"
fi
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell -- \
	radosgw-admin subuser create \
	--uid="operator" \
	--subuser="operator:swift" \
	--access="full" \
	--secret="opswift"
```

```bash
# pip3 install --upgrade python-swiftclient

# alias swift='swift -A http://serverc:80/auth/1.0 -U operator:swift -K opswift'

# swift stat
```

```bash
# swift list

# swift post testcontainer
# swift list
```

```bash
# dd if=/dev/zero of=/tmp/swift.dat \
	bs=1024K count=10
# swift upload testcontainer /tmp/swift.dat
```

```bash
# swift stat testcontainer

# swift stat

# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish api-swift
```





### [10. 使用 CephFS 提供文件存储]()

#### 10.1 <strong style='color: #1A97D5'>指导练习: </strong>部署共享文件存储

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start fileshare-deploy
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell

[ceph: root@clienta /]# ceph osd pool create mycephfs_data
[ceph: root@clienta /]# ceph osd pool create mycephfs_metadata
[ceph: root@clienta /]# ceph fs new mycephfs \
	mycephfs_metadata mycephfs_data
[ceph: root@clienta /]# ceph orch apply mds mycephfs \
	--placement="1 serverc.lab.example.com"

[ceph: root@clienta /]# ceph mds stat
[ceph: root@clienta /]# ceph status

[ceph: root@clienta /]# ceph df | grep myceph

[ceph: root@clienta /]# <Ctrl-D>
```

```bash
# yum -y install ceph-common
# ls /etc/ceph/ceph.client.admin.keyring

# mkdir /mnt/mycephfs
# mount.ceph serverc:/ /mnt/mycephfs \
	 -o name=admin
# df /mnt/mycephfs/

# mkdir /mnt/mycephfs/dir{1,2}
# ls -al /mnt/mycephfs

# touch /mnt/mycephfs/dir1/test1
# dd if=/dev/zero \
	of=/mnt/mycephfs/dir1/test2 \
	bs=1024  count=10000

# umount /mnt/mycephfs
```

```bash
# cephadm shell -- ceph fs status
```

```bash
# cephadm shell --mount /etc/ceph/
[ceph: root@clienta /]# ceph fs authorize \
	mycephfs client.restricteduser \
	/ r /dir2 rw

[ceph: root@clienta /]# ceph auth get \
	client.restricteduser \
	-o /mnt/ceph.client.restricteduser.keyring

[ceph: root@clienta /]# <Ctrl-D>
```

```bash
# mount.ceph serverc:/ /mnt/mycephfs \
	-o name=restricteduser,fs=mycephfs

# tree /mnt
# touch /mnt/mycephfs/dir1/ro.txt
# touch /mnt/mycephfs/dir2/rw.txt
# ls /mnt/mycephfs/dir2
# rm -f /mnt/mycephfs/dir2/rw.txt
```

```bash
# mkdir /mnt/mycephfuse

# yum -y install ceph-fuse

# ceph-fuse \
	-n client.restricteduser \
	--client_fs mycephfs /mnt/mycephfuse/

# tree /mnt

# umount /mnt/mycephfuse
```

```bash
# cat >> /etc/fstab <<EOF
serverc:/ /mnt/mycephfuse fuse.ceph ceph.id=restricteduser,_netdev 0 0
EOF

# mount -a

# df | grep ceph

# umount /mnt/mycephfuse
```

```bash
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

<blockquote alt="warn"><b>警告</b><br><p>在 workstation 上运行 lab 完成脚本，以便可以安全地重新启动 clienta 节点，而不会发生挂载冲突</p></blockquote>

```bash
ssh student@workstation \
	lab finish fileshare-deploy
```



#### 10.2 <strong style='color: #1A97D5'>指导练习: </strong>管理共享文件存储

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start fileshare-manage
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# mkdir /mnt/mycephfs/dir1
# touch /mnt/mycephfs/dir1/f1
# getfattr \
	-n ceph.dir.layout /mnt/mycephfs/dir1 \
	|| echo ERROR

# setfattr \
	-n ceph.dir.layout.stripe_count \
	-v 2 /mnt/mycephfs/dir1
# getfattr \
	-n ceph.dir.layout /mnt/mycephfs/dir1/
# getfattr \
	-n ceph.dir.layout /mnt/mycephfs/dir1/f1

# touch /mnt/mycephfs/dir1/newfile
# getfattr \
	-n ceph.dir.layout /mnt/mycephfs/dir1/f2

# setfattr \
	-n ceph.dir.layout.stripe_count \
	-v 3 /mnt/mycephfs/dir1/f2
# getfattr \
	-n ceph.file.layout /mnt/mycephfs/dir1/f2

# echo Not empty > /mnt/mycephfs/dir1/newfile
# setfattr \
	-n ceph.file.layout.stripe_count \
	-v 4 /mnt/mycephfs/dir1/f2 \
	|| echo ERROR

# setfattr -x ceph.dir.layout \
	/mnt/mycephfs/dir1/
# touch /mnt/mycephfs/dir1/f3
# getfattr \
	-n ceph.file.layout /mnt/mycephfs/dir1/f3
```

```bash
# umount /mnt/mycephfs
# mount.ceph serverc:/ /mnt/mycephfs \
	-o name=restricteduser

# cd /mnt/mycephfs/.snap
[root@clienta .snap]# mkdir mysnapshot \
	|| echo ERROR
[root@clienta .snap]# cephadm shell

[ceph: root@clienta /]# ceph auth get \
	client.restricteduser
[ceph: root@clienta /]# ceph auth caps \
	client.restricteduser \
	mds 'allow rws fsname=mycephfs' \
	mon 'allow r fsname=mycephfs' \
	osd 'allow rw tag cephfs data=mycephfs'
[ceph: root@clienta /]# <Ctrl-D>

[root@clienta .snap]# cd
# umount /mnt/mycephfs
# mount.ceph serverc:/ /mnt/mycephfs \
	-o name=restricteduser
# cd /mnt/mycephfs/.snap
[root@clienta .snap]# mkdir mysnapshot

[root@clienta .snap]# tree /mnt/mycephfs/
[root@clienta .snap]# tree \
	/mnt/mycephfs/.snap/mysnapshot
```

```bash
[root@clienta .snap]# cephadm shell
[ceph: root@clienta /]# ceph \
	mgr module enable snap_schedule
[ceph: root@clienta /]# ceph \
	fs snap-schedule add / 1h

[ceph: root@clienta /]# ceph \
	fs snap-schedule status /
[ceph: root@clienta /]# <Ctrl-D>
[root@clienta .snap]# ls
[root@clienta .snap]# tree

[root@clienta .snap]# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

<blockquote alt="warn"><b>警告</b><br><p>在 workstation 上运行 lab 完成脚本，以便可以安全地重新启动 clienta 节点，而不会发生挂载冲突</p></blockquote>

```bash
ssh student@workstation \
	lab finish fileshare-manage
```





### [11. 管理红帽 Ceph 存储集群]()

#### 11.1 <strong style='color: #1A97D5'>指导练习: </strong>执行群集管理和监视

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start cluster-admin
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
```

```bash
[ceph: root@clienta /]# ceph mgr module ls \
	| less

[ceph: root@clienta /]# ceph mgr services
```

<img align='left' height='36' src='https://img.shields.io/badge/firefox-https%3A%2F%2Fserverc%3A8443-FF7139?style=flat-square&logo=firefox'>

​		<kbd>Advanced...</kbd> / <kbd>Accept the Risk and Continue</kbd>

​				User name: ==admin==
​				Password: ==redhat== / <kbd>Log in</kbd>

<div alt="timeline">
    <div alt="timenode">
        <div alt="meta">Cluster</div>
        <div alt="body">
          <kbd>Monitors</kbd>
        </div>
    </div>
</div>

```bash
[ceph: root@clienta /]# ceph osd stat

[ceph: root@clienta /]# ceph osd find 2

[ceph: root@clienta /]# ssh root@serverc
```

<span alt="modern">[root@serverc ~]$ </span>

```bash
# systemctl list-units "ceph*" | grep osd.2
# systemctl stop ceph-2ae6d05a-229a-11ec-925e-52540000fa0c@osd.2.service

# <Ctrl-D>
```

<span alt="modern">[root@clienta ~]# </span>

```bash
[ceph: root@clienta /]# ceph osd stat

[ceph: root@clienta /]# ssh root@serverc \
	systemctl start ceph-2ae6d05a-229a-11ec-925e-52540000fa0c@osd.2.service
[ceph: root@clienta /]# ceph osd stat

[ceph: root@clienta /]# ssh root@serverc \
	journalctl -u ceph-2ae6d05a-229a-11ec-925e-52540000fa0c@osd.2.service \
	| grep systemd

[ceph: root@clienta /]# ceph osd out 4
[ceph: root@clienta /]# ceph osd stat
[ceph: root@clienta /]# ceph osd tree

[ceph: root@clienta /]# ceph osd in 4

[ceph: root@clienta /]# ceph osd df tree

[ceph: root@clienta /]# ceph pg stat
[ceph: root@clienta /]# ceph osd pool create \
	testpool 32 32
[ceph: root@clienta /]# rados -p testpool \
	put testobject /etc/ceph/ceph.conf
[ceph: root@clienta /]# ceph osd map \
	testpool testobject
osdmap e244 pool 'testpool' (8) object 'testobject' -> pg 8.98824931 (8.11) -> up ([8,7,1], p8) acting ([8,7,1], p8)
[ceph: root@clienta /]# ceph pg 8.11 query

[ceph: root@clienta /]# ceph versions
[ceph: root@clienta /]# ceph tell osd.* \
	version

[ceph: root@clienta /]# ceph balancer status

[ceph: root@clienta /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish cluster-admin
```



#### 11.2 <strong style='color: #1A97D5'>指导练习: </strong>执行群集维护操作

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start cluster-maint
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
```

```bash
[ceph: root@clienta /]# ceph osd set noscrub
[ceph: root@clienta /]# ceph osd set \
	nodeep-scrub
```

```bash
[ceph: root@clienta /]# ceph health detail
```

```bash
[ceph: root@clienta /]# ceph osd tree \
	| grep -i down

[ceph: root@clienta /]# ceph osd find osd.3

[ceph: root@clienta /]# ssh root@serverd
[root@serverd ~]# cephadm shell
[ceph: root@serverd /]# ceph-volume lvm list
[ceph: root@serverd /]# ceph-volume lvm list \
	| grep -A 16 osd.3 \
	| grep -w devices

[ceph: root@serverd /]# <Ctrl-D>
```

```bash
# systemctl list-units --all "ceph*" \
	| grep osd.3

# journalctl -ru ceph-2ae6d05a-229a-11ec-925e-52540000fa0c@osd.3.service | grep systemd

# systemctl start ceph-2ae6d05a-229a-11ec-925e-52540000fa0c@osd.3.service

# <Ctrl-D>
```

```bash
[ceph: root@clienta /]# ceph osd tree

[ceph: root@clienta /]# ceph osd unset noscrub

[ceph: root@clienta /]# ceph osd unset \
	nodeep-scrub

[ceph: root@clienta /]# ceph -w
<Ctrl-C>

[ceph: root@clienta /]# ceph orch ls \
	--service_type=mon
[ceph: root@clienta /]# ssh-copy-id -f \
	-i ~/ceph.pub root@serverg
[ceph: root@clienta /]# ceph orch host add \
	serverg.lab.example.com
[ceph: root@clienta /]# ceph orch apply mon \
	--placement="clienta.lab.example.com serverc.lab.example.com serverd.lab.example.com servere.lab.example.com serverg.lab.example.com"

[ceph: root@clienta /]# ceph orch ls \
	--service-type=mon
```

```bash
[ceph: root@clienta /]# ceph orch apply mon \
	--placement="clienta.lab.example.com serverc.lab.example.com serverd.lab.example.com servere.lab.example.com"
[ceph: root@clienta /]# ceph mon stat
```

<blockquote alt="warn"><b>警告</b><br><p>始终在生产群集中保持至少三个 MONs 运行</p></blockquote>

```bash
[ceph: root@clienta /]# ceph orch ps \
	serverg.lab.example.com | grep osd

[ceph: root@clienta /]# ceph osd crush \
	remove osd.9
[ceph: root@clienta /]# ceph osd crush \
	remove osd.10
[ceph: root@clienta /]# ceph osd crush \
	remove osd.11

[ceph: root@clienta /]# ceph osd rm 9 10 11

[ceph: root@clienta /]# ceph orch host rm \
	serverg.lab.example.com
[ceph: root@clienta /]# ceph orch host ls
```

```bash
[ceph: root@clienta /]# ceph orch host \
	maintenance enter servere.lab.example.com
[ceph: root@clienta /]# ceph orch host ls

[ceph: root@clienta /]# ssh root@servere reboot
[ceph: root@clienta /]# ceph orch host \
	maintenance exit servere.lab.example.com

[ceph: root@clienta /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish cluster-maint
```





### [12. 调整和故障排除红帽 Ceph 存储]()

#### 12.1 <strong style='color: #1A97D5'>指导练习: </strong>优化红帽 Ceph 存储性能

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start tuning-optimize
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell

[ceph: root@clienta /]# ceph osd pool create testpool
[ceph: root@clienta /]# ceph health detail
[ceph: root@clienta /]# ceph osd pool autoscale-status | grep testpool

[ceph: root@clienta /]# ceph osd pool set testpool pg_autoscale_mode off
[ceph: root@clienta /]# ceph osd pool set testpool pg_num 8
[ceph: root@clienta /]# ceph osd pool autoscale-status | grep testpool
[ceph: root@clienta /]# ceph health detail

[ceph: root@clienta /]# ceph osd pool set testpool pg_autoscale_mode warn
set pool 9 pg_autoscale_mode to warn
[ceph: root@clienta /]# ceph health detail

[ceph: root@clienta /]# ceph osd pool set testpool pg_autoscale_mode on
[ceph: root@clienta /]# ceph osd pool autoscale-status
```

```bash
[ceph: root@clienta /]# ceph osd primary-affinity 7 0
[ceph: root@clienta /]# ceph osd tree
[ceph: root@clienta /]# ceph osd dump | grep affinity
```

```bash
[ceph: root@clienta /]# ceph osd pool create benchpool 100 100
[ceph: root@clienta /]# rbd pool init benchpool
```

<kbd>Ctrl</kbd>-<kbd>Shift</kbd>-<kbd>T</kbd>

```bash
# cephadm shell
[ceph: root@clienta /]# 
```

<kbd>Alt</kbd>-<kbd>1</kbd>

```bash
[ceph: root@clienta /]# rados -p benchpool bench 30 write
```

<kbd>Alt</kbd>-<kbd>2</kbd>

```bash
[ceph: root@clienta /]# ceph osd perf
[ceph: root@clienta /]# ceph osd tree
```

```bash
[ceph: root@clienta /]# ceph tell osd.2 perf dump > perfdump.txt

[ceph: root@clienta /]# grep -A 88 -w osd perfdump.txt
```

<kbd>Alt</kbd>-<kbd>1</kbd>

```bash
[ceph: root@clienta /]# rados -p benchpool bench 30 write
```

<kbd>Alt</kbd>-<kbd>2</kbd>

```bash
[ceph: root@clienta /]# ceph tell osd.2 perf dump > perfdump.txt
[ceph: root@clienta /]# grep -A 88 -w osd perfdump.txt
```

==op_latency/sum==t2 - ==op_latency/sum==t1 = diffs

==op_latency/avgcount==t2 - ==op_latenc y/avgcount==t1 = diffa

==op_latency== = ==diffs== / ==diffa==

```bash
[ceph: root@clienta /]# ceph tell osd.6 dump_historic_ops > historicdump.txt
[ceph: root@clienta /]# head historicdump.txt

[ceph: root@clienta /]# ceph tell osd.2 config set osd_op_history_size 30
[ceph: root@clienta /]# ceph tell osd.2 config set osd_op_history_duration 900
[ceph: root@clienta /]# ceph tell osd.2 dump_historic_ops > historicops.txt
[ceph: root@clienta /]# head -n 3 historicops.txt

[ceph: root@clienta /]# ceph tell osd.* config set osd_op_history_size 20
[ceph: root@clienta /]# ceph tell osd.* config set osd_op_history_duration 600
```

```bash
[ceph: root@clienta /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish tuning-optimize
```



#### 12.2 <strong style='color: #1A97D5'>指导练习: </strong>调整对象存储集群性能

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start tuning-perf
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
[ceph: root@clienta /]# ceph tell osd.0 bluestore allocator score block
```

```bash
[ceph: root@clienta /]# ceph osd tree
[ceph: root@clienta /]# ceph tell osd.0 config get osd_max_backfills
[ceph: root@clienta /]# ceph tell osd.0 config set osd_max_backfills 2
```

```bash
[ceph: root@clienta /]# ceph tell osd.0 config get osd_recovery_max_active
[ceph: root@clienta /]# ceph tell osd.0 config get osd_recovery_max_active_hdd
[ceph: root@clienta /]# ceph tell osd.0 config get osd_recovery_max_active_ssd

[ceph: root@clienta /]# ceph tell osd.0 config set osd_recovery_max_active 1
[ceph: root@clienta /]# ceph tell osd.0 config get osd_recovery_max_active
```

```bash
[ceph: root@clienta /]# <Ctrl-D>
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish tuning-perf
```



#### 12.3 <strong style='color: #1A97D5'>指导练习: </strong>集群和客户端故障排除

<span alt="modern">[kiosk@foundation ~]$</span>

```bash
ssh student@workstation \
	lab start tuning-troubleshoot
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell -- ceph health
```

<span alt="modern">[root@serverd ~]# </span>

```bash
# systemctl is-active chronyd
# systemctl start chronyd
# systemctl is-active chronyd
# <Ctrl-D>
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# cephadm shell
[ceph: root@clienta /]# ceph health detail

[ceph: root@clienta /]# ceph osd tree \
	| grep -B 1 down
[ceph: root@clienta /]# <Ctrl-D>
```

<span alt="modern">[root@serverc ~]# </span>

```bash
# systemctl list-units --all "ceph*" \
	| awk '/osd.0/ {print $1}'
# systemctl start ceph-2ae6d05a-229a-11ec-925e-52540000fa0c@osd.0.service
# systemctl is-active ceph-2ae6d05a-229a-11ec-925e-52540000fa0c@osd.0.service
# <Ctrl-D>
```

<span alt="modern">[root@clienta ~]# </span>

```bash
# ceph osd tree | grep osd.0
# ceph health
# <Ctrl-D>
```

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh student@workstation \
	lab finish tuning-troubleshoot
```





### [13. 使用红帽 Ceph 存储管理云平台]()

#### 13.1 <strong style='color:#3B0083'>小测验: </strong>OpenStack 存储架构简介

1. **OpenStack 中默认对象存储服务是哪个名称?**
    a. Nova
    b. Glance
    c. RGW
    **d.** Swift

2. **以下哪两个选项描述了 Ceph 集成设计的实现选择?** 
    a. Stand-alone
    **b.** External
    **c.** Dedicated
    d. Containerized

3. **以下哪个选项是 TripleO 构建 Ceph 服务器时最常用的节点角色?**
    **a.** CephStorage
    b. CephAII
    c. ControllerStorage
    d. StorageNode

4. **以下哪两个选项是专用 Ceph 与 OSP 集成的好处?**
    a. 集群中的 OSD 数量仅受硬件配置限制
    **b.** 集成的安装和更新策略
    **c.** 具有计算资源的超融合基础架构
    d. 存储资源可供外部客户端使用
    e. Ceph 集群可以支持多个 OSP 环境

  

#### 13.2 <strong style='color:#3B0083'>小测验: </strong>在 OpenStack 组件中实现存储

1. **以下哪一种是红帽 OpenStack 平台支持用于集成 Ceph 集群的唯一映像格式?**
   a. QCOW2
   b. VMDK
   **c.** RAW
   d. VHDX
2. **以下哪四个是 OpenStack 服务使用的默认 Ceph 池名称?** 
   a. vms
   **b.** volumes
   **c.** backups
   d. glance
   e. shares
   **f.** images
   g. compute

3. **以下哪三项是 Ceph RADOS 块设备支持的 OpenStack 服务？**
   a. Deployment
   **b.** Images
   c. Shared FileSystems
   **d.** Block Storage
   **e.** Object Storage
   f. Compute
4. **以下哪三个参数是将外部 Ceph 存储集群与 OpenStack 集成所需的参数?**
   **a.** FSID
   b. Manager node list
   **c.** Monitor node list
   **d.** client .openstack key-ring
   e. admin. openstack key-ring
   f. Monitor map



#### 13.3 <strong style='color:#3B0083'>小测验: </strong>OpenShift 存储架构简介

1. **OpenShift Data Foundation 中的哪个组件为 OpenShift Container Platform 为 Ceph 存储提供了接口?**
**a.** CSI drivers
b. NooBaa
c. OCSlnitialization
d. CustomResourceDefinitions
2. **以内部模式安装 OpenShift Data Foundation 有哪三个优势?**
a. 支持多个 OpenShift Container Platform 集群
**b.** 存储后端可以使用与 OpenShift Container Platform 集群相同的基础设施
c. 高级功能和配置定制
**d.** 自动化 Ceph 存储安装和配置
**e.** 无缝自动更新和生命周期管理
3. **Rook-Ceph算子的主要能力是哪三个？**
a. 提供包含运营商和资源的捆绑包以部署存储集群
**b.** 监控 Ceph 守护进程并确保集群处于健康状态
**c.** 根据最佳实践和建议部署存储集群
d. 与多云交互，提供对象服务
**e.** 查找配置更改并将其应用到存储集群
4. **ocs-operator提供了哪两个 CustomerResourceDefinitions?**
**a.** StorageCluster
b. CSI Drivers
c. OpenShiftStorage
**d.** OCSInitialization



#### 13.4 <strong style='color:#3B0083'>小测验: </strong>在 OpenShift 组件中实现存储

1. **pv 和 pvc 有什么关系?**
a. pvc 可以定义多个要附加的 pv
b. pv 请求声明并附加 pvc
**c.** pvc 请求一个卷并且 pv 附加到该声明
d. pvc 是使用 pv 的定义创建的
2. NooBaa 可以与什么类型的资源交互?
a. CustornResourceDefinitions
b. StorageClass
c. PersistentVolumeClaim
**d.** ObjectBucketClaim
3. 什么场景下应用挂载 volume 需要 RWX 访问方式的volume?
**a.** 挂载到许多都具有读写权限的 pod
b. 挂载到许多只有读取权限的 pod
c. 挂载到一个有读写权限的pod
d. 挂载到一个只有读权限的 pod
4. 哪个 OpenShift Container Platform 资源声明了 QoS 和配置程序类型等存储后端特性?
a. CustomReourceDefinitions
**b.** StorageClass
c. PersistentVolumeClaim
d. ObjectBucketClaim



### A. 参考和附录

#### A1. Bash-completion

<span alt="modern">[ceph: root@clienta / ~]# </span>

```bash
bash -c "$(curl -sS http://content/tab)"
```

PS:

```bash
$ cat /content/tab
```

```bash
#!/bin/bash

# 备份
mv /etc/yum.repos.d/ubi.repo /etc/yum.repos.d/ubi.repo.bk

# 新建
URL=http://content/rhel8.4/x86_64/dvd
cat > /etc/yum.repos.d/dvd.repo <<EOR
[base]
name=base
baseurl=$URL/BaseOS/
gpgkey=$URL/RPM-GPG-KEY-redhat-release
[app]
name=app
baseurl=$URL/AppStream/
gpgkey=$URL/RPM-GPG-KEY-redhat-release
EOR

# 安装
yum -y install bash-completion

echo -e "\nPlease type \e[1;37msource /etc/profile\e[0;0m\n"
```



#### A2. PS1

<span alt="modern">[kiosk@foundation ~]$ </span>

```bash
ssh root@localhost \
	tee -a /etc/bashrc <<EOB >/dev/null
if [ "\$UID" != "0" ]; then
    PS1='\342\224\214\342\224\200[\e[1;96m\u@\h \W\e[0;0m]\n\342\224\224\\$ '
else
    PS1='\342\224\214\342\224\200[\e[1;37m\u@\h \W\e[0;0m]\n\342\224\224\\$ '
fi
EOB

source /etc/bashrc
```

