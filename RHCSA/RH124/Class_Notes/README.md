
**H3CNE　H3CSE  H3CTE  RHCE  RHCI**



**课程上对学员的帮助**

**1、线上直播视频授课**

**2、线上录屏，我的瑞通**

**3、微信群中老师和助教老师解决问题**（问答列表）

**4、每天课后练习**

**6、远程协助软件帮助学员解决问题**

**7、技术外问题，可以咨询班主任或课程顾问**

**9、遵守课堂纪律**

**10、下课会有倒计时软件，上课抓紧回来**

9：00-17：30  正式讲新知识    课程时间45分  课间15分       13：00-13：30

|      第一天       | 第二天             | 第三天             | 第四天               | 第五天               |
| :---------------: | ------------------ | :----------------- | -------------------- | -------------------- |
|   线下环境介绍    | 创建、查看编辑文本 | 控制服务和守护进程 | RHEL网络管理         | 访问Linux文件系统    |
| 红帽企业Linux入门 | 管理本地用户和组   | OpenSSH服务        | 归档与系统间复制文件 | 分析服务器和获取支持 |
|    访问命令行     | 控制文件的访问     | 日志分析与存储     | 安装与升级软件包     | 回顾复习             |
| 从命令行管理文件  | 进程监控及管理     |                    |                      |                      |
| 在RHEL中获取帮助  |                    |                    |                      |                      |

远程环境

1、建议大家用自己环境  周六日开放

2、线上环境，微信群中技术老师，告诉他你需要远程机器



# 认证

RHCSA  RHCE RHCA

RHCSA   初级

| 课程  | 项目   | 版本   | 时间 |
| ----- | ------ | ------ | ---- |
| RH124 | basic  | RHCSA8 | 5    |
| RH134 | system | RHCSA8 | 4    |

RHCE  中级

| 课程  | 项目        | 版本  |
| ----- | ----------- | ----- |
| RH254 | 安全+服务   | RHCE7 |
| RH294 | ansible 2.8 | RHCE8 |

RHCA- 高级

| 课程      | 内容                                      |
| --------- | ----------------------------------------- |
| CL210     | 红帽openstack认证系统管理员               |
| DO407 2.7 | Ansible网络自动化，配置和管理网络基础架构 |
| DO280     | 红帽平台即服务专业技能证书openshift  k8s  |
| RH318     | 红帽认证虚拟化管理员                      |
| RH236     | 红帽混合云存储专业技能证书                |

考前辅导、和考试时间待定



# 介绍环境搭建过程

课程环境方案：

1、瑞通提供了远程环境

​     注意： foundation 不要关机



2、自己加载练习环境（微信群共享环境）

​	1、网盘下载（一个虚拟机程序）

​	2、安装vmware软件并且加载虚拟机程序

​    3、可以自己开关机



all in one 所有内容虚拟机都在一个虚拟机里





### vmware安装、加载虚拟机

vmware软件-功能：开启、关闭、挂起、启动、快照

9卸载  再装更高版本，这种方法不推荐

当前9版本，直接升级到更高版本，比如15，推荐方法

### 环境配置

| ID       | 内容                                        |
| -------- | ------------------------------------------- |
| 硬件     | cpu：VT-X、mem：4G，disk 80G                |
| 软件     | OS：x64 APP：VMware（workstation\|Fustion） |
| 文件     | folder：RH294.vmx                           |
| 压缩软件 | 7z/win ，keka/mac                           |

### 线下环境机器模块

| 环境分类 | VM 虚拟机名称    | 功能                             |
| -------- | ---------------- | -------------------------------- |
| VMware   | foundation0      | 宿主机                           |
| KVM      | classroom        | 分配dhcp、dns、软件              |
| KVM      | bastion          | 网关设备，连接其他机器的网络     |
| KVM      | workstation      | 提供图形界面连接其他机器：如abcd |
| KVM      | servera、b、c、d | 练习机，nic/mac+IP+hostname      |

workstation 、servera、serverb在lab.example.com同一个域内

foundation0   普通用户kiosk 密码 redhat    超级用户root密码 Asimov

foundation0  172.25.254.250    宿主机

classroom     172.25.254.254    超级用户 root 密码 Asimov

bastion     172.25.250.254     普通 student 密码student  超级用户 root 密码 Asimov

servera  172.25.250.10  普通 student 密码student，超级用户 root 密码redhat

serverb  172.25.250.11普通 student 密码student  超级用户 root 密码redhat



账号kisok  redhat   root  Asimov

student student  超级用户root  redhat



安装之前su -  root  输入密码：Asimov   ，yum install -y langpacks-zh_CN  注销切换一下kisok用户，选择中文，注销即可。

win键+空格=切换输入法



### 环境注意事项、技巧

- 关闭vmware dhcp    怕和classroom起冲突
- 图形如何好看
- 关闭360或安全管家
- MEM3072



### 上网的话，需要开启nat的dhcp功能后重启网卡

1  systemctl restart NetworkManager
    2  nmcli connection down Wired\ connection\ 1 
    3  nmcli connection up Wired\ connection\ 1 





### 技巧：

| STEP |         | 含义       |
| ---- | ------- | ---------- |
| 1    | word    | 单词       |
| 2    | tab     | 列出、补全 |
| 3    | man     | 查帮助     |
| 4    | echo $? | 结果是0    |

### 虚拟机控制命令

rht-vmcli 管理线下虚拟机环境

```bash
foundation0 ~]$ ctrl+l
rht-vmctl status all   查看所有虚拟机状态
rht-vmctl status classroom 
rht-vmctl start classroom
rht-vmctl start bastion 
rht-vmctl start workstation 
rht-vmctl start servera
rht-vmctl stop servera
rht-vmctl reset servera  


ping -c 4 172.25.250.10
ping  servera
ctrl+c 

ssh servera
ssh 172.25.250.10 
ssh  root@172.25.250.10
exit 或者ctrl+d

关闭防火墙
firewall-cmd  --permanent --add-service=http
firewall-cmd  --reload

 



```

# 1、红帽企业Linux入门

### 开源

### Linux

linus  内核linux----莱纳斯

kernel.org 网站

### Linux系列发行版

公司特定的软件+linux内核=操作系统

红帽：GNU/Linux，各种开源应用+Linux内核  redhat

Centos 

fedora

debian

ubuntu

### 红帽培训和教育方案

RHCSA、RHCE、RHCA

红帽企业Linux



# 第二章 访问命令行

终端切换

|      |             |               |
| ---- | ----------- | ------------- |
| CLI  | Ctrl+alt+Fx | x in （3，6） |
| GUI  | Ctrl+alt+F2 |               |

### 登录Linux系统

图形化

字符界面

网络登录



打开终端后--文件--新建标签页   ，切换方式Alt+1，Alt+2 ，Alt+N.......

字条大小快捷键ctrl + shift + = ，缩小ctrl  +   - 

### Shell简介

作用：它是一个解释器，可以帮助用户将指令信息传递内核

基本组成：

[kiosk@foundation0 ~]$       $普通用户

[kiosk@foundation0 ~]$ su  -  root
Password: Asimov
Last login: Sat Feb 22 15:11:13 CST 2020 on tty3
[root@foundation0 ~]#       #超级用户

ctrl+d



### Shell的特性

补全   tab键  输入单词或命令前面几个首字母后，保证唯一可补全，不唯一可列出能选择的命令

历史命令

history

env--能容纳1000条

！23    历史命令的编号

！h      命令首字母



 vim  ~/.bash_history

[root@foundation0 ~]# history -c 

Bash Shell常用的快捷键

