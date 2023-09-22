#!/bin/bash

cat > /dev/null <<EOF
- 参考
    http://47.115.62.54/2021/11/13/linux_ackdo_use_wemeet_in_RHEL84%20/
- 环境
    RHEL 8.0
    kernel 4.18
EOF

# define vars
FILE_URL=https://updatecdn.meeting.qq.com/cos/196cdf1a3336d5dca56142398818545f/TencentMeeting_0300000000_2.8.0.1_x86_64.publish.deb

# define function
function user_perm {
    if [ $(id -u) -ne 0 ]; then
        echo -e "\nPlease use root\n"
        exit
    fi
}

function app_dep {
    wget -P /etc/yum.repos.d/ https://gitee.com/suzhen99/redhat/raw/master/centos-8-for-x86_64.repo
    yum -y install alien qt5-qtbase-gui qt5-qtwebkit qt5-qtx11extras libbsd
}

function app_extract {
    wget $FILE_URL
    # debian2rpm
    alien -r --scripts $(echo $FILE_URL | awk -F / '{print $6}')
    cd /
    rpm2cpio ~/wemeet-2.8.0.1-2.x86_64.rpm | cpio -ivm
}

function app_ldd {
    while ldd /opt/wemeet/bin/wemeetapp | grep -q not.*found; do
        for i in $(ldd /opt/wemeet/bin/wemeetapp | grep not.*found | awk -F '=>' '{print $1}' | sed 's/\t//'); do
                cp /opt/wemeet/lib/$i /lib64
        done
    done
}

function desktop_mod {
  sed -i -e '/Icon/s|=.*|=/opt/wemeet/splash_logo3x.png|' \
        -e '/Exec/s|=.*|=/opt/wemeet/bin/wemeetapp|' \
        /usr/share/applications/wemeetapp.desktop
}

# Main area
user_perm
app_dep
app_extract
app_ldd
desktop_mod
