| 第一天       | 第二天                       | 第三天                | 第四天                |
| ------------ | ---------------------------- | --------------------- | --------------------- |
| 介绍Ansible  | 管理变量和事实               | 管理大项目            | 自动执行Linux管理任务 |
| 部署Ansible  | 实施任务控制                 | 利用角色简化Playbook  | 总复习                |
| 实施Playbook | 在被管理节点上创建文件或目录 | 对Ansible进行故障排除 |                       |
|              |                              |                       |                       |

# 第一章 介绍ansible

### install-ansible

```bash
网站
yum



网站：
https://fedoraproject.org/wiki/EPEL
 # yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
镜像站方式：
https://www.centos.org/
或
http://mirrors.163.com/centos/8/
或
https://developer.aliyun.com/mirror/centos?spm=a2c6h.13651102.0.0.3e221b11ZQrqR5


yum
yum install -y ansible

[root@workstation ~]# rpm -qc ansible
/etc/ansible/ansible.cfg   配置文件
/etc/ansible/hosts  清单文件


pip安装

[root@foundation0 ~]# python3 --version
Python 3.6.8
[root@foundation0 ~]# rpm -qa | grep pip
python3-pip-9.0.3-13.el8.noarch
[root@foundation0 ~]# pip3 install ansible


```

# 第二章 部署Ansible

### 配置文件

#### 配置文件优先级

```bash
$ /etc/ansible/ansible.cfg
ansible --version
$ cp /etc/ansible/ansible.cfg /home/student/.ansible.cfg
ansible --version
$ mkdir /home/student/playbook/
$ cp /etc/ansible/ansible.cfg  /home/student/playbook/
$ cd /home/student/playbook/
ansible --version
# su - root
# vim  /etc/profile 最后一行
# export ANSIBLE_CONFIG=/opt/ansible.cfg   （此时/opt下需要有ansible.cfg配置文件）
# source /etc/profile   加载
# ansible --version
# su - student
$ ansible --version

取消环境变量
# su - root
# Vim  /etc/profile
# export ANSIBLE_CONFIG=/opt/ansible.cfg   （删除这一行）
# source /etc/profile  重新加载
# rm -f  /opt/ansible.cfg
# unset ANSIBLE_CONFIG


只设置某个用户的环境变量：
su - student
$ cd ~
$ vim .bash_profile
$ export ANSIBLE_CONFIG=/opt/ansible.cfg
$ source ./bash_profile
```

#### 配置文件内容

```bash

[defaults]
# some basic default values...
inventory      =  /home/student/playbook/inventory
forks          = 5
poll_interval  = 15
#sudo_user      = root
#ask_sudo_pass = True
#ask_pass      = True
#transport      = smart
#remote_port    = 22
#module_lang    = C
#module_set_locale = False
#roles_path    = /etc/ansible/roles
#host_key_checking = False
#remote_user = root
#module_name = command
#jinja2_extensions = jinja2.ext.do,jinja2.ext.i18n
#vault_password_file = /path/to/vault_password_file
#timeout = 10 ，如果网络不好，可以改为60左右，主要是看ssh是否稳定

[privilege_escalation]
#become=True
#become_method=sudo
#become_user=root
#become_ask_pass=False
```



| ansibel.cfg                    | ansible cmd      | shell cmd                         |
| ------------------------------ | ---------------- | --------------------------------- |
| remote_user=root               | 临时执行 -u root | ssh root@servera                  |
| become=yes,become_ask_pass=yes | -b     -K        | 开启sudo功能，并且输入sudo密码    |
|                                | -k               | 输入ssh连接密码，做了免密就不用了 |
|                                |                  |                                   |

### 清单文件

```bash
vim /etc/ansible/hosts    安装默认生成清单文件

cd ~ 
mkdir public
vim inventory
172.25.250.10

[web]
serverb.lab.example.com
serverc

[prod]
172.25.250.13



:wq

查看清单内有哪些主机
ansible web -i inventory --list-hosts
ansible all -i inventory --list-hosts
ansible ungrouped -i inventory --list-hosts


将清单记录到ansible.cfg配置文件中
[student@workstation public]$ansible --version
[student@workstation public]$ ls
ansible.cfg  inventory
[student@workstation public]$ vim ansible.cfg
inventory      =  /home/student/public/inventory
host_key_checking = False
remote_user = root
[student@workstation public]$ vim inventory
servera
  
[webserver]
serverb
serverc

[dbserver]
db1.example.com
db2.example.com

ansible servera --list-hosts
ansible webserver --list-hosts
ansible dbserver --list-hosts
man ansible-inventory 
ansible-inventory  --graph
ansible all --list-hosts
ansible ungrouped --list-hosts
```

#### 嵌套组

```bash


[webserver]
serverb
serverc

[dbserver]
db1.example.com
db2.example.com

[share:children]
webserver
dbserver

[student@workstation playbook]$ ansible share --list


```

#### 清单规则：

```
指定范围格式：通配符或正则表达式的方法
[START:END]
192.168.[0:15].[0:255] 表示 192.168.0.0-192.168.15.255
server[a:c].example.com  表示   a-c
server[01:15].example.com  表示   server01.example.com-server15
ipv6也可以通过[a:f]这种方式
重点：
all： 所有主机
ungrouped ： 不属于任何一个组的所有主机

验证计算机是否在清单内
ansible 主机成员 --list-hosts

重要：清单中含有名称相同的主机和主机组，ansible命令显示警告并以主机作为其目标，组被忽略。
```

#### 多清单

```bash
[student@workstation playbook]$ ls
ansible.cfg  inventory（目录）  playbook.yml
[student@workstation inventory]$ ls
inventory1  inventory2
[student@workstation inventory]$ cd ..
[student@workstation playbook]$ vim ansible.cfg 
inventory      =  /home/student/playbook/inventory/
[student@workstation playbook]$ ansible webserver --list-hosts
  hosts (2):
    serverb
    serverc
[student@workstation playbook]$ ansible group1 --list-hosts
  hosts (1):
    192.168.10.1

```