| ctrl+a      | 光标跳至行首             |
| ----------- | ------------------------ |
| ctrl+e      | 光标跳至行尾             |
| ctrl+u      | 从光标所在位置清空至行首 |
| ctrl+k      | 从光标所在位置清空至行末 |
| ctrl+左箭头 | 光标向左跳一个单词       |
| ctrl+右箭头 | 光标向右跳一个单词       |
| ctrl+w      | 回删一个单词             |
| alt+d       | 删除光标后一个单词       |

工作区切换

| ctrl+alt   上\|下  箭头 |      |
| ----------------------- | ---- |
|                         |      |

启动终端

ALT+F2  输入 gnome-terminal

锁定

win+l

关闭和重启

|      | 关机               | 重启             |
| ---- | ------------------ | ---------------- |
| 1    | init 0             | init 6           |
| 2    | poweroff           | reboot           |
| 3    | systemctl poweroff | systemctl reboot |
| 4    | shutdown -h 20：00 | shutdown -r 0    |

语法：

cmd 【-option】 【arg1】 【arg2】

```bash
# ls
# man ls
# ls -a
# 19  ls --all
# 20  ls /home
# 21  ls -a /home

```

回显式命令

```bash
 date +%Y%m%d
 date +%Y-%m-%d

```

交互式命令

passwd

# 第三章 从命令行管理文件

Linux系统目录结构

通过文件名定位文件

```bash
[root@foundation0 home]# cd /
[root@foundation0 /]# cd /etc/
```

路径的表示

绝对路径 

例子：

根开头    cd /etc/sysconfig

相对路径

非根开头 cd  ..



### 导航路径	

```bash
[root@foundation0 yum.repos.d]# pwd
/etc/yum.repos.d

cd
cd -   返回之前的目录
cd ~	家目录
cd .	当前目录
cd ..    上一级目录


ls
ls -a 
ls -a /home 
ls -a -l 
ls -al
[root@foundation0 /]# ls -l newfile 
-rw-r--r--. 1 root root 0 Feb 22 16:58 newfile
[root@foundation0 /]# ll newfile 
-rw-r--r--. 1 root root 0 Feb 22 16:58 newfile
ll -a
[root@foundation0 /]# ll -d opt
drwxr-xr-x. 2 root root 6 Aug 12  2018 opt

touch newfile1
    4* touch
    5  touch newfile2 newfile3
    7  touch /newfile10
   10  touch file{1..10}
   12  man rm
   15  rm file
   17  rm -f file2
   19  rm /newfile10 
   20  rm -f /newfile10 
	mkdir dir1
   27  mkdir dir2 dir3
   28  mkdir /dir10
   29  ls /
   31  mkdir dir10/dir11
   32  mkdir -p dir10/dir11 
   34  ls dir10
   35  mkdir -pv dir20/dir21
   37  ls dir20
   39  rm dir20
   40  rm -r dir20
   41  ls
   42  rm -rf dir1 
   cp newfile1 /newfile100
   cd /
   cp /etc/man_db.conf  . (./ ,  /)
   
   52  cp dir2 /
   53  cp -r dir2 /
   54  ls /
   55  man cp
   57  mv newfile1 dir2/
   59  ls dir2
   61  mv dir3 /opt/dir2
   65  ls dir2
   
   cd /opt
   rm -rf *
   touch {a..c}{1..3}.txt
   71  ls
   72  ls *.txt
   73  a*.txt
   74  ls a*.txt
   75  ls
   76  ls ?1.txt
   77  ls a?.txt
   78  ls [ab]*
   79  ls [^ab]*
   80  ls [!ab]*
   81  ls [ab]?
   82  ls [ab]?????
   83  ls [ab]*
   91  ls {a2,b3}*
   [root@foundation0 opt]# ls [a-z][0-9][0-9]*
   
```

查看文件内容

| cat  | cat /etc/passwd                                    |                              |
| ---- | -------------------------------------------------- | ---------------------------- |
| tail | tail  /var/log/message  ,tail -5  /var/log/message |                              |
| head | head  /var/log/message  ,head -5  /var/log/message |                              |
| less | less  /var/log/message                             | space。q，page up，page down |
| more | more /var/log/message                              | space ，q                    |
| vim  | vim  /etc/passwd                                   | 文本编辑器                   |

# 第四章  在线获取帮助

MAN帮助手册

--help

```bash
man passwd
  115  man -k passwd 
  116  mandb
  117  man -k passwd
  120  man passwd
  121  man 5 passwd
  
  ls --hlep
  
  man tar
  
```

### Pinfo

```
info
pinfo   回车  u
pinfo  ls


```

### rpm包中提供帮助

```
yum install -y httpd

rpm -qa | grep httpd
rpm -ql 软件包名称
rpm -qc

http tools install 
servera
classroom和bastion
yum install -y httpd-manual
systemctl start servera
允许http，或关闭防火墙

found：http：//172.25.250.10/manual
```



### 在线帮助

 https://access.redhat.com/ 

# 第五章 创建、查看编辑文本

### VIM文本编辑器

| 模式     | 功能               |      |
| -------- | ------------------ | ---- |
| 命令模式 | 光标移动、复制删除 | cmd  |
| 输入模式 | 输入文本内容       | a    |
| 末行模式 | 保存退出、设置环境 | ：   |

| 命令模式      |                                            |
| ------------- | ------------------------------------------ |
| 命令          | 解释                                       |
| h j k l       | 左下上右                                   |
| 方向键        | 上下左右                                   |
| 1G、nG        | n代表一个数字，去第1行或n行                |
| gg            | 将光标定位到文章的顶端                     |
| G             | 将光标定位到文章的底端                     |
| x，X          | 向后删除，向前删除一个字符                 |
| dd ，  ndd    | 删除1行，n行   。 例子：dgg dG  d$ d0 D    |
| yy，nyy       | 复制1行，n行                               |
| p，P          | 粘贴到下一行，粘贴到上一行                 |
| u             | 撤销                                       |
| ZZ            | 保存退出                                   |
| 末行模式      |                                            |
| w             | 保存                                       |
| q             | 退出                                       |
| wq            | 退出并保存                                 |
| q！           | 强制退出                                   |
| x             | 保存退出                                   |
| set nu        | 设置行号                                   |
| set nonu      | 取消行号                                   |
| ：w /newfile  | 另存为其他文件                             |
| ：r /newfile  | 读取/newfile到本文件中                     |
| ：！  command | vim编辑过程中，查询linux                   |
| 命令模式      |                                            |
| a             | 字符后进入插入模式                         |
| i             | 当前字符位置进入插入模式                   |
| o             | 在下一行新创建一行进入插入模式             |
| A             | 在行尾进入插入模式                         |
| I             | 在行首进入插入模式                         |
| O             | 在上一行新创建一行进入插入模式             |
| 其他模式      |                                            |
| ：            | 末行模式                                   |
| v、V或Ctrl+V  | 可视模式                                   |
| R             | 替换模式                                   |
| /word，？word | /向下查找，？向上查找                      |
| n，N          | 定位到下一个匹配字符，定位到上一个匹配字符 |
|               |                                            |

/usr/X11R6/bin

vim passwd

vim passwd

修改serveraip地址方法

[root@servera ~]# nmcli connection modify  Wired\ connection\ 1  ipv4.addresses 172.25.250.10

[root@servera ~]# nmcli connection down  Wired\ connection\ 1

[root@servera ~]# nmcli connection up  Wired\ connection\ 1



视图模式修改方法：
ctrl+v ， j+G，I，  空格，exc



### 重定向

