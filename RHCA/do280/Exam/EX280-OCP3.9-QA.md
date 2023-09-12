- 课堂计算机

![DO280-Classroom-Architecture-1](https://gitee.com/suzhen99/redhat/raw/master/images/DO280-Classroom-Architecture-1.png)

|  SOFT  |            计算机名称             |            IP 地址             |                 角色                  |
| :----: | :-------------------------------: | :----------------------------: | :-----------------------------------: |
| VMware |            foundation             |         172.25.254.250         |                 平台                  |
|  KVM   | classroom<br>(materials, content) |         172.25.254.254         |            实用工具服务器             |
|  KVM   |            workstation            |         172.25.250.254         |              图形工作站               |
|  KVM   |              master               |         172.25.250.10          | OpenShift 容器平台<br> cluster 服务器 |
|  KVM   |          node1<br>node2           | 172.25.250.11<br>172.25.250.12 |  OpenShift 容器平台 <br>cluster 节点  |
|  KVM   |       services<br>registry        |         172.25.250.13          |           private registry            |



[toc]
## 1. Create OpenShift users-c5

> Create additional OpenShift users with the following characteristics:  
>
> - [ ] The regular user **salvo** with password **redhat**  
> - [ ] The regular user **ayumi** with password **redhat**  
> - [ ] You must use the existing authentication file at **/etc/origin/master/htpasswd** while preserving its original content  
> - [ ] Both users must be able to authenticate to the OpenShift instance via **CLI** and on the **web console** at **https://master.lab.example.com**
> - [ ] Regular users must **NOT** be able to create projects themselves

**[root@master]**

 **步骤0. 确认验证文件**

```bash
# yum search openshift
`atomic-openshift-master.x86_64` : Origin Master
...

# rpm -qc atomic-openshift-master | grep conf
/etc/origin/.config_managed
/etc/origin/master/admin.kubeconfig
`/etc/origin/master/master-config.yaml`
/etc/origin/master/openshift-master.kubeconfig
/etc/origin/master/openshift-registry.kubeconfig
/etc/origin/master/openshift-router.kubeconfig
/etc/sysconfig/atomic-openshift-master

# grep -A 1 file /etc/origin/master/master-config.yaml
      file: `/etc/origin/master/htpasswd`
      kind: HTPasswdPasswordIdentityProvider
```
 **步骤1. 添加用户，并设置密码**

```bash
# htpasswd
	`htpasswd` -b[cmBdpsDv] [-C cost] `passwordfile` `username` `password`
 -b  Use the password from the command line rather than prompting for it.
...

*# htpasswd -b /etc/origin/master/htpasswd salvo redhat
Adding password for user salvo

*# htpasswd /etc/origin/master/htpasswd ayumi
New password: `redhat`
Re-type new password: `redhat`
Adding password for user ayumi

# cat /etc/origin/master/htpasswd
...
salvo:$apr1$mrGnFACY$clqUlmwpfEA2mMp/rbkJ1/
ayumi:$apr1$xJNaY0Dl$aomtMV72L3YxaExtxfw9M0
```
**步骤0. 确认可以创建项目，记得切回admin**

```bash
# oc login 
Authentication required for https://master.lab.example.com:443 (openshift)
Username: `salvo`
Password: `redhat`
Login successful.

You don\'t have any projects. You can try to create a new project, by running

    oc new-project <projectname>

# oc login -u ayumi -p redhat
Login successful.

You don\'t have any projects. You can try to create a new project, by running

    oc new-project <projectname>

# oc login -u admin -p redhat
Login successful.

You have access to the following projects and can switch between them with 'oc project <projectname>':

  * default
    kube-public
    kube-service-catalog
    kube-system
    logging
    management-infra
    openshift
    openshift-ansible-service-broker
    openshift-infra
    openshift-node
    openshift-template-service-broker
    openshift-web-console
    samples
    test

Using project "default".
```

 **步骤2. 不能自己创建项目**

**[kiosk@foundation]**

> firefox <a href="http://materials/docs/html/cluster_administration/">http://materials/docs/html/cluster_administration/</a>
			<kbd>CTRL+F</kbd> / **self**

**[root@master]**

```bash
# oc describe clusterrolebinding.rbac self-provisioners
Name:		self-provisioners
Labels:		<none>
Annotations:	rbac.authorization.kubernetes.io/autoupdate=true
Role:
  Kind:	ClusterRole
  Name:	self-provisioner
Subjects:
  Kind	Name				Namespace
  ----	----				---------
  Group	`system:authenticated:oauth`

*# oc adm policy \
   remove-cluster-role-from-group self-provisioner \
   system:authenticated system:authenticated:oauth
cluster role "self-provisioner" removed: ["system:authenticated" "system:authenticated:oauth"]
```
 **步骤3. 确认**

```bash
# oc login -u salvo -p redhat
Login successful.

You don\'t have any projects. Contact your system administrator to request a project.

# oc login -u ayumi -p redhat
Login successful.

You don\'t have any projects. Contact your system administrator to request a project.
```

**[kiosk@foundation0]**

> **firefox**	https://master.lab.example.com
> 		Username	**salvo**
> 		Password	**redhat**
> 		<kbd>Login in</kbd>

![image-20210905192423138](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905192423138.png)



## 2. Configure persistent storage for the local registry-c6

> - [ ] Associate the share named **/exports/registry** to the **built-in registry** running within your OpenShift Enterprise instance so that it will be used for permanent storage
> - [ ] Use **exam-registry-volume** for the volume name and **exam-registry-claim** for the claim name
> - [ ] You can find sample YAML files on **http://materials/storage/**
> (Note: This task needs to be solved before any applications are created)

**[kiosk@foundation]**

 **步骤1. 浏览文件**

> **firefox** http://materials/storage

![image-20210905192622575](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905192622575.png)

**[root@master]**

 **步骤2. 下载并修改文件**

```bash
*# wget http://materials/storage/pv.yaml

# host registry
registry.lab.example.com has address 172.25.250.13

*# vim pv.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
# name: pv0001
  name: exam-registry-volume
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce
  nfs:
#   path: /db
    path: /exports/registry
#   server: master.lab.example.com
    server: registry.lab.example.com
  persistentVolumeReclaimPolicy: Recycle
```
 **步骤3. 使用文件创建 pv**

```bash
# oc login -u system:admin
# oc project default

*# oc create -f pv.yaml
persistentvolume "exam-registry-volume" created

# oc get pv
`exam-registry-volume`  5Gi  RWO  Recycle  `Available`  5s
...
```
 **步骤4. 配置持久卷**

```bash
# oc get dc
NAME               REVISION   DESIRED   CURRENT   TRIGGERED BY
`docker-registry`  1          1         1         config
registry-console   1          1         1         config
router             1          2         2         config

# oc describe dc docker-registry | grep -A 10 Volumes
  Volumes:
   `registry-storage`:
    Type:	`EmptyDir` (a temporary directory that shares a pod\'s lifetime)
    Medium:	
   registry-certificates:
    Type:	Secret (a volume populated by a Secret)
    SecretName:	registry-certificates
    Optional:	false

Deployment \#1 (latest):
	Name:		docker-registry-1

# oc set volume -h | grep oc.*set.*claim
  oc set volume dc/registry --add --name=v1 -t pvc --claim-name=pvc1 --overwrite
  oc set volume dc/registry --add --name=v1 -t pvc --claim-size=1G --overwrite
  ...输出省略...

*# oc set volume dc/docker-registry --add \
  --name=registry-storage \
  --overwrite \
  -t pvc \
  --claim-name=exam-registry-claim \
  --claim-size='5G'
persistentvolumeclaims/exam-registry-claim
deploymentconfig "docker-registry" updated

# oc describe dc docker-registry | grep -A 10 Volumes
  Volumes:
   registry-certificates:
    Type:	Secret (a volume populated by a Secret)
    SecretName:	registry-certificates
    Optional:	false
   registry-storage:
    Type:	`PersistentVolumeClaim` (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:	`exam-registry-claim`
    ReadOnly:	false

Deployment \#2 (latest):
```

```bash
# oc get pvc
...
exam-registry-claim  `Bound`  exam-registry-volume  5Gi  RWO  3m
```



## 3. Create OpenShift Enterprise projects-c5
> On your OpenShift Enterprise instance create following projects:
>
> - [ ] **rome**  
> - [ ] **shrimp**  
> - [ ] **farm**  
> - [ ] **ditto**  
> - [ ] **samples** 
>
> Additionally, configure the projects as follows:  
> - [ ] For all of the projects, set the description to **This is an EX280 project on OpenShift v3**
> - [ ] Make **salvo** the **admin** of project **rome** and **ditto**
> - [ ] The user **ayumi** must be able to **view** the project **rome** but **not administrator delete** it
> - [ ] Make **ayumi** the **admin** of project **farm**,**shrimp** and **samples**

**[root@master]** 

**步骤1. 新建项目，同时设置描述**

```bash
# oc new-project -h | grep oc.*descr
  oc new-project NAME [--display-name=DISPLAYNAME] [--description=DESCRIPTION] [options]
  oc new-project web-team-dev --display-name="Web Team Development" --description="Development project for the web team."

*# for i in rome shrimp farm ditto samples; do
     oc new-project $i \
       --description="This is an EX280 project on OpenShift v3"
   done

# for i in rome shrimp farm ditto samples; do
    oc describe project $i \
      | grep Description
  done 
    openshift.io/description: This is an EX280 project on OpenShift v3
    openshift.io/description: This is an EX280 project on OpenShift v3
    openshift.io/description: This is an EX280 project on OpenShift v3
    openshift.io/description: This is an EX280 project on OpenShift v3
    openshift.io/description: This is an EX280 project on OpenShift v3
```
 **步骤2. salvo admin**

```bash
# oc adm policy add-role-to-user -h | grep oc.*add
  oc adm policy add-role-to-user ROLE (USER | -z SERVICEACCOUNT) [USER ...] [options]
  oc adm policy add-role-to-user view user1
  ...
Use "oc adm options" for a list of global command-line options (applies to all commands).
# oc adm options
  -n, --namespace='': If present, the namespace scope for this CLI request
  ...


*# for i in rome ditto; do
     oc adm policy add-role-to-user \
       admin salvo -n $i
   done
role "admin" added: "salvo"
role "admin" added: "salvo"
```
 **步骤3. ayumi view**

```bash
*# oc adm policy add-role-to-user \
     view ayumi -n rome
role "view" added: "ayumi"
```
 **步骤4. ayumi admin**

```bash
*# for i in farm shrimp samples; do
     oc adm policy add-role-to-user \
       admin ayumi -n $i
   done
role "admin" added: "ayumi"
role "admin" added: "ayumi"
role "admin" added: "ayumi"
```

**步骤0. 验证**

**[kiosk@foundation]**

> firefox <a href="http://materials/docs/html/cluster_administration/">http://materials/docs/html/cluster_administration/</a>
> 		<kbd>CTRL+F</kbd> / **oc adm policy**

```bash
# oc describe rolebinding.rbac -n rome
Name:         admin
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  admin
Subjects:
  Kind  Name   Namespace
  ----  ----   ---------
  User  admin  

Name:         admin-0
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  `admin`
Subjects:
  Kind  Name   Namespace
  ----  ----   ---------
  User  `salvo`  
...
Name:         view
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  `view`
Subjects:
  Kind  Name   Namespace
  ----  ----   ---------
  User  `ayumi`
```



## 4. Create an application from a Git repository-c4
> Use the S2I functionality of your OpenShift instance to build an application in the **rome** project
>
> - [ ] Use the Git repository at **http://services.lab.example.com/php-helloworld** for the application source
> - [ ] Use the Docker image labeled **registry.lab.example.com/rhscl/php-70-rhel7** 
> - [ ] Once deployed, the application must be reachable（and browseable）at the following address:  **http://hellophp.apps.lab.example.com**
> - [ ] Update the original repository so that the **index.php** file contains the text from **http://materials/mordor.txt** instead of the word **PHP**
> - [ ] Trigger a rebuild so that when browsing **http://hellophp.apps.lab.example.com** it will display the new text

**[root@master]**

 **步骤1. 切换项目**

```bash
*# oc project rome
Now using project "rome" on server "https://master.lab.example.com:443".

# oc project
Using project "rome" on server "https://master.lab.example.com:443".
```
 **步骤2. 新建应用，新建路由，测试**

```bash
# oc new-app -h
*# oc new-app \
     registry.lab.example.com/rhscl/php-70-rhel7~http://services.lab.example.com/php-helloworld
...

# oc logs -f bc/php-helloworld
Cloning "http://services.lab.example.com/php-helloworld" ...
...
---> Installing application source...
Pushing image docker-registry.default.svc:5000/rome/php-helloworld:latest ...
...
Pushed 6/6 layers, 100% complete
`Push successful`
# oc get pod
NAME                     READY     STATUS      RESTARTS   AGE
php-helloworld-1-build   0/1       Completed   0          3m
php-helloworld-1-c9bh8   1/1       `Running`   0          1m

# oc get svc
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
`php-helloworld` ClusterIP   172.30.216.33   <none>        8080/TCP   3m

*# oc expose svc php-helloworld \
  --hostname=hellophp.apps.lab.example.com
route "php-helloworld" exposed

# oc get route
NAME  HOST/PORT  PATH  SERVICES  PORT  TERMINATION  WILDCARD
php-helloworld  `hellophp.apps.lab.example.com`   php-helloworld  8080-tcp  None

*# curl http://hellophp.apps.lab.example.com
Hello, World! php version is 7.0.10
```
 **步骤3. git 更新，提交**

```bash
# git config --global user.name root
# git config --global user.email root@master
*# git config --global push.default simple

# git config -l
push.default=simple
user.name=root
user.email=root@master
```

```bash
*# git clone \
http://services.lab.example.com/php-helloworld
Cloning into 'php-helloworld'...
remote: Counting objects: 3, done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 0 (delta 0)
Unpacking objects: 100% (3/3), done.

*# cd php-helloworld

*# curl http://materials/mordor.txt
exam280

*# vim index.php
```
```php
<?php
print "exam280\n";
?>
```
```bash
*# git add .
*# git commit -m 'update'
*# git push

*# oc start-build php-helloworld 
build "php-helloworld-2" started

# oc get build
NAME               TYPE      FROM          STATUS     STARTED          DURATION
php-helloworld-1   Source    Git@6d61e75   Complete   17 minutes ago   2m2s
php-helloworld-2   Source    Git@80f908c  `Complete`  20 seconds ago   14s

# curl http://hellophp.apps.lab.example.com
exam280

*# cd
```



## 5. Create an application using Docker images and definition files-c6
> Using the example files from the wordpress directory under 
> **http://materials/wordpress** create a WordPress application in the **farm** project
>
> - [ ] For permanent storage use the NFS shares **/exports/wordpress** and **/exports/mysql** from **services.lab.example.com**. 
> Use the files from **http://materials/wordpress** for the volumes
> - [ ] For the WordPress pod, use the Docker image from 
> **http://materials/wordpress.tar** 
> (Note: it is normal if the WordPress pod initially restarts a couple of times due to permaission issues)
> - [ ] For the MySQL pod use the Docker image **rhscl/mysql-57-rhel7**
>
> Once deployed,the application must be reachable at the following address: 
> **http://blog.apps.lab.example.com**  
>
> - [ ] Finally, complete the **WordPress** installation by setting **ayumi** as the **admin** user with password **redhat** and **ayumi@master.lab.example.com** for the email address
> - [ ] Set the blog name to **EX280** Blog  
> - [ ] Create your first post with title **faber est quisque fortunae suae.  **
> - [ ] The text in the post does not matter

**[kiosk@foundation]**

 **步骤1. 浏览文件**

> **firefox** http://materials/wordpress/

![image-20210905202535360](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905202535360.png)

**[root@master]**

 **步骤2. 切换项目**

```bash
*# oc project farm
Now using project "farm" on server "https://master.lab.example.com:443".
```

 **步骤3. 创建 mysql pv**

```bash
*# wget http://materials/wordpress/pv.yaml \
   -O mpv.yaml

*# vim mpv.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
# name: pv0002
  name: mpv
spec:
  capacity:
    storage: 3Gi
  accessModes:
  - ReadWriteOnce
  nfs:
#   path: /blog
    path: /exports/mysql
#   server: 192.168.122.1
    server: services.lab.example.com
  persistentVolumeReclaimPolicy: Recycle
```
```bash
*# oc create -f mpv.yaml
persistentvolume "mpv" created

# oc get pv
...
mpv  Gi  RWO  Recycle  `Available`  1h
```
 **步骤4. 创建 mysql pvc**

```bash
*# wget http://materials/wordpress/pvc.yaml \
   -O mpvc.yaml

*# vim mpvc.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
# name: blogclaim
  name: mclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

```bash
*# oc create -f mpvc.yaml 
persistentvolumeclaim "mclaim" created

# oc get pvc
...
mclaim  `Bound` `mpv` 3Gi RWO  4s
```

 **步骤5. 创建 wordpress pv**

```bash
*# wget http://materials/wordpress/pv.yaml \
   -O wpv.yaml

*# vim wpv.yaml
```
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
# name: pv0002
  name: wpv
spec:
  capacity:
    storage: 3Gi
  accessModes:
  - ReadWriteOnce
  nfs:
#   path: /blog
    path: /exports/wordpress
#   server: 192.168.122.1
    server: services.lab.example.com
  persistentVolumeReclaimPolicy: Recycle
```
```bash
*# oc create -f wpv.yaml
persistentvolume "wpv" created

# oc get pv
...
wpv  3Gi  RWO  Recycle  `Available`  3m
```
 **步骤6. 创建 wordpress pvc**

```bash
*# wget http://materials/wordpress/pvc.yaml \
   -O wpvc.yaml

*# vim wpvc.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
# name: blogclaim
  name: wclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

```bash
*# oc create -f wpvc.yaml 
persistentvolumeclaim "wclaim" created

# oc get pvc
...
wclaim  `Bound`  wpv  3Gi  RWO  15s
```

 **步骤7. 上传 docker image**

```bash
*# wget http://materials/wordpress.tar

本地
*# docker load -i wordpress.tar 
...
Loaded image: 192.168.122.250:5000/openshift/wordpress:latest

# docker images
...
`registry.lab.example.com`/openshift3/ose-pod               v3.9.14             e598d93f5abe        5 years ago         209 MB
`192.168.122.250:5000/openshift/wordpress`  latest  dccaeccfba36  2 years ago  406 MB

*# docker tag \
   192.168.122.250:5000/openshift/wordpress \
   registry.lab.example.com/openshift/wordpress

上传至镜像仓库
*# docker push \
   registry.lab.example.com/openshift/wordpress
...
2c40c66f7667: Pushed 
latest: digest: sha256:ca4cf4692b7bebd81f229942c996b1c4e6907d6733e977e93d671a54b8053a22 size: 4078
```

**步骤0. 验证镜像上传到镜像仓库**

**[student@workstation]**

```bash
$ docker-registry-cli \
    registry.lab.example.com \
    search wordpress \
    ssl 
available options:- 
-----------
1) Name: `openshift/wordpress`
Tags: latest	

