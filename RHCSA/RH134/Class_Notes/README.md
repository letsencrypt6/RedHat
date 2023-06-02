| 第一天                     | 第二天               | 第三天              | 第四天                    |
| :------------------------- | -------------------- | :------------------ | ------------------------- |
| 1、提高命令行生产率        | 5、管理SELinux安全性 | 8、实施高级存储功能 | 11、管理网络安全firewalld |
| 2、计划将来的任务          | 6、管理基本存储      | 9、访问网络附加存储 | 12、安装rhel              |
| 3、调优系统性能            | 7、管理逻辑卷        | 10、控制启动过程    | 13、总复习                |
| 4、使用ACL控制对文件的访问 |                      |                     |                           |

# 第一章 提高命令行生产率

### 脚本：

| 系统    |                                  |      |
| ------- | -------------------------------- | ---- |
| Windows | *.bat,*.cmd,.vbd                 |      |
| Linux   | #！/bin/bash ,  chmod +x file.sh |      |

### \, '' , ""

```bash
echo $SHELL
echo \$SHELL
echo '$SHELL'
echo "$SHELL"
echo 'hello world'
echo 'hello world $SHELL'
echo "hello world $SHELL"

echo $HOSTNAME
ssh root@172.25.250.10 'touch /tmp/$HOSTNAME'
ssh root@172.25.250.10 'ls /tmp/'
ssh root@172.25.250.10 "touch /home/$HOSTNAME"
ssh root@172.25.250.10 'ls /home/'

```

### 基本用法

```bash
[root@foundation0 /]# cat /etc/shells 
/bin/sh
/bin/bash
/usr/bin/sh
/usr/bin/bash
/usr/bin/tmux
/bin/tmux
[root@foundation0 /]# echo $SHELL
/bin/bash

[root@foundation0 /]# vim first.sh
#!/bin/bash

echo hello world

[root@foundation0 /]# chmod +x first.sh 
[root@foundation0 /]# ll first.sh 
-rwxr-xr-x. 1 root root 30 Mar  8 09:34 first.sh
[root@foundation0 /]# ./first.sh 
hello world

[root@foundation0 /]# first.sh || echo no      
bash: first.sh: command not found...
Failed to search for file: Cannot update read-only repo
no

我们如何才能再任意路径下都可以执行一个脚本？
[root@foundation0 /]# echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
[root@foundation0 ~]# mkdir bin

[root@foundation0 ~]# mv /first.sh ./bin/
[root@foundation0 ~]# ls bin/
first.sh
[root@foundation0 ~]# cd bin/
[root@foundation0 bin]# pwd
/root/bin

[root@foundation0 bin]# first.sh 
hello world


[root@foundation0 bin]# sh first.sh 
hello world
[root@foundation0 bin]# bash first.sh 
hello world
[root@foundation0 bin]# source first.sh 
hello world
[root@foundation0 bin]# . first.sh    
hello world

```

### ``,$()

```bash
`命令`
$(命令)
whoami
echo whoami
echo `whoami`
echo $(whoami)
date
echo `date`
man date
date +%y%m%d
date +%Y%m%d
date +%Y-%m-%d
echo $(date +%Y-%m-%d)
touch $(date +%Y-%m-%d).txt
ls
tar -zcvf $(date +%Y-%m-%d).tar.gz /etc/
ls
cd /

既然可以通过``和$()的结果，通过echo来通过标准输出打印到屏幕上，那么我们也可以将其应用到脚本。
vim os.current
#!/bin/bash
  
echo -e "User:\t" $(whoami)
echo -e "HOST:\t" `hostname`
echo -e "ipv4:\t" $(ip a s enp1s0 | awk '/inet / {print $2}')
echo -e "Memory:\t" $(free -h | awk '/Mem/ {print $2}') 
echo -e "Disk:\t" $(df -ht xfs | awk '/dev/ {print $4}')

chmod +x os.current 
./os.current 
scp os.current root@servera:/
ssh root@servera

sh os.current
bash os.current
source os.current
. os.current


```

### for  * in ；do * ；done

```bash
[root@servera ~]# echo {1..10}
1 2 3 4 5 6 7 8 9 10
[root@servera ~]# echo $(seq 1 10)
1 2 3 4 5 6 7 8 9 10

[root@servera ~]# for i in host1 host2 host3;do echo $i;done
host1
host2
host3
[root@servera ~]# for i in host{1..3};do echo $i;done
host1
host2
host3


[root@servera ~]# echo ${HOSTNAME}O
servera.lab.example.comO
[root@servera ~]# echo $HOSTNAME\O
servera.lab.example.comO

vim user.sh
#!/bin/bash
for i in {1..10};do
        useradd user$i 2> /dev/null
        echo P@ssw0rd${i}a | passwd --stdin user$i
done


sh user.sh

```

### test, []

```bash
test 0 -ne 1 
   36  echo $?
   37  test 0 -ge 0 
   38  echo $?
   39  test 0 -ge 1 
   40  echo $?
   41  test 8 -gt 4
   42  echo $?
   43  [ 0 -ge 0 ]
   44  echo $?

-eq	等于则为真
-ne	不等于则为真
-gt	大于则为真
-lt	小于则为真
-ge	大于等于则为真
-le	小于等于则为真
```

### exit ,if  elif  else 

```bash
一、
vim tj.sh
#!/bin/bash
if [ 0 -ge 0 ];then
        echo ok
fi

二、
vim cjk.sh
#!/bin/bash
if [ -e /file1 ];then
        echo one
        exit 10
fi

三、
#!/bin/bash
if [ -e /file1 ];then
        echo one
        exit 10
else
        echo two
        exit 20
fi

四、
#!/bin/bash
if [ -e /file1 ];then
        echo one
        exit 10
elif [ -e /opt/file1 ];then
        echo two
        exit 20
else
        echo tree
        exit 30
fi


```

### $0，$1，$2..$9 ,$#

