an在您的系统上执行以下所有步骤。

[toc]

## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		安装和配置 Ansible

**[foundation]**

```bash
$ ssh greg@172.25.250.254
```

**[172.25.250.254|bastion]**

```bash
$ sudo yum install -y ansible
$ mkdir -p /home/greg/ansible/roles
$ cd /home/greg/ansible
$ cp /etc/ansible/ansible.cfg .
$ vim ansible.cfg
```
```ini
[defaults]
inventory      = /home/greg/ansible/inventory
roles_path    = /home/greg/ansible/roles
#roles_path    = /home/greg/ansible/roles:/usr/share/ansible/roles
host_key_checking = False
remote_user = root
```
```bash
$ ansible --version
$ ansible-galaxy list

$ vim /home/greg/ansible/inventory
```
```ini
[all:vars]
ansible_password=redhat
[dev]
172.25.250.9
[test]
172.25.250.10
[prod]
172.25.250.[11:12]
[balancers]
172.25.250.13
[webservers:children]
prod
```

```bash
$ ansible-inventory --graph
$ ansible all -a whoami
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建和运行 Ansible 临时命令

**[172.25.250.254|bastion]**

```bash
$ vim /home/greg/ansible/adhoc.sh
```
```bash
#!/bin/bash

ansible all -m yum_repository -a '\
name="EX294_BASE" \
description="EX294 base software" \
baseurl="http://content/rhel8.0/x86_64/dvd/BaseOS" \
gpgcheck="yes" \
gpgkey="http://content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release" \
enabled="yes"'

ansible all -m yum_repository -a '\
name="EX294_STREAM" \
description="EX294 stream software" \
baseurl="http://content/rhel8.0/x86_64/dvd/AppStream" \
gpgcheck="yes" \
gpgkey="http://content/rhel8.0/x86_64/dvd/RPM-GPG-KEY-redhat-release" \
enabled="yes"'
```
```bash
$ chmod +x /home/greg/ansible/adhoc.sh
$ /home/greg/ansible/adhoc.sh
```

```bash
$ ansible all -a 'yum repolist'
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		安装软件包

**[172.25.250.254|bastion]**

```bash
$ vim /home/greg/ansible/packages.yml
```

```yaml
---
- name: 安装软件包
  hosts: all 
  tasks:
  - name: install the latest version
    yum:
      name: "{{ item }}"
      state: latest
    loop:
    - php
    - mariadb
    when: "'dev' in group_names or 'test' in group_names or 'prod' in group_names"
  - block:
    - name: install the 'Development tools' package group
      yum:
        name: "@RPM Development Tools"
        state: present
    - name: upgrade all packages
      yum:
        name: '*' 
        state: latest
    when: "'dev' in group_names"
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		使用 RHEL 系统角色

**[172.25.250.254|bastion]**

```bash
$ sudo yum -y install rhel-system-roles
$ vim ansible.cfg
```
```ini
...
roles_path    = /home/greg/ansible/roles:/usr/share/ansible/roles
```
```bash
$ ansible-galaxy list
$ cp /usr/share/doc/rhel-system-roles/timesync/example-timesync-playbook.yml /home/greg/ansible/timesync.yml
$ vim /home/greg/ansible/timesync.yml
```
```yaml
---
- hosts: all
  vars:
    timesync_ntp_servers:
      - hostname: 172.25.254.254
        iburst: yes
  roles:
    - rhel-system-roles.timesync
```
```bash
$ ansible-playbook /home/greg/ansible/timesync.yml
```
```bash
$ ansible all -m shell -a 'grep ^server /etc/chrony.conf'
$ ansible all -m shell -a 'timedatectl | grep -B 1 NTP'
```



#### ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		使用 Ansible Galaxy 安装角色

**[172.25.250.254|bastion]**

```bash
$ vim /home/greg/ansible/roles/requirements.yml
```

```yaml
---
- src: http://materials/haproxy.tar
  name: balancer
- src: http://materials/phpinfo.tar
  name: phpinfo
```

```bash
$ ansible-galaxy install -r /home/greg/ansible/roles/requirements.yml -p   /home/greg/ansible/roles  
```

```bash
$ ansible-galaxy list
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建和使用角色

**[172.25.250.254|bastion]**