1 images found !
```

 **步骤8. 创建 mysql pod**

**[root@master]**

```bash
# oc get image | grep mysql-57
`sha256:0a8828385c63d6a7cdb1cfcf899303357d5cbe500fa1761114256d5966aacce3`  registry.lab.example.com/rhscl/mysql-57-rhel7@sha256:0a8828385c63d6a7cdb1cfcf899303357d5cbe500fa1761114256d5966aacce3

# oc describe image sha256:0a8828385c63d6a7cdb1cfcf899303357d5cbe500fa1761114256d5966aacce3 | grep Volume
Volumes:	`/var/lib/mysql/data`

*# wget \
     http://materials/wordpress/pod-mysql.yaml

*# vim pod-mysql.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql
  labels:
    name: mysql
spec:
  containers:
#   - image: 192.168.122.250:5000/rhscl/mysql-57-rhel7:latest
    - image: registry.lab.example.com/rhscl/mysql-57-rhel7:latest
      name: mysql
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: redhat
        - name: MYSQL_USER
          value: tom
        - name: MYSQL_PASSWORD
          value: redhat
        - name: MYSQL_DATABASE
          value: blog
      ports:
        - containerPort: 3306
          name: mysql
      volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql/data
  volumes:
    - name: mysql-persistent-storage
      persistentVolumeClaim:
