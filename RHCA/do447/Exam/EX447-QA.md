[TOC]

# 重要配置信息

在考试期间，除了您就坐位置的台式机之外，还将使用多个虚拟系统。您不具有台式机系统的根访问权，但具有对虚拟系统的完全 root 访问权。

## 系统信息

![AnsibleTower-Classroom-Architecture](https://i0.hdslb.com/bfs/album/52ee4e916d8995212342c5975ea62111ea6d5f64.png)

|   系统    |     IP地址     |        角色        |  ID  | 开启 |
| :-------: | :------------: | :----------------: | :--: | :--: |
| classroom | 172.25.254.254 | Content, materials |  1   |  Y   |
|  bastion  |                |    ==gateway==     |  2   |  Y   |
|  utility  |                |   ==Git== server   |  3   |      |

LAN

|            系统             |    IP地址     |            角色            |  ID  |
| :-------------------------: | :-----------: | :------------------------: | :--: |
| workstation.lab.example.com | 172.25.250.9  |    Ansible control node    |  1   |
|   servera.lab.example.com   | 172.25.250.10 |    Ansible managed node    |  2   |
|   serverb.lab.example.com   | 172.25.250.11 |    Ansible managed node    |  3   |
|   serverc.lab.example.com   | 172.25.250.12 |    Ansible managed node    |  4   |

|            系统             |    IP地址     |            角色            |  ID  |
| :-------------------------: | :-----------: | :------------------------: | :--: |
|    tower.lab.example.com    | 172.25.250.7  | Ansible Tower control node |  5   |
|   serverd.lab.example.com   | 172.25.250.13 | Ansible Tower managed node |  6   |
|   servere.lab.example.com   | 172.25.250.14 | Ansible Tower managed node |  7   |
|   serverf.lab.example.com   | 172.25.250.15 | Ansible Tower managed node |  8   |

这些系统的IP地址采用静态设置。请勿更改这些设置。主机名称解析已配置为解析上方列出的完全限定主机名，同时也解析主机短名称。

## 帐户信息

- 所有系统的root密码是**redhat**。请勿更改root密码。
- 除非另有指定，否则这将是用于访问其他系统和服务的密码。
- 除非另有指定，否则此密码也应用于您创建的所有帐户或者任何需要设置密码的服务。
- 为方便起见，所有系统上已预装了SSH密钥，允许在不输入密码的前提下通过SSH进行root访问。请勿对系统上的root SSH配置文件进行任何修改。
- **Ansible 控制节点上已创建了用户帐户 student。**此帐户预装了SSH密钥，允许在Ansible控制节点和各个Ansible受管节点之间进行SSH登录。请勿对系统上的student SSH配置文件进行任何修改。您可以从root帐户使用su访问此用户帐户。

## 其他信息

- 一些考试项目可能需要修改Ansible主机清单。您要负责确保所有以前的清单组和项目保留下来，与任何其他更改共存。您还要有确保清单中所有默认的组和主机保留您进行的任何更改。
- 考试系统上的防火墙默认为不启用，SELinux则处于Disabled模式。
- 所有节点，yum存储库已正确配置。
- 有些考试项目会将项目特定信息存储在 Git 存储库中。这些 Git 存储库已在 http://git.lab.example.com:8081 上进行了配置。考试项目 Git 存储库的确切位置将在使用 Git 存储库的考试项目中指定。每个项目 Git 存储库都独立于任何其他考试项目  Git 存储库，且与它们无关。除非另有指定，否则您在 Ansible 控制节点上为管理 Ansible 托管节点所做的所有工作（包括  Ansible playbook、配置文件、主机清单等）都应上传到相应的项目 Git 存储库中，具体由各考试项目指定。 
- 一些项目需要额外的文件，这些文件已在以下位置提供：http://materials.example.com/classroom/ansible/
- 产品文档可从以下位置找到：http://materilas.example.com/docs/
- 其他资源也进行了配置，供您在考试期间使用。关于这些资源的具体信息将在需要这些资源的项目中提供。

## 虚拟系统管理

考试期间，您可以随时关闭或重新引导虚拟机系统。您可以从虚拟系统本身进行这项操作，也可以从物理系统控制虚拟系统。要从物理系统访问或控制考试系统，单击桌面上VM控制台图标。这会显示一个表格，包含每个虚拟机系统的对应按钮，单击特定虚拟机系统的按钮将弹出一个菜单，包含用来控制该系统选项：

- 启动节点点VM-如果指定的虚拟系统未在运行，该选项将启动指定系统。如果系统已经在运行-则该选项无任何作用。
- 重新引导节点VM-正常关闭考试虚拟系统，然后重启。
- 关闭节点VM-正常关闭指定虚拟系统。
- 关闭节点VM电源-立即关闭指定虚拟系统。
- VM控制台节点-这将打开一个窗口，用于连接到指定虚拟系统的控制台。请注意，如果将焦点移动到此窗口，控制台将抓住您的鼠标。要恢复鼠标，同时键入Ctrl+Alt。
- 重建节点VM-将当前VM还原为原始状态。系统将弹出一个单独的窗口，要求您确认操作。警告！！！您在VM上完成的所有操作都将丢失。仅当系统无法使用时才应使用这个功能。在使用这个功能之前，确保关闭VM。

## 重要评测信息

请注意，在评分之前，您的 Ansible 托管节点系统 将重置为考试开始时的初始状态，您编写的 Ansible playbook 将通过以 **student** 用户身份在控制节点上运行来加以应用。在 playbook 运行后，系统会重新启动您的托管节点，然后进行评估，以判断它们是否按照规定进行了配置。

请注意，在评分之前，您的 Ansible 托管节点系统 将重置为考试开始时的初始状态，您创建的 Ansible Tower  作业将通过以指定的用户身份运行来加以应用。在作业运行后，系统会重新启动 Ansible Tower  托管节点，然后进行评估，以判断它们是否按照规定进行了配置。 



# 配置练习环境

##  VMware虚拟机配置

|      |         最小         |     建议     |             原因             |
| :--: | :------------------: | :----------: | :--------------------------: |
| CPU  | >= **12** 个处理器内核 | 直接配置最大 | 内核太少，KVM有2-3个无法启动 |
| MEM  |        不确定        |  **32768**MB   |     内存太小，KVM启动慢      |



# 考试要求

在您的系统上执行以下所有步骤。

## 1. 创建用户-c1

> 在 workstation.lab.example.com 节点上为用户管理员配置Git:
>
> - [ ] Git user name: **gituser**
>  - [ ] Git user email: **gituser@workstation.lab.example.com**
>   - [ ] Default push method: **simple**
>
> Git项目 create_users 负责管理人员与硬件，使用以下信息来相应地更新项目存储库:
>
>  - [ ] 可以点击http://git.lab.example.com:8081/git/create_users.git找到名为create_users的Git项目
>   - [ ] **create_users.yml** 是该项目使用的 playbook 的文件名
>  - [ ] 在**developer**组中添加用户**greg**
>   - [ ] 在**dev**主机组中增加**serverc**节点
>
> 除上面列出的以外，请勿进行任何其他更改

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
# mandb<br>$ man -k git<br>
  $ man git-config<br>
  提示：如果需要网页验证，去 11 题找帐号和密码
</div>
<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">**[student@workstation]**

```bash
$ yum provides git

*$ sudo yum -y install git
[sudo] password for student: `student`

$ git help config | grep name
$ git help config | grep email
$ git help config | grep push

*$ git config --global user.name gituser
*$ git config --global user.email gituser@workstation.lab.example.com
*$ git config --global push.default simple
$ git config --global -l
user.name=gituser
user.email=gituser@workstation.lab.example.com
push.default=simple
...

*$ git clone http://git.lab.example.com:8081/git/create_users.git
*$ cd create_users/
$ ls
ansible.cfg
inventory
user_list.yml
create_users.yml

# 建议配置
$ echo set nu ts=2 et sw=2 paste cuc > ~/.vimrc

*$ vim user_list.yml
```

```yaml
users:
  - name: bob
    group: manager
  - name: sally
    group: developer
# 添加用户和组
  - name: greg
    group: developer
```

```bash
*$ vim inventory
```

```ini
[dev]
servera
# 添加serverc
serverc

[prod]
serverb
```

```bash
*$ ansible-playbook create_users.yml

$ ansible dev -a "id greg"
...
serverc | CHANGED | rc=0 >>
uid=1004(greg) gid=1006(greg) groups=1006(greg),1003(developer)
```
```bash
*$ git add .
*$ git commit -m 1
*$ git push

*$ cd
```

## 2. 管理web服务器-c3

> 在Git存储库 httpd_alias 中管理的Web服务器配置需要添加别名，使用以下信息相应的更新项目仓库文件:
>
> - [ ] 可以点击http://git.lab.example.com:8081/git/httpd_alias.git 找到用来管理http别名的Git项目
> - [ ] 部署新别名的playbook文件是**install_httpd_alias.yml**
> - [ ] 只有在安装别名时，才会重启 httpd 服务器。也就是说，如果已经安装了别名，再运行playbook，则不会重新启动 httpd 服务
>
> 除上面列出的以外，请勿进行任何其他更改

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
Docs » User Guide » Working With Playbooks » <a href='https://docs.ansible.com/ansible/2.8/user_guide/playbooks_intro.html#handlers-running-operations-on-change'>Intro to Playbooks</a><br>&nbsp;&nbsp;&nbsp;&nbsp;<strong style='color: #4380B4'>Handlers: Running Operations On Change</strong>
</div>
**<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[student@workstation]**

```bash
*$ git clone http://git.lab.example.com:8081/git/httpd_alias.git
*$ cd httpd_alias
$ ls
ansible.cfg
inventory
alias.conf
install_httpd_alias.yml

*$ vim install_httpd_alias.yml
```

```yaml
---
- name: Add Apace alias
  hosts: prod
  become: yes
  tasks:
  - name: install the latest version of Apache
    yum:
      name: httpd
      state: latest
  - name: copy alias file
    copy:
      src: alias.conf
      dest: /etc/httpd/conf.d
# 下面是需要添加的内容
    notify: restart
    
  handlers:
    - name: restart
      service:
        name: httpd
        state: restarted
```

```bash
*$ ansible-playbook install_httpd_alias.yml
...
TASK [copy alias file] ``````````````````````````````****
**changed**: [serverb]

**RUNNING HANDLER** [restart] ``````````````````````````````****
changed: [serverb]

PLAY RECAP ````````````````````````*****
serverb : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


*$ ansible-playbook install_httpd_alias.yml
...
TASK [copy alias file] ``````````````````````````````****
**ok**: [serverb]

PLAY RECAP ````````````````````````*****
serverb : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
```bash
*$ git add .
*$ git commit -m 2
*$ git push

*$ cd
```

 

## 3. 管理网站内容-c3

> 在部署到生产之前，dev web 服务器用于测试网站内容
>
> Git 项目 manage_content 包含一个不完整的 playbook ，文件名为 **manage_content.yml **，用于管理dev web服务器的内容。在Git仓库中（http://git.lab.example.com:8081/git/manage_content.git）完善该playbook，实现：
>
> - [ ] 当使用标签**alpha**来运行该playbook时，将生成内容**Que Sera, Sera**并部署到**dev**主机上的 **/var/www/html/index.html** 文件中
> - [ ] 当使用标签**beta**来运行该playbook时，将生成以下信息**Whatever will be, will be**，并且保存到**dev**主机的 **/var/www/html/index.html** 文件中
> - [ ] 如果没有使用以上任何一个标签运行该playbook，则在受管主机上既不产生也不保存任何信息
>
> 除上面列出的以外，请勿进行任何其他更改

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
Docs » User Guide » Working With Playbooks » Advanced Playbooks Features » <a href='https://docs.ansible.com/ansible/2.8/user_guide/playbooks_tags.html'>Tags</a>
</div>
**<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[student@workstation ~]**

```bash
*$ git clone http://git.lab.example.com:8081/git/manage_content.git
*$ cd manage_content
$ ls
ansible.cfg
inventory
manage_content.yml

*$ vim manage_content.yml 
```

方法一、

```yaml
---
- name: Deploy content
  hosts: dev 
  become: yes
# 下面需要自己添加
  tags: never
  tasks:
  - name: Copy using inline content
    copy:
      content: 'Que Sera, Sera'
      dest: /var/www/html/index.html
    tags: alpha
  - name: Copy using inline content
    copy:
      content: 'Whatever will be, will be'
      dest: /var/www/html/index.html
    tags: beta
```

方法二、

```yaml
---
- name: Deploy content
  hosts: dev
  become: yes
# 下面需要自己添加
  tasks:
  - name: deploy on dev alpha
    copy:
      content: "Que sera, Sera"
      dest: /var/www/html/index.html
    tags:
    - alpha
    - never
  - name: deploy on dev beta
    copy:
      content: "Whatever will be, will be"
      dest: /var/www/html/index.html
    tags: [ beta, never ]
```

```bash
*$ ansible-playbook -v -t alpha manage_content.yml
...
TASK [deploy on dev alpha]
...
Que Sera, Sera

*$ ansible-playbook -v -t beta manage_content.yml
...
TASK [deploy on dev beta]
...
Whatever will be, will be

*$ ansible-playbook manage_content.yml
PLAY [Deploy content] ******************************************************

PLAY RECAP *****************************************************************
```
```bash
*$ git add .
*$ git commit -m 3
*$ git push

*$ cd
```

 

## 4. Ansible调优-c5

> 按照以下要求更新Git仓库（ http://git.lab.example.com:8081/git/tune_ansible.git ）中的Ansible配置文件:
>
> - [ ] 默认情况下，**gathering** facts 是被禁用的
> - [ ] 最大并发主机连接数为**45**
>
> 除上面列出的以外，请勿进行任何其他更改

**<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[student@workstation ~]**

```bash
*$ git clone http://git.lab.example.com:8081/git/tune_ansible.git
*$ cd tune_ansible
$ ls
ansible.cfg
inventory

$ rpm -qc ansible
/etc/ansible/ansible.cfg
...

$ grep -B 2 gather /etc/ansible/ansible.cfg
$ grep forks /etc/ansible/ansible.cfg
```

```bash
*$ vim ansible.cfg
```

```ini
[defaults]
...
#forks          = 5
forks     = 45
#gathering = implicit
gathering = explicit
```

```bash
$ ansible-config dump | egrep -i 'forks|gathering'
DEFAULT_FORKS(/home/student/tune_ansible/ansible.cfg) = `45`
DEFAULT_GATHERING(/home/student/tune_ansible/ansible.cfg) = `explicit`

*$ git add .
*$ git commit -m 4
*$ git push

*$ cd
```

 

## 5. 从列表创建用户-c4

> Git仓库（http://git.lab.example.com:8081/git/create_users_complex.git ）包含以下资源：
>
> - [ ] **user_list.yml** ，这是一个用户账户清单，该文件包含多字段: 
>    - [ ] **name**字段指定账户的用户名和登录ID 
>     - [ ] **first**字段指定用户的first name 
>    - [ ] **middle**字段指定用户的middle name
>     - [ ] **last**字段指定用户的last name 
>    - [ ] **uid**字段指定账户关联的用户ID 
> - [ ] **inventory**是本任务涉及的主机清单文件 
>- [ ] 不要对以上文件做任何修改
> 
>利用以上创建playbook，实现以下操作:
> 
>- [ ] Playbook文件名为**create_users.yml** ，在inventory规定的主机上运行时，该playbook会根据user_list.yml文件内容，使用指定的**用户ID**创建用户账户
> - [ ] 针对每个账户，该playbook会按照以下要求生成随机的**6**位**数字**密码
>    - [ ] 必须使用**sha512**，对密码进行加密
>     - [ ] 密码的纯文本版本和用于生成密码的随机值**salt**必须存储在名为**password-<name>**的文件中，其中**<name>**是与该帐户关联的用户名。例如，针对名为 frederick 用户，密码和 salt 存储在文件password-frederick 中
>   - [ ] Playbook需要在其运行的目录中生成**password-<name>**文件
> - [ ] 针对每个账户，**user comment**(GECOS)字段需要按照以下格式要求为用户设置恰当的名字:**First Middle Last**（中间有单空格符）。如上所示，名字的每个组成部分都必须大写
> - [ ] 需要将完整的playbook提交并上传到仓库中

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
  <li><b>capitalize</b>, <b>vars_files</b><br>Docs » User Guide » Working With Playbooks » Using Variables<br>
  &nbsp;&nbsp;&nbsp;&nbsp;Creating valid variable names<br>
  <li><b>password-NAME</b><br>Docs » User Guide » Working With Playbooks » Advanced Playbooks Features » Working With Plugins » Lookup Plugins<br>
  &nbsp;&nbsp;&nbsp;&nbsp;password – retrieve or generate a random password, stored in a file
  <li><b>password_hash</b><br>Docs » User Guide » Working With Playbooks » Templating (Jinja2) » Filters<br>
  &nbsp;&nbsp;&nbsp;&nbsp;Hashing filters<br>
  <li><b>loop</b><br>Docs » User Guide » Working With Playbooks » Loops
</div>

**<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[student@workstation]**

```bash
*$ git clone http://git.lab.example.com:8081/git/create_users_complex.git
*$ cd create_users_complex
$ ls
ansible.cfg
inventory
user_list.yml

$ cat user_list.yml
users:
  - name: tom
    first: man
    middle: cat
    last: tom
    uid: 1111
  - name: jerry
    first: shu 
    middle: mouse  
    last: jerry
    uid: 2222
  - name: spike
    first: gou
    middle: dog 
    last: spike
    uid: 3333
```
```bash
*$ vim create_users.yml
```

```yaml
---
- hosts: all
  become: true
### 方法1，关键字方式，下两行
  vars_files:
  - user_list.yml
  tasks:
### 方法2，模块方式，下三行
# - name: Include vars of stuff.yaml into the 'stuff' variable (2.2).
#   include_vars:
#     file: user_list.yml
  - user:
      name: "{{ item.name }}"
      uid: "{{ item.uid }}"
      comment: "{{ item.first | capitalize }} {{ item.middle | capitalize }} {{ item.last | capitalize }}"
      password: "{{ lookup('password','password-{{ item.name }} chars=digits length=6') | password_hash('sha512') }}"
    loop: "{{ users }}"
```

```bash
*$ ansible-playbook create_users.yml

$ ls
ansible.cfg
inventory
user_list.yml
create_users.yml
`password-jerry`
`password-spike`
`password-tom`

$ cat password-*
756082
506454
709479

$ cat password-tom
709479

方法A
$ sshpass -p 709479 ssh tom@servera 'tail -n 3 /etc/passwd'
tom:x:1111:1111:Mao Cat Tom:/home/tom:/bin/bash
jerry:x:2222:2222:Shu Mouse Jerry:/home/jerry:/bin/bash
spike:x:3333:3333:Gou Dog Spike:/home/spike:/bin/bash

方法B
$ ansible servera -a 'tail -n 3 /etc/passwd'
servera | CHANGED | rc=0 >>
tom:x:1111:1111:Mao Cat Tom:/home/tom:/bin/bash
jerry:x:2222:2222:Shu Mouse Jerry:/home/jerry:/bin/bash
spike:x:3333:3333:Gou Dog Spike:/home/spike:/bin/bash
```

```bash
*$ git add .
*$ git commit -m 5
*$ git push

*$ cd
```

 

## 6. 配置playbook资源统计信息-c3

> Git仓库（http://git.lab.example.com:8081/git/resource_stat.git）包含以下资源:
>
> - [ ] 完整的playbook，文件名为**install_vim.yml**
> - [ ] 不完整的**ansible.cfg**
> - [ ] **inventory**与**install_vim.yml**关联的主机清单文件
>
> 使用以上资源按要求完成以下事项：
>
> - [ ] 创建第二个playbook，完善已经提供的配置文件，实现以下要求:
>  - [ ] Playbook的文件名为**create_cgroup.yml**
>   - [ ] create_cgroup.yml只在**本机**上运行
>  - [ ] create_cgroup.yml会创建控制组**ex447_stats**，包含以下参数
>    - [ ] 拥有控制组文件的用户与用户组均是**student**
>    - [ ] 控制器列表**cpuacct**、**memory**、**pids**
>    - [ ] 相对路径：**ex447_stats**
>
> - [ ] 更新配置以便在控制组**ex447_stats**中运行playbook **install_vim.yml**时，显示该playbook中任务的系统活动。报告的活动应包括CPU时间和内存使用情况的摘要
> - [ ] 完成后的剧本**create_cgroup.yml**和对配置所做的任何更改都应提交并推送到存储库
> - [ ] 除上面列出的以外，请勿进行任何其他更改

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
  <li><b>Callback Plugins</b><br>
    &nbsp;&nbsp;&nbsp;&nbsp;Docs » User Guide » Working With Playbooks » Advanced Playbooks Features » Working With Plugins » Callback Plugins
  <li><b>callback_cgroup_perf_recap</b><br>&nbsp;&nbsp;&nbsp;&nbsp;Docs » User Guide » Working With Playbooks » Advanced Playbooks Features » Working With Plugins » Callback Plugins » cgroup_perf_recap
</div>
**<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[student@workstation ~]**

```bash
*$ git clone http://git.lab.example.com:8081/git/resource_stat.git
*$ cd resource_stat
$ ls
ansible.cfg
inventory
install_vim.yml

$ cgcreate -h
Usage: cgcreate [-h] [-f mode] [-d mode] [-s mode] [-t <tuid>:<tgid>] [-a <agid>:<auid>] -g <controllers>:<path> [-g ...]
Create control group(s)
  -a <tuid>:<tgid>		Owner of the group and all its files
  -g <controllers>:<path>	Control group which should be added
  -t <tuid>:<tgid>		Owner of the tasks file
  ...
  
*$ vim create_cgroup.yml
```

```yaml
---
- hosts: localhost
  become: true
  tasks:
  - shell: 'cgcreate -a student:student -t student:student -g cpuacct,memory,pids:ex447_stats'
```

```bash
*$ ansible-playbook create_cgroup.yml

*$ vim ansible.cfg
```

```ini
[defaults]
inventory = inventory

# 需添加下面 1 行，查网页（后面两个插件，可以不用）
callback_whitelist = cgroup_perf_recap, profile_tasks
# 需添加下面 2 行，查网页
[callback_cgroup_perf_recap]
control_group = ex447_stats
```

```bash
*$ ansible-playbook install_vim.yml
PLAY [install_vim.yml] ```````````````````````````**

TASK [Gathering Facts] ```````````````````````````**
Week dd Mont yyyy  HH:MM:SS +0000 (0:00:00.048) 0:00:00.048 ``````*
Week dd Mont yyyy  HH:MM:SS +0000 (0:00:00.047) 0:00:00.047 ``````*
ok: [servera]

TASK [install] ```````````````````````````**
Week dd Mont yyyy  HH:MM:SS +0000 (0:00:01.984) 0:00:02.032 ``````*
Week dd Mont yyyy  HH:MM:SS +0000 (0:00:01.984) 0:00:02.032 ``````*
ok: [servera]

PLAY RECAP `````````````````````````````````**
servera : ok=2 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0   


CGROUP PERF RECAP ``````````````````````````````*
Memory Execution Maximum: 0.00MB
cpu Execution Maximum: 0.00%
pids Execution Maximum: 0.00

memory:
Gathering Facts (52540000-fa09-44ab-0a5a-00000000000c): 0.00MB
install (52540000-fa09-44ab-0a5a-000000000008): 0.00MB

cpu:
Gathering Facts (52540000-fa09-44ab-0a5a-00000000000c): 0.00%
install (52540000-fa09-44ab-0a5a-000000000008): 0.00%

pids:
Gathering Facts (52540000-fa09-44ab-0a5a-00000000000c): 0.00
install (52540000-fa09-44ab-0a5a-000000000008): 0.00

Week dd Mont yyyy  HH:MM:SS +0000 (0:00:01.675) 0:00:03.708 ```* 
===================================================================
gather_facts ------------------------------------------------ 1.98s
yum --------------------------------------------------------- 1.68s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
total ------------------------------------------------------- 3.66s
Week dd Mont yyyy  HH:MM:SS +0000 (0:00:01.675) 0:00:03.708 ```*
===================================================================
Gathering Facts --------------------------------------------- 1.98s
install ----------------------------------------------------- 1.68s
Playbook run took 0 days, 0 hours, 0 minutes, 3 seconds
```

```bash
*$ git add .
*$ git commit -m 6
*$ git push

*$ cd
```



## 7. 验证文件完整性（A卷）-c4

> git仓库http://git.lab.example.com:8081/git/verify_files.git包含以下资源:
>
> - [ ] **verify_files.yml**， 需要被处理的文件的清单
> - [ ] **inventory**，与该任务相关的主机
> - [ ] **verify_files.yml**中列出的文件位于Ansible控制节点 control.domain1.example.com 的 **/opt/files** 目录中
>
> 请勿对这些文件进行任何更改
>
> 使用上述资源创建一个playbook，完成以下操作:
>
> - [ ] 该playbook将命名为**verify.yml**
> - [ ] 该playbook仅在**本地主机**上运行
> - [ ] 对于verify_files.yml中列出的每个文件，针对verify_files.yml文件中checksum字段，比较每个文件的SHA-1 哈希值
>   - [ ] 对于具有有效校验值的文件，按照以下格式显示信息：**Checksum PASS: <filename>**
>    - [ ] 针对无有效校验值的文件，按照以下格式显示信息：**Checksum FAIL: <filename>**
> - [ ] 你的playbook可以使用任何此类的**verify_files.yml**
> - [ ] 完成的playbook应该提交并推送到仓库

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
<li>ansible-doc assert<br>
<li>https://docs.ansible.com/ansible/2.8/user_guide/playbooks_filters.html#regular-expression-filters
<li>https://docs.ansible.com/ansible/2.8/user_guide/playbooks_filters.html#hashing-filters
</div>
**<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[student@workstation]**

```bash
*$ git clone http://git.lab.example.com:8081/git/verify_files.git
*$ cd verify_files
$ cat verify_files.yml
files:
  - name: /opt/files/file1
    checksum: 637d1f5c6e6d1be22ed907eb3d223d858ca396d8  /opt/files/file1
  - name: /opt/files/file2
    checksum: 637d1f5c6e6d1be22ed907eb3d223d858ca396d8  /opt/files/file2
  - name: /opt/files/file3
    checksum: 637d1f5c6e6d1be22ed907eb3d223d858ca396d9  /opt/files/file3

*$ vim verify.yml
```

```yaml
---
- hosts: localhost
  vars_files:
  - verify_files.yml
  tasks:
  - name: verify files
    vars:
    - h1: "{{ lookup('file','{{ item.name }}') | hash('sha1') }}"
    - h2: "{{ item.checksum | regex_replace(' .*') }}" 
    assert:
      that:
      - h1 == h2
      fail_msg: "Checksum FAIL: {{ item. name }}"
      success_msg: "Checksum PASS: {{ item.name }}"
    loop: "{{ files }}"
```

```bash
*$ ansible-playbook verify.yml
```

```bash
*$ git add .
*$ git commit -m 7
*$ git push

*$ cd
```



## 7. 查找IP（B卷）-c4

> git仓库http://git.lab.example.com:8081/git/collect_ip.git 包含以下资源:
>
> - [ ] **inventory**，与该任务相关的主机
> - [ ] **ip_files.yml**，需要被处理的文件的清单
> - [ ] 请勿对这些文件进行任何更改
>
> 使用上述资源创建一个名为**findip.yml**的 playbook，完成以下操作:
> - [ ] 该剧本仅在**本地主机**上运行
>
> - [ ] 对于 ip_files.yml 中列出的每个文件，从文件中提取IP地址列表，并将提取的IP地址列表保存在新创建的文件中，如下所示：
>   - [ ] 输出文件应存储在**workstation**系统上的**/opt/ipdir**目录下
>   - [ ] 输出文件名与后缀为**.ip**的数据文件具有相同的文件名
>    例如，文件名为data中的ip地址应该存储在data.ip文件中，每个输出文件包含一行，前缀为IPADDR=，后跟IP地址列表：
>   
>  - [ ] 如果找到IP地址192.168.1.1，则该行为：**IPADDR=192.168.1.1**
>   - [ ] 如果找到了多个IP地址，则值应用逗号分隔。比如找到三个IP地址，192.168.1.1、192.168.100.9和172.24.5.6，则该行的格式为：**IPADDR=192.168.1.1,192.168.100.9,172.24.5.6**
>   - [ ] 重复的IP地址应排除在外
>   - [ ] 如果在文件中未找到IP地址，则相应的输出文件应为一行：**IPADDR=none**
>   
>- [ ] 从三个文件中找出IP地址，并生成文件
> 
>- [ ] 完成的剧本应提交并推送到存储库

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
  Docs » User Guide » Working With Playbooks » Templating (Jinja2) » <a href=https://docs.ansible.com/ansible/2.8/user_guide/playbooks_filters.html>Filters</a>
  <br>
    <li>regex_findall
  <li>to_yaml
  <li>regex_replace<br>
  Docs » User Guide » Working With Playbooks » Advanced Playbooks Features » Working With Plugins » Lookup Plugins<br>
    <li> file – read file contents
      </div>



 **<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[student@workstation]**

```bash
*$ git clone http://git.lab.example.com:8081/git/collect_ip.git
*$ cd collect_ip
$ ls
ansible.cfg
inventory
ip_files.yml
app.conf
blob
server.txt

$ cat ip_files.yml
files:
	- app.conf
	- blob
	- server.txt

$ cat app.conf 
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no

$ cat blob 
abc 2.2.2.2
def 3.3.3.3 hig
klm 2.2.2.2 nop

$ cat server.txt 
The server IP 1.1.1.1
```

```bash
*$ vim findip.yml
```

```yaml
---  
- hosts: localhost
  vars_files:
  - ip_files.yml
  become: yes 
  tasks:
  - name: Create a directory if it does not exist
    file:
      path: /opt/ipdir
      state: directory

# man grep
# ?							The preceding item is optional and matched at most once.
# {n,m}  				The preceding item is matched at least n times, but not more than m times.
# [a-d] 				is equivalent to [abcd]

# \\b 					表示单词边界
# ?:[0-9]{1,3}	表示 1~3 个连续的数字
# \\.						表示IP分隔符 .
# {3}						3 组
# [0-9]{1,3}		表示 1~3 个连续的数字

  #- debug:
  #    msg: "{{ lookup('file', item) | regex_findall('\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b') | unique | to_yaml | regex_replace('\\[|\\]|\\\n| ')}}"
  #  loop: "{{ files }}"
  - name: Copy using inline content
    vars:
    - result: "{{ lookup('file', item) | regex_findall('\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b') | unique | to_yaml | regex_replace('\\[|\\]|\\\n| ')}}"
    copy:
      content: "IPADDR={{ result | default('none', true) }}"
      dest: /opt/ipdir/{{ item }}.ip
    loop: "{{ files }}"
```

```bash
*$ ansible-playbook findip.yml
```
```bash
$ ls /opt/ipdir/
app.conf.ip
blob.ip
server.txt.ip

$ more /opt/ipdir/app.conf.ip 
IPADDR=none

$ more /opt/ipdir/blob.ip 
IPADDR=2.2.2.2,3.3.3.3

$ more /opt/ipdir/server.txt.ip 
IPADDR=1.1.1.1
```

```bash
*$ git add .
*$ git commit -m 7
*$ git push

*$ cd
```



## 8. 在 tower 上安装Ansible Tower-c6

> - [ ] Ansible Tower 安装包能从以下地址下载: http://content.example.com/ansible2.8/x86_64/dvd/setup-bundle/ansible-tower-setup-bundle-latest.el8.tar.gz
>
> - [ ] 将安装包解压到 **/root/** 下
>- [ ] Ansible Tower license file 可以从以下地址下载: http://materials.example.com/tower/install/Ansible-Tower-license.txt
> 
> - [ ] 所有密码要求被设置为 **flectrag**

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
  # cat README.md<br>
  # systemctl disable --now chronyd && timedatectl set-time 2022-01-01
</div>



 **<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[root@tower ~]**

```bash
*# wget http://content.example.com/ansible2.8/x86_64/dvd/setup-bundle/ansible-tower-setup-bundle-latest.el8.tar.gz

*# tar -xf ansible-tower-setup-bundle-latest.el8.tar.gz

*# cd ansible-tower-setup-bundle-3.5.0-1.el8/
# ls
backup.yml  bundle  group_vars  install.yml  inventory  licenses  `README.md`  restore.yml  roles  setup.sh

# vim README.md

*# vim inventory
```

> <kbd>:</kbd><kbd>%</kbd><kbd>s</kbd>/password=''/password='flectrag'<kbd>Enter</kbd>

```ini
[tower]
localhost ansible_connection=local

[database]

[all:vars]
admin_password='flectrag'

pg_host=''
pg_port=''

pg_database='awx'
pg_username='awx'
pg_password='flectrag'

rabbitmq_username=tower
rabbitmq_password='flectrag'
rabbitmq_cookie=cookiemonster
```

```bash
*# ./setup.sh
...输出省略...
The setup process completed `successfully`.
Setup log saved to /var/log/tower/setup-yyyy-mm-dd-HH:MM:SS.log
```
<img width=35 src="https://i0.hdslb.com/bfs/album/556a153ed2f3ffb9343c691ade3d2cb11b87a7ae.png">**[kiosk@foundation]**

```bash
*$ wget http://materials.example.com/tower/install/Ansible-Tower-license.txt

$ firefox http://tower
```

> ​	USERNAME: **admin**
> ​	PASSWORD: **flectrag** / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SIGN IN</kbd> 

![login](https://i0.hdslb.com/bfs/album/4d6fe93addcf11c82c8fb716e5d66b5aa4f21591.png)

> <kbd style="background-color: #4579B2; color: #fff; display: inline-block;">BROWSE</kbd> /
>
>
> ​		**/home/kiosk/Ansible-Tower-license.txt** / <kbd style="background-color: #4579B2; color: #fff; display: inline-block;">OPEN</kbd>
>
> - [x] **I agree to the End User License Agreement** / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SUBMIT</kbd> 

![license](https://i0.hdslb.com/bfs/album/9ad792e5207d7b7740fdd500f1f69fcc4520fac4.png)



## 9. 按照以下要求配置 Ansible Tower 的用户和组-c7

> 创建以下用户:
>
> |              |       **User 1**        |      **User 2**       |        **User 3**        |       **User 4**        |
> | ------------ | :-------------------: | :-----------------: | :--------------------: | :-------------------: |
> | Organization |       **Default**       |      **Default**      |       **Default**        |       **Default**       |
> | Username     |        **brian**        |        **edy**        |        **philip**        |        **betty**        |
> | Email        | brian@lab.example.com | edy@lab.example.com | philip@lab.example.com | betty@lab.example.com |
> | Password     |      **flectrag**       |     **flectrag**      |       **flectrag**       |      **flectrag**       |
> | User type    |       **Normal**        |      **Normal**       |        **Normal**        |       **Normal**        |
>
> 
>
> 创建以下组:
>
> |              |   **Team 1**   |       **Team 2**       |
> | ------------ | :----------: | :------------------: |
> | Name         |    **Dev**     |     **Siteadmin**      |
> | Description  | **Developers** | **SiteAdministrators** |
> | Organization |  **Default**   |      **Default**       |
>
> 用户和组的关联如下:
>
> - [ ] 用户 **brian** 和 **edy** 关联到组 **Dev**
> - [ ] 用户 **philip** 和 **betty** 关联到组 **Siteadmin**
> - [ ] 除了上述提到的，不要创建任何其他资源

### 方法1、网页

**<img width=35 src="https://i0.hdslb.com/bfs/album/556a153ed2f3ffb9343c691ade3d2cb11b87a7ae.png">[kiosk@foundation]**

> ACCESS / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Users</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> 
>
> ​	\* ORGANIZATION **Default**					\* EMAIL	**brian@lab.example.com**
> ​	\* USERNAME **brian**									\* PASSWORD	**flectrag**
> ​	\* CONFIRM PASSWORD **flectrag**	\* USER TYPE	**Normal User**
>
> ​	 <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>
> ​	PS：User{2..4} 同上，也可以使用命令行操作

![create_user](https://i0.hdslb.com/bfs/album/b1a4a220dccb3ad211cc2f4415bd8ccd435db5ae.png)

> 
>ACCESS / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Teams</kbd> /  <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> 
> 
> ​	\* NAME **Dev**														DESCRIPTION **Developers**
> ​	\* ORGANIZATION **Default**
>
> ​	 <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>
> ​	PS：Team2 同上，也可以使用命令行操作

![create_team](https://i0.hdslb.com/bfs/album/da02cdd2ea1f49b06bc8abb48890ad921823d1cb.png)


> ACCESS / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Teams</kbd> / Dev /
>
> ​	<kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">USERS</kbd> /  <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> 
>
> - [x] brain
>
> - [x] edy
>
>   <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>
>   PS：Siteadmin同上

![add_user](https://i0.hdslb.com/bfs/album/94d6c6205ba921695ff278bb8af33a5a4f0b4fea.png)

### 方法2、命令行

<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">**[root@foundation ~]**

> -i, --index-url

```bash
# pip3 install ansible-tower-cli \
  -i https://pypi.tuna.tsinghua.edu.cn/simple
```

<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">**[student@workstation ~]**

```bash
$ tower-cli --help

查看默认配置
$ tower-cli config
# Defaults.
certificate: 
`username`: 
`verify_ssl`: True
insecure: False
use_token: False
verbose: False
`password`: 
format: human
oauth_token: 
description_on: False
`host: 127.0.0.1
color: True

命令行使用指定的身份登陆，相应的服务器
$ tower-cli config --help
$ tower-cli config --scope user host tower.lab.example.com
$ tower-cli config --scope user username admin
$ tower-cli config --scope user password flectrag
$ tower-cli config --scope user verify_ssl False

$ tower-cli config
# User options (set with `tower-cli config`; stored in ~/.tower_cli.cfg).
username: `admin`
password: `flectrag`
host: `tower`
verify_ssl: `False`

# Defaults.
color: True
oauth_token: 
format: human
description_on: False
certificate: 
insecure: False
use_token: False
verbose: False


创建用户
$ tower-cli user --help
$ tower-cli user create \
  --username philip \
  --password flectrag \
  --email philip@lab.example.com
Resource changed.
== ======== ====================== ========== ========= ============ ================= 
id username         email          first_name last_name is_superuser is_system_auditor 
== ======== ====================== ========== ========= ============ ================= 
 3 philip   philip@lab.example.com                             false             false
== ======== ====================== ========== ========= ============ =================
$ tower-cli user create --username betty --password flectrag --email betty@lab.example.com
Resource changed.
== ======== ===================== ========== ========= ============ ================= 
id username         email         first_name last_name is_superuser is_system_auditor 
== ======== ===================== ========== ========= ============ ================= 
 4 betty    betty@lab.example.com                             false             false
== ======== ===================== ========== ========= ============ =================


用户添加到相应的组织
$ tower-cli organization associate --organization Default --user philip
OK. (changed: true)
$ tower-cli organization associate --organization Default --user betty
OK. (changed: true)

查看用户在指定的组织中
# tower-cli organization get -n Default -v
*** DETAILS: Getting the record. **********************************************
GET `https://tower/api/v2/organizations/`
# tower-cli user get --username betty -v
*** DETAILS: Getting the record. **********************************************
GET `https://tower/api/v2/users/`

-k, --insecure							# curl: (60) SSL certificate problem: self signed certificate
-L, --location							# 301 Moved Permanently
-s, --silent								# % Total    % Received % Xferd  Average Speed   Time  ...
-u, --user <user:password>	# Authentication credentials were not provided

$ curl -kLs -u admin:flectrag https://tower/api/v2/users/5 | json_pp
$ curl -kLs -u admin:flectrag https://tower/api/v2/users/5/organizations | json_pp

创建team
$ tower-cli team --help
$ tower-cli team create \
  -n Siteadmin \
  -d SiteAdministrators \
  --organization Default
Resource changed.
== ========= ============ 
id   name    organization 
== ========= ============ 
 2 Siteadmin            1
== ========= ============

team 中添加用户
$ tower-cli team associate \
  --team Siteadmin \
  --user philip
OK. (changed: true)
$ tower-cli team associate \
  --team Siteadmin \
  --user betty
OK. (changed: true)
```

```bash
查看用户列表
$ tower-cli user list
== ======== ====================== ========== ========= ============ ================= 
id username         email          first_name last_name is_superuser is_system_auditor 
== ======== ====================== ========== ========= ============ ================= 
 1 admin    admin@example.com														true             false
 2 brian    brian@lab.example.com												false            false
 3 edy      edy@lab.example.com													false            false
 4 philip   philip@lab.example.com											false            false
 5 betty    betty@lab.example.com												false            false
== ======== ====================== ========== ========= ============ =================

查看 team 列表
$ tower-cli team list
== ========= ============ 
id   name    organization 
== ========= ============ 
 1 Dev                  1
 2 Siteadmin            1
== ========= ============

查看组织列表
$ tower-cli organization list
== ======= 
id  name   
== ======= 
 1 Default
== =======
```



## 10. 配置清单-c12,c8

> 按照以下要求配置 Ansible Tower 动态清单:
> - [ ] Name: **Dynamic inventory for ex447**
>  - [ ] Organization: **Default**
> - [ ] Source name : **EX447 custom source**
>  - [ ] 自定义脚本: <a href='http://materials/dynamic.py'>http://materials/dynamic.py</a>
>
> 动态清单包含以下主机组和主机:
> - [ ] Host group: **web_servers**
>     - [ ] **serverd**
>      - [ ] **servere**
> - [ ] Host group: **lb_servers**
>    - [ ] **serverf**
>
> 如果不能创建动态清单，则创建一个名为 **Static inventory for ex447** 的静态清单，并包含上述主机组和主机
>
> 除了上述提到的，不要创建其他任何资源

### 方法1、网页

**<img width=35 src="https://i0.hdslb.com/bfs/album/556a153ed2f3ffb9343c691ade3d2cb11b87a7ae.png">[kiosk@foundation]**

```bash
$ wget http://materials/dynamic.py
```

> RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Inventory Scripts</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> 
>
> ​	\* NAME **dynamic.py**
> ​	\* ORGANIZATION **Default**
> ​	\* CUSTOM SCRIPT **#!/usr/bin/python3...**
> ​	 	<=- Drag and drop your custom inventory script file / **~kiosk/dynamic.py**
>
> ​	<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>

![d-py](https://i0.hdslb.com/bfs/album/cce47e413f31f30d3c880b7046be6e909cffdcf1.png)

> 
>RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Inventories</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / Inventory
> 
> ​	\* NAME **Dynamic inventory for ex447**
> ​	\* ORGANIZATION **Default**
> 
>​	<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
> 

![d-inventory](https://i0.hdslb.com/bfs/album/9870beaf20bf20afb3aeb8d8a34a363f094ad258.png)

> 
>​	<kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">SOURCES</kbd> /  <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> 
> 
> ​		\* NAME **EX447 custom source**
> ​		\* SOURCE **Custom Script**
> ​		\* CUSTOM INVENTORY SCRIPT **dynamic.py**
>
> ​				<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 

![custom_source](https://i0.hdslb.com/bfs/album/3647e09003fc9f0faf403ac6dcdb2adfbedd98eb.png)

> RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Inventories</kbd> /  Dynamic inventory for ex447 / 
>
> ​	<kbd style="background-color: #484848; color: #fff; display: inline-block;">SOURCES</kbd>
> ​			Ex447 custom source				![image-20210609162553372](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210609162553372.png)**Start sync process**
>
> <hr>
>
> ​	<kbd style="background-color: #484848; color: #fff; display: inline-block;">GROUPS</kbd>
> ​			<strong style='color: #1E70AB'>lb_servers</strong>
> ​			<strong style='color: #1E70AB'>web_servers</strong>
>
> <hr>
>​	<kbd style="background-color: #484848; color: #fff; display: inline-block;">HOSTS</kbd>
> ​			<strong style='color: #1E70AB'>serverd</strong>		<kbd style="background-color: #1E70AB; color: #fff; display: inline-block;">web_servers  X</kbd>
> ​			<strong style='color: #1E70AB'>servere</strong>		<kbd style="background-color: #1E70AB; color: #fff; display: inline-block;">werb_servers X</kbd>
> ​			<strong style='color: #1E70AB'>serverf</strong>		<kbd style="background-color: #1E70AB; color: #fff; display: inline-block;">lb_servers X</kbd>

![start_sync](https://i0.hdslb.com/bfs/album/c0a9cc86b6e4cd6bd57048873aba63713536f3ad.png)

![synced](https://i0.hdslb.com/bfs/album/e8ac98d2b9ecb36e83506b7a0de822bf9e5013a8.png)

![all_groups](https://i0.hdslb.com/bfs/album/4b3ff74c32a6158df8cfcb94fe2edf867bfc0df2.png)

![hosts](https://i0.hdslb.com/bfs/album/4cb3445a7d2e9ce92a264ba9feb69aeb68fb3f52.png)

### 方法2、命令行

<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">**[student@workstation ~]**

```bash
$ wget http://materials/dynamic.py

$ tower-cli inventory_script create \
-n dynamic.py \
--organization Default \
--script @dynamic.py
$ tower-cli inventory_script list
== =============== 
id      name       
== =============== 
1 dynamic.py
== ===============

$ tower-cli inventory create \
--organization Default \
-n 'Dynamic inventory for ex447'
$ tower-cli inventory list
== =========================== ============ 
id            name             organization 
== =========================== ============ 
 1 Demo Inventory                         1
 2 Dynamic inventory for ex447            1
== =========================== ============

$ tower-cli inventory_source create \
-n "EX447 custom source" \
-i "Dynamic inventory for ex447" \
--source custom --source-script dynamic.py
$ tower-cli inventory_source list
== =================== ========= ====== 
id        name         inventory source 
== =================== ========= ====== 
 6 EX447 custom source         2 custom
== =================== ========= ======
```

```bash
$ tower-cli inventory_source update "EX447 custom source"
$ tower-cli inventory_source status --source custom
======= ====== ========== 
elapsed failed   status   
======= ====== ========== 
4.913    false successful
======= ====== ==========

$ tower-cli group list
== =========== ========= 
id    name     inventory 
== =========== ========= 
 1 lb_servers          2
 2 web_servers         2
== =========== ========= 
$ tower-cli host list 
== ========= ========= ======= 
id   name    inventory enabled 
== ========= ========= ======= 
 1 localhost         1    true
 2 serverd           2    true
 3 servere           2    true
 4 serverf           2    true
== ========= ========= =======
```



## 11. 配置凭据-c8

> 创建名为 Node_Credential 的 Ansible Tower 凭据:
>  - [ ] Name: **Node_Credential**
>   - [ ] Organization: **Default**
>  - [ ] Credential type: **Machine**
>   - [ ] Username: **devops**
>  - [ ] Password: **redhat**
>   - [ ] Privilege escalation method: **sudo**
>  - [ ] Privilege escalation username: **root**
>   - [ ] Privilege escalation password: **redhat**
>   - [ ] 配置权限：
>      - [ ] 用 Node_Credential 凭据为 **Dev** 组分配 **Admin** 角色
>       - [ ] 用 Node_Credential 凭据为 **Siteadmin** 组分配 **Use** 角色
>
>
> 创建名为 Git_Credential 凭据:
>
>  - [ ] Name: **Git_Credential**
>   - [ ] Organization: **Default**
>  - [ ] Credential type: **Source Control**
>   - [ ] Username: **git**
>  - [ ] Password: **redhat321**
>  - [ ] 配置权限：
>      - [ ] 用 Git_Credential 凭据为 **Dev** 组分配 **Admin** 角色
>     - [ ] 用 Git_Credential 凭据为 **Siteadmin** 组分配 **Use** 角色
>
>
> 除了上述提到的，不要创建其他任何资源

**<img width=35 src="https://i0.hdslb.com/bfs/album/556a153ed2f3ffb9343c691ade3d2cb11b87a7ae.png">[kiosk@foundation]**

> RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Credentials</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> 
>
> ​	<kbd style="background-color: #656971; color: #ffffff; display: inline-block;">DETAILS</kbd>
>
> ​		\* NAME **Node_Credential**					ORAGAINIZATION: **Default**
> ​		\* CREDENTIAL TYPE **Machine**
>​		\* USERNAME **devops**											PASSWORD **redhat**
> ​		PRIVILEGE ESCALATION METHOD **sudo**		PRIVILEGE ESCALATION USERNAME **root**
> ​		PRIVILEGE ESCALATION  PASSWORD **redhat**
> 
>​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
> 
><hr>
> 
>​	<kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">PERMISSIONS</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / <kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">TEAMS</kbd>
> 
>- [x] Dev / TEAM **Admin**
> - [x] Siteadmin / TEAM **Use**
> 
>​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 

> RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Credentials</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> 
>
> ​	<kbd style="background-color: #656971; color: #ffffff; display: inline-block;">DETAILS</kbd>
>
> ​		\* NAME **Git_Credential**					ORAGAINIZATION: **Default**
> ​		\* CREDENTIAL TYPE **Source Control**
>
> ​		\* USERNAME **git**									PASSWORD **redhat321**
> 
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>
> <hr>
>
> ​	<kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">PERMISSIONS</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / <kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">TEAMS</kbd>
>
> - [x] Dev / TEAM **Admin**
>- [x] Siteadmin / TEAM **Use**
> 
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 

![cred](https://i0.hdslb.com/bfs/album/b670e2113684d0d32fc7d4f16399f14a62633fa8.png)

![save](https://i0.hdslb.com/bfs/album/a679d87a699912401d6eaf1315fc83bbd5017e49.png)

![git](https://i0.hdslb.com/bfs/album/ba8ed6809c6f933d8978dcd1e63a1794f4d99230.png)

![permission](https://i0.hdslb.com/bfs/album/076309eb9bac268edfee2c887f7d9011873e0105.png)

## 12. 配置项目-c9

> 按照要求创建以下 Ansible Tower 项目:
>
>  - [ ] Name: **Web setup**
>     - [ ] Organization: **Default**
>    - [ ] SCM TYPE: **Git**
>     - [ ] SCM URL: http://git.lab.example.com:8081/git/apache_setup
>    - [ ] SCM Credential: **Git_Credential**
>     - [ ] 为 **Dev** 组添加 **Admin** 权限，为 **Siteadmin** 组添加 **Use** 权限
>  - [ ] Name: **LB setup**
>     - [ ] Organization: **Default**
>    - [ ] SCM TYPE: **Git**
>     - [ ] SCM URL: http://git.lab.example.com:8081/git/haproxy_setup
>    - [ ] SCM Credential: **Git_Credential**
>     - [ ] 为 **Dev** 组添加 **Admin** 权限，为 **Siteadmin** 组添加 **Use** 权限
>
>  - [ ] 除了上述提到的，不要创建其他任何资源

**<img width=35 src="https://i0.hdslb.com/bfs/album/556a153ed2f3ffb9343c691ade3d2cb11b87a7ae.png">[kiosk@foundation]**

>RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Projects</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd>
>
>​	<kbd style="background-color: #656971; color: #ffffff; display: inline-block;">DETAILS</kbd>
>
>​		\* NAME **Web setup**					ORAGAINIZATION: **Default**
>​		\* SCM TYPE **Git**
>
>​		\* SCM URL http://git.lab.example.com:8081/git/apache_setup
>​		SCM CREDENTIAL **Git_Credential**
>
>- [x] UPDATE REVISION ON LAUNCH
>
>​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>
><hr>
>​	<kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">PERMISSIONS</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / <kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">TEAMS</kbd>
>
>- [x] Dev / TEAM **Admin**
>- [x] Siteadmin / TEAM **Use**
>
>​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 

> RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Projects</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd>
>
> ​	<kbd style="background-color: #656971; color: #ffffff; display: inline-block;">DETAILS</kbd>
>
> ​		\* NAME **LB setup**					ORAGAINIZATION: **Default**
> ​		\* SCM TYPE **Git**
>
> ​		\* SCM URL http://git.lab.example.com:8081/git/haproxy_setup
> ​		SCM CREDENTIAL **Git_Credential**
>
> - [x] UPDATE REVISION ON LAUNCH
>
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>
> <hr>
> ​	<kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">PERMISSIONS</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / <kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">TEAMS</kbd>
>
> - [x] Dev / TEAM **Admin**
> - [x] Siteadmin / TEAM **Use**
>
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 



## 13. 配置模板-c9

> 按照以下要求创建 Ansible Tower 工作模板:
>
> - [ ] Name: **Webserver setup**
> - [ ] Job Type: **Run**
> - [ ] Inventory: **Dynamic inventory for ex447**
> - [ ] Project: **Web setup**
> - [ ] Playbook: **webserver-setup.yml**
> - [ ] Credential: ** Node_Credential**
>
>   该模板将在以下节点安装 httpd 服务和创建初始内容:
>
>    - [ ] **serverd**、**servere**
>   - [ ] 当浏览 http://serverd.lab.example.com 或者 http://servere.lab.example.com时会输出以下内容:**This is an EX447 test webpage** 
>
> 按照以下要求创建 Ansible Tower 工作模板:
>
> - [ ] Name: **Loadbalancer setup**
> - [ ] Job Type: **Run**
> - [ ] Inventory: **Dynamic inventory for ex447**
> - [ ] Project: **LB setup**
> - [ ] Playbook: **lb-setup.yml**
> - [ ] Credential: **Node_Credential**
> - [ ] 该模板将在 **serverf.lab.example.com** 上安装 **haproxy** 服务和配置负载均衡。针对http://serverf.lab.example.com的HTTP请求将被定向到**serverd.lab.example.com**或**servere.lab.example.com**
>
> 为上述模板添加访问 **Dev** 和 **Siteadmin** 组的 **Admin** 权限
>
> 如果本场考试中没有创建动态清单，那就为以上模板使用静态清单 **Static inventory for ex447**
>
> 除了上述提到的，不要创建其他任何资源

**<img width=35 src="https://i0.hdslb.com/bfs/album/556a153ed2f3ffb9343c691ade3d2cb11b87a7ae.png">[kiosk@foundation]**

> RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Templates</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / <kbd>Job Template</kbd>
>
> ​	<kbd style="background-color: #656971; color: #ffffff; display: inline-block;">DETAILS</kbd>
>
> ​		\* NAME **Webserver setup**
> ​		\* JOB TYPE **Run**							\* INVENTORY**Dynamic inventory for ex447**
>
> ​		\* PROJECT **Web setup**	\* PLAYBOOK **webserver-setup.yml**
> ​		CREDENTIAL **Node_Credential**
>
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>
> <hr>
>
> ​	<kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">PERMISSIONS</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / <kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">TEAMS</kbd>
>
>
> - [x] Dev / TEAM **Admin**
> - [x] Siteadmin / TEAM **Admin**
>
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd>  / <kbd style="background-color: #4579B2; color: #fff; display: inline-block;">LAUNCH</kbd>

> firefox http://serverd.lab.example.com
> firefox http://servere.lab.example.com

> RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Templates</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / <kbd>Job Template</kbd>
>
> ​	<kbd style="background-color: #656971; color: #ffffff; display: inline-block;">DETAILS</kbd>
>
> ​		\* NAME **Loadbalancer setup**
> ​		\* JOB TYPE **Run**							\* INVENTORY **Dynamic inventory for ex447**
>
> ​		\* PROJECT **LB setup**	\* PLAYBOOK **lb-setup.yml**
> ​		CREDENTIAL **Node_Credential**
>
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>
> <hr>
>
> ​	<kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">PERMISSIONS</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / <kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">TEAMS</kbd>
>
> - [x] Dev / TEAM **Admin**
> - [x] Siteadmin / TEAM **Admin**
>
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd>  / <kbd style="background-color: #4579B2; color: #fff; display: inline-block;">LAUNCH</kbd>

> firefox http://serverf.lab.example.com
> 	<kbd>F5</kbd>\* 多按几次



## 14. 创建通知-c10

> 按照以下要求创建 Ansible Tower 通知:
>
> - [ ] Notification name: **Web workflow notification**
> - [ ] Organization: **Default**
> - [ ] Type: **Email**
> - [ ] Host: **localhost** 
> - [ ] Recipient list: **devops@tower.lab.example.com**
> - [ ] Sender email: **student@tower.lab.example.com**
> - [ ] Port: **25**
> - [ ] SSL: **No**
>
> 除了上述提到的，不要创建其他任何资源

**<img width=35 src="https://i0.hdslb.com/bfs/album/556a153ed2f3ffb9343c691ade3d2cb11b87a7ae.png">[kiosk@foundation]**

>ADMINISTRATION / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Notifications</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd>
>
>​	\* NAME **Web workflow notification**		\* ORGANIZATION **Default**
>​	\* TYPE **Email**
>
>​	\* HOST **localhost**
>​	\* RECIPIENT LIST **devops@tower.lab.example.com**
>​	\* SENDER EMAIL **student@tower.lab.example.com**
>​	\* PORT **25**
>
>​		<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>
><hr>
>
>​	<strong style='color: #3880b4'>Web workflow notification</strong>		<img width=30 src="https://i0.hdslb.com/bfs/album/9e0dcd2b4531d68676868aead345d6c399368cc7.png">

![notifi](https://i0.hdslb.com/bfs/album/ffbd6692703b250b26c80a018b0cce08175cfc48.png)

**<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[root@tower]**

```bash
# yum provides *mail

# yum -y install mailx

测试本地可互发邮件
# su - student \
  -c 'echo q | mail -s bt1 devops@tower.lab.example.com'

查看邮件A
# su - devops \
	-c 'echo q | mail'
...输出省略...
>N  1 student@tower.lab.ex  Thu Sep  9 12:00  18/751   "Tower Notificati"
查看邮件B
# cat /var/spool/mail/devops
```



## 15. 创建工作流-c10

> 按照以下要求创建 Ansible Tower 工作流模板:
>
> - [ ] Name: **Web setup workflow**
> - [ ] Organization: **Default**
> - [ ] 这个工作流使用第十二题中创建的项目**Web setup** 和 **LB setup**，并且在运行作业之前始终与这些项目同步
> - [ ] 这个工作流使用 **Webserver setup** 和 **Loadbalancer setup** 模板
> - [ ] 这个工作流使用 **Web workflow notification** 来通知成功和失败
> - [ ] **Dev** 和 **Siteadmin** 组成员能用 **Administrator** 编辑这个工作流
>
> 运行这个工作流之后，你的系统将提供以下服务:
>
> - [ ] **serverd.lab.example.com** 和 **servere.lab.example.com** 将提供web服务
> - [ ] **serverf.lab.example.com** 将为**serverd.lab.example.com** 和 **servere.lab.example.com** 提供负载均衡服务
>
> 你能够通过浏览http://serverf.lab.example.com 来检查你的工作:
>
> - [ ] 活动的 web 服务器主机名将被显示，重新加载页面时，主机名将更改
> 
>除上述资源外，不要创建任何其他资源

**<img width=35 src="https://i0.hdslb.com/bfs/album/556a153ed2f3ffb9343c691ade3d2cb11b87a7ae.png">[kiosk@foundation]**

> RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Templates</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / <kbd>Workflow Template</kbd>
> ​	<kbd style="background-color: #656971; color: #ffffff; display: inline-block;">DETAILS</kbd>
>
> ​		\* NAME **Web setup workflow**
> ​		\* ORGANIZATION **Default**
> ​		INVENTORY **Dynamic inventory for ex447**
>
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>

![template](https://i0.hdslb.com/bfs/album/f288b3eaac12580a4ca7bfba676363359d2ee14a.png)


>​	<kbd style="background-color: #1E70AB; color: #ffffff; display: inline-block;">WORKFLOW VISUALIZER</kbd>
>
> ​				<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">START</kbd> 
>​				---- <kbd style="background-color: #ffffff; color: #737373; display: inline-block;">PROJECT SYNC</kbd> / **Web setup**/ <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SELECT</kbd> / <img  width=35 src="https://gitee.com/suzhen99/redhat/raw/master/images/image-20210610224839712.png">
> ​				---- <kbd style="background-color: #595e66; color: #ffffff; display: inline-block;">JOBS</kbd> / **Webserver setup**/ <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SELECT</kbd> / <img  width=35 src="https://gitee.com/suzhen99/redhat/raw/master/images/image-20210610224839712.png">
> ​				---- <kbd style="background-color: #ffffff; color: #737373; display: inline-block;">PROJECT SYNC</kbd> / **LB setup**/ <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SELECT</kbd> / <img  width=35 src="https://gitee.com/suzhen99/redhat/raw/master/images/image-20210610224839712.png">
> ​				---- <kbd style="background-color: #595e66; color: #ffff; display: inline-block;">JOBS</kbd> / **Loadbalancer setup**/ <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SELECT</kbd>
> 
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>

![workflow](https://i0.hdslb.com/bfs/album/ed852c1f6f3b96aad5902731e542a9ee8b07cb05.png)

>
>
> ​	<kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">PERMISSIONS</kbd> / <kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">+</kbd> / <kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">TEAMS</kbd>
>
> - [x] Dev / TEAM **Admin**
> - [x] Siteadmin / TEAM **Admin**
>
> ​			<kbd style="background-color: #5cb85c; color: #fff; display: inline-block;">SAVE</kbd> 
>
> <hr>
> ​	<kbd style="background-color: #ffffff; color: #6c6c6c; display: inline-block;">NOTIFICATIONS</kbd>
>
> ​		...	SUCCESS **ON**	FAILURE **ON**

![noti](https://i0.hdslb.com/bfs/album/66dc4efbf1e9bc7ec58b8640694eb20c89b7e899.png)

> RESOURCES / <kbd style="background-color: #484848; color: #fff; display: inline-block;">Templates</kbd> / <strong style='color: #3880b4'>Web setup workflow</strong> <img src="https://i0.hdslb.com/bfs/album/9952573e5d9d0b4535602a92834d57fd53f833ac.png"> 

![t](https://i0.hdslb.com/bfs/album/07d9e719e6bd9c1b7b9a0e1145262bc22acae471.png)

![jobs](https://i0.hdslb.com/bfs/album/45eef2e483427e30cc83d2c7aec4312870f5a62b.png)

> http://serverf.lab.example.com
> <kbd>F5</kbd>

**<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[devops@tower]**

```bash
$ mail
>N  2 student@tower.lab.ex  Thu Sep  9 13:18  24/1091  "Workflow Job #19"
```



## 16. 备份 Ansible Tower-c14

> 按以下要求为现有的 Ansible Tower 配置创建备份:
>
> - [ ] 备份包括你在此考试中在 Ansible Tower 完成的所有工作
>- [ ] 该备份能通过以下命令恢复: **/root/ansible-tower-*/setup.sh -r**

**<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[root@tower]**

```bash
*# /root/ansible-tower-*/setup.sh -h
Usage: /root/ansible-tower-setup-bundle-3.5.0-1.el8/setup.sh [Options] [-- Ansible Options]

Options:
  -i INVENTORY_FILE     Path to ansible inventory file (default: inventory)
  -e EXTRA_VARS         Set additional ansible variables as key=value or YAML/JSON
                        i.e. -e bundle_install=false will force an online install

  -b                    Perform a database backup in lieu of installing.
  -r                    Perform a database restore in lieu of installing.

  -h                    Show this help message and exit

Ansible Options:
  Additional options to be passed to ansible-playbook can be added
  following the -- separator.


*# /root/ansible-tower-*/setup.sh -b
...
The setup process completed `successfully`.
Setup log saved to /var/log/tower/setup-yyyy-mm-dd-HH:MM:SS.log
```



## 17. 使用 Ansible Tower API 启动一个作业-c11

> 按照以下要求创建一个 shell 脚本用来启动一个作业:
>
> - [ ] 这个脚本将被存放在 **tower.lab.example.com** 下的 **/root/build_webservice.sh**
>- [ ] 这个脚本将使用用户 **betty** 的权限来运行 **Web setup workflow** 工作流
> - [ ] 使用适当的 API 运行工作流
>- [ ] 命令不应重定向标准输出

<div style="background: #dbfaf4; padding: 12px; line-height: 24px; margin-bottom: 24px;">
<dt style="background: #1abc9c; padding: 6px 12px; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; margin-bottom: 12px;" >Hint - 提示</dt>
<li> betty密码参见第9题
<li> curl<br>
-u, --user user:password<br>
-s, --silent 这个选项不是必须<br>
-k, --insecure https<br>
-L, --location<br>
-X, --request <command><br>
   {GET (默认值)可以省略, POST}
</div>





### 方法A、网页

**<img width=35 src="https://i0.hdslb.com/bfs/album/556a153ed2f3ffb9343c691ade3d2cb11b87a7ae.png">[kiosk@foundation]**

> https://tower.lab.example.com/api / <kbd>Log in</kbd>
> ​	Username: **admin**
> ​	Password: **flectrag**
>
> <hr>
>
> "current_version": **"/api/v2/"**, 
>
> ​		"workflow_job_templates": **"/api/v2/workflow_job_templates/",** 
>
> ​				"launch": **"/api/v2/workflow_job_templates/10/launch/"**,	

![detial](https://i0.hdslb.com/bfs/album/7bd170e5f5bd95d30fb11327571a171889d337a2.png)

### 方法B、命令行

**<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">[root@tower ~]**

```bash
json_pp
# yum search json
perl-JSON-PP.noarch : JSON::XS compatible pure-Perl module
...输出省略...
# yum -y install perl-JSON-PP

lanuch
# curl https://tower/api
# curl https://tower/api -k
# curl https://tower/api -k -L
# curl https://tower/api -k -L | json_pp
# curl https://tower/api -k -L -s | json_pp
# curl https://tower/api/v2 -k -L -s | json_pp
# curl https://tower/api/v2 -k -L -s | json_pp | grep work
# curl https://tower/api/v2/workflow_job_templates/ -k -L -s | json_pp

# curl https://tower/api/v2/workflow_job_templates/ -k -L -s -u admin:flectrag | json_pp
# curl https://tower/api/v2/workflow_job_templates/ -k -L -s -u admin:flectrag | json_pp | grep launch
            "launch" : "/api/v2/workflow_job_templates/10/launch/",
```
<img width=35 src="https://i0.hdslb.com/bfs/album/41d94fd91de77380abe6f8639e7735e0b7947121.png">**[root@tower ~]**


```bash
*# vim /root/build_webservice.sh
```

```bash
#!/bin/bash

curl -X POST -k -u betty:flectrag https://tower.lab.example.com/api/v2/workflow_job_templates/10/launch/
```

```bash
*# chmod +x build_webservice.sh

*# /root/build_webservice.sh
{"workflow_job":**28**,...输出省略...
```

![j](https://i0.hdslb.com/bfs/album/abc08eb2ddce7c1c19f12dfab6bdc63bfcd50fb2.png)





# 相关内容

## A1. [红帽认证高级自动化专家：Ansible 最佳实践考试](https://www.redhat.com/zh/services/training/ex447-red-hat-certified-specialist-advanced-automation-ansible-best-practices-exam) 

> 持续时间	**4.00 小时**

> ### 考查要点
>
> 您应能独立完成下列分组任务：
>
> - 理解和运用 Git
>   - **克隆 Git 存储库**
>   - **在 Git 存储库中更新、修改和创建文件**
>   - **将这些修改过的文件添加回 Git 存储库**
>
> - 管理库存清单变量
>
>   - **利用每个主机或组的多个文件，构建主机和组变量**
>
>   - 使用特殊变量来覆盖主机、端口或 Ansible 针对特定主机而使用的远程用户
>   - 为某些托管主机设置包含多个主机变量文件的目录
>   - 以不同的名称或 IP 地址来覆盖库存清单文件中所用的名称
>
> - 管理任务的执行
>
>   - 控制权限执行
>
>   - **运行所选的任务**
>
> - 借助过滤器和插件转换数据
>
>   - **使用查找插件，用来自外部源的数据填充变量**
>
>   - **使用查找和查询功能，将来自外部源的模板数据化为 playbook 和已部署的模板文件**
>   - **使用查找插件和过滤器，用除简单列表之外的结构实现循环**
>   - **使用过滤器，检查、验证和操作包含网络信息的变量**
>
> - 委派任务
>
>   - 在另一台主机上运行托管主机的任务，然后控制是否将该任务收集的 fact 委派给托管主机或其他主机
>
> - 安装 Ansible Tower
>
>   - **配置完成后，执行 Ansible Tower 的基本配置**
>
> - 管理 Ansible Tower 的访问权限
>
>   - **创建 Ansible Tower 用户和团队并让其相互关联**
>
> - 管理库存清单和凭据
>
>   - 管理高级库存清单
>   - 从身份管理服务器或数据库服务器创建动态库存清单
>   - **创建机器凭据以访问库存清单主机**
>   - **创建源代码控制凭据**
>
> - 管理项目
>
>   - **创建作业模板**
>
> - 管理工作流
>
>   - **创建工作流模板**
>
> - 使用 Ansible Tower API
>
>   - **编写 API 脚本小程序以启动作业**
>
> - 备份 Ansible Tower
>
>   - **备份 Ansible Tower 的实例**
>
> 对于所有实际任务操作型的红帽考试，您的所有系统配置必须在重启后仍然有效（无需人工干预）。

## A2. Performance on exam objectives:

> **OBJECTIVE: SCORE**
> 	Understand and use Git: 100%
> 	Manage task execution: 100%
> 	Transform data with filters and plugins: 100%
> 	Install Ansible Tower: 100%
> 	Manage access for Ansible Tower: 100%
> 	Manage inventories and credentials: 100%
> 	Manage projects: 100%
> 	Manage job workflows: 100%
> 	Work with the Ansible Tower API: 100%
> 	Back up Ansible Tower: 100%

## A3. docs

windows

> 百度盘下载 docs.ansible.com.zip

```powershell
X: \> scp docs.ansible.com.zip root@192.168.201.129:
```

[root@foundation ~]#

```bash
# unzip docs.ansible.com.zip -d /content
```

> 浏览器访问 http://content/docs