#### 执行一些临时命令，指定远程用户及密码

```bash
指定远程用户
[student@workstation public]$ vim ansible.cfg 
remote_user = root
指定远程用户对应的密码
[student@workstation public]$ vim invdir/inventory
[all:vars]
ansible_password=redhat



临时命令
ansible 172.25.250.10 -m ping 

ansibie 172.25.250.10 -a 'useradd user10'
ansibie 172.25.250.10 -a 'id user10'
ansible 172.25.250.10 -m command -a 'id user10'

ansible servera -m shell -a 'useradd user1' 
ansible servera -m shell -a 'id user1' 

ansible servera  -a "useradd user2 && echo 123456 | passwd --stdin user2"  （默认使用的是command模块）
ansible servera  -m shell -a "useradd user2 && echo 123456 | passwd --stdin user2"


[student@workstation public]$ ansible serverc -m user -a 'name=jerry comment="John Doe"'
[student@workstation public]$ ansible serverc -m shell -a 'id jerry'

查看模块帮助
ansible-doc -l | grep user   
ansible-doc user     查看user模块的使用方法


```



# 第三章 PLAYBOOK

### vim 修改缩进

```bash
调整tab键缩进
vim回车-：help-- ：help usr_05.txt
$ ls /etc/vimrc ~/.vimrc 

# vim 进入帮助
# help usr_05.txt找到autocmd FileType
  
$ vim ~/.vimrc   生产环境你可能没有root权限那么做一个自己的vimrc比较合适
set number 
autocmd FileType text  setlocal
修改：
autocmd FileType yaml   setlocal ts=2 sw=2  et
```

### 一个简单的PLAYBOOK及yaml语法

```bash
---
- name: server
  hosts: webserver
  tasks:
  - name: install the latest version of Apache
    yum:
      name: httpd
      state: latest
  
 [student@workstation playbook]$ ansible-playbook playbook.yml --syntax-check

playbook: playbook.yml
[student@workstation playbook]$ ansible-playbook playbook.yml
 
```

### 整体缩进 视图模式

```bash
ctrl+v ， jjj ，I，tab，esc
```

```bash
继续上面的Playbook
---
- name: server
  hosts: webserver   （主机 or  主机组）
  tasks:
  - name: install the latest version of Apache
    yum:
      name: httpd
      state: latest

  - name: Start service httpd, if not started
    service:
      name: httpd
      state: started
      enabled: yes
    
  - name: Copy using inline content
    copy:
      content: "this is test page"
      dest: /var/www/html/index.html
      mode: '0644'

  - name: firewalld running and enabled
    firewalld:
      service: http
      permanent: yes
      state: enabled 
      immediate: yes
      
  [student@workstation playbook]$ ansible-playbook playbook.yml --syntax-check

playbook: playbook.yml
[student@workstation playbook]$ ansible-playbook playbook.yml
```

### 多个play

```bash
---
- name: server
  hosts: webserver
  tasks:
  - name: install the latest version of Apache
    yum:
      name: httpd
      state: latest

  - name: Start service httpd, if not started
    service:
      name: httpd
      state: started
      enabled: yes
    
  - name: Copy using inline content
    copy:
      content: "this is test page"
      dest: /var/www/html/index.html
      mode: '0644'

  - name: firewalld running and enabled
    firewalld:
      service: http
      permanent: yes
      state: enabled
      immediate: yes
      
      
- name: test apache server
  hosts: serverb
  tasks:
  - name: returns a status 200
    uri:
      url: http://serverb/index.html
      return_content: yes
      status_code: 200
      
 [student@workstation playbook]$ ansible-playbook playbook.yml --syntax-check

playbook: playbook.yml
[student@workstation playbook]$ ansible-playbook playbook.yml


以上实验，用ansible-doc 查询课程中的所有模块
```

# 第四章 变量

### 1、变量

全局范围：从命令行执行临时命令时指定的变量   最优先

play范围： 在playbook里面指定变量信息  其次

主机范围 ： 比如清单中主机或主机组指定变量（清单主机优先主机组） 优先级最低

##### 清单中定义变量

```
【bastion】
[greg@bastion ansible]$ pwd
/home/greg/ansible
$ vim inventory 
172.25.250.9   ansible_password=redhat     给主机定义变量

[test]
172.25.250.10
[test:vars]
ansible_password=redhat   给主机组定义变量

[prod]
172.25.250.[11:12]
[balancers]
172.25.250.13

[all:vars]   给所有主机和主机组组定义变量
ansible_password=redhat
```

#### 在PLAYBOOK中定义和使用变量

```yaml
--- 
- name: 1
  hosts: 172.25.250.9
  vars：
  	 user_tom: tom
  vars_files:
    - vars/users.yml  （此文件自行创建）
  tasks:
  - name: Add the user 
    user:
      name: "{{ user_tom }}"     使用变量时，变量开头要加“”双引号，非变量开头不用加双引号
      comment:

```

#### 全局范围-通过命令行执行

```bash
[greg@bastion ansible]$ ansible dev -m shell -a whoami -e ansible_user=root -e ansible_password=redhat
命令行使用变量优先级最高


vim  /home/greg/ansible/ansible.cfg
remote_user = root  设置登录的远程用户为root   

```

#### 主机变量和主机组变量

```bash
172.25.250.9 ansible_user=root ansible_password=redhat

主机组：
[dev:vars]
172.25.250.9  
ansible_user=root ansible_password=redhat


[all:vars]
ansible_password=redhat

可以在playbook里面加载变量
- name: 存储库
  hosts: all
  vars:
    ansible_password: redhat

```

#### 数组的表示方式：