#       claimName: dbclaim
        claimName: mclaim
```

```bash
*# oc create -f pod-mysql.yaml
pod "mysql" created
```
 **步骤9. 创建 mysql 服务**

```bash
*# wget \
   http://materials/wordpress/service-mysql.yaml

# cat service-mysql.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    name: mysql
  name: mysql
spec:
  ports:
    # the port that this service should serve on
    - port: 3306
  # label keys and values that must match in order to receive traffic for this service
  selector:
    name: mysql
```

```bash
*# oc create -f service-mysql.yaml
service "mysql" created

# oc get svc
...
`mysql`  ClusterIP  172.30.225.18  <none>       `3306`/TCP  20s
```
 **步骤10. 创建 wordpress pod**

```bash
*# wget \
   http://materials/wordpress/pod-wordpress.yaml

*# vim pod-wordpress.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: wordpress
  labels:
    name: wordpress
spec:
  containers:
#   - image: 192.168.122.250:5000/openshift/wordpress:latest
    - image: registry.lab.example.com/openshift/wordpress:latest
      name: wordpress
      env:
        - name: WORDPRESS_DB_USER
          value: root
        - name: WORDPRESS_DB_PASSWORD
          value: redhat
        - name: WORDPRESS_DB_NAME
          value: blog
        - name: WORDPRESS_DB_HOST
          # this is the name of the mysql service fronting the mysql pod in the same namespace
          # expands to mysql.<namespace>.svc.cluster.local  - where <namespace> is the current namespace