```bash
$0，$1，$2..$9 ,$# 
#!/bin/bash
  
ping -c $2 172.25.254.$1

echo '$0: ' $0
echo '$1: ' $1
echo '$2: ' $2
echo '$3: ' $3
echo '$#: ' $#

[root@servera ~]# chmod +x ping.sh
[root@servera ~]# ./ping.sh 254 5
PING 172.25.254.254 (172.25.254.254) 56(84) bytes of data.
64 bytes from 172.25.254.254: icmp_seq=1 ttl=63 time=3.02 ms
64 bytes from 172.25.254.254: icmp_seq=2 ttl=63 time=0.976 ms
64 bytes from 172.25.254.254: icmp_seq=3 ttl=63 time=1.03 ms
64 bytes from 172.25.254.254: icmp_seq=4 ttl=63 time=1.09 ms
64 bytes from 172.25.254.254: icmp_seq=5 ttl=63 time=2.16 ms

--- 172.25.254.254 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 12ms
rtt min/avg/max/mdev = 0.976/1.654/3.015/0.808 ms
$0:  ./ping.sh
$1:  254
$2:  5
$3: 
$#:  2

______

```

### grep,cut

```bash
grep root /etc/passwd
grep root /etc/passwd | cut  -d :  -f 1,3-5          
grep root /etc/passwd | cut -c 1,3-5                 
grep ^root /etc/passwd
grep nologin$ /etc/passwd
cat -n /etc/passwd									 
grep -n ^# /etc/selinux/config 	
vim /etc/selinux/config 
grep ^$ /etc/selinux/config 
grep ^$ /etc/selinux/config  | wc -l
grep -n ^$ /etc/selinux/config  
grep -v ^$ /etc/selinux/config 
grep ^# /etc/selinux/config 
grep -v ^# /etc/selinux/config 

（暂时不用）grep -v ^# /etc/selinux/config | grep -v ^$
cat /etc/selinux/config | grep -v ^# | grep -v ^$


[root@foundation0 /]# grep ng /usr/share/xml/iso-codes/iso_639_3.xml > /1.txt
[root@foundation0 /]# 
[root@foundation0 /]# 
[root@foundation0 /]# grep ^$ /1.txt
[root@foundation0 /]# grep ^$ /1.txt | wc -l
额外：
# grep -e root -e 0 /etc/passwd       grep -e可以在一个文件内单独匹配多个参数
root:x:0:0:root:/root:/bin/bash
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
# grep -E 'root|0' /etc/passwd

```

# 第二章 Linux计划任务

临时计划任务at

周期性计划任务cron



### at

```bash
[root@servera /]# rpm -qa at
at-3.1.20-11.el8.x86_64
[root@servera /]# systemctl status atd.service 

[root@servera /]# rpm -qc at
/etc/at.deny
/etc/pam.d/atd
/etc/sysconfig/atd

at 选项 参数

创建
[root@servera /]# at 13:49
warning: commands will be executed using /bin/sh
at> touch /at.txt
at> <EOT>          ctrl+d退出

3分钟后执行
echo "date" >> /home/student/myjob.txt | at now +3min

查看
[root@servera /]# atq
作业编号  执行日期和时间             队列a			运行作业所有者
7	     Sun Mar  8 13:51:00 2020 a         	 root
[root@servera /]# at -l

查看任务内容
[root@servera /]# at -c 7
删除
[root@servera /]# at -d 9
[root@servera /]# atrm 8

监控任务
[root@servera ~]# watch atq      ctrl+c 退出监控模式

```

### crontab

```bash
[root@servera /]# systemctl status crond.service 
[root@servera /]# systemctl  enable crond
[root@servera /]# systemctl is-enabled crond
[root@servera /]# systemctl enable --now crond


[root@servera /]# rpm -qa cron
[root@servera /]# rpm -qa | grep cron
cronie-anacron-1.5.2-2.el8.x86_64
cronie-1.5.2-2.el8.x86_64
crontabs-1.11-16.20150630git.el8.noarch


crontab 选项 
-e	编辑计划任务	crontab -e
-u	指定用户  crontab -u student -e
-r	删除
-l	列出

*       *       *       *       *       command
分		时     日 	 月       周		 任务内容
0-59    0-23   1-31    1-12    0-7

每年2月2日上午9点执行echo  hello
0       9       2       2       *       echo hello

每天3到6点2分 执行一个脚本/root/1.sh
2	3-6 *	*	* /bin/sh /root/1.sh

每两个小时的第2分钟，执行一个脚本/root/1.sh
2	*/2   *	*	*	 /bin/sh /root/1.sh

配置cron任务，每隔2分钟运行logger “Ex200 in progress”，以harry用户身份运行
[root@servera /]# crontab -u harry -e
[root@servera /]# crontab -u harry -l
*/2 	*	*	* 	*    /usr/bin/logger “Ex200 in progress” 

删除某条可以crontab -e 进去编辑
删除用户的所有任务
crontab -r 	

 vim /etc/cron.deny  限制用户使用crond服务
```

### 管理临时文件

rhel6 tmpwatch

systemd-tmpfiles

```bash
[root@servera /]# systemctl status systemd-tmpfiles-setup
[root@servera /]# rpm -qf /usr/lib/tmpfiles.d/tmp.conf 
systemd-239-13.el8.x86_64

cp /usr/lib/tmpfiles.d/tmp.conf /etc/tmpfiles.d/
cd /etc/tmpfiles.d/
vim tmp.conf
q /tmp 1777 root root 5d
systemd-tmpfiles --clean /etc/tmpfiles.d/tmp.conf 



清理临时文件
[root@servera /]# vim /etc/tmpfiles.d/momentary.conf
d /run/momentary 0700 root root 30s
[root@servera /]# systemd-tmpfiles --create /etc/tmpfiles.d/momentary.conf 
[root@servera /]# ll /run/momentary/ -d
drwx------. 2 root root 40 Mar  8 15:08 /run/momentary/
[root@servera /]# touch /run/momentary/mom.txt
[root@servera /]# sleep 30
[root@servera /]# ll /run/momentary/mom.txt 
-rw-r--r--. 1 root root 0 Mar  8 15:08 /run/momentary/mom.txt
[root@servera /]# systemd-tmpfiles --clean /etc/tmpfiles.d/momentary.conf 
[root@servera /]# ll /run/momentary/mom.txt 
ls: cannot access '/run/momentary/mom.txt': No such file or directory


对tmp做一些临时文件管理，设置临时文件管理时间
cp /usr/lib/tmpfiles.d/tmp.conf /etc/tmpfiles.d/
q /tmp 1777 root root 5d
[root@servera /]# systemd-tmpfiles --clean /etc/tmpfiles.d/tmp.conf
```

# 第三章 系统性能调优

### tuned 