```bash
1=stand，2=error，&=1+2
echo hello
echo hello > output.txt
   50  cat output.txt 
   51  echo world > output.txt 
   52  cat output.txt 
   54  echo hello >> output.txt 
   55  cat output.txt 
   
   57  echo $?
   58  echo hello
   59  echo $?
   
   60  Echo hello
   61  Echo hello > eor.txt
   	   cat eor.txt
   62  Echo hello 2> eor.txt
   63  cat eor.txt 
   64  echo aaa 1> output.txt  也是标准输出重定向
   65  cat output.txt 
   67  find / -name student
   68  find / -name student > A.txt 2> B.txt
   69  cat A.txt 
   70  cat B.txt 
   71  ls
   72  find / -name student > A.txt 2> /dev/null
   73  find / -name student &> C.txt 
   find / -name student &>> C.txt 
   
 [root@servera /]# grep na /etc/resolv.conf > /root/lines.txt
[root@servera /]# cat /root/lines.txt 
# Generated by NetworkManager
nameserver 172.25.250.254

验证是否有空行：
grep -n ^$  /root/lines.txt

修改主机名
[root@servera /]# vim /etc/hostname 
[root@servera /]# hostname         
[root@servera /]# hostnamectl set-hostname 

```

# 第六章 管理本地用户和组

UID 

GID

0 超级用户 ，1000以下系统用户，1000以上普通用户 ，组与用户ID对应（自然创建）

```bash
useradd user1
   81  passwd user1
   82  id user1
   
   option：
   -u：指定用户uid
   -G ：指定附加群组
   -s：指定shell环境 /bin/bash  /sbin/nolgoin /bin/false
   -g：指定主要群组
   [root@servera /]# useradd -u 10000 user2
[root@servera /]# vim /etc/passwd
[root@servera /]# echo 123456 | passwd --stdin user2
Changing password for user user2.
passwd: all authentication tokens updated successfully.

groupadd east 
useradd -G east user3
useradd -g east user4

usermod -s /bin/bash user5
usermod -u 20000 user5 

[root@servera tmp]# useradd -s /bin/false user5
[root@servera tmp]# vim /etc/passwd
[root@servera tmp]# su - user5

userdel -r user5

练习
groupadd sysmgrs
useradd -G    sysmgrs  natasha
useradd -G    sysmgrs  harry
useradd -s /bin/false sarah
echo  flectrag  | passwd --stdin natahsa
echo  flectrag  | passwd --stdin harry
echo  flectrag  | passwd --stdin sarah

验证方式：通过切换用户，id username，vim /etc/passwd

129  vim /etc/group
  130  groupadd group1
  132  tail -1 /etc/group
  133  groupadd -g 20000 group2
  134  tail -1 /etc/group
  135  groupadd  group3
  136  tail -1 /etc/group
  137  groupmod -g 21000 group3
  138  tail -1 /etc/group
  
  su  -
  su  - root
  su  - user1     su - user2  需要密码
  /etc/passwd   用户
  /etc/group    组
  /etc/shadow   密码

```

# 第七章 控制对文件的访问

### 文件权限介绍

| 权限分类 |         |          |                  |
| -------- | ------- | -------- | ---------------- |
|          |         | 文件     | 目录             |
| r        | read    | cat      | ls               |
| w        | write   | vim      | touch，rm，mkdir |
| x        | execute | ./script | cd               |

数字表示法

| rwx  |      |      |      |
| ---- | ---- | ---- | ---- |
| r--  | 100  | 4    |      |
| -w-  | 010  | 2    |      |
| --x  | 001  | 1    |      |

chmod

chmod  权限  目标文件

chmod  数字  目标文件

|      |       |      |      |
| ---- | ----- | ---- | ---- |
| u    | user  |      |      |
| g    | group |      |      |
| o    | other |      |      |
| a    | all   |      |      |

   

|      |      |
| ---- | ---- |
| +    | 添加 |
| -    | 减去 |
| =    | 设置 |



```
chmod u+x file1
   54  ls
   55  ll file1 
   56  chmod g+w file1
   57  ll file1
   58  chmod u-x,g-w,o=--- file1
   chmod a=rw file1
 chmod a+x file1
 chmod -x file1

每种方法都自己尝试一次

数字修改方法
chmod 644 file1
 ll -d dir1
 chmod 755 dir1

```

### 设置文件属主和属组

chown 

chown  所有者：所属组   文件名

```
ll newfile 
   84  chown user1 newfile 
   85  ll newfile 
   88  chown :east newfile 
   89  ll newfile  
   91  chown user2:user2 newfile 
   92  ll newfile 

[root@servera opt]# ll -d dir1
drwxr-xr-x. 2 root root 6 Feb 23 16:54 dir1
[root@servera opt]# chown :user1 dir1
[root@servera opt]# ll -d dir1
drwxr-xr-x. 2 root user1 6 Feb 23 16:54 dir1


```

文件默认权限

#### umask

系统默认权限对于文件666

对于目录来说777

```
umask 
0022

666-022=644
所以文件默认权限是644

777-022=755
默认目录权限

查看umask值方法
[root@servera /]# umask
0022

修改方法umask
[root@servera /]# umask 0002
修改完后，可以去文件和目录查看权限，看是否和之前不一样，看完改回来

```

### 特殊权限

```bash
SUID
[root@foundation0 ~]# chmod u+s /usr/bin/passwd
[root@foundation0 ~]# ll /usr/bin/passwd 
-rwsr-xr-x. 1 root root 34512 Aug 13  2018 /usr/bin/passwd
SGID
[root@foundation0 opt]# chmod g+s dir1
[root@foundation0 opt]# ll -d dir1/
drwxr-sr-x. 2 root root 6 Feb 29 09:21 dir1/

[root@foundation0 opt]# groupadd east
[root@foundation0 opt]# chown :east dir1
[root@foundation0 opt]# ll -d dir1
drwxr-sr-x. 2 root east 6 Feb 29 09:21 dir1
[root@foundation0 opt]# touch dir1/newfile
[root@foundation0 opt]# ll dir1/newfile 
-rw-r--r--. 1 root east 0 Feb 29 09:27 dir1/newfile

check:
在目录中创建新文件，看所属组是否和上级目录的所属组一致

SBIT
[root@foundation0 opt]# mkdir dirt
[root@foundation0 opt]# chmod 777 dirt/
[root@foundation0 opt]# ll -d dirt/
drwxrwxrwx. 2 root root 6 Feb 29 09:32 dirt/
[root@foundation0 opt]# chmod o+t dirt/
[root@foundation0 opt]# ll -d dirt
drwxrwxrwt. 2 root root 6 Feb 29 09:32 dirt

check：
创建两个不同用户登录操作系统，进入dirt目录分别创建文件，尝试互相删除对方文件，结果应不能互相删除文件。


SUID=4  SGID=2  SBIT=1
chmod 1777 dirt
[root@foundation0 opt]# ll -d dirt
drwxrwxrwt. 2 root root 6 Feb 29 09:32 dirt
chmod 2777  dirt
[root@foundation0 opt]# 
[root@foundation0 opt]# ll -d dirt
drwxrwsrwx. 2 root root 6 Feb 29 09:32 dirt

会修改基本权限、特殊权限chmod、修改所有者所属组chown

1.在/tmp下创建目录为common，所属组更改为tom，并且要求，其他用户在此目录中出创建的文件及目录的所属组也为父目录所属组
[root@servera /]# mkdir /tmp/common
[root@servera /]# chown :tom /tmp/common/
[root@servera /]# cat /etc/group | grep tom
tom:x:10006:
[root@servera /]# ll -d /tmp/common/
drwxr-xr-x. 2 root tom 6 Mar 17 04:28 /tmp/common/
[root@servera /]# chmod o+w,g+s /tmp/common/
[root@servera /]# ll -d /tmp/common/
drwxr-srwx. 2 root tom 6 Mar 17 04:28 /tmp/common/
[root@servera /]# su - user1
Last login: Tue Mar 17 04:14:08 CST 2020 on pts/0
[user1@servera ~]$ cd /tmp/common/
[user1@servera common]$ touch 111
[user1@servera common]$ ll 111 
-rw-rw-r--. 1 user1 tom 0 Mar 17 04:31 111

2.在/目录下创建一个test目录，要求不同用户可以进入目录创建文件和目录，但是不能互相删除彼此的文件。
[root@servera /]# ll -d test/
drwxr-xr-x. 2 root root 6 Mar 17 04:32 test/
[root@servera /]# chmod 757 test/
[root@servera /]# chmod 1757 test/
[root@servera /]# ll -d test/
drwxr-xrwt. 2 root root 6 Mar 17 04:32 test/
[root@servera /]# chmod o+t test/

```