#         value: 172.30.255.198
          value: mysql
      ports:
        - containerPort: 80
          name: wordpress
      volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
  volumes:
    - name: wordpress-persistent-storage
      persistentVolumeClaim:
#      claimName: dbclaim
       claimName: wclaim
```

```bash
*# oc create -f pod-wordpress.yaml 
pod "wordpress" created

# oc get pod -w
NAME        READY     STATUS    RESTARTS   AGE
mysql       1/1      `Running`  0          15m
wordpress   1/1      `Running`  0          41s
<Ctrl-C>
```
 **步骤11. 创建 wordpress 服务**

```bash
*# wget \
   http://materials/wordpress/service-wp.yaml

*# vim service-wp.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    name: wpfrontend
  name: wpfrontend
spec:
  ports:
    # the port that this service should serve on
#   - port: 5055
    - port: 80
      targetPort: 80
  # label keys and values that must match in order to receive traffic for this service
  selector:
    name: wordpress
  type: LoadBalancer
```

```bash
*# oc create -f service-wp.yaml
service "wpfrontend" created

# oc get svc
...
`wpfrontend` LoadBalancer   172.30.86.159   172.29.93.103,172.29.93.103   80:31074/TCP   45s
```
 **步骤12. 创建路由**

```bash
*# oc expose svc wpfrontend \
   --hostname=blog.apps.lab.example.com