```bash
tuned 
[root@servera tmp]# yum install -y tuned
[root@servera tmp]# systemctl status tuned

[root@servera tmp]# systemctl enable --now tuned
[root@servera tmp]# systemctl is-enabled tuned
enabled
查看
[root@servera tmp]# tuned-adm list
[root@servera tmp]# tuned-adm recommend   查看系统推荐的
[root@servera tmp]# tuned-adm profile virtual-guest 修改优化方案为virtual-guest
[root@servera tmp]# tuned-adm off 关闭优化



练习：修改为系统推荐的优化方案
[root@servera tmp]# tuned-adm recommend   查看系统推荐的
virtual-guest
[root@servera tmp]# tuned-adm profile virtual-guest 
[root@servera tmp]# tuned-adm active 
Current active profile: virtual-guest

方法二：
可以通过驾驶舱--导航栏--系统--Performance Profile 修改--修改后点 change profile

```

# 第四章 ACL访问控制列表

### setfacl，getfacl

```bash
查看文件是否设置了acl
[root@servera /]# ll os.current 
-rwxrwxr-x+ 1 root root 246 Mar  8 10:14 os.current    有+加号

选项
-m 设置后面的acl权限给文件（目录）使用
-x 删除acl，某条
-b 删除所有
-R  递归

acl可以针对：
user
group
mask


-m
设置
[root@servera /]# setfacl -m u:harry:rwx os.current 
[root@servera /]# 
[root@servera /]# ll os.current 
[root@servera /]# setfacl -m u:lisa:--- os.current
-rwxrwxrwx+ 1 root root 246 Mar  8 10:14 os.current
查看
[root@servera /]# getfacl os.current 
# file: os.current
# owner: root
# group: root
user::rwx
user:harry:rwx
user:lisa:---
group::r-x
mask::rwx
other::r-x


[root@servera /]# setfacl -m g:east:rwx acltest.txt 
[root@servera /]# setfacl -m m:rw- acltest.txt 
[root@servera /]# getfacl acltest.txt 
# file: acltest.txt
# owner: root
# group: root
user::rw-
group::r--
group:east:rwx			#effective:rw-
mask::rw-
other::r--

user和group权限只有和mask权限重叠时才生效


-x

[root@servera /]# setfacl -x g:east acltest.txt 
[root@servera /]# setfacl -x m: acltest.txt 
[root@servera /]# setfacl -x u:harry os.current 
[root@servera /]# getfacl os.current 
# file: os.current
# owner: root
# group: root
user::rwx
user:lisa:---
group::r-x
mask::r-x
other::r-x

-b
[root@servera /]# setfacl -b os.current


-R ，-Rb
[root@servera opt]# mkdir acldir
[root@servera opt]# touch acldir/acl.txt
[root@servera opt]# ls acldir/
acl.txt
[root@servera opt]# setfacl -Rm u:harry:rwx acldir/
[root@servera opt]# getfacl -R acldir/
# file: acldir/
# owner: root
# group: root
user::rwx
user:harry:rwx
group::r-x
mask::rwx
other::r-x

# file: acldir//acl.txt
# owner: root
# group: root
user::rw-
user:harry:rwx
group::r--
mask::rwx
other::r--

[root@servera opt]# setfacl -Rb acldir/
[root@servera opt]# getfacl -R acldir/
# file: acldir/
# owner: root
# group: root
user::rwx
group::r-x
other::r-x

# file: acldir//acl.txt
# owner: root
# group: root
user::rw-
group::r--
other::r--

ACL备份及恢复
setfacl -Rm u:harry:rwx acldir/
getfacl -R acldir/
getfacl -R acldir/ > /acl.bak   将权限备份到/acl.bak文件中
setfacl -Rb acldir/    清除，模拟丢失
getfacl -R acldir/    此时没有权限
setfacl --restore /acl.bak  恢复
getfacl -R acldir/   再查看权限已经恢复




练习：
配置 /var/tmp/fstab 权限
[root@servera /]# cp /etc/fstab /var/tmp
[root@servera /]# ll /var/tmp/fstab 
-rw-r--r--. 1 root root 427 Mar  8 16:40 /var/tmp/fstab
[root@servera /]# id natasha
id: ‘natasha’: no such user
[root@servera /]# id harry
uid=1014(harry) gid=1014(harry) groups=1014(harry)
[root@servera /]# useradd natasha
[root@servera /]# 
[root@servera /]# setfacl -m u:natasha:rw /var/tmp/fstab 
[root@servera /]# setfacl -m u:harry:--- /var/tmp/fstab 
[root@servera /]# getfacl /var/tmp/fstab 
getfacl: Removing leading '/' from absolute path names
# file: var/tmp/fstab
# owner: root
# group: root
user::rw-
user:harry:---
user:natasha:rw-
group::r--
mask::rw-
other::r--

```

# 第五章 管理SELinux

