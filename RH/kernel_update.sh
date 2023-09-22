#!/bin/bash

function install_kernel {
    # 导入公钥
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

    # 安装仓库文件
    #yum -y install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
    cat > /etc/yum.repos.d/elrepo.repo <<EOF
    ### Name: ELRepo.org Community Enterprise Linux Repository for el8
    ### URL: https://elrepo.org/

    [elrepo]
    name=ELRepo.org Community Enterprise Linux Repository - el8
    baseurl=https://mirrors.tuna.tsinghua.edu.cn/elrepo/elrepo/el8/x86_64/
    enabled=1
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org

    [elrepo-testing]
    name=ELRepo.org Community Enterprise Linux Testing Repository - el8
    baseurl=https://mirrors.tuna.tsinghua.edu.cn/elrepo/testing/el8/x86_64/
    enabled=0
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org

    [elrepo-kernel]
    name=ELRepo.org Community Enterprise Linux Kernel Repository - el8
    baseurl=https://mirrors.tuna.tsinghua.edu.cn/elrepo/kernel/el8/x86_64/
    enabled=1
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org

    [elrepo-extras]
    name=ELRepo.org Community Enterprise Linux Extras Repository - el8
    baseurl=https://mirrors.tuna.tsinghua.edu.cn/elrepo/extras/el8/x86_64/
    enabled=1
    gpgcheck=1
    gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
    EOF

    # 使用指定仓库，查看可用版本
    yum --disablerepo=\* --enablerepo=elrepo-kernel list available


    # 安装
    ## lt: Long Term support
    ## ml: MainLine stable
    yum -y install kernel-ml kernel-ml-devel
}

function uninstall_kernel {
    # 
    yum -y remove kernel-ml kernel-ml-devel
}


function confirm_kernel {
    # 确认内核
    rpm -qa | grep kernel
    # 查看系统启动默认版本
    grubby --default-kernel
}


# Mani Area
install_kernel
# 系统重启
reboot
confirm_kernel
# uninstall_kernel