route "wpfrontend" exposed

# oc get route
NAME        HOST/PORT                   PATH  SERVICES     PORT  TERMINATION  WILDCARD
wpfrontend `blog.apps.lab.example.com`        wpfrontend   `80`                 None
```

 **步骤13. 测试**

**[student@workstation]**

> **firefox** http://blog.apps.lab.example.com/
>
> - **Welcome**
>   ​		Site Title	**EX280**
>   ​		Username	**ayumi**
>   ​		Password	**redhat**
>   ​		Confirm Password	:negative_squared_cross_mark: Confirm use of weak password
>   ​		Your Email	**ayumi@master.lab.example.com**
>   ​		<kbd>Install WordPress</kbd>

![image-20210905003745553](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905003745553.png)

> - **Success!**
>   ​		<kbd>Log In</kbd>
>

![image-20210905003936089](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905003936089.png)

> - **Login**
>   ​		Username or Email address. **ayumi**
>   ​		Password  **redhat**
>     	<kbd>Log In</kbd>
> 

![image-20210905004032924](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905004032924.png)

> - **Dashboard**
>
>  ​		<kbd>Write your first blog post</kbd>
>
> ​					Add New Post **EX280**
>
>   ​				**faber est quisque fortunae suae.**
>  ​				 <kbd>Publish</kbd>
>
>   ​		[View post]()

![image-20210905004304831](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905004304831.png)

![image-20211011164526633](https://gitee.com/suzhen99/redhat/raw/master/images/image-20211011164526633.png)

![image-20211011164548850](https://gitee.com/suzhen99/redhat/raw/master/images/image-20211011164548850.png)

![image-20211011164601976](https://gitee.com/suzhen99/redhat/raw/master/images/image-20211011164601976.png)



## 6. Create an application with a secure edge-terminated route-c3

> - [ ] Create an application **greeter** in the project **samples**
> - [ ] which uses the Docker image **registry.lab.example.com/openshift/hello-openshift** 
> - [ ] so that it is reachable at the following address only: **https://greeter.apps.lab.example.com**
> (Note you can use the script **http://materials/gencert.sh** to generate the necessary certificate files.)

**[root@master]**

 **步骤1. 生成证书**

```bash
*# wget http://materials/gencert.sh \
   -O gencert.sh

考试时不用修改，直接执行脚本时使用-i选项加域名参数
# cat gencert.sh 
*# sed -i 's/cloud//g' gencert.sh
# cat gencert.sh
```
```bash
#!/bin/bash

echo "Generating a private key..."
openssl genrsa -out greeter.apps.lab.example.com.key 2048
echo

echo "Generating a CSR..."
openssl req -new -key greeter.apps.lab.example.com.key -out greeter.apps.lab.example.com.csr -subj "/C=US/ST=NC/L=Raleigh/O=RedHat/OU=RHT/CN=greeter.apps.lab.example.com"
echo

echo "Generating a certificate..."
openssl x509 -req -days 366 -in greeter.apps.lab.example.com.csr -signkey greeter.apps.lab.example.com.key -out greeter.apps.lab.example.com.crt
echo
echo  "DONE."
echo
```
```bash
*# bash gencert.sh
Generating a private key...
Generating RSA private key, 2048 bit long modulus
................+++
.......+++
e is 65537 (0x10001)

Generating a CSR...

Generating a certificate...
Signature ok
subject=/C=US/ST=NC/L=Raleigh/O=RedHat/OU=RHT/CN=greeter.apps.lab.example.com
Getting Private key

DONE.

# ls greeter.apps.lab.example.com.*
greeter.apps.lab.example.com.crt
greeter.apps.lab.example.com.csr
greeter.apps.lab.example.com.key
```
 **步骤2. 切换项目、创建应用**

```bash
*# oc project samples
Now using project "samples" on server "https://master.lab.example.com:443".

# oc new-app -h | grep image.*name
oc new-app --docker-image=myregistry.com/mycompany/mysql --name=private

*# oc new-app \
   --docker-image=registry.lab.example.com/openshift/hello-openshift \
   --name=greeter
--> Found Docker image 7af3297 (22 months old) from registry.lab.example.com for "registry.lab.example.com/openshift/hello-openshift"
...
```
 **步骤3. 使用证书，创建边界路由**

```bash
# oc get svc
NAME    TYPE      CLUSTER-IP     EXTERNAL-IP PORT(S)            AGE
`greeter` ClusterIP 172.30.225.190 <none>      8080/TCP,8888/TCP  6m

