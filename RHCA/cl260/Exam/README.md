[toc]

## <strong style='color: #00B9E4'>重要配置信息</strong>

### Topology

| ID | HOSTNAME | IP |
|:--:|:--------:|:--:|
| 1 | serverc.lab.example.com | `172.25.250.12` |
| 2 | serverd.lab.example.com | `172.25.250.13` |
| 3 | servere.lab.example.com | `172.25.250.14` |
| 4 | clienta.lab.example.com | `172.25.250.10` |

### 其他信息

产品文档可从以下位置找到：

- http://content/rhcs5.0/x86_64/dvd/docs/index.html

## <strong style='color: #00B9E4'>练习要求</strong>

### 1\. 布署 Ceph

> 容器 image 存储在 **registry.lab.example.com**
>
> - [ ] 账号: **registry**
> - [ ] 密码: **redhat**
>
> 使用集群网络 **172.25.250.0**
>
> - [ ] 在 **serverc**, **serverd**, **servere**和 **clienta** 节点上部署 Ceph 集群, 
>
> - [ ] **serverc.lab.example.com** 和 **clienta.lab.example.com** 为 Ceph 管理节点
> - [ ] 3 个存储节点使用 **/dev/vdb**, **/dev/vdc**, **/dev/vdd** 作为 OSD 硬盘
> - [ ] Dashboard 的管理员密码是 **redhat**
> - [ ] 安装并配置其它题目所要求的服务
>
> cephadm 软件包已经提前安装到了 serverc 节点

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
# DEPLOY
#* cephadm bootstrap -h
#  --dashboard-password-noupdate
#				stop forced dashboard password change
#  --allow-fqdn-hostname
#				allow hostname that is fully-qualified (contains ".")
#  --cluster-network CLUSTER_NETWORK
#				subnet to use for cluster replication, recovery and heartbeats (in CIDR notation network/mask)
cephadm bootstrap \
	--mon-ip 172.25.250.12 \
	--initial-dashboard-password redhat \
	--dashboard-password-noupdate \
	--allow-fqdn-hostname \
	--registry-url registry.lab.example.com \
	--registry-username registry \
	--registry-password redhat \
	--cluster-network 172.25.250.0/24

```

```bash
#* Enabling password-less SSH
# -f: force
ssh-copy-id -f -i /etc/ceph/ceph.pub root@serverd
ssh-copy-id -f -i /etc/ceph/ceph.pub root@servere
ssh-copy-id -f -i /etc/ceph/ceph.pub root@clienta

```

```bash
# install software
yum provides ceph

#* cmd
yum -y install ceph-common

# <Tab>: source OR logout then login
source /etc/bash_completion.d/ceph

```

```bash
# Add a host
#* ceph orch host add -h
ceph orch host add serverd.lab.example.com 172.25.250.13
ceph orch host add servere.lab.example.com 172.25.250.14
ceph orch host add clienta.lab.example.com 172.25.250.10

ceph orch host ls

```

```bash
#* Add a host label
ceph orch host label add clienta.lab.example.com _admin
ceph orch host label add serverc.lab.example.com _admin

ceph orch host ls

```

```bash
#* ceph orch apply -h
ceph orch apply mon \
	serverc.lab.example.com,serverd.lab.example.com,servere.lab.example.com

ceph orch ls mon

#* ceph orch apply -h
ceph orch apply mgr \
	serverc.lab.example.com,serverd.lab.example.com,servere.lab.example.com

ceph orch ls mgr

#* ceph orch daemon add osd -h
ceph orch daemon add osd serverc.lab.example.com:/dev/vdb,/dev/vdc,dev/vdd 
ceph orch daemon add osd serverd.lab.example.com:/dev/vdb,/dev/vdc,dev/vdd 
ceph orch daemon add osd servere.lab.example.com:/dev/vdb,/dev/vdc,dev/vdd 

ceph device ls

```

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>[root@clienta \~\]#

```bash
#* for ceph
yum -y install ceph-common
source /etc/bash_completion.d/ceph