```yaml
[greg@bastion ansible]$ vim vari.yml 
user1_A_name: zhang
user1_B_name: san
user1_C_name: /home/zhangsan
user2_A_name: li
user2_B_name: si
user2_C_name: /home/lisi
改写为
users:
  user1:
    A_name: zhang
    B_name: san
   
  user2:
    A_name: li
    B_name: si
   
    
[greg@bastion ansible]$ vim debug.yml
---
- name: useradd
  hosts: dev
  vars_files:
    - vari.yml
  tasks:
  - name: Add the user
    user:
      name: "{{ users.user1.A_name }}{{ users.user1.B_name }}"
      comment: name is zhangsan

[greg@bastion ansible]$ ansible-playbook debug.yml
[greg@bastion ansible]$ ansible dev -m shell -a 'tail -n 1 /etc/passwd'


应用方法1：
users.user1.A_name
users.user2.B_name

应用方法2：python字典
users['user1']['A_name']

```

##### register 

```bash
1、
[greg@bastion ansible]$ vim register.yml
---
- name: install a packages
  hosts: dev
  tasks:
  - name: install the latest version of Apache
    yum:
      name: httpd
      state: latest
    register: install_result
  - name:  message
    debug: var=install_result

2、在另一个窗口：
ssh root@172.25.250.9
[root@workstation yum.repos.d]# ls
rhel.repo
[rhel]
name=EX294 base software
baseurl=http://content/rhel8.0/x86_64/dvd/BaseOS
gpgcheck=1
gpgkey=http://content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release
[rhel2]
name=EX294 app software
baseurl=http://content/rhel8.0/x86_64/dvd/AppStream
gpgcheck=1
gpgkey=http://content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release

3、
[greg@bastion ansible]$ ansible-playbook register.yml 
```

##### debug

```bash
debug模块，可以使用到playbook中，它可以输出一些字符串，也可以输出变量，或者在执行playbook过程中获取的一些变量。
[greg@bastion ansible]$ vim debug.yml 
---
- name: debug message
  hosts: dev
  vars:
    ansible_password: redhat
    repo_name1: app
    repo_name2: base
  tasks:
  - name:
    debug:
      msg: one {{ repo_name1 }} two {{ repo_name2 }}
  - name:
    debug:
      var: ansible_password
      
[greg@bastion ansible]$ ansible-playbook debug.yml

```

### 2、事实 facts

```bash
临时命令收集
[greg@bastion ansible]$ ansible localhost -m setup
[greg@bastion ansible]$ ansible localhost -m setup -a  filter=ansible_fqdn
[greg@bastion ansible]$ ansible dev -m setup

playbook方式
[greg@bastion ansible]$ vim debug.yml
---
- name: debug message
  hosts: dev
  tasks:
  - debug:
      msg: "{{ ansible_facts.default_ipv4.address }}"
      
[greg@bastion ansible]$ ansible-playbook debug.yml

```

##### 关闭事实

```bash
[greg@bastion ansible]$ vim debug.yml
---
- name: debug message
  hosts: dev
  gather_fact： on/off  true/false
  tasks:
  - debug:
      msg: "{{ ansible_facts.default_ipv4.address }}"
      
[greg@bastion ansible]$ ansible-playbook debug.yml

如果playbook内容和事实收集没有关系，可以关闭可以大量减少playbook执行时间。
注意：考试时不要关闭
```

事实

```bash
- name: report
  hosts: all 
  gather_facts: false  开启或关闭事实收集
  tasks:


查看事实的方式
ansible all -m setup
ansible dev -m setup  -a filter=*fqdn*
ansible dev -m setup  -a filter=*hostname*


魔法变量
ansible  dev -m debug -a var=inventory_hostname
ansible  dev -m debug -a var=groups
ansible  all -m debug -a var=group_names
ansible  all -m debug -a var=hostvars

```

#### 变量相关模拟题：

```yaml
【cd /home/greg/ansible】 以下操作都是在此目录下执行
1、设置变量
[all:vars]
ansible_password=redhat
2、设置远程用户登录为root
vim  /home/greg/ansible/ansible.cfg
remote_user = root  设置登录的远程用户为root
3、

---
- name: 存储库
  hosts: all
  vars:
    base_name: EX294_BASE
    stream_name: EX124_BASE
  tasks:
  - name: BaseOS
    yum_repository:
      name: "{{ base_name }}"
      description: EX294 base software
      baseurl: http://content/rhel8.0/x86_64/dvd/BaseOS
      gpgcheck: yes 
      gpgkey: http://content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-r    edhat-release
      enabled: yes 
  
  - name: stream
    yum_repository:
      name: "{{ stream_name }}"
description: EX294 stream software
      baseurl: http://content/rhel8.0/x86_64/dvd/AppStream
      gpgcheck: yes
      gpgkey: http://content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-r    edhat-release
      enabled: yes
```

#### 事实变量相关模拟题：

```
【考试环境bastion】
$ wget http://materials/hwreport.empty -P /root/hwreport.txt

[greg@bastion ansible]$ vim hw.yml
- name: report
  hosts: all 
  tasks:
  - name: Copy using inline content
    copy:
      content: |
        HOST={{ inventory_hostname }}
        MEMORY={{ ansible_memtotal_mb }}
        BIOS={{ ansible_bios_version }}
        DISK_SIZE_VDA={{ ansible_devices.vda.size }}
        DISK_SIZE_VDB={{ ansible_devices.vdb.size }}
      dest: /root/hwreport.txt

```

### 3、ANSIBLE VAULT