# 第八章 进程监控及管理

```
yum install -y psmisc
pstree -p
一程序被开启会产生一个或多个进程，他们都有对应父进程与子进程，每个进程都有进程号PID
systemd 1 不能被杀死，除非重启，关机。

ps  aux  
ps aux | grep http

[root@servera ~]# ps -l
F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0 27392 27367  0  80   0 - 85532 -      pts/0    00:00:00 su
4 S     0 27396 27392  0  80   0 - 59008 -      pts/0    00:00:00 bash
4 T     0 27822 27396  1  80   0 - 63962 -      pts/0    00:00:00 vim
0 R     0 27823 27396  0  80   0 - 63625 -      pts/0    00:00:00 ps

[root@servera ~]# kill -9 27822
[root@servera ~]# 
[root@servera ~]# ps aux | grep http
root@servera ~]# killall httpd

top
M
P
h
k  pid    9/15  
```

### 作业控制jobs

```
[root@servera ~]# vim file2

[1]-  Stopped                 vim file1

[2]+  Stopped                 vim file2
[root@servera ~]# jobs
[1]-  Stopped                 vim file1
[2]+  Stopped                 vim file2

[root@servera ~]# dd if=/dev/zero of=./bigfile bs=1M count=1000
ctrl + z 
[root@servera ~]#
[1]+  Stopped                 dd if=/dev/zero of=./bigfile bs=1M count=1000
[root@servera ~]# bg 1
[1]+ dd if=/dev/zero of=./bigfile bs=1M count=1000 &
[root@servera ~]# jobs
[1]+  Running                 dd if=/dev/zero of=./bigfile bs=1M count=1000 &
[root@servera ~]# 
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB, 1000 MiB) copied, 65.0049 s, 16.1 MB/s


[root@servera ~]# kill -9 %2
[2]-  Stopped                 vim file2
[root@servera ~]# jobs
[2]-  Killed                  vim file2
[3]+  Stopped                 nice -n -10 vim file4


nice
nice  -n -5  vim &
renice -n  10  PID
renice -n 10 28183

```

# 第九章 控制服务与守护进程

/etc/init.d/network restart

service network restart

rhel7 rhel8

systemctl start NetworkManager

| 字段     | 描述                           |
| -------- | ------------------------------ |
| Loaded   | 服务单元是否加载到内存         |
| Active   | 服务单元是否在运行，运行了多久 |
| Main PID | 服务的主进程ID，包括命令名称   |
| Status   | 有关该服务的其他信息。         |

```
systemctl -t help

列入.service扩展名，代表服务，如web服务
systemctl list-units --type service  列出当前服务器加载的服务单元
systemctl  status  httpd.service   查看某个服务


服务运行状态
[root@servera system]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor pr>
   Active: inactive (dead)
     Docs: man:httpd.service(8)
     
[root@servera system]# systemctl start httpd     
[root@servera system]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor pr>
   Active: active (running) since Sat 2020-02-29 04:34:47 CST; 1s ago

查看服务是否启动
[root@servera system]# systemctl  is-active httpd
active

查看服务是否开机启动
[root@servera system]# systemctl enable httpd
[root@servera system]# systemctl is-enabled httpd
enabled
[root@servera system]# systemctl disable httpd
Removed /etc/systemd/system/multi-user.target.wants/httpd.service.
[root@servera system]# systemctl is-enabled httpd
disabled



```

### 服务状态关键字

| 关键字            | 描述                                     |
| ----------------- | ---------------------------------------- |
| loaded            | 单元配置文件已处理                       |
| active（running） | 正在通过一个或多个持续进程与运行         |
| active（exited）  | 已成功完成一次性配置                     |
| active（waiting） | 运行中，但正在等待事件                   |
| inactive          | 不在运行                                 |
| enabled           | 在系统引导时启动                         |
| disabled          | 未设为在系统引导时启动                   |
| static            | 无法启动，但可以由某一启动的单元自动启动 |

管理系统服务

| 语法：systemctl  管理命令  unitname |                               |
| ----------------------------------- | ----------------------------- |
| 管理命令                            | 描述                          |
| status                              | 查看状态                      |
| start                               | 开启                          |
| stop                                | 关闭                          |
| restart                             | 重启                          |
| reload                              | 加载配置文件                  |
| enable                              | 开机启动                      |
| disable                             | 关闭开机启动                  |
| list-dependencies  【unitname】     | 查看单元依赖                  |
| mask                                | 禁止服务，无法启动或开机 启动 |
| unmask                              | 解除mask                      |

```
 134  systemctl status httpd
  135  systemctl  is-active httpd
  136  systemctl status httpd
  137  systemctl stop httpd
  138  systemctl status httpd
  139  systemctl restart httpd
  140  systemctl status httpd
  141  systemctl enable httpd
  142  systemctl status httpd
  143  systemctl disable httpd
  144  systemctl status httpd
  145  systemctl list-dependencies httpd
  146  systemctl mask httpd
  147  systemctl unmask httpd
  
  可以用做练习的服务httpd，sshd，autofs，samba。
  
```

# 第10章 OPENSSH服务

### ssh的常用功能

```bash
[root@servera ~]# ssh serverb
root@serverb's password: 
[root@servera ~]# vim /etc/hosts  或者系统是否做了dns
[root@servera ~]# ssh 172.25.250.11
[root@servera ~]# ssh root@172.25.250.11

[root@servera opt]# scp rhcetext root@172.25.250.11:/
root@172.25.250.11's password: 
rhcetext                                                 100%    0     0.0KB/s   00:00

erverb /]# scp root@172.25.250.10:/opt/newfile  .
root@172.25.250.10's password: 
newfile                                                  100%    0     0.0KB/s   00:00 

[root@servera opt]# ssh root@172.25.250.11 “yum install -y httpd”

```

ssh免密登录

```
[root@servera ssh]# ssh-keygen 
[root@servera ssh]# ssh-copy-id -i /root/.ssh/id_rsa.pub root@serverb

[root@serverb /]# cd /root/.ssh/
[root@serverb .ssh]# ls
authorized_keys  known_hosts

[root@servera ssh]# ssh serverb

a免密远程b，如果想b远程a免密，需要做方向相同配置
```

拒绝root登录

```bash
[root@serverb ~]# vim /etc/ssh/sshd_config
PermitRootLogin no
[root@serverb ~]# systemctl reload sshd（或restart）


[root@servera ~]# ssh root@serverb


拒绝所有ssh连接
vim /etc/hosts.deny
sshd: ALL


```