```bash
$ cd roles/
$ ansible-galaxy init apache
$ cd ..
$ ansible-galaxy list
$ vim roles/apache/tasks/main.yml
```
```yaml
---
- name: install the latest version of Apache
  yum:
    name: httpd
    state: latest
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
- name: Template a file
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
```
```bash
$ vim roles/apache/templates/index.html.j2
```
```jinja2
Welcome to {{ ansible_fqdn }} on {{ ansible_default_ipv4.address }}
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		从 Ansible Galaxy 使用角色

**[172.25.250.254|bastion]**

```bash
$ vim /home/greg/ansible/roles.yml
```
```yaml
---
- name: 从 Ansible Galaxy 使用角色1 
  hosts: webservers
  roles:
  - apache

- name: 从 Ansible Galaxy 使用角色2 
  hosts: balancers
  roles:
  - balancer

- name: 从 Ansible Galaxy 使用角色3 
  hosts: webservers
  roles:
  - phpinfo
```
```bash
$ ansible-playbook roles.yml
```
**[foundation]**
<kbd>firefox</kbd>

- `http://172.25.250.11/hello.php`
- `http://172.25.250.12/hello.php`



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建和使用逻辑卷

**[172.25.250.254|bastion]**

```bash
$ vim /home/greg/ansible/lv.yml
```
```yaml
---
- name: 创建和使用逻辑卷
  hosts: all
  tasks:
  - block:
    - name: Create a logical volume of 1500m
      lvol:
        vg: research
        lv: data
        size: 1500
    - name: Create a ext4
      filesystem:
        fstype: ext4
        dev: /dev/research/data
    rescue:
    - debug:
        msg: Could not create logical volume of that size
    - name: Create a logical volume of 800m
      lvol:
        vg: research
        lv: data
        size: 800
    - name: Create a ext4
      filesystem:
        fstype: ext4
        dev: /dev/research/data
      when: ansible_lvm.vgs.research is defined
      ignore_errors: yes
    - debug:
        msg: Volume group done not exist
      when: ansible_lvm.vgs.research is undefined
```
```bash
$ ansible-playbook /home/greg/ansible/lv.yml
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		生成主机文件

**[172.25.250.254|bastion]**

```bash
$ wget http://materials/hosts.j2
$ vim hosts.j2
```
```jinja2
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain
{% for host in groups['all'] %}
{{ hostvars[host]['ansible_facts']['default_ipv4']['address'] }} {{ hostvars[host]['ansible_facts']['fqdn'] }} {{ hostvars[host]['ansible_facts']['hostname'] }}
{% endfor %}
```
```bash
$ vim hosts.yml
```
```yaml
---
- name: 生成主机文件
  hosts: all 
  tasks:
  - name: Template a file to /etc/myhosts
    template:
      src: /home/greg/ansible/hosts.j2
      dest: /etc/myhosts
    when: '"dev" in group_names'
```
```bash
$ ansible-playbook hosts.yml 
$ ansible dev -m shell -a 'cat /etc/myhosts'
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		修改文件内容

**[172.25.250.254|bastion]**

```bash
$ vim /home/greg/ansible/issue.yml
```
```yaml
---
- name: 修改文件内容
  hosts: all
  tasks:
  - name: Copy using inline content1
    copy:
      content: 'Development'
      dest: /etc/issue
    when: "inventory_hostname in groups.dev"
  - name: Copy using inline content2
    copy:
      content: 'Test'
      dest: /etc/issue
    when: "inventory_hostname in groups.test"
  - name: Copy using inline content3
    copy:
      content: 'Production'
      dest: /etc/issue
    when: "inventory_hostname in groups.prod"
```
```bash
$ ansible-playbook /home/greg/ansible/issue.yml
```
```bash
$ ansible-doc dev -a 'cat /etc/issue'
$ ansible test -a 'cat /etc/issue'
$ ansible prod -a 'cat /etc/issue'
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建 Web 内容目录

**[172.25.250.254|bastion]**

```bash
$ vim /home/greg/ansible/webcontent.yml
```
```yaml
---
- name: 创建 Web 内容目录
  hosts: dev
  roles:
  - apache
  tasks:
  - name: Create a directory if it does not exist
    file:
      path: /webdev
      state: directory
      group: webdev
      mode: '2775'
  - name: Create a symbolic link
    file:
      src: /webdev
      dest: /var/www/html/webdev
      state: link
  - name: Copy using inline content
    copy:
      content: 'Development'
      dest: /webdev/index.html
      setype: httpd_sys_content_t