#* keyring, conf
scp root@serverc:/etc/ceph/*.{keyring,conf} /etc/ceph

ceph health

```



### 2\. Ceph 的健康状态

> - [ ] Ceph 的健康状态应该为: **HEALTH_OK**

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
#*
ceph health

```



### 3\. 配置 Ceph

> - [ ] Ceph 中的 pool 允许被删除

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
ceph config ls | grep allow.*del

#* ceph config set -h
ceph config set mon mon_allow_pool_delete true

ceph config get mon

```



### 4\. 配置 Ceph dashboard

> - [ ] 配置 Ceph dashboard 支持 SSL https://serverc.lab.example.com:8443/

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
第 1 题已完成，此处只做验证
</div>
<img align='left' height='36' src='https://img.shields.io/badge/firefox-https://serverc.lab.example.com:8443/-FF7139?style=flat-square&logo=firefox'>

​		<kbd>Advanced...</kbd> / <kbd>Acept the Risk and Continue</kbd> /

​		Username<font style='color:red'>\*</font> ==admin==
​		Password<font style='color:red'>*</font> ==redhat==
​		<kbd>Log in</kbd>

<img src='https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/intro/gui-dashboard-security.png'>

<img src='https://k8s.ruitong.cn:8080/Redhat/CL260-RHCS5.0-en-1-20211117/images/intro/gui-dashboard-login.png'>



### 5\. 创建纠删代码 profile 和 pool

> - [ ] 创建名为 **ceph260-ecprofile** 的纠删代码 profile
> - [ ] 包含 **3** 个 data chunks，**2** 个coding chunks，crush-failure-domain 参数为 **osd**
> - [ ] 创建使用这个 profile 的名为 **ecpool** 的存储池，池包含 **32** 个PGs
> - [ ] 用于 **rgw** 类似的应用

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
# ceph -h | grep profile
#* ceph osd erasure-code-profile get default
ceph osd erasure-code-profile set \
	ceph260-ecprofile \
	k=3 m=2 crush-failure-domain=osd

#* ceph osd pool create --help
ceph osd pool create ecpool 32 erasure ceph260-ecprofile

#* ceph osd pool application enable --help
ceph osd pool application enable ecpool rgw

```

```bash
ceph osd erasure-code-profile get ceph260-ecprofile \
	| egrep 'k=|m=|fail'

ceph osd pool get ecpool pg_num
ceph osd pool get ecpool erasure_code_profile

ceph osd pool application get ecpool

```



### 6\. 管理 Ceph 身份认证

> - [ ] 创建 Ceph 用户 **thomas**
> - [ ] 可以读写 **ecpool** 存储池中的 **dev** namespace 中的对象
> - [ ] thomas 用户可从 clienta.lab.example.com 访问 ecpool, 但该用户不可以访问其它任何存储池
> - [ ] 创建 Ceph 用户 **rbd**
> - [ ] 可以对 **ceph260-pool** 存储池执行读、写和执行扩展的对象类
> - [ ] rbd 用户可以从 clienta.lab.example.com 访问 ceph260-pool, 但该用户不可以访问其它任何存储池

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
ceph auth ls
man ceph-authtool

# ceph auth get-or-create --help
ceph auth get-or-create \
	client.thomas \
	mon 'allow r' \
	osd 'allow rw pool=ecpool namespace=dev' \
	-o /etc/ceph/ceph.client.thomas.keyring

# ceph auth get-or-create --help
ceph auth get-or-create client.rbd \
	mon 'allow profile osd' \
	osd 'allow rwx pool=ceph260-pool' \
	-o /etc/ceph/ceph.client.rbd.keyring

ceph auth ls
ls /etc/ceph/*.keyring

scp /etc/ceph/*{thomas,rbd}.keyring root@clienta:/etc/ceph

```

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>[root@clienta \~\]#

```bash
# 可以读写 ecpool 存储池中的 dev namespace 中的对象
# rados -h | egrep '\-p |\-N |\--id '
rados --id thomas -p ecpool -N dev put newfile /etc/fstab

rados --id thomas -p ecpool -N dev ls

```



### 7\. 配置 Ceph RBD

> - [ ] 以 rbd 用户身份创建复制类型的存储池 **ceph260-pool**，含有 **32** 个PGs
> - [ ] 在存储池中创建一个 **512MB** 的 image: **ceph260-rbd**
> - [ ] 使用 **ext4** 文件系统格式化这个 image
> - [ ] 在 clienta.lab.example.com 上将这个 image 永久挂载到 **/mnt/rbd**

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
#* ceph osd pool create -h
ceph --id rbd \
	osd pool create ceph260-pool 32

ceph osd pool get ceph260-pool pg_num

#* ceph osd pool application enable -h
ceph osd pool application enable ceph260-pool rbd

ceph osd pool application get ceph260-pool

```

```bash
#* rbd help create
rbd create -s 512 ceph260-pool/ceph260-rbd

rbd ls -p ceph260-pool
rbd info -p ceph260-pool ceph260-rbd

```

```bash
#* rbd help map
rbd map -p ceph260-pool ceph260-rbd
lsblk

#* 使用 ext4 文件系统格式化这个 image
mkfs.ext4 /dev/rbd0
blkid /dev/rbd0

rbd showmapped

