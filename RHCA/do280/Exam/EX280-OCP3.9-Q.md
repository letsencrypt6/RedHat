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



## 2. Configure persistent storage for the local registry-c6

> - [ ] Associate the share named **/exports/registry** to the **built-in registry** running within your OpenShift Enterprise instance so that it will be used for permanent storage
> - [ ] Use **exam-registry-volume** for the volume name and **exam-registry-claim** for the claim name
> - [ ] You can find sample YAML files on **http://materials/storage/**
> (Note: This task needs to be solved before any applications are created)


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


## 4. Create an application from a Git repository-c4
> Use the S2I functionality of your OpenShift instance to build an application in the **rome** project
>
> - [ ] Use the Git repository at **http://services.lab.example.com/php-helloworld** for the application source
> - [ ] Use the Docker image labeled **registry.lab.example.com/rhscl/php-70-rhel7** 
> - [ ] Once deployed, the application must be reachable（and browseable）at the following address:  **http://hellophp.apps.lab.example.com**
> - [ ] Update the original repository so that the **index.php** file contains the text from **http://materials/mordor.txt** instead of the word **PHP**
> - [ ] Trigger a rebuild so that when browsing **http://hellophp.apps.lab.example.com** it will display the new text


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


## 6. Create an application with a secure edge-terminated route-c3

> - [ ] Create an application **greeter** in the project **samples**
> - [ ] which uses the Docker image **registry.lab.example.com/openshift/hello-openshift** 
> - [ ] so that it is reachable at the following address only: **https://greeter.apps.lab.example.com**
> (Note you can use the script **http://materials/gencert.sh** to generate the necessary certificate files.)


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


## 9. Scale an application-c7

> Scale the application **greeter** in the project **samples** to a total of **5** replicas

<div style="background: #e7f2fa; padding: 12px; line-height: 24px; margin-bottom: 24px; ">
<dt style="background: #6ab0de; font-weight: bold; display: block; color: #fff; margin: -12px; margin-bottom: -12px; padding: 6px 12px; margin-bottom: 12px;" >Note - 注意</dt>
需先完成第6题
</div>


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