# oc create route edge -h
*# oc create route edge \
   --service=greeter \
   --hostname=greeter.apps.lab.example.com \
   --key=greeter.apps.lab.example.com.key \
   --cert=greeter.apps.lab.example.com.crt 
route "greeter" created
```

 **步骤4. 验证**

-CLI

```bash
# curl -k https://greeter.apps.lab.example.com
Hello OpenShift!
```

-GUI

**[student@workstation]**

```bash
$ firefox https://greeter.apps.lab.example.com &
Hello OpenShift!
```



## 7. Configure OpenShift quotas for a project-c9
> Configure quotas and limits for project **shrimp** so that:  
> - [ ] The ResourceQuota resource is named **ex280-quota**  
>   - [ ] The amount of **memory** consumed across all containers may not exceed **1Gi**  
>   - [ ] The total amount of **CPU** usage consumed across all containers may not exceed **2** Kubernetes compute units.  
>   - [ ] The maximum number of **replication controllers** does not exceed **3**  
>   - [ ] The maximum number of **pods** does not exceed **3**  
>   - [ ] The maximum number of **service** does not exceed **6**  
> - [ ] The LimitRange resource is named **ex280-limits**  
>   - [ ] The amount of **memory** consumed by a single **pod** is between **5Mi** and **300Mi**  
>   - [ ] The amount of **memory** consumed by a single **container** is between **5Mi** amd **300Mi** with a default request value of **100Mi**.  
>   - [ ] The amount of **cpu** consumed by a single **pod** is between **10m** and **500m**  
>   - [ ] The amount of **cpu** consumed by a single **container** is between **10m** and **500m** with a default request value of **100m**

**[kiosk@foundation]**

 **步骤1. 查手册**

> **firefox** http://materials/docs/html/cluster_administration/
>
>   - 17.6 Sample Resource Quota Definitions
>   - 19.1. Overview
>     				***Core Limit Range Object Definition**

**[root@master]**

 **步骤2. 创建配额，注意项目**

```bash
*# vim quota.yml
```

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ex280-quota
spec:
  hard:
    limits.memory: 1Gi
    limits.cpu: "2" 
    replicationcontrollers: "3" 
    pods: "3" 
    services: "10"
```

```bash
*# oc apply \
     -f quota.yml \
     -n shrimp
resourcequota "ex280-quota" created

# oc get quota -n shrimp
NAME          AGE
ex280-quota   55s

# oc describe quota ex280-quota -n shrimp
Name:                   ex280-quota
Namespace:              shrimp
Resource                Used  Hard
--------                ----  ----
limits.cpu              0     2
limits.memory           0     1Gi
pods                    0     3
replicationcontrollers  0     3
services                0     10
```
 **步骤3. 创建限制，注意项目**

```bash
*# vim limits.yml
```

```yaml
apiVersion: "v1"
kind: "LimitRange"
metadata:
  name: "exam-limits"
spec:
  limits:
    - type: "Pod"
      max:
        cpu: "500m"
        memory: "300Mi"
      min:
        cpu: "10m"
        memory: "5Mi"
    - type: "Container"
      max:
        cpu: "500m"
        memory: "300Mi"
      min:
        cpu: "10m"
        memory: "5Mi"
      defaultRequest:
        cpu: "100m"
        memory: "100Mi"
```

```bash
*# oc apply -f limits.yml -n shrimp
limitrange "exam-limits" created

# oc get limits -n shrimp
NAME          AGE
`exam-limits` 56s

# oc describe limits exam-limits -n shrimp
Name:       exam-limits
Namespace:  shrimp
Type        Resource  Min  Max    Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---  ---    ---------------  -------------  ---
Pod         cpu       10m  500m   -                -              -
Pod         memory    5Mi  300Mi  -                -              -
Container   memory    5Mi  300Mi  100Mi            300Mi          -
Container   cpu       10m  500m   100m             500m           -
```



## 8. Create an application from a third party template-c7