```bash
一、给普通文件加密
[greg@bastion ansible]$ ls
ansible.cfg  debug.yml  inventory  
ansible-vault -h
ansible-vault encrypt debug.yml 
vim debug.yml 
ansible-vault view debug.yml 
ansible-vault edit  debug.yml 
vim debug.yml 
ansible-playbook debug.yml  --ask-vault-pass
ansible-vault decrypt  debug.yml 
vim debug.yml 

二、通过ansible-vault命令直接创建加密文件
ansible-vault create vault.yml
ansible-vault rekey  vault.yml

三、通过密码文件给敏感数据加密
[greg@bastion ansible]$ ls
ansible.cfg  inventory     vault.yml  passwd.yml  
[greg@bastion ansible]$ ansible-playbook vault.yml --vault-password-file=/home/greg/ansible/passwd.yml

四、将密码文件写入ansible.cfg 配置文件中
[greg@bastion ansible]$ vim ansible.cfg 
vault_password_file = /home/greg/ansible/passwd.yml
```

# 第五章 实施任务控制

### 循环

可以在loop循环列表里面定义一些循环体，使用item变量来应用loop中的信息

```yaml
---
未使用循环的方式
- name: service * 2
  hosts: dev
  tasks:
  - name: Start service nfs-server
    service:
      name: nfs-server
      state: started
  - name: Start service chronyd
    service:
      name: chronyd
      state: started
      
loop循环方式：
- name: service * 2
  hosts: dev
  tasks:
  - name: Start service nfs-server
    service:
      name: "{{ item }}"
      state: started
    loop:
      - nfs-server
      - chronyd
      
列表形式
- name: service loop
  hosts: servera
  vars:
    servers:
    - nfs-server
    - chronyd
  tasks:
  - name: Start service
    service:
      name: "{{ item }}"
      state: stopped
    loop: "{{ servers }}"
    
循环散列或字典列表
- name: service loop
  user:
    name: "{{ item.name }}"
    state: present
    group: "{{ item.group }}"
  loop:
    - name: jane
      group: tom
    - name: joe
      group: harry
  
  
- name: service loop
  hosts: servera
  vars_files:
  - vaifile.yml
    
  tasks:  
  - name: service loop
    user:
      name: "{{ item.name }}"
      state: present
      group: "{{ item.group }}"
    loop: "{{ servers }}"
     
  
 vaifile.yml
 servers:
     - name: jane
        group: tom
      - name: joe
        group: harry    
      
      

课上例子:
---
- name: service state
  hosts: dev
  tasks:
  - name: install the latest version of Apache
    yum:
      name: "{{ item }}"
      state: latest
    loop:
      - httpd
      - autofs
```

### when 

```yaml
when的第一个例子；
---
- name: service state
  hosts: all
  tasks:
  - name: install the latest version of Apache
    yum:
      name: "{{ item }}"
      state: absent
    loop:
      - httpd
      - autofs
    when: inventory_hostname == "172.25.250.9"  
    
and  与  多个条件同时为真才执行  
or   或  多个条件有一个为真就执行
    

第二个例子：
---
- name: 安装软件包
  hosts: all
  tasks:
  - name: install the latest version of Apache
    yum:
      name: "{{ item }}"
      state: latest
    loop:
    - php
    - mariadb
    when: '"dev" in group_names or "test" in group_names or "prod" in group_names'

  - name: install the 'Development tools' package group
    yum:
      name: "@RPM Development Tools"
      state: present
    when: '"dev" in group_names'
    
  - name: upgrade all packages
    yum:
      name: '*'
      state: latest
    when: '"dev" in group_names'

```

##### ignore_errors

```yaml
[greg@bastion ansible]$ vim ignore_errors.yml
---
- name: test error
  hosts: dev
  tasks:
  - name:  touch file
    shell: mkdir  /a/b
#   ignore_errors: yes   第一次执行加#注释，第二次执行取消注释

  - name: Add the user
    user:
      name: johnd
```

##### block

```yaml
---
- name: test error
  hosts: all
  tasks:
  - block:
    - name:  touch file
      shell: mkdir  -p /a/b

    - name: Add the user
      user:
        name: johnd
    when: inventory_hostname == "172.25.250.9"

```

#### （block、rescue、always）

```yaml
---
- name: block
  hosts: dev
  tasks:
  - name:
    block:
    - name: install http
      yum:
        name: http
        state: latest
    rescue:
    - name: install httpd
      yum:
        name: httpd
        state: latest
    always:
    - name: Start service httpd, if not started
      service:
        name: httpd
        state: started
```

# 第六章 在被管理节点上创建文件或目录

### 文件模块介绍

file，copy，lineinfile

| 模块名      | 说明                                                         |
| ----------- | ------------------------------------------------------------ |
| blockinfile | 插入、更新 、删除，自定义标记先包围的多行文本块              |
| file        | 设置权限、所有者、SElinux上下文及常规文件、符号连接、硬链接等 |
| copy        | 远程copy，类似file，可以设置文件属性、SElinux上下文          |
| fetch       | 和copy类似，相反工作方式，从远端拷贝到控制节点               |
| lineinfile  | 改文件某一行时使用                                           |
| stat        | 检测文件状态，类似linux 中stat命令                           |
| synchronize | 围绕rsync一个打包程序。                                      |

sefcontext

```bash
- name: Allow apache to modify files
  sefcontext:
    target: '/var/www/html/index.html'
    setype: httpd_sys_content_t
    state: present

```

```yaml
综合
---
- name: install packages
  hosts: dev
  tasks:
  - name: install apache
    yum:
      name: httpd
      state: latest

  - name: Change file ownership, group and permissions
    file:
      path: /var/www/html/index.html
      owner: apache
      group: apache
      mode: '0644'
      state: touch
  - name: Copy using inline content
    copy:
      content: "testweb"
      dest: /var/www/html/index.html


  - name: Start service httpd, if not started
    service:
      name: httpd
      state: started
      enabled: yes

  - firewalld:
      service: http
      permanent: yes
      state: enabled
      immediate: yes

```

