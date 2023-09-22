#!/bin/bash

# 监听端口
N_LISTEN=8080
N_PATH=/usr/local/nginx

# 安装依赖包
yum -y install zlib zlib-devel openssl openssl-devel pcre pcre-devel gcc gcc-c++ autoconf automake make 

# 下载
wget http://nginx.org/download/nginx-1.21.6.tar.gz
# 解压
tar xf nginx-1.21.6.tar.gz
# 切换目录
cd nginx-1.21.6

# 配置
./configure --prefix=$N_PATH --with-http_ssl_module --with-stream
# 编译
make
# 编译安装
make install

# 修改配置文件
sed -i -e "/80;$/s/80/$N_LISTEN/" -e '/worker_processes/s/1/2/' $N_PATH/conf/nginx.conf
# 创建 service 文件
cat > /usr/lib/systemd/system/nginx.service << EOF
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target
[Service]
Type=forking
PIDFile=$N_PATH/logs/nginx.pid
ExecStartPre=/usr/bin/rm -f $N_PATH/logs/nginx.pid
ExecStartPre=$N_PATH/sbin/nginx -t
ExecStart=$N_PATH/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=mixed
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
# service 文件生效
systemctl daemon-reload

# 开机启动，立即启动
systemctl enable --now nginx.service

# 测试
curl http://localhost:8080 