|  ID  |            |                         | SELinux                                                      |
| :--: | ---------- | ----------------------- | ------------------------------------------------------------ |
|  1   | Filesystem | chmod, chown, setfacl   | semanage fcontext ... restorecon ... chcon ... touch /.autorelabel |
|  2   | Service    | vim /etc/*.conf         | setsebool -P ...                                             |
|  3   | Firewall   | firewall-cmd ...        | semanage port ...                                            |
|  4   | SELinux    | vim /etc/selinux/config |                                                              |

### 临时开启或关闭selinux

```bash
[root@servera ~]# setenforce   设置
usage:  setenforce [ Enforcing | Permissive | 1 | 0 ]
[root@servera ~]# setenforce 1
[root@servera ~]# getenforce  查看
Enforcing

```

### 永久开启或关闭selinux状态

```bash
[root@servera ~]# vim /etc/selinux/config
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=enforcing

修改后，重启生效
```

继承特性

继承：在父目录下创建文件会继承selinux上下文touch

cp 

不继承：

创建了文件并且移动mv，会保留原来的父目录上下文关系

复制时cp  -a ，也会保留之前的上下文关系

```bash
[root@servera html]# echo webserver > index.html
[root@servera html]# ls
index.html
[root@servera html]# pwd
/var/www/html
[root@servera html]# ls -Z .
unconfined_u:object_r:httpd_sys_content_t:s0 index.html
[root@servera html]# ls -Z index.html 
unconfined_u:object_r:httpd_sys_content_t:s0 index.html
实验：查看上下文的继承关系
[root@servera html]# ls -Z /tmp/
system_u:object_r:tmp_t:s0 NIC1      
system_u:object_r:tmp_t:s0 rht-bastion
[root@servera html]# touch /tmp/file{1,2,3}
[root@servera html]# ls -Z /tmp/file*
unconfined_u:object_r:user_tmp_t:s0 /tmp/file1  unconfined_u:object_r:user_tmp_t:s0 /tmp/file2  unconfined_u:object_r:user_tmp_t:s0 /tmp/file3
[root@servera html]# cp /tmp/file1 /var/www/html/
[root@servera html]# mv /tmp/file2 /var/www/html/
[root@servera html]# cp -a /tmp/file3 /var/www/html/
[root@servera html]# cd /var/www/html/
[root@servera html]# ls
file1  file2  file3  index.html
[root@servera html]# ls -Z file*
unconfined_u:object_r:httpd_sys_content_t:s0 file1           unconfined_u:object_r:user_tmp_t:s0 file3
unconfined_u:object_r:user_tmp_t:s0 file2

```

### 定义selinux默认文件上下文规则

semanage fcontext 显示、修改上下文

restorecon 设置默认上下文

（/.*）? 表示匹配后跟任何数量的/。相当于递归到下级目录。

chcon 设置上下文关系

```bash
semanage fcontext 
-a 	添加
-d	删除
-l	查看
-t	指定上下文
-m  修改

restorecon
-v  显示修改标签内容
-R  递归

[root@servera html]# semanage fcontext -l | grep /var/www
[root@servera html]# cd /var/www/html/
[root@servera html]# ls
file1  file2  file3  index.html
[root@servera html]# ll -Z file*
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0 Mar 14 01:32 file1
-rw-r--r--. 1 root root unconfined_u:object_r:user_tmp_t:s0          0 Mar 14 01:31 file2
-rw-r--r--. 1 root root unconfined_u:object_r:user_tmp_t:s0          0 Mar 14 01:31 file3
[root@servera html]# restorecon -Rv /var/www/html/
Relabeled /var/www/html/file2 from unconfined_u:object_r:user_tmp_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /var/www/html/file3 from unconfined_u:object_r:user_tmp_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0

$chcon
touch /tmp/tmpfile
mv /tmp/tmpfile /var/www/html/
ls -Z
chcon -t httpd_sys_content_t tmpfile 
ls -Z

$chcon和restorecon 哪个更优先？
chcon -t user_tmp_t /var/www/html/tmpfile 
ls -Z
restorecon -Rv /var/www/html/


设置默认上下文
[root@servera /]# mkdir /setest
[root@servera /]# ls -Zd /setest/
unconfined_u:object_r:default_tefault_t:s0 /setest/
root@servera /]# semanage fcontext -a -t httpd_sys_content_t "/setest(/.*)?"  添加，并指定默认上下文
[root@servera /]# restorecon -Rv /setest      修改默认上下文
Relabeled /setest from unconfined_u:object_r:default_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
修改该某一条上下文规则
[root@servera html]# chcon -t default_t index.html



修改上下方式两种
1、chcon    文件、目录


2、semanage fcontext {-a|-m} -t 上下文类型       文件、目录 
   restorecon -Rv


希望可以通过web服务访问到index.html内容

1、http://172.25.250.10
2、apache服务是否打开？防火墙是否允许了http协议？selinux是否打开？
```

### 使用布尔值调整

```bash
getsebool 		列出布尔值状态  user
setsebool -P	更改布尔值永久生效
semanage boolean -l 查看布尔值是否永久

selinux-policy-doc 
[root@servera /]# yum install -y selinux-policy-doc
[root@servera /]# mandb
[root@servera /]# man -k '_selinux' | grep httpd
[root@servera /]# man 8 httpd_selinux
[root@servera /]# getsebool -a

修改布尔值状态
[root@servera /]# setsebool httpd_enable_homedirs on
[root@servera /]# setsebool httpd_enable_homedirs off
[root@servera /]# semanage boolean -l  | grep httpd_enable_home
httpd_enable_homedirs          (off  ,  off)  Allow httpd to enable homedirs
[root@servera /]# setsebool -P httpd_enable_homedirs on  永久生效
[root@servera /]# semanage boolean -l  | grep httpd_enable_home
httpd_enable_homedirs          (on   ,   on)  Allow httpd to enable homedirs


用户可以通过web访问servera的studnet用户家目录中的网页
1、安装apache
2、开启apache访问普通用户家目录的功能 
[root@servera /]# vim /etc/httpd/conf.d/userdir.conf
#UserDir disabled
UserDir public_html
[root@servera /]# systemctl restart httpd   （重启服务生效配置文件，如果不能重启开启bool值相应功能后才可重启服务）
3、创建普通用户发布目录和权限
[root@servera student]# mkdir /home/student/public_html
[root@servera home]# chmod 711 student/
[root@servera student]# ll -d /home/student/
drwx--x--x. 3 student student 102 Mar 16 23:59 /home/student/
[root@servera student]# chown student:student public_html/
[root@servera student]# ll -d public_html/
[root@servera student]#  chmod 775 public_html
drwxrwxr-x. 2 student student 6 Mar 14 02:46 public_html/
[root@servera student]# su - student
[student@servera ~]$ ls
public_html
[student@servera ~]$ cd public_html/
[student@servera public_html]$ echo studentserver > index.html
[student@servera public_html]$ cat index.html 
studentserver
[student@servera public_html]$ ll index.html 
-rw-rw-r--. 1 student student 14 Mar 14 02:48 index.html
4、打开布尔值
[root@servera home]# setsebool -P httpd_enable_homedirs on
5、打开防火墙
[root@servera home]# firewall-cmd --permanent --add-service=http
success
[root@servera home]# firewall-cmd --reload
success
[root@servera home]# firewall-cmd --list-all
6、http：//172.25.250.10/~student/index.html


练习：
希望用户可以通过8090 端口访问apache服务中的默认索引页
1、配置selinux允许8090端口
[root@servera html]# man semanage
[root@servera html]# man 8 semanage-port
[root@servera html]# semanage port -a -t http_port_t -p tcp 8090
[root@servera html]# semanage port -l | grep http_port_t
2、安装apache，修改配置文件，添加默认监听端口8090
[root@servera html]# vim /etc/httpd/conf/httpd.conf 
Listen 8090
[root@servera html]# systemctl restart httpd
3、允许防火墙
[root@servera html]# firewall-cmd --permanent --add-service=http
[root@servera html]# firewall-cmd --permanent --add-port=8090/tcp
[root@servera html]# firewall-cmd --reload
success
[root@servera html]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp1s0
  sources: 
  services: cockpit dhcpv6-client http ssh
  ports: 8090/tcp
  
  4、浏览器访问
  http://172.25.250.10:8090

```

# 第六章 管理基本存储

|    0     | mbr  |     dpt     |      |
| :------: | :--: | :---------: | :--: |
| 512 Byte | 446  |     64      |  2   |
|          |      | Primary<=4  |      |
|          |      |  Extend<=1  |      |
|          |      | Logical<=14 |      |

|  ID  |              | Count | Size |           |      |
| :--: | ------------ | ----- | ---- | --------- | ---- |
|  1   | mbr \| msdos | 15    | 2TB  | 3P+1E(nL) | 4P   |
|  2   | gpt          | 128   | 8ZB  | P         |      |

|  ID  |        |       Windows       |                            Linux                             |    MacOS     |
| :--: | ------ | :-----------------: | :----------------------------------------------------------: | :----------: |
|  1   | local  | ntfs, fat32,  exfat | xfs, ext4 \| swap [exfat](https://centos.pkgs.org/8/rpmfusion-free-updates-x86_64/) | apfs,  exfat |
|  2   | remote |      cifs, nfs      |                                                              |              |

### fdisk

```bash
fdisk -l 查看所有磁盘状态
fdisk  -l /dev/vdb  
#fdisk /dev/vdb
n
p
1
回车，不通过扇区范围分配
+1G  设置一个1G大小分区
p  查看分区状态

d 删除
w  保存退出

#partprobe    磁盘分区正常结束后，此命令可以正常执行
```

### parted

```bash
切换mbr及gpt分区方案方法：
parted /dev/vdc mklabel msdos
parted /dev/vdc print
parted /dev/vdc mklabel gpt
parted /dev/vdc print



mbr方式
[root@servera /]# parted /dev/vdc 
(parted) mklabel                                                          
New disk label type? msdos                                                
Number  Start  End  Size  Type  File system  Flags
(parted) mkpart                                                           
Partition type?  primary/extended? p                                      
File system type?  [ext2]? ext4
Start? 2048s                                                              
End? 1000MB                                                               
(parted) p                                                                
Model: Virtio Block Device (virtblk)
Disk /dev/vdc: 5369MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start   End     Size   Type     File system  Flags
 1      1049kB  1000MB  999MB  primary  ext4         lba

(parted) quit                                                             
Information: You may need to update /etc/fstab.
[root@servera ~]# udevadm  settle 
命令：
[root@servera /]# parted /dev/vdc mkpart p ext4 1000MB 2000MB



gpt方式：
[root@servera /]# parted /dev/vdd
(parted) mklabel gpt   
(parted) mkpart                                                           
Partition name?  []? part1
File system type?  [ext2]? xfs                                            
Start? 2048s                                                              
End? 1000MB                                                               
(parted) p                                                                
Model: Virtio Block Device (virtblk)
Disk /dev/vdd: 5369MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size   File system  Name   Flags
 1      1049kB  1000MB  999MB  xfs          part1

(parted) quit     
[root@servera ~]# udevadm  settle 
命令：
[root@servera /]# parted /dev/vdd mkpart part2 xfs 1000MB 2000MB


查看文件系统
lsblk  --fs /dev/vdc
blkid

格式化：
[root@servera /]# mkfs -t ext4 /dev/vdc1 	
[root@servera /]# mkfs.xfs /dev/vdc2
[root@servera /]# lsblk --fs /dev/vdc
NAME   FSTYPE LABEL UUID                                 MOUNTPOINT
vdc                                                      
├─vdc1 ext4         af656cc6-80e3-4b05-abcf-a162907c2f0a 
└─vdc2 xfs          64237913-4937-48ff-8afa-28c6fc05124d 
[root@servera /]# parted /dev/vdc p
Model: Virtio Block Device (virtblk)
Disk /dev/vdc: 5369MB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags: 

Number  Start   End     Size   Type     File system  Flags
 1      1049kB  1000MB  999MB  primary  ext4
 2      1000MB  2000MB  999MB  primary  xfs
```

### 挂载

```bash
mount  临时
[root@servera /]# mkdir /mnt/dir1
[root@servera /]# mkdir /mnt/dir2
[root@servera /]# mount /dev/vdc1 /mnt/dir1
[root@servera /]# mount /dev/vdc2 /mnt/dir2
[root@servera /]# df -h
[root@servera /]# umount /mnt/dir2

使用UUID方式挂载
root@serverb ~]# blkid /dev/vdb2
/dev/vdb2: UUID="f131c11b-0aaf-4f1f-8b4c-39787333b203" TYPE="xfs" 
[root@serverb ~]# mount UUID="f131c11b-0aaf-4f1f-8b4c-39787333b203" /mnt/disk2


开机自动挂载   永久
 /etc/fstab
#vim /etc/fstab
/dev/vdc1 /mnt/dir1 ext4  defaults 0 0
UUID=64237913-4937-48ff-8afa-28c6fc05124d  /mnt/dir2 xfs defaults 0 0

设备ID或设备名称	 挂载点	文件系统类型   权限   内核日志检测机制0不检测  磁盘检测机制0不检测
#mount -a
#df  -h
#reboot

创建swap 
[root@servera ~]# parted /dev/vdd mkpart backup xfs 2000MB 3000MB
[root@servera ~]# parted /dev/vdd p
Model: Virtio Block Device (virtblk)
Disk /dev/vdd: 5369MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name    Flags
 1      1049kB  1000MB  999MB                part1
 2      1000MB  2000MB  999MB                part2
 3      2000MB  3000MB  1000MB               backup

[root@servera ~]# mkswap /dev/vdd3
[root@servera ~]# swapon /dev/vdd3
[root@servera ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:           1829         173        1464          24         190        1488
Swap:           953           0         953
[root@servera ~]# swapoff /dev/vdd3
[root@servera ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:           1829         172        1465          24         190        1488
Swap:             0           0           0

开机自动加载swap
[root@servera ~]# vim /etc/fstab 
/dev/vdd3 swap swap defaults 0 0
[root@servera ~]# swapon -a
[root@servera ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:           1829         173        1464          24         190        1488
Swap:           953           0         953

#reboot重启验证



例题：
添加一个1G交换分区，并且重启系统依然有效。不能更改原来的swap分区（系统默认已经有了500M）
free -m
swap  500

创建swap
格式化swap
vim /etc/fstab

结果：
free -m  
1500

```

# 第七章 逻辑卷管理

PV

VG

PE

LV

逻辑卷管理

```bash
创建逻辑卷
分区或者添加物理硬盘---pv让物理磁盘或分区变成lvm可用的卷--创建vg同时指定pe块大小----在vg中划分lv空间---格式化lv空间---挂载或者永久挂载。

Disk /dev/vdb: 5 GiB, 5368709120 bytes, 10485760 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x0be8a7fd

Device     Boot   Start      End Sectors Size Id Type
/dev/vdb1          2048  2099199 2097152   1G 83 Linux
/dev/vdb2       4196352 10485759 6289408   3G  5 Extended
/dev/vdb3       2099200  4196351 2097152   1G 83 Linux
/dev/vdb5       4198400  6295551 2097152   1G 83 Linux

# pvcreate /dev/vdb{1,3,5}
# pvscan   或者  pvdisplay

# vgcreate -s 16M myvg /dev/vdb1 /dev/vdb3    
# vgdisplay 

# lvcreate -L 1G -n mylv myvg
# lvdisplay 

# mkfs.xfs /dev/myvg/mylv 
# lsblk --fs /dev/myvg/mylv

# mkdir /mnt/lvm
# mount /dev/myvg/mylv /mnt/lvm
# df -h
# cd /mnt/lvm/

永久挂载
vim /etc/fstab
/dev/myvg/mylv  /mnt/lvm  xfs defaults 0 0 
[root@servera /]# mount -a

reboot重启验证

删除逻辑卷思路：
创建顺序---分区--lv（pv-vg-lv）--格式化---挂载
卸载顺序---卸载--删lv--删vg--删pv--删分区
vgremove vg00

```

扩展逻辑卷

```bash
扩展流程：
1、扩展lv大小 -L +100M 容量   , -l +40  PE数量
2、将其生效：ext 文件系统 ”resize2fs 设备名“ ，xfs 文件系统   “xfs_growfs 挂载点”

需求，目前vg=2G，lv=1G，想把lv扩展到2.5G
添加PV 
已经添加了/dev/vdb5,如果没添加可以使用：[root@servera /]# pvcreate /dev/vdb5
扩展vg
先创建pv /dev/vdb5
[root@servera /]# man vgextend 
[root@servera /]# vgextend myvg /dev/vdb5
  Volume group "myvg" successfully extended
[root@servera /]# vgdisplay 

扩展lv
[root@servera /]# lvextend -L +1500M /dev/myvg/mylv 或者lvextend -L 2500M /dev/myvg/mylv
[root@servera /]# df -h

如果是xfs文件系统使用：
[root@servera /]# xfs_growfs /mnt/lvm (挂载点)
[root@servera /]# df -h

如果是ext4文件系统使用：
[root@servera /]# resize2fs /dev/myvg/mylv （lv设备名）






$缩小lv:ext文件系统可以缩小，xfs不支持
1、卸载
2、resize2fs 定义缩小后的大小
3、磁盘检测
4、lvresize -L 1G 逻辑卷名

# umount /dev/myvg/mylv
# resize2fs /dev/myvg/mylv 1G
# e2fsck -f /dev/myvg/mylv
# resize2fs /dev/myvg/mylv 1G
# lvdisplay 
# lvresize -L 1G /dev/myvg/mylv
# lvdisplay
```

# 第八章 实施高级存储功能

### stratis 本地存储管理系统多个存储层

### 使用VDO压缩存储设备上的数据并进行重复删除、以优化存储空间使用 



stratis

```bash
# yum install -y stratis-cli stratisd
# systemctl enable --now stratisd

[root@servera ~]# fdisk -l /dev/vdb
Disk /dev/vdb: 5 GiB, 5368709120 bytes, 10485760 sectors
Device     Boot   Start     End Sectors Size Id Type
/dev/vdb1          2048 2099199 2097152   1G 83 Linux
/dev/vdb2       2099200 4196351 2097152   1G 83 Linux

[root@servera ~]# stratis pool create pool1 /dev/vdb1
[root@servera ~]# stratis pool list
[root@servera ~]# stratis blockdev list
[root@servera ~]# stratis pool add-data pool1 /dev/vdb2
[root@servera ~]# stratis pool list
Name     Total Physical Size  Total Physical Used
pool1                  2 GiB               56 MiB
[root@servera ~]# stratis blockdev list
Pool Name  Device Node    Physical Size   State  Tier
pool1      /dev/vdb1              1 GiB  In-use  Data
pool1      /dev/vdb2              1 GiB  In-use  Data

创建文件系统
[root@servera ~]# stratis filesystem create pool1 filesystem1
[root@servera ~]# 
[root@servera ~]# stratis filesystem list 
Pool Name  Name         Used     Created            Device                      UUID                         
pool1      filesystem1  546 MiB  Mar 16 2020 21:47  /stratis/pool1/filesystem1  6d1ed6e714a6428eb374549b4fdd8d2b  
[root@servera ~]# mkdir /mnt/stratisvol
[root@servera ~]# mount /stratis/pool1/filesystem1 /mnt/stratisvol/



备份：
创建测试文件

[root@servera /]# cd /mnt/stratisvol/
[root@servera stratisvol]# dd if=/dev/zero of=myfile bs=1M count=100
[root@servera stratisvol]# du -sh myfile 
备份
[root@servera /]# stratis filesystem snapshot pool1 filesystem1 filesystembak1
模拟故障
[root@servera /]# cd /mnt/stratisvol/
[root@servera stratisvol]# ls
file1  myfile
[root@servera stratisvol]# rm -f *
[root@servera stratisvol]# cd /
[root@servera /]# umount /mnt/stratisvol
恢复
[root@servera /]# mkdir /mnt/stratisvolbak
[root@servera /]# mount /stratis/pool1/filesystembak1 /mnt/stratisvolbak/



开机自动启动：
vim /etc/fstab
/stratis/pool1/filesystembak1 /mnt/stratisvolbak/ xfs _netdev 0 0
mount -a
```

VDO

```bash
yum install -y vdo kmod-kvdo
systemctl enable --now vdo 

man vdo
vdo create --name=vdo0 --device=/dev/vdb --vdoLogicalSize=50G
vdo start  --name=vdo0
vdo stop  --name=vdo0
vdo status --name=vdo0
mkfs.xfs -K /dev/mapper/vdo0 
vdo list

mkdir /mnt/vdo0
mount /dev/mapper/vdo0 /mnt/vdo0/
df -h

man vdostats
vdostats --human-readable


cd /mnt/vdo0/
ls
dd if=/dev/zero of=./bigfile bs=400M count=1

du -sh /mnt/vdo0/bigfile
vdostats --human-readable
blkid


开机自动挂载
du -sh
umount /mnt/vdo0
systemctl status vdo.service 
vim /etc/fstab 
/dev/mapper/vdo0 /mnt/vdo0 xfs _netdev 0 0


mount -a
```

# 第九章 访问网络存储

NFS 网络文件系统

- mount

- vim /etc/fstab

- autofs

- nfsconf

  ```bash
  【foundation】
  root@foundation0 ~]# systemctl status nfs-server.service 
  [root@foundation0 ~]# vim /etc/exports
  /content    172.25.0.0/255.255.0.0(ro,sync,crossmnt)
  共享目录	  允许访问的网段           权限
  [root@foundation0 ~]# showmount -e localhost
  Export list for foundation0.ilt.example.com:
  /content 172.25.0.0/255.255.0.0
  
  【servera】
  [root@servera ~]# ping 172.25.254.250
  [root@servera ~]# showmount -e 172.25.254.250
  Export list for 172.25.254.250:
  /content 172.25.0.0/255.255.0.0
  [root@servera ~]# mkdir /mnt/nfs/
  [root@servera ~]# mount 172.25.254.250:/content /mnt/nfs/
  
  开机自动挂载
  [root@servera ~]# umount /mnt/nfs
  [root@servera ~]# vim /etc/fstab
  172.25.254.250:/content/ /mnt/nfs/  nfs defaults 0 0
  [root@servera ~]# mount -a
  [root@servera ~]# df -h
  [root@servera ~]# reboot  （重启后使用df -h查看挂载状态）
  
  【servera】
  autofs
  yum install -y autofs
  systemctl status autofs
  systemctl enable --now autofs
  systemctl status autofs
  systemctl is-enabled autofs
  
  [root@servera ~]# rpm -qa | grep autofs
  libsss_autofs-2.0.0-43.el8.x86_64
  autofs-5.1.4-29.el8.x86_64
  [root@servera ~]# 
  [root@servera ~]# rpm -qc autofs 
  /etc/auto.master
  /etc/auto.misc
  
  [root@servera ~]# vim /etc/auto.master
  /mnt    /etc/auto.misc
  [root@servera ~]# vim /etc/auto.misc
  dir1            -fstype=nfs      172.25.254.250:/content
  
  [root@servera ~]# systemctl restart autofs
  [root@servera ~]# cd /mnt/dir1
  [root@servera dir1]# df -h
  172.25.254.250:/content  491G   40G  451G   9% /mnt/dir  不和/etc/fstab一起用
  
  ```
  
  # 第十章 启动流程

```
  vim /etc/systemd/system/default.target
  systemctl cat default.target 
  systemctl list-dependencies 
  systemctl list-dependencies | grep target
  systemctl list-dependencies graphical.target
  
  systemctl get-default 
  syetemctl set-default  multi-user.target
  
  
  启动时选择其他目标
  reboot
  e
  linux.....<end> systemd.unit=graphical.target    或multi-user.target
  ctrl+x
  
  
  [root@workstation ~]# systemctl isolate multi-user.target 
  [root@workstation ~]# systemctl isolate graphical.target
  
  注意：如果安装了图形，启动后需要执行startx
  
  
  
  
  
  修改登录密码
  reboot
  e
  linux.....<end> rd.break console=tty0
  ctrl+x
mount -o remount,rw /sysroot/
  chroot /sysroot
echo mima | passwd --stdin root
  touch /.autorelabel
  exit
  exit
  
  
  
  
```

  # 练习环境

  ```bash
更新：
  1、恢复init
  2、添加镜像	
  [kiosk@foundation0 opt]$ whoami
  kiosk
  [kiosk@foundation0 opt]$ df -h
  /dev/sr0         82K   82K     0 100% /run/media/kiosk/20191229_164114
  3、
  su - root
  [root@foundation0 opt]# cp /run/media/kiosk/20191229_164114/ex200v8-1.3.0-191229.x86_64.rpm /opt/
  su - kiosk
  [kiosk@foundation0 20191229_164114]$ ssh root@localhost 'yum install -y /opt/ex200v8-1.3.0-191229.x86_64.rpm'
  
  布置环境：
  先执行exam-setup--做题---做完执行exam-grade收题
  exam-setup
  exam-grade      
    
  
  
  
  ```

#   第十一章 firewalld

  ```bash
   systemctl status firewalld
   systemctl enable --now firewalld
   
  firewall-cmd --get-default-zone 
  firewall-cmd --list-all
  man 5 firewalld.zones
  firewall-cmd --get-zones
  
  
  man firewall-cmd
  /Ex
  firewall-cmd -- 
  firewall-cmd --get-zones
  firewall-cmd --get-default-zone 
  firewall-cmd --set-default-zone=public
  firewall-cmd --get-default-zone 
  firewall-cmd --list-all
  
  firewall-cmd --get-service
  
  
  firewall-cmd --add-source=172.25.250.100 --zone=trusted --permanent
  firewall-cmd --reload
  
  firewall-cmd --add-interface=enp2s0 --zone=trusted --permanent
  firewall-cmd --reload
  
  ```

  允许服务及端口

  ```bash
  【servera】
  yum install -y httpd
  rpm -qc httpd
  setenforce 0
  rpm -ql httpd
  cd /var/www/html/
  echo "webservera" > index.html
  systemctl enable --now httpd
  
  firewall-cmd --permanent --add-service=http
  firewall-cmd --reload
  firewall-cmd --list-all
  【serverb： curl http://servera】
  
  vim /etc/services 
  netstat -ntlp | grep 80
  lsof -i:80
  
  firewall-cmd --info-service=http
  vim /etc/httpd/conf/httpd.conf 
  Listen 80 改成了Listen 82
  
  systemctl restart httpd
  netstat -ntlp | grep 82
  lsof -i:82
  firewall-cmd --permanent --add-port=82/tcp
  firewall-cmd --reload
  firewall-cmd --list-all
  【serverb： curl http://servera:82】
  
  lsof -i：80	
  ```

  2 、通过管理selinux标签来控网络服务，允许特定端口

  ```bash
  [servera]
  setenforce 1
  systemctl status httpd
  vim /etc/httpd/conf/httpd.conf 
  Listen 80 改成了Listen 8899
  systemctl restart httpd   重启不了，因为selinux
  semanage port -l | grep http
  man semanage port
  /example
  semanage port -a -t http_port_t -p tcp 8899
  semanage port -l | grep http
  
  systemctl restart httpd
  systemctl enable httpd
  systemctl enable --now httpd
  
  firewall-cmd --permanent --add-port=8899/tcp
  firewall-cmd --reload
  firewall-cmd --list-all
  
 
  
  【test case】
  [serverb curl http://servea:8899] 
  
  mars.domain10.example.com:8899
  mars:82   172.25.250.100
  172.25.250.100:82
  
  
  富规则参考
  man 5 firewalld.richlanguage
  ```

  test

  ```
  vsftp
  samba
  nfs
  dhcp
  ```

  

# 第 十二 章 kickstart

在workstation上面做服务器端，servera做客户端，务必使用rh124环境

cd 

iso

网络安装



```bash
systemctl stop firewalld;setenforce 0
【workstation】 server
一、dhcp
yum search dhcp
yum install -y dhcp-server
rpm -ql dhcp-server
vim /etc/dhcp/dhcpd.conf 
cp /usr/share/doc/dhcp-server/dhcpd.conf.example /etc/dhcp/dhcpd.conf
man 5 dhcpd.conf
/next-server
vim /etc/dhcp/dhcpd.conf
allow bootp;
allow booting;
subnet 172.25.250.0 netmask 255.255.255.0 {
  range 172.25.250.26 172.25.250.30;
  option routers 172.25.250.254;
  default-lease-time 600;
  max-lease-time 7200;
  filename "/pxelinux.0";
  next-server 172.25.250.9;
}

systemctl enable --now dhcpd
测试dhcp功能
设置servera开机启动为网卡，测试能够获取ip即可

二、tftp and syslinux
yum search tftp
yum install -y tftp-server
rpm -ql tftp-server


yum install -y syslinux-tftpboot.noarch
rpm -ql syslinunx-tftpboot
cd tftpboot/
mkdir /tftpboot/pxelinux.cfg/

mkdir /content
mount 172.25.254.250:/content /content/
df -h
cd /content/rhel8.0/x86_64/dvd/
cp isolinux/isolinux.cfg /tftpboot/pxelinux.cfg/default
cp isolinux/{boot.msg,vesamenu.c32} /tftpboot/
cp images/pxeboot/{initrd.img,vmlinuz} /tftpboot/
vim default 
default `vesamenu.c32` (反引号告诉大家是需要关注的点)
timeout 600
display `boot.msg`

label linux
  menu label ^Install Red Hat Enterprise Linux 8.0.0
  menu `default`
  kernel `vmlinuz`
  append initrd=`initrd.img` inst.stage2=`ftp://172.25.250.9/dvd` quiet

vim /usr/lib/systemd/system/tftp.service 
[Service]
ExecStart=/usr/sbin/in.tftpd -s /tftpboot  (将-s /var/lib/tftpboot，更成-s /tftpboot)

systemctl enable --now tftp
测试：
登录serverb，yum install -y tftp ,tftp 172.25.250.9,get ls.c32 quit


三、ftp
yum install -y vsftpd.x86_64 
rpm -qc vsftpd
vim /etc/vsftpd/vsftpd.conf 
anonymous_enable=YES
anon_root=/var/ftp
mkdir /var/ftp/dvd
mount /content/rhel8.0/x86_64/isos/rhel-8.0-x86_64-dvd.iso /var/ftp/dvd/

df -h
systemctl enable --now vsftpd


【servera】cleint
以网卡方式启动--安装1、指定ftp路径172.25.250.9/dvd 2 最小化 3 设置lvm分区
进度条走完-重启，添加硬盘启动 ， 从本地硬盘启动。



```

```bash
append initrd=initrd.img inst.stage2=ftp://172.25.250.9/dvd inst.ks=ftp://172.25.250.9/ks.cfg quiet

如果使用无人值守方式，还需要使用ks文件，路径指向写入到default里。
    # cp anaconda-ks.cfg /var/ftp/ks.cfg
# vim ks.cfg
#version=RHEL8
ignoredisk --only-use=vda
bootloader --append="console=ttyS0 console=ttyS0,115200n8 no_timer_check net.ifnames=0  crashkernel=auto" --location=mbr --timeout=1 --boot-drive=vda
zerombr
clearpart --all --initlabel
reboot
text
url --url="ftp://172.25.250.9/dvd"
keyboard --vckeymap=us --xlayouts=''
lang en_US.UTF-8
network  --bootproto=dhcp --device=link --activate
rootpw --iscrypted nope
auth --enableshadow --passalgo=sha512
selinux --enforcing
firstboot --disable
services --disabled="kdump,rhsmcertd" --enabled="sshd,NetworkManager,chronyd"
timezone America/New_York --isUtc
part / --fstype="xfs" --ondisk=vda --size=8000

%post --erroronfail
echo redhat | passwd --stdin root
useradd tom
%end

%packages
@core
@base
NetworkManager
dnf-utils
-plymouth
%end
# cp ks.cfg /var/ftp/
# chmod o+r /var/ftp/ks.cfg
# ll /var/ftp/ks.cfg 

再使用servera测试即可。
```

# 第十三章 总复习

### setcourse

```
【foundation】
rht-clearcourse 0
rht-setcourse rh124
rht-setcourse rh134
rht-setcourse rh294

virt-manager 
```

# RHCSA模拟考试环境布置方法

```bash
考试模拟环境布置方法：
1、恢复init初始环境，启动系统
2、加载ex200软件包，使虚拟机加载软件包镜像
3、以root身份将软件包拷贝到/opt/下 su - root 
4、su - kisok 后 ssh root@localhost 'yum install -y /opt/包名'   （注意不要用其他方式否则报错）
5、安装后，使用exam-setup部署模拟考试环境
6、使用
```