```
lineinfile
 - name: Ensure SELinux is set to enforcing mode
    lineinfile:
      path: /etc/selinux/config
      regexp: '^SELINUX='
      line: SELINUX=permissive

fetch 将远端文件拷贝到本地
- name: Store file into /tmp/fetched/host.example.com/tmp/somefile
  fetch:
    src: /tmp/somefile
    dest: /tmp/fetched


blockinfile

synchronize

template
- name: Template a file to /etc/files.conf
  template:
    src: /mytemplates/foo.j2
    dest: /etc/file.conf


```



### jinja2模板

```bash
第一个例子
[greg@bastion ansible]$ ls
jinja2.j2  temp.yaml
[greg@bastion ansible]$ vim jinja2.j2
{% for i in groups['all'] %}
{{ i }}
{% endfor %}
[greg@bastion ansible]$ vim temp.yaml
---
- name: temp
  hosts: dev
  tasks:
  - name: Template
    template:
      src: /home/greg/ansible/jinja2.j2
      dest: opt/ip_address

```

```bash
生成/etc/hosts
$ cd /home/greg/ansible/
1、wget http://materials/hosts.j2
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
	
{% for i in groups['all'] %}
{{ hostvars[i]['ansible_facts']['default_ipv4']['address'] }} {{ hostvars[i]['ansible_facts']['fqdn'] }} {{ hostvars[i]['ansible_facts']['hostname'] }} 
{% endfor %}

2、 vim /home/greg/ansible/test.yml
---
- name: sync file
  hosts: all 
  tasks:
  - name: Template a file to /etc/files.conf
    template:
      src: hosts.j2
      dest: /opt/HOSTFILE
    when: '"dev" in group_names'
    
3、
[greg@bastion ansible]$ ansible-playbook test.yml 


以json格式查看：
{{ hostvars[i]['ansible_facts'] |  to_nice_json }}
```

# 第七章



### 利用主机模式选择主机

```
清单的书写规则：

[START:END]
192.168.[0:15].[0:255] 表示 192.168.0.0-192.168.15.255
server[a:c].example.com  表示   a-c
server[01:15].example.com  表示   server01.example.com-server15
ipv6也可以通过[a:f]这种方式
重点：
all： 所有主机
ungrouped ： 不属于任何一个组的所有主机

验证计算机是否在清单内
ansible 主机成员 --list-hosts


二、playbook中hosts后面的写法
hosts： all
hosts： ungrouped
hosts： '*'  和all相同
使用特殊字符时，必须添加单引号，否则不生效
hosts：'*.example.com'
hosts：'datacenter*'
列表形式
hosts：servera，serverb
hosts：webserver,serverc
hosts：'devops,server*'
冒号：取代逗号
hosts：lab,&datacenter 匹配lab组同时也属于datacenter组，顺序无所谓&符号时同时也属于的意思
hosts：datacenter,!test2.example.com  表示datacenter组，但不包括test2.。。这个主机
hosts：all,!datacenter1  所有组，但不包含datacenter1组
```

### 配置并行

```
[greg@bastion ansible]$ vim /etc/ansible/ansible.cfg 
#forks          = 5
```

### 滚动更新

```
 - name: sync file
   hosts: all
   serial: 2
   tasks：
```

### 动态清单

### 包含和导入文件

如果playbook很长很复杂，可以拆分成较小的文件便于管理，以模块话管理，可以将多个不同功能的play，组合成一个主要的playbook，将文件中的任务列表插入play，这样可以将这种模块化的play应用到不同场景。

##### 包含与导入

```bash
Ansible可以支持两种方法将文件放入playbook中：

包含：属于动态操作。playbook运行期间，使用到相关内容时处理所包含的内容
导入：属于静态才做。在运行开始之前，ansible在解析playbook时预处理导入内容
```

##### 导入Playbook

```yaml
第一个tasks任务
[greg@bastion ansible]$ cat tasks/apache.yml 
---
- name:
  yum:
    name: httpd
    state: latest
- name:
  service:
    name: httpd
    enabled: yes
    state: started
第二个tasks任务
[greg@bastion ansible]$ cat tasks/firewall.yml 
---
- name:
  firewalld:
    service: http
    permanent: yes
    state: enabled
    immediate: yes
    
    
包含和导入的方式：
包含
[greg@bastion ansible]$ cat playbook.yml 
---
- name:
  hosts: dev
  tasks:
  - include_tasks: tasks/apache.yml  
  - include_tasks: tasks/firewall.yml


导入+包含
[greg@bastion ansible]$ cat playbook.yml 
---
- name:
  hosts: prod
  tasks:
  - include_tasks: tasks/apache.yml  
  - import_tasks: tasks/firewall.yml


```



# 第八章 利用角色简化PLAYBOOK

### 描述角色结构

角色的作用：提前写好角色任务或模板等，使用时直接应用即可。

角色优点：针对不同业务或功能，创建不同角色。

描述：

playbook：我们知道完成一个项目可以通过编写playbook

角色（roles）：编写角色过程中，我们可以将一个角色设置为一个功能，在一个大项目中可能会使用到多个角色来组成这个项目。在使用角色时要先定义保存角色的储存目录，在目录中创建多个角色，可以通过不同的角色组成，完成不同的项目，我们希望角色不要过于复杂并可以重复利用，以便完成不同项目的开发。



### 角色分类

自定义角色;   根据生产需求自定义角色，应变性强，自行维护

系统角色；分为linux系统角色及rhel系统角色，rhel系统角色如果已订阅的化，可以支持更新。系统角色重复使用率高，健壮性强，厂商维护更新。功能范围单一

### 自定义角色

##### 一、自定义角色流程

一、配置ansible.cfg文件中的roles-path

二、创建一个角色

三、完善角色功能

四、添加控制执行顺序



一、配置ansible.cfg文件中的roles-path

