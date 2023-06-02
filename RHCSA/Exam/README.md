<h2>考试要求</h2>
在您的系统上执行以下所有步骤。

[toc]

## 在 mars.domain250.example.com 上执行以下任务。

#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		配置网络设置

**[foundation]**

<kbd>VM servera Control</kbd> /  

```ini
clear login: root
Password: flectrag
```

**[mars]**

```bash
# nmcli con mod 'Wired connection 1' connection.autoconnect true ipv4.addresses 172.25.250.100/24 ipv4.gateway 172.25.250.254 ipv4.dns 172.25.250.254
# nmcli con up 'Wired connection 1'
```

**[foundation]**

```bash
$ ssh root@172.25.250.100
```

**[mars]**

```bash
# hostnamectl set-hostname mars.domain250.example.com
```

```bash
# ip a s
# ip route
# cat /etc/resolv.conf
# hostname
# cat /etc/hostname
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		配置您的系统以使用默认存储库

**[mars]**

```bash
# rpm -ivh http://content/rhel8.0/x86_64/dvd/BaseOS/Packages/dnf-utils-4.0.2.2-3.el8.noarch.rpm
# yum-config-manager --add-repo http://content/rhel8.0/x86_64/dvd/BaseOS
# yum-config-manager --add-repo http://content/rhel8.0/x86_64/dvd/AppStream
# vim /etc/yum.conf
...
gpgcheck=0
```

```bash
# yum -y install samba
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		调试 SELinux

```bash
# ll /var/www/html/ -Z
# semanage fcontext -a -t httpd_sys_content_t "/var/www/html/file1"
# semanage fcontext -m -t httpd_sys_content_t "/var/www/html/file1"
# restorecon -v /var/www/html/file1
# semanage port -a -t http_port_t -p tcp 82
# systemctl restart httpd
```

```bash
# curl http://localhost:82/file1
# curl http://localhost:82/file2
# curl http://localhost:82/file3
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建用户帐户

**[mars]**

```bash
# groupadd sysmgrs
# useradd -G sysmgrs natasha
# useradd -G sysmgrs harry
# useradd -s /bin/false sarah
# for i in natasha harry sarah; do echo flectrag | passwd --stdin $i; done
```

```bash
# ssh natasha@localhost id
# ssh harry@localhost id
# ssh sarah@localhost id
# grep sarah /etc/passwd
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		配置 cron 作业

**[mars]**

```bash
# systemctl status crond
# crontab -e -u natasha
*/2 * * * *     logger "EX200 in progress"
```

```bash
# crontab -l -u natasha
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建协作目录

**[mars]**

```bash
# mkdir /home/managers
# chown :sysmgrs /home/managers
# chmod g+rw,o=- /home/managers
# chmod g+s /home/managers/
```

```bash
# ls -ld /home/managers/
# touch /home/managers/file
# ll /home/managers/file
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		配置 NTP

**[mars]**

```bash
# systemctl status chronyd
# vim /etc/chrony.conf
# systemctl restart chronyd
```

```bash
# timedatectl
# chronyc sources -v

```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		配置 autofs

**[mars]**

```bash
# vim /etc/auto.master.d/rhome.autofs
/rhome	/etc/auto.rhome
# vim /etc/auto.rhome
remoteuser1	-rw	materials.example.com:/rhome/remoteuser1
# systemctl enable --now autofs
```

```bash
# ssh remoteuser1@localhost
remoteuser1@localhost's password: flectrag
$ pwd
$ touch my.file
$ mount | grep rhome
$ <Ctrl+D>
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		配置 /var/tmp/fstab 权限

**[mars]**

```bash
# cp /etc/fstab /var/tmp/fstab
# setfacl -m u:natasha:rw /var/tmp/fstab
# setfacl -m u:harry:- /var/tmp/fstab
```

```bash
# ll /var/tmp/fstab
# getfacl /var/tmp/fstab
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		配置用户帐户

**[mars]**

```bash
# useradd -u 3533 manalo
# echo flectrag | passwd --stdin manalo
```