# 第十一章 日志分析与存储

| 日志文件          | 存储的消息类型                           |
| ----------------- | ---------------------------------------- |
| /var/log/messages | 大多数系统日志消息处存放处。             |
| /var/log/secure   | 与安全性和身份验证时间相关的syslog消息。 |
| /var/log/maillog  | 与邮件服务器相关的syslog消息。           |
| /var/log/cron     | 与计划任务执行相关的syslog消息           |
| /var/log/boot.log | 与系统启动相关的消息。                   |

### rsyslog服务管理的日志配置文件

/etc/rsyslog.conf

### rsyslog配置文件类别

| 类别(facility) |                     |
| -------------- | ------------------- |
| Kern           | 内核                |
| authpriv       | 授权和安全          |
| cron           | 计划任务            |
| mail           | 邮件                |
| daemon         | 系统守护进程        |
| syslog         | 由rsyslog生成的信息 |
| local0~local7  | 自定义本地策略      |

日志的等级

|      |                 |                            |
| ---- | --------------- | -------------------------- |
| 0    | EMERG（紧急）   | 会导致主机系统不可用的情况 |
| 1    | ALERT（警告）   | 必须马上采取措施解决的问题 |
| 2    | CRIT（严重）    | 比较严重的情况             |
| 3    | ERR（错误）     | 运行出现错误               |
| 4    | WARNING（提醒） | 可能会影响系统功能的事件   |
| 5    | NOTICE（注意）  | 不会影响系统但值得注意     |
| 6    | INFO（信息）    | 一般信息                   |
| 7    | DEBUG（调试）   | 程序或系统调试信息等       |

使用logger发送测试日志信息

```bash
1、打开servera  rsyslog服务
2、配置 user.debug     /var/log/messages.debug
3、logger -p user.debug "Debug test messages"
4、[root@servera ~]# tail -n 0 -f /var/log/messages.debug 
Feb 29 08:06:18 servera root[29837]: test.debug


tail /var/log/messages.debug
```

### journalctl知识点

```bash
传统日志服务rsyslog，新添加的服务是syustemd-journal，它也是一个日志管理服务，可以收集来自内核、系统早期启动阶段的日志，以及系统进程在启动和运行中的一些标准输出与错误输出。此日志一旦重启既消失，因为保存在了/run/log中。

journalctl 查看系统日志
journalctl -n   通过q或ctrl接触观看  ，此命令显示方式类似与tail
 245  journalctl -p err
  247  journalctl -n 5 
  248  journalctl -f 
  249  journalctl -p err 
  250  journalctl -p info
  （deubg、info、notice、warning、err、crit、alert、emerg）

journalctl --since "2020-02-28 22:53:35" --until "2020-02-28 22:53:40"

```

| 常用字段     | 含义                    |
| ------------ | ----------------------- |
| _COMM        | 命令名称                |
| _EXE         | 进程的可执行文件的路径  |
| _PID         | 进程的PID               |
| _UID         | UID                     |
| _SYSTEM_UNIT | 启动该进程的systemd单元 |

```bash
journalctl -o verbose 
  193  journalctl _HOSTNAME=localhost
  194  journalctl _HOSTNAME=localhost _PID=1

```



### 设置永久保存journal服务文件方式

```
systemctl status systemd-journald
vim /etc/systemd/journald.conf 
Storage=persistent
mkdir /var/log/journal
ll -d /run/log/journal/
chown root:systemd-journal /var/log/journal/
chmod 2755 /var/log/journal/
systemctl restart systemd-journald
ls /var/log/journal/
#reboot
```

### 保持准确的系统时间

```bash
[root@servera log]# timedatectl 
               Local time: Sat 2020-02-29 08:51:49 CST
           Universal time: Sat 2020-02-29 00:51:49 UTC
                 RTC time: Sat 2020-02-29 08:11:07
                Time zone: Asia/Shanghai (CST, +0800)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
          
[root@servera log]# timedatectl list-timezones
         
[root@servera log]# timedatectl set-timezone Asia/Hong_Kong 
[root@servera log]# 
[root@servera log]# 
[root@servera log]# timedatectl 
               Local time: Sat 2020-02-29 08:55:48 HKT
           Universal time: Sat 2020-02-29 00:55:48 UTC
                 RTC time: Sat 2020-02-29 08:15:06
                Time zone: Asia/Hong_Kong (HKT, +0800)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no

修改时间方法
timedatectl set-time "2020-02-30 10:00:00"
Failed to set time: NTP unit is active
timedatectl set-ntp false 
timedatectl set-time "2020-02-30 10:00:00"
timedatectl set-ntp true 
```

### chrony

```bash
[root@servera ~]# systemctl status chronyd
[root@servera ~]# systemctl start chronyd
[root@servera ~]# vim /etc/chrony.conf
server classroom.exmaple.com iburst
systemctl  restart chronyd.service
[root@servera ~]# timedatectl set-ntp false 
[root@servera ~]# timedatectl set-ntp true 

[root@servera ~]# chronyc sources -v
210 Number of sources = 1

  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current synced, '+' = combined , '-' = not combined,
| /   '?' = unreachable, 'x' = time may be in error, '~' = time too variable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
^* classroom.example.com         8   6   377    25  -3837ns[  +21us] +/-  627us


find命令：
搜索用户natasha所属的文件复制到/root/findfiles中。
find / -user natasha -exec cp -rp {} /root/findfiles/ \；
```

# 第十二章 RHEL网络管理

### 认识IPv4地址

|      |                      |                                                      |
| ---- | -------------------- | ---------------------------------------------------- |
| 1    | IP/(NETMASK\|PREFIX) | 172.25.0.9/255.255.0.0 \| 172.25.0.9/16              |
| 2    | GATEWAY              | 172.25.x.x                                           |
| 3    | DNS                  | 正向解析 # host servera， 反向解析 # host 172.25.0.9 |

网段：IP与掩码二进制与运算 

|          |                |           |
| -------- | -------------- | --------- |
| 网络地址 | 172.25.0.0     | 主机位全0 |
| 广播地址 | 172.25.255.255 | 主机位全1 |

#### ip4,ip6

```bash
[root@servera ~]# ip addr show enp1s0 
2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:00:fa:0a brd ff:ff:ff:ff:ff:ff
    inet 172.25.250.10/24 brd 172.25.250.255 scope global noprefixroute enp1s0
       valid_lft forever preferred_lft forever
    inet6 fe80::e6c5:468e:edb6:9b52/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
       
       
 ifconfig
 
 [root@servera ~]# ip -s link show enp1s0 
2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:00:fa:0a brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    8129562    4141     0       1947    0       0       
    TX: bytes  packets  errors  dropped carrier collsns 
    200382     1535     0       0       0       0  

```

ipv4 ipv6 mac

|              |  ipv4  |   ipv6   |   mac    |
| :----------: | :----: | :------: | :------: |
| 二进制（位） |   32   |   128    |    48    |
|  符号（分）  |   .    |    :     |    :     |
|     进制     | 十进制 | 十六进制 | 十六进制 |
|      组      |   4    |    8     |    6     |

#### 查看路由及网关信息

```bash
[root@servera ~]# ip route 
default via 172.25.250.254 dev enp1s0 proto static metric 100 
172.25.250.0/24 dev enp1s0 proto kernel scope link src 172.25.250.10 metric 100

[root@servera ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         172.25.250.254  0.0.0.0         UG    100    0        0 enp1s0
172.25.250.0    0.0.0.0         255.255.255.0   U     100    0        0 enp1s0

[root@servera ~]# nmcli connection show Wired\ connection\ 1 | grep ipv4.ga
ipv4.gateway:                           172.25.250.254

[root@servera ~]# netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         172.25.250.254  0.0.0.0         UG        0 0          0 enp1s0
172.25.250.0    0.0.0.0         255.255.255.0   U         0 0          0 enp1s0
```