```
1、默认ansible会在roles子目录中查找。可以将自己的角色安装在~/.ansible/roles子目录中。
默认路径：
$ ~/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
如果ansible无法找到该位置角色，会按照ansible.cfg中roles_path指定的目录中查找。
#在没有配置ansible.cfg中roles_path时，使用ansible-galaxy list查看可以看到~/.ansible/role路径提示

2、如果自定义工作目录情况下，我们可以自定义roles目录，并使用ansible.cfg中roles_path字段功能指定角色路径
＄　mkdir /home/greg/ansible/roles
[greg@bastion ansible]$ vim ansible.cfg
roles_path    = /home/greg/ansible/roles
[greg@bastion ansible]$ ansible-galaxy list
# /home/greg/ansible/roles

```

##### 二、创建、使用、控制执行顺序

```
创建角色
目标：学习完后，能够在playbook的项目中创建角色，并应用到playbook中
角色创建流程：
1、创建角色目录结构 
2、创建角色
３、定义角色内容
４、在playbook中使用角色

１、创建角色目录结构 
[greg@bastion ansible]$ ansible-galaxy list
# /home/greg/ansible/roles

２、创建角色
[greg@bastion ansible]$ ansible-galaxy init roles/apache
- roles/apache was created successfully
[greg@bastion ansible]$ ansible-galaxy list
# /home/greg/ansible/roles
- apache, (unknown version)
[greg@bastion ansible]$ tree roles/ａｐａｃｈｅ
apache
    ├── defaults　　　　　　　角色默认变量
    │   └── main.yml
    ├── files				引用的静态文件，可以是一些文件，网页模板等。
    ├── handlers　　　　　　　　处理程序，通常通过模块完成的
    │   └── main.yml
    ├── meta				作者，许可、兼容性
    │   └── main.yml
    ├── README.md　　　　　　　
    ├── tasks　　　　　　　　　　任务，任务的组成就是模块应用，也是角色的主要功能
    │   └── main.yml
    ├── templates　　　　　　　　模板文件，通常使用ｊｉｎｊａ２模板　
    ├── tests					测试
    │   ├── inventory			
    │   └── test.yml
    └── vars				　　角色变量
        └── main.yml
	（用不到的目录可以删除，如ｄｅｆａｕｌｔ、ｖａｒｓ、ｔｅｓｔｓ）

３定义角色内容
#可以使用ROLENAME/tasks/main.yml任务文件的方式，它是有角色运行的主要任务列表。此文件中不用写play抬头信息，只写模块信息，直接顶头即可。
[greg@bastion ansible]$ vim roles/apache/tasks/main.yml
--
# tasks file for roles/apache
- name: install the latest version of Apache
  yum:
    name: httpd
    state: latest
- name: Start service httpd, if not started
  service:
    name: httpd
    state: started
    enabled: yes
- name: Template a file to /etc/files.conf
  template:
    src:  index.html.j2
    dest: /var/www/html/index.html
    owner: root
    group: root
    mode: '0644'
  notify:
  - restart httpd1

- name: permit httpd service
  firewalld:
    service: http
    permanent: yes
    state: enabled
    immediate: yes

＃创建模板文件
[greg@bastion ansible]$ vim roles/apache/templates/index.html.j2
Welcome to {{ ansiｂle_facts['fqdn'] }} on {{ ansible_facts['default_ipv4']['address'] }}

＃创建处理程序	
[greg@bastion ansible]$ vim roles/apache/handlers/main.yml
---
# handlers file for roles/apache
- name: restart httpd1
  service:
    name: httpd
    state: restarted


４、在playbook中使用角色
```

##### 三、控制执行顺序

```
#控制执行顺序
$例子：
一般我们会在ｐｌａｙｂｏｏｋ中tasks下面直接应用reloｓ，但是如果你想在角色之前执行任务，需要加pre_tasks,后面的话加post_tasks。

- name: xxx
  hosts: xxx
  pre_tasks 
  roles
  post_tasks
  
结合上面的例子，添加控制执行顺序
[greg@bastion ansible]$ vim playbook.yml
---
- name: install apache
  hosts: dev
  pre_tasks:
  - debug:
      msg: 'web server'
  roles:
  - apache
  post_tasks:
  - name: Copy file with owner and permissions
    copy:
      src: roles/apache/files/index2.html
      dest: /var/www/html/index2.html
      
＃在ｆｉｌｅｓ目录中创建文件
vim roles/apache/files/index2.html
ｗｅｂ　ｓｅｒｖｅｒ

  
```



##### 使用角色变量

```
---
- name: install apache
  hosts: all
  roles:
    - user.example
    - nfs
在角色里面使用变量
---
- name: install apache
  hosts: all
  roles:
    - user.example
    - nfs
      var1: name1     当前下面两个变量是给nfs这个角色使用的
	  var2： name2  
	变量优先级playbook---》角色目录中vars----角色目录中defaults

```

### 系统角色

```bash
安装系统角色
系统帮助我们定义了一些角色，有不同的功能，需要通过安装软件包。
$ cd /
$ sudo yum search roles
$ sudo yum install -y rhel-system-roles.noarch
$ ansible-galaxy list
[greg@bastion /]$ ansible-galaxy list
# /usr/share/ansible/roles
- linux-system-roles.kdump, (unknown version)
....
- rhel-system-roles.timesync, (unknown version)
# /etc/ansible/roles
 [WARNING]: - the configured path /home/greg/.ansible/roles does not exist.

$ rpm -ql rhel-system-roles.noarch

如果想使用自己的角色以及系统角色
$ cd /home/greg/ansible/
$ vim ansible.cfg
roles_path    = /home/greg/ansible/roles:/usr/share/ansible/roles
$  ansible-galaxy list

使用系统角色
```

##### 简化配置管理

linux6时间服务ntpd，linux7，chronyd，管理员必须配置两个服务，如果用系统角色system-roles.timesync角色就可以配置6、7的时间同步。