> On **master.lab.example.com** using the template file in  **http://materials/gogs** as a basis,
> install an application in the **ditto** project according to the following requirements:
>
> - [ ] All of the registry entries must point to your local registry at **registry.lab.example.com**
> - [ ] The version in the **ImageStream** line for the postgresql image must be changed from **postgresql:9.5** to **postgresql:9.2**
> - [ ] For the Gogs pod, use the Docker image from  **http://materials/gogs.tar** and make sure it is tagged as **registry.lab.example.com/openshiftdemos/gogs:0.9.97** and pushed to your local registry
> - [x] Mask the template gogs available across **all projects** and for **all users**
> - [ ] Deploy the appllication using the template, setting the parameter **HOSTNAME** to **gogs.apps.lab.example.com**
> - [ ] Create a user **salvo** with password **redhat** and email address **salvo@master.lab.example.com** on the application frontend
> (use the Register link on the top right of the page at    **http://gogs.apps.lab.example.com**) and, as this user, create a Git repository named **ex280**
> - [ ] If there isn't one already, create a file named **README.md** in the repository **ex280** and put the line **faber est quisque fortunae suae** in it and commit it.
> - [ ] The repository must be visible and accessible

**[kiosk@foundation]**

 **步骤1. 浏览文件**

> **firefox** http://materials/gogs

![image-20210905205748579](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905205748579.png)

**[root@master]**

 **步骤2. 创建模板**

```bash
*# wget http://materials/gogs/gogs-temp.yaml

*# vim gogs-temp.yaml
```

```yaml
kind: Template
apiVersion: v1
metadata:
  annotations:
    description: The Gogs git server (https://gogs.io/)
    tags: instant-app,gogs,go,golang
  name: gogs
...
    triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
        - postgresql
        from:
          kind: ImageStreamTag
#         name: postgresql:9.5
          name: postgresql:9.2
...
- kind: ImageStream
...
  spec:
    tags:
    - name: "${GOGS_VERSION}"
      from:
        kind: DockerImage
#       name: workstation.lab.example.com:5000/openshiftdemos/gogs:0.9.97
        name: registry.lab.example.com/openshiftdemos/gogs:0.9.97
...
```
```bash
*# oc create -f gogs-temp.yaml \
   -n openshift
template "gogs" created

# oc get template -n openshift | grep gog
`gogs`  The Gogs git server (https://gogs.io/)  13 (1 blank)  10
```
 **步骤3. 上传容器镜像**

```bash
*# wget http://materials/gogs.tar

*# docker load -i gogs.tar
...
Loaded image: openshiftdemos/gogs:latest

# docker images |  grep gog
openshiftdemos/gogs  latest  d44302ef5b2f  2 years ago  449 MB

*# docker tag \
  openshiftdemos/gogs:latest \
registry.lab.example.com/openshiftdemos/gogs:0.9.97

# docker images | grep gog
registry.lab.example.com/openshiftdemos/gogs  0.9.97  d44302ef5b2f   2 years ago   449 MB
openshiftdemos/gogs                           latest  d44302ef5b2f   2 years ago   449 MB
```


```bash
*# docker push \
registry.lab.example.com/openshiftdemos/gogs:0.9.97
...
0.9.97: digest: sha256:483a06aac04eb028ae1ddbd294954ba28d7c16b32fc5fca495f37d8e6c9295de size: 1160
```

**[student@workstation]**

```bash
$ docker-registry-cli \
    registry.lab.example.com \
    search gogs \
    ssl
...
1) Name: openshiftdemos/gogs
Tags: 0.9.97	

1 images found !
```

 **步骤4. 切换项目，创建应用**

**[root@master]**

```bash
*# oc project ditto
Now using project "ditto" on server "https://master.lab.example.com:443".

:<<EOF
oc new-app --template=ruby-helloworld-sample --param=MYSQL_USER=admin
EOF
*# oc new-app \
   --template=gogs \
   --param=HOSTNAME=gogs.apps.lab.example.com
...

# oc get pod -w
NAME                     READY  STATUS   RESTARTS  AGE
gogs-1-2tdcd             0/1    Running  3         1m
gogs-1-deploy            1/1   `Running`  0         1m
gogs-postgresql-1-wg8n2  1/1   `Running`  0         1m

# oc patch scc restricted \
  -p '{"runAsUser":{"type":"RunAsAny"}}'
```

 **步骤5. 验证**

**[student@workstation]**

> **firefox** http://gogs.apps.lab.example.com

> - **register** >
>   				Username **salvo**
>         Email **salvo@master.lab.example.com** 
>         Password **redhat**
>         Retype **redhat**
>         <kbd>Create New Account</kbd>
>

![image-20210905211126269](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905211126269.png)

![image-20210905211238779](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905211238779.png)

> - **Sign in**
>   	Username or email **salvo**
>      				Password **redhat**
>      				<kbd>Sign In</kbd> 

![image-20210905211335094](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905211335094.png)

> - **Dashboard**
>   	<kbd>My Repositories **+**</kbd>
>
> ​						"Repositories name"  **ex280**
> ​						<kbd>Create Repository</kbd>

![image-20210905211427620](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905211427620.png)

![image-20210905211532852](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905211532852.png)

> - **"salvo/ex280"**
>
> ​				HTTP "http://gogs.apps.lab.example.com/salvo/ex280.git"

![image-20210905211607738](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905211607738.png)

**步骤6. 创建README.md**

**[root@master]**

```bash
*# git clone \
http://gogs.apps.lab.example.com/salvo/ex280.git
Cloning into 'ex280'...
warning: You appear to have cloned an empty repository.

*# cd ex280/
*# echo faber est quisque fortunae suae > README.md

*# git add .
*# git commit -m "README"
[master (root-commit) c2e904d] README.md
 1 file changed, 1 insertion(+)
 create mode 100644 README.md
 
# git config --global push.default simple

*# git push
Counting objects: 3, done.
Writing objects: 100% (3/3), 246 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
Username for 'http://gogs.apps.lab.example.com': `salvo`
Password for 'http://salvo@gogs.apps.lab.example.com': `redhat`
To http://gogs.apps.lab.example.com/salvo/ex280.git
 * [new branch]      master -> master

*# cd
```

**步骤7. 验证**

**[student@workstation]**

> [ex280](http://gogs.apps.lab.example.com/salvo/ex280)

![image-20211012102612613](https://gitee.com/suzhen99/redhat/raw/master/images/image-20211012102612613.png)



## 9. Scale an application-c7

> Scale the application **greeter** in the project **samples** to a total of **5** replicas

<div style="background: #e7f2fa; padding: 12px; line-height: 24px; margin-bottom: 24px; ">
<dt style="background: #6ab0de; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; padding: 6px 12px; margin-bottom: 12px;" >Note - 注意</dt>
需先完成第6题
</div>

**[root@master]**

 **步骤1. 切换项目**

```bash
*# oc login -u ayumi -p redhat
Login successful.
...
Using project "farm".

*# oc project samples 
Now using project "samples" on server "https://master.lab.example.com:443".
```
 **步骤2. 缩放 Pod**

```bash
# oc get pods
NAME              READY     STATUS    RESTARTS   AGE
greeter-1-6ktkd   1/1       Running   0          3h

*# oc scale deploymentconfig \
   --replicas=5 \
   greeter 
deploymentconfig "greeter" scaled

# oc get pods
NAME              READY     STATUS    RESTARTS   AGE
greeter-1-6ktkd   1/1       Running   0          3h
greeter-1-mx7tc   1/1       Running   0          9s
greeter-1-p94nq   1/1       Running   0          9s
greeter-1-vgr9b   1/1       Running   0          9s
greeter-1-zp6vl   1/1       Running   0          9s
```



## 10. Install OpenShift metrics-c8
> On **master.lab.example.com** install the OpenShift Mertics component with the following requirements:
> - [ ] Use the storage **/exports/metrics** for **cassandra storage**. You can use the files on **http://materials/storage** for the pv sample.
> - [ ] Use the **inventory**, **ansible.cfg** in **/root/install-metrics/**
> - [ ] Use the playbook **/usr/share/ansible/openshift-ansible/playbooks/openshift-metrics/config.yml** for the installation
>   
>   **Use the following environmet variables:**
>   
>   - [ ] openshift_metrics_image_version=**3.9**
>   - [ ] openshift_metrics_heapster_requests_memory=**300M**
>   - [ ] openshift_metrics_hawkular_requests_memory=**750M**
>   - [ ] openshift_metrics_cassandra_requests_memory=**750M**
>   - [ ] openshift_metrics_cassandra_storage_type=**pv**
>   - [ ] openshift_metrics_cassandra_pvc_size=**5Gi**
>   - [ ] openshift_metrics_cassandra_pvc_prefix=**metrics**
>   - [ ] openshift_metrics_install_metrics=**True**

**[root@master]**

 **步骤1. 创建 pv**

```bash
*# oc login -u system:admin
Logged into "https://master.lab.example.com:443" as "system:admin" using existing credentials.
...
Using project "samples".

*# wget http://materials/storage/pv.yaml \
   -O pv.yaml

*# vim pv.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
# openshift_metrics_cassandra_pvc_prefix=metrics
# name: pv0001
  name: metric
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce
  nfs:
#   path: /db
    path: /exports/metrics
#   server: master.lab.example.com
    server: services.lab.example.com
  persistentVolumeReclaimPolicy: Recycle
```

```bash
*# oc create -f pv.yaml
persistentvolume "metric" created

# oc get pv | grep metric
metric  5Gi  RWO  Recycle  `Available`  31s
```

 **步骤2. 安装指标**

**[kiosk@foundation]**

> **firefox** http://materials/docs/html/installation_and_configuration
>
> ​		34.5.1. Specifying Metrics Ansible Variables

**[root@master]**

```bash
*# cd /root/install-metrics

*# vim inventory
```
> - openshift_metrics_image_prefix=registry.lab.example.com/openshift3/ose-
> - ==v==3.9

```ini
...
[OSEv3:vars]
...
openshift_metrics_image_prefix=registry.lab.example.com/openshift3/ose-
openshift_metrics_image_version=v3.9
openshift_metrics_heapster_requests_memory=300M
openshift_metrics_hawkular_requests_memory=750M
openshift_metrics_cassandra_requests_memory=750M
openshift_metrics_cassandra_storage_type=pv
openshift_metrics_cassandra_pvc_size=5Gi
openshift_metrics_cassandra_pvc_prefix=metrics
openshift_metrics_install_metrics=True
```
```bash
*# ansible-playbook \
   /usr/share/ansible/openshift-ansible/playbooks/openshift-metrics/config.yml
...
PLAY RECAP ```````````````````````````*****
localhost                   : ok=12  changed=0  unreachable=0  failed=0
master.lab.example.com      : ok=212 changed=47 unreachable=0  failed=0
node1.lab.example.com       : ok=0   changed=0  unreachable=0  failed=0
node2.lab.example.com       : ok=0   changed=0  unreachable=0  failed=0
services.lab.example.com    : ok=1   changed=0  unreachable=0  failed=0
workstation.lab.example.com : ok=4   changed=0  unreachable=0  failed=0

INSTALLER STATUS ```````````````````````````*****
Initialization             : Complete (0:00:25)
Metrics Install            : Complete (0:07:16)
```
 **步骤3. 验证**

```bash
# oc get pod \
  -n openshift-infra
NAME                     READY  STATUS RESTARTS   AGE
hawkular-cassandra-1-lqrzx 1/1  `Running` 0  7m
hawkular-metrics-42rh2     1/1  `Running` 0  40s
heapster-f9pfj             1/1  `Running` 0  40s

# oc get route \
  -n openshift-infra
NAME              HOST/PORT                               ...
hawkular-metrics  `hawkular-metrics.apps.lab.example.com` ...
```
**[student@workstation]**

> **firefox** https://hawkular-metrics.apps.lab.example.com

![image-20210904225138366](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210904225138366.png)

> **firefox**	https://master.lab.example.com
> 		Username	**salvo**
> 		Password	**redhat**
> 		<kbd>Login in</kbd>

![image-20210905192423138](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905192423138.png)

> <kbd>ditto</kbd> /
> 			<kbd>Applications</kbd>/ <kbd>pods</kbd> /
> 					<kbd>gogs</kbd> /
> 							 <kbd>Metrics</kbd>

![image-20210905220827162](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905220827162.png)

![image-20210905221238630](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905221238630.png)

![image-20210905221333299](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905221333299.png)

![image-20210905221433600](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905221433600.png)

![image-20210905221519289](https://gitee.com/suzhen99/redhat/raw/master/images/image-20210905221519289.png)