配置网关gateway

```
一、使用nmcli

二、修改配置文件
```

#### dns

```
vim /etc/resolv.conf 
nameserver 172.25.250.254
```

#### hostname

```bash
[root@servera ~]# hostname
servera.lab.example.com
[root@servera ~]# 
[root@servera ~]# 
[root@servera ~]# hostnmae  www.example.com 临时
[root@servera ~]# vim /etc/hostname  永久
[root@servera ~]# hostnamectl set-hostname hostname

```

#### 使用nmcli管理网络

```bash
[root@servera ~]# nmcli connection show 
NAME                UUID                                  TYPE      DEVICE 
Wired connection 1  6bc56692-0f3b-3bf9-941f-8bc9f5ff7941  ethernet  enp1s0 
[root@servera ~]# nmcli connection show --active 
NAME                UUID                                  TYPE      DEVICE 
Wired connection 1  6bc56692-0f3b-3bf9-941f-8bc9f5ff7941  ethernet  enp1s0 

[root@servera ~]# nmcli device status 

[root@servera ~]# nmcli connection add  con-name 'default' type ethernet ifname enp1s0

[root@servera ~]# nmcli connection add con-name 'static' ifname enp1s0 type ethernet autoconnect yes ipv4.add 172.25.250.110/24 ipv4.gateway 172.25.250.250 ipv4.dns 8.8.8.8 ipv4.method manual 

[root@servera /]# nmcli connection show 
NAME                UUID                                  TYPE      DEVICE 
Wired connection 1  6bc56692-0f3b-3bf9-941f-8bc9f5ff7941  ethernet  enp1s0 
default             e073aab5-91c4-469d-914b-a99b65e8fda6  ethernet  --     
static              b76d66ed-5cd1-4e04-9c6a-5beaf2a1c3ee  ethernet  --   

[root@servera /]# nmcli connection up static   启动static网卡

[root@serverb ~]# nmcli connection modify static +ipv4.dns 202.106.0.20

[root@serverb ~]# nmcli connection delete static 
Connection 'static' (b85e6a57-b8f7-421f-8d15-9ff5e27cbb85) successfully deleted.

[root@servera /]# nmcli connection down static   关闭static网卡

[root@servera /]# nmcli networking off


图形化管理配置
通过点击设置--network--网卡设置，ipv4address  netmask  dns  gateway
nmtui-edit

```

#### 网卡配置文件/etc/sysconfig/network-scripts/

```bash
BOOTPROTO=none       static     dhcp 
ONBOOT=yes
IPADDR=172.25.250.100
PREFIX=24
GATEWAY=172.25.250.254


修改配置文件方式修改IP
vim /etc/sysconfig/network-scripts/ifcfg-Wired_connection_1
[root@servera ~]# systemctl restart NetworkManager
[root@servera ~]# nmcli connection down Wired\ connection\ 1
[root@servera ~]# nmcli connection up Wired\ connection\ 1


```

#### host  and nslookup  检测dns域名解析是否正常

```
[root@servera ~]# host classroom.example.com
classroom.example.com has address 172.25.254.254
[root@servera ~]# nslookup classroom.example.com
Server:		172.25.250.254
Address:	172.25.250.254#53

Name:	classroom.example.com
Address: 172.25.254.254


```

# 第十三章 归档与系统间复制文件

tar归档

```bash
tar 选项  归档文件名    源文件 源文件2 源文件N
-c  创建
-t  查看
-f  指定文件名
-v  显示详细信息
-x  解包
-C  指定解包路径

tar -cvf /root/etc.tar /etc/

[root@servera opt]# touch file{1..3}
[root@servera opt]#
etc.tar  file1  file2  file3
[root@servera opt]# tar -cvf file.tar file1 file2 file3
file1
file2
file3
[root@servera opt]# tar -tf file.tar
file1
file2
file3

[root@servera opt]# ls
etc.tar  file1  file2  file3  file.tar
[root@servera opt]# tar -xvf file.tar -C /tmp/
file1
file2
file3
[root@servera opt]# ls /tmp/
file1  rclocal.log
file2  rht-bastion
file3  rht-default
NIC1   rht-vm-hosts
NIC2   systemd-private-ef2feb022cd2465c9dd920878a1d962b-chronyd.service-kRKFp0
[root@servera opt]# 


[root@servera opt]# ls
etc.tar  file1  file2  file3  file.tar
[root@servera opt]# cp etc.tar /home
[root@servera opt]# cd /home 
[root@servera opt]# tar -xvf etc.tar 

压缩：
[root@servera opt]# gzip file1
[root@servera opt]# ls
etc.tar  file1.gz  file2  file3  file.tar
[root@servera opt]# file file1.gz 
file1.gz: gzip compressed data, was "file1", last modified: Sun Mar  1 05:54:06 2020, from Unix, original size 0
[root@servera opt]# bzip2 file2
[root@servera opt]# ls
etc.tar  file1.gz  file2.bz2  file3  file.tar
[root@servera opt]# file file2.bz2 
file2.bz2: bzip2 compressed data, block size = 900k
[root@servera opt]# xz file.tar 
[root@servera opt]# ls
etc.tar  file1.gz  file2.bz2  file3  file.tar.xz

-z  gzip
-j	bzip2
-J	xz
打包并压缩
 tar -zcvf /root/etc.tar.gz /etc/
   47  cd /root/
   48  ls
   49  file etc.tar.gz 
   50  tar -jcvf /opt.tar.bz2 /opt/
   51  ls /
   tar -Jcvf /root/etc.tar.gz /etc/

解包解压缩并指定路径
tar -zxvf etc.tar.gz -C /opt/
tar xf etc.tar.gz -C /opt/


```

### 使用scp实现远程文件传输

```bash
# scp servra.txt root@bastion:/opt/
# ls
# scp root@bastion:/opt/bastion.txt .
# ls

```



### 使用sftp实现远程文件传输

|  ID  |       |                |
| :--: | :---: | -------------- |
|  1   |  ftp  | client         |
|  2   | sftp  | ssh SubService |
|  3   | vsftp | service        |

```bash
sftp instructor@classroom.example.com
instructor@classroom.example.com's password:   Asimov
sftp> cd /tmp
sftp> ls
NIC1                                                                              
NIC1.old                                                                          
NIC2                                                                              
NIC2.old                                                                          
systemd-private-08b92f3d73564b80ab17e5dce36310e9-chronyd.service-Dr3B9a           
systemd-private-08b92f3d73564b80ab17e5dce36310e9-httpd.service-bNcQmh             
systemd-private-08b92f3d73564b80ab17e5dce36310e9-named.service-IsIKUy             
testfile.txt                                                                      
sftp> get testfile.txt 
Fetching /tmp/testfile.txt to testfile.txt
sftp> exit
[root@servera opt]# 
[root@servera opt]# ls
etc  testfile.txt

[root@servera opt]# touch put.txt
[root@servera opt]# sftp instructor@classroom.example.com
instructor@classroom.example.com's password: 
Connected to instructor@classroom.example.com.
sftp> cd /tmp/
sftp> put /opt/put.txt 
Uploading /opt/put.txt to /tmp/put.txt
/opt/put.txt                                    100%    0     0.0KB/s   00:00    
sftp> ls
NIC1                                                                              
NIC1.old                                                                          
NIC2                                                                              
NIC2.old                                                                          
put.txt                                                     


```