使用系统角色

```bash
使用系统角色前，规划好角色路径，内容查看上面系统角色部分。
$ rpm -ql rhel-system-roles.noarch
$ cp /usr/share/doc/rhel-system-roles/timesync/example-timesync-playbook.yml /home/greg/ansible/timesync.yml

[greg@bastion ansible]$ vim timesync.yml
---
- hosts: all 
  vars:
    timesync_ntp_servers:
      - hostname: 172.25.254.254
        iburst: yes 
  roles:
    - rhel-system-roles.timesync

测试结果
$ ansible all -a 'chronyc sources -v'
```



#### 开发角色推荐做法

1、用版本库控制自己角色，也可以通过github

2、存储库不建议存放敏感信息

3、使用ansible-galaxy init 创建角色的目录中以及存放角色目录中不要放没用的目录信息

4、写好readme，和mate，功能、版本、通途、依赖

5、建议针对不同功能创建多个不同角色，而不是一个角色承载多个任务

6、经常重构角色，让你的角色更加完善。

# 环境设置

```bash
[kiosk@foundation0 ~]$ cat > ${COURSE}.sh <<EOF
> #!/bin/bash
> nmcli con down 'Wired connection 1'
> rhe-clerarocures 0
> rht-setcourse ${COURSE}
> rht-vmctl start classroom
> rht-vmctl start all
> EOF
```

# 第九章 排错

执行playbook的时候，根据报错排错，

1、给你一个playbook你需要修复他们

2、查看主机清单，配置文件中出现的错误



##### ANSIBLE 日志文件

排错当中最常用的就是log日志。

默认ansible配置不将输入记录到任何日志文件，它提供了一个内容之日志基础架构，可以通过ansibel.cfg中的defaults里面log_path参数进行配置。或者通过$ANSIBLE_LOG_PATH变量来配置。如果配置了以上介绍的两种其一方式，ansible和ansible-playbook命令的输出会存储到日志文件中。

如果使用日志建议通过logrotate来管理。

```bash
当ansible执行playbook或其他操作发生报错，会记录到日志。
vim /etc/ansible/ansible.cfg 
#log_path = /var/log/ansible.log      文件将产生在/var/log/ansibel.log 普通用户不能写

如果普通用户使用操作方法：
[greg@bastion ansible]$ vim /home/greg/ansible/ansible.cfg
log_path = /home/greg/ansible/ansible.log
然后执行一个playbook之后就会产生日志信息，否则不会生成ansible.log

建议：如果日志文件较大，可以使用logrotate做切割
```

##### debug

```bash
ansible dev -m setup -a filter=*lvm*    已经收集事实
ansible dev -m debug -a var=ansible_lvm  没有收集到事实，所以未查出变量值
 
使用playbook查看debug模块的变量值，在执行playbook之前会收集事实，然后通过debug模块显示出变量信息
---
- name:
  hosts: dev
  tasks:
  - debug:
      var: ansible_lvm
        
第二种
 - debug:
      msg: “{{ ansible_lvm }}”
    
第三种：
 - debug: var=ansible_lvm
 
 
 关闭事实收集
如果要关闭收集，可以编辑配置文件
gathering = explicit
或者在playbook里
gather_facts: yes/no  true/false
```

```
ansible-playbook debug.yml -v 显示详细信息-vvvv显示更详细的信息
```

```
ansible-playbook playbook.yml --start-at-task copy （copy是playbook中某模块的描述，--start-at-task选项可以从某一模块位置开始执行playbook）
```

```
[greg@bastion ansible]$ ansible-playbook playbook.yml --syntax-check
playbook: playbook.yml
```

##### 排错

```
排错点：
一、配置文件
未解除注释
未指定规定路径或用户
角色路径地址写错
没指定远程超级用户
清单路径错误
没关闭指纹验证
二、清单
配置文件中清单路径
清单文件名称
清单内容

三、playbook
hosts： all 指定的主机不在清单中，报错无partten
syntax-errors：注意格式缩进

四、角色排错
1、角色路径 如：roles_path=
2、创建角色    ansible-galaxy init apache  所在路径：/home/greg/ansible/roles
3、编辑角色    关注：roles/apache/tasks/main.yml 关注任务文件中的配做错误
4、使用角色  
---
- name:  install apache 
  hosts: webservers
  roles:
    - apache

提示：
参考答案经过了验证
按自己的方法做，一定要验证结果是否和考试要求一致
```

##### 教材中的案例与设置课程

```
[kiosk@foundation0 ~]$ rht-clearcourse 0 清除所有课程
[kiosk@foundation0 ~]$ rht-setcourse rh294 设置成ansible课程环境就可以运行课程内的脚本了（如果要设置rh134，把rh294环境rh134即可。）
验证方法：
设置后在所有应用里面Education里面可以看到abcd四个学员机，就证明切换成功了
```

# 第十章 自动执行Linux管理任务

### yum模块

yum模块

```bash
bastion ansible]$ ansible-doc -l | grep yum

可以使用此模块配置yum源
- name: Add multiple repositories into the same file (1/2)
  yum_repository:
    name: epel
    description: EPEL YUM repo
    baseurl: https://download.fedoraproject.org/pub/epel/$releasev>
    gpgcheck: yes
    １ http://content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release
    
    
    
[greg@bastion ~]$ ansible-doc rpm_key   
- rpm_key:
    state: present
    key: http://apt.sw.be/RPM-GPG-KEY.dag.txt

综合方法：
---
- name:　配置ｙｕｍ存储库
  hosts: all
  tasks:
  - name:　１
    yum_repository:
      file: rhel
      name: EX294_BASE
      description: "EX294 base software"
      baseurl: "http://content/rhel8.0/x86_64/dvd/BaseOS"
      gpgcheck: yes
      enabled: yes
      gpgkey: "http://content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release"

  - name: ２
    yum_repository:
      file: rhel
      name: EX294_STREAM
      description: "EX294 stream software"
      baseurl: "http://content/rhel8.0/x86_64/dvd/AppStream"
      gpgcheck: yes
      enabled: yes
      gpgkey: "http://content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release"


```