```
```bash
$ ansible-playbook /home/greg/ansible/webcontent.yml
```

**[172.25.250.9|workstation]**

```bash
$ curl http://172.25.250.9/webdev/
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		生成硬件报告

**[172.25.250.254|bastion]**

```bash
$ vim /home/greg/ansible/hwreport.yml
```
```yaml
---
- name: 生成硬件报告
  hosts: all 
  vars:
    hw_all:
    - hw_name: HOST
      hw_cont: "{{ inventory_hostname | default('NONE', true) }}"
    - hw_name: MEMORY
      hw_cont: "{{ ansible_memtotal_mb | default('NONE', true) }}"
    - hw_name: BIOS
      hw_cont: "{{ ansible_bios_version | default('NONE', true) }}"
    - hw_name: DISK_SIZE_VDA
      hw_cont: "{{ ansible_devices.vda.size | default('NONE', true) }}"
    - hw_name: DISK_SIZE_VDB
      hw_cont: "{{ ansible_devices.vdb.size | default('NONE', true) }}"
  tasks:
  - name: 1
    get_url:
      url: http://materials/hwreport.empty
      dest: /root/hwreport.txt 
  - name: 2
    lineinfile:
      path: /root/hwreport.txt
      regexp: '^{{ item.hw_name }}='
      line: "{{ item.hw_name }}={{ item.hw_cont }}"
    loop: "{{ hw_all }}"
```
```bash
$ ansible-playbook /home/greg/ansible/hwreport.yml
$ ansible all -a 'cat /root/hwreport.txt'
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建密码库

**[172.25.250.254|bastion]**

```bash
$ vim ansible.cfg
```

```ini
...
vault_password_file = /home/greg/ansible/secret.txt
```

```bash
$ vim /home/greg/ansible/locker.yml
```
```yaml
---
pw_developer: Imadev
pw_manager: Imamgr
```
```bash
$ echo whenyouwishuponastar > /home/greg/ansible/secret.txt
$ ansible-vault encrypt /home/greg/ansible/locker.yml
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		创建用户帐户

**[172.25.250.254|bastion]**

```bash
$ wget http://materials/user_list.yml -P /home/greg/ansible
$ vim /home/greg/ansible/users.yml
```

```yaml
---
- name: 创建用户帐户
  hosts: all
  vars_files:
  - /home/greg/ansible/locker.yml
  - /home/greg/ansible/user_list.yml
  tasks:
  - name: Ensure group
    group:
      name: devops
    when: inventory_hostname in groups.dev or inventory_hostname in groups.test
    
  - name: Add the user1 
    user:
      name: "{{ item.name }}"
      password: "{{ pw_developer | password_hash('sha512', 'mysecretsalt') }}"
      groups: devops
    loop: "{{ users }}"
    when: item.job == 'developer' and (inventory_hostname in groups.dev or inventory_hostname in groups.test)

  - name: Ensure group
    group:
      name: opsmgr
    when: inventory_hostname in groups.prod
    
  - name: Add the user1
    user:
      name: "{{ item.name }}"
      password: "{{ pw_manager | password_hash('sha512', 'mysecretsalt') }}"
      groups: opsmgr
    loop: "{{ users }}"
    when: item.job == 'manager' and inventory_hostname in groups.prod
```

```bash
$ ansible-playbook /home/greg/ansible/users.yml
```



## ○ <font style="font-size:80%">复查</font> ○ <font style="font-size:80%">完成</font>		更新 Ansible 库的密钥

**[172.25.250.254|bastion]**

```bash
$ wget http://materls/salaries.yml
$ ansible-vault rekey --ask-vault-pass salaries.yml
Vault password: `insecure8sure`
New Vault password: `bbs2you9527`
Confirm New Vault password: `bbs2you9527`
Rekey successful
$ ansible-vault view salaries.yml
```

```bash
$ ansible-vault view salaries.yml
Vault password: `bbs2you9527`
haha
```