### 使用rsync实现同步文件内容

```
-v  显示详细信息
-a  相当于存档模式

本地同步
[root@servera tmp]# rsync -av /var/log/ /tmp

远程同步
[root@servera tmp]# rsync -av /var/log/ serverb:/tmp
[root@servera tmp]# ssh root@serverb ls /tmp

问题：将serverb上的/var/log/同步到，servera当前目录下
[root@servera tmp]# rsync -av serverb:/var/log/  .

a ： echo 123456 > /opt/file
b: echo 66666 > /tmp/file
```

# 第十四章 安装和升级软件包

#### rpm包管理

```bash
安装rpm包
-i  安装
-v  显示过程
-h  以易读方式显示进度条
-e  卸载
[root@foundation0 Packages]# pwd
/content/rhel8.0/x86_64/dvd/AppStream/Packages
[root@foundation0 Packages]# rpm -ivh telnet-0.17-73.el8.x86_64.rpm 
warning: telnet-0.17-73.el8.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID fd431d51: NOKEY
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:telnet-1:0.17-73.el8             ################################# [100%]

[root@foundation0 Packages]# rpm -e telnet 
[root@foundation0 Packages]# rpm -qa | grep telnet

rpm -q 软件包名称
-q:query 查询  和其他参数配合
-l：list		列出软件包安装后给系统带来的所有文件
-a：all		查看所有已安装的软件包
-c：configure 查看软件包给系统带来的配置文件
-f：file      可以查看文件属于哪个软件包安装的
-i：information  软件包信息

rpm -qa | grep telnet
rpm -qa | grep httpd
rpm -q httpd
rpm -ql httpd
rpm -qc httpd
rpm -qf httpd
rpm -qi httpd

[root@foundation0 Packages]# rpm -qf /etc/httpd/conf/httpd.conf
httpd-2.4.37-10.module+el8+2764+7127e69e.x86_64

```

#### YUM配置文件

```bash
yum源软件配置方式
[root@servera yum.repos.d]# mkdir /repodir
[root@servera yum.repos.d]# mv * /repodir
[root@servera yum.repos.d]# vim rhel.repo
[rhel]
name=rhel
baseurl=http://content/rhel8.0/x86_64/dvd/BaseOS
gpgcheck=0

[rhel2]
name=rhel2
baseurl=http://content/rhel8.0/x86_64/dvd/AppStream
gpgcheck=0


[root@servera yum.repos.d]# yum repolist all
Last metadata expiration check: 0:05:27 ago on Sun 01 Mar 2020 04:17:03 PM CST.
repo id                             repo name                         status
rhel                                rhel                              enabled: 1,658
rhel2                               rhel2                             enabled: 4,672
```

#### yum-config-manager

```bash
# yum provides yum-config-manager
# yum install -y dnf-utils-4.0.2.2-3.el8.noarch
# yum-config-manager -h
# rm -f /etc/yum.repos.d/*
# yum-config-manager --add-repo=file:///content/rhel8.0/x86_64/dvd/AppStream/
# yum-config-manager --add-repo=file:///content/rhel8.0/x86_64/dvd/BaseOS/
# vim content_rhel8.0_x86_64_dvd_AppStream_.repo
添加gpgcheck=0
# vim content_rhel8.0_x86_64_dvd_BaseOS_.repo
添加gpgcheck=0
# yum clean all
# yum repolist all
结果：
repo id                               repo name                status
content_rhel8.0_x86_64_dvd_AppStream_ created by dnf config-ma enabled: 4,672
content_rhel8.0_x86_64_dvd_BaseOS_    created by dnf config-ma enabled: 1,658

开启或关闭
[root@servera /]# yum-config-manager --disable rhel-8.0-for-x86_64-appstream-rpms（yum 池ID）
[root@servera /]# yum repolist all
Red Hat Enterprise Linux 8.0 BaseOS (dvd)           176 kB/s | 2.7 kB     00:00    
repo id                            repo name                          status
rhel-8.0-for-x86_64-appstream-rpms Red Hat Enterprise Linux 8.0 AppSt disabled
rhel-8.0-for-x86_64-baseos-rpms    Red Hat Enterprise Linux 8.0 BaseO enabled: 1,660
[root@servera /]# yum-config-manager --enable rhel-8.0-for-x86_64-appstream-rpms
[root@servera /]# yum repolist all
Red Hat Enterprise Linux 8.0 AppStream (dvd)        192 kB/s | 3.2 kB     00:00    
Red Hat Enterprise Linux 8.0 BaseOS (dvd)           368 kB/s | 2.7 kB     00:00    
repo id                            repo name                          status
rhel-8.0-for-x86_64-appstream-rpms Red Hat Enterprise Linux 8.0 AppSt enabled: 4,672
rhel-8.0-for-x86_64-baseos-rpms    Red Hat Enterprise Linux 8.0 BaseO enabled: 1,658
```

#### yum 常见命令

```bash
yum常见命令

yum list httpd
yum list http*
yum search httpd
yum search ssh
yum info httpd-manual
[root@servera /]# yum provides /var/www/html
yum update
yum install  包名
yum remove   包名
yum install -y httpd
[root@servera /]# yum install  -y autofs
[root@servera /]# yum remove -y autofs
[root@servera /]# yum history

yum clean all 清除缓存

yum list
yum repolist 
yum repolist all

servera:
yum grouplist
yum groupinfo 'Server with GUI'
yum groupinstall -y 'Server with GUI'
startx 切图形
```

#### input，output

```bash
yum源文件倒入密钥方式
[foundation] # 

[ucf-rhel-8-for-x86_64-baseos-rpms]
name="Local classroom copy of BaseOS on dvd"
baseurl=file:///content/rhel8.0/x86_64/dvd/BaseOS
enabled=1         1生效，0不生效 ，不写相当于1
gpgcheck=1
gpgkey=file:///content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release
[ucf-rhel-8-for-x86_64-appstream-rpms]
name="Local classroom copy of AppStream on dvd"
baseurl=file:///content/rhel8.0/x86_64/dvd/AppStream
gpgcheck=1
gpgkey=file:///content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release
[ucf-upd]
name="Updates for UCF physical systems"
baseurl=file:///content/rhel8.0/x86_64/ucfupdates
gpgcheck=1
gpgkey=file:///content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release






rpm -qa | grep pub
[root@servera yum.repos.d]# rpm --import http://content.example.com/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release

rpm -e gpg-pubkey-d4082792-5b32db75 gpg-pubkey-fd431d51-4ae0493b

yum密钥方式
[rhel-8.0-for-x86_64-baseos-rpms]
baseurl = http://content.example.com/rhel8.0/x86_64/dvd/BaseOS
enabled = true
gpgcheck = true  如果此处为true，下面gpgkey一定要写公钥地址，否则不能安装，前提是卸载所有之前导入的密钥
gpgkey = http://content.example.com/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release
name = Red Hat Enterprise Linux 8.0 BaseOS (dvd)
[rhel-8.0-for-x86_64-appstream-rpms]
baseurl = http://content.example.com/rhel8.0/x86_64/dvd/AppStream
enabled = 1
gpgcheck = true
gpgkey = http://content.example.com/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release
name = Red Hat Enterprise Linux 8.0 AppStream (dvd)
```