##### 优化多软件包

```bash
---
- name:
  hosts: all
  tasks:
  - name: install the latest version of Apache
    yum:
      name: httpd
      state: latest
  - name: install the latest version of Apache
    yum:
      name: php
      state: latest

- name: install the latest version of Apache
    yum:
      name: "{{ item }}"
      state: latest
    loop:　
      - httpd
      - php

- name: install the latest version of Apache
    yum:
      name:
      - httpd
      - php
      state: latest
      
等同于：yum install -y httpd php
或
loop的这种方式，系统会执行两次独立事务，对每个事务应用一个软件包

yum模块：

state： absent删除, installed,  present确保安装  latest升级到最新版本
latest 等同  yum update

yum remove  yum install 

 name： '*'  代表所有软件包
 name: "@RPM Development tools"   ansible命令里面安装包组要加@
```

### 管理引导过程和调度进程

##### at

```yaml
---
- name:
  hosts: dev
  tasks:
  - name: Schedule a command to execute in 20 minutes as root
    at:
      command: ls -d / >/dev/null
      count: 20
      units: minutes
      
默认是创建一个任务，给root，删除的话使用选项state：absent
```

##### cron

```bash
[greg@bastion ansible]$ cat cron.yml 
---
- name:
  hosts: dev
  tasks:
  - name: Ensure a job that runs at 2 and 5 exists. 
    cron:
      name: "check dirs"
      minute: "*/2"
      hour: "5,2"
      day: 1-10
      user: harry
      job: "ls -alh > /dev/null"

[greg@bastion ansible]$ ansible dev -m shell -a 'crontab -u harry -l'

```

##### service

```bash
---
- name:
  hosts: dev
  tasks:
  - name: install the latest version of Apache
    yum:
      name: httpd
      state: latest
          
  - name: Start service httpd, if not started
    service:
      name: httpd
      state: started
      enabled: yes
~                  
```

##### systemd	

```yaml
[greg@bastion ansible]$ cat systemd.yml 
---
- name:
  hosts: dev
  tasks:
  - name: install the latest version of Apache
    yum:
      name: httpd
      state: latest

  - name: Make sure a service is running
    systemd:
      state: started
      name: httpd
      enabled: yes
      
测试命令：
ansible dev -m shell -a 'systemctl status httpd'
ansible dev -m shell -a 'systemctl is-enabled httpd'
```

reboot

```
- name: Unconditionally reboot the machine with all defaults
  reboot:

```

##### command

##### shell

### 管理用户和身份验证

##### group

```yaml
[greg@bastion ansible]$ cat group.yml 
---
- name:
  hosts: dev
  tasks:
  - name: create admin group
    group:
      name: grouptest
      gid： 10000

等同于：groupadd  grouptest
等同于：groupadd -g 10000 grouptest
```

##### user

```bash
user这个模块可以完成 useradd userdel suermod
[greg@bastion ansible]$ cat group.yml 
---
- name:
  hosts: dev
  tasks:
  - name: create admin group
    group:
      name: grouptest
  - name: Add the user u1
    user:
      name: u1
      comment: John Doe
      uid: 2000
      groups: grouptest
      append: yes    如果想额外添加附加群组，此选项需要yes
      shell: /bin/bash
      password:  "{{ mypassword | password_hash('sha512', 'mysecretsalt') }}"

验证方式：
[greg@bastion ansible]$ ansible dev -m shell -a 'tail /etc/shadow'

https://docs.ansible.com/ansible/latest/reference_appendices/faq.html  查看密码哈希方式，一定注意是512
```

### 管理存储

分区、lvm，格式化、挂载、交换分区

##### parted、lvg、lvol、filesystem、mount

##### parted模块

```yaml
[greg@bastion ansible]$ cat parted.yml 
---
- name:
  hosts: 172.25.250.12
  tasks:
  - name: Create a new primary partition
    parted:
      device: /dev/vdb
      number: 1
      state: present
      part_end: 1GiB

  - name: Create a new primary partition
    parted:
      device: /dev/vdb
      number: 2
      state: present
      part_start: 1074MB
      part_end: 2GiB

  - name: Create a new primary partition
    parted:
      device: /dev/vdb
      number: 3
      state: present
      part_start: 2147MB
      part_end: 3000MB
            
      
```

##### lvg

```yaml
  tasks:
  - name: Create a volume group
    lvg:
      vg: vg100
      pvs: /dev/vdb1,/dev/vdb2  
      pesize: 32

```

##### lvol

```yaml
  - name: Create a logical volume of 512m
    lvol:
      vg: vg100
      lv: lv100
      size: 512
      
      默认单位MB
```

##### filesystem

```bash

  - name: Create a xfs
    filesystem:
      fstype: xfs
      dev: /dev/vg100/lv100
      
    等同于：mkfs.xfs /dev/vg100/lv100

ansible 172.25.250.12 -m shell -a 'lsblk --fs /dev/vg100/lv100
```

##### mount

```yaml
  - name: Touch a directory    创建一个挂载点
    file:
      path: /mnt/dir1
      state: directory

  - name: 将lvm文件系统挂载到/mnt/dir1上
    mount:
      path: /mnt/dir1
      src: /dev/vg100/lv100
      fstype: xfs
      opts: defaults
      state: mounted
      
      总结：
      state：
      present    将配置信息写入/etc/fstab,不挂载
      mounted	 将配置信息写入/etc/fstab,挂载
      unmounted  不改变/etc/fstab信息,卸载
      absent     删除/etc/fstab信息，并卸载
```