# rbd help unmap
rbd unmap /dev/rbd0

```

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>[root@clienta \~\]#

```bash
#* cat /etc/ceph/rbdmap
cat >> /etc/ceph/rbdmap <<EOC
ceph260-pool/ceph260-rbd id=rbd,keyring=/etc/ceph/ceph.client.rbd.keyring
EOC

systemctl enable --now rbdmap

```

```bash
mkdir /mnt/rbd

cat >> /etc/fstab <<EOF
/dev/rbd/ceph260-pool/ceph260-rbd /mnt/rbd ext4 _netdev 0 0
EOF

mount -a

df -h /mnt/rbd

reboot

```

```bash
df -h | grep mnt

```



### 8\. 导出 RBD image 为文件

> - [ ] 在 serverc.lab.example.com 上导出 image: **ceph260-rbd** 到 **student 用户** 的家目录, 名为: **ceph260-export.img**

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[student@serverc \~\]$**

```bash
# ls -l /etc/ceph/*.keyring
#* rbd help export
rbd \
	--id rbd \
	export ceph260-pool/ceph260-rbd ceph260-export.img

ls ~student

```



### 9\. 导入 RBD image 文件

> - [ ] 下载 http://content/ex260/ceph260_import.img
> - [ ] 导入 ceph260-pool 中，名为: **ceph260-image**

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
#*
wget http://content/ex260/ceph260_import.img

#* rbd help import
rbd import ceph260_import.img ceph260-pool/ceph260-image

rbd ls -p ceph260-pool

```



### 10\. 创建 RBD 快照

> - [ ] 为 **ceph260-image** 创建名为 **rbd-snap** 的快照

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
#* rbd help snap create
rbd snap create ceph260-pool/ceph260-image@rbd-snap

# rbd help snap ls
rbd snap ls ceph260-pool/ceph260-image

```



### 11\. 创建 RBD 克隆

> - [ ] 对 **rbd-snap** 快照创建一个名为 **rbd-clone** 的克隆
> - [ ] 使用 **rbd** 用户身份在 clienta.lab.example.com 上将这个克隆永久挂载到 **/mnt/clone**

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
#* rbd help snap protect
rbd snap protect ceph260-pool/ceph260-image@rbd-snap

#* rbd help clone
rbd clone \
	ceph260-pool/ceph260-image@rbd-snap \
	ceph260-pool/rbd-clone

```

```bash
rbd snap ls ceph260-pool/ceph260-image

# rbd help children
rbd children ceph260-pool/ceph260-image

```

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>[root@clienta \~\]#

```bash
cat /etc/ceph/rbdmap

cat >> /etc/ceph/rbdmap <<EOR
ceph260-pool/rbd-clone id=rbd,keyring=/etc/ceph/ceph.client.rbd.keyring
EOR

systemctl restart rbdmap

rbd showmapped
blkid /dev/rbd1

```

```bash
mkdir /mnt/clone

cat >> /etc/fstab <<EOF
/dev/rbd/ceph260-pool/rbd-clone /mnt/clone ext4 defaults,_netdev 0 0
EOF

mount -a

```

```bash
reboot

df -h /mnt/clone

```



### 12\. 部署 RADOS Gateway

> 在 serverc.lab.example.com 上部署 RADOS Gateway
>
> - [ ] Gateway 使用 **80** 和 **81** 端口
> - [ ] Gateway 的名字是 **ceph260_radosgw**

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
#* ceph orch apply rgw -h
ceph orch apply rgw \
	ceph260_radosgw \
	--port 80 \
	--placement="2 serverc.lab.example.com"

```

```bash
ceph orch ls rgw

ceph orch ps | grep radosgw

```



### 13\. 部署 MDS 和 CephFS

> - [ ] 在 serverc.lab.example.com 上部署 Metadata Server
> - [ ] 部署名为 **cephfs_ceph260** 的 CephFS volume
> - [ ] **cephfs_ceph260:/** 可以被 client id 为 **rw** 的用户进行读写访问和创建快照
> - [ ] **cephfs_ceph260:/archive** 可以被 client id 为 **ro** 的用户只读访问
> - [ ] 在 clienta 可以手动挂载

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
#*
ceph orch apply mds cephfs_ceph260 \
	--placement "2 serverc.lab.example.com"

#*
ceph osd pool create m1
ceph osd pool application enable m1 cephfs
ceph osd pool create d1
ceph osd pool application enable d1 cephfs

#*
ceph fs new cephfs_ceph260 m1 d1

```