```bash
练习1：课堂笔记上的练习（不交）
练习2：RHCSA8-Q（交）
配置网络设置
配置您的系统以使用默认存储库
创建用户帐户
创建协作目录
配置 NTP
配置用户帐户
查找文件
查找字符串
创建存档

每天3个题左右，做题结果及过程，放置在word文档中，

1、时间       ：下周一前提交
2、作业提交邮箱 ：Rhce8@easthome.com
3、命名方式     ：BJ9014200518（晚班直播）_自己姓名     这块复制就行了
4、提交形式   ：文档形式提交到邮箱，内容为题目、练习过程、测试结果即可，不要太复杂

```

# 第十五章 访问Linux文件系统



windows   fat32   ntfs

linux  ext3  ext4  xfs

|                            |                                       |      |
| -------------------------- | ------------------------------------- | ---- |
| /dev/sda、/dev/sdb         | STAT/SAS（新SCSI技术）/USB 附加存储   |      |
| /dev/vda、/dev/vdb         | virtio-blk 超虚拟化存储（部分虚拟机） |      |
| /dev/nvme0，/dev/nvme1     | 附加存储 （SSD）                      |      |
| /dev/mmcblk0、/dev/mmcblk1 | SD卡                                  |      |

新磁盘--分区--格式化--挂载--使用



分区

主分区        最多可分4个  格式化   3P+1E 

扩展分区   扩展分区只能有1个，占一个主分区位置，扩展分区内可以分多个逻辑分区  不能格式化

逻辑分区    存在于扩展分区之中，可以格式化，数量可以多个    格式化

3p+1E    1E（L1 L2 L3  L4 ）

4P

1E （L1  Ln）

1P+1E

```bash
ssh root@servera
[root@servera /]# fdisk -l  查看当前磁盘状态
Disk /dev/vda: 10 GiB, 10737418240 bytes, 20971520 sectors  被使用
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x16a1e057

Device     Boot Start      End  Sectors Size Id Type
/dev/vda1  *     2048 20971486 20969439  10G 83 Linux


Disk /dev/vdb: 5 GiB, 5368709120 bytes, 10485760 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

此处没有任何分区信息，可能没有使用

Disk /dev/vdc: 5 GiB, 5368709120 bytes, 10485760 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


分区：（添加一块新硬盘/dev/vdc后，对其分1个区）
# fdisk /dev/vdc
# m   看帮助  n 创建  p 查看  d 删除 w保存并退出
# n
# p
# 回车    默认选1
# 回车    不以扇区数量形式分区
# +1G
# p
# w
fdisk  -l

[root@servera /]# mkfs.ext4 /dev/vdc1

[root@servera /]# blkid 
/dev/vda1: UUID="884f47c9-a69d-4c5b-915d-6b7c9c74c923" TYPE="xfs" PARTUUID="16a1e057-01"
/dev/vdb: UUID="3a0732a6-7192-4e9e-9c02-d7b82877bbf3" TYPE="xfs"
/dev/vdc1: UUID="8ba7e337-ce4d-413c-b678-12dd25f7d6b3" TYPE="ext4"


lsblk  
[root@servera /]# lsblk
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
vda    252:0    0  10G  0 disk 
└─vda1 252:1    0  10G  0 part /
vdb    252:16   0   5G  0 disk 
vdc    252:32   0   5G  0 disk 
└─vdc1 252:33   0   1G  0 part


mount 选项 设备名  挂载点

df -h

cd /mnt/
ls
mkdir mydata
mount /dev/vdc1 /mnt/mydata/
echo $?
[root@servera /]# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        388M     0  388M   0% /dev
tmpfs           411M     0  411M   0% /dev/shm
tmpfs           411M   16M  395M   4% /run
tmpfs           411M     0  411M   0% /sys/fs/cgroup
/dev/vda1        10G  1.5G  8.6G  15% /
tmpfs            83M     0   83M   0% /run/user/0
/dev/vdc1       976M  103M  807M  12% /mnt/mydata

[root@servera /]# cd /
[root@servera /]# umount /mnt/mydata
[root@servera /]# mount UUID="592313b8-c098-47f3-b278-b0fd6bcfa725" /mnt/mydata
[root@servera /]# df -h

查看挂载后的文件系统类型
[root@servera /]# mount
/dev/vdc1 on /mnt/mydata type ext4 (rw,relatime,seclabel)
```

### 查看文件系统

```bash
df -h    查看挂载状态
blkid     设备ID，文件系统类型
fdisk  -l  看所有磁盘状态 
lsblk	 文件系统及分区状态
du		  查看文件大小

[root@servera /]# dd if=/dev/zero of=bigfile  bs=1M count=100 生成一个100M文件
[root@servera /]# du -sh bigfile 
100M	bigfile
du -h /etc/
du -sh /etc/

```

### 卸载文件系统

```bash
[root@servera /]# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        892M     0  892M   0% /dev
tmpfs           915M     0  915M   0% /dev/shm
tmpfs           915M   17M  899M   2% /run
tmpfs           915M     0  915M   0% /sys/fs/cgroup
/dev/vda1        10G  1.6G  8.5G  16% /
tmpfs           183M     0  183M   0% /run/user/0
/dev/vdb        5.0G   68M  5.0G   2% /mnt/dir1
[root@servera /]# 
[root@servera /]# 
[root@servera /]# cd /mnt/dir1
[root@servera dir1]# umount /dev/vdb     卸载文件系统名称的方式
umount: /mnt/dir1: target is busy.
[root@servera dir1]# cd ..
[root@servera mnt]# umount /dev/vdb 
[root@servera mnt]# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        892M     0  892M   0% /dev
tmpfs           915M     0  915M   0% /dev/shm
tmpfs           915M   17M  899M   2% /run
tmpfs           915M     0  915M   0% /sys/fs/cgroup
/dev/vda1        10G  1.6G  8.5G  16% /
tmpfs           183M     0  183M   0% /run/user/0

[root@servera mnt]# umount /mnt/dir1   另一种卸载方式

```

### 文件查找

```bash
locate
 136  updatedb
  137  locate passwd
  138  locate -i image
  139  locate -n 5  image


find 
find / -name sshd_config
find /etc -name sshd_config
find /etc -name '*pass*'
find / -iname '*pass*'
cd /home/
ls
find / -user student
cd student/
ll -a
find / -group student
id student
find /home -uid 1000
man find
find /home/ -gid 1000


cd /home
find /home/ -perm 700

find /etc/ -size 10M
find /etc/ -size +10M
find /etc/ -size -10M

ll -a
cd /etc/
ll -h
find ./ -size +1k    如果是小于1k   用-1k
du -sh man_db.conf 

将系统中student用户的文件复制到/root/studentdir，并且保留权限
[root@servera ~]# find / -user student -exec cp -a {} /root/studentdir/ \;
```

# 第十六章 分析服务器获取支持

cockpit 

```bash
[root@servera /]# yum install -y cockpit
[root@servera /]# systemctl start cockpit
[root@servera /]# systemctl status cockpit

添加开机自启动方式：
vim /usr/lib/systemd/system/cockpit.service
[Install]
WantedBy=multi-user.target
systemctl enable cockpit

[root@serveraaa /]# firewall-cmd --permanent --add-service=cockpit
success
[root@serveraaa /]# firewall-cmd --reload
success
[root@serveraaa /]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp1s0
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
 
 netstat -ntlp  | grep 9090

连接cockpit
foundation  连接servera
浏览器  http：//172.25.250.10:9090
添加信任
输入用户名密码  root  redhat
```

#### KVM安装操作系统

```bash
1、[root@foundation0 ~]# yum install -y lrzsz
2、Xshell远程连接foundation0
	windows连接foundation上ens256网卡的ip，具体ip地址可查看VMnet8分配网段
3、向Xshell界面里面拖动软件或镜像文件
4、使用kvm软件安装系统
```