```bash
# ssh manalo@localhost id
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		查找文件

**[mars]**

```bash
# mkdir /root/findfiles
# find / -user jacques -exec cp -a {} /root/findfiles \;
```

```bash
# ll /root/findfiles/
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		查找字符串

**[mars]**

```bash
# grep ng /usr/share/xml/iso-codes/iso_639_3.xml 
# grep ng /usr/share/xml/iso-codes/iso_639_3.xml > /root/list
```

```bash
# cat /root/list
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建存档

**[mars]**

```bash
# tar -czf /root/backup.tar.gz /usr/local
```

```bash
# tar -tf /root/backup.tar.gz 
# file /root/backup.tar.gz
```



---

## 在 venus.domain250.example.com 上执行以下任务。

#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		设置 root 密码

**[foundation]**

<kbd>VM serverb Control</kbd> , <kbd>Send key</kbd>, <kbd>Ctrl+Alt+Del</kbd>

:computer_mouse: <kbd>Click</kbd>

<kbd>ArrowUp</kbd>, <kbd>e</kbd>

```bash
linux...<space>rd.break console=tty0
```

<kbd>Ctrl</kbd>+<kbd>X</kbd>

```bash
# mount -o remount,rw /sysroot
# mount | grep sysroot
# chroot /sysroot
# echo mima | passwd --stdin root
# touch /.autorelabel
# sync
```

<kbd>Ctrl</kbd>+<kbd>D</kbd>, <kbd>Ctrl</kbd>+<kbd>D</kbd>

```ini
venus login: root
Password: flectrag
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		配置您的系统以使用默认存储库

**[v****s]**

```bash
# rpm -ivh http://content/rhel8.0/x86_64/dvd/BaseOS/Packages/dnf-utils-4.0.2.2-3.el8.noarch.rpm
# yum-config-manager --add-repo http://content/rhel8.0/x86_64/dvd/BaseOS
# yum-config-manager --add-repo http://content/rhel8.0/x86_64/dvd/AppStream
# vim /etc/yum.conf
...
gpgcheck=0
```

```bash
# yum -y install samba
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		调整逻辑卷大小

**[venus]**

```bash
# df -h
# vgs myvol
# blkid /dev/myvol/vo
# lvextend -L 230M /dev/myvol/vo
# resize2fs /dev/myvol/vo
```

```bash
# df -h /reports/
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		添加交换分区

**[venus]**

```bash
# lsblk 
# fdisk /dev/vdb
命令(输入 m 获取帮助)：`n`
分区号 (2-128, 默认  2): `<Enter>
第一个扇区 (1000001-8388574, 默认 1001472): `<Enter>`
上个扇区，+sectors 或 +size{K,M,G,T,P} (1001472-8388574, 默认 8388574): `+756M`
命令(输入 m 获取帮助)：`w`
# mkswap /dev/vdb2
# vim /etc/fstab
...
/dev/vdb2       swap    swap    defaults 0 0
# swapon -a
```

```bash
# swapon
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建逻辑卷

**[venus]**

```bash
# lsblk
# parted /dev/vdb
(parted) print
(parted) mkpart primary 1305M 2500M
(parted) quit
# pvcreate /dev/vdb3
# vgcreate -s 16M qagroup /dev/vdb3
# lvcreate -l 60 -n qa qagroup
# mkfs.ext3 /dev/qagroup/qa
# mkdir /mnt/qa
# vim /etc/fstab 
...
/dev/qagroup/qa /mnt/qa ext3    defaults 1 2
# mount -a
```

```bash
# df
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建 VDO 卷

**[venus]**

```bash
# lsblk 
# vdo create --name=vdough --device=/dev/vdc --vdoLogicalSize=50G
# mkfs.xfs -K /dev/mapper/vdough
# udevadm settle 
# mkdir /vbread
# vim /etc/fstab 
...
/dev/mapper/vdough      /vbread xfs     _netdev 1 2
# mount -a
```

```bash
# df -h /vbread
# sync
# reboot
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		配置系统调优

**[venus]**

```bash
# tuned-adm recommend 
# tuned-adm profile virtual-guest
```

```bash
# tuned-adm active
```