```bash
#* ceph fs authorize -h
ceph fs authorize cephfs_ceph260 client.rw \
	/ rws \
	-o /etc/ceph/ceph.client.rw.keyring
ceph fs authorize cephfs_ceph260 client.ro \
	/archive r \
	-o /etc/ceph/ceph.client.ro.keyring

#*
scp /etc/ceph/*{rw,ro}.keyring root@clienta:/etc/ceph

```

```bash
# ceph auth get --help
ceph auth get client.rw
ceph auth get client.ro

```

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@clienta \~\]#**

```bash
#* man mount.ceph
mount.ceph serverc:/ /media \
	-o name=rw,fs=cephfs_ceph260

mount | grep ceph

```



### 14\. 配置 Ceph 全局参数

> - [ ] full_ratio 参数设为 **97%**
> - [ ] nearfull_ratio 参数设为 **80%**

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
ceph osd dump | grep full

#* ceph osd set-full-ratio -h
ceph osd set-full-ratio 0.97

# ceph osd set-nearfull-ratio -h
ceph osd set-nearfull-ratio 0.80

```

```bash
ceph osd dump | grep full

```



### 15\. 基于 S3 配置 RGW 对象存储

> **s3cmd** 工具已经预先安装到 RADOS Gateway 主机中
>
> 在 RADOS Gateway 主机中，按以下要求创建一个 S3 用户和一个 S3 bucket:
>
> - [ ] S3 用户的UID: **Sunny**, Access Key: **12345**, secret: **67890**
> - [ ] S3 bucket名为: **ceph260bucket**
> - [ ] 下载 http://content/ex260/S3_file 以 **my_S3_file** 的文件名上传到 **ceph260bucket**
> - [ ] DNS wildcard: ceph260bucket.serverc 已经配置好,
>   ceph260bucket 可以 http://serverc/ceph260bucket 或 http://ceph260bucket.serverc/ 方式访问
> - [ ] 设置 Sunny 用户的最大上传 quota 为 **20971520** 字节（全局）
> - [ ] 设置 Sunny 用户最大单 bucket quota 为 **10485760** 字节，并且最多能上传 **100** 个文件

<img width=36 src='https://k8s.ruitong.cn:8080/Redhat/virt-viewer.png'>**[root@serverc \~\]#**

```bash
#* radosgw-admin user create -h
radosgw-admin user create \
  --uid="Sunny" \
  --access-key="12345" \
  --secret="67890" \
  --display-name="Sunny"

```

```bash
#* aws configure help
aws configure
AWS Access Key ID [None]: `12345`
AWS Secret Access Key [None]: `67890`
Default region name [None]: `<Enter>`
Default output format [None]: `<Enter>`

```

```bash
#* aws s3 mb help
aws --endpoint-url http://serverc \
	s3 mb s3://ceph260bucket

aws --endpoint-url http://serverc \
	s3 ls

```

```bash
#* aws s3 cp help | grep acl
aws --endpoint-url http://serverc \
	s3 cp \
		--acl public-read-write \
		files/S3_file s3://ceph260bucket/my_S3_file

aws --endpoint-url http://serverc \
	s3 ls s3://ceph260bucket/

```

```bash
#*  'Object Gateway Guide' / <Ctrl-F> / dns
ceph config set client.rgw rgw_dns_name serverc
ceph orch restart rgw.ceph260_radosgw

curl http://serverc/ceph260bucket/my_S3_file
curl http://ceph260bucket.serverc/my_S3_file

```

```bash
# 配额
#* radosgw-admin -h | grep quota
radosgw-admin global quota set \
	--uid=Sunny \
	--quota-scope=user \
	--max-size=20971520
radosgw-admin global quota enable --quota-scope=user --uid=Sunny
ceph orch restart rgw.ceph260_radosgw

radosgw-admin quota set \
	--uid=Sunny \
	--quota-scope=bucket \
	--max-objects=100 \
	--max-size=10485760
radosgw-admin quota enable --quota-scope=bucket --uid=Sunny

```

```bash
radosgw-admin global quota get --uid Sunny

radosgw-admin user info --uid Sunny

```



## A. appendix

### A1. EX260 Exam Results

```ini
Passing score:          210
Your score:             240

Result: PASS

Congratulations -- you have earned the Red Hat Certified Specialist in Ceph Cloud Storage certification.

Performance on exam objectives:

	OBJECTIVE: SCORE
	Install Red Hat Ceph Storage Server: 100%
	Configure Red Hat Ceph Storage Server: 80%
	Provide block Storage with RBD: 100%
	Provide object Storage with RADOSGW: 33%
	Provide file Storage with CephFS: 50%
	Manage and update cluster maps: 100%
	Tuning Red Hat Ceph Storage: 100%
	Troubleshoot Red Hat Ceph Storage server problems: 100%
```

